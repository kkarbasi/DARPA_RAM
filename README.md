**Usage:**



**Create a new "subject"**:

`subj1 = subject(<r1.json file path> , <patient id>);`


**Get list of subject experiment types**:

`subj1.getexperimenttypes`


**Load data from a specific experiment**:

`subj1.loadexperiment(<experiment type, e.g. 'FR1' or 'FR2', etc.>)`


**Get each experiment's session names**:

`subj1.experiments(<experiment type>).getsessionnames`


**Get a specific sessions data**:

`subj1.experiments(<experiment type>).sessions(<session name>).eegData` _% eeg recordings`_

`subj1.experiments(<experiment type>).sessions(<session name>).allEvents` _% all events_

`subj1.experiments(<experiment type>).sessions(<session name>).taskEvents` _% only task events_

`subj1.experiments(<experiment type>).sessions(<session name>).mathEvents` _% only math events_