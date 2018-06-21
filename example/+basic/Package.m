classdef (Abstract, Hidden) Package

    properties (Constant)
        myDependency = 'MyDependency' % package may be omitted
    end

    methods (Static)
        function value = myConfigArray()
            value = [1 2 3];
        end
    end
end

