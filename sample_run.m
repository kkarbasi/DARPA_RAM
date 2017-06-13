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

% r1_path = '~/snel/share/data/DARPA_RAM/session_data/experiment_data/protocols/r1.json';
r1_path = '/mnt/scratch/data/DARPA_RAM/tar_files/session_data/experiment_data/protocols/r1.json';
% r1_path = '~/mnt/labs/snel/share/data/DARPA_RAM/session_data/experiment_data/protocols/r1.json';


patientID = 'R1135E';
% patientID = 'R1063C';
% experiment_type = 'catFR1';
%% Load data for selected subject
s1 = subject(r1_path , patientID);
s1.loadexperiment('FR1');
s1.loadexperiment('catFR1');


% %% Parameters 
% (epoch boundaries: from 500ms before event onset to 2100 ms 
% after with 1500ms buffer on both sides

noffset = 500;
poffset = 2100;
buffer = 1500;
trim = 500;


% %% Run wavelet transform: (THIS WILL TAKE A LONG TIME)
% % for now, this will save each event on local hdd (go to FR1 class function
% % wt_log_resample() to change the saving path
% 
% % sessID = '0';
% % s1.experiments(experiment_type).cmwt(sessID , [noffset , poffset] , buffer , [1 ,200] , 49);
% 
% % After saving this step is done, run data_prep to extract training data
% 
% %% Save to disk
% 
% % save_directory = ['~/snel/share/derived/DARPA_RAM/cmwt&resampled/5-31-17/session_' sessID];
% % s1.experiments(experiment_type).saveCWTResampled(save_directory);
% 
% 
%% Run wavelet and save (after changing maps to structs)
disp('wavelength transform')
expTypes = fieldnames(s1.experiments);
for iexp = 1:numel(expTypes)
    
    curr_exp = expTypes{iexp};
    disp(['Processing experiment ' curr_exp]);
    sessIDs = fieldnames(s1.experiments.(curr_exp).sessions);
    
    for isess = 1:numel(sessIDs)
        if ~(strcmp(curr_exp , 'catFR1') && isess > 2)
        curr_sess = sessIDs{isess};
        disp(['Processing session ' curr_sess]);
        s1.experiments.(curr_exp).cmwt(curr_sess , [noffset , poffset] , buffer , [1 ,200] , 50 , 10 , trim);
%         save_directory = fullfile('~/snel/share/derived/DARPA_RAM/cmwt&resampled/6-8-17/R1135E/', curr_exp , curr_sess);
%         
%         mkdirRecursive(save_directory);
%         s1.experiments.(curr_exp).sessions.(curr_sess).saveCWTResampled(save_directory);
        end
    end
end


%%


%% Run wavelet and save
% x0x30_
% 
% 
% for sess = 0:3
%     
%     curr_sess = num2str(sess);
%     s1_FR1.experiments('FR1').cmwt(curr_sess , [noffset , poffset] , buffer , [1 ,200] , 49);
%     
%     save_directory = ['~/snel/share/derived/DARPA_RAM/cmwt&resampled/5-31-17/R1135E/session_' num2str(sess)];
%     mkdirRecursive(save_directory)
%     s1_FR1.experiments('FR1').saveCWTResampled(save_directory);
% end
% 
% s1_catFR1 = subject(r1_path , patientID);
% s1_catFR1.loadexperiment('catFR1');
% 
% for sess = 0:1
%     
%     curr_sess = num2str(sess);
%     s1_catFR1.experiments('catFR1').cmwt(curr_sess , [noffset , poffset] , buffer , [1 ,200] , 49);
%     
%     save_directory = ['~/snel/share/derived/DARPA_RAM/cmwt&resampled/5-31-17/R1135E/session_' num2str(sess+4)];
%     mkdirRecursive(save_directory)
%     s1_catFR1.experiments('catFR1').saveCWTResampled(save_directory);
% end