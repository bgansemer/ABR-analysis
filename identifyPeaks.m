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
[rws, cls] = size(peaks);

for i = 1:cls
    tempcorr = xcorr(peaks(:, i), peaks(:, 1));
    
    crosscorrs = [crosscorrs tempcorr];

end