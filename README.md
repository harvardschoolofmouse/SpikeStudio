# SpikeStudio
Spike sorting visualization, processing and analysis tools

> Created: Allison Hamilos with contributions from Lingfeng Hou<br>
> Modified 7/28/2023<br>
> Version 0.1.3 -- for use with Intan | SpikeInterface Curated Datasets (Kilosort2.5, IronClust; Phy). 
> NB: Version 0.1.4 forthcoming @AH Needs upload from Dropbox

-------------------------
## Getting started:

- Download or open Matlab 2023a + 
- Clone SpikeStudio repo and add to your path.     
    - NB: you may also need dependencies from HSOManalysisPackages. If something doesn't work, let me know.

You will also need to add the following toolboxes using the Add-Ons manager:

- cprintf 1.14
- Curve Fitting Toolbox 3.8
- Image Processing Toolbox 11.6
- Mapping Toolbox 5.4
- Signal Processing Toolbox
- Statistics and Machine Learning Textbox 12.4

--------------------------
## Automated SpikeSorting

- Record behavioral session with Intan as *.rhd file. Works best as 1 min chunks.
- Create probe channel map (example in dependencies)
- Currently configured to take output from SpikeInterface using Omkar-Sort or SpikeSorter ('*.csv')
- Complete automated sorting using SpikeInterface using Omkar-Sort or SpikeSorter and export *.csv

---------------------------
## Analyzing a behavioral session with SpikeStudio

### Initial sorting and curation:
0. Sort, curate and export spike data as .csv file from Omkar-Sort

### Behavioral analysis:
1. Put Spike2.mat file and text file with exclusions (exclusions_null.txt) into a runner folder. SignalName is the same name as in Spike2. Each session should have a folder and thes can be processed in a batch:
    Analysis_Folder/SignalName/MOUSENAME_SignalName_dayNo

2. From matlab, run one of the following, depending on your experiment:

        % General:
        sObj = CLASS_photometry_roadmapv1_4('v3x','times',17,{'none',[]},30000,[],[],'off’);

        % Using only optogenetically stimulated trials:
        sObj = CLASS_photometry_roadmapv1_4('v3x','times',17,{'none',[]},30000,[],[],'stim’);

        % Using only optogenetically un-stimulated trials:
        sObj = CLASS_photometry_roadmapv1_4('v3x','times',17,{'none',[]},30000,[],[],'nostim’);

        % To include accelerometer signals:
        sObj = CLASS_photometry_roadmapv1_4('v3x','times',17,{'X',[]},30000,[],[],'off’);

        % To include photometry signals:
        sObj = CLASS_photometry_roadmapv1_4('v3x','times',17,{'multibaseline',10},30000,[],[],'off’);

4. Select SignalName from dropdown that matches your runner folder name. The behavioral files will be pre-processed.

5. Open the single-session folder (Analysis_Folder/SignalName/MOUSENAME_SignalName_dayNo) and load the pre-processed STIMNPHOT object into your workspace

        % e.g.,
        single_sesh_obj = load('~/Analysis/Lazarus_X_20/STIMNPHOT_Lazarus_X_day20_snpObj_Modetimes_1bins_nm1Condoff_07_13_23__ 8_22_PM.mat')

6. Create an ESP object. This automatically begins a cascade that loads in your spike data. Currently, this is configured for Intan or Blackrock recordings and works best if ephys files are saved in 1 min chunks

        [obj,tr,ss] = EphysStimPhot(single_sesh_obj, [], true);
        % be sure to select all Intan files for the session STARTING FROM FILE #1
        % the obj, tr and ss objects should all be saved to your working directory. Verify this. If not, use obj.save(ss, tr) to save all before proceeding.

### Working with analysis objects:

        obj: Class ESP object, which is specific to the self-timed movement task (Hamilos et al., 2021). This allows us to visualize and analyze behavior data, photometry/movement control data, optogenetics data and spike data from the same datastructure. 
        obj.SpikeSorterData:     contains all spike times, channels and units from Omkar-Sort or SpikeSorter
        obj.iv:                   initial variables, like mouse name, session, and file paths
        obj.GLM:                contains all behavior and non-spike data (times of events, timeseries of photometry, etc)
        obj.ts:                a dynamic field that has timeseries data pooled by movement time (spike, photometry, or otherwise). Is updated by calls to obj.getBinnedTimeseries or obj.getBinnedPETH

        Other fields are rarely used

        ss: Class SpikeStudio, a general spike analysis suite, which holds onto waveform data and interacts with TetrodeRecording
        tr: Class TetrodeRecording, a legacy object that handles import of Intan and Blackrock data, primarily for extracting behavioral events on the timebase of the spike data

### Visualizing units relative to timing behavior
The following code will plot waveforms, spike rasters, and PETHs relative to behavioral events. It will automatically save these as .fig (Matlab figure) and .eps files (for Adobe Illustrator/Publication):

        % obj.plotUnitSummary(UnitNo, Mode, seconds_before_event_to_plot, seconds_after_event_to_plot, 0.05, ss, trials_to_include, ignoreMerged);
        %    Modes: 'cue' -- cue triggered average, trials plotted in order they occurred in session
        %            'lick' -- lick triggered ave, licks plotted in order they occurred
        %            'flick' -- first-lick triggered ave, trials plotted in order they occurred in session
        %            'lamp off' -- lamp off triggered ave, as above
        %            'clta' -- cue and lick triggered ave, as above
        %            'cta2l' -- cue triggered ave, trials plotted in order of first-time
        %            'lta2l' -- cue triggered ave, trials plotted in order of first-lick time
        %
        %
        obj.plotUnitSummary(151, 'lta2l', 7, 3, 0.05, ss, 1:numel(obj.Intan.flick_s_wrtc), true);

    
   



---------------------------
## LEGACY: Creating a stand-alone SpikeStudio session

    >> obj = SpikeSorter;
    
- Select all the *.rhd files you wish to load. 

    <i> Pro-tip: make sure the files are sorted by time recorded (i.e., filename). Otherwise, files won't load in properly</i>
    
    <i> Pro-tip2: you don't have to load all your files. You can also preview just the first few.</i>
- Select the processed SpikeSorter .csv file
