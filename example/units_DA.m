batchPlotList = {...
	'desmond10', 20180910, 6, 1;... % DA up
	'desmond10', 20180910, 9, 1;... % DA up
	'desmond10', 20180910, 14, 1;... % DA
	'desmond10', 20180913, 5, 1;... % DA
	'desmond10', 20180915, 1, 1;... % DA
	'desmond10', 20180915, 1, 2;... % DA
	'desmond10', 20180917, 2, 1;... % DA up
	'desmond10', 20180917, 13, 1;... % DA
	'desmond10', 20180918, 2, 1;... % DA up
	'desmond10', 20180919, 2, 1;... % DA up
	'desmond10', 20180919, 5, 1;... % DA up
	'desmond10', 20180919, 10, 1;... % DA
	'desmond10', 20180919, 13, 1;... % DA
	'desmond10', 20180920, 4, 1;... % DA reward
	'desmond10', 20180920, 13, 1;... % DA
	'desmond10', 20180920, 16, 1;... % DA
	'desmond10', 20180922, 4, 1;... % DA
	'desmond10', 20180924, 25, 1;... % DA
	'desmond10', 20180925, 10, 1;... % DA
	'desmond10', 20180925, 20, 2;... % DA
	'desmond10', 20181017, 4, 1;... % DA
	'desmond10', 20181018, 7, 1;... % DA
	'desmond10', 20181018, 8, 2;... % DA
	'desmond10', 20181019, 1, 2;... % DA
	'desmond10', 20181019, 7, 1;... % DA
	'desmond10', 20181022, 1, 2;... % DA
	'desmond11', 20180911, 27, 1;... % DA
	'desmond11', 20180912, 28, 1;... % DA ?
	'desmond11', 20180914, 27, 1;... % DA
	'desmond11', 20180916, 20, 1;... % DA
	'desmond11', 20180922, 28, 1;... % DA
	'desmond11', 20180924, 28, 1;... % DA
	'desmond22', 20210624, 5, 2;... % DA, slow on
	'desmond22', 20210624, 7, 2;... % DA flat
	'desmond22', 20210630, 1, 1;... % DA flat
	'desmond22', 20210707, 12, 1;... % DA slow on
	'daisy8', 20210623, 4, 2;... % DA
	'daisy8', 20210625, 1, 1;... % DA inhibited by ChR2
	'daisy8', 20210707, 9, 1;... % DA slow off
	'daisy8', 20210709, 12, 1;... % DA fast off
};

expNames = cell(size(batchPlotList, 1), 1);
for iExp = 1:size(batchPlotList, 1)
	expNames{iExp} = [batchPlotList{iExp, 1}, '_', num2str(batchPlotList{iExp, 2})];
end

expNamesUnique = unique(expNames);

for iTr = 1:length(expNamesUnique)
	tr = TetrodeRecording.BatchLoad(expNamesUnique(iTr));
    if contains(expNamesUnique(iTr), 'desmond22')
        tr.ReadDigitalEvents();
    end
	try
		TetrodeRecording.BatchPlot(tr, batchPlotList, 'RasterXLim', [-5, 2], 'ExtendedWindow', [0, 2], 'PlotStim', false, 'PlotLick', false, 'Reformat', 'RasterAndPETHAndWaveform');
	catch ME
		warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
		warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
	end
end

%% Second run, wider waveform window
% ptr = TetrodeRecording.BatchPreview();
% TetrodeRecording.BatchSave(ptr, 'Prefix', 'ptr_DA_', 'DiscardData', true);
% TetrodeRecording.BatchProcess(ptr, 'Prefix', 'tr_DA_', 'NumSigmas', 3, 'NumSigmasReturn', 1.5, 'NumSigmasReject', 40, 'WaveformWindow', [-2, 2], 'WaveformFeatureWindow', [-0.35, 0.35], 'FeatureMethod', 'WaveletTransform', 'ClusterMethod', 'kmeans', 'Dimension', 10);
% TetrodeRecording.BatchSave(tr, 'Prefix', 'tr_DA_', 'DiscardData', false);

% Copy digital events from old data.
% tr_org = TetrodeRecording.BatchLoad();
% for iTr = 1:length(tr)
% 	tr(iTr).DigitalEvents = tr_org(iTr).DigitalEvents;
% end

% TetrodeRecording.BatchSave(tr(iTrLastSaved+1:iTr), 'Prefix', 'tr_DA_sorted_', 'DiscardData', false); iTrLastSaved = iTr;


batchPlotList = {...
	'desmond10', 20180913, 4, 1;...
	'desmond10', 20180913, 7, 1;...
	'desmond10', 20180917, 1, 1;...
	'desmond10', 20180917, 4, 1;...
	'desmond10', 20180918, 1, 1;...
	'desmond10', 20180918, 3, 1;...
	'desmond10', 20180918, 4, 1;...
	'desmond10', 20180920, 2, 1;...
	'desmond10', 20180920, 6, 1;...
	'desmond10', 20180920, 6, 2;...
	'desmond10', 20180920, 7, 1;...
};

expNames = cell(size(batchPlotList, 1), 1);
for iExp = 1:size(batchPlotList, 1)
	expNames{iExp} = [batchPlotList{iExp, 1}, '_', num2str(batchPlotList{iExp, 2})];
end

expNamesUnique = unique(expNames);

for iTr = 1:length(expNamesUnique)
	tr = TetrodeRecording.BatchLoad(expNamesUnique(iTr));
	try
		TetrodeRecording.BatchPlot(tr(iTr), batchPlotList, 'RasterXLim', [-5, 2], 'ExtendedWindow', [0, 2], 'WaveformWindow', [-1, 1], 'PlotStim', false, 'PlotLick', false, 'Reformat', 'RasterAndPETHAndWaveform');
	catch ME
		warning(['Error when processing iTr = ', num2str(iTr), ' - this one will be skipped.'])
		warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
	end
end
