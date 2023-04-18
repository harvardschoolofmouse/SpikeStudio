%%
%% 1.2Alt Or just load lite version, without non-SNr cells, without waveforms, spikecounts or spikerates.
eu = EphysUnit.load('C:\SERVER\Units\Lite_NonDuplicate');
ar = AcuteRecording.load('C:\SERVER\Acute\AcuteRecording');

% 1.3 AnimalInfo
animalInfo = { ...
%     'daisy1', 'wt', 'F', -3.2, -1.6, 'tetrode'; ...
    'daisy2', 'wt', 'F', -3.2, +1.6, 'tetrode'; ...
    'daisy3', 'DAT-Cre', 'F', -3.2, +1.6, 'tetrode'; ...
    'desmond10', 'wt', 'M', -3.28, -1.8, 'double-bundle'; ... % -0.962 for other bunder
    'desmond11', 'wt', 'M', -3.28, +1.8, 'double-bundle'; ... % +0.962 for other bunder
    'daisy4', 'D1-Cre', 'F', -3.28, -1.6, 'bundle'; ...
    'daisy5', 'D1-Cre', 'F', -3.28, +1.6, 'bundle'; ...
    'desmond12', 'DAT-Cre', 'M', -3.2, -1.4, 'bundle'; ...
    'desmond13', 'DAT-Cre', 'M', -3.2, +1.4, 'bundle'; ...
    'desmond15', 'wt', 'M', -3.40, -1.5, 'bundle'; ...
    'desmond16', 'wt', 'M', -3.40, +1.5, 'bundle'; ...
    'desmond17', 'wt', 'M', -3.40, +1.5, 'bundle'; ...
    'desmond18', 'wt', 'M', -3.40, +1.5, 'bundle'; ...
    'desmond20', 'A2A-Cre', 'M', -3.28, +1.6, 'bundle'; ...
    'daisy7', 'A2A-Cre', 'F', -3.28, +1.6, 'bundle'; ...
    'desmond21', 'D1-Cre;Dlx-Flp;Ai80', 'M', -3.28, -1.6, 'bundle'; ...
    'desmond22', 'D1-Cre;Dlx-Flp;Ai80', 'M', -3.28, -1.6, 'bundle'; ...
    'daisy8', 'D1-Cre;Dlx-Flp;Ai80', 'F', -3.28, +1.6, 'bundle'; ...
    'daisy9', 'D1-Cre;Dlx-Flp;Ai80', 'F', -3.28, +1.3, '4shank-neuronexus'; ... % 1.3 = center of 4 shanks -4.8DV tip 900um? wide
    'daisy10', 'D1-Cre;Dlx-Flp;Ai80', 'F', -3.28, -1.3, '4shank-neuronexus'; ... % 1.3 = center of 4 shanks -4.8DV tip 900um? wide
    'daisy12', 'wt', 'F', -3.28, +1.3, '4shank-acute-wide'; ... % 1.3 = center of 4 shanks -4.4DV tip 990um? wide
    'daisy13', 'wt', 'F', -3.28, -1.3, '4shank-acute-wide'; ... % 1.3 = center of 4 shanks -4.2DV tip 990um? wide
    'desmond23', 'D1-Cre;Dlx-Flp;Ai80', 'M', -3.28, -1.3, '4shank-acute'; ... % 1.3 = center of 4 shanks, 450um wide
    'daisy14', 'D1-Cre;Dlx-Flp;Ai80', 'F', -3.28, +1.3, '4shank-acute'; ... % 1.3 = center of 4 shanks
    'desmond24', 'A2A-Cre', 'M', -3.28, +1.3, '4shank-acute'; ... % 1.3 = center of 4 shanks
    'desmond25', 'A2A-Cre', 'M', -3.28, -1.3, '4shank-acute'; ... % 1.3 = center of 4 shanks
    'daisy15', 'A2A-Cre', 'F', -3.28, +1.3, '4shank-acute'; ... % 1.3 = center of 4 shanks
    'daisy16', 'A2A-Cre', 'F', -3.28, -1.3, '4shank-acute'; ... % 1.3 = center of 4 shanks
    'desmond26', 'D1-Cre;Dlx-Flp;Ai80', 'M', -3.28, +1.3, '4shank-acute'; ... % 1.3 = center of 4 shanks
    'desmond27', 'D1-Cre;Dlx-Flp;Ai80', 'M', -3.28, -1.3, '4shank-acute'; ... % 1.3 = center of 4 shanks
    };

ai(size(animalInfo, 1)) = struct('name', '', 'strain', '', 'sex', '', 'ap', [], 'ml', [], 'probe', '');
for i = 1:size(animalInfo, 1)
    ai(i).name = animalInfo{i, 1};
    ai(i).strain = animalInfo{i, 2};
    ai(i).sex = animalInfo{i, 3};
    ai(i).ap = animalInfo{i, 4};
    ai(i).ml = animalInfo{i, 5};
    ai(i).probe = animalInfo{i, 6};
end

% 2.1 Parameters
clear p
p.minSpikeRate = 15;
p.minTrialDuration = 2;
p.minNumTrials = 30;
p.etaNorm = [-4, -2];
p.etaWindow = [-4, 2];
p.metaWindowPress = [-0.5, -0.2];
p.metaWindowLick = [-0.3, 0];
p.posRespThreshold = 1;
p.negRespThreshold = -0.5;
p.binnedTrialEdges = 2:2:10;

p.minStimDuration = 1e-2;
p.maxStimDuration = 5e-2;
p.errStimDuration = 1e-3;
p.allowAltStimDuration = true;
p.etaWindowStim = [-0.2, 0.5];
p.metaWindowStim = [0, 0.1];


% %% 2.2.1 Cull non-SNr units to save memory (only once)
% msr = arrayfun(@(stats) stats.medianITI, [eu.SpikeRateStats]);
% isSNr = msr >= p.minSpikeRate;
% eu = eu(isSNr);
% fprintf(1, 'Kept %g out of %g SNr units with spike rate >= %g.\n', nnz(isSNr), length(msr), p.minSpikeRate)
% clearvars -except eu p ai

% Multiunit detection by ISI.
p.ISIThreshold = 0.0015;
for iEu = 1:length(eu)
    st = eu(iEu).SpikeTimes;
    isi = [NaN, diff(st)];
    st(isi == 0) = [];
    isi = [NaN, diff(st)];
    eu(iEu).SpikeTimes = st;
    ISI{iEu} = isi;
end

for iEu = 1:length(eu)
    prcLowISI(iEu) = nnz(ISI{iEu} < p.ISIThreshold) ./ length(ISI{iEu});
end
histogram(prcLowISI, 0:0.01:1)
c.isMultiUnit = prcLowISI > 0.05;
c.isSingleUnit = prcLowISI <= 0.05;
euAll = eu;
eu = euAll(c.isSingleUnit);

% Find location of units from AR
euPos = NaN(length(eu), 3); % ml dv ap
c.hasPos = false(1, length(eu));
for iEu = 1:length(eu)
    iAr = find(strcmpi(eu(iEu).ExpName, {ar.expName}));
    if ~isempty(iAr)
        euPos(iEu, :) = ar(iAr).getProbeCoords(eu(iEu).Channel);
        c.hasPos(iEu) = true;
    end
end




% 2.3.1  Basic summaries
% Baseline (median) spike rates
msr = arrayfun(@(stats) stats.medianITI, [eu.SpikeRateStats]);

% Lick/Press responses
% eta.press = eu.getETA('count', 'press', p.etaWindow, minTrialDuration=p.minTrialDuration, normalize=p.etaNorm);
% eta.lick = eu.getETA('count', 'lick', p.etaWindow, minTrialDuration=p.minTrialDuration, normalize=p.etaNorm);
% eta.pressRaw = eu.getETA('count', 'press', p.etaWindow, minTrialDuration=p.minTrialDuration, normalize='none');
% eta.lickRaw = eu.getETA('count', 'lick', p.etaWindow, minTrialDuration=p.minTrialDuration, normalize='none');
% 
% meta.press = transpose(mean(eta.press.X(:, eta.press.t >= p.metaWindowPress(1) & eta.press.t <= p.metaWindowPress(2)), 2, 'omitnan'));
% meta.lick = transpose(mean(eta.lick.X(:, eta.lick.t >= p.metaWindowLick(1) & eta.lick.t <= p.metaWindowLick(2)), 2, 'omitnan'));
% meta.pressRaw = transpose(mean(eta.pressRaw.X(:, eta.pressRaw.t >= p.metaWindowPress(1) & eta.pressRaw.t <= p.metaWindowPress(2)), 2, 'omitnan'));
% meta.lickRaw = transpose(mean(eta.lickRaw.X(:, eta.lickRaw.t >= p.metaWindowLick(1) & eta.lickRaw.t <= p.metaWindowLick(2)), 2, 'omitnan'));


% 2.3.2 Basic summaries (fast)
% hasPress/hasLick
c.hasPress = arrayfun(@(e) nnz(e.getTrials('press').duration() >= p.minTrialDuration) >= p.minNumTrials, eu);
c.hasLick = arrayfun(@(e) nnz(e.getTrials('lick').duration() >= p.minTrialDuration) >= p.minNumTrials, eu);

% animal info
c.isWT = arrayfun(@(eu) strcmpi(getAnimalInfo(eu, ai, 'strain'), 'wt'), eu);
c.isD1 = arrayfun(@(eu) strcmpi(getAnimalInfo(eu, ai, 'strain'), 'd1-cre'), eu);
c.isA2A = arrayfun(@(eu) strcmpi(getAnimalInfo(eu, ai, 'strain'), 'a2a-cre'), eu);
c.isAi80 = arrayfun(@(eu) strcmpi(getAnimalInfo(eu, ai, 'strain'), 'd1-cre;dlx-flp;ai80'), eu);
c.isDAT = arrayfun(@(eu) strcmpi(getAnimalInfo(eu, ai, 'strain'), 'dat-cre'), eu);
c.isAcute = ismember(eu.getAnimalName, {'daisy14', 'daisy15', 'daisy16', 'desmond23', 'desmond24', 'desmond25', 'desmond26', 'desmond27'});


% Use bootstraping to find significant movement responses
clear boot
p.bootAlpha = 0.01;
boot.press = struct('h', NaN(length(eu), 1), 'muDiffCI', NaN(length(eu), 2), 'muDiffObs', NaN(length(eu), 1));
boot.lick = struct('h', NaN(length(eu), 1), 'muDiffCI', NaN(length(eu), 2), 'muDiffObs', NaN(length(eu), 1));
[boot.press.h(c.hasPress), boot.press.muDiffCI(c.hasPress, :), boot.press.muDiffObs(c.hasPress)] = bootstrapMoveResponse( ...
    eu(c.hasPress), 'press', alpha=p.bootAlpha, withReplacement=false, oneSided=false, ...
    responseWindow=[-0.5, -0.2]);
[boot.lick.h(c.hasLick), boot.lick.muDiffCI(c.hasLick, :), boot.lick.muDiffObs(c.hasLick)] = bootstrapMoveResponse( ...
    eu(c.hasLick), 'lick', alpha=p.bootAlpha, withReplacement=false, oneSided=false, ...
    responseWindow=[-0.3, 0]);
fprintf(1, '\nAll done\n')

% Report bootstraped movement response direction
assert(nnz(isnan(boot.lick.h(c.hasLick))) == 0)
assert(nnz(isnan(boot.press.h(c.hasPress))) == 0)

figure, histogram(boot.press.h)
c.isPressUp = boot.press.h' == 1 & c.hasPress;
c.isPressDown = boot.press.h' == -1 & c.hasPress;
c.isPressResponsive = c.isPressUp | c.isPressDown;

figure, histogram(boot.lick.h)
c.isLickUp = boot.lick.h' == 1 & c.hasLick;
c.isLickDown = boot.lick.h' == -1 & c.hasLick;
c.isLickResponsive = c.isLickUp | c.isLickDown;

fprintf(1, ['%g total SNr units (baseline spike rate > %g):\n' ...
    '\t%g with %d+ press trials;\n' ...
    '\t%g with %d+ lick trials;\n' ...
    '\t%g with either (%g+ trials);\n' ...
    '\t%g with both (%g+ trials).\n'], ...
    length(eu), p.minSpikeRate, nnz(c.hasPress), p.minNumTrials, ...
    nnz(c.hasLick), p.minNumTrials, ...
    nnz(c.hasPress | c.hasLick), p.minNumTrials, ...
    nnz(c.hasPress & c.hasLick), p.minNumTrials)

fprintf(1, ['%g units with %g+ press trials (%gs or longer):\n' ...
    '\t%g (%.0f%%) are excited (p<%g);\n' ...
    '\t%g (%.0f%%) are inhibited (p<%g).\n'], ...
    nnz(c.hasPress), p.minNumTrials, p.minTrialDuration, ...
    nnz(c.isPressUp), 100*nnz(c.isPressUp)/nnz(c.isPressResponsive), p.bootAlpha, ...
    nnz(c.isPressDown), 100*nnz(c.isPressDown)/nnz(c.isPressResponsive), p.bootAlpha);

fprintf(1, ['%g units with %g+ lick trials (%gs or longer):\n' ...
    '\t%g (%.0f%%) are excited (p<%g);\n' ...
    '\t%g (%.0f%%) are inhibited (p<%g).\n'], ...
    nnz(c.hasLick), p.minNumTrials, p.minTrialDuration, ...
    nnz(c.isLickUp), 100*nnz(c.isLickUp)/nnz(c.isLickResponsive), p.bootAlpha, ...
    nnz(c.isLickDown), 100*nnz(c.isLickDown)/nnz(c.isLickResponsive), p.bootAlpha);

nTotal = nnz(c.isPressResponsive & c.isLickResponsive);
fprintf(1, ['%g units with %d+ press AND lick trials (%gs or longer):\n' ...
    '\t%g (%.0f%%) are press-excited AND lick-excited;\n' ...
    '\t%g (%.0f%%) are press-inhibited AND lick-inhibited;\n' ...
    '\t%g (%.0f%%) are press-excited AND lick-inhibited;\n' ...
    '\t%g (%.0f%%) are press-inhibited AND lick-excited;\n'], ...
    nnz(c.hasPress & c.hasLick), p.minNumTrials, p.minTrialDuration, ...
    nnz(c.isPressUp & c.isLickUp), 100*nnz(c.isPressUp & c.isLickUp)/nTotal, ...
    nnz(c.isPressDown & c.isLickDown), 100*nnz(c.isPressDown & c.isLickDown)/nTotal, ...
    nnz(c.isPressUp & c.isLickDown), 100*nnz(c.isPressUp & c.isLickDown)/nTotal, ...
    nnz(c.isPressDown & c.isLickUp), 100*nnz(c.isPressDown & c.isLickUp)/nTotal)   

clear animalInfo i euAll iEu iAr st isi ISI

%%
function info = getAnimalInfo(eu, ai, field)
    i = find(strcmpi({ai.name}, eu.getAnimalName()));
    assert(length(i) == 1, eu.getAnimalName())
    info = ai(i).(field);
end

function [h, muDiffCI, muDiffObs] = bootstrapMoveResponse(eu, trialType, varargin)
    p = inputParser();
    p.addRequired('eu', @(x) length(x) >= 1 && isa(x, 'EphysUnit'));
    p.addRequired('trialType', @(x) ismember(x, {'press', 'lick'}));
    p.addParameter('nboot', 10000, @isnumeric)
    p.addParameter('baselineWindow', [-4, -2], @(x) isnumeric(x) && length(x) == 2)
    p.addParameter('responseWindow', [-0.5, -0.2], @(x) isnumeric(x) && length(x) == 2)
    p.addParameter('alignTo', 'stop', @(x) ischar(x) && ismember(lower(x), {'start', 'stop'}))
    p.addParameter('allowedTrialDuration', [2, Inf], @(x) isnumeric(x) && length(x) >= 2 && x(2) >= x(1))
    p.addParameter('trialDurationError', 1e-3, @isnumeric) % Used for opto, error allowed when finding identical trial durations.
    p.addParameter('alpha', 0.01, @isnumeric)
    p.addParameter('withReplacement', false, @islogical)
    p.addParameter('oneSided', false, @islogical)
    p.parse(eu, trialType, varargin{:});
    r = p.Results;
    eu = r.eu;

    dataWindow = [min(r.baselineWindow(1), r.responseWindow(1)), max(r.baselineWindow(2), r.responseWindow(2))];

    h = NaN(length(eu), 1);
    p = h;
    muDiffCI = NaN(length(eu), 2);
    muDiffObs = NaN(length(eu), 1);
    for iEu = 1:length(eu)
        fprintf(1, '%d/%d ', iEu, length(eu))
        if mod(iEu, 15) == 0
            fprintf(1, '\n')
        end

        [sr, t] = eu(iEu).getTrialAlignedData('count', dataWindow, r.trialType, alignTo=r.alignTo, ...
            allowedTrialDuration=r.allowedTrialDuration, trialDurationError=r.trialDurationError, ...
            includeInvalid=false, resolution=0.1);

        if isempty(sr)
            warning('Spike rate for %d - %s is empty.', iEu, eu(iEu).getName('_'));
            continue
        end
    
        response = mean(sr(:, t >= r.responseWindow(1) & t <= r.responseWindow(2)), 2, 'omitnan');
        nBins = nnz(t >= r.responseWindow(1) & t <= r.responseWindow(2));
        baselineSampleIndices = find(t >= r.baselineWindow(1) & t <= r.baselineWindow(2));
        baselineSampleIndices = baselineSampleIndices((1:nBins) + flip(length(baselineSampleIndices)-nBins:-nBins:0)');
        baseline = NaN(size(sr, 1), size(baselineSampleIndices, 1));
        for i = 1:size(baselineSampleIndices, 1)
            baseline(:, i) = mean(sr(:, baselineSampleIndices(i, :)), 2);
        end
        baseline = baseline(:);
        combined = [baseline; response];
        nBase = length(baseline);
        
        % With replacement
        if r.withReplacement
            [~, bsample] = bootstrp(r.nboot, [], combined);
        else
            bsample = zeros(length(combined), r.nboot);
            for iboot = 1:r.nboot
                bsample(:, iboot) = randperm(length(combined));
            end
        end
        baselineSamples = combined(bsample(1:nBase, :));
        responseSamples = combined(bsample(nBase+1:end, :));
        muDiffObs(iEu) = mean(response, 'omitnan') - mean(baseline, 'omitnan');
        if muDiffObs(iEu) > 0
            direction = 1;
        else
            direction = -1;
        end
        muDiffBoot = mean(responseSamples, 1, 'omitnan') - mean(baselineSamples, 1, 'omitnan');
        if r.oneSided
            if direction == 1
                muDiffCI(iEu, :) = prctile(muDiffBoot, [0, 100 - r.alpha*100]);
            elseif direction == -1
                muDiffCI(iEu, :) = prctile(muDiffBoot, [r.alpha*100, 100]);
            end
        else
            muDiffCI(iEu, :) = prctile(muDiffBoot, [r.alpha*50, 100 - r.alpha*50]);
        end
        if direction == 1
            h(iEu) = muDiffObs(iEu) > muDiffCI(iEu, 2);
        elseif direction == -1
            h(iEu) = -(muDiffObs(iEu) < muDiffCI(iEu, 1));
        end
%         if muDiffObs(iEu) > muDiffCI(iEu, 2)
%             h(iEu) = 1;
%         elseif muDiffObs(iEu) < muDiffCI(iEu, 1)
%             h(iEu) = -1;
%         else
%             h(iEu) = 0;
%         end
    end
end
