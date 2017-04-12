classdef subject < handle
    
    properties
       BASE_DIR
       r1 
       experiments = containers.Map
       
    end
    properties
        
%         sessions
        id
        eegPath
        
    end
    
    properties
        all_events
        contacts
        import_type
        localization
        math_events
        montage
        original_experiment
        original_session
        pairs
        subject_alias
        task_events
    end
    
    properties(Dependent)
        
        
    end
    
    methods
        
        function obj = subject(BASE_DIR , subjectsData , patientID)
            % subjectsData: the r1 struct of the subjects.
            % patienID: patient  identifier
            % usage: p1 = subject(r1.protocols.r1.subjects, patientID);
            
            obj.r1 = subjectsData.(patientID);
            obj.id = patientID;
%             obj.sessions = pbj.r1.
            obj.BASE_DIR = BASE_DIR;
            
            obj.eegpathmaker();
            
            disp('Loading all events...')
%             obj.loadallevents();
            
            
        end
        
        
        function types = getexperimenttypes(obj)
            types = fieldnames(obj.r1.experiments);
        end
        
        function loadexperiments(obj)
            types = obj.getexperimenttypes();
            for i = 1:numel(types)
                obj.experiments(types{i}) = experiment(types{i} , obj.BASE_DIR);
            end
        end
        
    end
    
    methods (Access = protected)
        
        
        function eegpathmaker(obj)
            % Extract this subject's eeg data path from the available event
            % path in r1 struct
            tmp = obj.r1.experiments.FR1.sessions.('x0x30_').all_events;
            obj.eegPath = fileparts(tmp);
            obj.eegPath = strrep(obj.eegPath , 'behavioral' , 'ephys');
            obj.eegPath = fullfile(obj.eegPath , 'noreref');
        end
        
    end
    
    

        
        
        
    
end