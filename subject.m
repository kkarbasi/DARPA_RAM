classdef subject
    
    properties
       BASE_DIR % Z:\snel\share\data\DARPA_RAM\session_data\experiment_data\
       r1 
       experiments = containers.Map
       patientID
    end
    
    
    properties
   
    end
    
    properties(Dependent)
        
        
    end
    
    methods
        
        function obj = subject(r1Filename , patientID)
            % patienID: patient  identifier
                       
            tmp = loadjson(r1Filename);
            if isfield(tmp.protocols.r1.subjects , patientID)
                obj.r1 = tmp.protocols.r1.subjects.(patientID).experiments;
                obj.BASE_DIR = fileparts(fileparts(r1Filename));
                obj.patientID = patientID;
            else
                error('Patient ID does not exist');
            end
            
        end
        
        
        function types = getexperimenttypes(obj)
            types = fieldnames(obj.r1);
        end
        
        function loadexperiment(obj , expName)
            switch expName
                case 'FR1'
                    obj.experiments(expName) = FR1(obj.BASE_DIR , obj.r1.(expName));
                case 'FR2'
                    disp('You are the man!')
                case 'catFR1'
                    disp('You are the man!')
                case 'catFR2'
                    disp('You are the man!')
                case 'PAL1'
                    disp('You are the man!')
                case 'PAL2'
                    disp('You are the man!')
                case 'YC1'
                    disp('You are the man!')
                case 'YC2'
                    disp('You are the man!')
                otherwise
                    error([expName ' is not a valid expertiment type;'...
                        ' Choose from: FR1, FR2, PAL1, PAL2, YC1, YC2, catFR1, catFR2'])
            end
        end
        
    end
    
    methods (Access = protected)
        
    end
    
    

        
        
        
    
end