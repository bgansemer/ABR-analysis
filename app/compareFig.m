function compareFig(bigst, figOpts)
%compareFig 
%   started: July 2021
%   last updated: July 2021
%   author: Benjamin Gansemer, Green lab, University of Iowa
%   This function plots matched waveforms by stimulus level against each
%   other. First, get waveforms for two conditions, matched by stim level,
%   then plot those two waveforms on same plot. Do this for all waveforms 
%   for which there are matches. Currently plots the first 6 matches, which
%   corresponds to the highest stimulus level to the 6th highest. May add
%   in option to specify which stimulus levels to plot.
%   Currently only plots the first two entries in bigst against each other.
%   bigst is a struct with all waveform information. bigst is generated by
%   running identifyPeaks. 
%   t is a timeseries for the waveform. If it is not provided, it is
%   generated.
%   figOpts is a list of figure options 

% arguments
%     bigst struct
%     
%     figOpts.linkax (1,1) logical = 0;
% 
%     figOpts.plotPoints (1,1) logical = 1;
%     
%     figOpts.Tbegin (1,1) {mustBeNumeric} = 0;
%     
%     figOpts.Tend (1,1) {mustBeNumeric} = 6;
%     
%     figOpts.legend (1,1) logical = 1;
% 
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

%% get waveforms for each animal/conditon into separate arrays
if length(peakNames) == 1
    samp1 = allPeaks.(peakNames{1})(:,[1:6]);
    sampNames = peakNames(1);
else
    samp1 = allPeaks.(peakNames{1})(:,[1:6]);
    samp2 = allPeaks.(peakNames{2})(:,[1:6]);
    sampNames = peakNames(1:2);
end

%modify each to add a certain value to each amplitude for an individual
%Method from excel sheets is to subtract from waveforms from stimuli below
%90dB. First, try adding to waveforms from stimuli above the lowest.
%Example: lowest stimulus is 40dB. Add 0 to 40dB waveform, add 3 to all
%values in 50dB waveform, add 6 to all values in 60dB waveform, etc.
%number of columns is set at 6 currently
if length(peakNames) == 1
    for col = 1:6
        samp1(:,col) = samp1(:,col) + ((6-col)*3);
    end
else
    for col = 1:6
        samp1(:,col) = samp1(:,col) + ((6-col)*3);
        samp2(:,col) = samp2(:,col) + ((6-col)*3);
    end
end

numFigs = length(findobj('type', 'figure'));

figure(numFigs+1) 
hold on
if length(peakNames) == 1
    h1 = plot(t(idxBegin:idxEnd), samp1(idxBegin:idxEnd, :), ...
    'Color', 'k', 'LineWidth', 2);
    set(gca, 'YColor', 'white', 'yticklabel', [], 'YTick', [], ...
        'XMinorTick', 'on', 'TickLength', [0.025,0.01], 'TickDir', 'both')
    xlabel("Latency (ms)", 'FontWeight', 'bold')
    xlim([figOpts.Tbegin figOpts.Tend]);
else
    h1 = plot(t(idxBegin:idxEnd), samp1(idxBegin:idxEnd, :), ...
        'Color', 'k', 'LineWidth', 2);
    h2 = plot(t(idxBegin:idxEnd), samp2(idxBegin:idxEnd, :), ...
        'Color', [1 0.4 0], 'LineWidth', 2);
    set(gca, 'YColor', 'white', 'yticklabel', [], 'YTick', [], ...
        'XMinorTick', 'on', 'TickLength', [0.025,0.01], 'TickDir', 'both')
    xlabel("Latency (ms)", 'FontWeight', 'bold')
    xlim([figOpts.Tbegin figOpts.Tend]);
end

if figOpts.legend == true
    if length(peakNames) == 1
        legend([h1(1)], strrep(strrep(sampNames, 'r_', ''), '_', '-'), ...
        'Location', 'eastoutside')
    else
        legend([h1(1), h2(1)], strrep(strrep(sampNames, 'r_', ''), '_', '-'), ...
            'Location', 'eastoutside')
    end
end
%     ylab1 = ylabel("dB SPL", 'Color', 'k', 'FontWeight', 'bold', ...
%         'FontSize', 12, 'Rotation', 0);
%     ylab1.Position(1) = -0.5;
%     ylab1.Position(2) = 18;
%     ylab2 = ylabel("90", 'Color', 'k', 'FontWeight', 'bold', ...
%         'FontSize', 10, 'Rotation', 0);
%     ylab2.Position(1) = -0.5;
%     ylab2.Position(2) = 15;
end

