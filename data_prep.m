%% Run this file for each session.
%% find all events filenames
sessID = '0';
ef = regexdir(['~/snel/share/derived/DARPA_RAM/cmwt&resampled/session_' , sessID] , '^\d\d\d\.mat$');

ef = unique(ef);

numEvents = numel(ef);
load(ef{1})
numChannels = size(ecwt_r , 1);
numFreqs = size(ecwt_r , 2);
buffer = 150/2;

%% 

% [we , wi]  = s1.experiments('FR1').sessions(sessID).getwordevents();
% numEvents = numel(wi);


%% load all events data
disp('Loading event data...')
% events_all = cell(numEvents , 1);
events_all = zeros([numEvents , size(ecwt_r,1) , size(ecwt_r,2) , size(ecwt_r,3) - buffer*2-100], 'single'); % event X channel X freq X time

for ievent = 1 : numEvents
    load(ef{ievent}); 
    % do abs and cast to single (memory)
    curr_ev = single( abs( ecwt_r ) );
    events_all(ievent , : ,: ,:) = curr_ev( : , : , buffer+50+1 : end-buffer-50 );
end


%% Permute and reshape to calculate mean and std of each channel at each frequency
%PERMUTE%
events_all_tmp = permute(events_all , [2, 3, 1, 4]);

%RESHAPE%
events_all_tmp = reshape(events_all_tmp , size(events_all_tmp , 1) , size(events_all_tmp , 2) , []);


%% Calc mean and std of each channel at each frequency
avgs = mean(events_all_tmp , 3);
stds = std(events_all_tmp ,0, 3);

% reclaim some memory
% clear events_all_tmp

%% Calc zscore and take average for each freq/channel/event
zscored = num2cell(events_all , 4);


%% zscoring
disp('Calculating zscore...')
for ievent = 1:numEvents
    
    for ichannel = 1:numChannels
        for ifreq = 1:numFreqs
            zscored{ievent , ichannel , ifreq} =...
                mean( (zscored{ievent , ichannel , ifreq}...
                 - avgs(ichannel , ifreq)) ./ stds(ichannel , ifreq) );
        end
    end
end


%% Extract word event training data

trainingData = zscored;

%% Extract training labels
[we , ~] = s1.experiments('FR1').sessions(sessID).getwordevents;
trainingLabels = zeros(size(we));
for iwe = 1 : size(we , 2)
    trainingLabels(iwe) = we{iwe}.recalled;
end

%% save to disk
disp('Saving to disk...')
filename = fullfile('~/snel/share/derived/DARPA_RAM/training_testing_data/' , ['sess' sessID '.mat']);
save(filename , 'trainingData' , 'trainingLabels');


