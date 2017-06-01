%%
[~, utilfile] = system('find . -name getUsername.m');
utilpath = fileparts(utilfile);
addpath(utilpath);


%% Add Path
switch lower(getUsername)
  case 'cpandar'
    addpath(genpath('~/cosmic-home/c/ramAnalysis'));
  otherwise
    addpath(genpath('~/cosmic-home/DARPARAM')); % path to your code
end

r1_path = '~/snel/share/data/DARPA_RAM/session_data/experiment_data/protocols/r1.json';
% r1_path = '/mnt/scratch/data/DARPA_RAM/tar_files/session_data/experiment_data/protocols/r1.json';
% r1_path = '~/mnt/labs/snel/share/data/DARPA_RAM/session_data/experiment_data/protocols/r1.json';


patientID = 'R1135E';
experiment_type = 'catFR1';
%% Load data for selected subject
s1 = subject(r1_path , patientID);
s1.loadexperiment(experiment_type);

%% Parameters 
% (epoch boundaries: from 500ms before event onset to 2100 ms 
% after with 1500ms buffer on both sides

noffset = 500;
poffset = 2100;
buffer = 1500;


%% Run wavelet transform: (THIS WILL TAKE A LONG TIME)
% for now, this will save each event on local hdd (go to FR1 class function
% wt_log_resample() to change the saving path
sessID = '0';
s1.experiments(experiment_type).cmwt(sessID , [noffset , poffset] , buffer , [1 ,200] , 49);

% After saving this step is done, run data_prep to extract training data

%% Save to disk
save_directory = ['~/snel/share/derived/DARPA_RAM/cmwt&resampled/5-31-17/session_' sessID];
s1.experiments(experiment_type).saveCWTResampled(save_directory);


%% Run wavelet and save

for sess = 0:1
    s1.experiments(experiment_type).cmwt(num2str(sess) , [noffset , poffset] , buffer , [1 ,200] , 49);
    
    save_directory = ['~/snel/share/derived/DARPA_RAM/cmwt&resampled/5-31-17/R1135E/session_' num2str(sess + 4)];
    mkdirRecursive(save_directory)
    s1.experiments(experiment_type).saveCWTResampled(save_directory);
end