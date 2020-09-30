%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Benjamin Gansemer
%Affiliation: Green Lab, University of Iowa
%Date Started: August 2020
%Last Updated: September 2020

%The function(s) in this script are used to identify peaks in ABR
%waveforms. Main focus is on wave I amplitude. 

%Notes: use xcorr to aid in identifying peaks - cross correlate each
%waveform with the waveform of the highest stimulus level.
%Use smoothing spline function (csaps) to fit growth function. (also need
%to talk to Steven and Ning about this.
%use gradient/diff function to aid in peak identification?
%something about hanning windows

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data, peaks, crosscorrs] = identifyPeaks(dataFile)
% function peaks = identifyPeaks(waveforms)
% waveforms - table where each column is waveform data from a single animal,
% each waveform is from different stimulus level. The variable name is the
% stimulus level.
% Do I want to have this call getABRdata? Probably.

% OR - input argument is the dataFile, then first step is to run getABRdata
% to read the data into Matlab.

%% Read the raw data into Matlab using getABRdata.m and get waveform data
data = getABRdata(dataFile);

waveforms = data.Waveforms;

peaks = table2array(waveforms);

%% calculate signal-to-noise ratio?
%SNR - calculate SEM of averages


%% perform cross-correlation of each waveform with the 90dB waveform using xcorr

%iterating through matrix, where c is column number
%matrix(:, c)

crosscorrs = [];
lags = [];
[rws, cls] = size(peaks);

for i = 1:cls
    [tempcorr, templag] = xcorr(peaks(:, i), peaks(:, 1));
    
    crosscorrs = [crosscorrs tempcorr];
    lags = [lags templag];

end

[maxcors, corridx] = max(crosscorrs);

corrdiffs = corridx - corridx(1);

%% get wave 1 amplitudes and latencies for plotting
%generate timepoints/time domain for plotting
sampRate = 24.4; %in kHz
n = numel(peaks(:,1));
t = 1:1:n;
t = t/sampRate;

%get wave 1 amplitudes and latencies
%specify timewindow
t1 = 1.4;
t2 = 1.7;
tol = 0.02;

%get indices of timewindow
idx1 = find(abs(t-t1)<tol);
idx2 = find(abs(t-t2)<tol);

%get amplitudes and latencies using cross correlations to shift time windows
ALarray = [];
for wf = 1:cls
    idx1 = idx1 + corrdiffs(wf);
    idx2 = idx2 + corrdiffs(wf);
    amp = max(peaks(idx1:idx2, wf));
    ampidx = find(~(peaks(:, wf)-amp));
    ALarray(wf,1) = amp;
    ALarray(wf,2) = ampidx;
    
end 
    
%% generate plots
peaks = peaks.*1000000;
figure(1)
for wv = 1:cls
    subplot(cls, 1, wv);
    plot(t, peaks(:, wv))
    hold on
    plot(t(ALarray(wv,2)), (ALarray(wv,1)*1000000), "ro")
    hold off
    ylab = ylabel(data.Waveforms.Properties.VariableNames(wv));
    set(get(gca,'YLabel'),'Rotation',0,'VerticalAlignment','middle')
    ylab.Position(1) = -1;
    if wv ~= cls
        set(gca, 'xticklabel', [])
    end
end
linkaxes
%legend(data.Waveforms.Properties.VariableNames)
xlabel("Latency (ms)")
%ylabel("Amplitude (µV)")
%title("Waveforms")

% figure(2)
% for wv = 1:cls
%     plot((lags(:,wv)/sampRate).*1000, crosscorrs(:, wv))
%     hold on
% end
% hold off
% legend(data.Waveforms.Properties.VariableNames)
% xlabel("Latency (ms)")
% ylabel("Amplitude (µV)")
% title("Cross-correlations")



