% Dependencies are automatically resolved using the provided Package
% class. As shown in this folder, that class should be abstract and hidden,
% its properties constant and methods static.

myClass = Injector().get(?basic.MyClass);
assert(isa(myClass, 'basic.MyClass'));
assert(isa(myClass.MyDependency, 'basic.MyDependency'));
assert(isequal(myClass.MyConfigArray, [1 2 3]));

clear myClass
