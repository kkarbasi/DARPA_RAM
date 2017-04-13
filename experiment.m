classdef experiment < handle
    properties
        BASE_DIR
        expInfo % like this: r1.protocols.r1.subjects.R1001P.experiments.FR1
        sessions = containers.Map
        
    end
    
    methods
        % constructor
        function obj = experiment(BASE_DIR , expInfo)
            obj.BASE_DIR = BASE_DIR;
            obj.expInfo = expInfo; 
            obj.loadsessions();
        end    
        
        function loadsessions(obj)
        % loads the current experiment sessions data
            sessNames = fieldnames(obj.expInfo.sessions);
            for i = 1:numel(sessNames)
                disp(['Loading session ' sessNames{i} '...'])
                allEvents = loadjson([obj.BASE_DIR obj.expInfo.sessions.(sessNames{i}).all_events]);
                taskEvents = loadjson([obj.BASE_DIR obj.expInfo.sessions.(sessNames{i}).task_events]);
                mathEvents = loadjson([obj.BASE_DIR obj.expInfo.sessions.(sessNames{i}).math_events]);
                eegData = obj.getsesseeg(sessNames{i});
                obj.sessions(sessNames{i}) = session(allEvents , taskEvents ...
                    , mathEvents , eegData);
            end
            
            
        end
        
    end
    
        
    methods (Access = protected)
        
        function eeg = getsesseeg(obj , sessName) 
            % loads eeg data corresponding to session sessName
            eegpath = obj.eegpathmaker(sessName);
            sources = loadjson(fullfile(obj.BASE_DIR , eegpath , 'sources.json'));
            eegFN = fieldnames(sources);
            eegFN = eegFN{1};
            
            eegFiles = regexdir(fullfile(obj.BASE_DIR , eegpath , 'noreref') , ['^' eegFN '\.\d*']);
            eeg = [];
            for ff = 1:numel(eegFiles)
                [~ , ~ , ext] = fileparts(eegFiles{ff});
                disp(['reading channel ' ext ' ...']);
                f = fopen(eegFiles{ff});
                eeg = [eeg fread(f)];
                fclose(f);
            end
            
        end
        
                
        function eegPath = eegpathmaker(obj , sessName)
            % Extract this subject's eeg data path from the available event
            % path in r1 struct
            tmp = obj.expInfo.sessions.(sessName).all_events;
            eegPath = fileparts(tmp);
            eegPath = strrep(eegPath , 'behavioral' , 'ephys');
        end

    end
    
end

function Outfiles=regexdir(baseDir,searchExpression)
    % OUTFILES = regexdir(BASEDIRECTORY,SEARCHEXPRESSION)
    % A search to find files that match the search expression
    %

    dstr = dir(baseDir);%search current directory and put results in structure
    Outfiles = {};
    for II = 1:length(dstr)
        if ~dstr(II).isdir && ~isempty(regexp(dstr(II).name,searchExpression,'match')) 
        %look for a match that isn't a directory
            Outfiles{length(Outfiles)+1} = fullfile(baseDir,dstr(II).name);
        end
    end
end