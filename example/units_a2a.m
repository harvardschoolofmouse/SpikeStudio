% Channel id's are indices for ptr.SelectedChannels. Not actual channel id.

batchPlotList = {...
	% Depth 3.8
	'desmond20', 20201022, 2, 1;... % Big unit, flat, slow inhibition maybe?
	'desmond20', 20201022, 2, 2;... % Big unit, flat, no
	'desmond20', 20201022, 6, 1;... % Big unit, very late off, fast excitation
	'desmond20', 20201023, 1, 1;... % Small unit, off into late on, fast excitation
	'desmond20', 20201023, 2, 1;... % Small unit, flat, fast excitation
	'desmond20', 20201023, 4, 1;... % Big unit, late off, fast excitation
	'desmond20', 20201023, 4, 2;... % Big unit, 15Hz/flat, no effect
	'desmond20', 20201023, 7, 1;... % Big unit, off, fast excitation
	'desmond20', 20201026, 4, 1;... % Big unit, late off, fast excitation
	'desmond20', 20201026, 4, 2;... % Big unit, 15Hz/flat, no effect
	'desmond20', 20201026, 8, 1;... % Big unit, late off, fast excitation

	% Depth 4.12
	'desmond20', 20201109, 1, 1;... % Medium unit, on, fast excitation maybe?
	'desmond20', 20201109, 1, 2;... % Big unit, on, fast excitation into inhibition
	'desmond20', 20201109, 3, 1;... % Big unit, off into very late on, fast excitation
	'desmond20', 20201109, 4, 1;... % Big unit, early on, no effect maybe?
	'desmond20', 20201109, 4, 2;... % Small unit, early on, fast excitation
	'desmond20', 20201109, 5, 1;... % Big unit, early on, fast excitation
	'desmond20', 20201109, 5, 2;... % Small unit, very early on, fast excitation
	'desmond20', 20201109, 6, 1;... % Medium unit, early on, fast excitation into inhibition, source duplicate maybe?
	'desmond20', 20201109, 6, 2;... % Medium unit, early on, fast excitation
	'desmond20', 20201109, 7, 1;... % Big unit, on, fast excitation maybe?
	'desmond20', 20201109, 7, 2;... % Big unit, on, no effect maybe?
	'desmond20', 20201109, 8, 1;... % Small unit, on, fast excitation
	'desmond20', 20201109, 11, 1;... % Small unit, on, fast excitation into inhibition, duplicate maybe?
	'desmond20', 20201109, 12, 1;... % Medium unit, on, fast excitation into inhibition, duplicate maybe?
	'desmond20', 20201109, 12, 1;... % Small unit, on, fast excitation
	'desmond20', 20201109, 13, 1;... % Medium unit, on, fast excitation
	'desmond20', 20201109, 15, 1;... % Medium unit, on, fast excitation
	'desmond20', 20201109, 15, 2;... % Small unit, on, fast excitation into inhibition, duplicate maybe?

	% Depth 4.28
	'desmond20', 20201116, 3, 1;... % Big unit, on, no effect maybe?
	'desmond20', 20201116, 5, 1;... % Medium unit, flat into very late off, excitation
	'desmond20', 20201116, 8, 1;... % Small unit, on, excitation
	'desmond20', 20201116, 9, 1;... % Big unit, on into late off, excitation
	'desmond20', 20201116, 10, 1;... % Small unit, on, excitation
	'desmond20', 20201116, 10, 1;... % Small unit, on, excitation
	'desmond20', 20201118, 2, 1;... % Big unit, off, excitation
	'desmond20', 20201118, 4, 1;... % Big unit, on, slow inhibition maybe?, source duplicate maybe?
	'desmond20', 20201118, 4, 2;... % Big unit, late off, excitation, source duplicate maybe?
	'desmond20', 20201118, 5, 1;... % Big unit, on, slow inhibition maybe?, duplicate maybe?
	'desmond20', 20201118, 5, 2;... % Big unit, late off, excitation, duplicate maybe?
	'desmond20', 20201118, 8, 1;... % Big unit, very late on, slow inhibition

	% Depth 4.44
	'desmond20', 20201201, 2, 1;... % Big unit, on, excitation
	'desmond20', 20201201, 4, 1;... % Big unit, on, excitation
	'desmond20', 20201201, 5, 1;... % Big unit, on, excitation
	'desmond20', 20201201, 5, 2;... % Big unit, on, excitation
	'desmond20', 20201201, 7, 1;... % Big unit, off, no effect
	'desmond20', 20201201, 8, 1;... % Big unit, on, excitation

	% Depth 4.52
	'desmond20', 20201202, 2, 1;... % Big unit, on, excitation
	'desmond20', 20201202, 3, 1;... % Big unit, on, excitation
	'desmond20', 20201202, 4, 1;... % Big unit, on, excitation maybe?
	'desmond20', 20201202, 4, 2;... % Big unit, on into off, excitation
	'desmond20', 20201202, 5, 2;... % Medium unit, on, excitation maybe?
	'desmond20', 20201202, 7, 1;... % Medium unit, on late, no effect
	'desmond20', 20201202, 8, 1;... % Big unit, on late, excitation
	'desmond20', 20201202, 8, 1;... % Big unit, on, no effect
	'desmond20', 20201202, 8, 2;... % Small unit, on, excitation
	'desmond20', 20201202, 9, 1;... % Small unit, on, excitation
	'desmond20', 20201202, 9, 2;... % Medium unit, on, excitation
	'desmond20', 20201202, 10, 1;... % Medium unit, on, excitation
	'desmond20', 20201202, 11, 2;... % Small unit, on into off, excitation
};

batchPlotList = {...
	% Daisy 7
	'daisy7', 20201204, 5, 1;... % Small unit, on, no effect
	'daisy7', 20201204, 7, 1;... % Small unit, on, no effect
	'daisy7', 20201204, 8, 1;... % Very small unit, on, no effect
	'daisy7', 20201204, 9, 1;... % Big unit, on, excitation maybe
	'daisy7', 20201204, 11, 1;... % Small unit, on, no effect


	'daisy7', 20201221, 2, 1;... % Big unit, on, no effect
	'daisy7', 20201221, 2, 2;... % Small unit, on, no effect
	'daisy7', 20201221, 3, 1;... % Small unit, on, no effect
	'daisy7', 20201221, 4, 1;... % Small unit, on, no effect
	'daisy7', 20201221, 5, 1;... % Small unit, on, no effect

	'daisy7', 20210104, 1, 1;... % Small unit, on, excitation
	'daisy7', 20210104, 4, 1;... % Big unit, on, no effect
	'daisy7', 20210104, 5, 1;... % Small unit, on, excitation
	'daisy7', 20210104, 6, 1;... % Big unit, on, no effect

% DA at this depth
	'daisy7', 20210106, 2, 1;... % Medium unit, on, inhibition? Due to missing spikes from sorting?
	'daisy7', 20210106, 3, 1;... % Big unit, flat, no effect
	'daisy7', 20210106, 4, 1;... % Big unit, up, very slow excitation maybe?
	'daisy7', 20210106, 6, 1;... % Big unit, up, no effect
	'daisy7', 20210106, 7, 1;... % Small unit, up, no effect
	'daisy7', 20210106, 11, 1;... % Small unit, up, excitation maybe
	'daisy7', 20210106, 14, 1;... % Small unit, up, excitation maybe


	'daisy7', 20210115, 1, 1;... % Big unit, on, excitation
	'daisy7', 20210115, 2, 1;... % Big unit, on, excitation
	'daisy7', 20210115, 3, 1;... % Very big unit, on, excitation
	'daisy7', 20210115, 4, 1;... % Very big unit, on, excitation
	'daisy7', 20210115, 5, 1;... % Big unit, on, excitation
	'daisy7', 20210115, 6, 1;... % Big unit, off, excitation maybe?
	'daisy7', 20210115, 6, 2;... % Big unit, on, excitation
	'daisy7', 20210115, 8, 1;... % Big unit, on, no effect
	'daisy7', 20210115, 9, 1;... % Big unit, on, excitation
	'daisy7', 20210115, 10, 1;... % Small unit, on, excitation
	'daisy7', 20210115, 11, 1;... % Smal unit, on, no effect
	'daisy7', 20210115, 11, 2;... % Big unit, on, no effect
	'daisy7', 20210115, 13, 1;... % Big unit, on, excitation, suspect duplicate

	'daisy7', 20210121, 2, 1;... % Small unit, on, excitation
	'daisy7', 20210121, 2, 2;... % Small unit, on, excitation
	'daisy7', 20210121, 3, 1;... % Big unit, on, excitation
	'daisy7', 20210121, 4, 1;... % Big unit, on, excitation maybe?
	'daisy7', 20210121, 6, 1;... % Big unit, on, inhibition
	'daisy7', 20210121, 7, 1;... % Big unit, off, excitation
	'daisy7', 20210121, 8, 1;... % Big unit, flat, no effect

	'daisy7', 20210202, 1, 1;... % Small unit, up, no effect
	'daisy7', 20210202, 3, 1;... % Big unit, up, inhibition
	'daisy7', 20210202, 4, 1;... % Big unit, up, excitation
	'daisy7', 20210202, 5, 1;... % Big unit, flat, inhibition
	'daisy7', 20210202, 6, 1;... % Big unit, up, no effect
	'daisy7', 20210202, 7, 1;... % Small unit, up, inhibition maybe
	'daisy7', 20210202, 9, 1;... % Big unit, up, excitation
	'daisy7', 20210202, 10, 1;... % Big unit, up, excitation
	'daisy7', 20210202, 11, 1;... % Small unit, up, inhibition
	'daisy7', 20210202, 12, 1;... % Big unit, up, no effect


	'daisy7', 20210203, 2, 1;... % Big unit, up, no effect
	'daisy7', 20210203, 3, 1;... % Big unit, up, no effect
	'daisy7', 20210203, 7, 1;... % Big unit, down, inhibition
	'daisy7', 20210203, 7, 2;... % Small unit, flat, no effect
	'daisy7', 20210203, 7, 3;... % Big unit, up, excitation
	'daisy7', 20210203, 9, 1;... % Big unit, up, no effect
	'daisy7', 20210203, 9, 2;... % Big unit, up, excitation
	'daisy7', 20210203, 10, 1;... % Big unit, up, no effect
	'daisy7', 20210203, 12, 1;... % Big unit, flat, slow inhibition
	'daisy7', 20210203, 13, 1;... % Big unit, up, excitation
	'daisy7', 20210203, 15, 1;... % Big unit, up, no effect
	'daisy7', 20210203, 16, 1;... % Small unit, up, inhibition
	'daisy7', 20210203, 17, 1;... % Big unit, up, no effect
	};

% 
sessions = {...
	'desmond20', 20201022;...
	'desmond20', 20201023;...
	'desmond20', 20201026;...
	'desmond20', 20201027;... % All short trials

};

needsManualSorting = {...
	'desmond20', 20201116, 2;...
	'desmond20', 20201116, 8;...
	'desmond20', 20201116, 10;...
	'desmond20', 20201118, 7;...
	'desmond20', 20201201, 4;..

	'daisy7', 20201204, 12;... 
	'daisy7', 20201221, 1;... 


};

% Generate PETH data struct
expNames = cell(length(batchPlotList), 1);
for iExp = 1:length(batchPlotList)
	expNames{iExp} = [batchPlotList{iExp, 1}, '_', num2str(batchPlotList{iExp, 2})];
end

expNamesUnique = unique(expNames);

for iTr = 1:length(expNamesUnique)
	tr = TetrodeRecording.BatchLoad(expNamesUnique(iTr));
	try
		if iTr == 1;
			PETH = TetrodeRecording.BatchPETHistCounts(tr, batchPlotList, 'TrialLength', 6, 'ExtendedWindow', 1, 'SpikeRateWindow', 100, 'ExtendedWindowStim', [-1, 1], 'SpikeRateWindowStim', 10, 'Press', true, 'Lick', false, 'Stim', true);
		else
			PETH = [PETH, TetrodeRecording.BatchPETHistCounts(tr, batchPlotList, 'TrialLength', 6, 'ExtendedWindow', 1, 'SpikeRateWindow', 100, 'ExtendedWindowStim', [-1, 1], 'SpikeRateWindowStim', 10, 'Press', true, 'Lick', false, 'Stim', true)];
		end
	catch ME
		warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
		warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
	end
end

% Plot heatmap
I = TetrodeRecording.HeatMapStimSimple(PETH, 'Window', [-6, 0], 'NormalizationBaselineWindow', [-6, 0], 'WindowStim', [-0.25, 0.75], 'NormalizationBaselineWindowStim', [-1, 0], 'CLimStim', [-3,3], 'Sorting', 'latency');

% Single plots
for iTr = 1:length(expNamesUnique)
	tr = TetrodeRecording.BatchLoad(expNamesUnique(iTr));
	try
		TetrodeRecording.BatchPlot(tr, batchPlotList, 'PlotStim', true, 'Reformat', 'Raw');
	catch ME
		warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
		warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
	end
end





for iTr = 1:length(expNamesUnique)
	tr = TetrodeRecording.BatchLoad(expNamesUnique(iTr));
	try
		TetrodeRecording.BatchPlotSimple(tr, batchPlotList)
	catch ME
		warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
		warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
	end
end


% Sorted stim PETH
for i = 1:length(PETH)
	sel = PETH(i).Stim.Timestamps <= 0.2;
	peth(i, 1:sum(sel)) = PETH(i).Stim.SpikeRate(sel);
	t = PETH(i).Stim.Timestamps(sel);
end
clear i sel

[pethSorted, Istim, whenDidFiringRateChange] =  TetrodeRecording.SortPETH(peth, 'Method', 'latency', 'LatencyThreshold', 0.675);
pethSortedNorm = TetrodeRecording.NormalizePETH(pethSorted, 'Method', 'zscore', 'BaselineSamples', t < 0);


figure()
axes()
hold on
for i = 1:size(pethSortedNorm, 1)
	sel = t >= -0.2;
	isDec = any(pethSortedNorm(i, t>=0 & t < 0.03) < -2);
	if ~isDec
		plot(t(sel), pethSortedNorm(i, sel), 'color', [.2, .8, .2, 0.5])
	else
		plot(t(sel), pethSortedNorm(i, sel), 'color', [.8, .2, .2, 0.5])
	end
end
plot([0, 0.02], [55, 55], 'b', 'LineWidth', 3)
hold off
title("A2A-ChR2 stim response of 60 SNr units")
xlabel("Time (s)")
ylabel("Spike rate (z-score)")



image(pethSortedNorm, 'CDataMapping', 'scaled')
caxis([-6,6])
colormap('jet')


