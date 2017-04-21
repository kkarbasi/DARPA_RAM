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
                disp(['Loading session ' getsessionid(sessNames{i}) ' ...'])
                allEvents = loadjson(fullfile(obj.BASE_DIR , obj.expInfo.sessions.(sessNames{i}).all_events));
                taskEvents = loadjson(fullfile(obj.BASE_DIR , obj.expInfo.sessions.(sessNames{i}).task_events));
                mathEvents = loadjson(fullfile(obj.BASE_DIR , obj.expInfo.sessions.(sessNames{i}).math_events));
                [eegData , sourceData] = obj.getsesseeg(sessNames{i});
                obj.sessions(getsessionid( sessNames{i} ) ) = ...
                    session( allEvents , taskEvents , mathEvents ,...
                    eegData , sourceData );
            end
            
        end
        
        function sessNames = getsessionids(obj)
            sessNames = obj.sessions.keys;
        end
        
    end
        
    methods (Access = protected)
        
        function [eeg , sourceData] = getsesseeg(obj , sessName) 
            % loads eeg data corresponding to session sessName
            
            eegpath = obj.eegpathmaker(sessName);
            sources = loadjson(fullfile(obj.BASE_DIR , eegpath , 'sources.json'));
            eegFN = fieldnames(sources);
            eegFN = eegFN{1};
            dataFormat = sources.(eegFN).data_format;
            sourceData = sources.(eegFN);
            eegFiles = regexdir(fullfile(obj.BASE_DIR , eegpath , 'noreref') , ['^' eegFN '\.\d*']);
            nChannels = numel(eegFiles); 
            eeg = [];
            disp(['Number of EEG channels: ' , num2str(nChannels)]);
            textprogressbar('Reading EEG data: ' , nChannels , 'Channel'); pause(0.05);
            for ff = 1 : nChannels
                textprogressbar(ff, nChannels, 'Channel');
                f = fopen(eegFiles{ff});
                eeg = [eeg fread(f , dataFormat)];
                fclose(f);
            end
            textprogressbar('done')
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

function sessID = getsessionid(sessName)
    sessID = sessName(5);
end