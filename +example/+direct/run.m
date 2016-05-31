% You can name the constructor parameter identical to the dependency class
% name to avoid creating an InjectorConfig file.

injector = Injector();
myFirstInstance = injector.get(?example.direct.MyClass);
myOtherInstance = injector.get(?example.direct.MyClass);

assert(myFirstInstance ~= myOtherInstance);
assert(myFirstInstance.MyDependency == myOtherInstance.MyDependency);

clear injector myFirstInstance myOtherInstance
