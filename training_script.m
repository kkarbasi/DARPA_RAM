%% Set path and load
% 
% addpath(genpath('./utils'));
% addpath(genpath('./submodules'));
% load traindata.mat
Y = trainingLabels';
X = reshape(trainingData, size(trainingData , 1), []);
X = cell2mat(X);

%% Training params
defaults.regularization = 'L2';
defaults.lambda         = 1;
defaults.optimization   = 'minimize';
defaults.labelsGroup    = [];

% lambda = logspace(-6,4,22);
% for ii = 1:numel(lambda)
%     defaults.lambda = lambda(ii);
%     % Train
%     sctratchpad = train_L2_RLR(X' , Y' , defaults, 1);
% 
%     % Test
% 
%     [acts , scratchpad] = test_L2_RLR(X',0,sctratchpad);
% 
%     % Plot ROC
% 
%     [x1 , y1 ,~, AUC ] = perfcurve(Y' , acts , 1);
%     plot(x1,y1)
%     title(['AUC = ' num2str(AUC)])
%     waitforbuttonpress;
% end

%% Train
sctratchpad = train_L2_RLR(X' , Y' , defaults, 1);

%% Test

[acts , scratchpad] = test_L2_RLR(X',0,sctratchpad);

%% test & Plot ROC

y_t = sigmoid(X*w);
y(y == -1) = 0;
[x1 , y1 ,~, AUC ] = perfcurve(y' , y_t , 1);
plot(x1,y1)
title(['AUC = ' num2str(AUC)])

%% Plot classifier output probability

%% get list event indices
listIndices = {};

for l  = 1:25

    indices = [];
    
    for ii = 1:numel(events)
        if events{ii}.list == l && strcmp(events{ii}.type, 'WORD')
            indices = [indices [ii]];
            
        end

    end
    
    listIndices{l} = indices;
end
%%
plot(acts)
hold on

for tt = 1:numel(trainingLabels)
    if trainingLabels(tt) == 0
        plot(tt , acts(tt) , 'ob')
    end
    if trainingLabels(tt) == 1
        plot(tt , acts(tt) , 'pr')
    end
    
end









%% trash

for l  = 1:25
    listIndices = {};
    c = 1;
    for ii = 1:numel(events)
        if events{ii}.list == l && strcmp(events{ii}.type, 'WORD')
            listIndices{c} = events{ii}.word;
            c = c + 1;
        end

    end
    disp(size(listIndices))
end