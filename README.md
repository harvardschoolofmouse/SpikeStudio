# SpikeStudio
Spike sorting visualization, processing and analysis tools

    Created: Allison Hamilos with contributions from Lingfeng Hou<br>
    Modified 4/18/2023<br>
    Version 0.1.2

-------------------------
## Getting started:

- Download or open Matlab 2023a + 
- Clone SpikeStudio repo and add to your path. 
    - Note, you may also need dependencies from HSOManalysisPackages. If something doesn't work, let us know.

You will also need to add the following toolboxes using the Add-Ons manager:

- cprintf 1.14
- Mapping Toolbox 5.4
- Signal Processing Toolbox
- Statistics and Machine Learning Textbox 12.4
- Curve Fitting Toolbox 3.8
- Image Processing Toolbox 11.6

--------------------------
## Automated SpikeSorting

- Record behavioral session with Intan as *.rhd file. Works best as 1 min chunks.
- Create probe channel map (example in dependencies)
- Currently configured to take output from SpikeSorter ('*.csv')
- Complete automated sorting using SpikeSorter and export *.csv

---------------------------
## Creating a SpikeStudio session

    >> obj = SpikeSorter;
    
- Select all the *.rhd files you wish to load. 

    <i> Pro-tip: make sure the files are sorted by time recorded (i.e., filename). Otherwise, files won't load in properly</i>
    
    <i> Pro-tip2: you don't have to load all your files. You can also preview just the first few.</i>
- Select the processed SpikeSorter .csv file
