
%% 1.1. Load acute EU objects (duplicates already removed)
eu = EphysUnit.load('C:\SERVER\Units\acute_2cam'); 
%%
% Remove multiunit detected by ISI test.
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
cat.isMultiUnit = prcLowISI > 0.05;
cat.isSingleUnit = prcLowISI <= 0.05;
eu = eu(cat.isSingleUnit);
clearvars -except p eu

eu = eu(:)';

%%
% 1.2. Load Video Tracking Data (vtd) and ArduinoConnection (ac), and group into experiments
exp = CompleteExperiment(eu);

% 1.3 Align video and ephys timestamps
exp.alignTimestamps();

%% 1.3 AnimalInfo
animalInfo = { ...
    'daisy1', 'wt', 'F', -3.2, -1.6, 'tetrode'; ...
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
p.etaWindow = [-4, 0];
p.metaWindow = [-0.2, 0];
p.posRespThreshold = 1;
p.negRespThreshold = -0.5;
p.binnedTrialEdges = 2:2:10;

p.minStimDuration = 1e-2;
p.maxStimDuration = 5e-2;
p.errStimDuration = 1e-3;
p.allowAltStimDuration = true;
p.etaWindowStim = [-0.2, 0.5];
p.metaWindowStim = [0, 0.1];

%%
msr = arrayfun(@(stats) stats.medianITI, [eu.SpikeRateStats]);

% Lick/Press responses
eta.press = eu.getETA('count', 'press', p.etaWindow, minTrialDuration=p.minTrialDuration, normalize=p.etaNorm);
meta.press = transpose(mean(eta.press.X(:, eta.press.t >= p.metaWindow(1) & eta.press.t <= p.metaWindow(2)), 2, 'omitnan'));
eta.lick = eu.getETA('count', 'lick', p.etaWindow, minTrialDuration=2, normalize=p.etaNorm);
meta.lick = transpose(mean(eta.lick.X(:, eta.lick.t >= p.metaWindow(1) & eta.lick.t <= p.metaWindow(2)), 2, 'omitnan'));

eta.pressRaw = eu.getETA('count', 'press', p.etaWindow, minTrialDuration=p.minTrialDuration, normalize='none');
meta.pressRaw = transpose(mean(eta.pressRaw.X(:, eta.pressRaw.t >= p.metaWindow(1) & eta.pressRaw.t <= p.metaWindow(2)), 2, 'omitnan'));

%% Get first significant arm movemetn befor trials
thetaRamp = 2.5;
[velocityKernels, ~, ~] = CompleteExperiment.makeConsineKernels(0, width=0.2, overlap=0.5, direction='both');

sto.pressSR = cell(1, length(exp));
sto.press = cell(1, length(exp));
sto.lick = cell(1, length(exp));
for iExp = 1:length(exp)
    disp(iExp)
    trials = exp(iExp).eu(1).getTrials('press');
    trueStartTime = NaN(length(trials), 1);
    srnStartTime = NaN(length(trials), length(exp(iExp).eu));
    for iTrial = 1:length(trials)
        t = trials(iTrial).Start:1/30:trials(iTrial).Stop;
        F = exp(iExp).getFeatures(timestamps=t, features={'handL', 'handR'}, stats={'xPos', 'yPos'});
        F = CompleteExperiment.convolveFeatures(F, velocityKernels, kernelNames={'_smooth'}, ...
            features={'handL', 'handR'}, ...
            stats={'xPos', 'yPos'}, ...
            mode='replace', normalize='maxabs');
        F.inTrial = [];
        F.t = [];
        F = normalize(F);
        data = table2array(F);
        trueStartIndex = find(all(abs(data) < thetaRamp, 2), 1, 'last');
        if ~isempty(trueStartIndex)
            trueStartTime(iTrial) = t(trueStartIndex) - t(end);
        end

        for iEuInExp = 1:length(exp(iExp).eu)
            thisETA = exp(iExp).eu(iEuInExp).getETA('count', 'press', p.etaWindow, minTrialDuration=p.minTrialDuration, normalize=p.etaNorm);
            thisMETA = transpose(mean(thisETA.X(:, thisETA.t >= p.metaWindow(1) & thisETA.t <= p.metaWindow(2)), 2, 'omitnan'));
            expectedSign = sign(thisMETA);
            expectedThreshold = thisMETA;
            sr = [NaN, eu(iEuInExp).getSpikeRates('gaussian', 0.1, t)]'; 
            srn = normalize(sr, 'zscore', 'robust');
            if expectedSign > 0
                srnStartIndex = find(srn > 0 & srn < expectedThreshold, 1, 'last');
            else
                srnStartIndex = find(srn < 0 & srn > expectedThreshold, 1, 'last');
            end
            if ~isempty(srnStartIndex)
                srnStartTime(iTrial, iEuInExp) = t(srnStartIndex) - t(end);
            end
        end

    end
    sto.press{iExp} = trueStartTime;
    sto.pressSR{iExp} = srnStartTime;

    trials = exp(iExp).eu(1).getTrials('lick');
    trueStartTime = NaN(1, length(trials));
    for iTrial = 1:length(trials)
        t = trials(iTrial).Start:1/30:trials(iTrial).Stop;
        F = exp(iExp).getFeatures(timestamps=t, features={'handL', 'handR'}, stats={'xPos', 'yPos'});
        F = CompleteExperiment.convolveFeatures(F, velocityKernels, kernelNames={'_smooth'}, ...
            features={'handL', 'handR'}, ...
            stats={'xPos', 'yPos'}, ...
            mode='replace', normalize='maxabs');
        F.inTrial = [];
        F.t = [];
        F = normalize(F);
        data = table2array(F);
        trueStartIndex = find(all(abs(data) < thetaRamp, 2), 1, 'last');
        if ~isempty(trueStartIndex)
            trueStartTime(iTrial) = t(trueStartIndex) - t(end);
        end
    %     lclips = exp(i).getVideoClip(trueStartTime, side='l', numFramesBefore=30);
    %     rclips = exp(i).getVideoClip(trueStartTime, side='r', numFramesBefore=30);
    %     implay(lclips, 30)
    %     implay(rclips, 30)
        % plot(F.t - F.t(end), table2array(F(:, {'handL_xVel', 'handL_yVel', 'handR_xVel', 'handR_yVel'})))
    end
    sto.lick{iExp} = trueStartTime;
end

%%
figure(DefaultAxesFontSize=14)
ax = subplot(2, 1, 1);
tst = cat(1, sto.press{:});
histogram(-tst, 0:0.05:1, FaceColor="auto", Normalization='probability')
xlabel('Limb movement duration (s)')
ylabel('Probability')
legend(sprintf('%g trials, %g animals', length(tst), length(exp)))
title('Lever-press trials')

ax = subplot(2, 1, 2);
tst = cat(2, sto.lick{:});
histogram(-tst, 0:0.05:1, FaceColor="auto", Normalization='probability')
xlabel('Limb movement duration (s)')
ylabel('Probability')
legend(sprintf('%g trials, %g animals', length(tst), length(exp)))
title('Lick trials')
%%
for iExp = 1:length(sto.pressSR)
    sto.pressSRMean{iExp} = mean(sto.pressSR{iExp}, 2, 'omitnan');
end
rampDuration = -cat(1, sto.pressSRMean{:});
pressDuration = -cat(1, sto.press{:});
scatter(rampDuration, pressDuration)
corr(rampDuration, pressDuration)

%% 
% c = cat;
% clear cat;

thetaPos = 1;
thetaNeg = -0.5;
overTheta = abs(eta.press.X) > thetaRamp;
for iEu = 1:size(overTheta, 1)
    if c.isPressUp(iEu)
        pressRampStart(iEu) = eta.press.t(find(eta.press.X(iEu, :) < thetaPos, 1, 'last'));
    elseif c.isPressDown(iEu)
        pressRampStart(iEu) = eta.press.t(find(eta.press.X(iEu, :) > thetaNeg, 1, 'last'));
    else
        pressRampStart(iEu) = NaN;
    end
end

figure(DefaultAxesFontSize=14)
ax = subplot(2, 1, 1);
tst = cat(1, sto.press{:});
histogram(tst, -2:0.1:0, FaceColor="auto", Normalization='probability')
ylabel('Probability')
legend(sprintf('%g trials, %g animals', length(tst), length(unique(exp.animalName))))
title('Limb movement onset latency')

ax = subplot(2, 1, 2);
histogram(pressRampStart(c.isPressUp | c.isPressDown), -2:0.1:0, FaceColor="auto", Normalization='probability')
xlabel('Time relative to lever-touch (s)')
ylabel('Probability')
legend(sprintf('%g neurons, %g animals', length(pressRampStart(c.isPressUp | c.isPressDown)), length(unique(eu(c.isPressUp | c.isPressDown).getAnimalName))))
title('Neural activity onset latency')
