%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Benjamin Gansemer
%Affiliation: Green Lab, University of Iowa
%Date Started: October 2020
%Last Updated: October 2020

% This script contains a function to quickly get a list of file names from
% a folder

% get list of files in directory: 
%   files = dir([directory '\*.txt']);
%   names = {files.name};
%   folders = {files.folder};
%   fullNames = strcat(folders, {'\'}, names);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fullNames = getFileNames(directory)

files = dir([directory, '\*.txt']);
names = {files.name};
folders = {files.folder};
fullNames = strcat(folders, {'\'}, names);
end