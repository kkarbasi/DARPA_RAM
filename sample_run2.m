%%
[~, utilfile] = system('find . -name getUsername.m');
utilpath = fileparts(utilfile);
addpath(utilpath);

[~, utilfile] = system('find . -name loadjson.m');
utilpath = fileparts(utilfile);
addpath(utilpath);


%% Add Path
% switch lower(getUsername)
%   case 'cpandar'
%     addpath(genpath('~/cosmic-home/c/ramAnalysis'));
%   otherwise
%     addpath(genpath('~/cosmic-home/DARPARAM')); % path to your code
% end

r1_path = '/home/kkarbasi/snel/share/data/DARPA_RAM/session_data/experiment_data/protocols/r1.json';
% r1_path = '/mnt/scratch/data/DARPA_RAM/tar_files/session_data/experiment_data/protocols/r1.json';
% r1_path = '~/mnt/labs/snel/share/data/DARPA_RAM/session_data/experiment_data/protocols/r1.json';


% patientID = 'R1135E';
patientID = 'R1063C';
%% Load data for selected subject
s1 = subject(r1_path , patientID);
s1.loadexperiment('FR1');
% s1.loadexperiment('catFR1');

%% highpass Filtering
% Fs = 500;  % Sampling Frequency
% 
% N    = 2000;     % Order
% Fc   = 0.05;      % Cutoff Frequency
% flag = 'scale';  % Sampling Flag
% 
% % Create the window vector for the design algorithm.
% win = hamming(N+1);
% 
% % Calculate the coefficients using the FIR1 function.
% b  = fir1(N, Fc/(Fs/2), 'high', win, flag);
% %Hd = dfilt.dffir(b);
% 
% eegData = s1.experiments.FR1.sessions.x0x30_.eegData;
% filtData = filtfilt(b,1,eegData);
% 
% s1.experiments.FR1.sessions.x0x30_.eegData = filtData;
% %% Parameters 
% (epoch boundaries: from 500ms before event onset to 2100 ms 
% after with 1500ms buffer on both sides

noffset = 500; %ms
poffset = 2100; %ms
buffer = 1500; %ms
trim = 500; %ms
resamplef = 10; % resample to 1/resamplef

%% Run wavelet and save (after changing maps to structs)
disp('wavelength transform')
expTypes = fieldnames(s1.experiments);
for iexp = 1:numel(expTypes)
    
    curr_exp = expTypes{iexp};
    disp(['Processing experiment ' curr_exp]);
    sessIDs = fieldnames(s1.experiments.(curr_exp).sessions);
    
    for isess = 1:1%numel(sessIDs)
        if ~(strcmp(curr_exp , 'catFR1') && isess > 2)
        curr_sess = sessIDs{isess};
        disp(['Processing session ' curr_sess]);
        s1.experiments.(curr_exp).preptrainingdata(curr_sess , [noffset , poffset] , buffer , [1 ,200] , 50 , resamplef , trim);

        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%% TRAINING %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add sessions to sessionCollection (FR1)
sc = sessionCollection;

FR1_sessions = s1.experiments.FR1.sessions;
sfn = fieldnames(FR1_sessions);

for i = 1:numel(sfn)
    sc.addsessionobject(FR1_sessions.(sfn{i}));
end

%% Add sessions to sessionCollection (catFR1)
catFR1_sessions = s1.experiments.catFR1.sessions;
sfn = fieldnames(catFR1_sessions);

for i = 1:2
    sc.addsessionobject(catFR1_sessions.(sfn{i}));
end

%% in-session
lambdas = logspace(-7,4,30);
% lambdas = lambdas(15:30);
[y_h , y_test ,AUCs , ws , maxIdx] = sc.trainis(lambdas , 25,12);

%% multi-session

lambdas = logspace(-8,1,40);
% lambdas = lambdas(10)
[y_h , y_test ,AUCs , ws , maxIdx] = sc.trainms(lambdas);

%% Prep for LFADS
buffer = 100;
lower_b = 500 + buffer;
upper_b = 2100 + buffer;
target_freq = 300; %Hz
trials_per_event = 1;
% zscore = true;

seq = s1.experiments.FR1.sessions.x0x30_.createLFADSseq(lower_b,...
    upper_b, target_freq, trials_per_event);

%% replace session event data with loaded event data from LFADS
s1.experiments.FR1.sessions.x0x30_.wordEventsEEG = wordEventsEEG;
%% scale the data back to the original mean/variance
s1.experiments.FR1.sessions.x0x30_.scaleZSback();

%% wavelet transform before exporting to LFADS
Fs = 500;
numFreqs = 8;
spacing = (log2(200) - log2(1))/numFreqs;
eegData = s1.experiments.FR1.sessions.x0x30_.eegData;
eegData = contwt_par(eegData, 1/Fs, 0, spacing, 1.0/200.0, numFreqs - 1, 'MORLET', 5);
eegData = reshape(eegData, [],size(eegData , 3));
s1.experiments.FR1.sessions.x0x30_.eegData = log10(abs(eegData).^2)';
% then run the createLFADSseq function
%% spectrum shaping
coef = -0.9;
eegData = s1.experiments.FR1.sessions.x0x30_.eegData;
eegData = bsxfun(@minus , eegData , mean(eegData));
eegDataSpecShaped = spectShape(eegData , coef);
s1.experiments.FR1.sessions.x0x30_.eegData = eegDataSpecShaped;
