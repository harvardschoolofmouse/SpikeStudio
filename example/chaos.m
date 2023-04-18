% Selected unit
expName = 'daisy8_20210629';
iChn = 9;
iUnit = 1;
referenceEventName = 'CueOn';
eventName = 'PressOn';
excludeEventName = 'LickOn';

% Recalculate spikeTimestamps relative to cue on
% Find the first lever press (true first movement: before any lick/press has occured since cue on)

% Get spikes between two reference and first event
reference = sort(tr.DigitalEvents.(referenceEventName));
event = sort(tr.DigitalEvents.(eventName));
exclude = tr.DigitalEvents.(excludeEventName);

[trialStart, trialEnd] = TetrodeRecording.FindFirstInTrial(reference, event, exclude);

edges = [trialStart; trialEnd]; edges = edges(:);

isSelectedUnit = tr.Spikes(iChn).Cluster.Classes == iUnit;
spikeTimestamps = tr.Spikes(iChn).Timestamps(isSelectedUnit);
spikeISI = [0, diff(spikeTimestamps)];

[~, ~, bins] = histcounts(spikeTimestamps, edges);
oddBins = rem(bins, 2) ~= 0;	% Spikes in odd bins occur in trial (between reference and event), should keep these spikes
spikeISI = spikeISI(oddBins);
spikeTimestamps = spikeTimestamps(oddBins);
spikeTrialIndices = (bins(oddBins) + 1)/2;
clear bins oddBins edges isSelectedUnit

spikeIDAlignedToMovement = zeros(size(spikeTrialIndices));
for iTrial = 1:max(spikeTrialIndices)
	isInTrial = spikeTrialIndices == iTrial;
	spikeIDAlignedToMovement(isInTrial) = -sum(isInTrial):-1;
end

% plot(spikeIDAlignedToMovement(spikeTrialIndices <= 50), spikeISI(spikeTrialIndices <= 50), '.');

minSpikeCount = 300;

for iTrial = 1:max(spikeTrialIndices)
	isInTrial = spikeTrialIndices == iTrial;
	if (sum(isInTrial) >= minSpikeCount)
		plot(spikeIDAlignedToMovement(isInTrial), spikeISI(isInTrial), '.')
		title(['Trial ', num2str(iTrial)])
		ylim([0, 0.02])
		xlim([-1000, 0])
		waitforbuttonpress()
	end

end

% spikesRelative = spikes - event(spikeTrialIndices);
% eventRelative = reference(spikeTrialIndices) - event(spikeTrialIndices);

