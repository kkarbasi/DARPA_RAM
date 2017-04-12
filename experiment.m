classdef experiment < handle
    properties
        BASE_DIR
        type
        expPath
        sessions = containers.Map
        
    end
    properties (Access = protected)
        
        
    end
    
    methods
        function obj = experiment(type , BASE_DIR , expPath)
            obj.type = type;
            obj.BASE_DIR = BASE_DIR;
            obj.expPath = expPath;
            
            
        end    
        
        function addSessions(obj)
            
            
        end
        
    end
    
    properties(Dependent)
        
    end
    
end