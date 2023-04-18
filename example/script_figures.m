p.fontSize = 13;
%% 8. Reach PETH
close all

p.etaSortWindow = [-3, 0];
p.etaSignWindow = [-0.3, 0];
p.etaLatencyThresholdPos = 0.5;
p.etaLatencyThresholdNeg = 0.25;


% a. Distribution of baseline rates
fig = figure(Units='inches', Position=[0, 0, 3, 7], DefaultAxesFontSize=p.fontSize);
ax = subplot(3, 1, 1);
histogram(ax, msr(c.hasPress), 15);
xlabel(ax, 'Baseline spike rate (sp/s)'), ylabel(ax, 'Count')
legend(ax, sprintf('N=%g', length(msr(c.hasPress))))

% b. Distribution or pre-reach response
ax = subplot(3, 1, 2);
histogram(ax, meta.pressRaw(c.hasPress)./0.1 - msr(c.hasPress))
xlabel(ax, 'Pre-move response (\Deltasp/s)'), ylabel(ax, 'Count')
legend(ax, sprintf('N=%g', nnz(c.hasPress)))

% c. Distribution or pre-reach response (z-scored)
ax = subplot(3, 1, 3);
histogram(ax, meta.press(c.hasPress))
xlabel(ax, 'Normalized pre-move response (a.u.)'), ylabel(ax, 'Count')
legend(ax, sprintf('N=%g', nnz(c.hasPress)))
set(fig.Children, FontSize=p.fontSize);

% d. Heatmap PETH for reach task
ax = EphysUnit.plotETA(eta.press, c.hasPress, xlim=[-4,0], clim=[-1.5, 1.5], ...
    sortWindow=p.etaSortWindow, signWindow=p.etaSignWindow, ...
    sortThreshold=p.etaLatencyThresholdPos, negativeSortThreshold=p.etaLatencyThresholdNeg); 
title('Pre-reach PETH')
xlabel('Time to touchbar-contact (s)')
ax.Parent.Units = 'inches';
ax.Parent.Position = [0, 0, 3.5, 7];
ax.FontSize = p.fontSize;


%% 9. Baseline spiking vs. reach response direction
close all

sz = 5;

fig = figure(Units='inches', Position=[0, 0, 6.5, 6], DefaultAxesFontSize=p.fontSize);
ax = subplot(2, 2, 2);

nBins = 15;
edges = linspace(0, max(msr, [], 'all', 'omitnan'), nBins);
NAll = histcounts(msr(c.hasPress), edges, 'Normalization', 'probability');
NUp = histcounts(msr(c.isPressUp), edges, 'Normalization', 'probability');
NDown = histcounts(msr(c.isPressDown), edges, 'Normalization', 'probability');
centers = 0.5*(edges(2:end) + edges(1:end-1));
hold(ax, 'on')
plot(ax, centers, cumsum(NDown), 'LineWidth', 2, 'Color', 'blue', 'DisplayName', sprintf('suppressed (N=%g)', nnz(c.isPressDown)))
plot(ax, centers, cumsum(NUp), 'LineWidth', 2, 'Color', 'red', 'DisplayName', sprintf('excited (N=%g)', nnz(c.isPressUp)));
hold(ax, 'off')
legend(ax, Location='southeast');
ylim(ax, [0, 1])
xlabel(ax, 'Baseline spike rate (sp/s)')
ylabel(ax, 'Cumulative probability')
[ks.h, ks.p] = kstest2(msr(c.isPressDown), msr(c.isPressUp), Tail='larger');
title(ax, 'Suppressed vs. Excited (CDF)')
fprintf(1, 'Median: suppressed=%.1f, excited=%.1f, one-tailed rank-sum (suppressed > excited) p=%g\n', median(msr(c.isPressDown)), median(msr(c.isPressUp)), ranksum(msr(c.isPressDown), msr(c.isPressUp), tail='right'))
fprintf(1, 'One-tailed K-S test (suppressed > excited), p=%g\n', ks.p)



ax = subplot(2, 2, 1);
histogram(ax, msr(c.isPressDown), edges, FaceColor='blue')
xlabel(ax, 'Baseline spike rate (sp/s)'), ylabel(ax, 'Count')
legend(ax, sprintf('N=%g', nnz(c.isPressDown)), Location='northeast')
title(ax, 'Suppressed population')

ax = subplot(2, 2, 3);
histogram(ax, msr(c.isPressUp), edges, FaceColor='red');
xlabel(ax, 'Baseline spike rate (sp/s)'), ylabel(ax, 'Count')
legend(ax, sprintf('N=%g', nnz(c.isPressUp)), Location='northeast')
title(ax, 'Excited population')

ax = subplot(2, 2, 4);
hold(ax, 'on')
isResp = c.isPressResponsive;
isNonResp = c.hasPress & ~c.isPressResponsive;
clear h
sel = c.isPressResponsive;
h(1) = scatter(ax, msr(sel), meta.pressRaw(sel)./0.1 - msr(sel), sz, 'black', 'filled', DisplayName=sprintf('N=%g', nnz(sel)));
xl = ax.XLim;
plot(ax, ax.XLim, [0, 0], 'k--', LineWidth=1.5);
hold(ax, 'off')
xlabel(ax, 'Baseline spike rate (sp/s)'), ylabel(ax, 'Pre-move response (\Deltasp/s)')
legend(ax, h, Location='best')
title(ax, 'Responsive population')

set(fig.Children, FontSize=p.fontSize);

%% Trial-avg move traces
%% 1.1.1 Get trial aligned movement velocity data (slow)
p.velETAWindow = [-10, 3];
p.velETABinWidth = 0.05;
p.minTrialLength = 2;

close all

statName = 'spd';
t = flip(p.velETAWindow(2):-p.velETABinWidth:p.velETAWindow(1));
fCorrect = cell(1, length(exp));
fIncorrect = cell(1, length(exp));
fnamesL = {'handL', 'footL', 'handR', 'footR', 'spine', 'tongue', 'nose'};
fnamesR = {'handR', 'footR', 'handL', 'footL', 'spine', 'tongue', 'nose'};
fnames = {'handContra', 'footContra', 'handIpsi', 'footIpsi', 'spine', 'tongue', 'nose'};
fnamesDisp = {'contra hand', 'contra foot', 'ipsi hand', 'ipsi foot', 'spine', 'tongue', 'nose'};
[kernels, ~, ~] = CompleteExperiment.makeConsineKernels(0, width=0.1); % Kernels for smoothing velocity traces
for iExp = 1:length(exp)
    clear trials
    switch leverSide(iExp)
        case 'L'
            theseNames = fnamesL;
        case 'R'
            theseNames = fnamesR;
    end

    fCorrect{iExp} = struct('press', [], 'lick', []);
    fIncorrect{iExp} = struct('press', [], 'lick', []);
    for trialType = {'press', 'lick'}
        trialType = trialType{1};
        trials = exp(iExp).eu(1).getTrials(trialType);
        if strcmp(trialType, 'press')
            disp(length(trials))
        end

        nCorrectTrials = nnz(trials.duration >= 4);
        nIncorrectTrials = nnz(trials.duration < 4 & trials.duration >= p.minTrialLength);
        fIncorrect{iExp}.(trialType) = NaN(length(t), length(fnames), nIncorrectTrials);
        fCorrect{iExp}.(trialType) = NaN(length(t), length(fnames), nCorrectTrials);
        iTrialCorrect = 0;
        iTrialIncorrect = 0;
        for iTrial = 1:length(trials)
            if trials(iTrial).duration < p.minTrialLength
                continue;
            end

            tGlobal = flip(trials(iTrial).Stop + p.velETAWindow(2):-p.velETABinWidth:trials(iTrial).Stop + p.velETAWindow(1));
            F = exp(iExp).getFeatures(timestamps=tGlobal, features=theseNames, stats={statName}, useGlobalNormalization=true);
            F = CompleteExperiment.convolveFeatures(F, kernels, kernelNames={'_smooth'}, ...
                features=theseNames, ...
                stats={statName}, ...
                mode='replace', normalize='none');
            inTrial = F.t >= trials(iTrial).Start;
            if iTrial < length(trials)
                inTrial = inTrial & F.t <= trials(iTrial + 1).Start;
            end
            F(:, {'t', 'inTrial'}) = [];
            thisData = table2array(F);
            thisData(~inTrial, :) = NaN;

            % Incorrect
            if trials(iTrial).duration < 4
                iTrialIncorrect = iTrialIncorrect + 1;
                fIncorrect{iExp}.(trialType)(:, :, iTrialIncorrect) = thisData;
            % Correct
            else
                iTrialCorrect = iTrialCorrect + 1;
                fCorrect{iExp}.(trialType)(:, :, iTrialCorrect) = thisData;
            end
        end
    end
end

%% Average by trial
clear fstats
statStruct = struct('mean', [], 'nTrials', [], 'sd', []);
fallIncorrect = struct('press', statStruct, 'lick', statStruct);
for trialTypeName = {'press', 'lick'}
    trialTypeName = trialTypeName{1};
    ff = cellfun(@(f) f.(trialTypeName), fIncorrect, UniformOutput=false);
    fallIncorrect.(trialTypeName) = cat(3, ff{:});
    fstats{1}.(trialTypeName).mean = array2table(mean(fallIncorrect.(trialTypeName), 3, 'omitnan'), VariableNames=fnames);
    fstats{1}.(trialTypeName).mean.t = t';
    fstats{1}.(trialTypeName).nTrials = nnz(any(~isnan(fallIncorrect.(trialTypeName)), [1, 2]));
    fstats{1}.(trialTypeName).sd = array2table(std(fallIncorrect.(trialTypeName), 0, 3, 'omitnan'), VariableNames=fnames);
end

fallCorrect = struct('press', statStruct, 'lick', statStruct);
for trialTypeName = {'press', 'lick'}
    trialTypeName = trialTypeName{1};
    ff = cellfun(@(f) f.(trialTypeName), fCorrect, UniformOutput=false);
    fallCorrect.(trialTypeName) = cat(3, ff{:});
    fstats{2}.(trialTypeName).mean = array2table(mean(fallCorrect.(trialTypeName), 3, 'omitnan'), VariableNames=fnames);
    fstats{2}.(trialTypeName).mean.t = t';
    fstats{2}.(trialTypeName).nTrials = nnz(any(~isnan(fallCorrect.(trialTypeName)), [1, 2]));
    fstats{2}.(trialTypeName).sd = array2table(std(fallCorrect.(trialTypeName), 0, 3, 'omitnan'), VariableNames=fnames);
end

clear iExp kernels trials trialTypeName trialType iTrial tGlobal inTrial thisData F mu sd n ff

%% 1.1.2 Plot average traces
% load('C:\Users\AssadLab\Desktop\fstats\fstats_correct.mat')
% load('C:\Users\AssadLab\Desktop\fstats\fstats_incorrect.mat')
close all
resultNames = {'incorrect', 'correct'};

p.fontSize=13;

for iExp = 1:length(fstats)
    fig = figure(Units='inches', Position=[0+(iExp-1)*4.5, -1, 7.5, 7.5], DefaultAxesFontSize=p.fontSize);
    axAll = gobjects(1, 2);
    iTrialType = 0;
    for trialTypeName = {'press', 'lick'}
        trialTypeName = trialTypeName{1};
        iTrialType = iTrialType + 1;
        ax = subplot(2, 1, iTrialType);
        axAll(iTrialType) = ax;
        hold(ax, 'on')

        switch trialTypeName
            case {'press', 'lick'}
                mu = table2array(fstats{iExp}.(trialTypeName).mean(:, fnames));
                sd = table2array(fstats{iExp}.(trialTypeName).sd(:, fnames));
                n = fstats{iExp}.(trialTypeName).nTrials;
        end

        sdNames = {'handContra', 'tongue'};
        ftNames = {'handContra', 'tongue'};


        h = gobjects(1, length(ftNames));
        ii = 0;
        for iVar = 1:length(fnames)
            col = hsl2rgb([0.8*(iVar-1)/(length(fnames)-1), 1, 0.5]);
            if ismember(fnames{iVar}, ftNames)
                ii = ii + 1;
                h(ii) = plot(ax, t, mu(:, iVar), Color=col, LineWidth=1.5, DisplayName=fnamesDisp{iVar});
            end
            if ismember(fnames{iVar}, sdNames)
                sel = ~isnan(mu(:, iVar)+sd(:, iVar));
                patch(ax, [t(sel)'; flip(t(sel)')], [mu(sel, iVar)-sd(sel, iVar); flip(mu(sel, iVar)+sd(sel, iVar))], 'r', ...
                    LineStyle='none', FaceAlpha=0.075, FaceColor=col)
            end
        end
        switch trialTypeName
            case 'press'
                xlabel(ax, 'time to bar contact (s)')
                trialTypeDispName = 'Reach';
            case 'lick'
                xlabel(ax, 'time to spout contact (s)')
                trialTypeDispName = 'Lick';
        end
%         if iExp == 1
            ylabel(ax, 'z-scored speed (a.u.)')
%         end
        plot(ax, [0, 0], [-100, 100], 'k--')
%         if iExp == 1 && iTrialType == 1
        if iTrialType == 1
            legend(ax, h, Location='northwest')
        end
%         title(ax, sprintf('%s trials (%s, N=%d)', trialTypeDispName, resultNames{iExp}, n));
        title(ax, sprintf('%s trials (%s)', trialTypeDispName, resultNames{iExp}));
        hold(ax, 'off')
    end

    set(axAll(1:2), YLim=[0, 7.5])
    set(axAll, XLim=[-3, 1])
end
clear iTrialType iExp ax fig trialTypeName h iVar axAll n


%%
tst = [-0.233333333333334	-0.266666666666680	-0.0999999999999943	-0.200000000000045	-0.533333333333303	-0.166666666666629	-0.166666666666629	-0.100000000000023	-0.133333333333326	-0.100000000000023	-0.133333333333326	-0.133333333333326	-0.133333333333326	-0.100000000000023	-0.166666666666629	-0.566666666666720	-0.133333333333326	-0.133333333333326	-0.200000000000045	-0.200000000000045	-0.166666666666629	-0.133333333333439	-0.133333333333439	-0.433333333333394	-0.166666666666742	-0.133333333333439	-0.133333333333212	-0.166666666666515	-0.0999999999999091	-0.166666666666515	-0.133333333333212	-0.0999999999999091	-0.133333333333212	-0.133333333333212	-0.133333333333212	-0.133333333333212	-0.199999999999818	-0.133333333333212	-0.133333333333212	-0.0999999999999091	-0.0999999999999091	-0.166666666666515	-0.133333333333212	-0.333333333333485	-0.166666666666515	-0.199999999999818	0	-0.0999999999999091	0	-0.166666666666970	-0.133333333333212	-0.166666666666970	-0.166666666666970	-0.199999999999818	-0.233333333333576	-0.166666666666970	-0.199999999999818	-0.166666666666970	-0.133333333333212	0	-0.133333333333212	-0.166666666666657	-0.0999999999999943	0	-0.300000000000011	-0.199999999999989	-0.266666666666652	-0.166666666666686	-0.133333333333326	0	-0.100000000000023	0	0	-0.100000000000023	-0.166666666666629	-0.333333333333371	-0.166666666666742	-0.166666666666515	-0.166666666666515	-0.133333333333212	-0.266666666666879	-0.233333333333121	-0.400000000000091	0	0	-0.233333333333121	-0.133333333333212	-0.233333333333121	-0.300000000000182	-0.133333333333212	-0.0999999999999091	0	-0.300000000000182	-0.400000000000091	-0.166666666666970	-0.100000000000364	-0.233333333333576	-0.199999999999818	-0.133333333333212	-0.133333333333212	-0.166666666666970	-0.199999999999989	-0.0999999999999943	-0.133333333333326	-0.100000000000023	-0.133333333333326	-0.133333333333326	-0.300000000000011	-0.166666666666686	-0.0666666666667197	-0.133333333333326	-0.100000000000023	-0.100000000000023	-0.133333333333326	-0.0666666666667197	-0.133333333333326	0	-0.0666666666666060	-0.0666666666666060	-0.133333333333212	-0.166666666666515	-0.133333333333212	-0.0999999999999091	-0.266666666666879	-0.0666666666666060	-0.0999999999999091	-0.166666666666515	-0.133333333333212	-0.233333333333121	-0.133333333333212	-0.0999999999999091	-0.0666666666666060	-0.0666666666666060	-0.166666666666515	-0.0999999999999091	-0.0999999999999091	-0.199999999999818	-0.133333333333212	-0.133333333333212	-0.133333333333212	0	0	-0.166666666666686	0	-0.166666666666686	-0.100000000000023	-0.133333333333326	0	-0.100000000000023	-0.133333333333326	0	-0.0666666666667197	-0.233333333333349	-0.133333333333326	-0.166666666666742	-0.133333333333439	-0.200000000000045	-0.233333333333349	-0.166666666666515	-0.266666666666879	-0.133333333333212	-0.0999999999999091	-0.0333333333333030	-0.0333333333333030	-0.0666666666666060	-0.233333333333121	-0.133333333333212	-0.233333333333576	-0.0333333333337578	0	0	0	-0.433333333333337	-0.199999999999989	-0.333333333333314	0	-0.133333333333326	-0.600000000000023	0	0	-0.433333333333280	-0.433333333333280	-0.0666666666667197	-0.100000000000023	0	-0.166666666666515	-0.233333333333121	-0.166666666666515	-0.0666666666666060	-0.199999999999818	0	0	-0.233333333333576	-0.133333333333212	-0.199999999999818	-0.100000000000364	-0.266666666666680	-0.0999999999999943	-0.166666666666657	0	-0.166666666666629	-0.199999999999818	-0.0999999999999091	-0.233333333333121	-0.266666666666879	-0.166666666666515	0	-0.199999999999818	-0.199999999999818	0	-0.166666666666515	-0.166666666666515	-0.199999999999818	-0.233333333333121	-0.199999999999818	-0.199999999999818	0	-0.133333333333212	-0.300000000000182	0	0	-0.333333333333030	-0.266666666666424	-0.300000000000182	0	0	-0.266666666666424	-0.133333333333212	-0.233333333333576	-0.199999999999818	-0.0666666666666060	-0.600000000000001	-0.133333333333326	-0.166666666666629	0	0	0	-0.633333333333212	-0.233333333333121	-0.533333333333303	0	0	0	0	-0.199999999999818	-0.133333333333212	-0.300000000000182	-0.333333333333030	-0.666666666666970	0	0	-0.766666666666424	0	-0.199999999999818	-0.500000000000000	-0.233333333333576];

p.etaSortWindow = [-3, 0];
p.etaSignWindow = [-0.3, 0];
p.etaLatencyThresholdPos = 0.5;
p.etaLatencyThresholdNeg = 0.5;

close all
pressLatency = NaN(size(eu));
lickLatency = NaN(size(eu));
[ax, ~, ~, pressLatency(c.hasPress)] = EphysUnit.plotETA(eta.press, c.hasPress, xlim=[-4,0], clim=[-2, 2], ...
    sortWindow=p.etaSortWindow, signWindow=p.etaSignWindow, ...
    sortThreshold=p.etaLatencyThresholdPos, negativeSortThreshold=p.etaLatencyThresholdNeg); 
title('Pre-reach PETH')
xlabel('Time to touchbar-contact (s)')
ax.Parent.Position(3) = 0.25;

[ax, ~, ~, lickLatency(c.hasLick)] = EphysUnit.plotETA(eta.lick, c.hasLick, xlim=[-4,0], clim=[-2, 2], ...
    sortWindow=p.etaSortWindow, signWindow=p.etaSignWindow, ...
    sortThreshold=p.etaLatencyThresholdPos, negativeSortThreshold=p.etaLatencyThresholdNeg); 
title('Pre-lick PETH')
xlabel('Time to spout-contact (s)')
ax.Parent.Position(3) = 0.25;

latency.press = pressLatency;
latency.lick = lickLatency;
latency.contraPaw = tst;
latency.pRankSum.pressVsContraPaw = ranksum(tst, pressLatency(c.isPressResponsive), tail='right');
latency.pRankSum.pressUpVsContraPaw = ranksum(tst, pressLatency(c.isPressUp), tail='right');
latency.pRankSum.pressDownVsContraPaw = ranksum(tst, pressLatency(c.isPressDown), tail='right');
latency.pRankSum.pressVsLick = ranksum(lickLatency, pressLatency, tail='right');
latency.pRankSum.pressVsContraPawPlus200 = ranksum(tst-0.2, pressLatency(c.isPressResponsive), tail='right');

fprintf(1, 'Median pre-press spiking onset latency = %.1f ms \n', median(latency.press(c.isPressResponsive)*1000, 'omitnan'))
fprintf(1, 'Median pre-press spiking onset latency (excited) = %.1f ms \n', median(latency.press(c.isPressUp)*1000, 'omitnan'))
fprintf(1, 'Median pre-press spiking onset latency (suppressed) = %.1f ms \n', median(latency.press(c.isPressDown)*1000, 'omitnan'))
fprintf(1, 'Median pre-lick spiking onset latency = %.1f ms \n', median(latency.lick(c.isLickResponsive)*1000, 'omitnan'))
fprintf(1, 'Median contralateral paw movement onset latency = %.3f ms \n', median(latency.contraPaw*1000, 'omitnan'))
fprintf(1, 'Press spiking precedes paw: One-tailed ranksum test p = %g\n', latency.pRankSum.pressVsContraPaw)
fprintf(1, 'Press spiking precedes paw (-200ms): One-tailed ranksum test p = %g\n', latency.pRankSum.pressVsContraPawPlus200)
fprintf(1, 'Excited press spiking precedes paw: One-tailed ranksum test p = %g\n', latency.pRankSum.pressUpVsContraPaw)
fprintf(1, 'Inhibited press spiking precedes paw: One-tailed ranksum test p = %g\n', latency.pRankSum.pressDownVsContraPaw)
fprintf(1, 'Press spiking precedes lick spiking: One-tailed ranksum test p = %g\n', latency.pRankSum.pressVsLick)


clear ax
p.fontSize = 9;
figure(DefaultAxesFontSize=p.fontSize, Units='inches', Position=[0 0 6 8])

ax(2) = subplot(4, 1, 1);
histogram(latency.press(c.isPressResponsive)*1000, (-2:0.1:0)*1000, Normalization='probability', FaceColor='black')
title('Pre-move response onset time')
legend(sprintf('%d units', nnz(~isnan(pressLatency(c.isPressResponsive & c.hasPress)))), Location='northwest')
ylabel('Probability')

ax(2) = subplot(4, 1, 2);
histogram(latency.press(c.isPressUp)*1000, (-2:0.1:0)*1000, Normalization='probability', FaceColor='red')
title('Pre-move response onset time (excited)')
legend(sprintf('%d units', nnz(~isnan(pressLatency(c.isPressUp & c.hasPress)))), Location='northwest')
ylabel('Probability')

ax(2) = subplot(4, 1, 3);
histogram(latency.press(c.isPressDown)*1000, (-2:0.1:0)*1000, Normalization='probability', FaceColor='blue')
title('Pre-move response onset time (suppressed)')
legend(sprintf('%d units', nnz(~isnan(pressLatency(c.isPressDown & c.hasPress)))), Location='northwest')
ylabel('Probability')

ax(1) = subplot(4, 1, 4);
histogram(latency.contraPaw*1000, (-2:0.1:0)*1000, Normalization='probability', FaceColor='black')
legend(sprintf('%g trials, %g sessions', nnz(~isnan(tst)), 7), Location='northwest')
title('Contralateral forepaw movement onset time')
xlabel('Time to touchbar-contact (ms)')
ylabel('Probability')
set(ax, FontSize=9);
