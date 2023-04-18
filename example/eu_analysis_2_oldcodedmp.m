
%% Apply time correction to eu only once
% for iExp = 1:length(exp)
%     trials = exp(iExp).eu(1).getTrials('press');
%     newTrials = Trial([trials.Start], [trials.Stop] + sto.press{iExp});
%     for iEu = 1:length(exp(iExp).eu)
%         exp(iExp).eu(iEu).Trials.PressCorrected = newTrials;
%         exp(iExp).eu(iEu).Trials.PressOriginal = trials;
%         exp(iExp).eu(iEu).Trials.Press = newTrials;
%     end
% end
% eu = [exp.eu];
% eu = eu(:)';
% disp('CORRECTION APPLIED');
% corrApplied = true;
% 
% %% 
% % Lick/Press responses
% eta.pressCorrected = eu.getETA('count', 'press', p.etaWindow, minTrialDuration=p.minTrialDuration, normalize=p.etaNorm);
% meta.pressCorrected = transpose(mean(eta.pressCorrected.X(:, eta.pressCorrected.t >= p.metaWindow(1) & eta.pressCorrected.t <= p.metaWindow(2)), 2, 'omitnan'));
% eta.lickCorrected = eu.getETA('count', 'lick', p.etaWindow, minTrialDuration=2, normalize=p.etaNorm);
% meta.lickCorrected = transpose(mean(eta.lickCorrected.X(:, eta.lickCorrected.t >= p.metaWindow(1) & eta.lickCorrected.t <= p.metaWindow(2)), 2, 'omitnan'));
% 
% eta.pressRawCorrected = eu.getETA('count', 'press', p.etaWindow, minTrialDuration=p.minTrialDuration, normalize='none');
% meta.pressRawCorrected = transpose(mean(eta.pressRawCorrected.X(:, eta.pressRawCorrected.t >= p.metaWindow(1) & eta.pressRawCorrected.t <= p.metaWindow(2)), 2, 'omitnan'));
% 
% %% Reverse apply previous step
% for iExp = 1:length(exp)
%     for iEu = 1:length(exp(iExp).eu)
%         exp(iExp).eu(iEu).Trials.Press = exp(iExp).eu(iEu).Trials.PressOriginal;
%     end
% end
% eu = [exp.eu];
% eu = eu(:)';
% disp('CORRECTION Removed');
% corrApplied = false;


%% 4.1 Single unit raster for stim responses (first pulse in each train)
% clear rdStim
% c.hasStim = arrayfun(@(eu) ~isempty(eu.getTrials('stim')), eu);
% rdStim(c.hasStim) = eu(c.hasStim).getRasterData('stim', window=[-0.1, 0.1], sort=false);
% 
% %% 4.1.1 Filter out specific stim durations (try 10ms, then the smallest above 10ms)
% rdStimFiltered = rdStim;
% p.minStimDuration = 0.01;
% p.maxStimDuration = 0.01;
% p.allowAltStimDuration = false;
% 
% for i = 1:length(rdStim)
%     if isempty(rdStim(i).t)
%         continue
%     end
% 
%     roundedDuration = round(rdStim(i).duration ./ p.errStimDuration) * p.errStimDuration;
%     isMinDur = roundedDuration == p.minStimDuration;
%     if any(isMinDur)
%         sel = ismember(rdStim(i).I, find(isMinDur));
%         rdStimFiltered(i).t = rdStim(i).t(sel);
%         newI = rdStim(i).I(sel); newI = changem(newI, 1:length(unique(newI)), unique(newI));
%         rdStimFiltered(i).I = newI;
%         rdStimFiltered(i).duration = roundedDuration(isMinDur);
%         rdStimFiltered(i).iti = rdStim(i).iti(isMinDur);
%         fprintf('%g: found %g trials with length %g.\n', i, nnz(isMinDur), p.minStimDuration);
%     else
%         isAboveMinDur = roundedDuration > p.minStimDuration;
%         if p.allowAltStimDuration && any(isAboveMinDur)
%             altMinDur = min(roundedDuration(isAboveMinDur));
%             isAltMinDur = roundedDuration == altMinDur;
%             sel = ismember(rdStim(i).I, find(isAltMinDur));
%             rdStimFiltered(i).t = rdStim(i).t(sel);
%             newI = rdStim(i).I(sel); newI = changem(newI, 1:length(unique(newI)), unique(newI));
%             rdStimFiltered(i).I = newI;
%             rdStimFiltered(i).duration = roundedDuration(isAltMinDur);
%             rdStimFiltered(i).iti = rdStim(i).iti(isAltMinDur);
%             fprintf('%g: could not find requested duration, found %g trials with length %g instead.\n', i, nnz(isAltMinDur), altMinDur);
%         else
%             fprintf('%g: could not find requested duration.', i)
%             rdStimFiltered(i).t = [];
%             rdStimFiltered(i).I = [];
%             rdStimFiltered(i).duration = [];
%             rdStimFiltered(i).iti = [];
%         end
%     end
% end
% 
% c.hasStim = arrayfun(@(rd) ~isempty(rd.t), rdStimFiltered);
% fprintf(1, '%g units with requested stim duration.\n', nnz(c.hasStim))
% 
% clear i roundedDuration isMinDur isAboveMinDur altMinDur isAltMinDur sel
%% 4.2.1 Stim ETA (PSTH) as heatmap
% 
% %%
% etaHighRes.stimD1 = eu.getETA('count', 'stim', [-0.5, 0.5], ...
%     resolution=0.002, ...
%     minTrialDuration=0, maxTrialDuration=0.101, ...
%     findSingleTrialDuration='max', normalize=[-0.5, 0], includeInvalid=false);
% 
% eta.stimD1 = eu.getETA('count', 'stimfirstpulse', [-0.5, 0.5], ...
%     resolution=0.01, ...
%     minTrialDuration=0, maxTrialDuration=0.101, ...
%     findSingleTrialDuration='max', normalize=[-0.5, 0], includeInvalid=false);
% %%
% etaHighRes.stim = eu.getETA('count', 'stim', [-0.5, 0.5], ...
%     resolution=0.002, ...
%     minTrialDuration=0.01, maxTrialDuration=0.01, ...
%     findSingleTrialDuration='min', normalize=[-0.5, 0], includeInvalid=false);
% etaHighRes.stimRaw = eu.getETA('count', 'stim', [-0.5, 0.5], ...
%     resolution=0.002, ...
%     minTrialDuration=0.01, maxTrialDuration=0.01, ...
%     findSingleTrialDuration='min', normalize='none', includeInvalid=false);
% 
% % 4.2.1 Stim ETA (PSTH) as heatmap
% eta.stim = eu.getETA('count', 'stim', [-0.5, 0.5], ...
%     resolution=0.01, ...
%     minTrialDuration=0.01, maxTrialDuration=0.01, ...
%     findSingleTrialDuration='min', normalize=[-0.5, 0], includeInvalid=false);
% eta.stimRaw = eu.getETA('count', 'stim', [-0.5, 0.5], ...
%     resolution=0.01, ...
%     minTrialDuration=0.01, maxTrialDuration=0.01, ...
%     findSingleTrialDuration='min', normalize='none', includeInvalid=false);
% 
% % For acute recording, pick DLS at 2.8
% bsr = arrayfun(@(ar) ar.selectStimResponse(Light=2, Duration=0.01, MLRank=2, DVRank=3), ar, UniformOutput=false);
% bsr = cat(2, bsr{:});
% 
% for iEu = 1:length(eu)
%     nameMatch = strcmpi({bsr.expName}, eu(iEu).ExpName);
%     channelMatch = [bsr.channel] == eu(iEu).Channel;
%     unitMatch = [bsr.unit] == eu(iEu).Unit;
%     iBsr = find(nameMatch & channelMatch & unitMatch);
%     
%     if isempty(iBsr)
%         continue
%     end
% 
%     t = bsr(iBsr).t;
%     sr = bsr(iBsr).spikeRates;
%     nsr = bsr(iBsr).normalizedSpikeRates;
% 
%     [li, loc] = ismember(round(t*1000), round(eta.stim.t*1000));
%     assert(all(li));
%     eta.stim.X(iEu, :) = NaN;
%     eta.stimRaw.X(iEu, :) = NaN;
%     eta.stim.X(iEu, loc) = mean(nsr, 1, 'omitnan');
%     eta.stimRaw.X(iEu, loc) = mean(sr, 1, 'omitnan') ./ 100;
%     fprintf(1, 'Replaced %g: %s.\n', iEu, eu(iEu).getName())
% end
% %% Catergoeize
% close all
% 
% p.metaWindowStim = [0.004, 0.02];
% p.posRespThresholdStim = 0.2;
% p.negRespThresholdStim = -0.2;
% 
% meta.stim = transpose(mean(etaHighRes.stim.X(:, etaHighRes.stim.t >= p.metaWindowStim(1) & etaHighRes.stim.t <= p.metaWindowStim(2)), 2, 'omitnan'));
% meta.stimRaw = transpose(mean(etaHighRes.stimRaw.X(:, etaHighRes.stimRaw.t >= p.metaWindowStim(1) & etaHighRes.stimRaw.t <= p.metaWindowStim(2)), 2, 'omitnan'));
% meta.stimD1 = transpose(mean(etaHighRes.stimD1.X(:, etaHighRes.stimD1.t >= p.metaWindowStim(1) & etaHighRes.stimD1.t <= p.metaWindowStim(2)), 2, 'omitnan'));
% 
% % meta.stim = etaHighRes.stim.X(:, etaHighRes.stim.t >= p.metaWindowStim(1) & etaHighRes.stim.t <= p.metaWindowStim(2));
% % [~, I] = max(abs(meta.stim), [], 2, 'omitnan');
% % meta.stim = diag(meta.stim(:, I))';
% % 
% % meta.stimD1 = etaHighRes.stimD1.X(:, etaHighRes.stimD1.t >= p.metaWindowStim(1) & etaHighRes.stimD1.t <= p.metaWindowStim(2));
% % [~, I] = max(abs(meta.stimD1), [], 2, 'omitnan');
% % meta.stimD1 = diag(meta.stimD1(:, I))';
% 
% histogram(meta.stim, 30)
% c.isStimUp = meta.stim >= p.posRespThresholdStim;
% c.isStimDown = meta.stim <= p.negRespThresholdStim;
% c.hasStimResponse = (c.isStimUp | c.isStimDown);% & cb.hasLowLatencyStimResponse';
% 
% c.isStimUpD1 = meta.stimD1 >= p.posRespThresholdStim;
% c.isStimDownD1 = meta.stimD1 <= p.negRespThresholdStim;
% c.hasStimResponseD1 = (c.isStimUpD1 | c.isStimDownD1);% & cb.hasLowLatencyStimResponse';
% c.excludeD1 = strcmpi('daisy4_20190429', {eu.ExpName}) | strcmpi('daisy4_20190404', {eu.ExpName});% Bad timing alignment?

%% latencies = NaN(length(eu), 1);
p.prctStimPeak = 0.5;
edges = 0:2.5:50;
latencies = NaN(length(eu), 1);
for iEu = find(c.hasStimResponse)
    t0 = etaHighRes.stim.t;
    x0 = etaHighRes.stim.X(iEu, :);
    xResp = x0(t0 > 0 & t0 <= 0.05);
    [~, Im] = max(abs(xResp));
    peak = xResp(Im);
    if peak >= 0
        I = find(t0 > 0 & t0 <= 0.05 & x0 >= p.prctStimPeak*peak, 1);
    else
        I = find(t0 > 0 & t0 <= 0.05 & x0 <= p.prctStimPeak*peak, 1);
    end
%     I = find(t0 > 0 & abs(x0) >= 0.15, 1);
    if isempty(I)
        warning('Could not find')
    else
        latencies(iEu) = t0(I);
    end
end
for iEu = find(c.hasStimResponseD1 & c.isD1 & ~c.excludeD1)
    t0 = etaHighRes.stimD1.t;
    x0 = etaHighRes.stimD1.X(iEu, :);
    xResp = x0(t0 > 0 & t0 <= 0.05);
    [~, Im] = max(abs(xResp));
    peak = xResp(Im);
    if peak >= 0
        I = find(t0 > 0 & t0 <= 0.05 & x0 >= p.prctStimPeak*peak, 1);
    else
        I = find(t0 > 0 & t0 <= 0.05 & x0 <= p.prctStimPeak*peak, 1);
    end
%     I = find(t0 > 0 & abs(x0) >= 0.15, 1);
    if isempty(I)
        warning('Could not find')
    else
        latencies(iEu) = t0(I);
    end
end
%%

latencies = NaN(length(eu), 1);
for iEu = find(c.hasStimResponse)
    t0 = etaHighRes.stim.t;
    x0 = etaHighRes.stim.X(iEu, :);
    hold on
    if meta.stim(iEu) > 0.1
        plot(t0, x0, 'r')
    elseif meta.stim(iEu) <-0.1
        plot(t0, x0, 'b')
    end
    xlim([-0.1, 0.1])
    xResp = x0(t0 > 0 & t0 <= 0.05);
    [~, Im] = max(abs(xResp));
    peak = xResp(Im);
    if peak >= 0
        I = find(t0 > 0 & t0 <= 0.05 & x0 >= p.prctStimPeak*peak, 1);
    else
        I = find(t0 > 0 & t0 <= 0.05 & x0 <= p.prctStimPeak*peak, 1);
    end
%     I = find(t0 > 0 & abs(x0) >= 0.15, 1);
    if isempty(I)
        warning('Could not find')
    else
        latencies(iEu) = t0(I);
    end
end
for iEu = find(c.hasStimResponseD1 & c.isD1 & ~c.excludeD1)
    t0 = etaHighRes.stimD1.t;
    x0 = etaHighRes.stimD1.X(iEu, :);
    xResp = x0(t0 > 0 & t0 <= 0.05);
    [~, Im] = max(abs(xResp));
    peak = xResp(Im);
    if peak >= 0
        I = find(t0 > 0 & t0 <= 0.05 & x0 >= p.prctStimPeak*peak, 1);
    else
        I = find(t0 > 0 & t0 <= 0.05 & x0 <= p.prctStimPeak*peak, 1);
    end
%     I = find(t0 > 0 & abs(x0) >= 0.15, 1);
    if isempty(I)
        warning('Could not find')
    else
        latencies(iEu) = t0(I);
    end
end

%% Cull AR duplicate/multiunits from AR. Use eu as reference
ar = AcuteRecording.load();
SEL = cell(1, length(ar));
for iAr = 1:length(ar)
    bsr = ar(iAr).bsr;
    found = false(1, length(bsr));
    for iBsr = 1:length(bsr)
        expName = bsr(iBsr).expName;
        channel = bsr(iBsr).channel;
        unit = bsr(iBsr).unit;
        found(iBsr) = any(strcmpi(expName, {eu.ExpName}) & [eu.Channel] == channel & [eu.Unit] == unit);
    end
    ar(iAr).bsr = bsr(found);
    ar(iAr).bmrPress = ar(iAr).bmrPress(found);
    ar(iAr).bmrLick = ar(iAr).bmrLick(found);
    ar(iAr).stats = ar(iAr).stats(found, :);
    ar(iAr).statsPress = ar(iAr).statsPress(found, :);
    ar(iAr).statsLick = ar(iAr).statsLick(found, :);
    SEL{iAr} = found;
end
clear found

%% Find acute units for video analysis
unitNames = eu(c.isAcute).getName()';
expNames = cellfun(@(x) strsplit(x, ' '), unitNames, UniformOutput=false);
expNames = unique(cellfun(@(x) x{1}, expNames, UniformOutput=false));

fprintf(1, 'Found %g sessions for video analysis:\n', length(expNames));
cellfun(@(x) fprintf(1, '\t%s\n', x), expNames);
