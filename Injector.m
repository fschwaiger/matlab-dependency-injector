classdef Injector < handle
    % Resolves object dependencies automatically by class inspection.
    %
    % Usage:
    %   injector = Injector(knownDependency1, ...)
    %   injector = Injector('knownDependency1', value1, ...)
    %   injector = injector.with(knownDependency1, ...)
    %   injector = injector.with('knownDependency1', value1, ...)
    %
    %   instance = injector.get(?package.name.ClassName)
    %   instance = injector.get('package.name.ClassName')
    %   instance = injector.get('package.name', 'ClassName')
    %
    % To empty internal cache (if classes are modified):
    %   clear Injector
    %
    % To resolve class dependencies, the INJECTOR analyses the class'
    % definitions and notes all constructor input names. It then looks up
    % its internal cache of already resolved objects. If not present, the
    % corresponding static InjectorConfig class is consulted to map the
    % unknown dependencies to either classes or injector methods.
    %
    % Every package needs an InjectorConfig class. The unknown dependencies
    % are there looked up by name, first evaluating constant properties of
    % the required name, then static injector methods and class names.
    %
    % Step-by-step example, how the internals work:
    %   1) example.basic.MyClass has 2 parameters in its constructor:
    %        'myDependency', 'myConfigArray'
    %   2) The INJECTOR shall make an object of ?example.basic.MyClass:
    %        injector = Injector();
    %        myObject = injector.get(?example.basic.MyClass)
    %   3) The INJECTOR inspects the constructor and finds
    %      'myDependency' and 'myConfigArray' - values yet unresolved.
    %   4) The INJECTOR opens the example.basic.InjectorConfig class,
    %      searching its constant properties for the two dependency names.
    %   5) The INJECTOR finds 'myDependency' to be a redirect to
    %      'example.basic.MyDependency'.
    %   6) The INJECTOR changes scope to the example.basic package, looking
    %      up the example.basic.InjectorConfig, finding no more reference.
    %   7) The INJECTOR finds the example.basic.MyDependency class and
    %      instantiates it, as it has 0 dependencies.
    %   8) The INJECTOR escapes to its last scope (also 'example.basic'), 
    %      looking up the example.basic.InjectorConfig class for 
    %      'myConfigArray'.
    %   9) The INJECTOR resolves 'myConfigArray' to the
    %      example.basic.InjectorConfig.myConfigArray() method.
    %  11) Using the return value from myConfigArray(), the CodeWorkflow
    %      handle can finally be instantiated.
    %
    % You can inject handles by specifying either their class names or
    % meta.classes. It is also possible to inject various other types, as
    % returned by their corresponding InjectorConfig methods. Parameters to
    % these InjectorConfig methods are also recursively resolved.
    %
    % To speed up resolving, already resolved dependencies are stored in a
    % containers.Map cache for fast lookup.
    %
    % Builtin automatically resolved dependencies are:
    %   injector  -  Resolves to the currently active INJECTOR handle.
    %   scope     -  Resolves to the current package name.
    %   folder    -  Resolves to the current package folder (absolute).
    %
    % INJECTOR methods:
    %   with  -  Save dependencies by name. The variable name is used.
    %   get   -  Resolve meta.class or config string to a value.
    %
    % See also inputname, meta.class, meta.method, meta.property
    
    % The MIT License (MIT)
    % 
    % Copyright (c) 2016 Florian Schwaiger (fschwaiger@gmail.com)
    % 
    % Permission is hereby granted, free of charge, to any person obtaining
    % a copy of this software and associated documentation files (the
    % "Software"), to deal in the Software without restriction, including
    % without limitation the rights to use, copy, modify, merge, publish,
    % distribute, sublicense, and/or sell copies of the Software, and to
    % permit persons to whom the Software is furnished to do so, subject to
    % the following conditions:
    % 
    % The above copyright notice and this permission notice shall be
    % included in all copies or substantial portions of the Software.
    % 
    % THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    % EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    % MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    % NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
    % BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
    % ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    % CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    % SOFTWARE.
    
    properties (Access = private)
        Resolved@containers.Map
    end
    
    methods
        function self = Injector(varargin)
            % New injector instance with known dependencies as params.
            %
            % Usage:
            %   injector = Injector(knownDependency1, ...)
            %   injector = Injector('knownDependency1', value1, ...)
            %
            % NOTE: the variable names of your input parameters do matter!
            % The variable names will be used to store the known
            % dependencies. A wrong parameter name will result in an
            % unresolvable dependency. Specify the name as a string before,
            % if you cannot change your variable names to match.
            %
            % See also inputname
            self.Resolved = containers.Map();
            
            names = arrayfun(@inputname, 1:nargin, 'Uniform', false);
            self.saveAsResolved(names, varargin);
        end
        
        function self = with(self, varargin)
            % Add more known dependencies on-the-fly.
            %
            % Usage:
            %   injector = injector.with(knownDependency1, ...)
            %   injector = injector.with('knownDependency1', value1, ...)
            %
            % NOTE: the variable names of your input parameters do matter!
            % The variable names will be used to store the known
            % dependencies. A wrong parameter name will result in an
            % unresolvable dependency. Specify the name as a string before,
            % if you cannot change your variable names to match.
            %
            % See also Injector/Injector, inputname
            names = arrayfun(@inputname, 2:nargin, 'Uniform', false);
            self.saveAsResolved(names, varargin);
        end
        
        function value = get(self, varargin)
            % Resolves a new value and saves it.
            %
            % Usage:
            %   value = injector.get(?meta.class)
            %   value = injector.get('package.name', 'methodOrClass')
            %   value = injector.get('package.name.methodOrClass')
            %
            % Resolves the dependencies of the specifed class / method and
            % returns its handle / value. Classes will then be remembered as
            % their truncated ClassName, methods and redirects by their names.
            [scope, name, path] = resolveArguments(varargin);
            
            if strcmp(name, 'scope')
                % current package name, empty if outside any package
                value = scope;
            elseif strcmp(name, 'injector')
                % reference to currently invoking injector
                value = self;
            elseif strcmp(name, 'folder')
                % absolute path to current package folder
                value = fileparts(which(joinPath(scope, 'InjectorConfig')));
            elseif isKey(self.Resolved, name)
                % resolved value from cache
                value = self.Resolved(name);
            elseif strcmp(name, 'varargin')
                % varargin is optional, if unresolved
                value = {};
            else
                % resolve value by invoking a function
                value = self.resolveMethodValue(scope, name, path);
            end
        end
    end
    
    methods (Access = private)
        function saveAsResolved(self, names, values)
            % Saves the given values as resolved by the given names.
            index = 1;
            while index <= length(names)
                name = names{index};
                
                if isempty(name)
                    name = values{index};
                    value = values{index + 1};
                    index = index + 2;
                else
                    value = values{index};
                    index = index + 1;
                end
                
                self.Resolved(name) = value;
            end
        end
        
        function value = resolveMethodValue(self, scope, name, path)
            % Executes a function handle to resolve the specified value.
            methodInfo = resolveInjectorMethod(scope, name, path);
                
            dependencies = cellfun( ...
                @(name) self.get(methodInfo.Scope, name), ...
                methodInfo.Parameters, 'Uniform', false);
            self.saveAsResolved(methodInfo.Parameters, dependencies);

            if ~isempty(dependencies) && strcmp(methodInfo.Parameters{end}, 'varargin')                    
                value = methodInfo.Function(dependencies{1:end-1}, dependencies{end}{:});
            else 
                value = methodInfo.Function(dependencies{:});
            end
        end
    end
end

function [scope, name, path] = resolveArguments(arguments)
    % Resolves the varargin to scope, name and path.
    if isscalar(arguments)
        if isa(arguments{1}, 'meta.class')
            path = arguments{1}.Name;
            [scope, name] = splitPath(path);
        else
            [scope, name, path] = normalizePath('', arguments{1});
        end
    else
        [scope, name, path] = normalizePath(arguments{:});
    end
end

function methodInfo = resolveInjectorMethod(scope, name, path)
    % Resolves a struct with all injection information.
    %
    % Inputs:
    %   scope  -  Package where name will be resolved.
    %   name   -  Name of class or InjectorConfig function within scope.
    %   path   -  Combined scope and name. See joinPath(scope, name).
    %
    % Returns a scalar struct with the fields:
    %   Function    -  1x1 function_handle that will be executed to resolve
    %                  the dependency.
    %   Parameters  -  Cell array of strings, lists all names of the
    %                  function handle parameters for quick access.
    %   Scope       -  String referring to the package scope of the method.
    %
    % See also resolveInjectorConfigMethod, resolveClassContructorMethod
    
    % internal cache for resolved function handles
    persistent methodCache
    if isempty(methodCache)
        methodCache = containers.Map();
    end
    
    if isKey(methodCache, path)
        methodInfo = methodCache(path);
    else
        try
            methodInfo = resolveInjectorConfigMethod(scope, name);
        catch
            methodInfo = resolveClassContructorMethod(scope, name, path);
        end

        % do not resolve the method again, keep access in cache
        methodCache(path) = methodInfo;
    end
end

function methodInfo = resolveInjectorConfigMethod(scope, name)
    % Resolves the scope.InjectorConfig.name property or function.
    %
    % See also resolveInjectorMethod
    configPath = joinPath(scope, 'InjectorConfig');
    configClass = meta.class.fromName(configPath);
    
    configProperty = findobj(configClass.PropertyList, 'Name', name);
    if ~isempty(configProperty)
        path = configProperty.DefaultValue;
        [scope, name, path] = normalizePath(scope, path);
        methodInfo = resolveInjectorMethod(scope, name, path);
        return
    end
    
    configMethod = findobj(configClass.MethodList, 'Name', name);
    if ~isempty(configMethod)    
        methodInfo.Function = str2func([configPath '.' name]);
        methodInfo.Parameters = configMethod.InputNames;
        methodInfo.Scope = scope;
        return
    end
    
    error('No field or method ''%s'' in class ''%s''.', name, configPath);
end

function methodInfo = resolveClassContructorMethod(scope, name, path)
    % Resolves a class constructor method or fails if no such class exists.
    %
    % See also resolveInjectorMethod
    metaClass = meta.class.fromName(path);
    if ~isempty(metaClass)
        classConstructor = findobj(metaClass.MethodList, 'Name', name);
        if ~isempty(classConstructor)
            methodInfo.Parameters = classConstructor.InputNames;
        else
            methodInfo.Parameters = {};
        end

        methodInfo.Function = str2func(path);
        methodInfo.Scope = scope;
    else
        error('Injector:MissingDependency', ...
            'Cannot inject ''%s'' in scope ''%s''.', name, scope);
    end
end

function [scope, name, path] = normalizePath(scope, name)
    % Resolves scope and name into class paths.
    %
    % ('scope1',        'name') -> ['scope1', 'name', 'scope1.name']
    % ('scope1', 'scope2.name') -> ['scope2', 'name', 'scope2.name']
    if any(name == '.')
        path = name;
        [scope, name] = splitPath(path);
    else
        path = joinPath(scope, name);
    end
end
   
function [scope, name] = splitPath(path)
    % Splits 'scope.test.class' into 'scope.test' and 'class'
    for dot = length(path) : -1 : 1
        if path(dot) == '.'
            break
        end
    end
    
    scope = path(1:dot-1);
    name = path(1+dot:end);
end

function path = joinPath(scope, name)
    % Combines 'scope' and 'name' to 'scope.name'
    path = [scope '.' name];
    if path(1) == '.'
        path = path(2:end);
    end
end

