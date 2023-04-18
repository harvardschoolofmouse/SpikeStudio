% goal is to pull out waveforms from the SpikeSorter file and look at them
% using LFH's tr object

ch=26;
% find some waveforms on channel 26. This channel has a big ol' waveform in
% the first 2 minutes of recording.
ch_units = cellfun(@(x) find(x == ch), {units.channels}, 'uniformoutput',0);

clusters_with_ch_units = find(cell2mat(cellfun(@(x) ~isempty(x), ch_units, 'uniformoutput',0))==1);
%% let's extract those timepoints...
ch_timepoints = {};
for ii = 1:numel(clusters_with_ch_units)
    this_cluster = clusters_with_ch_units(ii);
    ch_timepoints{ii} = units(this_cluster).times(ch_units{this_cluster});
end
% let's get the minimum timepoint to make sure this isn't a wasted effort,
% lol
min_ss_timepoint = min(cell2mat(cellfun(@(x) min(x), ch_timepoints, 'UniformOutput',false)));

%% now let's find any of those timepoints in our LFH dataset
LFH_ch_times = tr.Spikes(ch).Timestamps; % these are in sec
max_LFH_time = max(LFH_ch_times);

%% awesome, we seem to have some overlap. Now let's first look at each cluster from ss that we can get a waveform for...
tr.ReadFiles('ChunkSize',10,...
    'WaveformWindow', [-0.5, 0.5],...
    'SpikeSorterAlign', true,...
    'SpikeSorterCSV', units)
