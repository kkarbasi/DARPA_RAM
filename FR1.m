classdef FR1 < experiment
    properties
        noffset
        poffset
        buffer
    end
    properties
        spacing
        numFreqs
        
        
        eventsEEG
    end
    
    methods
        function obj = FR1(BASE_DIR , expInfo)
            obj@experiment(BASE_DIR , expInfo);
        end
        
    end
    
    methods
        function wList = getwordorylist(obj , sessionID) 
            % get a list of used words in session sessionID of this
            % experiment
            wList = obj.sessions(sessionID).geteventfieldvalues('word');
        end
        
        function seteegrange(obj , range , buffer)
            % set epoch range and buffer for events' eeg data
            
            if isequal(size(range) , [1,2]) 
                obj.noffset = range(1);
                obj.poffset = range(2);
                obj.buffer = buffer;
                
            else
                
                error('Size of first argument should be [1,2]');
            end
        end
        
        function setspacing(obj , freqRange , numFreqs)
            % Set the spacing between log values based on desired frequency
            % range (freqRange) and number of frequencies in between
            % (numFreqs).
            if isequal(size(freqRange) , [1,2]) 
                obj.spacing = (log2(freqRange(2)) - log2(freqRange(1)))/numFreqs;
                obj.numFreqs = numFreqs;
            else
                error('Size of first argument should be [1,2]');

            end
        end
        
        function eventsEEG = cmwt(obj , sessionID , eegRange , buffer , freqRange , numFreqs)
            % Applying continuous Morlet wavelet transform
            
            % set eeg epoch range and frequency range and spacing
            % parameters:
            obj.seteegrange(eegRange , buffer);
            obj.setspacing(freqRange , numFreqs);
            
            % Trim eeg for all events:
            taskEvents = obj.sessions(sessionID).taskEvents;
            sigLen = (sum(eegRange) + 2 * buffer)/2;
            
            eventsEEG = zeros(numel(taskEvents) , sigLen , size(obj.sessions(sessionID).eegData,2));
%             parpool('local' , 2);
            for ievent = 1:numel(taskEvents)
                eventsEEG(ievent , : , :) = ...
                    obj.sessions(sessionID).geteventeeg(taskEvents{ievent}...
                    , obj.noffset , obj.poffset , obj.buffer);
            end
            % now eventsEEG is of size (num task events , epoch
            % range(2800*2 ms) in paper) , num channels)
           obj.eventsEEG = eventsEEG;
            
        end
        
        function ievent = dummy(obj)
            
            Fs = obj.sessions('0').sampleRate;
%             wave = zeros(size(obj.eventsEEG , 1) , size(obj.eventsEEG , 3) , obj.numFreqs+1 , 280);
%             wave = complex(wave , 0);
%             parpool('local' , 4)
            for ievent = 1:size(obj.eventsEEG , 1)
                disp('1')
                ecwt = contwt_par(squeeze(obj.eventsEEG(ievent , : , :)),...
                    1/Fs, 0, obj.spacing, [], obj.numFreqs, 'MORLET', 5);
                disp('2')
                ecwt = log(ecwt);
                ecwt_r = zeros(size(ecwt,1) , size(ecwt , 2) , floor(size(ecwt , 3)/10));
                for ielectrode = 1:size(obj.eventsEEG , 3)
                    ecwt_r(ielectrode , : , :) = resample(squeeze(ecwt(ielectrode , : , :))' , 1, 10)';
                end
%                 ecwt_r = ecwt(: , : , 1:10:2800);

                disp(['Saving event ' num2str(ievent)]);
%                 wave(ievent , :,:,:) = ecwt_r;
                save(['~/cosmic-home/DARPARAM/events_resampled_bp/' num2str(ievent,'%03i') '.mat'] ,  'ecwt_r');
%                 parfor ielectrode = 1:size(obj.eventsEEG , 3)
%                     [wave(ievent , ielectrode , : , :), ~, ~, ~, ~, ~, ~] = ...
%                         contwt(obj.eventsEEG(ievent , : , ielectrode), 1/Fs, 0, obj.spacing, [], obj.numFreqs, 'MORLET', 5);    
%                 end
                disp('saved')
            end
        end
        
    end
    
end