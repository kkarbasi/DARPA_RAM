# DARPA-RAM Matlab data Interface

This code contains a set of classes and methods, mainly to perform two tasks:

    1. To provide an easy-to-use interface for reading the DARPA RAM’s publicly available data.
    2. To implement the classifier explained in Ezzyat et. al. (2017).
    
Detailed documentaion can be found [here](https://github.com/kkarbasi/DARPA_RAM/tree/master/doc).

_How to Use:_

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

