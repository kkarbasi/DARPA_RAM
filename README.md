**You can sart using by running cells in the sample_run.m script**
**To prepare training data, run prep_data.m script after loading data using sample_run script**



**Detailed Usage:**



**Create a new "subject"**:

`subj1 = subject(<r1.json file path> , <patient id>);`


**Get list of subject experiment types**:

`subj1.getexperimenttypes`


**Load data from a specific experiment**:

`subj1.loadexperiment(<experiment type, e.g. 'FR1' or 'FR2', etc.>)`


**Get each experiment's session ids**:

`subj1.experiments(<experiment type>).getsessionids`


**Get a specific session's data**:

`subj1.experiments(<experiment type>).sessions(<session id>).eegData` _% eeg recordings`_

`subj1.experiments(<experiment type>).sessions(<session id>).allEvents` _% all events_

`subj1.experiments(<experiment type>).sessions(<session id>).taskEvents` _% only task events_

`subj1.experiments(<experiment type>).sessions(<session id>).mathEvents` _% only math events_


**Get trimmed to events start/end eeg data**

`subj1.experiments(<experiment type>).sessions(<session id>).gettrimmedeeg`


**Get a list of event data field names**

`subj1.experiments(<experiment type>).sessions(<session id>).geteventfields`


**Get a list of values for a specific field in the event data**

`subj1.experiments(<experiment type>).sessions(<session id>).geteventfieldvalues(<field name>)`
