%% find all events filenames
ef = regexdir('~/snel/share/derived/DARPA_RAM/events_resampled_bp' , '^\d\d\d\.mat$');

% ef = regexdir('~/cosmic-home/DARPARAM/events_resampled_bp/' , '^\d\d\d\.mat$');

% ef = regexdir('../session_1' , '^\d\d\d\.mat$');
ef = unique(ef);

numEvents = numel(ef);

load(ef{1})
numChannels = size(ecwt_r , 1);
numFreqs = size(ecwt_r , 2);
buffer = 150/2;
%% load all events data

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
% avgChannels2 = mean(reshape(per mute(events_all , [2,1,3,4]) , size(events_all , 2) , []),2);
% stdChannels = std(std(std(events_all,1) , 3) , 4);

%% Calc zscore and take average for each freq/channel/event
zscored = num2cell(events_all , 4);


%% trash
ievent = 10;
ichannel = 20;
ifreq = 30;


a  = (zscored{ievent , ichannel , ifreq} - avgs(ichannel , ifreq)) ./ stds(ichannel , ifreq);
disp(['std = ' num2str(std(squeeze(a)))])
disp(['avg = ' num2str(mean(squeeze(a)))])
disp('----------------------------')
%% trash 2 - test channel std after zscoring

ichannel = 105;
ifreq = 1;
as = [];
for ievent = 1:numEvents
        
   a =  (zscored{ievent , ichannel , ifreq} - avgs(ichannel , ifreq)) ./ stds(ichannel , ifreq);
   as = [as [squeeze(a)]'];

end

disp(['std = ' num2str(std(as))])
disp(['avg = ' num2str(mean(as))])
disp('----------------------------')

%% zscoring
for ievent = 1:numEvents
    
    for ichannel = 1:numChannels
        for ifreq = 1:numFreqs
            zscored{ievent , ichannel , ifreq} =...
                mean( (zscored{ievent , ichannel , ifreq}...
                 - avgs(ichannel , ifreq)) ./ stds(ichannel , ifreq) );
        end
    end
end

%% Get word event indices
sessID = '0';
[we , wi]  = s1.experiments('FR1').getwordevents(sessID);

%% Extract word event training data

trainingData = zscored(wi , : , :);

%% Extract training labels
trainingLabels = zeros(size(we));
for iwe = 1 : size(we , 2)
    trainingLabels(iwe) = we{iwe}.recalled;
end
%%
% addpath(genpath('~/cosmic-home/RAMstuff/logisticregress'));
% addpath(genpath('Y:/RAMstuff/logisticregress'));
addpath(genpath('./utils'));
addpath(genpath('./submodules'));
load traindata.mat
Y = trainingLabels';
X = reshape(trainingData, size(trainingData , 1), []);
X = cell2mat(X);
model = classifierLogisticRegression( X, Y, 'lambda', 'crossvalidation' , logspace(-6,4,22)' );