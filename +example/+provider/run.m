% If some objects cannot be injected on construction time but later, you
% can use a provider scheme as shown by this example. The method at
% example.provider.InjectorConfig.dataProvider() returns an anonymous
% struct with only the function get(). Like this, you can treat the struct
% like an object and just call dataProvider.get(anyArguments) to receive a
% new object without specifying its exact type.
%
% Note that by consistently following this scheme (constructor dependency
% or via provider), no dependencies or references to Injector remain in the
% production code, making it as much reusable as possible. The only
% references to Injector can be found within the InjectorConfig files.

myClass = Injector().get(?example.provider.MyClass);
myClass.addData('hello');
myClass.addData('world');

assert(isa([myClass.Data{:}], 'example.provider.Data'));
assert(strcmp(myClass.Data{1}.String, 'hello'));
assert(strcmp(myClass.Data{2}.String, 'world'));
