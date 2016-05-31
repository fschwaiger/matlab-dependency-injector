% You can get objects of interface types, as long as they are mapped in the
% InjectorConfig class like MyInterface = 'MyClass'.
%
% See also example.interface.InjectorConfig

myClass = Injector().get(?example.interface.MyInterface);
assert(isa(myClass, 'example.interface.MyInterface'));

clear myClass