classdef MyOtherClass < handle
    
    properties
        MyOtherDependency % 1x1 example.basic.MyDependency
    end
    
    methods
        function self = MyOtherClass(myDependency)
            self.MyOtherDependency = myDependency;
        end
    end
end

