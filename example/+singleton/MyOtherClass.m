classdef MyOtherClass < handle
    
    properties
        MyOtherDependency % 1x1 basic.MyDependency
    end
    
    methods
        function self = MyOtherClass(myDependency)
            self.MyOtherDependency = myDependency;
        end
    end
end

