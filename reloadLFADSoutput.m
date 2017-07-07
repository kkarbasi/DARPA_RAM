%%
figure('pos' , [30 30 1600 200])
realL = 96;
L = 124;
for i = 1:110
    numCH = i;
    % subplot(1,2,1)
    plot(seq(3).rates(numCH , :)); hold on
    % subplot(1,2,2)
    plot(realL+1 : realL+ L ,seq(4).rates(numCH , :));
    
%     plot(realL+L+1 : realL+ L+L
    waitforbuttonpress
    clf
end

%%
close all
trim = 28;
data = [seq(3).rates(1:110,1:(96+trim)) seq(4).rates(1:110,trim+1:end)];
data_var = [seq(3).rates(110+(1:110),1:(96+trim)) seq(4).rates(110+(1:110),trim+1:end)];
data_orig = [seq(3).y(1:110,1:(96+trim)) seq(4).y(1:110,trim+1:end)];
%imagesc(diff(data_orig')')
imagesc(diff(data')')
%imagesc(
%tmp = [seq(ntrial).rates(1:110, 96+trim:end)

%% 
fs = seq(1).fs;
realL = 96;
L = numel(seq(1).y_time);
OL = L - realL; %overlap length
tpe = seq(1).trialPerEvent;
ievent = 1;
wordEventsEEG = zeros(300,2800,110);
for is  = 1:tpe:numel(seq)
    curr_event = seq(is).rates(1:110 , 1:realL+OL);
    for it = 1:tpe-1
       curr_event = [curr_event seq(is + it).rates(1:110 , OL+1:end)];
    end
    for ich = 1:110
        curr_event_us(ich,:) = interp(curr_event(ich,:) , 4);
    end
    wordEventsEEG(ievent , : , :) = curr_event_us';
    ievent = ievent + 1;
end









%% Creating the wordEventsEEG cell array from 
fs = seq(1).fs;
realL = 96;
L = numel(seq(1).y_time);
OL = L - realL; %overlap length
tpe = seq(1).trialPerEvent;

eventIdx = unique([seq(:).ievent]);
trialIdx = unique([seq(:).itrial]);
padding = 5;
ievent = 1;
for is = 1 : tpe : numel(seq)
    curr_event = [];
    for it = trialIdx
        curr_seq = seq(is+it-1).rates(1:110,:);
        next_seq = seq(is+it).rates(1:110,:);
        
        mean_curr = mean(curr_seq(:, end-OL+1:end)');
        mean_next = mean(next_seq(:, 1:OL)');
        mean_diff = mean_next - mean_curr;
        
        next_seq = bsxfun(@minus, next_seq , mean_diff');
        
        curr_event = [curr_event seq(is+it-1).rates(1:110,padding:end)];
    end
    wordEventsEEG{ievent} = curr_event;
    ievent = ievent + 1;
end

%%
realL = 96;
L = numel(seq(1).y_time);
OL = L - realL; %overlap length
tpe = seq(1).trialPerEvent;
padding = 5;

curr_ev_seq = seq(1:tpe);

curr_event = [];
for i = 1:tpe-1
    curr_seq = seq(i).rates(1:110 , :);
    next_seq = seq(i+1).rates(1:110 , :);
    
    mean_curr = mean(curr_seq(:, end-OL+1:end)');
    mean_next = mean(next_seq(:, 1:OL)');
    
    mean_diff = mean_next - mean_curr;
    
    next_seq = bsxfun(@minus, next_seq , mean_diff');
    
    curr_event = [curr_seq(: , padding:end) next_seq(:, )]
    
end

%%
realL = 96;
L = numel(seq(1).y_time);
OL = L - realL; %overlap length
tpe = seq(1).trialPerEvent;
padding = 7;

curr_ev_seq = seq(1:tpe);
seq_aligned = [];
seq_aligned(1).y = seq(1).rates(1:110,:);
curr_event = [];
for i = 2:numel(seq)
    curr_seq = seq(i-1).rates(1:110 , :);
    next_seq = seq(i).rates(1:110 , :);
    
    mean_curr = mean(curr_seq(:, end-OL+1:end)');
    mean_next = mean(next_seq(:, padding:OL)');
    
    mean_diff = mean_next - mean_curr;
    
    next_seq = bsxfun(@minus, next_seq , mean_diff');
    
    seq_aligned(i).y = next_seq;
    
end



%%
figure('pos' , [30 30 1600 200])
for i = 1:110
    numCH = i;
    % subplot(1,2,1)
    plot(seq_aligned(1).y(numCH , :)); hold on
    % subplot(1,2,2)
    plot(realL+1 : realL+ L ,seq_aligned(2).y(numCH , :));
    
%     plot(realL+L+1 : realL+ L+L
    waitforbuttonpress
    clf
end






