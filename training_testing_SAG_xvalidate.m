clear all; close all

%% Load training data
fprintf('Loading Training Data\n');

sess0 = '~/snel/share/derived/DARPA_RAM/training_testing_data/5-24-17/sess0.mat';
sess1 = '~/snel/share/derived/DARPA_RAM/training_testing_data/5-24-17/sess1.mat';

trainVar = 'sess1';
testVar = 'sess0';

load(eval(trainVar));

%%% removing channels from session 0 that are missing in session 1
if strcmp(trainVar, 'sess0')
    a = cell2mat(trainingData);
    a(:, [19 20 66], :) = [];
    trainingData = num2cell(a);
end

y_train = trainingLabels';
X_train = reshape(trainingData, size(trainingData , 1), []);
X_train = cell2mat(X_train);

X_train = [ones(size(X_train,1),1) standardizeCols(X_train)];
% X_train = [ones(size(X_train,1),1) X_train];
X_train = double(X_train);
% y_train(y_train==0) = -1;

clearvars 'trainingData' 'trainingLabels'
%% Load test data

%%% Load data
% clear all
fprintf('Loading Test Data\n');
load(eval(testVar));

if strcmp(testVar, 'sess0')
    a = cell2mat(trainingData);
    a(:, [19 20 66], :) = [];
    trainingData = num2cell(a);
end

y_test = trainingLabels';
X_test = reshape(trainingData, size(trainingData , 1), []);
X_test = cell2mat(X_test);

X_test_orig = X_test;
X_test = [ones(size(X_test,1),1) standardizeCols(X_test)];
% X_test = [ones(size(X_test,1),1) X_test];
X_test = double(X_test);

clearvars 'trainingData' 'trainingLabels'

%% X-Validate on lambda
% lambdas = logspace(-6, 4, 22);
lambdas =       1.5505;
AUCs = [];
for ll = 1:numel(lambdas)
    
    %%%%%%%%%%% training %%%%%%%%%%%%
    
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%% testing %%%%%%%%%%%%
    
    y_h = sigmoid(X_test*w);
    [x1 , y1 ,~, AUC ] = perfcurve(y_test' , y_h , 1);
    fh = figure; plot(x1,y1); hold on
    title(['Lambda = ' num2str(lambda) ';  AUC = ' num2str(AUC)])
    plot( [0 1] , [0 1] , '--r'); hold off
%     saveas(fh , ['~/snel/share/derived/DARPA_RAM/R1063C_XVal_tr_1_test_0/' num2str(lambda) '.jpg']) 
%     close(fh)
    AUCs = [AUCs AUC];
    pause(0.1)
    
end
figure; semilogx(lambdas , AUCs); title(['AUC vs lambda; test on ' testVar]);
%% Plot classifier output probability
% load('y_h_from_py.mat')
figure('Position' , [50 0 1200 280])

plot(y_h(205:end))
hold on

for tt = 205:numel(y_test)
    if y_test(tt) == 0
        plot(tt-204 , y_h(tt) , 'ob')
    end
    if y_test(tt) == 1
        plot(tt-204 , y_h(tt) , 'pr')
    end
    
end
plot([1 tt-204],[0.5 0.5] ,'--k' , 'linewidth' , 2)
title(['Classifier output probability for test data ' testVar])
xlabel('Word Event (each 12 event is a list, total 25 lists)')
ylim([0,1])
yticks([0 , 0.2 , 0.4 , 0.6 , 0.8 , 1])
ylabel('probability')
