classdef InjectorTests < matlab.unittest.TestCase
    
    methods (Test)
        function injectorCreatesInstanceOfInterface(self)
            injector = Injector();
            instance = injector.get(?interface.MyInterface);
            
            self.verifyInstanceOf(instance, ?interface.MyInterface);
        end
        
        function injectorDoesNotSaveMultipleRequests(self)
            injector = Injector();
            instance1 = injector.get(?basic.MyClass);
            instance2 = injector.get(?basic.MyClass);
            
            self.verifyNotSameHandle(instance1, instance2);
        end
        
        function injectorIgnoresRedirects(self)
            injector = Injector();
            instance1 = injector.get(?interface.MyClass);
            instance2 = injector.get(?interface.MyInterface);
            
            self.verifyNotSameHandle(instance1, instance2);
        end
        
        function injectorSavesNamedDependencies(self)
            injector = Injector();
            instance1 = injector.get(?basic.MyClass);
            instance2 = injector.get(?basic.MyClass);
            
            self.verifySameHandle(instance1.MyDependency, instance2.MyDependency);
        end
        
        function injectorThrowsErrorIfDependencyIsMissing(self)
            injector = Injector();
            
            self.verifyError(@() injector.get(?cascade.Loader), ...
                'Injector:MissingDependency');
        end
        
        function injectorUsedProvidedDependencies(self)
            fileName = 'test.txt';
            loader = Injector(fileName).get(?cascade.Loader);
            
            self.verifyEqual(loader.FileReader.FileName, fileName);
        end
        
        function injectorWithDependencyInjectsThat(self)
            fileName = 'test.txt';
            injector = Injector();
            loader = injector.with(fileName).get(?cascade.Loader);
            
            self.verifyEqual(loader.FileReader.FileName, fileName);
        end
        
        function canUseStringToProvideDependency(self)
            otherName = 'test.txt';
            loader = Injector('fileName', otherName).get(?cascade.Loader);
            
            self.verifyEqual(loader.FileReader.FileName, otherName);
        end
        
        function canInjectClassWithoutNamespace(self)
            addpath('example/no_namespace');
            instance = Injector().get(?MyTopLevelClass);
            
            self.verifyInstanceOf(instance, 'MyTopLevelClass');
        end
    end
end

