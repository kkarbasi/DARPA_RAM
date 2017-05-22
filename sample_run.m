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
% r1_path = '~/mnt/labs/snel/share/data/DARPA_RAM/session_data/experiment_data/protocols/r1.json';


patientID = 'R1063C';

%% Load data for selected subject
s1 = subject(r1_path , patientID);
s1.loadexperiment('FR1');

%% Parameters 
% (epoch boundaries: from 500ms before event onset to 2100 ms 
% after with 1500ms buffer on both sides

noffset = 500;
poffset = 2100;
buffer = 1500;


%% Run wavelet transform: (THIS WILL TAKE A LONG TIME)
% for now, this will save each event on local hdd (go to FR1 class function
% wt_log_resample() to change the saving path
s1.experiments('FR1').cmwt('1' , [noffset , poffset] , buffer , [1 ,200] , 49);

% After saving this step is done, run data_prep to extract training data