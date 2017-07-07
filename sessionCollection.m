classdef sessionCollection < handle
   properties
       sessions
       buffer

   end
   
   methods
       function obj = sessionCollection(varargin)
%            p = inputParser();
%            p.addParameter('loadSessionFromFile' , true , @islogical);
%            if narargin
           
       end
       
       function addsessionfromfile(obj, sess_dir)
           curr_sess = session();
           disp('Loading event data...')
            % events_all = cell(numEvents , 1);
            events_all = zeros([numEvents , size(ecwt_r,1) , size(ecwt_r,2) , size(ecwt_r,3)], 'single'); % event X channel X freq X time

            for ievent = 1 : numEvents
                fprintf(repmat('\b' , 1,9))
                fprintf(['Event ' num2str(ievent , '%03i')]);

                load(ef{ievent}); 
                % do abs and cast to single (memory)
                curr_ev = single( abs( ecwt_r ) );
                events_all(ievent , : ,: ,:) = curr_ev( : , : , :);

            end

           
       end
       
       function addsessionobject(obj , session)
           if isempty(obj.sessions)
               sessCount = 0;
           else
               sessCount = numel(fieldnames(obj.sessions));
           end
           obj.sessions.(['x' num2str(sessCount+1)]) = session;
           
       end
       
       function preptrainingdata(obj, xval)
           xvalstr  = {'multi-session' , 'in-session'};
           if ~any(strcmp(xval , xvalstr))
               error('xval should be ''multi-session''(default) or ''in-session''');
           end

           if ~exist('xval' , 'var') || isempty(xval)
               xval = 'multi-session';
           end
           
           
       end
       
       function [y_h_all , y , AUC_all , w_all , maxIdx] = trainis(obj , lambdas, numLists , wpl)
            
            w_all = {};
            AUC_all = [];
            y_h_all = {};
            
            currSessions = fieldnames(obj.sessions);
            X = obj.sessions.(currSessions{1}).trainingData;
            y = obj.sessions.(currSessions{1}).trainingLabels';
            X = reshape(X, size(X , 1), []);
            X = cell2mat(X);
            X = double(X);
            y_h_all = cell(1,numel(lambdas));
            AUC_all = cell(1,numel(lambdas));
            all_idx = 1:size(X , 1);
            funlogisticreg = @(X_train , y_train , lambda) obj.logisticreg(X_train , y_train , lambda);
            for ll = 1:numel(lambdas)
                lambda = lambdas(ll);
                disp(['lambda = ' num2str(lambda)])
                y_h = [];
                parfor ilist = 0 : numLists - 1
                    % hold one list out
                    test_idx = ilist*wpl + 1 : ilist*wpl + wpl;

                    X_test = X(test_idx , :); 
                    X_test = [ones(size(X_test,1),1) standardizeCols(X_test)];
%                     y_test = y(test_idx , :);

                    train_idx = setdiff(all_idx , test_idx);

                    X_train = X(train_idx , :);
                    X_train = [ones(size(X_train,1),1) standardizeCols(X_train)];
                    y_train = y(train_idx , :);
                    

                    % train
                    
           
                    w = funlogisticreg(X_train , y_train , lambda);
                    %w_all{end+1} = w;
                    y_h = [y_h; sigmoid(X_test*w)];
                end
                y_h_all{ll} = y_h;
%                 keyboard
                [~ , ~ ,~, AUC ] = perfcurve(y' , y_h , 1);
                disp(['AUC = ' num2str(AUC)])
                AUC_all(ll) = AUC;
                
            end
            
            [~ , maxIdx] = max(AUC_all(:));
            
            
           
       end
       
       
       function [y_h_all , y_test , AUC_all , w_all , maxIdx] = trainms(obj , lambdas)
           currSessions = fieldnames(obj.sessions);
           numSess = numel(currSessions);
           all_idx = 1:numSess;
           w_all = {};
           AUC_all = [];
           y_h_all = {};
            for ll = 1:numel(lambdas)
                lambda = lambdas(ll);
                disp(['lambda = ' num2str(lambda)])
                y_h = [];
                y_test = [];
                
                for isess = 1:numSess
                   y_test = [y_test ; obj.sessions.(currSessions{isess}).trainingLabels'];
                    
                   X_train = [];
                   y_train = [];
                   
                   X_test = obj.sessions.(currSessions{isess}).trainingData;
                   X_test = reshape(X_test , size(X_test,1),[]);
                   X_test = cell2mat(X_test);
                   X_test = double(X_test);
                   X_test = [ones(size(X_test,1),1) standardizeCols(X_test)];

                   train_idx = setdiff(all_idx , isess);
                   disp(['Test index = ' num2str(isess) ' __ Train index = ' num2str(train_idx)])

                   for ii = 1:numel(train_idx)
%                        disp(size(X_train))
                       
                       X_train_tmp = obj.sessions.(currSessions{train_idx(ii)}).trainingData;
                       X_train_tmp = reshape(X_train_tmp , size(X_train_tmp,1),[]);
                       X_train_tmp = cell2mat(X_train_tmp);
                       X_train_tmp = double(X_train_tmp);
%                        X_train_tmp = [ones(size(X_train_tmp,1),1) standardizeCols(X_train_tmp)];
                       
                       X_train  = [X_train ;X_train_tmp];    
                       y_train  = [y_train ;obj.sessions.(currSessions{train_idx(ii)}).trainingLabels'];    

                   end

                    X_train = [ones(size(X_train,1),1) standardizeCols(X_train)];
                    w = obj.logisticreg(X_train , y_train , lambda);
                    w_all{end+1} = w;
                    y_h = [y_h; sigmoid(X_test*w)];
                end
                y_h_all{end+1} = y_h;
%                 keyboard
                [~ , ~ ,~, AUC ] = perfcurve(y_test' , y_h , 1);
                disp(['AUC = ' num2str(AUC)])

                AUC_all(end+1) = AUC;
                
            end
            
            [~ , maxIdx] = max(AUC_all(:));
            
            
           
       end
       
       
       function [AUC , fh] = plotROC(obj, y_test , y_h , plot_title)
           if ~exist('plot_title' , 'var') || isempty(plot_title)
               plot_title = 'ROC Curve';
           end

           [x1 , y1 ,~, AUC ] = perfcurve(y_test' , y_h , 1);
           fh = figure; plot(x1,y1); hold on
           title([plot_title '; AUC = ' num2str(AUC) ])
           plot( [0 1] , [0 1] , '--r'); hold off; pause(0.1)

       end
       
       function getytest(obj)
           
       end
              
       function w = logisticreg(obj , X_train , y_train , lambda)
            [n,p] = size(X_train);
            rand('state',0);
            randn('state',0);

            %%% Set up problem
            maxIter = n*100; % 10 passes through the data set



            objective = @(w)(1/n)*LogisticLoss(w,X_train,y_train) + (lambda/2)*(w'*w);

            % Order of examples to process
            iVals = int32(ceil(n*rand(maxIter,1)));

            Xt = X_train';
            xtx = sum(X_train.^2,2);
            yX = diag(sparse(y_train))*X_train;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            fprintf('Running stochastic average gradient with line-search and adaptive Lipschitz sampling\n');

            Lmax = 1; % Initial guess of overall Lipschitz constant
            Li = ones(n,1); % Initial guess of Lipschitz constant of each function

            randVals = rand(maxIter,2); % Random values to be used by the algorithm

            d = zeros(p,1);
            g = zeros(n,1);
            covered = int32(zeros(n,1));

            w = zeros(p,1);
            SAG_LipschitzLS_logistic(w,Xt,y_train,lambda,Lmax,Li,randVals,d,g,covered,int32(1),xtx);
            % Li is also updated in-place

            f = objective(w);
            fprintf('f = %.6f\n',f);

       end
       
       
   end
    
end