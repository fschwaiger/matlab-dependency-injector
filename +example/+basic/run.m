% Dependencies are automatically resolved using the provided InjectorConfig
% class. As shown in this folder, that class should be abstract and hidden,
% its properties constant and methods static.

myClass = Injector().get(?example.basic.MyClass);
assert(isa(myClass, 'example.basic.MyClass'));
assert(isa(myClass.MyDependency, 'example.basic.MyDependency'));
assert(isequal(myClass.MyConfigArray, [1 2 3]));

clear myClass
