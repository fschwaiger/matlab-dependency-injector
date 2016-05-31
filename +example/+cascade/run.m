injector = Injector();

%% if no 'fileName' is specified, cannot create a Loader
try
    injector.get(?example.cascade.Loader);
catch exception
    assert(strcmp(exception.message, ...
        'Cannot inject ''fileName'' in scope ''example.cascade''.'));
end

%% only with 'fileName' provided, will create the appropriate instance
fileName = 'myvalues.txt';
loader = injector.with(fileName).get(?example.cascade.Loader);
assert(isa(loader.FileReader, 'example.cascade.TxtFileReader'));

clear injector fileName loader exception