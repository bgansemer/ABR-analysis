%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Benjamin Gansemer
%Affiliation: Green Lab, University of Iowa
%Date Started: July 2021
%Last Updated: July 2021

%This function is used to generate figures of ABR waveform data. It is 
%called from the master ABR analysis script if figures are wanted. 
%Data for plotting are received from the identifyPeaks function. 


%Development notes: 
%Add in argument for user to define colors for plots
%Figure out how to check args so that function can be used standalone or be
%called from analyzeABR.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function generateFigs(bigst, t, linkax, plotPoints, compareFig)
function generateFigs(bigst, figOpts)
% bigst the master struct containing all information
% waveforms is the waveform data from identifyPeaks
% t is the time series generated in identifyPeaks
% linkax: logical/boolean, if true, y axes will be linked on figure 1

% arguments
%     bigst struct
%     
%     figOpts.linkax(1,1) logical = 0;
% 
%     figOpts.plotPoints(1,1) logical = 1;
%     
%     figOpts.compareFig(1,1) logical = 0;
%
%     figOpts.Tbegin(1,1) {mustBeNumeric} = 0;
%     
%     figOpts.Tend(1,1) {mustBeNumeric} = 6;
% end

%% transform waveform data from table to array for plotting

waveforms = struct([]);
for f = 1:length(bigst)
    wfs = bigst(f).Waveforms;
    waveforms(1).(bigst(f).Name) = wfs;
end

allPeaks = structfun(@table2array, waveforms, 'UniformOutput', false);
peakNames = fieldnames(allPeaks);
for p = 1:length(peakNames)
    allPeaks.(peakNames{p}) = (allPeaks.(peakNames{p})).*1000000;
end
%     figOpts.legend(1,1) logical = 1;
% end


%% Check if time series (t) is present and sent end time for plots

%sampRate = 24.4; %in kHz
tempWv = bigst(1).Waveforms;
n = numel(tempWv(:,1));
t = 1:1:n;
%t = t/sampRate;
t = t*0.04096;


if figOpts.Tbegin == 0
    idxBegin = 1;
else
    idxBegin = find(abs(t-figOpts.Tbegin)<0.02);
end
idxEnd = find(abs(t-figOpts.Tend)<0.02);

%% Plot each waveform on a separate subplot
%One figure per animal/waveform set, each subplot is an individual waveform
for pk = 1:length(peakNames)
    peaks = allPeaks.(peakNames{pk});
    [~,cls] = size(peaks);
    plotTitle = strrep(peakNames{pk}, 'r_', '');
    plotTitle = strrep(plotTitle, '_', '-');

    figure(pk)
    for wv = 1:cls
        subplot(cls, 1, wv);
        plot(t(idxBegin:idxEnd), peaks(idxBegin:idxEnd, wv))
        if figOpts.plotPoints == true
            hold on
            plot(t(table2array(bigst(pk).waveIdata(wv,2))), ...
                (table2array(bigst(pk).waveIdata(wv,1))), "ro")
            hold on
            plot(t(table2array(bigst(pk).waveIdata(wv,4))), ...
                (table2array(bigst(pk).waveIdata(wv,3))), "bo")
            hold off
        end
        ylab = ylabel(waveforms.(peakNames{pk}).Properties.VariableNames{wv});
        set(get(gca,'YLabel'),'Rotation',0,'VerticalAlignment','middle')
        ylab.Position(1) = -0.5;
        xlim([figOpts.Tbegin figOpts.Tend]);
        if wv ~= cls
            set(gca, 'xticklabel', [])
        end
    end
    if figOpts.linkax == true
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
    plot(t(idxBegin:idxEnd), allPeaks.(peakNames{wv})(idxBegin:idxEnd, :))
    subTitle = strrep(peakNames{wv}, 'r_', '');
    title(strrep(subTitle, '_', '-'))
    xlabel("Latency (ms)")
    ylabel("Wave I Amplitude (µV)")
    xlim([figOpts.Tbegin figOpts.Tend]);
    legend(bigst(wv).Waveforms.Properties.VariableNames, 'Location', 'eastoutside');
    if figOpts.plotPoints == true
        hold on
        plot(t(table2array(bigst(wv).waveIdata(:,2))), ...
            (table2array(bigst(wv).waveIdata(:,1))), "ro")
        hold on
%         plot(t(table2array(waveIdata.(peakNames{wv})(:,4))), ...
%             (table2array(waveIdata.(peakNames{wv})(:,3))), "bo")
        plot(t(table2array(bigst(wv).waveIdata(:,4))), ...
            (table2array(bigst(wv).waveIdata(:,3))), "bo")
        hold off
    end

end
if figOpts.linkax == true
    linkaxes
end
%hold off
%legend(bigst(1).Waveforms.Properties.VariableNames)
%sgtitle(subjID)

%% Plot wave I amplitudes (y-axis) vs. stimulus level (x-axis)
%One figure, one subplot for each animal/waveform set
figure(numFigs+2) %Wave I amp - not fitted
for wv = 1:length(peakNames)
    subplot(2,2,wv);
    amps = flip(table2array(bigst(wv).waveIdata(:,5)));
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
    subTitle = strrep(peakNames{wv}, 'r_', '');
    title(strrep(subTitle, '_', '-'))
end
%linkaxes
%sgtitle(subjID)

%% Plot two waveforms against each other
% if figOpts.compareFig == true
%     %matched waveforms by stimulus level
%     %get waveforms for two conditions, matched by stim level
%     %plot those two waveforms on same plot
%     %do for all waveforms for which there are matches
%     %currently only plots the first two entries in bigst against each other
% 
%     %get waveforms for each animal/conditon into separate arrays
%     samp1 = allPeaks.(peakNames{1})(:,[1:6]);
%     samp2 = allPeaks.(peakNames{2})(:,[1:6]);
%     sampNames = peakNames(1:2);
% 
%     %modify each to add a certain value to each amplitude for an individual
%     %Method from excel sheets is to subtract from waveforms from stimuli below
%     %90dB. First, try adding to waveforms from stimuli above the lowest.
%     %Example: lowest stimulus is 40dB. Add 0 to 40dB waveform, add 3 to all
%     %values in 50dB waveform, add 6 to all values in 60dB waveform, etc.
%     %number of columns is set at 6 currently
%     for col = 1:6
%         samp1(:,col) = samp1(:,col) + ((6-col)*3);
%         samp2(:,col) = samp2(:,col) + ((6-col)*3);
%     end
%     
%     figure(numFigs+3) 
%     hold on
%     h1 = plot(t(idxBegin:idxEnd), samp1(idxBegin:idxEnd, :), ...
%         'Color', 'k', 'LineWidth', 2);
%     h2 = plot(t(idxBegin:idxEnd), samp2(idxBegin:idxEnd, :), ...
%         'Color', [1 0.4 0], 'LineWidth', 2);
%     set(gca, 'YColor', 'white', 'yticklabel', [], 'YTick', [], ...
%         'XMinorTick', 'on', 'TickLength', [0.025,0.01], 'TickDir', 'both')
%     xlabel("Latency (ms)", 'FontWeight', 'bold')
%     xlim([figOpts.Tbegin figOpts.Tend]);
%     
%     if figOpts.legend == true
%         legend([h1(1), h2(1)], strrep(strrep(sampNames, 'r_', ''), '_', '-'), ...
%             'Location', 'eastoutside')
%     end
% %     ylab1 = ylabel("dB SPL", 'Color', 'k', 'FontWeight', 'bold', ...
% %         'FontSize', 12, 'Rotation', 0);
% %     ylab1.Position(1) = -0.5;
% %     ylab1.Position(2) = 18;
% %     ylab2 = ylabel("90", 'Color', 'k', 'FontWeight', 'bold', ...
% %         'FontSize', 10, 'Rotation', 0);
% %     ylab2.Position(1) = -0.5;
% %     ylab2.Position(2) = 15;
% end
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


end