%% find all events filenames
ef = regexdir('~/snel/share/derived/DARPA_RAM/events_resampled_bp' , '^\d\d\d\.mat$');
ef = unique(ef);

numEvents = numel(ef);

load(ef{1})
numChannels = size(ecwt_r , 1);
numFreqs = size(ecwt_r , 2);

%% load all events data

% events_all = cell(numEvents , 1);
events_all = zeros([numEvents , size(ecwt_r)], 'single'); % event X channel X freq X time

for ievent = 1 : numEvents
    load(ef{ievent});
    % do abs and cast to single (memory)
    events_all(ievent , : ,: ,:) = single( abs( ecwt_r ) );
end

%% Permute and reshape to calculate mean and std of each channel at each frequency
%PERMUTE%
events_all_tmp = permute(events_all , [2, 3, 1, 4]);
disp(size(events_all_tmp))
%RESHAPE%
events_all_tmp = reshape(events_all_tmp , size(events_all_tmp , 1) , size(events_all_tmp , 2) , []);
disp(size(events_all))
%% Calc mean and std of each channel at each frequency
avgs = mean(events_all_tmp , 3);
stds = std(events_all_tmp ,0, 3);

% reclaim some memory
clear events_all_tmp

% avgChannels = mean(mean(mean(events_all,1) , 3) , 4);
% avgChannels2 = mean(reshape(permute(events_all , [2,1,3,4]) , size(events_all , 2) , []),2);
% stdChannels = std(std(std(events_all,1) , 3) , 4);
%% Calc zscore and take average for each freq/channel/event
zscored = num2cell(events_all , 4);
%%
for ievent = 1:numEvents
    
    for ichannel = 1:numChannels
        for ifreq = 1:numFreqs
            zscored{ievent , ichannel , ifreq} =...
                mean( (zscored{ievent , ichannel , ifreq}...
                 - avgs(ichannel , ifreq)) ./ stds(ichannel , ifreq) );
        end
    end
end

