%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Benjamin Gansemer
% Affiliation: Green Lab, University of Iowa
% Date Started: July 2020
% Last Updated: November 2021

% The function in this script is used to read 
% auditory brainstem response (ABR) data into Matlab.
% The code is written for data exported in ASCII format from BioSigRZ.
% Takes txt file as input and outputs a struct with all data from the txt
% file. Should contain animal info and table of all ABR traces where each
% waveform dataset is a single column.
% need to add functionality input list of files so you can display
% waveforms across frequencies for an animal

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function st = getABRdata(dataFile)
% dataFiles: filename for a txt file from BioSigRZ containing all records to be
% analyzed from one animal at one timepoint. 

%bigst = struct([]);

%for f = 1:length(dataFiles)
    %% get filename - contains subj ID and frequency
    %[~, fname] = fileparts(dataFiles{f});
    %fname = strrep(fname, '-', '_');
    %fname = strcat('r', fname);
    %% Read in raw data
    %generate name for the entry
    [~, fname] = fileparts(dataFile);
    fname = strrep(fname, '-', '_');
    %fname = convertCharsToStrings(fname);
    fname = strcat('r_', fname);
    
    %read in data
    abrFile = fopen(dataFile, 'r');
    rawData = textscan(abrFile, '%s', 'Delimiter', '\n');
    fclose(abrFile);

    %% Divide data into individual records (traces)
    % split group info into separate array
    if contains(rawData{1}{1}, 'ABR Group Header');
        groupInfo = rawData{1}(1:13);
        noGroup = rawData{1}(14:length(rawData{1}));    
        data{1} = noGroup;
    else
        data = rawData;
    end

    % write each record to an individual array
    %numRecords = length(grep(data{1}, 'Record Number')); % get number of traces
    recIdxs = find(contains(data{1}, 'Record Number'));
    for i = 1:length(recIdxs)
        %start = round((length(data{1})/numRecords)*(i-1)+1);
    %     if i == 1
    %         start = 1
    %     else
    %         start = 309*(i-1)+1
    %     end
        start = recIdxs(i);
        if length(find(contains(data{1}, 'Freq'))) == 0;
            fin = start + 306;
        else
            fin = start + 307;
        end


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

    %% Parse through all arrays and create a table with all waveform data

    % OLD this is for a labeledSignalSet
    %allTraces = labeledSignalSet; %generate empty signal set to put data into
    %allTraces.Description = 'All ABR traces';
    %allTraces.TimeInformation = 'sampleRate';
    %traceNames = {};

    % trying to generate a struct instead
    st = struct([]);
    
    st(1).Name = fname;

    if exist("groupInfo", 'var') == 1
        st(1).Info = groupInfo;
    else
        st(1).Info = "No group info";
    end

    freqCell = table2cell(combinedTable{1});

    %grep from https://www.mathworks.com/matlabcentral/fileexchange/9647-grep-a-pedestrian-very-fast-grep-utility
    frequency = grep(freqCell, 'Freq');
    if length(frequency) == 0;
        frq = 'click';
    else
        freq = textscan(frequency{1}, '%s', 'Delimiter', '=');
        frq = freq{1}{2};
    end
    st(1).Info{end+1} = frq;

    allWFs = cell2table({});

    for a = 1:length(combinedTable)
       tempTable = combinedTable{a}; %create temporary array to work with

       % split the data into info about the trace and the actual waveform data
       if convertCharsToStrings(frq) == "click"
           traceInfo = table2cell(tempTable(1:14, 'Var1'));
           traceData = tempTable(15:height(tempTable)-1, 'Var1');
       else
           traceInfo = table2cell(tempTable(1:16, 'Var1'));
           traceData = tempTable(17:height(tempTable)-1, 'Var1');
       end
       
       % get record number of the trace
       %recordCell = grep(traceInfo, 'Record');
       %record = textscan(recordCell{1}, '%s', 'Delimiter', ':');
       %rcd = record{1}{2};

       % get the dB level of the trace
       levelCell = grep(traceInfo, 'Level');
       level = textscan(levelCell{1}, '%s', 'Delimiter', '=');
       lvl = strrep(level{1}{2}, ' ', '-');

       % set name of trace based on record number and dB level
       %tName = strcat(rcd, '_', lvl);

       %change stim lvl varname if it is already present in the list
       %allows for duplicate stim lvls
       %c = ismember(allWFs.Properties.VariableNames, lvl)
       count = 1;
       while any(ismember(allWFs.Properties.VariableNames, lvl))
           count = count+1;
           spl = strsplit(lvl, 'B');
           lvl = strrep(lvl, spl{2}, '');
           lvl = strcat(lvl, num2str(count));
       end
%        if length(c) > 0
%             if any(c)
%                 lvl = strcat(lvl, '2')
%             end
%        end

       %traceData.Properties.VariableNames{'Var1'} = lvl;

       %traceNames = horzcat(traceNames, tName);
       traceTable = array2table(str2double(traceData.Var1));
       traceTable.Properties.VariableNames{'Var1'} = lvl;

       % OLD add data to allTraces
       %addMembers(allTraces, traceMat, [24.41e3]);

       % add data to allWFs table
       allWFs = [allWFs traceTable];
    %    fprintf(lvl)
    %    fprintf('\n')

    end

    %allTraces.setMemberNames(traceNames);
    st(1).Waveforms = allWFs;

    %bigst(end+1).(fname) = st;
%end
end
    

