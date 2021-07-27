%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Benjamin Gansemer
%Affiliation: Green Lab, University of Iowa
%Date Started: July 2021
%Last Updated: Juy 2021

%This is the analyze ABR master script used to call other functions to 
%read in ABR data from txt files, process the data to get waveform info,
%and generate figures, if desired. 
%See each matlab file for details on individual functions. 

%How to use:


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function [bigst] = analyzeABR(dataFiles, figs, linkax, plotPoints, compareFig)
function [bigst] = analyzeABR(dataFiles, figs, comparePlot, figOpts)
% dataFiles: char of a directory name or filename
% figs: logical/boolean, if true figures will be generated
% linkax: logical/boolean, if true, y axes will be linked on figure 1
% plotPoints: logical/boolean, if true, markers of the identified wave I
% peak and trough will be plotted on each waveform

%% Check arguments

arguments
    dataFiles;

    figs(1,1) logical = 1;
    
    comparePlot(1,1) logical = 0;

    figOpts.linkax(1,1) logical = 0;

    figOpts.plotPoints(1,1) logical = 1;
    
    figOpts.Tbegin(1,1) {mustBeNumeric} = 0;
    
    figOpts.Tend(1,1) {mustBeNumeric} = 6;
    
    figOpts.legend(1,1) logical = 1;
end

%% get dataFile information using getFileNames.m
%need to figure out how to catch errors
if class(dataFiles) == 'char'
    dataFiles = getFileNames(dataFiles);
else
    error('Error. File input must be a char, not a %s.', ...
        class(dataFiles))
end

%% Run identify peaks to get waveform data
%[bigst, waveforms, t] = identifyPeaks(dataFiles);
[bigst] = identifyPeaks(dataFiles);

%% Generate figures if figs == true
if figs == true
    generateFigs(bigst, figOpts);
end

if comparePlot == true
    compareFig(bigst, figOpts);
end