%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Benjamin Gansemer
%Affiliation: Green Lab, University of Iowa
%Date Started: August 2020
%Last Updated: July 2021

%The function(s) in this script are used to identify peaks in ABR
%waveforms. Main focus is on wave I amplitude. 

%Notes: use xcorr to aid in identifying peaks - cross correlate each
%waveform with the waveform of the highest stimulus level.
%Use smoothing spline function (csaps) to fit growth function. (also need
%to talk to Steven and Ning about this.
%use gradient/diff function to aid in peak identification?
%something about hanning windows

%Notes for development:
%Should get rid of the separate waveforms struct and put it in the big struct. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function [bigst, waveforms, crosscorrs, arrayTable] = identifyPeaks(dataFiles, linkax)
%function [bigst, waveforms, waveIdata, t] = identifyPeaks(dataFiles)
function [bigst, t] = identifyPeaks(dataFiles)
% dataFiles: cell array of filename information for txt files to be
% analyzed. The array is generated using getFileNames.m
% bigst is a struct with sample info and waveform data from each input file
% waveforms is struct with all waveform data
% waveIdata is a struct with calculated ABR wave I amplitude and latencies
% t is the time series generated for getting indices of amplitude
% measurements and timepoints for plotting

        

%% Read the raw data into Matlab using getABRdata.m
bigst = struct([]);

bigst = cellfun(@getABRdata, dataFiles);
% for f = 1:length(dataFiles)
%     
%     [~, fname] = fileparts(dataFiles{f});
%     fname = strrep(fname, '-', '_');
%     fname = strcat('r', fname);
%     
%     data = getABRdata(dataFiles{f});
% 
% %     if data.Info ~= "No group info"
% %         subjID = strrep(data.Info{find(contains(data.Info, 'Subject ID:'))}, ...
% %             'Subject ID: ', '');
% %     else
% %         subjID = "No ID";
% %     end
%     
%     bigst(1).(fname) = data;
% end

%% Get waveform data for each frequency
%fields = fieldnames(bigst);

% waveforms = struct([]);
% 
% for f = 1:length(bigst)
%     wfs = bigst(f).Waveforms;
%     waveforms(1).(bigst(f).Name) = wfs;
% end

%freq = data.Info{end};

%peaks = table2array(waveforms);

%% Generate timepoint series
%all waveforms should have 292 elements.
%add in check to make sure all waveforms have 292 elements
%sampRate = 24.4; %in kHz
tempWv = bigst(1).Waveforms;
n = numel(tempWv(:,1));
t = 1:1:n;
%t = t/sampRate;
t = t*0.04096;
%add t to bigst so an additional argument isn't needed later



%% start processing each waveform in a loop
%adds calculated wave I data to table and adds to table to corresponding
%entry in bigst
%maybe make this its own function to vectorize it instead of using the
%loop? (or figure out some other way to vectorize it)

%for f = 1:length(fields)
for f = 1:length(bigst)
    
    %% get individual waveform data
    data = bigst(f);

    %peaks = table2array(waveforms.(bigst(f).Name));
    peaks = table2array(data.Waveforms);
    [rws, cls] = size(peaks);
   
    freq = data.Info{end};
    freq = strrep(freq, '000 Hz', 'kHz');
    

    
    if data.Info ~= "No group info"
        subjID = strrep(data.Info{find(contains(data.Info, 'Subject ID:'))}, ...
            'Subject ID: ', '');
    else
        subjID = "No ID";
    end
    
    %stimLevels = (waveforms.(bigst(f).Name).Properties.VariableNames)';
    stimLevels = (data.Waveforms.Properties.VariableNames)';
    
    %% calculate signal-to-noise ratio?
    %SNR - calculate SEM of averages


    %% perform cross-correlation of each waveform with the 90dB waveform using xcorr
    
%     %iterating through matrix, where c is column number
%     %matrix(:, c)
%     
%     crosscorrs = [];
%     lags = [];
%     %[rws, cls] = size(peaks);
%     
%     for i = 1:cls
%         [tempcorr, templag] = xcorr(peaks(:, i), peaks(:, 1));
%         
%         crosscorrs = [crosscorrs tempcorr];
%         lags = [lags templag];
%     
%     end
%     
%     [maxcors, corridx] = max(crosscorrs);
%     
%     corrdiffs = corridx - corridx(1);
    
    %% get wave 1 amplitudes and latencies
    %generate timepoints/time domain for plotting
%     sampRate = 24.4; %in kHz
%     n = numel(peaks(:,1));
%     t = 1:1:n;
%     t = t/sampRate;
    %get wave 1 amplitudes and latencies
    %specify timewindow for N1
    t1 = 1.1;
    t2 = 2.0;
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
        tempidx1 = round(idx1 + 1.2*wf);
        tempidx2 = round(idx2 + 1.2*wf);
        %tempidx1 = idx1;
        %tempidx2 = idx2;
        %assess how far apart the tempidx are from the previous?
        
        if tempidx1 < 0 || tempidx2 < 0 
            tempidx1 = idx1;
            tempidx2 = idx2;
        end
        
        %need to figure out how to catch index out of range error
        N = max(peaks(tempidx1:tempidx2, wf));
        Nidx = find(~(peaks(:, wf)-N));
        if length(Nidx) > 1
            Nidx = Nidx(1);
        end
        N = N*1000000;
        %set time window for looking for P1 - first time is N1 latency,
        %next time is N1 latency + 0.5ms
        idx3 = Nidx;
        t4 = t(Nidx) + 0.75;
        idx4 = find(abs(t-t4)<tol);
        
        P = min(peaks(idx3:idx4, wf));
        Pidx = find(~(peaks(:, wf)-P));
        if length(Pidx) > 1
            Pidx = Pidx(1);
        end
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
    
    %waveIdata(1).(fields{f}) = arrayTable;
    %bigst.(fields{f}).WaveI = arrayTable;
    bigst(f).waveIdata = arrayTable;
    
    %writetable(bigst(f).waveIdata, filename.csv);

end   

end

