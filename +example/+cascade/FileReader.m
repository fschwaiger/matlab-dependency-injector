classdef (Abstract) FileReader < handle
    
    properties
        FileName
    end
    
    methods
        function self = FileReader(fileName)
            self.FileName = fileName;
        end
    end
    
    methods (Abstract)
        contents = read(self);
    end
end

