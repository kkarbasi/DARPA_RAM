classdef FR1 < experiment
    properties
        noffset
        poffset
        buffer
    end
    properties
        spacing
        numFreqs
        
        curr_sess
        wordEventsCWT % cell array: Morlet transformed, log transformed, and resampled word events
        wordEventsEEG % word events eeg
    end
    
    methods
        function obj = FR1(BASE_DIR , expInfo)
            obj@experiment(BASE_DIR , expInfo);
        end
        
    end
    
    methods
%         function [wordEvents , wei] = getwordevents(obj , sessionID)
%             numEvents = numel(obj.sessions(sessionID).taskEvents);
%             wordEvents = {};
%             wei = []; % word event indices
%             wec = 1; % word event count
%             for ievent = 1 : numEvents
%                 if strcmp(obj.sessions(sessionID).taskEvents{ievent}.type...
%                         , 'WORD')
%                     wordEvents{wec} =  obj.sessions(sessionID).taskEvents{ievent};
%                     wec = wec + 1;
%                     wei = [wei ievent];
%                 end
%                     
%             end
%             
%         end
        
        function wList = getwordlist(obj , sessionID) 
            % get a list of used words in session sessionID of this
            % experiment
            wList = obj.sessions(sessionID).geteventfieldvalues('word');
        end
        
        function obj = seteegrange(obj , range , buffer)
            % set epoch range and buffer for events' eeg data
            
            if isequal(size(range) , [1,2]) 
                obj.noffset = range(1);
                obj.poffset = range(2);
                obj.buffer = buffer;
                
            else
                
                error('Size of first argument should be [1,2]');
            end
        end
        
        function obj = setspacing(obj , freqRange , numFreqs)
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
        
        function obj = cmwt(obj , sessionID , eegRange , buffer , freqRange , numFreqs)
            % Applying continuous Morlet wavelet transform
            
            % set eeg epoch range and frequency range and spacing
            % parameters:
            obj.curr_sess = sessionID;
            obj.seteegrange(eegRange , buffer);
            obj.setspacing(freqRange , numFreqs);
            disp('Extracting word events'' EEG')
            % Trim eeg for all events:
            [wordEvents , ~] = obj.sessions(sessionID).getwordevents();
            sigLen = (sum(eegRange) + 2 * buffer)/(1000/obj.sessions(sessionID).sampleRate);
            
            obj.wordEventsEEG = zeros(numel(wordEvents) , sigLen , size(obj.sessions(sessionID).eegData,2));
            for ievent = 1:numel(wordEvents)
                obj.wordEventsEEG(ievent , : , :) = ...
                    obj.sessions(sessionID).geteventeeg(wordEvents{ievent}...
                    , obj.noffset , obj.poffset , obj.buffer);
            end
            % now wordEventsEEG is of size (num word events , epoch
            % range(2800*2 ms) in paper) , num channels)
            
            % Executes the contwt_par function (vectorized wavelet
            % transform). Then log transforms the data, then resample at
            % 1/10 rate
            disp('Applying Morlet wavelet transform')
            Fs = obj.sessions(sessionID).sampleRate;
            obj.wordEventsCWT = cell(size(obj.wordEventsEEG , 1),1);
            for ievent = 1:size(obj.wordEventsEEG , 1)
                disp(['Processing word event ' num2str(ievent)]);
                ecwt = contwt_par(squeeze(obj.wordEventsEEG(ievent , : , :)),...
                    1/Fs, 0, obj.spacing, [], obj.numFreqs, 'MORLET', 5);
              
                % log transform
                ecwt = log(ecwt); 
                ecwt_r = zeros(size(ecwt,1) , size(ecwt , 2) , floor(size(ecwt , 3)/10));
                for ielectrode = 1:size(obj.wordEventsEEG , 3)
                    ecwt_r(ielectrode , : , :) = resample(squeeze(ecwt(ielectrode , : , :))' , 1, 10)';
                end
                obj.wordEventsCWT{ievent} = ecwt_r;

            end
        end
        
    end
    methods
        function obj = saveCWTResampled(obj, folderPath)
            for ievent = 1:numel(obj.wordEventsCWT)
                disp(['Saving event ' num2str(ievent)]);
                ecwt_r = obj.wordEventsCWT{ievent};
                save(fullfile(folderPath, [num2str(ievent,'%03i') '.mat']) ,  'ecwt_r');
                disp('saved')
            end
        end
        
    end
    
end