PETHStim = PETHStimD1;
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


figure()
axes()
hold on
for i = 1:size(pethSortedNorm, 1)
	sel = t >= -0.2;
	isDec = any(pethSortedNorm(i, t>=0 & t < 0.03) < -2);
    isInc = any(pethSortedNorm(i, t>=0 & t < 0.03) > 2);
	if isDec
		plot(t(sel)*1000, pethSortedNorm(i, sel), 'color', [.2, .8, .2, 0.67])
    elseif isInc
		plot(t(sel)*1000, pethSortedNorm(i, sel), 'color', [.8, .2, .2, 0.67])
    else
		plot(t(sel)*1000, pethSortedNorm(i, sel), 'color', [.2, .2, .2, 0.67])
    end
end
plot([0, 100], [55, 55], 'b', 'LineWidth', 3)
hold off
title(char(sprintf("Drd1-ChR2 stim response of %d SNr units", size(pethStim, 1))))
xlabel("Time (ms)")
ylabel("Spike rate (z-score)")
xlim([-100, 100])

%% Contingency table
% Normalize rates
pethStimNorm = TetrodeRecording.NormalizePETH(pethStim, 'Method', 'zscore', 'BaselineSamples', t < 0);


tPress = PETHStim(1).Time;
pethPress = transpose(reshape([PETHStim.Press], [length(tPress), length(PETHStim)]));
pethPressNorm = TetrodeRecording.NormalizePETH(pethPress, 'Method', 'zscore', 'BaselineSamples', tPress < -2 & tPress > -4);

% Find isDec/isInc
for i = 1:length(PETHStim)
	PETHStim(i).IsDecStim = any(pethStimNorm(i, t>=0 & t <= 0.02) < -2);
	PETHStim(i).IsIncStim = any(pethStimNorm(i, t>=0 & t <= 0.02) > 2);
	PETHStim(i).IsDecPress = any(pethPressNorm(i, tPress>=-2 & tPress <= 0) < -4);
	PETHStim(i).IsIncPress = any(pethPressNorm(i, tPress>=-2 & tPress <= 0) > 4);
end


sum([PETHStim.IsDecPress])
sum([PETHStim.IsIncPress])

sum([PETHStim.IsDecStim])
sum([PETHStim.IsIncStim])

contTable = zeros(3);
contTable(1, 1) = sum([PETHStim.IsDecPress] & [PETHStim.IsDecStim]);
contTable(1, 2) = sum([PETHStim.IsDecPress] & [PETHStim.IsIncStim]);
contTable(1, 3) = sum([PETHStim.IsDecPress] & ~([PETHStim.IsDecStim] | [PETHStim.IsIncStim]));
contTable(2, 1) = sum([PETHStim.IsIncPress] & [PETHStim.IsDecStim]);
contTable(2, 2) = sum([PETHStim.IsIncPress] & [PETHStim.IsIncStim]);
contTable(2, 3) = sum([PETHStim.IsIncPress] & ~([PETHStim.IsDecStim] | [PETHStim.IsIncStim]));
contTable(3, 1) = sum(~([PETHStim.IsDecPress] | [PETHStim.IsIncPress]) & [PETHStim.IsDecStim]);
contTable(3, 2) = sum(~([PETHStim.IsDecPress] | [PETHStim.IsIncPress]) & [PETHStim.IsIncStim]);
contTable(3, 3) = sum(~([PETHStim.IsDecPress] | [PETHStim.IsIncPress]) & ~([PETHStim.IsDecStim] | [PETHStim.IsIncStim]));





% Desmond 21

batchPlotListStim = {...
	% 'desmond21', 20210406, 2, 1;... % Up, stim flat
	% 'desmond21', 20210406, 4, 1;... % Down, stim flat
	% 'desmond21', 20210406, 5, 1;... % Down maybe, stim flat
	% 'desmond21', 20210406, 6, 1;... % Up, stim flat
	% % 'desmond21', 20210406, 7, 1;... % DA
	% 'desmond21', 20210406, 9, 1;... % Up, stim flat
	% 'desmond21', 20210407, 1, 1;... % Up, stim flat
	% 'desmond21', 20210407, 2, 1;... % Down, stim flat
	% 'desmond21', 20210407, 6, 1;... % Up, stim flat
	% 'desmond21', 20210407, 7, 1;... % Up, stim flat
	% 'desmond21', 20210407, 8, 1;... % Up, stim flat
	% 'desmond21', 20210407, 9, 1;... % DA

	% 'desmond21', 20210408, 2, 1;... % Down, stim flat
	% 'desmond21', 20210408, 7, 1;... % Up, stim flat
	% 'desmond21', 20210409, 1, 1;... % Up, stim flat
	% 'desmond21', 20210409, 2, 1;... % Down, stim off maybe?
	% 'desmond21', 20210409, 5, 1;... % Up, stim flat
	% 'desmond21', 20210411, 1, 1;... % Up, stim flat
	% 'desmond21', 20210411, 3, 1;... % Up, stim flat
	% 'desmond21', 20210411, 5, 1;... % Up, stim flat

	% 'desmond21', 20210415, 1, 1;... % Up, stim flat
	% 'desmond21', 20210415, 2, 1;... % Up, stim flat
	% 'desmond21', 20210415, 4, 1;... % DA, Down, stim flat
	% 'desmond21', 20210415, 5, 1;... % DA, Up, stim flat

	% 'desmond21', 20210416, 5, 1;... % Down, stim flat
	% 'desmond21', 20210416, 5, 2;... % Up, stim flat
	% 'desmond21', 20210416, 7, 1;... % Down, stim flat
	% 'desmond21', 20210416, 10, 1;... % DA, Up, stim flat
	% 'desmond21', 20210416, 12, 1;... % Down, stim flat

	% Long stim
	'desmond21', 20210419, 3, 1;... % Up, stim flat
	'desmond21', 20210419, 4, 1;... % Up, stim flat
	'desmond21', 20210419, 4, 2;... % Up, stim on or slow off maybe?
	'desmond21', 20210419, 10, 1;... % Up, stim off
	'desmond21', 20210419, 11, 1;... % Up, stim flat

	'desmond21', 20210422, 2, 1;... % Up, stim on
	'desmond21', 20210422, 3, 1;... % Up, stim flat
	'desmond21', 20210422, 10, 1;... % Up, stim flat
	'desmond21', 20210422, 12, 1;... % Up, stim delayed off

	'desmond21', 20210427, 2, 1;... % Up, stim flat
	'desmond21', 20210427, 3, 1;... % Up, stim on
	'desmond21', 20210427, 5, 1;... % Down, stim on
	
	'desmond21', 20210429, 1, 1;... % Down, stim flat
	'desmond21', 20210429, 1, 2;... % Down, stim flat
	'desmond21', 20210429, 2, 1;... % Up, stim on
	'desmond21', 20210429, 2, 2;... % Up, stim on
	'desmond21', 20210429, 3, 1;... % Up, stim off
	'desmond21', 20210429, 3, 2;... % Up, stim on then delayed on
	'desmond21', 20210429, 4, 1;... % Up, stim flat then delayed off then delayed on
	'desmond21', 20210429, 5, 1;... % Up, stim on then delayed off
	'desmond21', 20210429, 9, 1;... % Up, stim off then delayed on
	'desmond21', 20210429, 11, 1;... % Up, stim on then delayed off then delayed on

	'desmond21', 20210430, 4, 1;... % Up, stim on
	'desmond21', 20210430, 11, 1;... % Up, stim delayed on
	'desmond21', 20210430, 12, 1;... % Up, stim off then delayed on
	'desmond21', 20210430, 12, 2;... % Up, stim on then delayed on
	'desmond21', 20210430, 14, 1;... % Up, stim on then delayed on
	'desmond21', 20210503, 2, 1;... % Up, stim on
	'desmond21', 20210503, 8, 1;... % Up, stim flat
	'desmond21', 20210503, 9, 1;... % Up, stim off
	'desmond21', 20210503, 14, 1;... % Up, stim on htne delayed on

	'desmond21', 20210506, 2, 1;... % Up, stim delayed on
	'desmond21', 20210506, 3, 1;... % Flat, stim off
	'desmond21', 20210506, 3, 2;... % Up, stim on
	'desmond21', 20210506, 4, 1;... % On, stim delayed off
	'desmond21', 20210506, 6, 1;... % Off, stim flat
	'desmond21', 20210506, 8, 1;... % Off, stim on
	'desmond21', 20210506, 10, 1;... % Flat, stim flat
	'desmond21', 20210506, 12, 1;... % On, stim on then delayed on

	'desmond21', 20210507, 3, 1;... % Flat, stim off
	'desmond21', 20210507, 3, 2;... % On, stim on
	'desmond21', 20210507, 7, 1;... % On, stim delayed off
	'desmond21', 20210507, 8, 1;... % Flat, stim flat
	'desmond21', 20210507, 10, 1;... % Off, stim delayed off
	'desmond21', 20210507, 12, 1;... % On, stim delayed off
	'desmond21', 20210507, 13, 1;... % On, stim flat
	'desmond21', 20210507, 14, 1;... % On, stim delayed off
	'desmond21', 20210507, 15, 1;... % On, stim delayed on

	'desmond21', 20210510, 3, 1;... % On, stim on
	'desmond21', 20210510, 5, 1;... % Flat, stim delayed off
	'desmond21', 20210510, 7, 1;... % On, stim off?
	'desmond21', 20210510, 8, 1;... % Off, stim on
	'desmond21', 20210510, 9, 1;... % On, stim off then delayed on
	'desmond21', 20210510, 10, 1;... % Off, stim delayed off
	'desmond21', 20210510, 11, 1;... % On, stim flat
	'desmond21', 20210510, 12, 1;... % On, stim delayed off
	'desmond21', 20210510, 12, 2;... % Off, stim flat
	'desmond21', 20210510, 13, 1;... % On, stim delayed off
	'desmond21', 20210510, 13, 2;... % Off, stim delayed off

	'desmond21', 20210511, 5, 1;... % On, stim delayed off
	'desmond21', 20210511, 6, 1;... % On, stim off
	'desmond21', 20210511, 8, 1;... % On, stim off
	'desmond21', 20210511, 9, 1;... % Flat, stim flat
	'desmond21', 20210511, 12, 1;... % Up, stim delayed off, duplicate with 0506

	'desmond21', 20210512, 2, 1;... % Up, stim off
	'desmond21', 20210512, 6, 1;... % Flat, stim delayed off
	'desmond21', 20210512, 9, 1;... % Flat, stim delayed off
	'desmond21', 20210512, 10, 1;... % Up, stim off
	'desmond21', 20210512, 10, 2;... % Up, stim off
	'desmond21', 20210512, 12, 1;... % Up, stim delayed off, duplicate with 0506
	
	'desmond21', 20210513, 1, 1;... % On, stim off then delayed on
	'desmond21', 20210513, 3, 1;... % On, stim off then delayed on
	'desmond21', 20210513, 4, 1;... % Flat, stim off then delayed on
	'desmond21', 20210513, 6, 1;... % Up, stim flat?
	'desmond21', 20210513, 7, 1;... % Up, stim off
	'desmond21', 20210513, 9, 1;... % Down, stim delayed off

	'desmond21', 20210514, 1, 1;... % On, stim off
	'desmond21', 20210514, 1, 2;... % On, stim off
	'desmond21', 20210514, 2, 1;... % On, stim on
	'desmond21', 20210514, 3, 1;... % Flat, stim delayed off
	'desmond21', 20210514, 5, 1;... % On, stim delayed off
	'desmond21', 20210514, 6, 1;... % On, stim off then delayed on
	'desmond21', 20210514, 6, 2;... % On, stim off then delayed on
	'desmond21', 20210514, 9, 1;... % On, stim delayed off
	'desmond21', 20210514, 10, 1;... % On, stim delayed off

	'desmond21', 20210517, 1, 1;... % Off, stim on
	'desmond21', 20210517, 3, 1;... % On, stim delayed off
	'desmond21', 20210517, 3, 2;... % On, stim off
	'desmond21', 20210517, 4, 1;... % On, stim off

	};

% Weird cells, not batchable

	'desmond21', 20210503, 5, 1;... % Up, stim on. Completely off when animal satiated



expNames = cell(length(batchPlotListStim), 1);
for iExp = 1:length(batchPlotListStim)
	expNames{iExp} = [batchPlotListStim{iExp, 1}, '_', num2str(batchPlotListStim{iExp, 2})];
end

expNamesUnique = unique(expNames);

for iTr = 1:length(expNamesUnique)
	tr = TetrodeRecording.BatchLoad(expNamesUnique(iTr));
	try
		if iTr == 1;
			PETH = TetrodeRecording.BatchPETHistCounts(tr, batchPlotListStim, 'TrialLength', 6, 'ExtendedWindow', 1, 'SpikeRateWindow', 100, 'ExtendedWindowStim', [-1, 1], 'SpikeRateWindowStim', 10, 'Press', true, 'Lick', false, 'Stim', true);
		else
			PETH = [PETH, TetrodeRecording.BatchPETHistCounts(tr, batchPlotListStim, 'TrialLength', 6, 'ExtendedWindow', 1, 'SpikeRateWindow', 100, 'ExtendedWindowStim', [-1, 1], 'SpikeRateWindowStim', 10, 'Press', true, 'Lick', false, 'Stim', true)];
		end
	catch ME
		warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
		warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
	end
end

PETHStim = PETH;

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



figure()
axes()
hold on
for i = 1:size(pethSortedNorm, 1)
	sel = t >= -0.2;
	isDec = any(pethSortedNorm(i, t>0 & t <= 0.1) < -2.5);
    isInc = any(pethSortedNorm(i, t>0 & t <= 0.1) > 2.5);
	if isDec
		h = plot(t(sel)*1000, pethSortedNorm(i, sel), 'color', [.2, .8, .2, 0.67]);
    elseif isInc
		h = plot(t(sel)*1000, pethSortedNorm(i, sel), 'color', [.8, .2, .2, 0.67]);
    else
		h = plot(t(sel)*1000, pethSortedNorm(i, sel), 'color', [.2, .2, .2, 0.67]);
    end
    h.DisplayName = num2str(i);
end
plot([0, 20], [0, 0], 'b', 'LineWidth', 3)
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
	isDec = any(pethSortedNorm(i, t>0 & t <= 0.1) < -2.5);
    isInc = any(pethSortedNorm(i, t>0 & t <= 0.1) > 2.5);
	if isDec
		h = plot(t(sel)*1000, pethSorted(i, sel), 'color', [.2, .8, .2, 0.67]);
    elseif isInc
		h = plot(t(sel)*1000, pethSorted(i, sel), 'color', [.8, .2, .2, 0.67]);
    else
		h = plot(t(sel)*1000, pethSorted(i, sel), 'color', [.2, .2, .2, 0.67]);
    end
    h.DisplayName = num2str(i);
end
plot([0, 20], [0, 0], 'b', 'LineWidth', 3)
hold off
title(char(sprintf("Drd1-ChR2 stim response of %d SNr units", size(pethStim, 1))))
xlabel("Time (ms)")
ylabel("Spike rate (z-score)")
xlim([-100, 100])
