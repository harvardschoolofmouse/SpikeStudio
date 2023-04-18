expNames = {...
	'daisy8_20210616';... % 3.80
	'daisy8_20210617';... % 3.80
	'daisy8_20210623';... % 3.96
	'daisy8_20210625';... % 4.04 6.64mW
	'daisy8_20210630';... % 4.12 3mW
	'daisy8_20210702';... % 4.20 3mW
	'daisy8_20210706';... % 4.28 3mW
	'daisy8_20210707';... % 4.36 7mW
	'daisy8_20210708';... % 4.44 7mW
	'daisy8_20210709';... % 4.44 10mW
	'daisy8_20210713';... % 4.52 10mW


	'desmond22_20210617';... % 3.96 9.6mW
	'desmond22_20210621';... % 3.96 9.6mW
	'desmond22_20210624';... % 4.04 9.6mW
	'desmond22_20210628';... % 4.04 3mW
	'desmond22_20210630';... % 4.12 3mW
	'desmond22_20210701';... % 4.20 3mW
	'desmond22_20210702';... % 4.28 3mW
	'desmond22_20210706';... % 4.36 3mW
	'desmond22_20210707';... % 4.44 6mW
	'desmond22_20210708';... % 4.52 6mW
	'desmond22_20210709';... % 5.00 10mW
};

% Batchplot based on date/channel, and paste to clipboard
% Ref/noise cluster is last cluster
batchPlotListStim = {...
	'desmond22', 20210617, 1, 1;... % off
	'desmond22', 20210617, 3, 1;... % on maybe
	'desmond22', 20210617, 3, 2;... % slow on
	'desmond22', 20210617, 5, 1;... % slow on
	'desmond22', 20210621, 3, 1;... % flat
	'desmond22', 20210624, 1, 1;... % flat
	'desmond22', 20210624, 2, 1;... % flat
	'desmond22', 20210624, 3, 1;... % fast off the on
	'desmond22', 20210624, 4, 1;... % flat
	'desmond22', 20210624, 5, 1;... % flat
	% 'desmond22', 20210624, 5, 2;... % DA, slow on
	'desmond22', 20210624, 6, 1;... % flat
	'desmond22', 20210624, 7, 1;... % flat
	% 'desmond22', 20210624, 7, 2;... % DA flat
	'desmond22', 20210624, 8, 1;... % flat
	'desmond22', 20210624, 9, 1;... % fast off slow on
	'desmond22', 20210624, 9, 2;... % flat
	% 'desmond22', 20210630, 1, 1;... % DA flat
	'desmond22', 20210630, 3, 1;... % flat
	'desmond22', 20210630, 4, 1;... % slow off
	'desmond22', 20210630, 5, 1;... % slow off
	'desmond22', 20210630, 5, 2;... % flat
	'desmond22', 20210630, 6, 1;... % slow off
	'desmond22', 20210630, 7, 1;... % flat
	'desmond22', 20210630, 8, 1;... % flat
	'desmond22', 20210630, 8, 2;... % slow off
	'desmond22', 20210630, 10, 1;... % slow off
	'desmond22', 20210702, 2, 1;... % flat
	'desmond22', 20210702, 2, 2;... % flat
	'desmond22', 20210702, 3, 1;... % flat
	'desmond22', 20210702, 4, 1;... % flat
	'desmond22', 20210702, 5, 1;... % flat
	'desmond22', 20210702, 6, 2;... % slow up
	'desmond22', 20210702, 8, 1;... % flat
	'desmond22', 20210702, 9, 1;... % flat
	'desmond22', 20210702, 10, 2;... % slow up
	'desmond22', 20210702, 11, 1;... % flat
	'desmond22', 20210706, 1, 1;... % flat
	'desmond22', 20210706, 2, 1;... % flat
	'desmond22', 20210706, 3, 2;... % flat
	'desmond22', 20210706, 4, 1;... % flat
	'desmond22', 20210706, 5, 1;... % flat
	'desmond22', 20210706, 6, 1;... % flat
	'desmond22', 20210706, 7, 1;... % flat
	'desmond22', 20210706, 11, 2;... % fast off and slow on
	'desmond22', 20210707, 1, 1;... % flat
	'desmond22', 20210707, 1, 2;... % Slow on 
	'desmond22', 20210707, 2, 1;... % flat
	'desmond22', 20210707, 3, 1;... % off and slow on
	'desmond22', 20210707, 4, 1;... % flat
	'desmond22', 20210707, 5, 1;... % flat
	'desmond22', 20210707, 9, 1;... % flat
	'desmond22', 20210707, 12, 1;... % flat
	% 'desmond22', 20210707, 12, 1;... % DA slow on
	'desmond22', 20210707, 12, 2;... % flat
	'desmond22', 20210707, 14, 1;... % flat
	'desmond22', 20210707, 15, 1;... % flat
	'desmond22', 20210709, 4, 1;... % slow on
	'desmond22', 20210709, 4, 2;... % flat
	'desmond22', 20210709, 5, 1;... % flat
	'desmond22', 20210709, 6, 1;... % flat
	'desmond22', 20210709, 8, 1;... % slow up
	'desmond22', 20210709, 8, 2;... % slow up
	'desmond22', 20210709, 9, 1;... % flat
	'desmond22', 20210709, 12, 1;... % flat
	'desmond22', 20210709, 18, 1;... % flat
	'desmond22', 20210709, 21, 1;... % flat
	'desmond22', 20210709, 21, 2;... % flat


	'daisy8', 20210617, 2, 1;... % Up, stim flat maybe?
	'daisy8', 20210617, 2, 2;... % Up, stim flat maybe?
	'daisy8', 20210617, 3, 1;... % Up, stim flat maybe?
	'daisy8', 20210617, 4, 1;... % Up, stim up 50ms delay
	'daisy8', 20210617, 5, 1;... % Down, stim slow down maybe?
	'daisy8', 20210617, 7, 1;... % Up then down, stim slow up
	'daisy8', 20210617, 8, 1;... % Up, stim slow up
	'daisy8', 20210617, 10, 1;... % Up, stim slow up
	'daisy8', 20210617, 10, 2;... % Up, stim flat
	'daisy8', 20210617, 12, 1;... % Up, stim flat
	'daisy8', 20210617, 13, 1;... % Up, stim slow up
	'daisy8', 20210617, 14, 1;... % Up then down, stim slow up
	'daisy8', 20210618, 2, 1;... % Flat, stim flat
	'daisy8', 20210618, 3, 1;... % Up, stim flat
	'daisy8', 20210618, 6, 1;... % Up, stim slow up
	'daisy8', 20210623, 1, 1;... %
	'daisy8', 20210623, 2, 1;... % TODO Maybe Disentangle with next unit
	'daisy8', 20210623, 2, 2;... % TODO Maybe Disentangle with prev unit
	'daisy8', 20210623, 3, 1;... % TODO Maybe Disentangle with next unit
	'daisy8', 20210623, 3, 2;... % TODO Maybe Disentangle with prev unit
	'daisy8', 20210623, 4, 1;... %
	% 'daisy8', 20210623, 4, 2;... % DA
	'daisy8', 20210623, 5, 1;... %
	'daisy8', 20210623, 5, 2;... %
	'daisy8', 20210623, 6, 1;... %
	% 'daisy8', 20210625, 1, 1;... % DA inhibited by ChR2
	'daisy8', 20210625, 2, 1;... % Fast excitation
	'daisy8', 20210625, 4, 1;... % SNr opto off
	'daisy8', 20210625, 5, 1;... % SNr fast on
	'daisy8', 20210625, 7, 1;... % 
	'daisy8', 20210625, 8, 1;... % flat
	'daisy8', 20210630, 1, 1;... % slow on
	'daisy8', 20210630, 2, 1;... % fast off and then on at opto offset
	'daisy8', 20210630, 3, 1;... % slow off, lick cell?
	'daisy8', 20210630, 4, 1;... % slow on
	'daisy8', 20210630, 5, 1;... % slow on
	'daisy8', 20210630, 6, 1;... % slow on
	'daisy8', 20210702, 1, 1;... % flat
	'daisy8', 20210702, 1, 2;... % slow on
	'daisy8', 20210702, 2, 1;... % FAST on
	'daisy8', 20210702, 5, 1;... % flat
	'daisy8', 20210702, 7, 1;... % slow on
	'daisy8', 20210702, 8, 1;... % fast off slow on
	'daisy8', 20210702, 8, 2;... % fast off 25ms on
	'daisy8', 20210702, 9, 1;... % flat
	'daisy8', 20210702, 12, 1;... % slow off?
	'daisy8', 20210702, 13, 1;... % slow off?
	'daisy8', 20210702, 16, 1;... % flat
	'daisy8', 20210702, 16, 2;... % flat
	'daisy8', 20210702, 17, 1;... % fast on
	'daisy8', 20210702, 18, 1;... % flat
	'daisy8', 20210702, 18, 2;... % flat
	'daisy8', 20210706, 1, 1;... % on
	'daisy8', 20210706, 2, 1;... % fast on
	'daisy8', 20210706, 3, 1;... % fast on
	'daisy8', 20210706, 5, 1;... % slow on
	'daisy8', 20210706, 6, 1;... % flat
	'daisy8', 20210706, 7, 1;... % slow on
	'daisy8', 20210706, 9, 1;... % slow on
	'daisy8', 20210706, 11, 1;... % fast off
	'daisy8', 20210706, 12, 1;... % flat
	'daisy8', 20210706, 13, 1;... % fast on
	'daisy8', 20210706, 14, 1;... % fast on
	'daisy8', 20210706, 14, 2;... % flat
	'daisy8', 20210706, 15, 1;... % flat
	'daisy8', 20210706, 15, 2;... % flat
	'daisy8', 20210707, 1, 1;... % flat
	'daisy8', 20210707, 1, 2;... % flat
	'daisy8', 20210707, 2, 1;... % fast on
	'daisy8', 20210707, 3, 1;... % flat
	'daisy8', 20210707, 4, 1;... % flat
	'daisy8', 20210707, 4, 2;... % flat
	'daisy8', 20210707, 5, 1;... % flat
	'daisy8', 20210707, 7, 1;... % flat
	% 'daisy8', 20210707, 9, 1;... % DA slow off
	'daisy8', 20210707, 11, 1;... % flat
	'daisy8', 20210707, 12, 1;... % flat
	'daisy8', 20210707, 13, 1;... % flat
	'daisy8', 20210708, 1, 1;... % flat
	'daisy8', 20210708, 4, 1;... % on
	'daisy8', 20210708, 6, 1;... % fast on
	'daisy8', 20210708, 7, 1;... % slow off?
	'daisy8', 20210708, 8, 1;... % flat
	'daisy8', 20210708, 8, 2;... % slow on
	'daisy8', 20210708, 9, 1;... % slow on
	'daisy8', 20210708, 10, 1;... % flat
	'daisy8', 20210708, 11, 1;... % slow on
	'daisy8', 20210708, 11, 2;... % slow on
	'daisy8', 20210708, 13, 1;... % flat
	'daisy8', 20210708, 15, 1;... % fast off
	'daisy8', 20210708, 16, 1;... % flat
	'daisy8', 20210708, 17, 1;... % slow on
	'daisy8', 20210708, 18, 1;... % flat
	'daisy8', 20210708, 19, 1;... % flat
	'daisy8', 20210708, 19, 2;... % flat
	'daisy8', 20210708, 21, 1;... % slow on
	'daisy8', 20210709, 3, 1;... % fast off, slow on then, then slow off then slow on
	'daisy8', 20210709, 6, 1;... % fast on
	'daisy8', 20210709, 6, 2;... % flat
	'daisy8', 20210709, 7, 1;... % flat
	'daisy8', 20210709, 9, 1;... % flat
	'daisy8', 20210709, 10, 1;... % slow on
	% 'daisy8', 20210709, 12, 1;... % DA fast off
	'daisy8', 20210709, 16, 1;... % flat
	'daisy8', 20210709, 17, 1;... % slow on


	};

expNames = cell(size(batchPlotListStim, 1), 1);
for iExp = 1:size(batchPlotListStim, 1)
	expNames{iExp} = [batchPlotListStim{iExp, 1}, '_', num2str(batchPlotListStim{iExp, 2})];
end

expNamesUnique = unique(expNames);


% Single plots stim
for iTr = 1:length(expNamesUnique)
	tr = TetrodeRecording.BatchLoad(expNamesUnique(iTr));
	tr.ReadDigitalEvents();
	try
		TetrodeRecording.BatchPlot(tr, batchPlotListStim, 'PlotStim', true, 'Reformat', 'Raw');
		TetrodeRecording.BatchPlotSimple(tr, batchPlotListStim);
	catch ME
		warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
		warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
	end
end

% Single plots, lick vs press
for iTr = 1:length(expNamesUnique)
	tr = TetrodeRecording.BatchLoad(expNamesUnique(iTr));
	tr.ReadDigitalEvents();
	try
		TetrodeRecording.BatchPlot(tr, batchPlotListStim, 'RasterXLim', [-5, 2], 'ExtendedWindow', [-1, 2], 'PlotStim', false, 'PlotLick', true, 'Reformat', 'DualRasterAndWaveform');
	catch ME
		warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
		warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
	end
end


% Make PETH struct
for iTr = 1:length(expNamesUnique)
	tr = TetrodeRecording.BatchLoad(expNamesUnique(iTr));
	tr.ReadDigitalEvents();
	try
		if iTr == 1;
			PETH = TetrodeRecording.BatchPETHistCounts(tr, batchPlotListStim, 'TrialLength', 6, 'ExtendedWindow', 1, 'SpikeRateWindow', 100, 'ExtendedWindowStim', [-1, 1], 'SpikeRateWindowStim', 10, 'Press', true, 'Lick', true, 'Stim', true);
		else
			PETH = [PETH, TetrodeRecording.BatchPETHistCounts(tr, batchPlotListStim, 'TrialLength', 6, 'ExtendedWindow', 1, 'SpikeRateWindow', 100, 'ExtendedWindowStim', [-1, 1], 'SpikeRateWindowStim', 10, 'Press', true, 'Lick', true, 'Stim', true)];
		end
	catch ME
		warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
		warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
	end
end

PETHStim = PETHStim_D1Triple;

clear pethStim
% Sorted stim PETHStim
for i = 1:length(PETHStim)
	Stim = PETHStim(i).Stim;
	sel = Stim(1).Timestamps <= 0.2;
	t = Stim(1).Timestamps(sel);
	thisPeth = zeros(1, sum(sel));
	for j = 1:length(Stim)
		thisPeth = thisPeth + Stim(j).SpikeRate(sel) * Stim(j).NumTrains;
	end
	pethStim(i, 1:length(t)) = thisPeth ./ sum([Stim.NumTrains]);
end
clear i sel Stim
%%
[pethSorted, Istim, whenDidFiringRateChange] =  TetrodeRecording.SortPETH(pethStim, 'Method', 'latency', 'LatencyThreshold', 0.675);
pethSortedNorm = TetrodeRecording.NormalizePETH(pethSorted, 'Method', 'zscore', 'BaselineSamples', t < 0);

% Heatmap
TetrodeRecording.HeatMap(PETH, 'Normalization', 'zscore', 'Sorting', 'latency', 'MinNumTrials', 75, 'MinSpikeRate', 15, 'Window', [-4, 1], 'NormalizationBaselineWindow', [-4, -2], 'Lick', true, 'UseSameSorting', true);


figure()
axes()
hold on
for i = 1:size(pethSortedNorm, 1)
	sel = t >= -0.2;
	isDec = any(pethSortedNorm(i, t>0 & t <= 0.025) < -2.5);
    isInc = any(pethSortedNorm(i, t>0 & t <= 0.025) > 2.5);
	if isDec
		h = plot(t(sel)*1000, pethSortedNorm(i, sel), 'color', [.2, .8, .2, 0.67]);
    elseif isInc
		h = plot(t(sel)*1000, pethSortedNorm(i, sel), 'color', [.8, .2, .2, 0.67]);
    else
		h = plot(t(sel)*1000, pethSortedNorm(i, sel), 'color', [.2, .2, .2, 0.67]);
    end
    h.DisplayName = num2str(i);
end
plot([0, 100], [0, 0], 'b', 'LineWidth', 3)
hold off
title(char(sprintf("Drd1-ChR2 stim response of %d SNr units", size(pethStim, 1))))
xlabel("Time (ms)")
ylabel("Spike rate (z-score)")
xlim([-100, 100])

figure()
axes()
hold on
for i = 1:size(pethSortedNorm, 1)
	sel = t >= -0.2;
	isDec = any(pethSortedNorm(i, t>0 & t <= 0.025) < -2.5);
    isInc = any(pethSortedNorm(i, t>0 & t <= 0.025) > 2.5);
	if isDec
		h = plot(t(sel)*1000, pethSorted(i, sel), 'color', [.2, .8, .2, 0.67]);
    elseif isInc
		h = plot(t(sel)*1000, pethSorted(i, sel), 'color', [.8, .2, .2, 0.67]);
    else
		h = plot(t(sel)*1000, pethSorted(i, sel), 'color', [.2, .2, .2, 0.67]);
    end
    h.DisplayName = num2str(i);
end
plot([0, 25], [0, 0], 'b', 'LineWidth', 3)
hold off
title(char(sprintf("Drd1-ChR2 stim response of %d SNr units", size(pethStim, 1))))
xlabel("Time (ms)")
ylabel("Spike rate (z-score)")
xlim([-100, 25])
