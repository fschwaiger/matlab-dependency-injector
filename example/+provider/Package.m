classdef (Abstract, Hidden) Package

    methods (Static)
        function provider = dataProvider(scope)
            provider.get = @(string) Injector(string).get(scope, 'Data');

            % provider is an anonymous struct with the pseudo-function
            % get(). get() can have as many arguments as you like, but
            % preferrably maximal one or two, or you might confuse the
            % argument order sooner or later.
        end
    end
end

