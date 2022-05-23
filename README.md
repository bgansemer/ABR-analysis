# ABRapp v1

This is a MATLAB app developed in AppDesigner for post-analysis of ABR waveform data to identify wave I peaks/amplitude and latency. It is currently designed to take as input data .txt files from BioSigRZ. It can handle files with or without group information. 

To run the app, after opening, click the 'Load Data' button, which will open a dialog to select a folder containing the text files for analysis. The file names should populate the 'Data sets loaded' list. To view one of the files, click on that file name in the list box. The table and graphs should then populate, along with the 'Data selected' box. 

### Plots

#### Overlay

Plots of waveforms for all stimulus levels for that run/file.

#### Selected Wave

Plot of a waveform from a single stimulus level from that run/file. The waveform plotted can be changed with the 'Waveform plotted' option.

#### WaveIamp and WaveIlat

Plots of Wave I amplitude or latency vs. stimulus level.

#### Compare plot

In development...

#### Individual Waveforms

Plots of each waveform on its own separate axis to allow better visualization of waveforms across stimulus levels.

### Options

Begin timepoint
End timepoint
Plot points
