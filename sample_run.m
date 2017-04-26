%% Add Path
addpath(genpath('~/cosmic-home/DARPARAM')); % path to your code
r1_path = '~/snel/share/data/DARPA_RAM/session_data/experiment_data/protocols/r1.json';
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
%% Run wavelet transform:
% for now, this will save each event on local hdd (go to FR1 class function
% dumy() to change the saving path
s1.experiments('FR1').cmwt('0' , [noffset , poffset] , buffer , [1 ,200] , 49);


% After saving this step is done, run data_prep to extract training data