%Benjamin Gansemer
%Green Lab, University of Iowa
%July 2020


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Script used to test parts of other scripts and functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function output = testerScript(dataFiles)
% Input argument is the dataFile, first step is to run getABRdata
% to read the data into Matlab.
% Want to figure out how to accept list of files (will need to edit
% getABRdata for this) so that all files for an animal (all frequencies)
% can be analyzed in one go.

%% Read the raw data into Matlab using getABRdata.m and get waveform data
output = struct([]);
for f = 1:length(dataFiles)
    
    [~, fname] = fileparts(dataFiles{f});
    fname = strrep(fname, '-', '_');
    fname = strcat('r', fname);
    
    data = getABRdata(dataFiles{f});

    if data.Info ~= "No group info"
        subjID = strrep(data.Info{find(contains(data.Info, 'Subject ID:'))}, ...
            'Subject ID: ', '');
    else
        subjID = "No ID";
    end
    
    output(1).(fname) = data;
end
end


%% test

for i=1:length(levs)
    l = levs{i}{1};
    