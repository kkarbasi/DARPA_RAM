classdef session < handle
    properties
        allEvents
        mathEvents
        taskEvents
        eegData
    end
          
    properties
        
        sampleRate % eeg sample rate (Hz)
        nSamples % number of eeg samples
        
    end
    
    methods
        % constructor
        function obj = session(allEvents , taskEvents , mathEvents , eegData , sourceData)
            obj.allEvents = allEvents;
            obj.mathEvents = mathEvents;
            obj.taskEvents = taskEvents;
            obj.eegData = eegData;
            obj.sampleRate = sourceData.sample_rate;
            obj.nSamples = sourceData.n_samples;
        end
        
        function trimmedEEG = gettrimmedeeg(obj)
           % trim the eeg to include only recordings from the first event
           % to the last event
           
           i0 = obj.allEvents{1}.eegoffset;
           iend = obj.allEvents{end}.eegoffset;
           trimmedEEG = obj.eegData(i0 : iend , : );
           
        end
        
    end
    
    methods (Access = protected)

    end    
        
    
end