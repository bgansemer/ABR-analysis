%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Benjamin Gansemer
%Affiliation: Green Lab, University of Iowa
%Date Started: July 2021
%Last Updated: July 2021

%This function is used to generate figures of ABR waveform data. It is 
%called from the master ABR analysis script if figures are wanted. 
%Data for plotting are received from the identifyPeaks function. 


%Development notes: need to change all waveIdata instances to reflect
%removal of waveIdata as its own struct. All wave I data is now part of
%bigst. Early solution = generate waveIdata struct from bigst within this
%function. Later solution will get rid of that step.

%Also want to add argument to allow user to decide whether wave I points
%will also be plotted on waveform traces.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function generateFigs(waveforms, bigst, t, linkax)
% waveforms is the waveform data from identifyPeaks
% waveIdata is the table of wave I amp and latency from idenfyPeaks
% t is the time series generated in identifyPeaks
% linkax: logical/boolean, if true, y axes will be linked on figure 1
%% generate plots - all freqs on figures

allPeaks = structfun(@table2array, waveforms, 'UniformOutput', false);
peakNames = fieldnames(allPeaks);
for p = 1:length(peakNames)
    allPeaks.(peakNames{p}) = (allPeaks.(peakNames{p})).*1000000;
end

Tend = 6;
idxEnd = find(abs(t-Tend)<0.02);

%% Plot each waveform on a separate subplot
%One figure per animal/waveform set, each subplot is an individual waveform
for pk = 1:length(peakNames)
    peaks = allPeaks.(peakNames{pk});
    [~,cls] = size(peaks);
    plotTitle = strrep(peakNames{pk}, 'r', '');
    plotTitle = strrep(plotTitle, '_', '-');

    figure(pk)
    for wv = 1:cls
        subplot(cls, 1, wv);
        plot(t(1:idxEnd), peaks(1:idxEnd, wv))
        hold on
        plot(t(table2array(waveIdata.(peakNames{pk})(wv,2))), ...
            (table2array(waveIdata.(peakNames{pk})(wv,1))), "ro")
        hold on
        plot(t(table2array(waveIdata.(peakNames{pk})(wv,4))), ...
            (table2array(waveIdata.(peakNames{pk})(wv,3))), "bo")
        hold off
        ylab = ylabel(waveforms.(peakNames{pk}).Properties.VariableNames{wv});
        set(get(gca,'YLabel'),'Rotation',0,'VerticalAlignment','middle')
        ylab.Position(1) = -0.5;
        if wv ~= cls
            set(gca, 'xticklabel', [])
        end
    end
    if linkax == true
        linkaxes
    end
    %legend(data.Waveforms.Properties.VariableNames)
    xlabel("Latency (ms)")
    %ylabel("Amplitude (µV)")
    %title("Waveforms")
    sgtitle(plotTitle)
end

numFigs = length(findobj('type', 'figure'));

%% Plot waveforms for all stimulus levels on one plot
%One figure, one subplot for each animal/waveform set
figure(numFigs+1) %all waveforms on same plot

for wv = 1:length(peakNames)
    subplot(2,2,wv);
    plot(t(1:idxEnd), allPeaks.(peakNames{wv})(1:idxEnd, :))
    subTitle = strrep(peakNames{wv}, 'r', '');
    title(strrep(subTitle, '_', '-'))
    xlabel("Latency (ms)")
    ylabel("Wave I Amplitude (µV)")
    hold on
    plot(t(table2array(waveIdata.(peakNames{wv})(:,2))), ...
        (table2array(waveIdata.(peakNames{wv})(:,1))), "ro")
    hold on
    plot(t(table2array(waveIdata.(peakNames{wv})(:,4))), ...
        (table2array(waveIdata.(peakNames{wv})(:,3))), "bo")
    hold off

end
if linkax == true
    linkaxes
end
%hold off
legend(waveforms.(peakNames{1}).Properties.VariableNames)
%sgtitle(subjID)

%% Plot wave I amplitudes (y-axis) vs. stimulus level (x-axis)
%One figure, one subplot for each animal/waveform set
figure(numFigs+2) %Wave I amp - not fitted
for wv = 1:length(peakNames)
    subplot(2,2,wv);
    amps = flip(table2array(waveIdata.(peakNames{wv})(:,5)));
    stims = flip(waveforms.(peakNames{wv}).Properties.VariableNames);
    levs = cellfun(@(x) strsplit(x, '-'), stims, 'UniformOutput', false);
    x = [];
    for i=1:length(levs)
        l = convertCharsToStrings(levs{i}{1});
        x = vertcat(x, l);
    end
    x = str2double(x);
    plot(x, amps, "ko", 'MarkerSize', 8, 'MarkerFaceColor', 'k')
    %set(gca, 'XTickLabel', stims)
    ax = gca;
    ax.XAxis.MinorTick = 'on';
    xlim([0 100])
    xticks([0:20:100])
    ylim([0 3])
    xlabel('Stimulus level (dB SPL)')
    ylabel("Wave I Amplitude (µV)")
    subTitle = strrep(peakNames{wv}, 'r', '');
    title(strrep(subTitle, '_', '-'))
end
%linkaxes
%sgtitle(subjID)

%figure(numFigs+3) %matched waveforms by stimulus level
%get waveforms for two conditions, matched by stim level
%plot those two waveforms on same plot
%do for all waveforms for which there are matches

%     figure(numFigs+3) %Wave I amp - curve fitted
%     for wv = 1:length(peakNames)
%         subplot(2,2,wv);
%         amps = flip(table2array(waveIdata.(peakNames{wv})(:,5)));
%         stims = flip(waveforms.(peakNames{wv}).Properties.VariableNames);
%         
%         %get stim levels to calculate growth function
%         levs = cellfun(@(x) strsplit(x, '-'), stims, 'UniformOutput', false);
%         x = [];
%         for i=1:length(levs)
%             l = convertCharsToStrings(levs{i}{1});
%             x = vertcat(x, l);
%         end
%         x = str2double(x);
%         
%         %calculate noise - average from 7ms to end
%         Tnoise = 7.0;
%         idxnoise = find(abs(t-Tnoise)<0.02);
%         avgs = mean(allPeaks.(peakNames{pk})(idxnoise:end,:);
%         noise = mean(avgs);
%         
%         gf = csaps(x, amps, 0.001);
%         
%     end

% figure(4) %cross correlations
% for wv = 1:cls
%     plot((lags(:,wv)/sampRate).*1000, crosscorrs(:, wv))
%     hold on
% end
% hold off
% legend(data.Waveforms.Properties.VariableNames)
% xlabel("Latency (ms)")
% ylabel("Amplitude (µV)")
% title("Cross-correlations")
end