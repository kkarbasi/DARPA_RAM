Usage


Create a new "subject":

subj1 = subject(<r1.json file path> , patien id);


Get list of subject experiment types:

subj1.getexperimenttypes


Load data from a specific experiment:

subj1.loadexperiment(<experiment type, e.g. 'FR1' or 'FR2', etc.>)


Get each experiment's session names:

subj1.experiments(<experiment type>).getsessionnames


Get a specific sessions data:

subj1.experiments(<experiment type>).sessions(<session name>).eegData % eeg recordings

subj1.experiments(<experiment type>).sessions(<session name>).allEvents % all events

subj1.experiments(<experiment type>).sessions(<session name>).taskEvents % only task events

subj1.experiments(<experiment type>).sessions(<session name>).mathEvents % only math events