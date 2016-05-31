classdef Loader < handle
    
    properties
        FileReader
    end
    
    methods
        function self = Loader(fileReader)
            self.FileReader = fileReader;
        end
        
        function load(self)
            fileContents = self.FileReader.read();
            % TODO
        end
    end
end

