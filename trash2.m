%% load all events
ef = regexdir('~/cosmic-home/DARPARAM/events_resampled_bp' , '^\d\d\d\.mat$');
ef = unique(ef);

numEvents = numel(ef);

load(ef{1})
numChannels = size(ecwt_r , 1);
numFreqs = size(ecwt_r , 2);

%%

% events_all = cell(numEvents , 1);
events_all = zeros([numEvents , size(ecwt_r)]); % event X channel X freq X time

for ievent = 1 : numEvents
    load(ef{ievent});
    events_all(ievent , : ,: ,:) = abs(ecwt_r);

end

%%
% events_all = abs(events_all);
events_all = single(events_all);

%%

events_all_tmp = permute(events_all , [2, 3, 1, 4]);
disp(size(events_all_tmp))
%%
events_all_tmp = reshape(events_all_tmp , size(events_all_tmp , 1) , size(events_all_tmp , 2) , []);
disp(size(events_all))
%%
% events_all = single(events_all);
% disp(size(events_all))
%%
avgs = mean(events_all_tmp , 3);
stds = std(events_all_tmp ,0, 3);
% avgChannels = mean(mean(mean(events_all,1) , 3) , 4);
% avgChannels2 = mean(reshape(permute(events_all , [2,1,3,4]) , size(events_all , 2) , []),2);
% stdChannels = std(std(std(events_all,1) , 3) , 4);
%%
events_all = reshape(events_all , size(events_all , 1) , size(events_all , 2) , numEvents , size(ecwt_r,3));
disp(size(events_all))

%%
events_all = permute(events_all , [3,1,2,4]);
disp(size(events_all))
%%
zscored = num2cell(events_all , 4);
%%
for ievent = 1:numEvents
    
    for ichannel = 1:numChannels
        for ifreq = 1:numFreqs
            zscored{ievent , ichannel , ifreq} =...
                mean( (zscored{ievent , ichannel , ifreq}...
                 - avgs(ichannel , ifreq)) ./ stds(ichannel , ifreq) );
        end
    end
end


%%

for ievent  = 1:numel(ef)
    disp(ef{ievent})
end

%%
outIdx =[];
for ievent = 1:numel(ef)
    tmp = strfind(ef , ef{ievent});
    outIdx = [outIdx [find(~cellfun('isempty' , tmp))]];
    if numel(outIdx)>1 && outIdx(end) < outIdx(end-1)
        disp(outIdx(end-1))
        disp(outIdx(end))
    end
end