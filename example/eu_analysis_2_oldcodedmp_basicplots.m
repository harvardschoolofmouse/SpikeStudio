
%%  Plot basics for lever press
close all
sz = 5;

fig = figure(Units='pixels', OuterPosition=[0, 0, 1920, 1080], DefaultAxesFontSize=14);
ax = subplot(2, 2, 2);

nBins = 15;
edges = linspace(0, max(msr, [], 'all', 'omitnan'), nBins);
NAll = histcounts(msr(c.hasPress), edges, 'Normalization', 'probability');
NUp = histcounts(msr(c.isPressUp), edges, 'Normalization', 'probability');
NDown = histcounts(msr(c.isPressDown), edges, 'Normalization', 'probability');
centers = 0.5*(edges(2:end) + edges(1:end-1));
hold(ax, 'on')
plot(ax, centers, cumsum(NDown), 'LineWidth', 2, 'Color', 'blue', 'DisplayName', sprintf('Press-suppressed (N=%g)', nnz(c.isPressDown)))
plot(ax, centers, cumsum(NUp), 'LineWidth', 2, 'Color', 'red', 'DisplayName', sprintf('Press-activated (N=%g)', nnz(c.isPressUp)));
hold(ax, 'off')
legend(ax, 'Location', 'northeast');
ylim(ax, [0, 1])
xlabel(ax, 'Baseline spike rate (sp/s)')
ylabel(ax, 'Cumulative probability')
[ks.h, ks.p] = kstest2(msr(c.isPressDown), msr(c.isPressUp), Tail='larger');


ax = subplot(2, 2, 4);
hold(ax, 'on')
isResp = c.isPressResponsive;
isNonResp = c.hasPress & ~c.isPressResponsive;
clear h
h(1) = scatter(ax, msr(c.hasPress), meta.pressRaw(c.hasPress)./0.1 - msr(c.hasPress), sz, 'black', 'filled', DisplayName=sprintf('N=%g', nnz(c.hasPress)));
xl = ax.XLim;
plot(ax, ax.XLim, [0, 0], 'k--', LineWidth=1.5);
hold(ax, 'off')
xlabel(ax, 'Baseline spike rate (sp/s)'), ylabel(ax, '\DeltaSpike rate (sp/s)')
legend(ax, h)


ax = subplot(2, 2, 1);
histogram(ax, msr(c.isPressDown), edges)
xlabel(ax, 'Baseline spike rate (sp/s)'), ylabel(ax, 'Count')
legend(ax, sprintf('Press-suppressed (N=%g)', nnz(c.isPressDown)))

ax = subplot(2, 2, 3);
histogram(ax, msr(c.isPressUp), edges);
xlabel(ax, 'Baseline spike rate (sp/s)'), ylabel(ax, 'Count')
legend(ax, sprintf('Press-activated (N=%g)', nnz(c.isPressUp)))

% clear fig ax h isResp isNonResp xl yl sz

% Distribution of responses (normalization)
% fig = figure(Units='normalized', OuterPosition=[0, 0, 0.2, 1], DefaultAxesFontSize=12);
fig = figure(Units='inches', Position=[0, 0, 3, 7], DefaultAxesFontSize=p.fontSize);
ax = subplot(3, 1, 1);
histogram(ax, msr(c.hasPress), 15);
xlabel(ax, 'Baseline spike rate (sp/s)'), ylabel(ax, 'Count')
legend(ax, sprintf('N=%g', length(msr(c.hasPress))))

ax = subplot(3, 1, 2);
histogram(ax, meta.pressRaw(c.hasPress)./0.1 - msr(c.hasPress))
xlabel(ax, 'Pre-move response (\Deltasp/s)'), ylabel(ax, 'Count')
legend(ax, sprintf('N=%g', nnz(c.hasPress)))

ax = subplot(3, 1, 3);
histogram(ax, meta.press(c.hasPress))
xlabel(ax, 'Normalized pre-move response (a.u.)'), ylabel(ax, 'Count')
legend(ax, sprintf('N=%g', nnz(c.hasPress)))
set(fig.Children, FontSize=9);


% clear fig ax h isResp isNonResp xl yl sz

%% 3.1 Plot basics for lick
% Distribution of baseline, press response, lick response
% Baseline vs press, lick, press vs lick
close all
sz = 10;

fig = figure(Units='normalized', OuterPosition=[0 0 0.5 0.8], DefaultAxesFontSize=14);
% ax = subplot(2, 2, 1);
% histogram(ax, meta.lickRaw(c.hasLick & c.hasPress)*10 - msr(c.hasLick & c.hasPress), Normalization='probability');
% xlabel(ax, 'Spike rate (sp/s)'), ylabel(ax, 'Probability'), title(ax, 'Baseline spike rate (median, ITI)')
% 
% ax = subplot(2, 2, 2);
% histogram(ax, meta.lick(c.hasLick), Normalization='probability')
% xlabel(ax, '\Deltaz (lick, a.u.)'), ylabel(ax, 'Probability'), title(ax, sprintf('Normalized lick response (%gs-%gs, %g units)', p.metaWindow(1), p.metaWindow(2), nnz(c.hasLick)))

ax = subplot(2, 2, 3);
hold(ax, 'on')
clear h
x = msr(c.hasLick);
y = meta.lickRaw(c.hasLick)*10 - msr(c.hasLick);
h(1) = scatter(ax, x, y, sz, 'black', 'filled', DisplayName=sprintf('%g units', nnz(c.hasLick)));

xl = ax.XLim'; yl = ax.YLim';
mdl = fitlm(x, y);
h(2) = plot(ax, xl, mdl.predict(xl), 'k--', LineWidth=1.5, DisplayName=sprintf('R^2 = %.2f', mdl.Rsquared.Ordinary));
hold(ax, 'off')
xlabel(ax, 'Baseline spike rate (sp/s)'), ylabel(ax, 'Lick response (\Deltasp/s)'), title(ax, 'Lick response vs baseline')
legend(ax, h)

ax = subplot(2, 2, 4);
hold(ax, 'on')
x = meta.lickRaw(c.hasPress & c.hasLick)*10 - msr(c.hasPress & c.hasLick);
y = meta.pressRaw(c.hasPress & c.hasLick)*10 - msr(c.hasPress & c.hasLick);
clear h
h(1) = scatter(ax, x, y, sz, 'black', 'filled', DisplayName=sprintf('%g units', nnz(c.hasPress & c.hasLick)));
xl = ax.XLim; yl = ax.YLim;
ax.XLimMode = 'manual'; ax.YLimMode = 'manual'; 
mdl = fitlm(x, y);
h(2) = plot(ax, xl', mdl.predict(xl'), 'k--', LineWidth=1.5, DisplayName=sprintf('R^2 = %.2f', mdl.Rsquared.Ordinary));

plot(ax, xl, [0, 0], 'k:')
plot(ax, [0, 0], yl, 'k:')
hold(ax, 'off')
xlabel(ax, 'Lick response (\Deltasp/s)'), ylabel(ax, 'Press response (\Deltasp/s)'), title(ax, 'Press vs lick response')
legend(ax, h, Location='northwest')

% clear fig ax h isResp isNonResp xl yl sz

%% 3.2 Plot binned averaged (BTA)
% Calculate BTA
% [bta.pressUp.X, bta.pressUp.T, bta.pressUp.N, bta.pressUp.S, bta.pressUp.B] = eu(c.isPressUp).getBinnedTrialAverage('rate', p.binnedTrialEdges, 'press', 'window', [-10, 1], 'normalize', true);
% [bta.pressDown.X, bta.pressDown.T, bta.pressDown.N, bta.pressDown.S, bta.pressDown.B] = eu(c.isPressDown).getBinnedTrialAverage('rate', p.binnedTrialEdges, 'press', 'window', [-10, 1], 'normalize', true);
% [bta.pressFlat.X, bta.pressFlat.T, bta.pressFlat.N, bta.pressFlat.S, bta.pressFlat.B] = eu(c.hasPress & ~c.isPressUp & ~c.isPressDown).getBinnedTrialAverage('rate', p.binnedTrialEdges, 'press', 'window', [-10, 1], 'normalize', false);

[bta.pressUpRaw.X, bta.pressUpRaw.T, bta.pressUpRaw.N, bta.pressUpRaw.S, bta.pressUpRaw.B] = eu(c.isPressUp).getBinnedTrialAverage('rate', p.binnedTrialEdges, 'press', 'window', [-10, 1], 'normalize', false);
[bta.pressDownRaw.X, bta.pressDownRaw.T, bta.pressDownRaw.N, bta.pressDownRaw.S, bta.pressDownRaw.B] = eu(c.isPressDown).getBinnedTrialAverage('rate', p.binnedTrialEdges, 'press', 'window', [-10, 1], 'normalize', false);
% [bta.pressRaw.X, bta.pressRaw.T, bta.pressRaw.N, bta.pressRaw.S, bta.pressRaw.B] = eu(c.hasPress).getBinnedTrialAverage('rate', p.binnedTrialEdges, 'press', 'window', [-10, 1], 'normalize', false);

[bta.lickUpRaw.X, bta.lickUpRaw.T, bta.lickUpRaw.N, bta.lickUpRaw.S, bta.lickUpRaw.B] = eu(c.isLickUp).getBinnedTrialAverage('rate', p.binnedTrialEdges, 'lick', 'window', [-10, 1], 'normalize', false);
[bta.lickDownRaw.X, bta.lickDownRaw.T, bta.lickDownRaw.N, bta.lickDownRaw.S, bta.lickDownRaw.B] = eu(c.isLickDown).getBinnedTrialAverage('rate', p.binnedTrialEdges, 'lick', 'window', [-10, 1], 'normalize', false);
% [bta.lickRaw.X, bta.lickRaw.T, bta.lickRaw.N, bta.lickRaw.S, bta.lickRaw.B] = eu(c.hasLick).getBinnedTrialAverage('rate', p.binnedTrialEdges, 'lick', 'window', [-10, 1], 'normalize', false);



% [bta.lickUp.X, bta.lickUp.T, bta.lickUp.N, bta.lickUp.S, bta.lickUp.B] = eu(c.isLickUp).getBinnedTrialAverage('rate', p.binnedTrialEdges, 'lick', 'window', [-10, 1], 'normalize', true);
% [bta.lickDown.X, bta.lickDown.T, bta.lickDown.N, bta.lickDown.S, bta.lickDown.B] = eu(c.isLickDown).getBinnedTrialAverage('rate', p.binnedTrialEdges, 'lick', 'window', [-10, 1], 'normalize', true);
% [bta.lickUpRaw.X, bta.lickUpRaw.T, bta.lickUpRaw.N, bta.lickUpRaw.S, bta.lickUpRaw.B] = eu(c.isLickUp).getBinnedTrialAverage('rate', p.binnedTrialEdges, 'lick', 'window', [-10, 1], 'normalize', false);
% [bta.lickDownRaw.X, bta.lickDownRaw.T, bta.lickDownRaw.N, bta.lickDownRaw.S, bta.lickDownRaw.B] = eu(c.isLickDown).getBinnedTrialAverage('rate', p.binnedTrialEdges, 'lick', 'window', [-10, 1], 'normalize', false);

%% Plot press BTA
figure(Units='inches', Position=[0, 0, 6.5, 3.5]);
clear ax
ax(1) = subplot(2, 1, 1);
ax(2) = subplot(2, 1, 2);
EphysUnit.plotBinnedTrialAverage(ax(1), bta.pressDownRaw, [-8, 0], nsigmas=1, sem=true);
EphysUnit.plotBinnedTrialAverage(ax(2), bta.pressUpRaw, [-8, 0], nsigmas=1, sem=true);
title(ax(1), sprintf('Reach-inhibited (populaton-average, N=%i)', nnz(c.isPressDown)))
title(ax(2), sprintf('Reach-excited (populaton-average, N=%i)', nnz(c.isPressUp)))
xlabel(ax(2), 'Time to touchbar-contact (s)')
ylabel(ax, 'Spike rate (sp/s)')
h = legend(ax(1)); h.Location='southwest';
set(ax, FontSize=p.fontSize)
clear ax

%% Specific single units

figure(Units='inches', Position=[0, 0, 6.5, 3.5]);
ax(1) = subplot(2, 1, 1);
ax(2) = subplot(2, 1, 2);
[Sr.X, Sr.T, Sr.N, Sr.S, Sr.B] = eu(402-11).getBinnedTrialAverage('rate', p.binnedTrialEdges, 'press', 'window', [-10, 1], 'normalize', false);
EphysUnit.plotBinnedTrialAverage(ax(1), Sr, [-8, 0], nsigmas=1, sem=true);

[Sr.X, Sr.T, Sr.N, Sr.S, Sr.B] = eu(491-11).getBinnedTrialAverage('rate', p.binnedTrialEdges, 'press', 'window', [-10, 1], 'normalize', false);
EphysUnit.plotBinnedTrialAverage(ax(2), Sr, [-8, 0], nsigmas=1, sem=true);

title(ax(1), 'Reach-inhibited (example unit)')
title(ax(2), 'Reach-excited (example unit)')
% xlabel(ax(2), 'Time to lever-contact (s)')
ylabel(ax, 'Spike rate (sp/s)')
set(ax, FontSize=p.fontSize);
clear ax Sr

%% Plot lick BTA
figure(Units='normalized', Position=[0, 0, 0.35, 0.8], DefaultAxesFontSize=14);
clear ax
ax(1) = subplot(3, 1, 1);
ax(2) = subplot(3, 1, 2);
ax(3) = subplot(3, 1, 3);
EphysUnit.plotBinnedTrialAverage(ax(1), bta.pressRaw, [-8, 0], nsigmas=1, sem=true);
EphysUnit.plotBinnedTrialAverage(ax(2), bta.lickDownRaw, [-8, 0], nsigmas=1, sem=true);
EphysUnit.plotBinnedTrialAverage(ax(3), bta.lickUpRaw, [-8, 0], nsigmas=1, sem=true);
title(ax(1), sprintf('Whole-population (%i units)', nnz(c.hasPress)))
title(ax(2), sprintf('Lick-inhibited (%i units)', nnz(c.isPressDown)))
title(ax(3), sprintf('Lick-excited (%i units)', nnz(c.isPressUp)))
xlabel(ax(3), 'Time relative to first lick (s)')
ylabel(ax, 'Average spike rate (sp/s)')
clear ax

        
%% Plot single unit BTA (SLOW) save to DISK

plotBinnedTrialAveragedForSingleUnits(eu(c.isPressUp & c.isPressBTADifferent), 'press', 'PressUpDiff', p.binnedTrialEdges)
plotBinnedTrialAveragedForSingleUnits(eu(c.isPressDown & c.isPressBTADifferent), 'press', 'PressDownDiff', p.binnedTrialEdges)
% plotBinnedTrialAveragedForSingleUnits(eu(c.isLickUp & c.isPressBTADifferent), 'lick', 'LickUpDiff', p.binnedTrialEdges)
% plotBinnedTrialAveragedForSingleUnits(eu(c.isLickDown) & c.isPressBTADifferent, 'lick', 'LickDownDiff', p.binnedTrialEdges)

%% Plot single unit BTA (SLOW) save to DISK

plotBinnedTrialAveragedForSingleUnits(eu(c.isPressUp), 'press', 'PressUp', p.binnedTrialEdges)
plotBinnedTrialAveragedForSingleUnits(eu(c.isPressDown), 'press', 'PressDown', p.binnedTrialEdges)
plotBinnedTrialAveragedForSingleUnits(eu(c.isLickUp), 'lick', 'LickUp', p.binnedTrialEdges)
plotBinnedTrialAveragedForSingleUnits(eu(c.isLickDown), 'lick', 'LickDown', p.binnedTrialEdges)

%% 3.3 Plot ETA Heatmap
close all
EphysUnit.plotETA(eta.press, c.hasPress, xlim=[-4,0], clim=[-2, 2], sortWindow=[-3, 0], signWindow=[-0.2, 0], sortThreshold=0.6, negativeSortThreshold=0.3); title('Press ETA')
% EphysUnit.plotETA(eta.lick, cat.hasLick, xlim=[-4,0], clim=[-2, 2], sortWindow=[-3, 0], signWindow=[-0.2, 0], sortThreshold=0.6, negativeSortThreshold=0.3); title('Lick ETA')
% [~, ~, ~, latency] = EphysUnit.plotDoubleETA(eta.press, eta.lick, cat.hasPress & cat.hasLick, 'Lever-press', 'Lick', xlim=[-4,0], clim=[-2, 2], sortWindow=[-3, 0], signWindow=[-0.2, 0], sortThreshold=0.6, negativeSortThreshold=0.3);
% EphysUnit.plotDoubleETA(eta.lick, eta.press, cat.hasPress & cat.hasLick, 'Lick', 'Lever-press', xlim=[-4,0], clim=[-2, 2], sortWindow=[-3, 0], signWindow=[-0.2, 0], sortThreshold=0.6, negativeSortThreshold=0.3);

%% 3.4 Single units raster and BTAs (plot and save to disk)
% plotRasterForSingleUnits(eu(cat.isLickUp), 'lick', 'Raster_LickUp')
% plotRasterForSingleUnits(eu(cat.isLickDown), 'lick', 'Raster_LickDown')
unitsNames = { ...
    'daisy5_20190515_Channel6_Unit1'; ...
    'desmond13_20190508_Channel2_Unit1'; ...
    'daisy4_20190417_Channel6_Unit1'; ...
    'desmond10_20180911_Channel10_Unit1'; ...
    };
close all
for iEu = find(ismember(eu.getName('_'), unitsNames))
    thisRd = eu(iEu).getRasterData('press', window=[0, 0], sort=true);
    ax = EphysUnit.plotRaster(thisRd, xlim=[-4, 0]);
    ax.FontSize=p.fontSize;
    ax.Legend.FontSize=14;
    title(ax, '')
end
clear thisRd ax
% plotRasterForSingleUnits(eu(c.isPressUp), 'press', 'Raster_PressUp')
% plotRasterForSingleUnits(eu(c.isPressDown), 'press', 'Raster_PressDown')

%% 3.5 Single unit double rasters
plotDoubleRasterForSingleUnits(eu(c.isPressDown & c.isLickUp), 'DoubleRaster_PressDownLickUp')
plotDoubleRasterForSingleUnits(eu(c.isPressUp & c.isLickDown), 'DoubleRaster_PressUpLickDown')
plotDoubleRasterForSingleUnits(eu(c.isPressDown & c.isLickDown), 'DoubleRaster_PressDownLickDown')
plotDoubleRasterForSingleUnits(eu(c.isPressUp & c.isLickUp), 'DoubleRaster_PressUpLickUp')

%% Double rasters examples (lick vs press)
unitsNames = { ...
    'Daisy2_20180420_Channel14_Unit1'; ...
    'daisy13_20220106_Electrode97_Unit1'; ...
    'desmond24_20220510_Channel44_Unit1'; ...
    'daisy8_20210709_Channel7_Unit1'; ...
    };
close all
for iEu = find(ismember(eu.getName('_'), unitsNames))
    thisRdPress = eu(iEu).getRasterData('press', window=[0, 2], sort=true);
    thisRdLick = eu(iEu).getRasterData('lick', window=[0, 2], sort=true);
    ax = plotDoubleRaster(thisRdPress, thisRdLick, 'Reach', 'Lick', xlim=[-3, 2], iti=false);
    set(ax, FontSize=p.fontSize);
    set(ax(1).Parent, Units='inches', Position=[0 0 3.5 5.5]);
    xlabel(ax, '')
    if iEu > 1
        ax(1).Legend.Visible=false;
        ax(2).Legend.Visible=false;
    else
        ax(2).Legend.Visible=false;
    end
    xlabel(ax(2), 'Time to contact (s)')
end
clear thisRd ax

%%
function plotRasterForSingleUnits(eu, moveType, category)
    if ~isfolder(sprintf('C:\\SERVER\\Figures\\Single Units\\%s', category))
        mkdir(sprintf('C:\\SERVER\\Figures\\Single Units\\%s', category))
    end
    for e = eu
        try
            rd = e.getRasterData(moveType, window=[0, 0], sort=true);
            ax = EphysUnit.plotRaster(rd, xlim=[-4, 0]);
            fig = ax.Parent;
            print(fig, sprintf('C:\\SERVER\\Figures\\Single Units\\%s\\%s', category, e.getName('_')), '-dpng');            
            close(fig)
        catch ME
            fprintf(1, 'Error while processing %s.\n', e.getName('_'));
        end
        close all
    end
end

function plotDoubleRasterForSingleUnits(eu, category)
    if ~isfolder(sprintf('C:\\SERVER\\Figures\\Single Units\\%s', category))
        mkdir(sprintf('C:\\SERVER\\Figures\\Single Units\\%s', category))
    end
    for e = eu
        try
            rdpress = e.getRasterData('press', window=[0, 2], sort=true);
            rdlick = e.getRasterData('lick', window=[0, 2], sort=true);
            ax = plotDoubleRaster(rdpress, rdlick, xlim=[-4, 2], iti=false);
            fig = ax(1).Parent;
            print(fig, sprintf('C:\\SERVER\\Figures\\Single Units\\%s\\%s', category, e.getName('_')), '-dpng');            
            close(fig)
        catch ME
            fprintf(1, 'Error while processing %s.\n', e.getName('_'));
        end
        close all
    end
end
function plotBinnedTrialAveragedForSingleUnits(eu, moveType, category, edges)
    if ~isfolder(sprintf('C:\\SERVER\\Figures\\Single Units\\%s', category))
        mkdir(sprintf('C:\\SERVER\\Figures\\Single Units\\%s', category))
    end
    for e = eu
        try
            [Sr.X, Sr.T, Sr.N, Sr.S, Sr.B] = e.getBinnedTrialAverage('rate', edges, moveType, 'window', [-10, 1], 'normalize', false);
            [Sn.X, Sn.T, Sn.N, Sn.S, Sn.B] = e.getBinnedTrialAverage('rate', edges, moveType, 'window', [-10, 1], 'normalize', true);
            
            fig = figure('Units', 'normalized', 'Position', [0, 0, 0.6, 0.9]);
            ax(1) = subplot(2, 1, 1);
            ax(2) = subplot(2, 1, 2);
            EphysUnit.plotBinnedTrialAverage(ax(1), Sr, [-8, 1]);
            EphysUnit.plotBinnedTrialAverage(ax(2), Sn, [-8, 1]);
            suptitle(e.getName('_'));
            
            print(fig, sprintf('C:\\SERVER\\Figures\\Single Units\\%s\\%s', category, e.getName('_')), '-dpng');
            
            close(fig)
        catch ME
            fprintf(1, 'Error while processing %s.\n', e.getName('_'));
        end
        close all
    end
end

function ax = plotDoubleRaster(rd1, rd2, varargin)
    p = inputParser();
    p.addRequired('rd1', @isstruct)
    p.addRequired('rd2', @isstruct)
    p.addOptional('label1', '', @ischar)
    p.addOptional('label2', '', @ischar)
    p.addParameter('xlim', [-6, 1], @(x) isnumeric(x) && length(x) == 2 && x(2) > x(1));
    p.addParameter('iti', false, @islogical);
    p.addParameter('timeUnit', 's', @(x) ismember(x, {'s', 'ms'}))
    p.addParameter('maxTrials', Inf, @isnumeric)
    p.parse(rd1, rd2, varargin{:});
    r = p.Results;
    rd(1) = r.rd1;
    rd(2) = r.rd2;
    label{1} = r.label1;
    label{2} = r.label2;
    maxTrials = p.Results.maxTrials;


    disp(label)

    f = figure(Units='normalized', Position=[0, 0, 0.5, 1], DefaultAxesFontSize=14);
    nTrials(1) = min(length(rd(1).duration), maxTrials);
    nTrials(2) = min(length(rd(2).duration), maxTrials);
    xmargin = 0.16;
    ymargin = 0.09;
    ax(1) = axes(f, Position=[xmargin, 2*ymargin+nTrials(2)/sum(nTrials)*(1-0.09*3), 0.7, nTrials(1)/sum(nTrials)*(1-ymargin*3)]);
    ax(2) = axes(f, Position=[xmargin, ymargin, 0.7, nTrials(2)/sum(nTrials)*(1-ymargin*3)]);

    for i = 1:2
        EphysUnit.plotRaster(ax(i), rd(i), xlim=r.xlim, iti=r.iti, ...
            timeUnit=p.Results.timeUnit, maxTrials=maxTrials, sz=1);
        if ~isempty(label{i})
            title(ax(i), label{i})
        else
            switch lower(rd(i).trialType)
                case 'press'
                    name = 'Lever-press';
                case 'lick'
                    name = 'Lick';
                case {'stim', 'stimtrain', 'stimfirstpulse'}
                    name = 'Opto';
            end
            title(ax(i), name)
        end
%         suptitle(rd(1).name);
    end
end
