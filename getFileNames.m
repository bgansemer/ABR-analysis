%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Benjamin Gansemer
%Affiliation: Green Lab, University of Iowa
%Date Started: October 2020
%Last Updated: July 2021

% This script contains a function to quickly get a list of file names from
% a folder

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fullNames = getFileNames(directory)

if endsWith(directory, '.txt');
     files = dir([directory]);
     names = {files.name};
     folders = {files.folder};
     fullNames = strcat(folders, {'\'}, names);
else
    files = dir([directory, '\*.txt']);
    names = {files.name};
    folders = {files.folder};
    fullNames = strcat(folders, {'\'}, names);
end
end