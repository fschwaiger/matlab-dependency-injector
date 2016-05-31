# matlab-dependency-injector

TL;DR: Automated dependency injector class for Matlab. Works by inspecting constructor and function parameter names and resolving classes and values by mappings provided by the user.


## Installation

Copy the file '__Injector.m__' to your project directory. The license is already included.

The +example and +test directories are optional, you will not need them for production.


## Why do I need this?

Working on one GUI project and another OOP project in Matlab, I discovered the need of an easy way to work with the (https://en.wikipedia.org/wiki/Dependency_injection) pattern in order to separate the wiring of dependencies from my production code.

In the beginning, I wrote a whole bunch of separate functions as factories that instantiated objects with all their dependencies. As you see, even with few dependencies, lots of code accumulates:

```Matlab
function loader = createLoader(fileName)
    reader = createReader(fileName);
    parser = createParser();
    loader = my.package.Loader(reader, parser);
end

function reader = createReader(fileName)
    reader = my.package.TxtFileReader(fileName);
end

function parser = createParser()
    config = getParserConfig();
    parser = my.package.Parser(config);
end

function config = getParserConfig()
    config = struct(....);
end
```

The problem is not the exposure of dependencies using the constructor injection method, but writing reusable methods to create appropriate instances. Also, when working with packages, I could not find a convenient way of organizing these functions. Note that matlab requires each function call within a package to expose the whole package path while no global imports are possible. The functions above in an __my.package__ hierarchy would be organized most likely as shown below.

You see, there is lots of duplicated code like the __my.package__ part, it soon becomes tedious to write.

```Matlab
% file '+my/+package/Injector.m'
classdef (Abstract, Hidden) Injector

    methods (Static)
        function loader = createLoader(fileName)
            reader = my.package.Injector.createReader(fileName);
            parser = my.package.Injector.createParser();
            loader = my.package.Loader(reader, parser);
        end

        function reader = createReader(fileName)
            reader = my.package.TxtFileReader(fileName);
        end

        function parser = createParser()
            config = my.package.Injector.getParserConfig();
            parser = my.package.Parser(config);
        end

        function config = getParserConfig()
            config = struct(....);
        end
    end
end
```


## Automating the Boring Stuff

The `Injector` class expects that if you are consistently naming your dependencies in your class constructors, it will find the values by looking up their names in the configuration file `InjectorConfig.m`. That is, you no longer write functions for each class, but only the minimal required configuration in each package:

```Matlab
% file '+my/+package/InjectorConfig.m'
classdef (Abstract, Hidden) InjectorConfig

    properties (Constant)
        reader = 'TxtFileReader' % you can omit the current package path
        parser = 'Parser'
    end

    methods (Static)
        function defaultConfig = parserConfig()
            defaultConfig = struct(....);
        end
    end
end
```

You now retrieve your loader simply like:

```Matlab
fileName = 'my_ini_file.txt';
loader = Injector(fileName).get(?my.package.Loader);
```


## Usage

__Please have a look at the examples in the _+example/_ folder.__

For starters, you can create class instances like that:

```Matlab
injector = Injector();
instance  = injector.get(?example.basic.MyClass);
```

You can even create instances from interfaces, if you configured it to be resolved as a concrete implementation in your `InjectorConfig` file:

```Matlab
injector = Injector();
instance = injector.get(?example.interface.MyInterface);
```

You provide user values needed for the resolving task (aka already resolved dependencies) directly via the constructor or the fluent with() method. Note how the variable name is also inspected to spare you from writing 'fileName' twice. This works similar to the Matlab builtin `table()` function.

```Matlab
fileName = 'my_ini_file.txt';
config = struct(....)
injector = Injector(fileName); % will be injected into 'fileName' constructor parameters
injector = injector.with(config);
```

Of course, you do not have to store the reference to the `Injector` every time, there are numerous options for inline code styles, all lines below do the same:

```Matlab
loader = Injector(fileName).get(?example.cascade.Loader);
loader = Injector().with(fileName).get(?example.cascade.Loader);
loader = Injector().with(fileName).get('example.cascade.Loader');
loader = Injector().with(fileName).get('example.cascade', 'Loader');
loader = Injector('fileName', someOtherVarname).get('example.cascade', 'Loader');
loader = Injector().with('fileName', someOtherVarname).get('example.cascade', 'Loader');
```


## Syntax of InjectorConfig

The `InjectorConfig.m` file is a static class that can be placed in every directory to map the dependencies of the classes therein. For static invokation of properties and methods, the syntax shall be like the following (pro tip: use this as a template):

```Matlab
classdef (Abstract, Hidden) InjectorConfig
    % INJECTORCONFIG - Maps package dependencies.

    properties (Constant)
        % Put dependencies resolved by named reference here.

        dependencyA = 'MyInterface'
        dependencyB = 'myFunctionInThisFile'
        dependencyC = 'other.package.ClassName'
        dependencyD = 'other.package.functionInInjectorConfigThere'
        MyInterface = 'MyConcreteClass'
    end
    
    methods (Static)
        % Put dependencies resolved by function calls here.
        % Besides your own parameters, the parameters 'scope', 'folder' or
        % 'injector' can always be injected automatically.

        % dynamic class resolving
        function instance = fileReader(injector, scope, fileExtension)
            instance = injector.get(scope, [ucfirst(fileExtension), 'FileReader']);
        end

        % lazy loading instances via a provider
        function provider = dataProvider(scope)
            provider.get = @() Injector().get(scope, 'Data');
        end

        % resolving a file name with the 'folder'
        function fileName = layoutFileName(folder)
            fileName = fullpath(folder, 'Layout.xml');
        end
    end
end
```

