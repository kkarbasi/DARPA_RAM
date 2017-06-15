classdef FR1 < experiment
    properties
        noffset
        poffset
        buffer
    end
    properties
        spacing
        numFreqs
        numChannels
        numEvents

%         trialLength
        curr_sess % Most recent session that wavelet transform has been called on
%         weCWT %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<added for plots
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
            wList = obj.sessions.(sessionID).geteventfieldvalues('word');
        end
        
        function obj = seteegrange(obj , range , buffer)
            % set epoch range and buffer for events' eeg data
            
            if isequal(size(range) , [1,2]) 
                obj.noffset = range(1);
                obj.poffset = range(2);
                obj.buffer = buffer;
%                 obj.trialLength = range(1) + range(2) + 2*buffer;
                
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
        
        function obj = preptrainingdata(obj , sessionID , eegRange , buffer , freqRange , numFreqs , resampRate,trim)
            % Applying continuous Morlet wavelet transform
            
            % set eeg epoch range and frequency range and spacing
            % parameters:
            obj.curr_sess = sessionID;
            obj.numChannels = size(obj.sessions.(sessionID).eegData,2);
            obj.seteegrange(eegRange , buffer);
            obj.setspacing(freqRange , numFreqs);
            Fs = obj.sessions.(sessionID).sampleRate;
            sigLen = (sum(eegRange) + 2 * buffer)/(1000/Fs);
            
            
            % Trim eeg for all events:
            disp('Extracting word events'' EEG')
            [wordEvents , ~] = obj.sessions.(sessionID).getwordevents();
            obj.numEvents = numel(wordEvents);
            obj.sessions.(sessionID).wordEventsEEG = zeros(obj.numEvents , sigLen , size(obj.sessions.(sessionID).eegData,2));
            
            for ievent = 1:obj.numEvents
                tmp = ...
                    obj.sessions.(sessionID).geteventeeg(wordEvents{ievent}...
                    , obj.noffset , obj.poffset , obj.buffer);
                obj.sessions.(sessionID).wordEventsEEG(ievent , : , :) = tmp;
            end
            
            % now wordEventsEEG is of size (num word events , epoch
            % range(2800*2 ms) in paper) , num channels)
            % Executes the contwt_par function (vectorized wavelet
            % transform). Then log transforms the data, then resample at
            % 1/10 rate
            
            disp('Applying Morlet wavelet transform')
            
%             obj.sessions.(sessionID).wordEventsCWT = cell(size(obj.sessions.(sessionID).wordEventsEEG , 1),1);
            
            buffResampled = obj.buffer/(resampRate*(1000/Fs)); %buffer size after resampling
            trimResampled = trim/(resampRate*(1000/Fs));
            
            events_all = zeros([obj.numEvents , obj.numChannels ,...
                obj.numFreqs , sigLen/resampRate - buffResampled*2 - 2*trimResampled], 'single');
            % event X channel X freq X time
            
            for ievent = 1:size(obj.sessions.(sessionID).wordEventsEEG , 1)
                fprintf(['Processing word event ' num2str(ievent , '%03i')]);
                ecwt = contwt_par(squeeze(obj.sessions.(sessionID).wordEventsEEG(ievent , : , :)),...
                    1/Fs, 0, obj.spacing, 1.0/200.0, obj.numFreqs-1, 'MORLET', 5);
              
                % log transform
                ecwt = log(ecwt); 
                
                ecwt_r = zeros(obj.numChannels , obj.numFreqs , floor(size(ecwt , 3)/resampRate));
                for ielectrode = 1:size(obj.sessions.(sessionID).wordEventsEEG , 3)
                    ecwt_r(ielectrode , : , :) = resample(squeeze(ecwt(ielectrode , : , :))' , 1, resampRate)';
                end
                curr_ev = single( abs( ecwt_r ) );
                events_all(ievent , : ,: ,:) = curr_ev( : , : , buffResampled+trimResampled+1 : end-buffResampled-trimResampled );
%                 obj.sessions.(sessionID).wordEventsCWT{ievent} = ecwt_r;
                fprintf(repmat('\b',1,25))
            end
            disp([num2str(ievent) ' events was wavelet transformed and resampled'])
            
            % Permute and reshape to calculate mean and std of each channel at each frequency
            %PERMUTE%
            events_all_tmp = permute(events_all , [2, 3, 1, 4]);

            %RESHAPE%
            events_all_tmp = reshape(events_all_tmp , size(events_all_tmp , 1) , size(events_all_tmp , 2) , []);


            % Calc mean and std of each channel at each frequency
            avgs = mean(events_all_tmp , 3);
            stds = std(events_all_tmp ,0, 3);

            % reclaim some memory
            clear events_all_tmp

            % Calc zscore and take average for each freq/channel/event
            zscored = num2cell(events_all , 4);


            % zscoring
            disp('Calculating zscore...')
            for ievent = 1:obj.numEvents

                for ichannel = 1:obj.numChannels
                    for ifreq = 1:obj.numFreqs
                        zscored{ievent , ichannel , ifreq} =...
                            mean( (zscored{ievent , ichannel , ifreq}...
                             - avgs(ichannel , ifreq)) ./ stds(ichannel , ifreq) );
                    end
                end
            end


            % Extract word event training data

            obj.sessions.(sessionID).trainingData = zscored;
%             disp('done........size of training data =');
%             size(zscored)
            
            [we , ~] = obj.sessions.(sessionID).getwordevents;
            trainingLabels = zeros(size(we));
            for iwe = 1 : size(we , 2)
                trainingLabels(iwe) = we{iwe}.recalled;
            end
            obj.sessions.(sessionID).trainingLabels = trainingLabels;
            
        end
        
    end
    methods
        
    end
    
end