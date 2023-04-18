% Batchplot based on date/channel, and paste to clipboard
% Ref/noise cluster is last cluster
batchPlotList = {...
	'Daisy1', 20171114, 32, 1;...
	'Daisy1', 20171117, 10, 1;...
	'Daisy1', 20171117, 7, 1;...
	'Daisy1', 20171121, 24, 1;...
	'Daisy1', 20171121, 28, 1;...
	'Daisy1', 20171121, 1, 1;...
	'Daisy1', 20171122, 12, 1;...
	'Daisy1', 20171122, 15, 1;...
	'Daisy1', 20171128, 19, 1;...
	'Daisy1', 20171128, 28, 1;...
	'Daisy1', 20171130, 19, 1;...



	'Daisy2', 20180420, 14, 1;... % Up
	'Daisy2', 20180420, 32, 1;... % DA
	'Daisy2', 20180421, 13, 1;... % Up (flat short trials)
	'Daisy2', 20180421, 14, 1;... % Up (flat short trials)
	'Daisy2', 20180422, 15, 1;... % Down late
	'Daisy2', 20180422, 21, 1;... % Up
	'Daisy2', 20180425, 17, 1;... % Down at 0
	'Daisy2', 20180425, 23, 1;... % Down at 0
	'Daisy2', 20180425, 27, 1;... % DA
	'Daisy2', 20180425, 29, 1;... % DA
	'Daisy2', 20180427, 31, 1;... % DA
	'Daisy2', 20180429, 1, 1;...  % flat
	'Daisy2', 20180429, 3, 1;...  % slight down
	'Daisy2', 20180429, 4, 1;...  % slight down
	'Daisy2', 20180429, 17, 1;... % multi up
	'Daisy2', 20180430, 4, 1;...  % flat
	'Daisy2', 20180501, 18, 1;... % flat
	'Daisy2', 20180501, 30, 1;... % flat
	'Daisy2', 20180501, 30, 2;... % flat
	'Daisy2', 20180502, 8, 1;...  % down
	'Daisy2', 20180508, 20, 1;... % DA
	'Daisy2', 20180509, 2, 1;...  % flat
	'Daisy2', 20180514, 6, 1;...  % flat/fast up
	'Daisy2', 20180514, 18, 1;... % down
	'Daisy2', 20180514, 20, 1;... % DA down
	'Daisy2', 20180514, 20, 2;... % DA down
	'Daisy2', 20180515, 20, 1;... % DA down
	'Daisy2', 20180516, 4, 1;...  % flat
	'Daisy2', 20180517, 3, 1;...  % up
	'Daisy2', 20180517, 4, 1;...  % up
	'Daisy2', 20180518, 18, 1;... % down
	'Daisy2', 20180519, 3, 1;... % up
	'Daisy2', 20180519, 3, 2;... % down
	'Daisy2', 20180520, 18, 1;... % down
	'Daisy2', 20180521, 21, 1;... % up
	'Daisy2', 20180521, 24, 1;... % up
	'Daisy2', 20180522, 24, 1;... % up
	'Daisy2', 20180523, 18, 1;... % down
	'Daisy2', 20180523, 21, 1;... % up
	'Daisy2', 20180523, 22, 1;... % up
	'Daisy2', 20180523, 24, 1;... % up
	'Daisy2', 20180524, 22, 1;... % up
	'Daisy2', 20180524, 24, 1;... % up
	'Daisy2', 20180526, 24, 1;... % up
	'Daisy2', 20180528, 17, 1;... % flat/DA/antireward
	'Daisy2', 20180529, 17, 1;... % flat/DA/antireward
	'Daisy2', 20180529, 19, 1;... % flat/DA/antireward
	'Daisy2', 20180613, 5, 1;...  % flat
	'Daisy2', 20180613, 21, 1;... % down
	'Daisy2', 20180615, 4, 1;... % flat (slower for longer trials)
	'Daisy2', 20180615, 21, 1;... % huge slow
	'Daisy2', 20180618, 6, 1;... % up
	'Daisy2', 20180618, 18, 1;... % flat
	'Daisy2', 20180618, 18, 2;... % flat
	'Daisy2', 20180619, 17, 1;... % up




	'Daisy3', 20180419, 32, 1;... % DA/up/reward
	'Daisy3', 20180420, 3, 1;... % DA/up/reward
	'Daisy3', 20180420, 29, 1;... % flat/up/down
	'Daisy3', 20180422, 15, 1;... % up
	'Daisy3', 20180422, 30, 1;... % up
	'Daisy3', 20180423, 13, 1;... % DA/up
	'Daisy3', 20180423, 13, 2;... % down/up
	'Daisy3', 20180423, 14, 1;... % DA down
	'Daisy3', 20180423, 15, 1;... % up
	'Daisy3', 20180423, 17, 1;... % up
	'Daisy3', 20180423, 26, 1;... % up (cue/move)
	'Daisy3', 20180423, 31, 1;... % up
	'Daisy3', 20180424, 10, 1;... % DA
	'Daisy3', 20180424, 10, 2;... % down
	'Daisy3', 20180424, 21, 1;... % up
	'Daisy3', 20180424, 29, 1;... % quiet up
	'Daisy3', 20180425, 16, 1;... % DA
	'Daisy3', 20180425, 19, 1;... % up
	'Daisy3', 20180425, 25, 1;... % up
	'Daisy3', 20180426, 29, 1;... % up
	'Daisy3', 20180427, 19, 1;... % up
	'Daisy3', 20180427, 22, 1;... % up
	'Daisy3', 20180427, 22, 2;... % up
	'Daisy3', 20180429, 10, 2;... % up
	'Daisy3', 20180429, 25, 1;... % cue
	'Daisy3', 20180429, 30, 1;... % up
	'Daisy3', 20180430, 10, 1;... % up
	'Daisy3', 20180430, 14, 1;... % up
	'Daisy3', 20180430, 23, 1;... % up
	'Daisy3', 20180430, 23, 2;... % up
	'Daisy3', 20180501, 22, 1;... % up
	'Daisy3', 20180502, 22, 1;... % up
	'Daisy3', 20180502, 29, 1;... % up
	'Daisy3', 20180503, 17, 1;... % down
	'Daisy3', 20180504, 15, 1;... % up
	'Daisy3', 20180507, 20, 1;... % up
	'Daisy3', 20180507, 29, 1;... % down
	'Daisy3', 20180508, 11, 1;... % up
	'Daisy3', 20180508, 28, 1;... % DA down
	'Daisy3', 20180509, 1, 1;... % up
	'Daisy3', 20180509, 13, 1;... % up
	'Daisy3', 20180509, 15, 1;... % down
	'Daisy3', 20180509, 29, 1;... % up
	'Daisy3', 20180515, 15, 1;... % down
	'Daisy3', 20180515, 18, 1;... % up
	'Daisy3', 20180515, 31, 1;... % down
	'Daisy3', 20180516, 18, 1;... % down
	'Daisy3', 20180517, 1, 1;... % ?
	'Daisy3', 20180517, 1, 2;... % DA
	'Daisy3', 20180517, 9, 1;... % down
	'Daisy3', 20180517, 10, 1;... % down
	'Daisy3', 20180517, 15, 1;... % up
	'Daisy3', 20180517, 15, 2;... % down
	'Daisy3', 20180518, 1, 1;... % down DA
	'Daisy3', 20180518, 10, 1;... % down
	'Daisy3', 20180518, 15, 1;... % up
	'Daisy3', 20180518, 20, 1;... % up
	'Daisy3', 20180519, 9, 1;... % down
	'Daisy3', 20180519, 20, 1;... % up
	'Daisy3', 20180520, 1, 1;... % up
	'Daisy3', 20180520, 10, 1;... % down
	'Daisy3', 20180520, 15, 1;... % up
	'Daisy3', 20180521, 1, 1;... % DA
	'Daisy3', 20180521, 3, 1;... % down
	'Daisy3', 20180521, 16, 1;... % up
	'Daisy3', 20180522, 1, 1;... % DA
	'Daisy3', 20180522, 1, 2;... % DA
	'Daisy3', 20180522, 8, 1;... % down
	'Daisy3', 20180522, 32, 1;... % up
	'Daisy3', 20180522, 32, 2;... % down
	'Daisy3', 20180523, 1, 1;... % flat
	'Daisy3', 20180523, 1, 2;... % DA/up
	'Daisy3', 20180523, 1, 3;... % lick/or lick transient
	'Daisy3', 20180523, 4, 1;... % flat
	'Daisy3', 20180523, 6, 1;... % up
	'Daisy3', 20180523, 15, 1;... % down after
	'Daisy3', 20180523, 15, 2;... % up
	'Daisy3', 20180523, 32, 1;... % up
	'Daisy3', 20180524, 1, 1;... % DA
	'Daisy3', 20180524, 1, 2;... % flat
	'Daisy3', 20180524, 6, 1;... % flat
	'Daisy3', 20180524, 16, 1;... % up
	'Daisy3', 20180524, 23, 1;... % DA
	'Daisy3', 20180524, 27, 1;... % down?
	'Daisy3', 20180525, 1, 1;... % DA
	'Daisy3', 20180525, 1, 2;... % DA
	'Daisy3', 20180525, 4, 1;... % same as above
	'Daisy3', 20180525, 15, 1;... % down
	'Daisy3', 20180525, 16, 1;... % DA
	'Daisy3', 20180525, 27, 1;... % down
	'Daisy3', 20180526, 1, 1;... % down
	'Daisy3', 20180526, 15, 1;... % down
	'Daisy3', 20180526, 16, 1;... % up down
	'Daisy3', 20180526, 32, 1;... % flat
	'Daisy3', 20180528, 15, 1;... % down
	'Daisy3', 20180528, 32, 1;... % down
	'Daisy3', 20180529, 12, 1;... % up
	'Daisy3', 20180529, 30, 1;... % DA
	'Daisy3', 20180529, 32, 1;... % DA
	'Daisy3', 20180530, 11, 1;... % DA
	'Daisy3', 20180611, 15, 1;... % down
	'Daisy3', 20180611, 25, 1;... % burst
	'Daisy3', 20180612, 13, 1;... % up
	'Daisy3', 20180612, 15, 1;... % up
	'Daisy3', 20180613, 13, 1;... % up (earlier for licking)
	'Daisy3', 20180613, 20, 1;... % up
	'Daisy3', 20180614, 13, 1;... % up
	'Daisy3', 20180614, 29, 1;... % up
	'Daisy3', 20180615, 9, 1;... % up
	'Daisy3', 20180615, 13, 1;... % up
	'Daisy3', 20180615, 15, 1;... % up
	'Daisy3', 20180615, 27, 1;... % ?
	'Daisy3', 20180618, 13, 1;... % up
	'Daisy3', 20180618, 28, 1;... % ?
	'Daisy3', 20180618, 29, 1;... % up
	'Daisy3', 20180619, 13, 1;... % up
	'Daisy3', 20180619, 29, 1;... % up
	'Daisy3', 20180620, 2, 1;... % down
	'Daisy3', 20180620, 13, 1;... % up
	'Daisy3', 20180620, 17, 1;... % up




	'desmond10', 20180909, 1, 1;... % up
	'desmond10', 20180909, 2, 1;... % up
	'desmond10', 20180909, 4, 1;... % up
	'desmond10', 20180909, 5, 1;... % up
	'desmond10', 20180909, 6, 1;... % up
	'desmond10', 20180909, 9, 1;... % up
	'desmond10', 20180909, 10, 1;... % up
	'desmond10', 20180909, 14, 1;... % up
	'desmond10', 20180910, 2, 1;... % up
	'desmond10', 20180910, 5, 1;... % up
	'desmond10', 20180910, 6, 1;... % DA up
	'desmond10', 20180910, 9, 1;... % DA up
	'desmond10', 20180910, 10, 1;... % up
	'desmond10', 20180910, 14, 1;... % DA
	'desmond10', 20180911, 1, 1;... % up
	'desmond10', 20180911, 5, 1;... % up
	'desmond10', 20180911, 7, 1;... % up
	'desmond10', 20180911, 9, 1;... % up
	'desmond10', 20180911, 10, 1;... % up
	'desmond10', 20180911, 13, 1;... % up
	'desmond10', 20180912, 5, 1;... % up
	'desmond10', 20180912, 6, 1;... % up
	'desmond10', 20180912, 10, 1;... % up
	'desmond10', 20180913, 4, 1;... % up
	'desmond10', 20180913, 5, 1;... % DA
	'desmond10', 20180913, 9, 1;... % burst
	'desmond10', 20180913, 32, 1;... % off error trials
	'desmond10', 20180915, 1, 1;... % DA
	'desmond10', 20180915, 1, 2;... % DA
	'desmond10', 20180915, 5, 1;... % up
	'desmond10', 20180915, 5, 2;... % up
	'desmond10', 20180915, 9, 1;... % up
	'desmond10', 20180915, 10, 1;... % up
	'desmond10', 20180916, 2, 1;... % up
	'desmond10', 20180916, 5, 1;... % up
	'desmond10', 20180916, 9, 1;... % up
	'desmond10', 20180916, 13, 1;... % up
	'desmond10', 20180917, 2, 1;... % DA up
	'desmond10', 20180917, 5, 1;... % up
	'desmond10', 20180917, 9, 1;... % up
	'desmond10', 20180917, 13, 1;... % DA
	'desmond10', 20180918, 1, 1;... % up
	'desmond10', 20180918, 2, 1;... % DA up
	'desmond10', 20180918, 5, 1;... % up
	'desmond10', 20180918, 9, 1;... % up
	'desmond10', 20180918, 10, 1;... % up
	'desmond10', 20180919, 1, 1;... % press not lick
	'desmond10', 20180919, 2, 1;... % DA up
	'desmond10', 20180919, 5, 1;... % DA up
	'desmond10', 20180919, 8, 1;... % flat
	'desmond10', 20180919, 9, 1;... % up
	'desmond10', 20180919, 10, 1;... % DA
	'desmond10', 20180919, 13, 1;... % DA
	'desmond10', 20180920, 4, 1;... % DA reward
	'desmond10', 20180920, 5, 1;... % up
	'desmond10', 20180920, 13, 1;... % DA
	'desmond10', 20180920, 16, 1;... % DA
	'desmond10', 20180920, 19, 1;... % flat
	'desmond10', 20180920, 29, 1;... % flat
	'desmond10', 20180921, 2, 1;... % up
	'desmond10', 20180921, 5, 1;... % up
	'desmond10', 20180921, 30, 1;... % flat
	'desmond10', 20180922, 4, 1;... % DA
	'desmond10', 20180922, 5, 1;... % up
	'desmond10', 20180922, 18, 1;... % lick cell
	'desmond10', 20180922, 30, 1;... % flat
	'desmond10', 20180923, 2, 1;... % flat
	'desmond10', 20180923, 6, 1;... % flat
	'desmond10', 20180923, 8, 1;... % flat
	'desmond10', 20180923, 10, 1;... % up
	'desmond10', 20180923, 30, 1;... % flat
	'desmond10', 20180924, 19, 1;... % ?
	'desmond10', 20180924, 25, 1;... % DA
	'desmond10', 20180924, 29, 1;... % ?
	'desmond10', 20180924, 30, 1;... % flat
	'desmond10', 20180925, 7, 1;... % up
	'desmond10', 20180925, 8, 1;... % flat
	'desmond10', 20180925, 10, 1;... % DA
	'desmond10', 20180925, 10, 2;... % flat
	'desmond10', 20180925, 19, 2;... % ??
	'desmond10', 20180925, 20, 2;... % DA
	'desmond10', 20180925, 29, 2;... % ??
	'desmond10', 20181017, 4, 1;... % DA
	'desmond10', 20181018, 1, 1;... % down
	'desmond10', 20181018, 7, 1;... % DA
	'desmond10', 20181018, 8, 1;... % down
	'desmond10', 20181018, 8, 2;... % DA
	'desmond10', 20181019, 1, 1;... % flat
	'desmond10', 20181019, 1, 2;... % DA
	'desmond10', 20181019, 7, 1;... % DA
	'desmond10', 20181019, 9, 1;... % up
	'desmond10', 20181020, 1, 1;... % up
	'desmond10', 20181020, 7, 1;... % up
	'desmond10', 20181022, 1, 1;... % up
	'desmond10', 20181022, 1, 2;... % DA
	'desmond10', 20181022, 7, 2;... % up




	'desmond11', 20180909, 5, 1;... % down/up
	'desmond11', 20180910, 5, 1;... % up
	'desmond11', 20180910, 27, 1;... % up
	'desmond11', 20180910, 28, 1;... % up
	'desmond11', 20180911, 10, 1;... % up
	'desmond11', 20180911, 27, 1;... % DA
	'desmond11', 20180912, 4, 1;... % up
	'desmond11', 20180912, 5, 1;... % up
	'desmond11', 20180912, 28, 1;... % DA ?
	'desmond11', 20180913, 28, 1;... % servo?
	'desmond11', 20180914, 27, 1;... % DA
	'desmond11', 20180914, 29, 1;... % up
	'desmond11', 20180915, 31, 1;... % up
	'desmond11', 20180915, 31, 2;... % up
	'desmond11', 20180916, 4, 2;... % down
	'desmond11', 20180916, 20, 1;... % DA
	'desmond11', 20180916, 20, 2;... % up
	'desmond11', 20180916, 31, 1;... % up
	'desmond11', 20180917, 8, 1;... % down
	'desmond11', 20180917, 28, 1;... % down
	'desmond11', 20180918, 8, 1;... % down
	'desmond11', 20180919, 23, 1;... % up
	'desmond11', 20180919, 28, 1;... % up
	'desmond11', 20180919, 30, 1;... % up
	'desmond11', 20180920, 18, 1;... % up
	'desmond11', 20180921, 2, 1;... % lick not press
	'desmond11', 20180922, 2, 1;... % lick not press
	'desmond11', 20180922, 28, 1;... % DA
	'desmond11', 20180924, 2, 1;... % up
	'desmond11', 20180924, 17, 1;... % up
	'desmond11', 20180924, 28, 1;... % DA
	'desmond11', 20180925, 2, 1;... % up
	'desmond11', 20181022, 28, 1;... % down
	'desmond11', 20181023, 28, 1;... % down

	};

batchPlotListMulti = {...
	'Daisy3', 20180422, 13, 1;... % multi up
	'Daisy3', 20180523, 12, 1;... % multi up
	'Daisy3', 20180524, 27, 1;... % multi up
	'desmond10', 20180910, 12, 1;... % multi up
	'desmond11', 20180911, 14, 1;... % multi up
	'desmond11', 20180915, 10, 1;... % multi up
	};

expNames = cell(length(batchPlotList), 1);
for iExp = 1:length(batchPlotList)
	expNames{iExp} = [batchPlotList{iExp, 1}, '_', num2str(batchPlotList{iExp, 2})];
end

expNamesUnique = unique(expNames);

for iTr = 1:length(expNamesUnique)
	tr = TetrodeRecording.BatchLoad(expNamesUnique(iTr));
	try
		if iTr == 1;
			PETH = TetrodeRecording.BatchPETHistCounts(tr, batchPlotList, 'TrialLength', 6, 'ExtendedWindow', 1);
		else
			PETH = [PETH, TetrodeRecording.BatchPETHistCounts(tr, batchPlotList, 'TrialLength', 6, 'ExtendedWindow', 1)];
		end
	catch ME
		warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
		warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
	end
end



TetrodeRecording.HeatMap(PETH, 'Normalization', 'zscore', 'Sorting', 'latency', 'MinNumTrials', 75, 'MinSpikeRate', 15, 'Window', [-4, 1], 'NormalizationBaselineWindow', [-6, 0]);
TetrodeRecording.HeatMap(PETH, 'Normalization', 'zscore', 'Sorting', 'latency', 'MinNumTrials', 75, 'MinSpikeRate', 15, 'Window', [-4, 1], 'NormalizationBaselineWindow', [-4, 0], 'UseSameSorting', true);


% For Daisy3/4 (D1-ChR2) and Desmond12/13 (DAT-ChR2)

batchPlotListStim = {...
	'daisy4', 20190402, 2, 1;...
	'daisy4', 20190403, 2, 1;... % SAME WAVEFORM/CHN AS ABOVE?
	'daisy4', 20190404, 1, 1;... % down, stim down (weird effects before stim?)
	'daisy4', 20190404, 4, 1;... % multi, down, stim down (weird effects before stim?)
	'daisy4', 20190404, 5, 1;... % DA up, but clear stim (up) effects
	'daisy4', 20190404, 6, 1;... % up
	'daisy4', 20190408, 5, 1;... % up, stim effects after stim off???? misaligned???
	'daisy4', 20190408, 6, 1;... % DA, stim effects after stim off???? misaligned???
	'daisy4', 20190408, 6, 2;... % DA, stim effects after stim off???? misaligned???
	'daisy4', 20190409, 4, 1;... % down
	'daisy4', 20190409, 6, 1;...
	'daisy4', 20190411, 1, 1;... % Up, stim up
	'daisy4', 20190411, 3, 1;... % Up, stim up
	'daisy4', 20190411, 7, 1;... % DA, stim
	'daisy4', 20190411, 7, 2;... % DA, stim
	'daisy4', 20190411, 9, 1;... % DA, stim
	'daisy4', 20190416, 3, 1;... % Misaligned
	'daisy4', 20190416, 5, 1;... % DA, Misaligned
	'daisy4', 20190416, 10, 1;... % Misaligned
	'daisy4', 20190416, 11, 1;... % Misaligned
	'daisy4', 20190417, 1, 1;... % Misaligned
	'daisy4', 20190417, 3, 1;... % Misaligned
	'daisy4', 20190417, 6, 1;... % Misaligned
	'daisy4', 20190418, 2, 1;... % Misaligned
	'daisy4', 20190418, 6, 1;... % Misaligned
	'daisy4', 20190422, 1, 1;... % Misaligned
	'daisy4', 20190422, 5, 1;... % Misaligned
	'daisy4', 20190422, 6, 1;... % DA Misaligned
	'daisy4', 20190423, 1, 1;... % Misaligned
	'daisy4', 20190423, 7, 1;... % Misaligned
	'daisy4', 20190423, 8, 1;... % Misaligned
	'daisy4', 20190424, 1, 1;... % up, stim up
	'daisy4', 20190424, 5, 1;... % up, stim down
	'daisy4', 20190424, 6, 1;... % up, stim up
	'daisy4', 20190425, 4, 1;... % MISALIGNED
	'daisy4', 20190425, 5, 1;... % MISALIGNED
	'daisy4', 20190429, 2, 1;... % Misaligned, stim off
	'daisy4', 20190429, 3, 1;... % Misaligned
	'daisy4', 20190429, 5, 1;... % Misaligned
	'daisy4', 20190508, 1, 1;... % Misaligned
	'daisy4', 20190508, 5, 1;... % Misaligned
	'daisy4', 20190508, 6, 1;... % Misaligned, stim off
	'daisy4', 20190508, 7, 1;... % Misaligned, stim off
	'daisy4', 20190508, 8, 1;... % Misaligned, stim off
	'daisy4', 20190514, 3, 1;... % Misaligned
	'daisy4', 20190514, 5, 1;... % Misaligned
	'daisy4', 20190514, 6, 1;... % Misaligned
	'daisy4', 20190514, 7, 1;... % Misaligned
	'daisy4', 20190515, 1, 1;... % Misaligned
	'daisy4', 20190515, 2, 1;... % Misaligned
	'daisy4', 20190515, 3, 1;... % Misaligned
	'daisy4', 20190515, 4, 1;... % Misaligned
	'daisy4', 20190515, 6, 1;... % Misaligned

	'daisy5', 20190328, 4, 1;... % DA
	'daisy5', 20190328, 4, 2;... % Up multi
	'daisy5', 20190401, 4, 1;... % Up multi
	'daisy5', 20190401, 5, 1;... % Up
	'daisy5', 20190403, 10, 1;... % Up
	'daisy5', 20190404, 6, 1;... % Down
	'daisy5', 20190404, 7, 1;... % Down
	'daisy5', 20190404, 9, 1;... % Down
	'daisy5', 20190408, 1, 1;... % up
	'daisy5', 20190408, 2, 1;... % DA
	'daisy5', 20190408, 3, 1;... % Multi
	'daisy5', 20190409, 1, 1;... % DA
	'daisy5', 20190409, 3, 1;... % Down
	'daisy5', 20190410, 2, 1;... % Down
	'daisy5', 20190411, 2, 1;... % 
	'daisy5', 20190411, 3, 1;... % 
	'daisy5', 20190416, 2, 1;... % Reward response?
	'daisy5', 20190417, 1, 1;... %
	'daisy5', 20190418, 1, 1;... %
	'daisy5', 20190418, 2, 1;... %
	'daisy5', 20190422, 1, 1;... %
	'daisy5', 20190424, 1, 1;... % Up
	'daisy5', 20190425, 4, 1;... % Up
	'daisy5', 20190425, 5, 1;... % Up
	'daisy5', 20190425, 6, 1;... % Up
	'daisy5', 20190425, 7, 1;... % None, reward response?
	'daisy5', 20190425, 8, 1;... % None, reward response?
	'daisy5', 20190425, 12, 1;... % Up
	'daisy5', 20190508, 1, 1;... % Up
	'daisy5', 20190508, 2, 1;... % Down?
	'daisy5', 20190508, 4, 1;... 
	'daisy5', 20190508, 6, 1;... 
	'daisy5', 20190508, 9, 1;... % Up, unrewarded down 
	'daisy5', 20190514, 1, 1;... % Up
	'daisy5', 20190514, 2, 1;... % Up
	'daisy5', 20190514, 4, 1;... % Up
	'daisy5', 20190514, 6, 1;... % DA
	'daisy5', 20190514, 7, 1;... % Down
	'daisy5', 20190514, 14, 1;... % Down
	'daisy5', 20190515, 2, 1;... % Down
	'daisy5', 20190515, 6, 1;... % Down
	'daisy5', 20190515, 7, 1;... % Down
	'daisy5', 20190515, 9, 1;... % Up
	'daisy5', 20190515, 10, 1;... % Down


	'desmond12', 20190329, 1, 1;...
	'desmond12', 20190329, 3, 1;...
	'desmond12', 20190401, 1, 1;...
	'desmond12', 20190401, 2, 1;...
	'desmond12', 20190402, 2, 1;...
	'desmond12', 20190403, 4, 1;... % Weird delayed cue response
	'desmond12', 20190404, 1, 1;... % Big decrease
	'desmond12', 20190405, 6, 1;...
	'desmond12', 20190408, 2, 1;... % Big decrease
	'desmond12', 20190408, 3, 1;... % decrease
	'desmond12', 20190409, 3, 1;... % decrease
	'desmond12', 20190409, 4, 1;... % decrease
	'desmond12', 20190410, 3, 1;... % decrease (wierd response)
	'desmond12', 20190410, 4, 1;... % decrease (wierd response)
	'desmond12', 20190411, 2, 1;... % decrease (wierd response)
	'desmond12', 20190422, 1, 1;... % decrease
	'desmond12', 20190422, 2, 1;... % decrease
	'desmond12', 20190424, 2, 1;... % increase
	'desmond12', 20190424, 10, 1;... % increase (multi?)
	'desmond12', 20190425, 1, 1;... % increase
	'desmond12', 20190425, 2, 1;... % increase
	'desmond12', 20190425, 6, 1;... % increase
	'desmond12', 20190425, 7, 1;... % increase
	'desmond12', 20190429, 1, 1;... % increase
	'desmond12', 20190429, 3, 1;... % increase
	'desmond12', 20190429, 6, 1;... % increase, lever off response
	'desmond12', 20190429, 6, 2;... % increase
	'desmond12', 20190429, 7, 1;... % increase
	'desmond12', 20190429, 9, 1;... % increase
	'desmond12', 20190508, 1, 1;... % increase
	'desmond12', 20190508, 2, 1;... % increase
	'desmond12', 20190508, 3, 1;... % increase
	'desmond12', 20190508, 4, 1;... % increase
	'desmond12', 20190508, 5, 1;... % increase
	'desmond12', 20190508, 6, 1;... % increase
	'desmond12', 20190514, 1, 1;... % flat, bad alignment
	'desmond12', 20190514, 2, 1;... % flat, bad alignment
	'desmond12', 20190514, 4, 1;... % down, bad alignment
	'desmond12', 20190514, 5, 1;... % down, bad alignment
	'desmond12', 20190514, 6, 1;... % down, bad alignment
	'desmond12', 20190515, 3, 1;... % down, bad alignment



	'desmond13', 20190402, 2, 1;... % down
	'desmond13', 20190402, 5, 1;... % only cue resp (down)
	'desmond13', 20190402, 6, 1;... % up
	'desmond13', 20190403, 1, 1;... % down
	'desmond13', 20190403, 2, 1;... % flat
	'desmond13', 20190404, 1, 1;... % flat misaligned
	'desmond13', 20190405, 1, 1;... % flat
	'desmond13', 20190408, 1, 1;... % flat
	'desmond13', 20190408, 2, 1;... % down
	'desmond13', 20190410, 6, 1;... % down
	'desmond13', 20190411, 2, 1;... % down
	'desmond13', 20190411, 6, 1;... % up
	'desmond13', 20190417, 3, 1;... % up
	'desmond13', 20190418, 3, 1;... % up
	'desmond13', 20190418, 4, 1;... % up
	'desmond13', 20190422, 3, 1;... % up
	'desmond13', 20190422, 5, 1;... % up
	'desmond13', 20190422, 7, 1;... % up
	'desmond13', 20190423, 2, 1;... % down
	'desmond13', 20190423, 3, 1;... % down
	'desmond13', 20190423, 3, 1;... % down
	'desmond13', 20190424, 6, 1;... % down
	'desmond13', 20190425, 1, 1;... % down
	'desmond13', 20190425, 4, 1;... % flat
	'desmond13', 20190429, 2, 1;... % flat
	'desmond13', 20190508, 1, 1;... % flat
	'desmond13', 20190508, 2, 1;... % down
	'desmond13', 20190514, 2, 1;... % up
	'desmond13', 20190515, 1, 1;... % up
	'desmond13', 20190515, 2, 1;... % up
	'desmond13', 20190515, 3, 1;... % down
	};


batchPlotListStim = {...
	'desmond21', 20210406, 2, 1;... % Up, stim flat
	'desmond21', 20210406, 4, 1;... % Down, stim flat
	'desmond21', 20210406, 5, 1;... % Down maybe, stim flat
	'desmond21', 20210406, 6, 1;... % Up, stim flat
	'desmond21', 20210406, 7, 1;... % DA
	'desmond21', 20210406, 9, 1;... % Up, stim flat

	'desmond21', 20210407, 1, 1;... % Up, stim flat
	'desmond21', 20210407, 2, 1;... % Down, stim flat
	'desmond21', 20210407, 6, 1;... % Up, stim flat
	'desmond21', 20210407, 7, 1;... % Up, stim flat
	'desmond21', 20210407, 8, 1;... % Up, stim flat
	'desmond21', 20210407, 9, 1;... % DA

	'desmond21', 20210408, 2, 1;... % Down, stim flat
	'desmond21', 20210408, 7, 1;... % Up, stim flat
	};


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


% BatchPlot stim type 1910 (10 100ms pulse, 100ms spacing)
I = TetrodeRecording.HeatMapStim(PETHStim, 'Window', [-6, 0], 'NormalizationBaselineWindow', [-6, 0], 'WindowStim', [-0.25, 0.75], 'NormalizationBaselineWindowStim', [-1, 0], 'CLimStim', [-3,3], 'StimTrainTypes', [1910, 1606, 1604, 4002], 'Sorting', 'latency');


III = I([6 8 61 79 74 81]);
names = cellfun(@(x) x{1}, cellfun(@(x) strsplit(x, '_'), {PETHStim(III).ExpName}', 'UniformOutput', false), 'UniformOutput', false);
dates = cellfun(@(x) str2num(x{2}), cellfun(@(x) strsplit(x, '_'), {PETHStim(III).ExpName}', 'UniformOutput', false), 'UniformOutput', false);
bpl = [names, dates, {PETHStim(III).Channel}', {PETHStim(III).Cluster}'];


expNames = cell(length(bpl), 1);
for iExp = 1:length(bpl)
	expNames{iExp} = [bpl{iExp, 1}, '_', num2str(bpl{iExp, 2})];
end
for iTr = 1:length(expNames)
	tr = TetrodeRecording.BatchLoad(expNames(iTr));
	try
		TetrodeRecording.BatchPlot(tr, bpl, 'PlotStim', true);
	catch ME
		warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
		warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
	end
end


TetrodeRecording.HeatMapStim(PETHStim(cellfun(@(x) contains(x, {'daisy4', 'daisy5'}), {PETHStim.ExpName})), 'Window', [-6, 0], 'NormalizationBaselineWindow', [-6, 0], 'WindowStim', [-0.5, 1], 'NormalizationBaselineWindowStim', [-1, 0], 'CLimStim', [-3,3], 'StimTrainTypes', [1910, 1606, 1604, 4002], 'Sorting', 'latency');
TetrodeRecording.HeatMapStim(PETHStim(cellfun(@(x) contains(x, {'desmond12', 'desmond13'}), {PETHStim.ExpName})), 'Window', [-6, 0], 'NormalizationBaselineWindow', [-6, 0], 'WindowStim', [-0.5, 1], 'NormalizationBaselineWindowStim', [-1, 0], 'CLimStim', [-3,3], 'StimTrainTypes', [1910, 1606, 1604, 4002], 'Sorting', 'latency');


