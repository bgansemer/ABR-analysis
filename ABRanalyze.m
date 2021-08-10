%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Benjamin Gansemer
%Affiliation: Green Lab, University of Iowa
%Date Started: July 2021
%Last Updated: July 2021

%This is the analyze ABR master script used to call other functions to 
%read in ABR data from txt files, process the data to get waveform info,
%and generate figures, if desired. 
%See each matlab file for details on individual functions.

%How to use:

%Development Notes:
%Make an interactive app that reads in the data and allows the user to
%change options/parameters to update plots in real time. 
%Add in more user options, such as color choice.
%Add option to automatically save wave I tables (as excel files)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ABRanalyze
%getOptions 
%   This function creates a ui panel to allow users to select
%   options/argumetns for running the ABR analysis package.
%   dataFiles:
%   generateFigs:
%   comparePlot:
%   figOpts:

%% Get screen size info for placing panels in the center
SS = get(0, 'screensize'); 
SW = SS(3); %Screen width in pixels
SH = SS(4); %Screen height in pixels
CW = round(SW/2)-150;
CH = round(SH/2)-175;

%% Generate panel to select options
%dataFiles = uigetdir();
opts = uifigure(Name='Analysis Options', Position=[CW CH 300 350],...
    HandleVisibility='on');
chkPan = uipanel(opts, Title='Checkbox options', FontSize=12,...
    Position=[20 190 250 150]);

figBox = uicheckbox(chkPan, Text='Generate Figures?', Value=1,...
    Position=[20 105 150 25]);
compBox = uicheckbox(chkPan, Text='Generate compare plot?',...
    Value=1, Position=[20 80 150 25]);
linkBox = uicheckbox(chkPan, Text='Link axes?', Value=0,...
    Position=[20 55 125 25]);
pointsBox = uicheckbox(chkPan, Text='Plot Wave I points?',...
    Value=1, Position=[20 30 150 25]);
legendBox = uicheckbox(chkPan, Text='Include Fig. legends?',...
    Value=1, Position=[20 5 150 25]);

beginField = uieditfield(opts, 'numeric', Limits=[0 12],...
    Value=0, Position=[110 150 75 25]);
beginLabel = uilabel(opts, Text='Begin timepoint:', Position=[20 150 100 25]);

endField = uieditfield(opts, 'numeric', Limits=[0 12],...
    Value=6, Position=[110 120 75 25]);
endLabel = uilabel(opts, Text='End timepoint:', Position=[20 120 100 25]);

% dirBtn = uibutton(opts, 'push', 'Text', 'Select file location',...
%     'Position', [75 50 150 25],...
%     'ButtonPushedFcn', @(dirBtn,event) getDir(dirBtn));

 startBtn = uibutton(opts, 'push', 'Text', 'Start analysis',...
     'Position', [100 50 100 25],...
     'ButtonPushedFcn', @(startBtn,event) startAnalysis(startBtn, figBox, ...
     compBox, linkBox, pointsBox, legendBox, beginField, endField));

% %% Get options from panel
% genFigs = figBox.Value;
% compPlot = compBox.Value;
% figOpts.linkax = linkBox.Value;
% figOpts.plotPoints = pointsBox.Value;
% figOpts.legend = legendBox.Value;
% figOpts.Tbegin = beginField.Value;
% figOpts.Tend = endField.Value;

end

function startAnalysis(startBtn, figBox, compBox, linkBox, pointsBox, ...
    legendBox, beginField, endField)
    dataFiles = uigetdir(Title='Select folder with files for analysis');
    %% Get options from panel
    genFigs = figBox.Value;
    compPlot = compBox.Value;
    figOpts.linkax = linkBox.Value;
    figOpts.plotPoints = pointsBox.Value;
    figOpts.legend = legendBox.Value;
    figOpts.Tbegin = beginField.Value;
    figOpts.Tend = endField.Value;
    
    close all;
    %% Run analyze ABR
    helperFunc(dataFiles, genFigs, compPlot, figOpts);
    
    
end

