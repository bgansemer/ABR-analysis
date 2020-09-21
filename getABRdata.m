%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Benjamin Gansemer
% Affiliation: Green Lab, University of Iowa
% Date Started: July 2020
% Last Updated: August 2020

% The function in this script is used to read 
% auditory brainstem response (ABR) data into Matlab.
% The code is written for data exported in ASCII format from BioSigRZ.
% Takes txt file as input and outputs a struct with all data from the txt
% file. Should contain animal info and table of all ABR traces where each
% waveform dataset is a single column.
% Additional notes here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function st = getABRdata(dataFile)
% data file should be a txt file from BioSigRZ containing all records to be
% analyzed from one animal at one timepoint. 
%% Read in raw data and divide into individual records (traces)

abrFile = fopen(dataFile, 'r');
rawData = textscan(abrFile, '%s', 'Delimiter', '\n');
fclose(abrFile);

% split group info into separate array
if contains(rawData{1}{1}, 'ABR Group Header');
    groupInfo = rawData{1}(1:13);
    noGroup = rawData{1}(14:length(rawData{1}));    
    data{1} = noGroup;
else
    data = rawData;
end

% write each record to an individual array
numRecords = length(grep(data{1}, 'Record Number')); % get number of traces
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
    
    % generates nested array off all individual arrays
    combinedTable{i} = recordTable; 
    
end

%% Parse through all arrays and create a labeledSignalSet for Signal Analyzer
% need to rewrite to put the data into a matrix or table (not LSS)

% OLD this is for a labeledSignalSet
%allTraces = labeledSignalSet; %generate empty signal set to put data into
%allTraces.Description = 'All ABR traces';
%allTraces.TimeInformation = 'sampleRate';
%traceNames = {};

% trying to generate a struct instead
st = struct([]);
st(1).Info = groupInfo;

allWFs = cell2table({});

for a = 1:length(combinedTable)
   tempTable = combinedTable{a}; %create temporary array to work with
   
   % split the data into info about the trace and the actual waveform data
   traceInfo = table2cell(tempTable(1:16, 'Var1'));
   traceData = tempTable(17:height(tempTable)-1, 'Var1');
   
   % get record number of the trace
   %recordCell = grep(traceInfo, 'Record');
   %record = textscan(recordCell{1}, '%s', 'Delimiter', ':');
   %rcd = record{1}{2};
   
   % get the dB level of the trace
   levelCell = grep(traceInfo, 'Level');
   level = textscan(levelCell{1}, '%s', 'Delimiter', '=');
   lvl = strrep(level{1}{2}, ' ', '_');
   
   % set name of trace based on record number and dB level
   %tName = strcat(rcd, '_', lvl);
   
   count = 0;
   while contains(allWFs.Properties.VariableNames, lvl)
       count = count+1;
       strcount = num2str(count);
       lvl = strcat(lvl, strcount); 
   end
   
   %traceData.Properties.VariableNames{'Var1'} = lvl;
       
   %traceNames = horzcat(traceNames, tName);
   traceTable = array2table(str2double(traceData.Var1));
   traceTable.Properties.VariableNames{'Var1'} = lvl;
   
   % OLD add data to allTraces
   %addMembers(allTraces, traceMat, [24.41e3]);
    
   % add data to allWFs table
   allWFs = [allWFs traceTable];
   
   
end

%allTraces.setMemberNames(traceNames);
st(1).Waveforms = allWFs;


end
