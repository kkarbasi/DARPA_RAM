clear all; close all

%% Load training data
fprintf('Loading Training Data\n');

load('~/cosmic-home/DARPARAM/traindata.mat');
% load('~/cosmic-home/DARPARAM/testdata_sess_1.mat');

%%% removing missing channels of session 1
a = cell2mat(trainingData);
a(:, [19 20 66], :) = [];
trainingData = num2cell(a);

y_train = trainingLabels';
X_train = reshape(trainingData, size(trainingData , 1), []);
X_train = cell2mat(X_train);

X_train = [ones(size(X_train,1),1) standardizeCols(X_train)];
y_train(y_train==0) = -1;

clearvars 'trainingData' 'trainingLabels'
%% Load test data

%%% Load data
% clear all
fprintf('Loading Test Data\n');
load('~/cosmic-home/DARPARAM/testdata_sess_1.mat');
% load('~/cosmic-home/DARPARAM/traindata.mat')
% 
% a = cell2mat(trainingData);
% a(:, [19 20 66], :) = [];
% trainingData = num2cell(a);

y_test = trainingLabels';
X_test = reshape(trainingData, size(trainingData , 1), []);
X_test = cell2mat(X_test);

X_test = [ones(size(X_test,1),1) standardizeCols(X_test)];

clearvars 'trainingData' 'trainingLabels'

%% X-Validate on lambda
%lambdas = logspace(-6, 4, 22);
lambdas = 372.7594;
AUCs = [];
for ll = 1:numel(lambdas)
    
    %%%%%%%%%%% training %%%%%%%%%%%%
    
    lambda = lambdas(ll);
    disp(['Lambda = ' num2str(lambda)]);
    
    [n,p] = size(X_train);

    rand('state',0);
    randn('state',0);

    %%% Set up problem
    maxIter = n*1000; % 10 passes through the data set
    
    

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
    fh = figure; plot(x1,y1)
    title(['Lambda = ' num2str(lambda) ';  AUC = ' num2str(AUC)])
    
%     saveas(fh , ['~/snel/share/derived/DARPA_RAM/R1063C_XVal_tr_1_test_0/' num2str(lambda) '.jpg']) 
%     close(fh)
    AUCs = [AUCs AUC];
    
end

%% Plot classifier output probability

figure('Position' , [50 0 1600 180])

plot(y_h)
hold on

for tt = 1:numel(y_test)
    if y_test(tt) == 0
        plot(tt , y_h(tt) , 'ob')
    end
    if y_test(tt) == 1
        plot(tt , y_h(tt) , 'pr')
    end
    
end
plot([1 tt],[0.5 0.5] ,'--k' , 'linewidth' , 2)
title('Classifier output probability for test data (session 0)')
xlabel('Word Event (each 12 event is a list, total 25 lists)')
ylabel('probability')