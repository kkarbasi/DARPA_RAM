_How to USE:_

**You can sart using by running cells in the `sample_run.m` script**

_Detailed Usage:_



**Create a new "subject"**:

`subj1 = subject(<r1.json file path> , <patient id>);`


**Get list of subject experiment types**:

`subj1.getexperimenttypes`


**Load data from a specific experiment**:

`subj1.loadexperiment(<experiment type, e.g. 'FR1' or 'FR2', etc.>)`


**Get each experiment's session ids**:

`subj1.experiments.<experiment type>.getsessionids`


**Get a specific session's data**:

`subj1.experiments.<experiment type>.sessions.<session id>.eegData` _% bipolar sEEG recordings`_

`subj1.experiments.<experiment type>.sessions.<session id>.allEvents` _% all events_

`subj1.experiments.<experiment type>.sessions.<session id>.taskEvents` _% only task events_

`subj1.experiments.<experiment type>.sessions.<session id>.mathEvents` _% only math events_


**Get a list of event data field names**

`subj1.experiments.<experiment type>.sessions.<session id>.geteventfields`


**Get a list of values for a specific field in the event data**

`subj1.experiments(<experiment type>).sessions(<session id>).geteventfieldvalues(<field name>)`


**Return sEEG recordings from the first event to the last event**

`subj1.experiments(<experiment type>).sessions(<session id>).gettrimmedeeg`

