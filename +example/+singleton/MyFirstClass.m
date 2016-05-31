classdef MyFirstClass < handle
    
    properties
        MyFirstDependency % 1x1 example.basic.MyDependency
    end
    
    methods
        function self = MyFirstClass(myDependency)
            self.MyFirstDependency = myDependency;
        end
    end
end

