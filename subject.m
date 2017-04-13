classdef subject < handle
    
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
            obj.r1 = tmp.protocols.r1.subjects.(patientID).experiments;
            obj.BASE_DIR = fileparts(fileparts(r1Filename));
            obj.patientID = patientID;
            
        end
        
        
        function types = getexperimenttypes(obj)
            types = fieldnames(obj.r1);
        end
        
        function loadexperiment(obj , expName)
            switch expName
                case 'FR1'
                    obj.experiments(expName) = FR1(obj.BASE_DIR , obj.r1.(expName));
                case 'FR2'
                    
                case 'catFR1'
                    
                case 'catFR2'
                    
            end
        end
        
    end
    
    methods (Access = protected)
        
    end
    
    

        
        
        
    
end