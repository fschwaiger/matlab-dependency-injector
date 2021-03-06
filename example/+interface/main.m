% You can get objects of interface types, as long as they are mapped in the
% Package class like MyInterface = 'MyClass'.
%
% See also example.interface.Package

myClass = Injector().get(?interface.MyInterface);
assert(isa(myClass, 'interface.MyInterface'));

clear myClass