classdef MyClass < handle
    
    properties
        DataProvider % 1x1 example.provider.Data
        Data = {}
    end
    
    methods
        function self = MyClass(dataProvider)
            self.DataProvider = dataProvider;
        end
        
        function addData(self, string)
            self.Data{end + 1} = self.DataProvider.get(string);
        end
    end
end

