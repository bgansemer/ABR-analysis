%Benjamin Gansemer
%Green Lab, University of Iowa
%July 2020

%This script is used to analyze auditory brainstem response (ABR) data.
%The code is written for data exported in ASCII format from BioSigRZ.
%Main goal is to analyze wave I amplitude and latency
%Additional function to determine threshold?
%Uses Signal Analyzer app
%Additional notes here


%% clear environment
clear all; clc

%% Read in raw data and divide into individual records (traces)

abrFile = fopen('8k-full-test.txt', 'r'); %need to figure out args
%abrFile = fopen('8k-full-test.txt', 'r');
rawData = textscan(abrFile, '%s', 'Delimiter', '\n');
fclose(abrFile);

%split group info into separate array
if contains(rawData{1}{1}, 'ABR Group Header');
    groupInfo = rawData{1}(1:13);
    noGroup = rawData{1}(14:length(rawData{1}));    
    data{1} = noGroup;
else
    data = rawData;
end

%write each record to an individual array
numRecords = length(grep(data{1}, 'Record Number')); %get number of traces
for i = 1:numRecords
    start = (length(data{1})/numRecords)*(i-1)+1;
    fin = start + 308;
    recordTable = cell2table(data{1}(start:fin));
%     for j = 1:308;
%         newstart = start + (j-1);
%             recordArray = vertcat(recordArray, ' ');
%         else
%             recordArray = vertcat(recordArray, data{1}{newstart});
%         end
%    end
    
    %generates nested array off all individual arrays
    combinedTable{i} = recordTable; 
    
end

%% Parse through all arrays and create a labeledSignalSet for Signal Analyzer

allTraces = labeledSignalSet; %generate empty signal set to put data into
allTraces.Description = 'All ABR traces';
allTraces.TimeInformation = 'sampleRate';
traceNames = {};

for a = 1:length(combinedTable)
   tempTable = combinedTable{a}; %create temporary array to work with
   
   %split the data into info about the trace and the actual waveform data
   traceInfo = table2cell(tempTable(1:16, 'Var1'));
   traceData = tempTable(17:height(tempTable)-1, 'Var1');
   
   %get record number of the trace
   recordCell = grep(traceInfo, 'Record');
   record = textscan(recordCell{1}, '%s', 'Delimiter', ':');
   rcd = record{1}{2};
   
   %get the dB level of the trace
   levelCell = grep(traceInfo, 'Level');
   level = textscan(levelCell{1}, '%s', 'Delimiter', '=');
   lvl = strrep(level{1}{2}, ' ', '_');
   
   tName = strcat(rcd, '_', lvl);
   
   traceNames = horzcat(traceNames, tName);
   traceMat = str2double(traceData.Var1);
   
   %add data to allTraces
   addMembers(allTraces, traceMat, [24.41e3]);

   
end

allTraces.setMemberNames(traceNames);


