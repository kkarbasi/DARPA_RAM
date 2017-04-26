BASE_DIR = 'Z:\snel\share\data\DARPA_RAM\session_data\experiment_data\';
r1_path = 'Z:\snel\share\data\DARPA_RAM\session_data\experiment_data\protocols\r1.json';
patientID = 'R1063C';

%% for linux 
addpath(genpath('~/cosmic-home/RAMstuff/invcwt_v1.4'));
addpath(genpath('~/cosmic-home/DARPARAM'));

BASE_DIR = '~/snel/share/data/DARPA_RAM/session_data/experiment_data/';
r1_path = '/home/kkarbas/snel/share/data/DARPA_RAM/session_data/experiment_data/protocols/r1.json';
r1_path_local = '/home/kkarbas/DARPARAM_localData/DARPA_RAM/session_data/experiment_data/protocols/r1.json';
patientID = 'R1063C';
%%
r1 = loadjson([BASE_DIR 'protocols\r1.json']); 

%%
pairs = loadjson([BASE_DIR r1.protocols.r1.subjects.R1001P.experiments.FR1.sessions.x0x30_.pairs]);


%%
subjects = fieldnames(r1.protocols.r1.subjects); % cell array containing subject names

%%

all_events = loadjson([BASE_DIR r1.protocols.r1.subjects.(patientID).experiments.FR1.sessions.x0x30_.all_events]);

%%
index = loadjson([BASE_DIR r1.protocols.r1.subjects.(patientID).experiments.FR1.sessions.x0x30_.index]);
%%
experiments = {};
fields = fieldnames(r1.protocols.r1.subjects);
for s =1:numel(fields)
%         if strmatch('FR1' , fieldnames(r1.protocols.r1.subjects.(fields{s}).experiments) , 'exact')
            experiments = [experiments fieldnames(r1.protocols.r1.subjects.(fields{s}).experiments)'];
        
end

experiments = unique(experiments)

%%
s1 = subject(r1_path , patientID);
s1.loadexperiment('FR1');

%%
ievent = 4;
ielectrode = 10;
noffset = 500;
poffset = 2100;
buffer = 1500;
%%
sess = s1.experiments('FR1').sessions('0');
eeg = s1.experiments('FR1').sessions('0').eegData;
taskEvents = s1.experiments('FR1').sessions('0').taskEvents;
seeg = sess.geteventeeg(taskEvents{ievent} , noffset , poffset , buffer);
seeg = seeg(:,ielectrode);




%% wavelet number test

eta = -10 : 0.1 : 10;
w0 = 20;
wave = pi.^(-1/4).*exp(i*w0*eta).*exp(-eta.^2/2);

plot(eta,wave)

%%
Fs = 500; %Hz
w = 1000; %ms (win size)
subplot(2,1,1)

spectrogram(e10 , 1000 , [] , [] , Fs , 'yaxis')

subplot(2,1,2)
cwt(e10 , 'amor' , Fs)

%%
Fs = 500; %Hz
w = 1000; %ms (win size)


% the number of octaves (the number of times the frequency of the mother wavelet is halved)
No = 19;

% number of voices per octave (the number of partitions in each octave)
Nv = 32;

fh = figure;
cwt(e10 , Fs ,  'amor' , 'NumOctaves' , No , 'VoicesPerOctave' , Nv);

