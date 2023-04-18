% Batchplot based on date/channel, and paste to clipboard
% Ref/noise cluster is last cluster
% TODO: Because channel number is actual channel (1-32), this is different from before
% AnimalName, Date, ElectrodeID, ReadElectrodeID, ClusterID, % Move effect (Up/Down/Flat), Stim effect (On/Off/None)
batchPlotListStim = {...
	%% Daisy9 reversed omnetics connection

	% Lick only (naive)
	'daisy9', 20211001, 7, 1, 1;... % Down, On
	'daisy9', 20211001, 14, 3, 1;... % Up, On
	'daisy9', 20211001, 20, 5, 1;... % Down, None
	'daisy9', 20211001, 30, 10, 1;... % Down, None

	% Lick and press
	'daisy9', 20211012, 7, 1, 1;... % Down, OffOn
	'daisy9', 20211012, 14, 4, 1;... % Up, Off
	'daisy9', 20211012, 30, 10, 1;... % Down, None

	'daisy9', 20211013, 7, 1, 1;... % Down, OffOn
	'daisy9', 20211013, 14, 3, 1;... % Up, Off
	'daisy9', 20211013, 23, 7, 1;... % Up, None
	'daisy9', 20211013, 30, 11, 1;... % Down, None

	'daisy9', 20211014, 7, 1, 1;... % Down, OffOn
	'daisy9', 20211014, 10, 2, 1;... % Up, Off
	'daisy9', 20211014, 14, 3, 1;... % Down, Off
	'daisy9', 20211014, 20, 5, 1;... % Down, None
	'daisy9', 20211014, 23, 7, 1;... % Up, None

	'daisy9', 20211027, 4, 1, 1;... % Flat, Off
	'daisy9', 20211027, 5, 2, 1;... % Down, Off
	'daisy9', 20211027, 7, 4, 1;... % Flat, None
	'daisy9', 20211027, 14, 5, 1;... % Flat, None
	'daisy9', 20211027, 20, 6, 1;... % Up, None

	% Lever-only
	% Drifty-session, split at trial 80
	'daisy9', 20211028, 4, 1, 1;... % Up, Off, after trial 80
	'daisy9', 20211028, 5, 2, 1;... % Down, Off, after trial 80
	'daisy9', 20211028, 7, 4, 1;... % Up, On, before trial 80
	'daisy9', 20211028, 10, 5, 1;... % Up, On, after trial 80
	'daisy9', 20211028, 14, 6, 1;... % Up, Up, after trial 80
	'daisy9', 20211028, 20, 7, 1;... % Up, None

	%
	'daisy9', 20211029, 6, 2, 1;... % Up, None
	'daisy9', 20211029, 7, 3, 1;... % Up, On
	'daisy9', 20211029, 14, 4, 1;... % Flat, None
	'daisy9', 20211029, 23, 5, 1;... % Up, None
	'daisy9', 20211029, 30, 6, 1;... % Up, None

	'daisy9', 20211102, 7, 2, 1;... % Flat, None
	'daisy9', 20211102, 26, 5, 1;... % Up, None

	% Lick only
	'daisy9', 20211103, 5, 1, 1;... % Flat, Off
	'daisy9', 20211103, 7, 3, 1;... % Up, On
	'daisy9', 20211103, 10, 4, 1;... % Up, Off
	'daisy9', 20211103, 14, 5, 1;... % Down, Off
	'daisy9', 20211103, 20, 6, 1;... % Flat, None
	'daisy9', 20211103, 23, 7, 1;... % Up, None
	'daisy9', 20211103, 30, 11, 1;... % Up, None

	'daisy9', 20211104, 6, 1, 1;... % Up, None
	'daisy9', 20211104, 7, 2, 1;... % Up, On
	'daisy9', 20211104, 7, 2, 2;... % Down, Off
	'daisy9', 20211104, 10, 3, 1;... % Up, Off
	'daisy9', 20211104, 12, 4, 1;... % Up, Off
	'daisy9', 20211104, 14, 5, 1;... % Down, Off
	'daisy9', 20211104, 16, 6, 1;... % Up, On
	'daisy9', 20211104, 30, 9, 1;... % Up, None

	'daisy9', 20211108, 7, 2, 1;... % Up, On
	'daisy9', 20211108, 10, 3, 1;... % Up, Off
	'daisy9', 20211108, 12, 4, 1;... % Down, Off
	'daisy9', 20211108, 14, 5, 1;... % Up, None
	'daisy9', 20211108, 16, 6, 1;... % Up, On
	'daisy9', 20211108, 23, 8, 1;... % Up, None
	'daisy9', 20211108, 26, 9, 1;... % Up, None
	'daisy9', 20211108, 30, 10, 1;... % Up, None

	%% Daisy10
	% Lick only (naive, day 3)
	'daisy10', 20211014, 1, 1, 1;... % Up, None
	'daisy10', 20211014, 1, 1, 2;... % Up, None
	'daisy10', 20211014, 3, 2, 1;... % Down, None
	'daisy10', 20211014, 9, 5, 1;... % Up, Off
	'daisy10', 20211014, 13, 7, 1;... % Up, None
	'daisy10', 20211014, 26, 11, 1;... % Up, None
	'daisy10', 20211014, 28, 12, 1;... % Down, Off

	% Lever+Lick
	'daisy10', 20211020, 1, 1, 1;... % Flat, None
	'daisy10', 20211020, 6, 2, 1;... % Up, Up
	'daisy10', 20211020, 7, 3, 1;... % Flat, Up
	'daisy10', 20211020, 8, 4, 1;... % Flat, Down
	'daisy10', 20211020, 9, 5, 1;... % Down, Off
	'daisy10', 20211020, 9, 5, 2;... % Up, Off
	'daisy10', 20211020, 13, 6, 1;... % Up, None
	'daisy10', 20211020, 17, 7, 1;... % Up, None
	'daisy10', 20211020, 18, 8, 1;... % Up, On
	'daisy10', 20211020, 19, 9, 1;... % Up, On
	'daisy10', 20211020, 21, 10, 1;... % Up, Off
	'daisy10', 20211020, 27, 12, 1;... % Up, None, bursty

	% Lever only
	'daisy10', 20211102, 6, 1, 1;... % Up, None
	'daisy10', 20211102, 7, 2, 1;... % Up, None
	'daisy10', 20211102, 13, 5, 1;... % Up, None
	'daisy10', 20211102, 28, 6, 1;... % Up, None
	'daisy10', 20211102, 29, 7, 1;... % Down, None

	% Press Only
	% 'daisy10', 20211108, 6, 2, 1;... % Up, Up, DA???
	'daisy10', 20211108, 6, 2, 1;... % Up, Up
	'daisy10', 20211108, 13, 4, 1;... % Down, None
};


expNames = cell(size(batchPlotListStim, 1), 1);
for iExp = 1:size(batchPlotListStim, 1)
	expNames{iExp} = [batchPlotListStim{iExp, 1}, '_', num2str(batchPlotListStim{iExp, 2})];
end

expNamesUnique = unique(expNames);


% Cull low ISI
% for iTr = 1:length(expNamesUnique)
% 	tr = TetrodeRecording.BatchLoad(expNamesUnique(iTr));
% 	try
% 		TetrodeRecording.BatchCullLowISI(tr, batchPlotListStim, 0.5)
% 		TetrodeRecording.BatchSave(tr, 'Prefix', 'tr_sorted_culled_')
% 	catch ME
% 		warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
% 		warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
% 	end
% end

% Single plots stim vs Press/Lick
% for iTr = 1:length(expNamesUnique)
% 	tr = TetrodeRecording.BatchLoad(expNamesUnique(iTr));
% 	try
% 		TetrodeRecording.BatchPlotSimple(tr, batchPlotListStim, 'Event', 'PressOn', 'Exclude', 'LickOn', 'RasterXLim', [-6, 1]);
% 	end
% 	try
% 		TetrodeRecording.BatchPlotSimple(tr, batchPlotListStim, 'Event', 'LickOn', 'Exclude', 'PressOn', 'RasterXLim', [-6, 1]);
% 	end
% 	try
% 		TetrodeRecording.BatchPlot(tr, batchPlotListStim, 'RasterXLim', [-6, 1], 'ExtendedWindow', [-1, 1], 'PlotStim', false, 'PlotLick', true, 'Reformat', 'DualRasterAndWaveform');
% 	end
% end

% Make PETH struct and plot
for iTr = 1:length(expNamesUnique)
	% Load
	tr = TetrodeRecording.BatchLoad(expNamesUnique(iTr));

	% Plots
	% try
	% 	TetrodeRecording.BatchPlotSimple(tr, batchPlotListStim, 'Event', 'PressOn', 'Exclude', 'LickOn', 'RasterXLim', [-6, 1]);
	% catch ME
	% 	warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
	% 	warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
	% end
	% try
	% 	TetrodeRecording.BatchPlotSimple(tr, batchPlotListStim, 'Event', 'LickOn', 'Exclude', 'PressOn', 'RasterXLim', [-6, 1]);
	% catch ME
	% 	warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
	% 	warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
	% end
	% try
	% 	TetrodeRecording.BatchPlot(tr, batchPlotListStim, 'RasterXLim', [-6, 1], 'ExtendedWindow', [-1, 1], 'PlotStim', false, 'PlotLick', true, 'Reformat', 'DualRasterAndWaveform');
	% catch ME
	% 	warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
	% 	warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
	% end
	% close all

	% Make PETH
	try
		if iTr == 1;
			PETH = TetrodeRecording.BatchPETHistCounts(tr, batchPlotListStim, 'TrialLength', 6, 'ExtendedWindow', 1, 'SpikeRateWindow', 100, 'ExtendedWindowStim', [-.5, .5], 'SpikeRateWindowStim', 10, 'Press', true, 'Lick', true, 'Stim', true);
		else
			PETH = [PETH, TetrodeRecording.BatchPETHistCounts(tr, batchPlotListStim, 'TrialLength', 6, 'ExtendedWindow', 1, 'SpikeRateWindow', 100, 'ExtendedWindowStim', [-.5, .5], 'SpikeRateWindowStim', 10, 'Press', true, 'Lick', true, 'Stim', true)];
		end
	catch ME
		warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
		warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
	end
end

load('C:\SERVER\PETH_TripleCross_4shank.mat')
%%

[~, ~, I] = TetrodeRecording.HeatMap(PETH, 'Normalization', 'zscore', 'Sorting', 'latency', 'MinNumTrials', 40, 'MinSpikeRate', 15, 'Window', [-4, 0], 'NormalizationBaselineWindow', [-4, -2], 'LatencyThreshold', 0.75);
PETH = PETH(sort(I));
% Separate Lick-only vs Press-only vs PressAndLick
PETH_PressAndLick = [PETH([PETH.NumTrialsPress] > 0 & [PETH.NumTrialsLick] > 0)];
PETH_PressOnly = [PETH([PETH.NumTrialsPress] > 0 & [PETH.NumTrialsLick] == 0)];
PETH_LickOnly = [PETH([PETH.NumTrialsPress] == 0 & [PETH.NumTrialsLick] > 0)];
PETH_Press = [PETH([PETH.NumTrialsPress] > 0)];
PETH_Lick = [PETH([PETH.NumTrialsLick] > 0)];

% ScatterPlot, move vs stim
plot_stim_response(PETH, 'Daisy9/10 dSPN', 2, 0.025, [], [-0.1, 0.2], 1025)
scatter_stim_vs_press(PETH_Press, 'dSPN-stim vs. Press', 2, 1025, [-1, 0], [0, 0.02], true)
scatter_stim_vs_lick(PETH_Lick, 'dSPN-stim vs. Lick', 2, 1025, [-1, 0], [0, 0.02], true)
scatter_press_vs_lick(PETH_PressAndLick, 'Daisy9/10 Press vs Lick', 2, [-2, 0], true)
scatter_press_vs_lick(PETH_PressAndLick, 'Daisy9/10 Press vs Lick', 2, [-0, 0.5], true)

