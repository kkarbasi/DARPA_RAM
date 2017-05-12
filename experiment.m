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
        
        function [bpeeg , sourceData] = getsesseeg(obj , sessName) 
            % loads eeg data corresponding to session sessName
            
            eegpath = obj.eegpathmaker(sessName);
            sources = loadjson(fullfile(obj.BASE_DIR , eegpath , 'sources.json'));
            eegFN = fieldnames(sources);
            eegFN = eegFN{1};
            dataFormat = sources.(eegFN).data_format;
            sourceData = sources.(eegFN);
            
            disp('Extracting bipolar eeg...')
            
            pairs = obj.getpairs(sessName);
            pairNames = fieldnames(pairs);
            nChannels = numel(pairNames); 
            textprogressbar('Reading EEG data: ' , nChannels , 'Channel'); pause(0.05);
            bpeeg = [];
            c = 1;
            for i = 1:nChannels
                textprogressbar(i, nChannels, 'Channel');
                ch1 = num2str(pairs.(pairNames{i}).channel_1 , '%03i');
                ch2 = num2str(pairs.(pairNames{i}).channel_2 , '%03i');
                
                ch1FN = fullfile(obj.BASE_DIR , eegpath , 'noreref' , [eegFN '.' ch1]);
                ch2FN = fullfile(obj.BASE_DIR , eegpath , 'noreref' , [eegFN '.' ch2]);
                
                [ch1eeg , success1] = readeegdata(ch1FN , dataFormat);
                [ch2eeg , success2] = readeegdata(ch2FN , dataFormat);
                
                if success1 && success2
                    bpeeg(:,c) = abs(ch2eeg - ch1eeg);
                    c = c + 1;
                end
                
            end
            textprogressbar(['done!---EEG data for ' num2str(c-1) ' channels was found!'])


        end
                
        function eegPath = eegpathmaker(obj , sessName)
            % Extract this subject's eeg data path from the available event
            % path in r1 struct
            tmp = obj.expInfo.sessions.(sessName).all_events;
            eegPath = fileparts(tmp);
            eegPath = strrep(eegPath , 'behavioral' , 'ephys');
        end
        
        function pairs = getpairs(obj , sessionName)
            pairsPath = obj.expInfo.sessions.(sessionName).pairs;
            pairsJson = loadjson(fullfile(obj.BASE_DIR , pairsPath));
            subjectID = obj.expInfo.sessions.(sessionName).subject_alias;
            pairs = pairsJson.(subjectID).pairs;
            
        end
        
%         function bpeeg = getbipolareeg(obj , sessName , eeg)
%             disp('Extracting bipolar eeg...')
%             pairs = obj.getpairs(sessName);
%             pairNames = fieldnames(pairs);
%             bpeeg = zeros(size(eeg , 1) , numel(pairNames));
%             for i = 1:numel(pairNames)
%                 ch1 = pairs.(pairNames{i}).channel_1;
%                 ch2 = pairs.(pairNames{i}).channel_2;
%                 ch1 = eeg(:,ch1);
%                 ch2 = eeg(:,ch2);
%                 bpeeg(:,i) = abs(ch2 - ch1);
%             end
%             
%         end

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

function [eeg , success] = readeegdata(filename , dataFormat)
    if exist(filename , 'file')
        f = fopen(filename);
        eeg = fread(f , dataFormat);
        fclose(f);
        success = true;
    else
        eeg = [];
        success = false;
    end
end
