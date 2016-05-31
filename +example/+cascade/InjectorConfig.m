classdef (Abstract, Hidden) InjectorConfig
    
    methods (Static)
        function value = fileReader(injector, scope, fileReaderClass)
            value = injector.get(scope, fileReaderClass);
        end
        
        function className = fileReaderClass(fileExt)
            className = [upper(fileExt(1)), fileExt(2:end), 'FileReader'];
        end
        
        function extension = fileExt(fileName)
            [~, ~, extension] = fileparts(fileName);
            extension = extension(2:end);
        end
    end
end

