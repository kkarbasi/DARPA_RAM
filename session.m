classdef session < handle
    properties
        BASE_DIR
        sid
        sstruct
    end
    
    properties
        eegPath
        allEvents
    end
    
    methods
        function obj = session(id , sessionStruct , eegPath , BASE_DIR)
            obj.sid = id;
            obj.sstruct = sessionStruct;
            obj.eegPath = eegPath;
            obj.BASE_DIR = BASE_DIR;
            
            
        end
        
        
    end
    
    methods (Access = protected)

        function loadallevents(obj)
            allEventsPath = obj.sstruct.(obj.sid).all_events;
            obj.allEvents = loadjson([obj.BASE_DIR allEventsPath]);
            
        end
    end    
        
    
end