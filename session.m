classdef session < handle
    properties
        allEvents
        mathEvents
        taskEvents
        eegData
    end
          
    properties
        startTime % eeg start time (ms)
        sampleRate % eeg sample rate (Hz)
        nSamples % number of eeg samples
        
    end
    
    methods
        function obj = session(allEvents , taskEvents , mathEvents , eegData , sourceData)
            obj.allEvents = allEvents;
            obj.mathEvents = mathEvents;
            obj.taskEvents = taskEvents;
            obj.eegData = eegData;
            obj.startTime = sourceData.start_time_ms;
            obj.sampleRate = sourceData.sample_rate;
            obj.nSamples = sourceData.n_samples;
        end
        
    end
    
    methods (Access = protected)

    end    
        
    
end