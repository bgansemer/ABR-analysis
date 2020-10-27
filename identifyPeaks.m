%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Benjamin Gansemer
%Affiliation: Green Lab, University of Iowa
%Date Started: August 2020
%Last Updated: October 2020

%The function(s) in this script are used to identify peaks in ABR
%waveforms. Main focus is on wave I amplitude. 

%Notes: use xcorr to aid in identifying peaks - cross correlate each
%waveform with the waveform of the highest stimulus level.
%Use smoothing spline function (csaps) to fit growth function. (also need
%to talk to Steven and Ning about this.
%use gradient/diff function to aid in peak identification?
%something about hanning windows

% get list of files in directory: 
%   files = dir([directory '\*.txt']);
%   names = {files.name};
%   folders = {files.folder};
%   fullNames = strcat(folders, {'\'}, names);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function [bigst, waveforms, crosscorrs, arrayTable] = identifyPeaks(dataFiles, linkax)
function [bigst, waveforms, waveIdata] = identifyPeaks(dataFiles, figs, linkax)
% Input argument is the dataFile, first step is to run getABRdata
% to read the data into Matlab.
% figs: logical/boolean, if true figures will be generated
% linkax: logical/boolean, if true, y axes will be linked on figure 1

arguments
    dataFiles;
end

arguments
    figs(1,1) logical = 1;
end

arguments
    linkax(1,1) logical = 0;
end

%% Check type of dataFiles input
if class(dataFiles) == 'cell'
    dataFiles = dataFiles;
elseif class(dataFiles) == 'char'
    dataFiles = getFileNames(dataFiles);
else
    error('Error. File input must be a char or cell, not a %s.', ...
        class(dataFiles))
end
        

%% Read the raw data into Matlab using getABRdata.m
bigst = struct([]);
for f = 1:length(dataFiles)
    
    [~, fname] = fileparts(dataFiles{f});
    fname = strrep(fname, '-', '_');
    fname = strcat('r', fname);
    
    data = getABRdata(dataFiles{f});

%     if data.Info ~= "No group info"
%         subjID = strrep(data.Info{find(contains(data.Info, 'Subject ID:'))}, ...
%             'Subject ID: ', '');
%     else
%         subjID = "No ID";
%     end
    
    bigst(1).(fname) = data;
end


%% Get waveform data for each frequency
fields = fieldnames(bigst);

waveforms = struct([]);

for f = 1:length(fields)
    wfs = bigst.(fields{f}).Waveforms;
    waveforms(1).(fields{f}) = wfs;
    
end

%freq = data.Info{end};

%peaks = table2array(waveforms);


%% start processing each waveform in a loop
waveIdata = struct([]);

for f = 1:length(fields)
    
    %% get individual waveform data
    data = bigst.(fields{f});
    peaks = table2array(waveforms.(fields{f}));
    [rws, cls] = size(peaks);
   
    freq = data.Info{end};
    freq = strrep(freq, '000 Hz', 'kHz');
    

    
    if data.Info ~= "No group info"
        subjID = strrep(data.Info{find(contains(data.Info, 'Subject ID:'))}, ...
            'Subject ID: ', '');
    else
        subjID = "No ID";
    end
    
    stimLevels = (waveforms.(fields{f}).Properties.VariableNames)';
    
    %% calculate signal-to-noise ratio?
    %SNR - calculate SEM of averages


    %% perform cross-correlation of each waveform with the 90dB waveform using xcorr
    
    %iterating through matrix, where c is column number
    %matrix(:, c)
    
    crosscorrs = [];
    lags = [];
    %[rws, cls] = size(peaks);
    
    for i = 1:cls
        [tempcorr, templag] = xcorr(peaks(:, i), peaks(:, 1));
        
        crosscorrs = [crosscorrs tempcorr];
        lags = [lags templag];
    
    end
    
    [maxcors, corridx] = max(crosscorrs);
    
    corrdiffs = corridx - corridx(1);
    
    %% get wave 1 amplitudes and latencies
    %generate timepoints/time domain for plotting
    sampRate = 24.4; %in kHz
    n = numel(peaks(:,1));
    t = 1:1:n;
    t = t/sampRate;
    %get wave 1 amplitudes and latencies
    %specify timewindow for N1
    t1 = 1.2;
    t2 = 1.8;
%     %specify timewindow for P1
%     t3 = 1.5;
%     t4 = 2.8;
    tol = 0.02;

    %get indices of timewindows
    idx1 = find(abs(t-t1)<tol);
    idx2 = find(abs(t-t2)<tol);
%     idx3 = find(abs(t-t3)<tol);
%     idx4 = find(abs(t-t4)<tol);
    
    
    %get amplitudes and latencies 
    %Need to figure out how to appropriately use cross correlations to
    %shift time windows. 
    ALarray = [];
    for wf = 1:cls
        tempidx1 = round(idx1 + 2.5*wf);
        tempidx2 = round(idx2 + 2.5*wf);
        
        %assess how far apart the tempidx are from the previous?
        
        if tempidx1 < 0 || tempidx2 < 0 
            tempidx1 = idx1;
            tempidx2 = idx2;
        end
        
        %need to figure out how to catch index out of range error
        N = max(peaks(tempidx1:tempidx2, wf));
        Nidx = find(~(peaks(:, wf)-N));
        N = N*1000000;
        %set time window for looking for P1 - first time is N1 latency,
        %next time is N1 latency + 0.5ms
        idx3 = Nidx;
        t4 = t(Nidx) + 0.75;
        idx4 = find(abs(t-t4)<tol);
        
        P = min(peaks(idx3:idx4, wf));
        Pidx = find(~(peaks(:, wf)-P));
        P = P*1000000;
        W = N-P;
        ALarray(wf,1) = N;
        ALarray(wf,2) = Nidx;
        ALarray(wf,3) = P;
        ALarray(wf,4) = Pidx;
        ALarray(wf,5) = W;
        ALarray(wf,6) = t(Nidx);
    end 

    arrayTable = array2table(ALarray);
    arrayTable = [ arrayTable cell2table(stimLevels) ];
    %arrayTable = arrayTable(:,:);
    arrayTable.Properties.VariableNames = [ {'N1 amplitude (µV)'}...
        {'N1 index'} {'P1 amplitude (µV)'} {'P1 index'}...
        {'Wave I amplitude (µV)'} {'Wave I latency (ms)'} {'Stimulus level'} ];
    % writetable(arrayTable, filename.csv);
    
    waveIdata(1).(fields{f}) = arrayTable;

%     %% generate plots - all freqs separate
%     if figs == true
%         peaks = peaks.*1000000;
%         figure(1) %each waveform on separate plot
%         %want to figure out how to plot only 1 to 6 ms
%         for wv = 1:cls
%             subplot(cls, 1, wv);
%             plot(t, peaks(:, wv))
%             hold on
%             plot(t(ALarray(wv,2)), (ALarray(wv,1)*1000000), "ro")
%             hold off
%             ylab = ylabel(data.Waveforms.Properties.VariableNames(wv));
%             set(get(gca,'YLabel'),'Rotation',0,'VerticalAlignment','middle')
%             ylab.Position(1) = -1;
%             if wv ~= cls
%                 set(gca, 'xticklabel', [])
%             end
%         end
%         if linkax == true
%             linkaxes
%         end
%         %legend(data.Waveforms.Properties.VariableNames)
%         xlabel("Latency (ms)")
%         %ylabel("Amplitude (µV)")
%         %title("Waveforms")
%         sgtitle(strcat(subjID, ' -  ', freq))
% 
%         figure(2) %all waveforms on same plot
%         %want to figure out how to plot only 1 to 6 ms
%         %figure out how to plot all for freqs on one plot
%         for wv = 1:cls
%             plot(t, peaks(:, wv))
%             hold on
%             plot(t(ALarray(wv,2)), (ALarray(wv,1)*1000000), "ro")
%             hold on
% 
%         end
%         hold off
%         legend(data.Waveforms.Properties.VariableNames)
%         xlabel("Latency (ms)")
%         ylabel("Wave I Amplitude (µV)")
%         title(strcat(subjID, ' -  ', freq))
% 
%         figure(3) %Wave I amp
%         %figure out how to plot all for freqs on one plot
%         amps = flip(ALarray(:,1));
%         amps2 = vertcat(0, amps, 0);
%         stims = flip(data.Waveforms.Properties.VariableNames);
%         plot(amps.*1000000, "ko", 'MarkerSize', 8, 'MarkerFaceColor', 'k')
%         set(gca, 'XTickLabel', stims)
%         ylabel("Wave I Amplitude (µV)")
%         title(strcat(subjID, ' -  ', freq))
% 
%         % figure(4) %cross correlations
%         % for wv = 1:cls
%         %     plot((lags(:,wv)/sampRate).*1000, crosscorrs(:, wv))
%         %     hold on
%         % end
%         % hold off
%         % legend(data.Waveforms.Properties.VariableNames)
%         % xlabel("Latency (ms)")
%         % ylabel("Amplitude (µV)")
%         % title("Cross-correlations")
%     end
end   
%% generate plots - all freqs on figures
if figs == true

    allPeaks = structfun(@table2array, waveforms, 'UniformOutput', false);
    peakNames = fieldnames(allPeaks);
    for p = 1:length(peakNames)
        allPeaks.(peakNames{p}) = (allPeaks.(peakNames{p})).*1000000;
    end
    
    Tend = 6;
    idxEnd = find(abs(t-Tend)<0.02);
    
    
    for pk = 1:length(peakNames)
        peaks = allPeaks.(peakNames{pk});
        [~,cls] = size(peaks);
        plotTitle = strrep(peakNames{pk}, 'r', '');
        plotTitle = strrep(plotTitle, '_', '-');
        
        figure(pk) %each waveform on separate plot
        %want to figure out how to plot only 1 to 6 ms
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
    
    figure(5) %all waveforms on same plot
    %want to figure out how to plot only 1 to 6 ms
    
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
    legend(data.Waveforms.Properties.VariableNames)
    sgtitle(subjID)

    figure(6) %Wave I amp
    for wv = 1:length(peakNames)
        subplot(2,2,wv);
        amps = flip(table2array(waveIdata.(peakNames{wv})(:,5)));
        %amps = amps.*1000000;
        stims = flip(waveforms.(peakNames{wv}).Properties.VariableNames);
        plot(amps, "ko", 'MarkerSize', 8, 'MarkerFaceColor', 'k')
        set(gca, 'XTickLabel', stims)
        ylabel("Wave I Amplitude (µV)")
        subTitle = strrep(peakNames{wv}, 'r', '');
        title(strrep(subTitle, '_', '-'))
    end
    %linkaxes
    sgtitle(subjID)
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
end

