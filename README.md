# ABRapp v1

This is a MATLAB app developed in AppDesigner for post-analysis of ABR waveform data to identify wave I peaks/amplitude and latency. It is currently designed to take as input data .txt files from BioSigRZ. It can handle files with or without group information. 

To run the app, after opening, click the 'Load Data' button, which will open a dialog to select a folder containing the text files for analysis. The file names should populate the 'Data sets loaded' list. To view one of the files, click on that file name in the list box. The table and graphs should then populate, along with the 'Data selected' box. 

Required MATLAB Add-ons:  
Statistics and Machine Learning Toolbox
Signal Processing Toolbox

All other scripts and files required for running the app should be present in this repository. The app should run properly if run directly from the `app` directory. The cloned repo may need to be added to the MATLAB path if file not found errors occur when trying to run.

There are two files retrieved from MATLAB file exchange that are required to run the app (both are present in this repo.  
legendUnq.m was retrieved from [legendUnq](https://www.mathworks.com/matlabcentral/fileexchange/67646-legendunq).  
grep.m was retrieved from [grep](https://www.mathworks.com/matlabcentral/fileexchange/9647-grep-a-pedestrian-very-fast-grep-utility).  

## Instructions for running

In development...

## Plots

### Overlay

Plots of waveforms for all stimulus levels for that run/file.

### Selected Wave

Plot of a waveform from a single stimulus level from that run/file. The waveform plotted can be changed with the 'Waveform plotted' option.

### WaveIamp and WaveIlat

Plots of Wave I amplitude or latency vs. stimulus level.

### Compare plot

In development...

#### Individual Waveforms

Plots of each waveform on its own separate axis to allow better visualization of waveforms across stimulus levels.

### Options

Begin timepoint
End timepoint
Plot points
