% If you instantiate multiple classes with the same dependency (identical
% constructor parameter name), they will receive the same handle.

injector = Injector();
myFirstInstance = injector.get(?example.singleton.MyFirstClass);
myOtherInstance = injector.get(?example.singleton.MyOtherClass);

assert(myFirstInstance.MyFirstDependency == myOtherInstance.MyOtherDependency);

clear myFirstInstance myOtherInstance injector