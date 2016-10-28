classdef MyClass < handle
    
    properties
        MyDependency % 1x1 example.basic.MyDependency
    end
    
    methods
        function self = MyClass(MyDependency)
            self.MyDependency = MyDependency;
        end
    end
end

