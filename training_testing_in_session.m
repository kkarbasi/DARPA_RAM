clear all; close all

%% Load session data
fprintf('Loading Data\n');

sess0 = '~/snel/share/derived/DARPA_RAM/training_testing_data/5-24-17/sess0.mat';
sess1 = '~/snel/share/derived/DARPA_RAM/training_testing_data/5-24-17/sess1.mat';

trainVar = 'sess0';


load(eval(trainVar));

y = trainingLabels';
% X = trainingData;
X = reshape(trainingData, size(trainingData , 1), []);
X = cell2mat(X);

% X_train = [ones(size(X_train,1),1) standardizeCols(X_train)];
% X_train = [ones(size(X_train,1),1) X_train];
X = double(X);
% y_train(y_train==0) = -1;

clearvars 'trainingData' 'trainingLabels'

%% In-session x-val
% 25 lists, hold one list out
% lambdas = logspace(-6, 4, 22);
lambdas =       13.895; % best lambda

all_idx = 1:size(X , 1);
numLists = 25;
wpl = 12; % words per list

X_trains = {};
y_trains = {};

for ll = 1:numel(lambdas)
    y_h = [];
    for ilist = 0 : numLists - 1
        % hold one list out
        test_idx = ilist*wpl + 1 : ilist*wpl + wpl;

        X_test = X(test_idx , :); 
        X_test = [ones(size(X_test,1),1) standardizeCols(X_test)];
        y_test = y(test_idx , :);

        train_idx = setdiff(all_idx , test_idx);

        X_train = X(train_idx , :);
        X_train = [ones(size(X_train,1),1) standardizeCols(X_train)];
        y_train = y(train_idx , :);
        
        X_trains{ilist+1} = X_train;
        X_tests{ilist+1} = X_test;
        y_trains{ilist+1} = y_train;
        y_tests{ilist+1} = y_test;
        % train
        lambda = lambdas(ll);
        disp(['Lambda = ' num2str(lambda)]);

        [n,p] = size(X_train);

        rand('state',0);
        randn('state',0);

        %%% Set up problem
        maxIter = n*500; % 10 passes through the data set



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
        %test

        y_h = [y_h; sigmoid(X_test*w)];

    end
    
    [x1 , y1 ,~, AUC ] = perfcurve(y' , y_h , 1);
    fh = figure; plot(x1,y1); hold on
    title(['Lambda = ' num2str(lambda) ';  AUC = ' num2str(AUC)])
    plot( [0 1] , [0 1] , '--r'); hold off; pause(0.1)
end
disp('done')
%% Plot classifier output probability
load('y_h_from_py.mat')
figure('Position' , [50 0 1200 280])

plot(y_h(205:end))
hold on

for tt = 205:numel(y)
    if y(tt) == 0
        plot(tt-204 , y_h(tt) , 'ob')
    end
    if y(tt) == 1
        plot(tt-204 , y_h(tt) , 'pr')
    end
    
end
plot([1 tt-204],[0.5 0.5] ,'--k' , 'linewidth' , 2)
title(['Classifier output probability for test data '])
xlabel('Word Event (each 12 event is a list, total 25 lists)')
ylim([0,1])
yticks([0 , 0.2 , 0.4 , 0.6 , 0.8 , 1])
ylabel('probability')
