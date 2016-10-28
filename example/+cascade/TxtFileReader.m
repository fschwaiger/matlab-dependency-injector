classdef TxtFileReader < cascade.FileReader
    
    methods
        function self = TxtFileReader(fileName)
            self@cascade.FileReader(fileName);
        end
        
        function contents = read(self)
            file = fopen(self.FileName, 'r');
            contents = fread(file);
        end
    end
end

