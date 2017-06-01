% training and testing using the SAG package
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% training %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load data
clear all; close all
fprintf('Loading Data\n');
% load('covtype.libsvm.binary.mat');
load('~/cosmic-home/DARPARAM/traindata.mat');
% load('~/cosmic-home/DARPARAM/testdata_sess_1.mat');
%%% removing missing channels of session 1
a = cell2mat(trainingData);
a(:, [19 20 66], :) = [];
trainingData = num2cell(a);
%%%
y = trainingLabels';
X = reshape(trainingData, size(trainingData , 1), []);
X = cell2mat(X);
clearvars 'trainingData' 'trainingLabels'

%%%
X = [ones(size(X,1),1) standardizeCols(X)];
y(y==0) = -1;

%%%
[n,p] = size(X);

rand('state',0);
randn('state',0);

%%% Set up problem
maxIter = n*100; % 10 passes through the data set
% lambda = 1/n;
lambda = 313;

objective = @(w)(1/n)*LogisticLoss(w,X,y) + (lambda/2)*(w'*w);

% Order of examples to process
iVals = int32(ceil(n*rand(maxIter,1)));

Xt = X';
xtx = sum(X.^2,2);
%%%
fprintf('Running stochastic average gradient with line-search and adaptive Lipschitz sampling\n');

Lmax = 1; % Initial guess of overall Lipschitz constant
Li = ones(n,1); % Initial guess of Lipschitz constant of each function

randVals = rand(maxIter,2); % Random values to be used by the algorithm

d = zeros(p,1);
g = zeros(n,1);
covered = int32(zeros(n,1));

w = zeros(p,1);
SAG_LipschitzLS_logistic(w,Xt,y,lambda,Lmax,Li,randVals,d,g,covered,int32(1),xtx);
% Li is also updated in-place

f = objective(w);
fprintf('f = %.6f\n',f);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% testing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except w

%%% Load data
% clear all
fprintf('Loading Data\n');
% load('covtype.libsvm.binary.mat');
% load('~/cosmic-home/DARPARAM/traindata.mat');
load('~/cosmic-home/DARPARAM/testdata_sess_1.mat');
%%% removing missing channels of session 1
% a = cell2mat(trainingData);
% a(:, [19 20 66], :) = [];
% trainingData = num2cell(a);
%%%
y = trainingLabels';
X = reshape(trainingData, size(trainingData , 1), []);
X = cell2mat(X);
clearvars 'trainingData' 'trainingLabels'


%%% test & Plot ROC
X = [ones(size(X,1),1) standardizeCols(X)];
y_t = sigmoid(X*w);
[x1 , y1 ,~, AUC ] = perfcurve(y' , y_t , 1);
plot(x1,y1)
title(['AUC = ' num2str(AUC)])


























