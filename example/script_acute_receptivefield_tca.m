%% 1.0 Load data
animalInfo = { ...
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
clear animalInfo i

eu = EphysUnit.load('C:\SERVER\Units\Lite_NonDuplicate', animalNames={ai.name});
ar = AcuteRecording.load('C:\SERVER\Acute\AcuteRecording');



% 1.1 Parameters
clear p
p.minSpikeRate = 15;
p.minStimDuration = 0.01;
p.maxStimDuration = 0.05;
p.errStimDuration = 1e-3;
p.allowAltStimDuration = true;
p.etaWindowStim = [-0.2, 0.5];
p.metaWindowStim = [0, 0.1];

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
isSingleUnit = prcLowISI <= 0.05;
euAll = eu;
eu = euAll(isSingleUnit);

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

c.isA2A = arrayfun(@(eu) strcmpi(getAnimalInfo(eu, ai, 'strain'), 'a2a-cre'), eu);
c.isAi80 = arrayfun(@(eu) strcmpi(getAnimalInfo(eu, ai, 'strain'), 'd1-cre;dlx-flp;ai80'), eu);

clear iEu st isi ISI prcLowISI euAll isSingleUnit iAr

% 1.2 ISI Analysis to categorize stim responses
clear rdStimSpatial isiSpatial
p.stimLight = [0.28, 0.4, 0.5, 2];
p.stimDuration = [0.01, 0.05];
p.isiWindow = [-0.2, 0.2];

if ~exist('ar')
    ar = AcuteRecording.load('C:\SERVER\Acute\AcuteRecording');
end

c.hasAnyStimTrials = arrayfun(@(eu) ~isempty(eu.getTrials('stim')), eu);
c.exclude = ...
    (strcmpi('desmond26_20220531', {eu.ExpName})  & [eu.Channel] == 13 & [eu.Unit] == 1) | ...
    (strcmpi('daisy16_20220502', {eu.ExpName})  & [eu.Channel] == 76 & [eu.Unit] == 1);% No spikes in DLS stim

xl = p.isiWindow; % Extend left by an extra 100ms to get accurate ISI curves. 

rdStimSpatial(2, 4, length(eu)) = struct('name', [], 'trialType', [], 'alignTo', [], 't', [], 'I', [], 'duration', [], 'iti', []);
for iEu = find(c.hasAnyStimTrials & (c.isAi80 | c.isA2A) & ~c.exclude)
    % Attempt to select specific galvo trials to simplify conditions
    iAr = find(strcmpi(eu(iEu).ExpName, {ar.expName}));

    for iML = 1:2
        for iDV = 1:4
            [~, IPulse] = ar(iAr).selectStimResponse(Light=p.stimLight, Duration=p.stimDuration, MLRank=iML, DVRank=iDV);
            trials = Trial(ar(iAr).stim.tOn(IPulse), ar(iAr).stim.tOff(IPulse));
            rdStimSpatial(iML, iDV, iEu) = eu(iEu).getRasterData('stim', window=xl, sort=false, alignTo='start', trials=trials, minTrialDuration=0.01, maxTrialDuration=0.01);
        end
    end
end

c.hasStimSpatial = false(2, 4, length(eu));
c.hasStimSpatial = arrayfun(@(rd) ~isempty(rd.I), rdStimSpatial);
c.hasStimSpatialAny = squeeze(any(c.hasStimSpatial, [1, 2]))';

fprintf(1, '%d units with requested stim conditions.\n', nnz(c.hasStimSpatialAny))

% Find stim response direction
warning('off')
isiSpatial(2, 4, length(eu)) = struct('t', [], 'isi', [], 'isi0', [], 'onsetLatency', [], 'peakLatency', [], ...
    'peak', [], 'baseline', [], 'baselineSD', [], 'width', []);
c.isStimUpSpatial = false(2, 4, length(eu));
c.isStimDownSpatial = false(2, 4, length(eu));
for iML = 1:2
    for iDV = 1:4
        sel = c.hasStimSpatial(iML, iDV, :);
        isiSpatial(iML, iDV, sel) = getISILatencies(rdStimSpatial(iML, iDV, sel), xlim=[-100, 100], peakThreshold=1, posMultiplier=1, minProminence=2, onsetThreshold=0.25, ...
            showPlots=false, savePlots=false, maxTrials=Inf);
        for iEu = 1:length(eu)
            if ~isempty(isiSpatial(iML, iDV, iEu).peak) && ~isnan(isiSpatial(iML, iDV, iEu).peak)
                c.isStimUpSpatial(iML, iDV, iEu) = isiSpatial(iML, iDV, iEu).peak < isiSpatial(iML, iDV, iEu).baseline & isiSpatial(iML, iDV, iEu).baseline <= 1000/15;
                c.isStimDownSpatial(iML, iDV, iEu) = isiSpatial(iML, iDV, iEu).peak > isiSpatial(iML, iDV, iEu).baseline & isiSpatial(iML, iDV, iEu).baseline <= 1000/15;
            end
        end
    end
end
c.hasStimResponseSpatial = c.isStimUpSpatial | c.isStimDownSpatial;
c.hasStimResponseSpatialAny = squeeze(any(c.hasStimResponseSpatial, [1, 2]))';
c.isStimUpSpatialAny = squeeze(any(c.isStimUpSpatial, [1, 2]))';
c.isStimDownSpatialAny = squeeze(any(c.isStimDownSpatial, [1, 2]))';

fprintf(1, '%d A2A units (%d responsive), %d has up, %d has down.\n', nnz(c.hasStimSpatialAny & c.isA2A), nnz(c.hasStimResponseSpatialAny & c.isA2A), ...
    nnz(c.isA2A & c.isStimUpSpatialAny), nnz(c.isA2A & c.isStimDownSpatialAny))
fprintf(1, '%d Ai80 units (%d responsive), %d has up, %d has down.\n', nnz(c.hasStimSpatialAny & c.isAi80), nnz(c.hasStimResponseSpatialAny & c.isAi80), ...
    nnz(c.isAi80 & c.isStimUpSpatialAny), nnz(c.isAi80 & c.isStimDownSpatialAny))
warning('on')

clear iEu sel iML iDV iAr IPulse xl trials


%% 2.0 Plot TCA for stim response
%% 2.1 Make tensors
arIndices = arrayfun(@(eu) find(strcmpi(eu.ExpName, {ar.expName})), eu);
arRep = ar(arIndices);
% selAi80 = find(c.hasStimResponseSpatialAny & c.isAi80);
% selAi80 = selAi80(1:5);
% selA2A = find(c.hasStimResponseSpatialAny & c.isA2A);
% selA2A = selA2A(1:5);
% [dataAi80, ~] = getTensor(eu(selAi80), arRep(selAi80), [0.28, 0.4, 0.5, 2], [0.01, 0.05], 32);
% [dataA2A, t] = getTensor(eu(selA2A), arRep(selA2A), [0.28, 0.4, 0.5, 2], [0.01, 0.05], 32);
% 
% %%
[dataAi80, ~] = getTensor(eu(c.hasStimResponseSpatialAny & c.isAi80), arRep(c.hasStimResponseSpatialAny & c.isAi80), ...
    [0.28, 0.4, 0.5, 2], [0.01, 0.05], 32);
[dataA2A, t] = getTensor(eu(c.hasStimResponseSpatialAny & c.isA2A), arRep(c.hasStimResponseSpatialAny & c.isA2A), ...
    [0.28, 0.4, 0.5, 2], [0.01, 0.05], 32);

%% Do TCA
close all
clear figsAi80 figsA2A
w = 1/4; h = 0.95/2;
iters = 1; 
figsAi80 = gobjects(1, iters);
figsA2A = gobjects(1, iters);
figsAi80_hi = gobjects(1, iters);
figsA2A_hi = gobjects(1, iters);
for iter = 1:iters
    figsAi80(iter) = figure(Units='normalized', OuterPosition=[w*(iter-1), h+0.05, w, h]);
    figsA2A(iter) = figure(Units='normalized', OuterPosition=[w*(iter-1), 0.05, w, h]);
    figsAi80_hi(iter) = figure(Units='normalized', OuterPosition=[w*iter, h+0.05, w, h]);
    figsA2A_hi(iter) = figure(Units='normalized', OuterPosition=[w*iter, 0.05, w, h]);
end

R = [2, 4, 8, 16];
selTime = t>=-50 & t <= 200;
selCond = 1:32;
[modelsAi80, errAi80, reconstructionAi80] = doTCA(figsAi80, figsAi80_hi, dataAi80(:, selTime, selCond), t(selTime), R);
[modelsA2A, errA2A, reconstructionA2A] = doTCA(figsA2A, figsA2A_hi, dataA2A(:, selTime, selCond), t(selTime), R);

figure(Units='normalized', OuterPosition=[w*(iter+1), h+0.05, w, h])
plot(R, mean(errAi80, 2))

figure(Units='normalized', OuterPosition=[w*(iter+1), 0.05, w, h])
plot(R, mean(errA2A, 2))

%%
% dFitAi80 = double(reconstructionAi80{1, 1});
dFitAi80_1 = double(reconstructionAi80{1, 1});
dFitAi80_end = double(reconstructionAi80{end, 1});
dAi80 = dataAi80(:, selTime, selCond);

figure(Units='normalized', OuterPosition=[0, 0, 1, 1]);
for iUnit = randperm(size(dAi80, 1))
    for iCond = 1:length(selCond)
        ax = subplot(4, 8, iCond);
        cla(ax)
        plot(t(selTime), dAi80(iUnit, :, iCond)', 'k', LineWidth=2, DisplayName='data'), hold on
        plot(t(selTime), dFitAi80_1(iUnit, :, iCond)', 'g', LineWidth=1, DisplayName=sprintf('reconstruction (R=%d)', R(1)))
        plot(t(selTime), dFitAi80_end(iUnit, :, iCond)', 'r', LineWidth=1, DisplayName=sprintf('reconstruction (R=%d)', R(end)))
        ylim([-50, 50])
    end
end

%%
% dFitA2A = double(reconstructionA2A{1, 1});
dFitA2A_1 = double(reconstructionA2A{1, 1});
dFitA2A_end = double(reconstructionA2A{end, 1});
dA2A = dataA2A(:, selTime, selCond);

figure(Units='normalized', OuterPosition=[0, 0, 1, 1]);
for iUnit = randperm(size(dA2A, 1))
    for iCond = 1:length(selCond)
        ax = subplot(4, 8, iCond);
        cla(ax)
        plot(t(selTime), dA2A(iUnit, :, iCond)', 'k', LineWidth=2, DisplayName='data'), hold on
        plot(t(selTime), dFitA2A_1(iUnit, :, iCond)', 'g', LineWidth=1, DisplayName=sprintf('reconstruction (R=%d)', R(1)))
        plot(t(selTime), dFitA2A_end(iUnit, :, iCond)', 'r', LineWidth=1, DisplayName=sprintf('reconstruction (R=%d)', R(end)))
        ylim([-50, 50])
    end
end

%% 3. Use ISI to find first peak amplitude and sign
[firstPeakAi80, peakLatencyAi80] = getFirstPeakTensor(eu(c.hasStimResponseSpatialAny & c.isAi80), arRep(c.hasStimResponseSpatialAny & c.isAi80), ...
    [0.28, 0.4, 0.5, 2], [0.01, 0.05], 32);
[firstPeakA2A, peakLatencyA2A] = getFirstPeakTensor(eu(c.hasStimResponseSpatialAny & c.isA2A), arRep(c.hasStimResponseSpatialAny & c.isA2A), ...
    [0.28, 0.4, 0.5, 2], [0.01, 0.05], 32);

%% Plot RFs as heatmap
close all
ax = gobjects(2, 1);
figure(Units='inches', Position=[0, 0, 6.5, 6.5])
ax(1) = subplot(1, 2, 1);
firstPeakAi80Norm = firstPeakAi80 ./ max(abs(firstPeakAi80), [], 2, 'omitnan');
firstPeakAi80Norm(isnan(firstPeakAi80Norm)) = 0;
[~, I] = sort(sum(firstPeakAi80Norm, 2));
imagesc(ax(1), firstPeakAi80Norm(I, :))
hold(ax(1), 'on')
for x = [8.5, 16.5, 24.5, 32.5]
    plot(ax(1), [x, x], ax(1).YLim, 'k')
end
title(ax(1), 'dSPN')
hold(ax(1), 'off')


ax(2) = subplot(1, 2, 2);
firstPeakA2ANorm = firstPeakA2A ./ max(abs(firstPeakA2A), [], 2, 'omitnan');
firstPeakA2ANorm(isnan(firstPeakA2ANorm)) = 0;
[~, I] = sort(sum(firstPeakA2ANorm, 2));
imagesc(ax(2), firstPeakA2ANorm(I, :))
hold(ax(2), 'on')
for x = [8.5, 16.5, 24.5, 32.5]
    plot(ax(2), [x, x], ax(2).YLim, 'k')
end
hold(ax(2), 'off')
title(ax(2), 'iSPN')


xticks(ax, [4.5, 12.5, 20.5, 28.5])
xticklabels(ax, {'0.5mW 10ms', '0.5mW 50ms', '2mW 10ms', '2mW 50ms'})
colormap(ax(1), 'jet')
colormap(ax(2), 'jet')
colorbar(ax(1))
colorbar(ax(2))
set(ax, CLim=[-1.5, 1.5])
ylabel(ax(1), 'SNr unit')
xlabel(ax, 'site \times light \times duration')
set(ax, FontSize=13)


%% Center on peak and average
firstPeakAi80Norm = firstPeakAi80(:, 1:8) ./ max(abs(firstPeakAi80(:, 1:8)), [], 2, 'omitnan');
[~, I] = max(abs(firstPeakAi80Norm), [], 2, 'omitnan');
firstPeakAi80NormAligned = firstPeakAi80Norm;
for i = 1:size(firstPeakAi80Norm, 1)
    firstPeakAi80NormAligned(i, :) = circshift(firstPeakAi80Norm(i, :), 4-I(i), 2);
end
toRemove = all(isnan(firstPeakAi80NormAligned), 2);
firstPeakAi80NormAligned(isnan(firstPeakAi80NormAligned)) = 0;
firstPeakAi80NormAligned(toRemove, :) = NaN;
firstPeakAi80NormAligned = firstPeakAi80NormAligned.*sign(firstPeakAi80NormAligned(:, 4));

firstPeakA2ANorm = firstPeakA2A(:, 1:8) ./ max(abs(firstPeakA2A(:, 1:8)), [], 2, 'omitnan');
[~, I] = max(abs(firstPeakA2ANorm), [], 2, 'omitnan');
firstPeakA2ANormAligned = firstPeakA2ANorm;
for i = 1:size(firstPeakA2ANorm, 1)
    firstPeakA2ANormAligned(i, :) = circshift(firstPeakA2ANorm(i, :), 4-I(i), 2);
end
toRemove = all(isnan(firstPeakA2ANormAligned), 2);
firstPeakA2ANormAligned(isnan(firstPeakA2ANormAligned)) = 0;
firstPeakA2ANormAligned(toRemove, :) = NaN;
firstPeakA2ANormAligned = firstPeakA2ANormAligned.*sign(firstPeakA2ANormAligned(:, 4));

ax = axes(figure(Units='inches', Position=[0 0 5 4]));
h = gobjects(2, 1);
mu = mean(firstPeakAi80NormAligned, 1, 'omitnan');
sd = std(firstPeakAi80NormAligned, 0, 1, 'omitnan');

hold(ax, 'on')
h(1) = plot(ax, mu, 'b', DisplayName='dSPN', LineWidth=2);
patch(ax, [1:8, 8:-1:1], [mu-sd, flip(mu+sd)], 'b', FaceAlpha=0.05, LineStyle='none')
mu = mean(firstPeakA2ANormAligned, 1, 'omitnan');
sd = std(firstPeakA2ANormAligned, 0, 1, 'omitnan');

h(2) = plot(mean(firstPeakA2ANormAligned, 1, 'omitnan'), 'r', DisplayName='iSPN', LineWidth=2);
patch(ax, [1:8, 8:-1:1], [mu-sd, flip(mu+sd)], 'r', FaceAlpha=0.05, LineStyle='none')
legend(ax, h, FontSize=13)
xlim(ax, [1, 8])
xticks(ax, 1:8)
yticks(ax, [0, 0.5, 1])
ylabel(ax, 'Response amplitude (a.u.)')
xlabel(ax, {'Striatal site';'(0.5mW 10ms)'})
ax.FontSize=13;
ylim(ax, [0, 1])


%% Functions

function [peak, latency] = getFirstPeakTensor(eu, ar, light, duration, nConditions)
    warning('off')
    groupHash = [1111:1114, 1121:1124, 1211:1214, 1221:1224, 2111:2114, 2121:2124, 2211:2214, 2221:2224];
    groupHash = groupHash(1:nConditions);
    peak = NaN(length(eu), length(groupHash));
    latency = NaN(length(eu), length(groupHash));
    for iEu = 1:length(eu)
        fprintf(1, '%d\n', iEu);
        [~, I] = ar(iEu).selectStimResponse('Light', light, 'Duration', duration);
        groups = ar(iEu).groupByStimCondition(I, {'light', 'duration', 'ml', 'dv'}); 
        for iGrpOf32 = 1:length(groupHash)
            gh = [groups.groupHash];
            gh(gh >= 3000) = gh(gh >= 3000) - 1000;
            iGrp = find(gh == groupHash(iGrpOf32));
            if length(iGrp) ~= 1
                continue
            end
            trials = Trial(ar(iEu).stim.tOn(groups(iGrp).IPulse), ar(iEu).stim.tOff(groups(iGrp).IPulse));
            rd = eu(iEu).getRasterData('stim', window=[-0.3, 0.4], sort=false, alignTo='start', trials=trials, minTrialDuration=0, maxTrialDuration=Inf);
            isi = getISILatencies(rd, xlim=[-100, 200], ...
                peakThreshold=1, posMultiplier=1, minProminence=2, onsetThreshold=0.25, ...
                showPlots=false, savePlots=false, maxTrials=Inf);

            peak(iEu, iGrpOf32) = 1000/(isi.peak) - 1000/isi.baseline;
            latency(iEu, iGrpOf32) = isi.peakLatency;
        end
    end
    warning('on')
end

function [data, t] = getTensor(eu, ar, light, duration, nConditions)
    warning('off')
    groupHash = [1111:1114, 1121:1124, 1211:1214, 1221:1224, 2111:2114, 2121:2124, 2211:2214, 2221:2224];
    groupHash = groupHash(1:nConditions);
    data = NaN(length(eu), 301, length(groupHash));
    for iEu = 1:length(eu)
        fprintf(1, '%d\n', iEu);
        [~, I] = ar(iEu).selectStimResponse('Light', light, 'Duration', duration);
        groups = ar(iEu).groupByStimCondition(I, {'light', 'duration', 'ml', 'dv'}); 
        for iGrpOf32 = 1:length(groupHash)
            gh = [groups.groupHash];
            gh(gh >= 3000) = gh(gh >= 3000) - 1000;
            iGrp = find(gh == groupHash(iGrpOf32));
            if length(iGrp) ~= 1
                data(iEu, :, iGrpOf32) = 0.1*randn(1, size(data, 2));
                continue
            end
            trials = Trial(ar(iEu).stim.tOn(groups(iGrp).IPulse), ar(iEu).stim.tOff(groups(iGrp).IPulse));
            rd = eu(iEu).getRasterData('stim', window=[-0.3, 0.4], sort=false, alignTo='start', trials=trials, minTrialDuration=0, maxTrialDuration=Inf);
            isi = getISILatencies(rd, xlim=[-100, 200], ...
                peakThreshold=1, posMultiplier=1, minProminence=2, onsetThreshold=0.25, ...
                showPlots=false, savePlots=false, maxTrials=Inf);

            d = 1000./(isi.isi) - 1000/isi.baseline;
            if ~any(isnan(d))
                data(iEu, :, iGrpOf32) = d;
            elseif ~all(isnan(d))
                d(isnan(d)) = mean(d, 'omitnan');
                data(iEu, :, iGrpOf32) = d;
            else
                data(iEu, :, iGrpOf32) = 1*randn(1, size(data, 2));
            end

%             eta = eu(iEu).getETA('rate', 'stim', [-0.3, 0.4], resolution=0.001, ...
%                     trials=trials, normalize=[-0.3, 0], includeInvalid=false);
%             if all(isnan(eta.X))
%                 data(iEu, :, iGrpOf32) = 0.1*randn(1, size(data, 2));
%             else
%                 data(iEu, :, iGrpOf32) = eta.X;
%             end
        end
    end
    warning('on')
%     t = eta.t;
    t = isi.t;
end

function [models, err, reconstruction] = doTCA(figs, figsHi, data, t, R)
    data = tensor(data);
    iters = 5;
    err = zeros(length(R), iters);
    for iR = 1:length(R)
        for iter = 1:iters
            model = cp_als(data, R(iR), maxiters=1000, tol=1e-5, ...
                printitn=10);
            models{iR, iter} = model;
    
            reconstruction{iR, iter} = full(model);
            err(iR, iter) = norm(full(model) - data) / norm(data);
    
            if iter <= length(figs) && iR == 1
                % score aligns the cp decompositions
%                 [sc, model] = score(model, models{1});
    
                viz_ktensor2(model, ...
                    'Figure', figs(iter), ...
                    'Plottype', {'bar', 'line', 'bar'}, ...
                    'Modetitles', {'neurons', 'time', 'striatum site'}, ...
                    'CLim', [-.01, .01], ...
                    'Timestamps', t);
            end

            if iter <= length(figsHi) && iR == length(R)
                viz_ktensor2(model, ...
                    'Figure', figsHi(iter), ...
                    'Plottype', {'bar', 'line', 'bar'}, ...
                    'Modetitles', {'neurons', 'time', 'striatum site'}, ...
                    'CLim', [-.01, .01], ...
                    'Timestamps', t);
            end
        end
    end
end

function info = getAnimalInfo(eu, ai, field)
    i = find(strcmpi({ai.name}, eu.getAnimalName()));
    assert(length(i) == 1, eu.getAnimalName())
    info = ai(i).(field);
end


function [isiStruct, ax] = getISILatencies(rd, varargin)
    p = inputParser();
    p.addRequired('rd', @isstruct);
    p.addParameter('xlim', [-100, 100], @isnumeric);
    p.addParameter('showPlots', false, @islogical);
    p.addParameter('savePlots', false, @islogical);
    p.addParameter('maxTrials', Inf, @isnumeric);
    p.addParameter('peakThreshold', 1, @isnumeric); % sd multiplier
    p.addParameter('posMultiplier', 0.5, @isnumeric); % sd multiplier
    p.addParameter('onsetThreshold', 0.1, @isnumeric); % sd multiplier
    p.addParameter('minProminence', 4, @isnumeric); % absolute unit, ms
    p.parse(rd, varargin{:});
    rd = p.Results.rd;
    xl = p.Results.xlim;
    onsetThreshold = p.Results.onsetThreshold;
    posMultiplier = p.Results.posMultiplier;
            

    isiStruct(length(rd), 1) = struct('t', [], 'isi', [], 'isi0', [], 'onsetLatency', [], 'peakLatency', [], 'peak', [], 'baseline', [], 'baselineSD', [], 'width', []);

    for iUnit = 1:length(rd)
        spikeTimes = rd(iUnit).t .* 1000;
        trialIndices = rd(iUnit).I;
    
        % Sort them
        [~, ISort] = sort(trialIndices*1000 + spikeTimes);
        trialIndices = trialIndices(ISort);
        spikeTimes = spikeTimes(ISort);

        if ~all(diff(trialIndices) >= 0)

            error('Well fuck you still.')
            
            isiStruct(iUnit).isi = [];
            isiStruct(iUnit).t = [];
            isiStruct(iUnit).onsetLatency = NaN;
            isiStruct(iUnit).peakLatency = NaN;
            isiStruct(iUnit).peak = NaN;
            isiStruct(iUnit).baseline = [];
            isiStruct(iUnit).baselineSD = [];
            isiStruct(iUnit).width = NaN;

            continue
        end

        [~, IFirstInTrial] = unique(trialIndices);
%         [~, ILastInTrial] = unique(flip(trialIndices));
%         ILastInTrial = length(trialIndices) + 1 - ILastInTrial;
    
        % Time to next spike
        isi = diff(spikeTimes);
        isi = [NaN, isi];
        isi(IFirstInTrial) = NaN;
%         isi(IFirstInTrial) = isiBaseline;
%         isiStd = mad(isi(spikeTimes < 0), 1, 'all') / 0.6745;

        % Always use 1ms bins
        t = xl(1):1:xl(2);
        isiContinuous = NaN(length(unique(rd(iUnit).I)), length(t));   
        iTrial = 0;
        isiStd = NaN(length(unique(trialIndices)), 1);
        for trialIndex = unique(trialIndices)
            iTrial = iTrial + 1;
            sel = trialIndices == trialIndex;
            if nnz(sel) >= 2 && length(unique(spikeTimes(sel))) == nnz(sel)
                isiContinuous(iTrial, :) = interp1(spikeTimes(sel), isi(sel), t, 'linear', NaN);
                isiStd(iTrial) = std(isiContinuous(iTrial, t<0 & t>xl(1)), 1, 'all', 'omitnan');
            end
        end

        x = mean(isiContinuous, 1, 'omitnan');
%         tPost = t(t>=0);
%         xPost = x(t>=0);
        isiBaseline = mean(x(t < 0 & t > xl(1)), 'omitnan');
        isiStd = mean(isiStd, 'omitnan');
        xStart = x(t == 0);
        x0 = x - xStart; % isi minus on baseline
        [posPeaks, posPeakTimes, posPeakWidths, posPeakProminences] = findpeaks(x0, t, MinPeakHeight=p.Results.peakThreshold*isiStd, MinPeakProminence=p.Results.minProminence);
        [negPeaks, negPeakTimes, negPeakWidths, negPeakProminences] = findpeaks(-x0, t, MinPeakHeight=posMultiplier * p.Results.peakThreshold*isiStd, MinPeakProminence=p.Results.minProminence);

        posPeaks = xStart + posPeaks;
        negPeaks = xStart - negPeaks;

        % Discard peaks before 0
        sel = posPeakTimes > 0;
        posPeaks = posPeaks(sel);
        posPeakTimes = posPeakTimes(sel);
        posPeakWidths = posPeakWidths(sel);
        posPeakProminences = posPeakProminences(sel);

        sel = negPeakTimes > 0;
        negPeaks = negPeaks(sel);
        negPeakTimes = negPeakTimes(sel);
        negPeakWidths = negPeakWidths(sel);
        negPeakProminences = negPeakProminences(sel);

        % Merge positive and negative peaks
        peaks = [posPeaks, negPeaks];
        peakSigns = [ones(size(posPeaks)), -1*ones(size(negPeaks))];

        % Skip the rest if no peaks detected
        peakTimes = [posPeakTimes, negPeakTimes];
        peakWidths = [posPeakWidths, negPeakWidths];
        peakProminences = [posPeakProminences, negPeakProminences];
    
        [peakTimes, ISort] = sort(peakTimes);
        ISort = ISort(peakTimes > 0);
        peakTimes = peakTimes(peakTimes > 0);
        peaks = peaks(ISort);
        peakSigns = peakSigns(ISort);
        peakWidths = peakWidths(ISort);
        peakProminences = peakProminences(ISort);
    
        if (isempty(peakTimes))
            isiStruct(iUnit).isi = x;
            isiStruct(iUnit).t = t;
            isiStruct(iUnit).isi0 = xStart;
            isiStruct(iUnit).onsetLatency = NaN;
            isiStruct(iUnit).peakLatency = NaN;
            isiStruct(iUnit).peak = NaN;
            isiStruct(iUnit).baseline = isiBaseline;
            isiStruct(iUnit).baselineSD = isiStd;
            isiStruct(iUnit).width = NaN;

            if p.Results.showPlots
                fig = figure(Position=[300 0 300, 600], DefaultAxesFontSize=12);
                ax = subplot(2, 1, 1);
                try
                    EphysUnit.plotRaster(ax, rd(iUnit), xlim=xl, ...
                        timeUnit='ms', maxTrials=p.Results.maxTrials);
                catch
                    disp()
                end
            
                ax = subplot(2, 1, 2);
                hold on
                h = gobjects(3, 1);
                h(1) = plot(ax, t, x, 'k', LineWidth=2, DisplayName='ISI');
                xlim(xl)
                h(2) = patch(ax, [xl, flip(xl)], [isiBaseline + isiStd, isiBaseline + isiStd, isiBaseline - isiStd, isiBaseline - isiStd], 'k', FaceAlpha=0.2);
                h(3) = plot(ax, xl, [isiBaseline, isiBaseline], 'k:', LineWidth=2, DisplayName='baseline');
                plot(ax, [0, 0], ax.YLim, 'k:')
                title('ISI (Time to next spike)')
                ylabel('ISI (ms)')
                yl = ax.YLim;
                plot(ax, [0, 0], ax.YLim, 'k:')
                ax.YLim = yl;
                xlabel('Time from opto on (ms)')
                legend(ax, h, Location='best')
        
                if p.Results.savePlots
                    if ~isfolder(sprintf('C:\\SERVER\\Figures\\Single Units\\Raster_%s_ISILatency', rd(iUnit).trialType))
                        mkdir(sprintf('C:\\SERVER\\Figures\\Single Units\\Raster_%s_ISILatency', rd(iUnit).trialType));
                    end
                    print(fig, sprintf('C:\\SERVER\\Figures\\Single Units\\Raster_%s_ISILatency\\%s (%s)', rd(iUnit).trialType, rd(iUnit).name, rd(iUnit).trialType), '-dpng')
                    close(fig)
                end     
            end
        else
            % Traceback from first isi peak to isi ramp onset 
            if peakSigns(1) > 0
                onsetSampleIndex = find(flip(x0 >= onsetThreshold * posMultiplier * isiStd & t >= 0), 1, 'last');
            else
                onsetSampleIndex = find(flip(x0 <= -onsetThreshold * isiStd & t >= 0), 1, 'last');
            end
            onsetSampleIndex = length(x) + 1 - onsetSampleIndex;
            tOnset = t(onsetSampleIndex);
            xOnset = x(onsetSampleIndex);
    
            % Store data
            isiStruct(iUnit).isi = x;
            isiStruct(iUnit).t = t;
            isiStruct(iUnit).isi0 = xStart;
            isiStruct(iUnit).onsetLatency = tOnset;
            isiStruct(iUnit).peakLatency = peakTimes(1);
            isiStruct(iUnit).peak = peaks(1);
            isiStruct(iUnit).baseline = isiBaseline;
            isiStruct(iUnit).baselineSD = isiStd;
            isiStruct(iUnit).width = peakWidths(1);
    
            if p.Results.showPlots
                fig = figure(Position=[300 0 300, 600], DefaultAxesFontSize=11);
                ax = subplot(2, 1, 1);
                EphysUnit.plotRaster(ax, rd(iUnit), xlim=xl, ...
                        timeUnit='ms', maxTrials=p.Results.maxTrials);
            
                ax = subplot(2, 1, 2);
                hold on
                clear h
                h(1) = plot(ax, t, x, 'k', LineWidth=2, DisplayName='ISI');
                xlim(xl)
                h(2) = patch(ax, [xl, flip(xl)], [isiBaseline + isiStd, isiBaseline + isiStd, isiBaseline - isiStd, isiBaseline - isiStd], 'k', FaceAlpha=0.2, DisplayName='std');
                h(3) = plot(ax, xl, [isiBaseline, isiBaseline], 'k:', LineWidth=2, DisplayName='baseline');
                if nnz(posPeakTimes>0) >= 1
                    h(end+1) = scatter(ax, posPeakTimes(posPeakTimes>0), posPeaks(posPeakTimes>0), 100, 'b', 'filled', DisplayName='peak');
                end
                if nnz(negPeakTimes>0) >= 1
                    h(end+1) = scatter(ax, negPeakTimes(negPeakTimes>0), negPeaks(negPeakTimes>0), 100, 'r', 'filled', DisplayName='peak');
                end
                plot(ax, [0, 0], ax.YLim, 'k:')
                title('ISI (Time to next spike)')
                ylabel('ISI (ms)')
                yl = ax.YLim;
                plot(ax, [0, 0], ax.YLim, 'k:')
                ax.YLim = yl;
                xlabel('Time from opto onset (ms)')
                text(peakTimes(1), peaks(1) - peakSigns(1) * 0.1 * diff(yl), arrayfun(@(x) sprintf('%.0fms', x), peakTimes(1), UniformOutput=false))
                h(end+1) = scatter(tOnset, xOnset, 100, 'yellow', 'filled', DisplayName='onset');
                text(tOnset, xOnset - peakSigns(1) * 0.1 * diff(yl), sprintf('%.0fms', tOnset));
                legend(ax, h, Location='best', FontSize=9)
        
                if p.Results.savePlots
                    if ~isfolder(sprintf('C:\\SERVER\\Figures\\Single Units\\Raster_%s_ISILatency', rd(iUnit).trialType))
                        mkdir(sprintf('C:\\SERVER\\Figures\\Single Units\\Raster_%s_ISILatency', rd(iUnit).trialType));
                    end
                    print(fig, sprintf('C:\\SERVER\\Figures\\Single Units\\Raster_%s_ISILatency\\%s (%s)', rd(iUnit).trialType, rd(iUnit).name, rd(iUnit).trialType), '-dpng')
                    close(fig)
                else
                    ax = subplot(2, 1, 1);
                    title(ax, 'Spike raster'); xlabel(ax, '');
                    ax = subplot(2, 1, 2);
                    title(ax, 'ISI (trial-average)')
                end
            end
        end
    end
end
