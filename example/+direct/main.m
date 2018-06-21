% You can name the constructor parameter identical to the dependency class
% name to avoid creating an Package file.

injector = Injector();
myFirstInstance = injector.get(?direct.MyClass);
myOtherInstance = injector.get(?direct.MyClass);

assert(myFirstInstance ~= myOtherInstance);
assert(myFirstInstance.MyDependency == myOtherInstance.MyDependency);

clear injector myFirstInstance myOtherInstance
