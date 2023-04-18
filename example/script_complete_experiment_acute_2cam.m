%% Create EphysUnit objects for acute units. This time do not cull ITI 
% spikes, also include lampON/Off events as LIGHT trials. Duplicates are
% not included.

% clear
% 
% whitelist = dir('C:\SERVER\Units\Lite_NonDuplicate\*.mat');
% whitelist = {whitelist.name}';
% whitelist = cellfun(@(x) strsplit(x, '.mat'), whitelist, UniformOutput=false);
% whitelist = cellfun(@(x) x{1}, whitelist, UniformOutput=false);
% 
% ar = AcuteRecording.load();
% for i = 1:length(ar)
%     clear eu
%     try  
%         eu = EphysUnit(ar(i), savepath='C:\SERVER\Units\acute_2cam', whitelist=whitelist, ...
%             cullITI=false, readWaveforms=false);
%     catch ME
%         warning('Error while processing file %g (%s)', i, ar(i).expName);
%     end
% end

p.fontSize = 9;

%% 1. Load data
%% 1.1. Load acute EU objects (duplicates already removed)
eu = EphysUnit.load('C:\SERVER\Units\acute_2cam'); 

%% Remove multiunit detected by ISI test.
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

eu = eu';

%%
% 1.2. Load Video Tracking Data (vtd) and ArduinoConnection (ac), and group into experiments
clearvars -except eu
exp = CompleteExperiment(eu);

% 1.3 Align video and ephys timestamps
exp.alignTimestamps();

%% Get first significant arm movement befor trials
theta = 1;
% thetaPrct = 0.1;
[velocityKernels, ~, ~] = CompleteExperiment.makeConsineKernels(0, width=0.1, overlap=0.5, direction='both');

TST = cell(1, length(exp));
for iExp = 1:length(exp)
    disp(iExp)
    trials = exp(iExp).eu(1).getTrials('press');
    trials = trials(trials.duration >= p.minTrialLength);
    trueStartTime = NaN(1, length(trials));
    for iTrial = 1:length(trials)
        t = trials(iTrial).Start:1/30:trials(iTrial).Stop;
        F = exp(iExp).getFeatures(timestamps=t, features={sprintf('hand%s', leverSide(iExp))}, stats={'xPos', 'yPos'});
        F = CompleteExperiment.convolveFeatures(F, velocityKernels, kernelNames={'_smooth'}, ...
            features={sprintf('hand%s', leverSide(iExp))}, ...
            stats={'xPos', 'yPos'}, ...
            mode='replace', normalize='maxabs');
        F.inTrial = [];
        F.t = [];
        F = normalize(F);
        data = flip(table2array(F), 1);
        isAbove = abs(data) >= theta;
%         isAbove = abs(data) >= abs(data(1, :)) * thetaPrct;
        isAboveConseq = any(isAbove & [0, 0; diff(isAbove)] == 0, 2);
        t = flip(t);
        t = t - t(1);
        trueStartIndex = find(~isAboveConseq, 1, 'first') - 1;
        if ~isempty(trueStartIndex)
            trueStartTime(iTrial) = t(max(trueStartIndex, 1));
        end
%         close all
%         plot(t, data, 'r')
%         hold('on')
%         plot(t, isAboveConseq, 'g')
%         plot([trueStartTime(iTrial), trueStartTime(iTrial)], [-4, 4], 'k:')
    %     lclips = exp(i).getVideoClip(trueStartTime, side='l', numFramesBefore=30);
    %     rclips = exp(i).getVideoClip(trueStartTime, side='r', numFramesBefore=30);
    %     implay(lclips, 30)
    %     implay(rclips, 30)
        % plot(F.t - F.t(end), table2array(F(:, {'handL_xVel', 'handL_yVel', 'handR_xVel', 'handR_yVel'})))
    end
    TST{iExp} = trueStartTime;
end

%%
theta = 0.25;
% thetaPrct = 0.1;
[velocityKernels, ~, ~] = CompleteExperiment.makeConsineKernels(0, width=0.1, overlap=0.5, direction='both');

TST = cell(1, length(exp));
for iExp = 1:length(exp)
    disp(iExp)
    trials = exp(iExp).eu(1).getTrials('press');
    trials = trials(trials.duration >= p.minTrialLength);
    trueStartTime = NaN(1, length(trials));
    for iTrial = 1:length(trials)
        t = trials(iTrial).Start:1/30:trials(iTrial).Stop;
        F = exp(iExp).getFeatures(timestamps=t, features={sprintf('hand%s', leverSide(iExp))}, stats={'spd'});
        F = CompleteExperiment.convolveFeatures(F, velocityKernels, kernelNames={'_smooth'}, ...
            features={sprintf('hand%s', leverSide(iExp))}, ...
            stats={'spd'}, ...
            mode='replace', normalize='maxabs');
        F.inTrial = [];
        F.t = [];
        F = normalize(F);
        data = flip(table2array(F), 1);
        isAbove = abs(data) >= theta;
%         isAbove = abs(data) >= abs(data(1, :)) * thetaPrct;
        isAboveConseq = any(isAbove & [0; diff(isAbove)] == 0, 2);
        t = flip(t);
        t = t - t(1);
        trueStartIndex = find(~isAboveConseq, 1, 'first') - 1;
        if ~isempty(trueStartIndex)
            trueStartTime(iTrial) = t(max(trueStartIndex, 1));
        end
%         close all
%         plot(t, data, 'r')
%         hold('on')
%         plot(t, isAboveConseq, 'g')
%         plot([trueStartTime(iTrial), trueStartTime(iTrial)], [-4, 4], 'k:')
    %     lclips = exp(i).getVideoClip(trueStartTime, side='l', numFramesBefore=30);
    %     rclips = exp(i).getVideoClip(trueStartTime, side='r', numFramesBefore=30);
    %     implay(lclips, 30)
    %     implay(rclips, 30)
        % plot(F.t - F.t(end), table2array(F(:, {'handL_xVel', 'handL_yVel', 'handR_xVel', 'handR_yVel'})))
    end
    TST{iExp} = trueStartTime;
end

%%
close all
figure(DefaultAxesFontSize=11, Position=[200,200,600,300])
tst = cat(2, TST{:});
histogram(tst, -2:0.1:0, FaceColor="auto", Normalization='probability')
xlabel('Time to lever-contact (s)')
ylabel('Probability')
legend(sprintf('%g trials, %g sessions', nnz(~isnan(tst)), length(exp)), Location='northwest')
title('Contralateral forepaw movement onset latency')

% clearvars -except eu exp TST
    
%% 1.4 Get video clips around event times to verify stuff
i = 9;
eventTimes = exp(i).getEventTimestamps('Press');
eventTimes = eventTimes(1);%randi(length(eventTimes)));
lclips = exp(i).getVideoClip(eventTimes, side='l', numFramesBefore=30);
rclips = exp(i).getVideoClip(eventTimes, side='r', numFramesBefore=30);
implay(lclips, 30)
implay(rclips, 30)

%% 2. Build GLM
clearvars -except exp

%% 2.1 Examine data
clearvars -except exp
close all
iExp = 1;
iEu = 1;
pTheta = 0.95;
bodyparts = {'handIpsi', 'footIpsi', 'spine', 'tail', 'nose', 'tongue'};

%% 2.1.1 Plot timecourse of velocity and position data, see if there are correlations (redundancies).
for ibp = 1:length(bodyparts)
    bp = bodyparts{ibp};
    posX = exp(iExp).vtdL.(sprintf('%s_X', bp));
    posY = exp(iExp).vtdL.(sprintf('%s_Y', bp));
    velX = [0; diff(posX)];
    velY = [0; diff(posY)];
    prob = exp(iExp).vtdL.(sprintf('%s_Likelihood', bp));
    isUncertain = prob < pTheta;
    velX(isUncertain) = NaN;
    velY(isUncertain) = NaN;
    posX(isUncertain) = NaN;
    posY(isUncertain) = NaN;


    fig = figure(Units='normalized', OuterPosition=[0.1, 0.2, 0.8, 0.6]);
    suptitle(bp)

    ax = subplot(2, 2, 1); hold on;
    t = exp(iExp).vtdL.Timestamp;
    xname = sprintf('%s_VelX', bp);
    yname = sprintf('%s_VelY', bp);
    plot(ax, t, velX, DisplayName=xname)
    plot(ax, t, velY, DisplayName=yname)
    xlabel(ax, 't', Interpreter='none')
    ylabel(ax, 'vel', Interpreter='none')
    legend(ax, Interpreter='none')
    hold off;
    
    ax = subplot(2, 2, 2);
    scatter(ax, velX, velY)
    xlabel(ax, xname, Interpreter='none')
    ylabel(ax, yname, Interpreter='none')


    ax = subplot(2, 2, 3); hold on;
    t = exp(iExp).vtdL.Timestamp;
    xname = sprintf('%s_X', bp);
    yname = sprintf('%s_Y', bp);
    plot(ax, t, posX, DisplayName=xname)
    plot(ax, t, posY, DisplayName=yname)
    xlabel(ax, 't', Interpreter='none')
    ylabel(ax, 'pos', Interpreter='none')
    legend(ax, Interpreter='none')
    hold off;
    
    ax = subplot(2, 2, 4);
    scatter(ax, posX, posY)
    xlabel(ax, xname, Interpreter='none')
    ylabel(ax, yname, Interpreter='none')
end
% clearvars -except exp iExp iEu bodyparts pTheta


%% 2.2 Fit GLMs
% clearvars -except exp
MDL = cell(length(exp), 1);
SRT = cell(length(exp), 1);
FT = cell(length(exp), 1);
TT = cell(length(exp), 1);
NOTNAN = cell(length(exp), 1);
% MASK = cell(length(exp), 1);

for iExp = 1:length(exp)
    F = exp(iExp).getFeatures(sampleRate=30, trialType={'press'}, stats={'xVel', 'yVel'}, ...
        features={'handL', 'handR', 'footL', 'footR', 'nose', 'spine', 'trialStart', 'pressTrialRamp', 'firstPressRamp'}, ...
        likelihoodThreshold=0.95);
%     [~, mask] = exp(iExp).maskFeaturesByTrial(F, NaN, 'press', [-1, 3], ...
%         features={'handL', 'handR', 'footL', 'footR', 'nose', 'spine'}, ...
%         stats={'xVel', 'yVel'}, replace=true);
    [velocityKernels, ~, velocityDelays] = CompleteExperiment.makeConsineKernels(4, width=0.1, overlap=0.5, direction='both');
    velocityDelays = round(velocityDelays * 1000);
    F = CompleteExperiment.convolveFeatures(F, velocityKernels, kernelNames=velocityDelays, ...
        features={'handL', 'handR', 'footL', 'footR', 'nose', 'spine'}, ...
        stats={'xVel', 'yVel'}, ...
        mode='replace', normalize='maxabs');

    [eventKernels, ~, eventDelays] = CompleteExperiment.makeConsineKernels(6, width=0.4, overlap=0.75, direction='both');
    eventDelays = round(eventDelays * 1000);
    F = CompleteExperiment.convolveFeatures(F, eventKernels, kernelNames=eventDelays, ...
        features={'trialStart'}, ...
        mode='replace', normalize='none');

    % Mask velocity predictors befor first movement


    t = F.t;
    inTrial = F.inTrial;
    F.t = [];
    F.inTrial = [];
    Ft = F(inTrial, :);
    tt = t(inTrial);
%     mask = mask(inTrial);


    Ft.constant = ones(height(Ft), 1);

    % Names of predictors
    % Cue and first move
    % Movement velocities
    % Trial-length ramping signals
    % Short pre-movement ramps
    names = Ft.Properties.VariableNames;
    cuePredictors = names(contains(names, {'trialStart'}))';
    velocityPredictors = names(contains(names, {'Vel'}))';
    rampPredictors = names(contains(names, {'firstPressRamp'}))';
    trialProgressPredictors = names(contains(names, 'TrialRamp'))';


    variantPredictors = { ...
        {'constant'}, ...
        [{'constant'}; cuePredictors], ...
        [{'constant'}; cuePredictors; velocityPredictors], ...
        [{'constant'}; cuePredictors; velocityPredictors; rampPredictors], ...
        [{'constant'}; cuePredictors; velocityPredictors; rampPredictors; trialProgressPredictors]};
    variantNames = {'Constant', '+Cue', '+Velocity', '+Ramp', '+Trial-progress'};
    nVariants = length(variantNames);
    
    % All nan if one nan
    notnan = all(~isnan(Ft(:, variantPredictors{end}).Variables), 2);
    prctNotNan = nnz(notnan) ./ height(Ft); 
    data = Ft.Variables;
    data(~notnan, :) = NaN;
    Ft.Variables = data;

    FT{iExp} = Ft;
    TT{iExp} = tt;

    % 2.3 Fit GLM
    % Grab a unit and start fitting glms!
    fprintf(1, 'Fitting %g modelsets...\n', length(exp(iExp).eu)); tTicAll = tic();
    mdl = cell(length(exp(iExp).eu), nVariants);
    srt = cell(length(exp(iExp).eu), 1);
    warning('off','all')
    for iEu = 1:length(exp(iExp).eu)
        fprintf(1, '\tFitting modelset %g of %g...\n', iEu, length(exp(iExp).eu)); tTic = tic();
        eu = exp(iExp).eu(iEu);
        srTrialAligned = [0, eu.getSpikeRates('gaussian', 0.1, t)]'; 
        srt{iEu} = srTrialAligned(inTrial);
    
        for iVariant = 1:nVariants
            thisF = Ft;
            thisF.SpikeRate = double(srt{iEu});
%             if strcmp(variantNames{iVariant}, '+PreMoveVel')
%                 thisF(mask, :) = [];
%             end
            mdl{iEu, iVariant} = fitglm(thisF, ResponseVar='SpikeRate', PredictorVars=variantPredictors{iVariant}, Distribution='poisson');
            fprintf(1, '\t\t%s R^2 = %.2f\n', variantNames{iVariant}, mdl{iEu, iVariant}.Rsquared.Ordinary);
        end

        % fprintf(1, '\tDone (%.0f%% not nan) in %.2f sec.\n', prctNotNan*100, toc(tTic));
    end
    warning('on','all')
    warning('query','all')
    fprintf(1, 'Fitted %g units in %.2f seconds.\n', length(exp(iExp).eu), toc(tTicAll));
    MDL{iExp} = cellfun(@compact, mdl, UniformOutput=false);
    SRT{iExp} = srt;
    NOTNAN{iExp} = notnan;
%     MASK{iExp} = mask;
end
mdl = cat(1, MDL{:});
srt = cat(1, SRT{:});
expIndices = zeros(size(mdl, 1), 1);
i = 0;
for iExp = 1:length(exp)
    expIndices(i + 1:i + length(exp(iExp).eu)) = iExp;
    i = i + length(exp(iExp).eu);
end
% clearvars -except exp mdl srt variantNames nVariants FT TT NOTNAN expIndices

% %% Estimate loss
% L = {};
% eu = [exp.eu];
% curExpIndex = -1;
% for iEu = 1:length(eu)
%     iExp = expIndices(iEu);
%     if curExpIndex ~= iEu
%         curExpIndex = iEu;
%         
%         F = exp(iExp).getFeatures(sampleRate=30, stats={'xVel', 'yVel'}, ...
%             features={'handL', 'handR', 'footL', 'footR', 'nose', 'spine' 'trialStart', 'firstPress', 'firstLick', 'pressTrialRamp', 'lickTrialRamp', 'firstPressRamp', 'firstLickRamp'}, ...
%             likelihoodThreshold=0.95);
%         [velocityKernels, ~, velocityDelays] = CompleteExperiment.makeConsineKernels(4, width=0.1, overlap=0.5, direction='both');
%         velocityDelays = round(velocityDelays * 1000);
%         F = CompleteExperiment.convolveFeatures(F, velocityKernels, kernelNames=velocityDelays, ...
%             features={'handL', 'handR', 'footL', 'footR', 'nose', 'spine'}, ...
%             stats={'xVel', 'yVel'}, ...
%             mode='replace', normalize='maxabs');
% 
%         [eventKernels, ~, eventDelays] = CompleteExperiment.makeConsineKernels(6, width=0.4, overlap=0.75, direction='both');
%         eventDelays = round(eventDelays * 1000);
%         F = CompleteExperiment.convolveFeatures(F, eventKernels, kernelNames=eventDelays, ...
%             features={'trialStart'}, ...
%             mode='replace', normalize='none');
%     
%         [eventKernels, ~, eventDelays] = CompleteExperiment.makeConsineKernels(6, width=0.4, overlap=0.75, direction='left');
%         eventDelays = round(eventDelays * 1000);
%         F = CompleteExperiment.convolveFeatures(F, eventKernels, kernelNames=eventDelays, ...
%             features={'firstPress', 'firstLick'}, ...
%             mode='replace', normalize='none');
%     end
% 
%     for iVariant = 1:nVariants
%         ll = loss(mdl(iEu, iVariant), )
%     end
% 
% end

%% Estimate model performance (R^2)

R2 = NaN(size(mdl));
for iEu = 1:size(mdl, 1)
    X = FT{expIndices(iEu)};
    y = srt{iEu};

    for iVariant = 1:nVariants
        yHat = predict(mdl{iEu, iVariant}, X, Simultaneous=true);
        sel = ~isnan(yHat) & ~isnan(y);
        R2(iEu, iVariant) = corr(yHat(sel), y(sel)) .^ 2;
    end
end

%% 2.3 Plot R^2 distribution for all units, compare different models.
edges = 0:0.05:1;
centers = (edges(1:end-1) + edges(2:end))*0.5;

fig = figure(Units='inches', Position=[0 0 6 2.25], DefaultAxesFontSize=12);

paramNames = {'Ordinary', 'Adjusted', 'AdjGeneralized', 'LLR', 'Deviance'};
np = length(paramNames);

clear ax
np = 1;
for ip = 1:np
    ax = subplot(np, 2, 2*(ip-1)+1);
    hold(ax, 'on')
    for iVariant = 2:nVariants
        N = histcounts(R2(:, iVariant), edges, Normalization='probability');
        plot(ax, edges, [0, cumsum(N)], Color=getColor(iVariant-1, nVariants-1), LineWidth=1.5, DisplayName=variantNames{iVariant})
    end
%     xlabel(sprintf('R^2 %s', paramNames{ip}))
    xlabel('R^2')
    ylabel('Cumulative probability')
    legend(ax, Location='southeast');
    hold(ax, 'off')
    ax.FontSize = p.fontSize;

    ax = subplot(np, 2, 2*(ip-1)+2);
    hold(ax, 'on')
    dR2 = diff(R2, 1, 2);

    x = repmat(1:nVariants-1, [size(dR2, 1), 1]);
    x = x(:);
    y = dR2(:);
    swarmchart(ax, x, y, 1, 'filled', 'k')
    
    boxplot(ax, dR2, Symbol='.', OutlierSize=0.000001, Color='k', Whisker=0)
    
    xticks(ax, 1:nVariants-1)
    xticklabels(ax, variantNames(2:end))
    xtickangle(ax, 315)
    ylabel('\DeltaR^2')
    ylim(ax, [0, max(y)+0.01])
    xlim(ax, [0,nVariants])
    ax.FontSize = p.fontSize;
end

%% Calculate trial-average fitted vs. observed for all units
eu = vertcat(exp.eu);
p.minSpikeRate = 15;
p.minTrialDuration = 2;
p.minNumTrials = 30;
p.etaNorm = [-4, -2];
p.etaWindow = [-4, 2];
p.metaWindowPress = [-0.5, -0.2];
p.metaWindowLick = [-0.3, 0];
p.posRespThreshold = 1;
p.negRespThreshold = -0.5;

c.hasPress = arrayfun(@(e) nnz(e.getTrials('press').duration() >= p.minTrialDuration) >= p.minNumTrials, eu)';
c.hasLick = arrayfun(@(e) nnz(e.getTrials('lick').duration() >= p.minTrialDuration) >= p.minNumTrials, eu)';

% RUN eu_analysis_4_movement %%4
% to bootstrap significantly movement-modulated units


% ax = axes(figure()); hold on;

assert(length(eu) > 1)
msr = cell(length(eu), 1);
msrHat = cell(length(eu), 1);
peak = NaN(length(eu), 1);
tPeak = NaN(length(eu), 1);
tOnset = NaN(length(eu), 1);
peakHat = NaN(length(eu), nVariants);
tPeakHat = NaN(length(eu), nVariants);
tOnsetHat = NaN(length(eu), nVariants);
for iEu = 1:length(eu)
    iExp = expIndices(iEu);
    tt = TT{iExp};
    Ft = FT{iExp};

    srtHat = NaN(height(Ft), size(mdl, 2));
    for iVariant = 2:size(mdl, 2)
        srtHat(:, iVariant) = predict(mdl{iEu, iVariant}, Ft);
    end

    trials = exp(iExp).eu(1).getTrials('press');

    maxTrialSampleLength = 0;
    for iTrial = 1:length(trials)
        inTrial = tt >= trials(iTrial).Start & tt <= trials(iTrial).Stop;
        maxTrialSampleLength = max(maxTrialSampleLength, nnz(inTrial));
    end

    srTrialAligned = NaN(length(trials), maxTrialSampleLength);
    srTrialAlignedHat = NaN(length(trials), maxTrialSampleLength, size(mdl, 2));
    for iTrial = 1:length(trials)
        inTrial = tt >= trials(iTrial).Start & tt <= trials(iTrial).Stop;
        trialSampleLength = nnz(inTrial);
        srTrialAligned(iTrial, maxTrialSampleLength - trialSampleLength + 1:end) = srt{iEu}(inTrial);
        for iVariant = 2:size(mdl, 2)
            srTrialAlignedHat(iTrial, maxTrialSampleLength - trialSampleLength + 1:end, iVariant) = srtHat(inTrial, iVariant);
        end
    end

    % Trial aligned mean spike rate
    t = (-maxTrialSampleLength + 1:0)*median(diff(tt));
    selT = t >= -4;
    t = t(selT);
    msr{iEu} = mean(srTrialAligned(:, selT), 1, 'omitnan');
    msrHat{iEu} = squeeze(mean(srTrialAlignedHat(:, selT, :), 1, 'omitnan'));

    % Onset/peak of trial-averaged msr/msrHat
    [peak(iEu), tPeak(iEu), tOnset(iEu), mu, sd] = getPeakAndOnset(srTrialAligned(:, selT), t);
    assert(~isnan(peak(iEu)))

    for iVariant = 2:size(mdl, 2)
        [peakHat(iEu, iVariant), tPeakHat(iEu, iVariant), tOnsetHat(iEu, iVariant)] = ...
            getPeakAndOnset(srTrialAlignedHat(:, selT, iVariant), t, mu=mu, sd=sd);
    end
% 
%     if ismember(iEu, find(c.isPressResponsive))
%         cla(ax);
%         plot(t, msr{iEu}, 'k:');
%         ylim('auto')
%         yl = ax.YLim;
%         plot([tPeak(iEu), tPeak(iEu)], yl, 'k:', LineWidth=1)
%         plot([tOnset(iEu), tOnset(iEu)], yl, 'k:', LineWidth=2)
%         for iVariant = 2:nVariants-1
%             plot(t, msrHat{iEu}(:, iVariant), Color=getColor(iVariant-1, nVariants-1))
% %             plot([tPeakHat(iEu), tPeakHat(iEu)], yl, Color=getColor(iVariant-1, nVariants-1), LineStyle=':', LineWidth=1)
%             plot([tOnsetHat(iEu, iVariant), tOnsetHat(iEu, iVariant)], yl, Color=getColor(iVariant-1, nVariants-1), LineStyle=':', LineWidth=2)
%         end
%         ylim(yl)
%     end
end
msrObs = cat(3, msr{:});
msrHat = cat(3, msrHat{:});

clear ax;
%% Plot fitted vs. observed for 2 example units and population average
SEL = { ...
    84, ...
    39, ...
    c.isPressDown, ...
    c.isPressUp, ...
    };
TITLE = { ...
    sprintf('Example unit (R^2=%.2f)', R2(84, end)), ...
    sprintf('Example unit (R^2=%.2f)', R2(39, end)), ...
    sprintf('Population average (N=%d)', nnz(SEL{3})), ...
    sprintf('Population average (N=%d)', nnz(SEL{4})), ...
    };
LOCATION = { ...
    'southwest', ...
    'northwest', ...
    'southwest', ...
    'northwest', ...
    };
SHOW_LEGEND = { ...
    false, ...
    false, ...
    true, ...
    false, ...
    };


fig = figure(Units='inches', Position=[0, 0, 6, 4]);
for i = 1:length(SEL)
    ax = subplot(2, 2, i);
    hold(ax, 'on')
    clear h
    sel = SEL{i}';
    h(1) = plot(ax, t, mean(msrObs(:, :, sel), 3, 'omitnan'), 'k:', LineWidth=3, DisplayName='Observed');
    for iVariant = 2:nVariants-1
        h(iVariant) = plot(ax, t, mean(msrHat(:, iVariant, sel), 3, 'omitnan'), ...
            Color=getColor(iVariant-1, nVariants-1), LineWidth=1.5, ...
            DisplayName=variantNames{iVariant});
    end
    if SHOW_LEGEND{i}
        legend(ax, h, Location=LOCATION{i})
    end
    xlim(ax, [-4, 0])
    xlabel(ax, sprintf('Time to %s (s)', 'lever-contact'))
    ylabel(ax, 'Spike rate (sp/s)')
    title(ax, TITLE{i});
    ax.FontSize = p.fontSize;
end

%% Plot fitted vs observed ramp onset times and peak SR
fig = figure(Units='inches', Position=[0, 0, 6, 2.25]);
SEL = { ...
    c.isPressResponsive, ...
    c.isPressResponsive, ...
    };
XDATA = { ...
    peak, ...
    tOnset, ...
    };

YDATA = { ...
    peakHat, ...
    tOnsetHat, ...
    };
SHOW_LEGEND = { ...
    true, ...
    false, ...
    };
XLIM = { ...
    'auto', ...
    [-2, 0], ...
    };
UNITS = { ...
    'sp/s', ...
    's', ...
    };

TITLE = {'Peak spike rate', 'Onset time'};

for i = 1:length(SEL)
    ax = subplot(1, 2, i);
    hold(ax, 'on')
    clear h
    sel = SEL{i}';
    x = XDATA{i}(sel);
    y = YDATA{i}(sel, :);
    h = gobjects(nVariants - 2, 1);
    for iVariant = 2:nVariants-1
        h(iVariant - 1) = scatter(ax, x, y(:, iVariant), 5, getColor(iVariant-1, nVariants-1), ...
            'filled', DisplayName=variantNames{iVariant});
    end
    if SHOW_LEGEND{i}
        legend(ax, h, Location='northwest', AutoUpdate=false)
    end
    title(ax, TITLE{i})
    xlim(ax, XLIM{i})
    xl = ax.XLim;
    ylim(ax, xl);
    plot(ax, xl, xl, 'k:')
    xlabel(ax, sprintf('Observed (%s)', UNITS{i}));
    ylabel(ax, sprintf('Predicted (%s)', UNITS{i}));
    ax.FontSize = p.fontSize;
end



%%

%%
function [peak, tPeak, tOnset, mu, sd] = getPeakAndOnset(X, t, varargin)
    p = inputParser();
    p.addParameter('onsetThresholdPos', 0.5, @isnumeric);
    p.addParameter('onsetThresholdNeg', 0.25, @isnumeric);
    p.addParameter('signWindow', [-0.5, -0.2], @isnumeric);
    p.addParameter('peakWindow', [-0.5, 0], @isnumeric);
    p.addParameter('mu', []);
    p.addParameter('sd', []);
    p.addParameter('baselineWindow', [-4, -2], @isnumeric);
    p.parse(varargin{:})
    r = p.Results;

    assert(length(t) == size(X, 2));

    % Calculate baseline for normalization
    if isempty(r.mu) || isempty(r.sd)
        baseX = X(:, t >= r.baselineWindow(1) & t <= r.baselineWindow(2));
        mu = mean(baseX, 'all', 'omitnan');
        sd = std(baseX, 0, 'all', 'omitnan');
    else
        mu = r.mu;
        sd = r.sd;
    end

    normX = (X - mu) ./ sd; % Normalize spike rate to baseline
    normX = mean(normX, 1, 'omitnan'); % Then average across trial

    signX = sign(mean(normX(t >= r.signWindow(1) & t <= r.signWindow(2)), 'omitnan'));
    inPeakWindow = find(t >= r.peakWindow(1) & t <= r.peakWindow(2));
    [~, peakIndex] = max(normX(inPeakWindow) .* signX, [], 'omitnan');
    peakIndex = inPeakWindow(peakIndex);
    peak = mean(X(:, peakIndex), 'omitnan');
    tPeak = t(peakIndex);

    if signX > 0
        isAbove = normX(1:peakIndex) >= r.onsetThresholdPos;
    else
        isAbove = normX(1:peakIndex) <= -abs(r.onsetThresholdNeg);
    end
    isAbove = flip(isAbove);
    isAboveConseq = isAbove & [0, diff(isAbove)] == 0;
    onsetIndex = find(~isAboveConseq, 1, 'first') - 1;
    onsetIndex = peakIndex - onsetIndex + 1;
    if isempty(onsetIndex)
        onsetIndex = peakIndex;
    end
    onsetIndex = min(onsetIndex, length(normX));

    tOnset = t(onsetIndex);
    try
        assert(~isempty(tOnset))
        assert(~isempty(tPeak))
    catch
        disp(1)
    end
end

function c = getColor(i, n, maxHue)
    if nargin < 3
        if n <= 4
            c = 'rgbm';
            c = c(i);
            return
        end
        maxHue = 0.8;
    end
    c = hsl2rgb([maxHue*(i-1)./(n-1), 1, 0.5]);
end