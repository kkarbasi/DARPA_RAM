

% Load Runs
% 
runPath = '/home/kkarbasi/snel/share/derived/lfads_runs/runs/RAM_test/170728_1532_RAMtest';
list_runs = '*';

clear allRuns;
i = 0;
if ischar(list_runs)
    D = dir(fullfile(runPath,list_runs));
    for d = D(:)'
        dn = d.name;
        fileName = fullfile(runPath, dn, dn, '*.mat');
        matFileName = dir(fileName);
        if isempty(matFileName), continue; end
        fileName = fullfile(runPath, dn, dn, matFileName.name);
        load(fileName, '-mat', 'rc');
        rc.loadRunResults

        % select the best run
        [~,runIdx] = min([rc.runResults.MinReconVal]);

        % load the posterior mean values into matlab
        rc.runs(runIdx).loadSequenceData();
        rc.runs(runIdx).loadPosteriorMeans(1);
        rc.runs(runIdx).addPosteriorMeansToSeq();
        r = rc.runs(runIdx);
        i = i + 1;
        allRuns(i) = r;
        %allRuns(i).datasetName = r.datasets.name;
    end
end

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

%%
% wordEventsEEG = zeros(300,2800,110);
irun = 1;
seq = allRuns(irun).sequenceData;
seq = seq{1};
Fs = seq(1).fs;

freq_target = 500; %Hz



for is = 1:numel(seq)
    tmp = resample(seq(is).rates' , freq_target , Fs);
    numCh = size(tmp , 2)/2;
    wordEventsEEG(is , : , :) = tmp(: , 1:numCH);
end

%% replace session event data with loaded event data from LFADS
s1.experiments.FR1.sessions.x0x30_.wordEventsEEG = wordEventsEEG;
%% Prepare training data
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
        s1.experiments.(curr_exp).preptrainingdata_from_LFADS(curr_sess , [noffset , poffset] , buffer , [1 ,200] , 50 , resamplef , trim);

        end
    end
end

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

%% in-session Log Reg
lambdas = logspace(-7,4,30);
% lambdas = lambdas(10:end);
% lambdas = lambdas(16);
[y_h , y_test ,AUCs , ws , maxIdx] = sc.trainis(lambdas , 25,12);





