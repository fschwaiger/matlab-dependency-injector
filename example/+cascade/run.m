injector = Injector();

%% if no 'fileName' is specified, cannot create a Loader
try
    injector.get(?cascade.Loader);
catch exception
    assert(strcmp(exception.message, ...
        'Cannot inject ''fileName'' in scope ''cascade''.'));
end

%% only with 'fileName' provided, will create the appropriate instance
fileName = 'myvalues.txt';
loader = injector.with(fileName).get(?cascade.Loader);
assert(isa(loader.FileReader, 'cascade.TxtFileReader'));

clear injector fileName loader exception