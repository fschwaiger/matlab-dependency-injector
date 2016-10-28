classdef MyClass < handle
    
    properties
        MyDependency % 1x1 basic.MyDependency
        MyConfigArray % 1x3 double
    end
    
    methods
        function self = MyClass(varargin)
            values = {[], [1 2 3]};
            values(1:nargin) = varargin;
            
            [self.MyDependency, self.MyConfigArray] = values{:};
        end
    end
end

