classdef MyClass < handle
    
    properties
        MyDependency % 1x1 example.basic.MyDependency
        MyConfigArray % 1x3 double
    end
    
    methods
        function self = MyClass(myDependency, myConfigArray)
            self.MyDependency = myDependency;
            self.MyConfigArray = myConfigArray;
        end
    end
end

