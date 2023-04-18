%% Select files
files = uipickfiles('Prompt', 'Select .mat files containing TetrodeRecording objects to load...', 'Type', {'*.mat', 'MAT-files'});

%% Generate batchPlotList and PETH from file (SLOW)
batchPlotList = {};

for iTr = 1:length(files)
% 	try
		disp(['Loading file: ', files{iTr}, '...'])
		S = load(files{iTr}, 'tr');
		tr = S.tr;

		expName = tr.GetExpName();
		animalName = strsplit(expName, '_');
		date = str2num(animalName{2});
		animalName = animalName{1};

		channels = [tr.Spikes.Channel];
		thisBatchPlotList = {};
		for iChn = channels
			for iUnit = 1:max(tr.Spikes(iChn).Cluster.Classes) - 1
				thisBatchPlotList = vertcat(thisBatchPlotList, {animalName, date, iChn, iChn, iUnit});
			end
		end
		batchPlotList = vertcat(batchPlotList, thisBatchPlotList);

        % Cull low ISI
        TetrodeRecording.BatchCullLowISI(tr, thisBatchPlotList, 0.5)
		
        % Plot lick vs press raster
        TetrodeRecording.BatchPlot(tr, thisBatchPlotList, 'RasterXLim', [-6, 1], 'ExtendedWindow', [-1, 1], 'PlotStim', false, 'PlotLick', true, 'Reformat', 'DualRasterAndWaveform');
        
        % Calculate PETH
        thisPETH = TetrodeRecording.BatchPETHistCounts(tr, thisBatchPlotList, 'TrialLength', 6, 'ExtendedWindow', 1, 'SpikeRateWindow', 100, 'Press', true, 'Lick', true, 'Stim', false);
		if iTr == 1
			PETH = thisPETH;
		else
			PETH = [PETH, thisPETH];
		end

		clear S expName animalName date iChn thisPETH thisBatchPlotList channels tr iTr iUnit
% 	catch ME
% 		warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
% 		warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
% 	end
end

%%
save('C:\SERVER\PETH_WT_4shank_acute.mat');

%%
load('C:\SERVER\PETH_WT_4shank_acute.mat')
scatter_press_vs_lick(PETH, 'Daisy12/13 Press vs Lick (Pre-move)', 2, [-2, 0], true)
scatter_press_vs_lick(PETH, 'Daisy12/13 Press vs Lick (Post-move)', 2, [0, 0.5], true)

%% Daisy12 only
scatter_press_vs_lick(PETH(contains({PETH.ExpName}, 'daisy12')), 'Daisy12 Press vs Lick (Pre-move)', 2, [-2, 0], true)
scatter_press_vs_lick(PETH(contains({PETH.ExpName}, 'daisy12')), 'Daisy12 Press vs Lick (Post-move)', 2, [0, 0.5], true)

%% Daisy13 only
scatter_press_vs_lick(PETH(contains({PETH.ExpName}, 'daisy13')), 'Daisy13 Press vs Lick (Pre-move)', 2, [-2, 0], true)
scatter_press_vs_lick(PETH(contains({PETH.ExpName}, 'daisy13')), 'Daisy13 Press vs Lick (Post-move)', 2, [0, 0.5], true)

%% Pre-move
scatter_press_vs_lick(PETH_9, 'Press vs Lick vs Location (Daisy9)', 1, [-2, 0], true)
scatter_press_vs_lick(PETH_10, 'Press vs Lick vs Location (Daisy10)', 1, [-2, 0], true)
scatter_press_vs_lick(PETH_12, 'Press vs Lick vs Location (Daisy12)', 1, [-2, 0], true)
scatter_press_vs_lick(PETH_13, 'Press vs Lick vs Location (Daisy13)', 1, [-2, 0], true)

%% Peri-move
scatter_press_vs_lick(PETH_9, 'Press vs Lick vs Location (Daisy9)', 1, [-2, 1], true)
scatter_press_vs_lick(PETH_10, 'Press vs Lick vs Location (Daisy10)', 1, [-2, 1], true)
scatter_press_vs_lick(PETH_12, 'Press vs Lick vs Location (Daisy12)', 1, [-2, 1], true)
scatter_press_vs_lick(PETH_13, 'Press vs Lick vs Location (Daisy13)', 1, [-2, 1], true)
scatter_press_vs_lick(PETH_Selected_4shank, 'Press vs Lick vs Location (Daisy13)', 1, [-2, 1], true)
