

% Load Runs
% 
runPath = '/home/mreza/snel/share/derived/lfads_runs/runs/RAM_test/170728_1532_RAMtest';
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
for is = 1:numel(seq)
    tmp = resample(seq(is).rates' , 5 , 3);
    wordEventsEEG(is , : , :) = tmp(: , 1:110);
end

%% replace session event data with loaded event data from LFADS
s1.experiments.FR1.sessions.x0x30_.wordEventsEEG = wordEventsEEG;







