
expNames = cell(length(batchPlotList), 1);
for iExp = 1:length(batchPlotList)
	expNames{iExp} = [batchPlotList{iExp, 1}, '_', num2str(batchPlotList{iExp, 2})];
end

expNamesUnique = unique(expNames);

for iTr = 1:length(expNamesUnique)
	tr = TetrodeRecording.BatchLoad(expNamesUnique(iTr));
	trCalibration = TetrodeRecording();
	trCalibration.Files = tr.Files;
	trCalibration.Path = tr.Path;
	trCalibration.System = 'Blackrock';
	trCalibration.ReadFiles(10, 'Rig', 1, 'Duration', [0 60], 'DetectSpikes', false, 'DetectEvents', false);
	tThreshold = trCalibration.FrequencyParameters.SysInitDelay.Duration;
	iThreshold = trCalibration.FrequencyParameters.SysInitDelay.NumSamples;

	tr.FrequencyParameters.SysInitDelay.Duration = tThreshold;
	tr.FrequencyParameters.SysInitDelay.NumSamples = iThreshold;
	if ~isnan(iThreshold)
		for iChn = 1:length(tr.Spikes);
			if ~isempty(tr.Spikes(iChn).Channel)
				tr.Spikes(iChn).SampleIndex = tr.Spikes(iChn).SampleIndex - iThreshold;
				tr.Spikes(iChn).Timestamps = tr.Spikes(iChn).Timestamps - tThreshold;
				tr.DeleteWaveforms(iChn, 0, 'IndexType', 'Threshold');
			end
		end
		tr.FrequencyParameters.SysInitDelay.DataTrimmed = true;
		disp(['Removed data in the first ', num2str(tThreshold), ' seconds'])
	else
		disp('Does not need fixing.');
	end
	TetrodeRecording.BatchSave(tr, 'Prefix', 'tr_sorted_fixed_', 'DiscardData', false, 'MaxChannels', 5);
end


batchPlotList = {...
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