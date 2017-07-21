classdef session < handle
    properties
        allEvents
        mathEvents
        taskEvents
        eegData
        sessionID
    end
          
    properties
        sampleRate % eeg sample rate (Hz)
        nSamples % number of eeg samples
    end
    
    properties
        trainingData
        trainingLabels
%         wordEventsCWT % cell array: Morlet transformed, log transformed, and resampled word events
        wordEventsEEG % word events eeg
    end
    
    methods

        function obj = session(varargin)
            % Constructor
            if nargin>0
                allEvents = varargin{1}; taskEvents = varargin{2};
                mathEvents = varargin{3}; eegData = varargin{4};
                sourceData = varargin{5}; sessionID = varargin{6};
                
                obj.allEvents = allEvents;
                obj.mathEvents = mathEvents;
                obj.taskEvents = taskEvents;
                obj.eegData = eegData;
                obj.sampleRate = sourceData.sample_rate;

                if sourceData.sample_rate > 998 && sourceData.sample_rate < 1002; obj.sampleRate = 1000; end
                if sourceData.sample_rate > 498 && sourceData.sample_rate < 502; obj.sampleRate = 500; end
                if sourceData.sample_rate > 1598 && sourceData.sample_rate < 1602; obj.sampleRate = 1600; end

                obj.nSamples = sourceData.n_samples;
                obj.sessionID = sessionID;
            end
            
        end
        
        function trimmedEEG = gettrimmedeeg(obj)
           % trim the eeg to include only recordings from the first event
           % to the last event           
           i0 = obj.allEvents{1}.eegoffset;
           iend = obj.allEvents{end}.eegoffset;
           trimmedEEG = obj.eegData(i0 : iend , : );
           
        end
        
        function fields = geteventfields(obj)
            % Returns event field names
            fields = fieldnames(obj.allEvents{1});
        end
        
        function vals = geteventfieldvalues(obj , fieldName)
            % Returns list of values for fieldName of this session's events 

            vals = cellfun(@(x) {x.(fieldName)} , obj.allEvents);
            if ischar(vals{1})
                vals = unique(vals);
            else
                vals = num2cell(unique(cell2mat(vals)));
            end
        end
        
        function eventEEG = geteventeeg(obj , event , noffset , poffset , buffer)
            % Returns EEG data associated with an event. eeg is returned
            % from noffset ms before the event onset to poffset ms after. There
            % can also be a buffer (ms) added befor and after the epoch.
            
            div = 1000.0/obj.sampleRate;
            
            eegIdx = event.eegoffset;
            noffset = floor(noffset/div);
            poffset = floor(poffset/div);
            buffer = floor(buffer/div);
            eventEEG = obj.eegData( eegIdx - (noffset + buffer) : eegIdx + ...
                (poffset + buffer)-1 , : );
        end
        
        function [wordEvents , wei] = getwordevents(obj)
            % Returns a the word events of this session and the indices
            % associated with the word events
            numEvents = numel(obj.taskEvents);
            wordEvents = {};
            wei = []; % word event indices
            wec = 1; % word event count
            for ievent = 1 : numEvents
                if strcmp(obj.taskEvents{ievent}.type...
                        , 'WORD')
                    wordEvents{wec} =  obj.taskEvents{ievent};
                    wec = wec + 1;
                    wei = [wei ievent];
                end
                    
            end
            
        end
        
        function savetrainingdata(obj)
            
        end
        
        % Adding function for extracting LFADS data
        function seq = createLFADSseq(obj, noffset, poffset, ds_target, tpe)
            % numEvents: Number of events to create seq from
            % tpe: trials per event (to create multiple trials per each
            % event for LFADS input)
            % ds_target: downsample target (Hz)
            % 
            obj.zscoreallchannels();
            [wEvents , ~] = obj.getwordevents();
            numEvents = numel(wEvents);
%             if numEvents > numel(wei)
%                 error(['numEvents should be less than ' num2str(numel(wei))...
%                     ' (number of word events)']);
%             end
            iseq = 1;
            eegLength = (poffset + noffset)/(1000/ds_target);
            d = eegLength - 4*tpe;
            
            trialIdx = int32(linspace(0 , d , tpe+1)); 
%             trialIdx(2:end) = trialIdx(2:end) + eegLength-d;
            for ie = 1:numEvents
                rs_padding = 50; %ms
                weEEG = obj.geteventeeg(wEvents{ie} , noffset + rs_padding , poffset + rs_padding , 0); 
%                 figure; plot(weEEG(3:end-2,1));
                weEEG = resample(weEEG ,  ds_target ,obj.sampleRate);
                
                rs_padded_r = rs_padding/(1000/ds_target);
                weEEG = weEEG(rs_padded_r+1:end-rs_padded_r , :);
%                 figure; plot(weEEG(:,1));title('resampled')
%                 size(weEEG)
                
                for it = 1:numel(trialIdx)-1
                    
                    seq(iseq).trial = iseq;
                    seq(iseq).sessionId = obj.sessionID;
                    seq(iseq).ievent = ie;
                    seq(iseq).itrial = it;
                    seq(iseq).trialPerEvent = tpe;
                    seq(iseq).y = weEEG( trialIdx(it) + 1 : trialIdx(it+1)+eegLength-d,:)';
                    seq(iseq).fs = ds_target;
                    seq(iseq).dtMs = 1000/ds_target;
                    
                    
                    iseq= iseq + 1;
                end
            end
            
            
        end
        function zscoreallchannels(obj)
    %             obj.eegData = obj.eegData';
            means = mean(obj.gettrimmedeeg);
            stds = std(obj.gettrimmedeeg);
            obj.eegData = bsxfun(@rdivide, bsxfun(@minus, obj.eegData, means(:)'), stds(:)'); 

%             obj.eegData = obj.eegData';
        end

        
        function zscoreallchannelsByQuantile(obj)
            %             obj.eegData = obj.eegData';
            means = mean(obj.gettrimmedeeg);
            stds = std(obj.gettrimmedeeg);
            obj.eegData = bsxfun(@rdivide, bsxfun(@minus, obj.eegData, means(:)'), stds(:)');
            
            %             obj.eegData = obj.eegData';
        end

        function scaleZSback(obj)
            means = mean(obj.gettrimmedeeg);
            stds = std(obj.gettrimmedeeg);
            for ievent = 1:size(obj.wordEventsEEG,1)
                obj.wordEventsEEG(ievent , : , :) = ...
                    bsxfun(@plus , bsxfun(@times , squeeze(obj.wordEventsEEG(ievent , : , :))...
                    ,stds(:)') , means(:)');
            end
            
        end
        
    end
    
    methods (Access = protected)
%         function zscoreallchannels(obj)
% %             obj.eegData = obj.eegData';
%             means = mean(obj.eegData');
%             stds = std(obj.eegData');
%             obj.eegData = bsxfun(@rdivide, bsxfun(@minus, obj.eegData, means(:)), stds(:)); 
%             
% %             obj.eegData = obj.eegData';
%         end
    end    
        
    
end