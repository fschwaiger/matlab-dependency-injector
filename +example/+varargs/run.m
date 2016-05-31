% You can specify 'varargin' as dependency too, it will be feeded into
% varargin constructor arguments as separate inputs.

arguments = {struct('this', 'is a fake object'), [4 5 6]};
injector = Injector('varargin', arguments);
myClass = injector.get(?example.varargs.MyClass);

assert(isa(myClass, 'example.varargs.MyClass'));
assert(isstruct(myClass.MyDependency));
assert(isequal(myClass.MyConfigArray, [4 5 6]));

% Also, you need not to specify varargin at all, it will be ignored.
myOtherClass = Injector().get(?example.varargs.MyClass);

assert(isempty(myOtherClass.MyDependency));
assert(isequal(myOtherClass.MyConfigArray, [1 2 3]));

clear myClass myOtherClass injector arguments