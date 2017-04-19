classdef FR1 < experiment
    properties
        noffset
        poffset
        buffer
    end
    
    methods
        function obj = FR1(BASE_DIR , expInfo)
            obj@experiment(BASE_DIR , expInfo);
        end
        
    end
    
    methods
        function wList = getwordlist(obj , sessionID) 
            % get a list of used words in session sessionID of this
            % experiment
            wList = obj.sessions(sessionID).geteventfieldvalues('word');
        end
        
        function seteegrange(obj , range , buffer)
            % set epoch range and buffer for events' eeg data
            if isequal(size(range) , [1,2]) 
                obj.noffset = range(1);
                obj.noffset = range(2);
                obj.buffer = buffer;
            else
                error('Size of first argument should be (1,2)');
            end
        end
        
    end
    
end