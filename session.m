classdef session < handle
    properties
        allEvents
        mathEvents
        taskEvents
        eegData
    end
    
    properties
        
    end
    
    methods
        function obj = session(allEvents , taskEvents , mathEvents , eegData)
            obj.allEvents = allEvents;
            obj.mathEvents = mathEvents;
            obj.taskEvents = taskEvents;
            obj.eegData = eegData;
        end
        
        
    end
    
    methods (Access = protected)

    end    
        
    
end