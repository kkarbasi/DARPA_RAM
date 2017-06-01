%% get word event bp eeg trimmed to -2000ms to +3600ms rel to event onset
sessID = '0';
seeg_sess_0 = s1.experiments('FR1').wordEventsEEG;
save_path = '~/snel/share/derived/DARPA_RAM/Plots/For_email_to_youssef/5-24-17/';

%% get electrode ids for the first 3 bipolar channels
pairs = s1.experiments('FR1').getpairs(['x0x3' sessID '_']);
pairNames = fieldnames(pairs);
nChannels = numel(pairNames); 
refs = {};
for i = 1:3
    ch1 = num2str(pairs.(pairNames{i}).channel_1 , '%03i');
    ch2 = num2str(pairs.(pairNames{i}).channel_2 , '%03i');
    disp(['Bipolar channel: ' ch2 ' - ' ch1])
    refs{i} = [ch1 ; ch2];
end

%% plot bp channels (normalized) vs time for the first three events:
close all
for ievent = 1:3

    fh = figure('units','normalized','outerposition',[0 0 1 1]);
    curr_event = squeeze(seeg_sess_0(ievent , :,:));
    curr_event = curr_event./repmat(std(curr_event),size(curr_event,1),1);
    curr_event = curr_event - repmat(mean(curr_event),size(curr_event,1),1);

    t = -2000:2:3599;
    numChannels = 110;

    for k=1:numChannels
      plot(t,curr_event(:,k)+3*k);
      hold on
    end
    yticks([min(curr_event(:,1)) , max(curr_event(:,k) + 3*k)])
    yticklabels({'bp ch 1' , ['bp ch ' num2str(numChannels)]})
    xlim([t(1) , t(end)+1])
    ylim([min(curr_event(:,1)) , max(curr_event(:,k) + 3*k)]);
    
    xlabel('Time (ms) relative to event onset')
    ylabel('Bipolar channels')
    title(['Raw bipolar (normalized) data for session ' sessID ' event ' num2str(ievent)])  
    hold off
    saveas(fh , fullfile(save_path , ['Raw_sess_' sessID '_wordevent_' num2str(ievent) '.png']));
    % heatmap style
    fh = figure('units','normalized','outerposition',[0 0 1 1]);
    imagesc(flipud(curr_event'));
    set(gca,'YTickLabel',flipud(get(gca,'YTickLabel')));
    set(gca,'XTickLabel', num2str((str2double(get(gca , 'XTicklabels'))*2+t(1)))  )
    xlabel('Time (ms) relative to event onset')
    ylabel('Bipolar channels')
    title(['Raw bipolar (normalized) data for session ' sessID ' event ' num2str(ievent)])  
    saveas(fh , fullfile(save_path , ['Raw_sess_' sessID '_wordevent_' num2str(ievent) 'heatmap.png']));
end

%% wavelet plot for first event first 3 channels
waveletTd = s1.experiments('FR1').weCWT;

ievent = 1;
for ichannel = 1:3
    % ichannel = 1;
    wecwt1 = waveletTd{ievent};
    fh = figure;
    imagesc(squeeze( abs( wecwt1(ichannel , : , : ))));
    
%     set(gca,'YTickLabel',flipud(get(gca,'YTickLabel')));
    logsp = (log2(200)-log2(1))/49;
    logsp = 2.^(0:logsp:logsp*49);
    logsp = logsp(5:5:50);
    
    set(gca,'YTickLabel' , logsp)
    set(gca,'XTickLabel', num2str((str2double(get(gca , 'XTicklabels'))*2+t(1))))
    ylabel('Frequency (Hz)');
    xlabel('Time (ms) relative to event onset')
    title(['Wavelet conv. output; event ' num2str(ievent) ' channel '...
        num2str(ichannel) '; bp pairs:' num2str(refs{ichannel}(1,:)) ', ' ...
        num2str(refs{ichannel}(2,:))]);
    saveas(fh , fullfile(save_path , ['wavelet_conv_output_sess_' sessID ...
    '_event_' num2str(ievent) '_bpch_' num2str(ichannel) '.png']));
end


%% plot mean power after zscoring
sess0 = '~/snel/share/derived/DARPA_RAM/training_testing_data/5-24-17/sess0.mat';
sess1 = '~/snel/share/derived/DARPA_RAM/training_testing_data/5-24-17/sess1.mat';
sessVar = ['sess' sessID];

load(eval(sessVar));

freqLS = 2.^([0:49].*0.1560); % frequencies, logspaced

for ichannel = 1:3
   fh = figure('units','normalized','outerposition',[0 0 1 1]);
   plot(freqLS , cell2mat(squeeze(trainingData(ievent , ichannel , :))) , '-*');
   xlabel('Frequency (Hz)');
   xlim([1 , 200])
   ylabel('abs')
   title(['Power vs freq; event ' num2str(ievent) ' channel '...
        num2str(ichannel) '; bp pairs:' num2str(refs{ichannel}(1,:)) ', ' ...
        num2str(refs{ichannel}(2,:))]);
    saveas(fh , fullfile(save_path , ['powerVSfreq_sess_' sessID '_event_' num2str(ievent)...
        '_bpch_' num2str(ichannel) '.png']));
end


