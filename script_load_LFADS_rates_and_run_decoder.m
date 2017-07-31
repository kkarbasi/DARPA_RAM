%%
% load('/snel/share/share/derived/lfads_runs/runs/RAM_test/170721_2308_RAMtest/RAM_wavelet_buff100_rsto300hz_abs_log_zscored/RAM_wavelet_buff100_rsto300hz_abs_log_zscored/RC_RAM_wavelet_buff100_rsto300hz_abs_log_zscored_c6629735.mat')
%% load posterior mean sampling results
numRuns = numel(rc.runs);
maxAUCs = [];
for rr = 1:numRuns
    r = rc.runs(rr);
    r.loadSequenceData();
    r.loadPosteriorMeans(1);
    r.addPosteriorMeansToSeq();
    %% 
    events_all = {r.sequenceData{1}.rates};
    meanRange = 1:size(events_all{1} , 1)/2;
    %%
    events_all = cellfun(@(x) x(meanRange,:),events_all , 'UniformOutput' , false);

    %%
    events_all = cellfun(@(x) mean(x,2), events_all , 'UniformOutput' , false);

    %% add training data to session
    sess = session;
    sess.trainingData = cell2mat(events_all)';

    %% add training labels to session
    [we , ~] = s1.experiments.FR1.sessions.x0x30_.getwordevents;
    trainingLabels = zeros(size(we));
    for iwe = 1 : size(we , 2)
        trainingLabels(iwe) = we{iwe}.recalled;
    end
    sess.trainingLabels = trainingLabels;
    %% add sess to sessionCollection
    sc = sessionCollection;
    sc.addsessionobject(sess);

    %% Train the decoder
    lambdas = logspace(-4,5,30);
    % lambdas = lambdas(10:end);
    % lambdas = lambdas(16);
    [y_h , y_test ,AUCs , ws , maxIdx] = sc.trainis(lambdas , 25,12);
    
    maxAUCs(end+1) = AUCs(maxIdx);
end

%%
[maxAUCsSorted , I] = sort(maxAUCs,'descend');
paramsSorted = {rc.runs(I).params};
c_ic_dim =  cellfun(@(x) x.c_ic_dim , paramsSorted)';
c_factors_dim = cellfun(@(x) x.c_factors_dim , paramsSorted)';

maxAUCsSorted = maxAUCsSorted';
T = table(maxAUCsSorted ,c_ic_dim , c_factors_dim);
writetable(T , '~/snel/share/people/kaveh/runComp2.csv')


%%
events_all = {seq.y};

