%% Behavior plots
close all
clear fig ax
edges = 0:0.5:10;

% Plot aggregate histograms as line plots
fig = figure(Units='inches', Position=[0, 0, 7, 5], DefaultAxesFontSize=p.fontSize);
ax = axes(fig);
centers = 0.5*(edges(2:end) + edges(1:end-1));
hold(ax, 'on')
ndayshown = 18;
for id = 1:ndayshown
    N = histcounts(ptcat{id}, edges, Normalization='probability');
    plot(ax, centers, N, Color=hsl2rgb([0.7*(id-1)/(ndayshown-1), 1, 0.5]), LineWidth=2.5, DisplayName=sprintf('Day %g', daysPress(id)))
    xlabel(ax, 'Contact time (s)')
    ylabel(ax, 'Probability')
end
hold(ax, 'off')
legend(ax, Location='northeast', NumColumns=2)
title(ax, sprintf('Reach task training progress (%g animals)', nAnimalsPress))
set(ax, FontSize=p.fontSize);
clear ax fig id

fig = figure(Units='inches', Position=[0, 0, 7, 5], DefaultAxesFontSize=p.fontSize);
ax = axes(fig);
hold(ax, 'on')
for id = 1:ndayshown
    N = histcounts(ltcat{id}, edges, Normalization='probability');
    plot(ax, centers, N, Color=hsl2rgb([0.7*(id-1)/(ndayshown-1), 1, 0.5]), LineWidth=2.5, DisplayName=sprintf('Day %g', daysPress(id)))
    xlabel(ax, 'Contact time (s)')
    ylabel(ax, 'Probability')
end
hold(ax, 'off')
legend(ax, Location='northeast', NumColumns=2)
title(ax, sprintf('Lick task training progress (%g animals)', nAnimalsLick))
set(ax, FontSize=p.fontSize);
clear ax fig id
%% Single units rasters, 4 examples
close all
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

%% Plot press BTA
figure(Units='inches', Position=[0, 0, 6, 5]);
clear ax
ax(1) = subplot(2, 1, 1);
ax(2) = subplot(2, 1, 2);
EphysUnit.plotBinnedTrialAverage(ax(1), bta.pressDownRaw, [-8, 0], nsigmas=1, sem=true);
EphysUnit.plotBinnedTrialAverage(ax(2), bta.pressUpRaw, [-8, 0], nsigmas=1, sem=true);
title(ax(1), sprintf('SNr reach-inhibited (populaton-average, N=%i)', nnz(c.isPressDown)))
title(ax(2), sprintf('SNr reach-excited (populaton-average, N=%i)', nnz(c.isPressUp)))
xlabel(ax(2), 'Time to touchbar-contact (s)')
ylabel(ax, 'Spike rate (sp/s)')
h = legend(ax(1)); h.Location='southwest';
set(ax, FontSize=13)
clear ax

%% OSCI vs lick vs press

naans = NaN(length(eu), 1);
stimResp = table(naans, naans, naans, naans, naans, ...
    VariableNames={'baseline', 'baselineSD', 'peak', 'latency', 'peakLatency'});
clear naans


stimResp.baseline(c.hasStim) = [isi(c.hasStim).baseline];
stimResp.baselineSD(c.hasStim) = [isi(c.hasStim).baselineSD];
stimResp.peak(c.hasStim) = [isi(c.hasStim).peak];
stimResp.latency(c.hasStim) = [isi(c.hasStim).onsetLatency];
stimResp.peakLatency(c.hasStim) = [isi(c.hasStim).peakLatency];
stimResp.baselineSR = 1000./stimResp.baseline;
stimResp.peakSR = 1000./stimResp.peak;

% Pretend this is meta
r.stim = stimResp.peakSR - stimResp.baselineSR;
r.press = meta.pressRaw*10 - msr;
r.lick = meta.lickRaw*10 - msr;
sz = 25;

figure(Units='inches', Position=[0 0 11 5], DefaultAxesFontSize=13)
clear ax
ax(1) = subplot(1, 2, 1);
sel = c.isPressResponsive & c.isLickResponsive;
scatter(ax(1), r.lick(sel), r.press(sel), sz, 'k', 'filled')
xl = ax(1).XLim;
yl = ax(1).YLim;

ax(2) = subplot(1, 2, 2);
sel = c.isPressResponsive & c.isLickResponsive & c.isLick;
scatter(ax(2), r.lick(sel), r.press(sel), sz, 'k', 'filled')

for i = 1:2
    hold(ax(i), 'on')
    plot(ax(i), [0, 0], yl, 'k:')
    plot(ax(i), xl, [0, 0], 'k:')
    hold(ax(i), 'off')
end

xlabel(ax, 'Pre-lick (\Deltasp/s)')
ylabel(ax, 'Pre-reach (\Deltasp/s)')
title(ax(1), 'All')
title(ax(2), 'Osci')
set(ax, FontSize=13)



%% 2. Plot lick vs press response by position
close all
sz = 5;

xEdges = [0 1300 2600];
yEdges = [0 4300 10000];
xPos = abs(euPos(:, 1));
yPos = abs(euPos(:, 2));

aspectRatio = 1.8;
height = 1000;
useNormalized = false;

labels = {'DM', 'VM', 'DL', 'VL'};

figure(Units='inches', Position=[0 0 5 6.5], DefaultAxesFontSize=13)

clear ax
N = histcounts2(yPos(c.hasPos & c.hasLick), xPos(c.hasPos & c.hasLick), yEdges, xEdges);

ax(1) = subplot(2, 1, 1);
sel = c.hasPos & c.isLickDown;
n1 = histcounts2(yPos(sel), xPos(sel), yEdges, xEdges);
sel = c.hasPos & c.isLickUp;
n2 = histcounts2(yPos(sel), xPos(sel), yEdges, xEdges);
sel = c.hasPos & c.isLick & c.hasLick;
n3 = histcounts2(yPos(sel), xPos(sel), yEdges, xEdges);
bar([n1(:)./N(:), n2(:)./N(:), n3(:)./N(:)])
ylabel('Fraction of units')
title('Lick')
legend({'suppressed (pre-move)', 'excited (pre-move)', 'oscillatory (lick)'}, FontSize=11, ...
    Orientation='horizontal', Position=[0.148341448746023,0.953484610393047,0.739583319208275,0.031249999275638])

xticklabels(ax, labels)
% ylim(ax(2:end), [0, 0.6]);
sum(N(:))

ax(2) = subplot(2, 1, 2);
sel = c.hasPos & c.isPressDown;
n1 = histcounts2(yPos(sel), xPos(sel), yEdges, xEdges);
sel = c.hasPos & c.isPressUp;
n2 = histcounts2(yPos(sel), xPos(sel), yEdges, xEdges);
bar([n1(:)./N(:), n2(:)./N(:)])
ylabel('Fraction of units')
title('Reach')

xticklabels(ax, labels)
sum(N(:))
set(ax, FontSize=13);

%% Movement response maps in SNr
close all
MOVETYPE = {'press', 'lick', 'lickosci'};
SEL = {c.isPressResponsive; c.isLickResponsive; c.isLick};
STATS = {meta.press, meta.lick, meta.anyLickNorm};
TITLE = {'Reach', 'Lick', 'Osci Lick'};
COLOR = {[], [], [237 177 32] ./ 255};
ALPHA = {0.125, 0.125, 0.5};

fig = figure(Units='inches', Position=[0, 0, 8, 4], DefaultAxesFontSize=13);
for iMove = 1:length(MOVETYPE)
    ax = subplot(1, length(MOVETYPE), iMove);
    sel = SEL{iMove};
    coords = euPos(sel, :);
    stats = STATS{iMove}(sel);
    AcuteRecording.plotMap(ax, coords, stats, [0 5], 0, UseSignedML=false, BubbleSize=[2, 10], MarkerAlpha=ALPHA{iMove}, Color=COLOR{iMove});
    title(ax, TITLE{iMove})
    axis(ax, 'image')
    xlim(ax, [0.9, 1.7])
    ylim(ax, [-4.8, -3.7])
    xticks(ax, [1, 1.6])
    yticks(ax, [-4.7, -3.8])
    if iMove > 1
        ylabel(ax, "");
    end
    xlabel(ax, 'ML');
    set(ax, FontSize=13)
end

%% Timing
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
ax.Parent.Position = [0, 0, 5, 7.5];
ax.FontSize = p.fontSize;



%% Stim raster (whole train examples)


% 4.1.1.2 Example stim responses (2dSPN 2iSPN)
close all
maxTrials = 100;
clear name
name{1} = 'daisy9_20211103_Electrode5_Unit1'; % ai80.inhibited
name{2} = 'daisy9_20211028_Electrode10_Unit1'; % ai80.excited

clear rrdd
for iUnit = 1:2
    iEu = find(strcmpi(name{iUnit}, eu.getName('_')));
    rrdd(iUnit) = eu(iEu).getRasterData('stimfirstpulse', window=[-0.3, 1.5], minTrialDuration=0.01, maxTrialDuration=0.01, sort=false, alignTo='start');
end


ax = plotDoubleRaster(rrdd(1), rrdd(2), xlim=[-300, 1400], timeUnit='ms', maxTrials=maxTrials);
fig = ax(1).Parent;
set(fig, Units='inches', Position=[0, 0, 13, 6.5])
set(ax, FontSize=14)
xlabel(ax(1), '')
title(ax, '')
% title(ax(1), 'dSPN stim')
ax(1).Legend.Orientation = 'horizontal';
ax(1).Legend.Location = 'southoutside';
ax(2).Legend.Visible = false;
ax(1).Legend.AutoUpdate = false;
ax(1).Legend.FontSize = 12;
ax(1).Legend.String = {'spikes', 'opto (10ms)'};
ax(1).Legend.Position = [0.673477565678648,0.926850162844623,0.187499996847831,0.040064101561139];
xlabel(ax(2), 'Time from stim train onset (ms)')
for tOn = 260:260:1040
    patch(ax(1), [tOn, tOn+10, tOn+10, tOn], [0, 0, ax(1).YLim(2), ax(1).YLim(2)], 'b', FaceAlpha=0.25, EdgeAlpha=0, DisplayName='opto');
    patch(ax(2), [tOn, tOn+10, tOn+10, tOn], [0, 0, ax(2).YLim(2), ax(2).YLim(2)], 'b', FaceAlpha=0.25, EdgeAlpha=0, DisplayName='opto');
end
%%
close all
clear name
name{1} = 'daisy9_20211103_Electrode5_Unit1'; % ai80.inhibited
name{2} = 'daisy9_20211028_Electrode10_Unit1'; % ai80.excited

clear rrdd
for iUnit = 1:2
    iEu = find(strcmpi(name{iUnit}, eu.getName('_')));
    rrdd(iUnit) = eu(iEu).getRasterData('stim', window=[-0.1, 0.1], minTrialDuration=0.01, maxTrialDuration=0.01, sort=false, alignTo='start');
end

% 4.1.1.2 Select example units and plot stim raster (GALVO ACUTE UNITS)
clear selUnit

selUnit(3).expName = 'daisy15_20220511'; %A2A
selUnit(3).channel = 37;
selUnit(3).unit = 1;

selUnit(4).expName = 'desmond24_20220510'; %A2A-suppressed, kind of weak
selUnit(4).channel = 54;
selUnit(4).unit = 1;

for iUnit = 3:4
    iEu = find(strcmpi(selUnit(iUnit).expName, {eu.ExpName}) & [eu.Channel] == selUnit(iUnit).channel & [eu.Unit] == selUnit(iUnit).unit);
    iAr = find(strcmpi(selUnit(iUnit).expName, {ar.expName}));
    iBsr = find([ar(iAr).bsr.channel] == selUnit(iUnit).channel & [ar(iAr).bsr.unit] == selUnit(iUnit).unit);
    [~, IPulse] = ar(iAr).selectStimResponse(Light=2, Duration=0.01, MLRank=2, DVRank=3);
    trials = Trial(ar(iAr).stim.tOn(IPulse), ar(iAr).stim.tOff(IPulse));
    assert(~isempty(iEu))
    rrdd(iUnit) = eu(iEu).getRasterData('stim', trials=trials, window=[-0.1, 0.1], sort=false, alignTo='start');
end



ax = plotDoubleRaster(rrdd(1), rrdd(2), xlim=[-100, 100], timeUnit='ms', maxTrials=200, sz=5);
fig = ax(1).Parent;
set(fig, Units='inches', Position=[0, 0, 3.5, 7])
set(ax, FontSize=14)
xlabel(ax(1), '')
title(ax, '')
title(ax(1), 'dSPN stim')
ax(1).Legend.Orientation = 'horizontal';
ax(1).Legend.Location = 'southoutside';
ax(2).Legend.Visible = false;
ax(1).Legend.AutoUpdate = false;
ax(1).Legend.FontSize = 12;
ax(1).Legend.String = {'spikes', 'opto (10ms)'};
ax(1).Legend.Position = [0.159226196330218,0.957638555805247,0.696428559720516,0.037202380021058];
ax(1).Legend.Visible=false;
yticks(ax, [1 200])
ylabel(ax, '')
xlabel(ax, '')

ax = plotDoubleRaster(rrdd(3), rrdd(4), xlim=[-100, 100], timeUnit='ms', maxTrials=50, sz=5);
fig = ax(1).Parent;
set(fig, Units='inches', Position=[0, 0, 3.5, 7])
set(ax, FontSize=14)
xlabel(ax(1), '')
title(ax, '')
title(ax(1), 'iSPN stim')
ax(1).Legend.Orientation = 'horizontal';
ax(1).Legend.Location = 'southoutside';
ax(2).Legend.Visible = false;
ax(1).Legend.FontSize = 12;
ax(1).Legend.String = {'spikes', 'opto (10ms)'};
ax(1).Legend.Position = [0.159226196330218,0.957638555805247,0.696428559720516,0.037202380021058];
yticks(ax, [1 50])
ylabel(ax, '')
xlabel(ax, '')


%%

%% Movement onset time vs neural onset time histograms
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
figure(DefaultAxesFontSize=13, Units='inches', Position=[0 0 6 7.5])

ax(1) = subplot(4, 1, 1);
histogram(latency.press(c.isPressResponsive)*1000, (-2:0.1:0)*1000, Normalization='probability', FaceColor='black')
title('SNr response onset')
% legend(sprintf('%d units', nnz(~isnan(pressLatency(c.isPressResponsive & c.hasPress)))), Location='northwest')
ylabel('Probability')

ax(2) = subplot(4, 1, 2);
histogram(latency.press(c.isPressUp)*1000, (-2:0.1:0)*1000, Normalization='probability', FaceColor='red')
title('SNr response onset (excited)')
% legend(sprintf('%d units', nnz(~isnan(pressLatency(c.isPressUp & c.hasPress)))), Location='northwest')
ylabel('Probability')

ax(3) = subplot(4, 1, 3);
histogram(latency.press(c.isPressDown)*1000, (-2:0.1:0)*1000, Normalization='probability', FaceColor='blue')
title('SNr response onset (suppressed)')
% legend(sprintf('%d units', nnz(~isnan(pressLatency(c.isPressDown & c.hasPress)))), Location='northwest')
ylabel('Probability')

ax(4) = subplot(4, 1, 4);
histogram(latency.contraPaw*1000, (-2:0.1:0)*1000, Normalization='probability', FaceColor='black')
% legend(sprintf('%g trials, %g sessions', nnz(~isnan(tst)), 7), Location='northwest')
title('Forepaw movement onset')
xlabel('Time to touchbar-contact (ms)')
ylabel('Probability')
set(ax, FontSize=13);
yticks(ax, [])
ylabel(ax, [])

%%

%% 6.1 Scatter press vs lick, color by stim response 
SEL = { ...
    c.hasPress & c.hasLick & c.isAi80, c.hasPress & c.hasLick & c.isA2A; ...
    };
XDATA = { ...
    meta.lickRaw*10 - msr, meta.lickRaw*10 - msr; ...
    };
YDATA = { ...
    meta.pressRaw*10 - msr, meta.pressRaw*10 - msr; ...
    };
XNAME = { ...
    'Pre-lick (\Deltasp/s)', 'Pre-lick (\Deltasp/s)'; ...
    };
YNAME = { ...
    'Pre-reach (\Deltasp/s)', 'Pre-reach (\Deltasp/s)'; ...
    };
TITLE = { ...
    'dSPN-stim', 'iSPN-stim'; ...
    };
AXIS = { ...
    zeros(size(msr)), zeros(size(msr)); ...
    };

% Same as above but as scatter
fig = figure(Units='inches', Position=[0 0 7.5 3.75]);
nrows = size(XDATA, 1);
ncols = size(XDATA, 2);
for i = 1:nrows
    for j = 1:ncols
        iAx = ncols*(i-1) + j;
        ax = subplot(nrows, ncols, iAx);
        hold(ax, 'on')
        
        x = XDATA{i, j};
        y = YDATA{i, j};
        s = abs(r.stim);% ./ max(abs(r.stim));
        s(r.stim<0) = s(r.stim<0) * 3;

        selUp = SEL{i, j} & c.isStimUp;
        selDown = SEL{i, j} & c.isStimDown;
        selFlat = SEL{i, j} & c.hasStim & ~c.isStimUp & ~c.isStimDown;

        h = gobjects(1, 2);
        h(1) = scatter(x(selUp), y(selUp), 35, 'red', 'filled', MarkerFaceAlpha=0.5, DisplayName='stim-excited');
        h(2) = scatter(x(selDown), y(selDown), 35, 'blue', 'filled', MarkerFaceAlpha=0.5, DisplayName='stim-inhibited');
%         h(1) = bubblechart(x(selUp), y(selUp), s(selUp), 'red', MarkerFaceAlpha=0.5, DisplayName='stim-excited');
%         h(2) = bubblechart(x(selDown), y(selDown), s(selDown), 'blue', MarkerFaceAlpha=0.5, DisplayName='stim-suppressed');
%         bubblesize(ax, [1 10])
%         bubblelim(ax, [5, 100])
%         bubblelegend(ax, '\Deltasp/s')
        xlabel(ax, XNAME{i, j})
        ylabel(ax, YNAME{i, j})
        title(ax, TITLE{i, j})
        if i == 1 && j == 1
            legend(ax, h, Orientation='horizontal', AutoUpdate=false, FontSize=12)
        end
    end
end

ax = findobj(fig, Type='Axes');
xl = [ax.XLim]; xl = [min(xl), max(xl)];
yl = [ax.YLim]; yl = [min(yl), max(yl)];

for i = 1:length(ax)
        plot(ax(i), xl, [0, 0], 'k:')
        plot(ax(i), [0, 0], yl, 'k:')
        
        xlim(ax, xl);
        ylim(ax, yl);
end
set(ax, FontSize=13)

%% Bar plots for stim vs. move (congruent lick and reach)
SEL_MOVE = {c.isPressUp, c.isPressDown, c.isLickUp, c.isLickDown, c.isPressUp & c.isLickUp, c.isPressDown & c.isLickDown};
% XTICK_MOVE = {'reach-excited', 'reach-inhibited', 'lick-excited', 'lick-inhibited', 'both-excited', 'both-inhibited'};
XTICK_MOVE = {'reach+', 'reach-', 'lick+', 'lick-', 'both+', 'both-'};
SEL_STIM = {c.isAi80 & c.hasStimResponse, c.isA2A & c.hasStimResponse};
TITLE_STIM = {'dSPN-stim', 'iSPN-stim'};

close all
clear i
clc
figure(Units='inches', Position=[0 0 6 6])
for iStim = 1:length(SEL_STIM)
    ax = subplot(2, 1, iStim);
    N = zeros(length(SEL_MOVE), 2);
    n = zeros(length(SEL_MOVE), 2);
    for iMove = 1:length(SEL_MOVE)
        N(iMove, 1) = nnz(SEL_MOVE{iMove} & SEL_STIM{iStim} & c.isStimDown);
        N(iMove, 2) = nnz(SEL_MOVE{iMove} & SEL_STIM{iStim} & c.isStimUp);
        n(iMove, 1) = N(iMove, 1) / nnz(SEL_MOVE{iMove} & SEL_STIM{iStim});
        n(iMove, 2) = N(iMove, 2) / nnz(SEL_MOVE{iMove} & SEL_STIM{iStim});
    end
    disp(N)
    for j = 1:2:length(SEL_MOVE)
        [~, pp] = fishertest(N(j:j+1, :)); fprintf(1, '%g ', pp)
    end
    fprintf(1, '\n')
%     bar(ax, n)
%     ylim(ax, [0, 1])
    bar(ax, N)
    title(ax, TITLE_STIM{iStim})
%     if iStim == 1
%         xticks(ax, [])
        legend(ax, {'stim-inhibited', 'stim-excited'}, FontSize=12)
%     else
        xticklabels(ax, XTICK_MOVE)
%     end
    ylabel(ax, 'No. units')
    ax.FontSize=13;
end
%% SNr receptive fields, 2 example units
clear selUnit
close all
selUnit(1).expName = 'daisy15_20220511';
selUnit(1).channel = 31;
selUnit(1).unit    = 1;

selUnit(2).expName = 'desmond23_20220504';
selUnit(2).channel = 67;
selUnit(2).unit    = 1;

if ~exist('ar')
    ar = AcuteRecording.load('C:\SERVER\Acute\AcuteRecording');
end

for iUnit = 1:length(selUnit)
    iAr = find(strcmpi(selUnit(iUnit).expName, {ar.expName}));
    bsr = ar(iAr).bsr;
    iBsr = find([bsr.channel] == selUnit(iUnit).channel & [bsr.unit] == selUnit(iUnit).unit);
    ar(iAr).plotStimResponse([0.4 0.5 2], [0.01 0.05], {'heatmap'}, Units=iBsr, ...
        HeatmapCLim=[-1, 1], Print=false, Position=[0 0 0.7 0.7]);
end



%% Str-SNr projective fields
%% Plot latency Str/SNr map
% expNameWhiteLists = {ar(arrayfun(@(ar) length(ar.bsr), ar) > 31).expName};

% close all

SEL = { ...
    c.isAi80; ...
    c.isA2A; ...
    };
STATS = {'response'; 'response'};
TITLE = {'dSPN-stim response', 'iSPN-stim response'};
EXPECTED_SIGN = [-1; 1;];
EXPECTED_LATENCY = [12, 12];

for iFig = 1:length(SEL)
    fig = figure(Units='inches', Position=[0, 0, 4, 7.5], DefaultAxesFontSize=12);
    for iML = 1:2
        for iDV = 1:4
            if iML == 1
                switch iDV
                    case 1
                        i = 7;
                    case 2
                        i = 5;
                    case 3
                        i = 3;
                    case 4
                        i = 1;
                end
            elseif iML == 2
                switch iDV
                    case 1
                        i = 8;
                    case 2
                        i = 6;
                    case 3
                        i = 4;
                    case 4
                        i = 2;
                end
            end
            switch iML
                case 1
                    mlText = 'mStr';
                case 2
                    mlText = 'lStr';
            end
            switch iDV
                case 4
                    dvText = '-2.15';
                case 3
                    dvText = '-2.81';
                case 2
                    dvText = '-3.48';
                case 1
                    dvText = '-4.15';
            end 
            ax = subplot(4, 2, i);
            sel = squeeze(c.hasStimResponseSpatial(iML, iDV, :))' & SEL{iFig};
            coords = euPos(sel, :);

            latencies = [isiSpatial(iML, iDV, sel).onsetLatency];
            directions = ones(1, length(eu));
            directions(c.isStimDownSpatial(iML, iDV, :)) = -1;
            directions = directions(sel);
            responses = 1000./[isiSpatial(iML, iDV, sel).peak] - 1000./[isiSpatial(iML, iDV, sel).baseline];

            switch STATS{iFig}
                case 'latency'
                    stats = directions .* latencies;
                    srange = [5, 30];
                    bsrange = [2, 10];
                    sthreshold = 0;
                case 'response'
                    stats = responses;
                    stats(responses < 0) = stats(responses < 0) * 5;
                    srange = [0 30];
%                     srange = [0, 7.5];
%                     bsrange = [1, 15];
                    bsrange = [2, 10];
                    sthreshold = 0;
            end

%             subsel = latencies <= EXPECTED_LATENCY(iFig) & directions == EXPECTED_SIGN(iFig);
%             h = AcuteRecording.plotMap(ax, coords(subsel, :), stats(subsel), srange, sthreshold, UseSignedML=false, BubbleSize=bsrange, MarkerAlpha=0.4);
            h = AcuteRecording.plotMap(ax, coords, stats, srange, sthreshold, UseSignedML=false, BubbleSize=bsrange, MarkerAlpha=0.4);
            if iML > 1
                ylabel(ax, "");
            end
            if iDV > 1
                xlabel(ax, "");
            else
                xlabel(ax, 'ML');
            end
            title(ax, sprintf('%s %s', mlText, dvText))
            axis(ax, 'image')
            xlim(ax, [0.9, 1.7])
            ylim(ax, [-4.8, -3.7])
            xticks(ax, [1, 1.6])
            yticks(ax, [-4.7, -3.8])
            xlabel(ax, '')
            ylabel(ax, '')
            if iML == 1 && iDV == 1
                title(ax, 'VMS')
            elseif iML == 1 && iDV == 4
                title(ax, 'DMS')
            elseif iML == 2 && iDV == 1
                title(ax, 'VLS')
            elseif iML == 2 && iDV == 4
                title(ax, 'DLS')
            else
                title(ax, '')
            end
        end
    end
%     suptitle(TITLE(iFig))
end

%% Plot latency Str/SNr map
% expNameWhiteLists = {ar(arrayfun(@(ar) length(ar.bsr), ar) > 31).expName};

% close all

SEL = { ...
    c.isAi80; ...
    c.isA2A; ...
    };
STATS = {'response'; 'response'};
TITLE = {'dSPN-stim response', 'iSPN-stim response'};
EXPECTED_SIGN = [-1; 1;];
EXPECTED_LATENCY = [12, 12];

for iFig = 1:length(SEL)
    fig = figure(Units='inches', Position=[0, 0, 4, 7.5], DefaultAxesFontSize=12);
    for iML = 1:2
        for iDV = 1:4
            if iML == 1
                switch iDV
                    case 1
                        i = 7;
                    case 2
                        i = 5;
                    case 3
                        i = 3;
                    case 4
                        i = 1;
                end
            elseif iML == 2
                switch iDV
                    case 1
                        i = 8;
                    case 2
                        i = 6;
                    case 3
                        i = 4;
                    case 4
                        i = 2;
                end
            end
            switch iML
                case 1
                    mlText = 'mStr';
                case 2
                    mlText = 'lStr';
            end
            switch iDV
                case 4
                    dvText = '-2.15';
                case 3
                    dvText = '-2.81';
                case 2
                    dvText = '-3.48';
                case 1
                    dvText = '-4.15';
            end 
            ax = subplot(4, 2, i);
            sel = squeeze(c.hasStimResponseSpatial(iML, iDV, :))' & SEL{iFig};
            coords = euPos(sel, :);

            latencies = [isiSpatial(iML, iDV, sel).onsetLatency];
            directions = ones(1, length(eu));
            directions(c.isStimDownSpatial(iML, iDV, :)) = -1;
            directions = directions(sel);
            responses = 1000./[isiSpatial(iML, iDV, sel).peak] - 1000./[isiSpatial(iML, iDV, sel).baseline];

            switch STATS{iFig}
                case 'latency'
                    stats = directions .* latencies;
                    srange = [5, 30];
                    bsrange = [2, 10];
                    sthreshold = 0;
                case 'response'
                    stats = responses;
                    stats(responses < 0) = stats(responses < 0) * 5;
                    srange = [0 30];
%                     srange = [0, 7.5];
%                     bsrange = [1, 15];
                    bsrange = [2, 10];
                    sthreshold = 0;
            end

            subsel = latencies <= EXPECTED_LATENCY(iFig) & directions == EXPECTED_SIGN(iFig);
            h = AcuteRecording.plotMap(ax, coords(subsel, :), stats(subsel), srange, sthreshold, UseSignedML=false, BubbleSize=bsrange, MarkerAlpha=0.4);
%             h = AcuteRecording.plotMap(ax, coords, stats, srange, sthreshold, UseSignedML=false, BubbleSize=bsrange, MarkerAlpha=0.4);
            if iML > 1
                ylabel(ax, "");
            end
            if iDV > 1
                xlabel(ax, "");
            else
                xlabel(ax, 'ML');
            end
            title(ax, sprintf('%s %s', mlText, dvText))
            axis(ax, 'image')
            xlim(ax, [0.9, 1.7])
            ylim(ax, [-4.8, -3.7])
            xticks(ax, [1, 1.6])
            yticks(ax, [-4.7, -3.8])
            xlabel(ax, '')
            ylabel(ax, '')
            if iML == 1 && iDV == 1
                title(ax, 'VMS')
            elseif iML == 1 && iDV == 4
                title(ax, 'DMS')
            elseif iML == 2 && iDV == 1
                title(ax, 'VLS')
            elseif iML == 2 && iDV == 4
                title(ax, 'DLS')
            else
                title(ax, '')
            end
        end
    end
%     suptitle(TITLE(iFig))
end



%% Salt and pepper map (dSPN/iSPN stim)
close all
SEL = { ...
    c.isAi80; ...
    c.isA2A; ...
    };
STATS = {'response'; 'response'};
TITLE = {'dSPN-stim response', 'iSPN-stim response'};
EXPECTED_SIGN = [-1; 1;];
EXPECTED_LATENCY = [12, 12];

% colors = {[0.6350 0.0780 0.1840], [0.4660 0.6740 0.1880], [0 0.4470 0.7410], [0.4940 0.1840 0.5560]	};
colors = {[1 0 0], [0.4660 0.6740 0.1880], [0 0 1], [0.9290 0.6940 0.1250]	};

for iFig = 1:length(SEL)
    fig = figure(Units='inches', Position=[0, 0, 3, 4], DefaultAxesFontSize=12);
    ax = axes(fig);
    hold(ax, 'on')
    for iML = 1:2
        for iDV = 1:4
            if iML == 1
                switch iDV
                    case 4
                        i = 1;
                    case 3
                        i = 2;
                    case 2
                        i = 3;
                    case 1
                        i = 4;
                end
            elseif iML == 2
                switch iDV
                    case 4
                        i = 5;
                    case 3
                        i = 6;
                    case 2
                        i = 7;
                    case 1
                        i = 8;
                end
            end
            switch iML
                case 1
                    mlText = 'mStr';
                case 2
                    mlText = 'lStr';
            end
            switch iDV
                case 4
                    dvText = '-2.15';
                case 3
                    dvText = '-2.81';
                case 2
                    dvText = '-3.48';
                case 1
                    dvText = '-4.15';
            end 
            sel = squeeze(c.hasStimResponseSpatial(iML, iDV, :))' & SEL{iFig};
            coords = euPos(sel, :);

            latencies = [isiSpatial(iML, iDV, sel).onsetLatency];
            directions = ones(1, length(eu));
            directions(c.isStimDownSpatial(iML, iDV, :)) = -1;
            directions = directions(sel);
            responses = 1000./[isiSpatial(iML, iDV, sel).peak] - 1000./[isiSpatial(iML, iDV, sel).baseline];

            switch STATS{iFig}
                case 'latency'
                    stats = directions .* latencies;
                    srange = [5, 30];
                    bsrange = [2, 10];
                    sthreshold = 0;
                case 'response'
                    stats = responses;
                    stats(responses < 0) = stats(responses < 0) * 5;
                    srange = [0 30];
%                     srange = [0, 7.5];
%                     bsrange = [1, 15];
                    bsrange = [5, 6];
                    sthreshold = 0;
            end

%             subsel = latencies <= EXPECTED_LATENCY(iFig) & directions == EXPECTED_SIGN(iFig);
%             h = AcuteRecording.plotMap(ax, coords(subsel, :), stats(subsel), srange, sthreshold, UseSignedML=false, BubbleSize=bsrange, MarkerAlpha=0.1, Color=hsl2rgb([0.8*(ceil(i/2)-1)/(4-1), 1, 0.5]));
            h(i) = AcuteRecording.plotMap(ax, coords, stats, srange, sthreshold, UseSignedML=false, BubbleSize=bsrange, ...
                MarkerAlpha=0.33, Color=colors{ceil(i/2)}, ...
                XJitter='rand', XJitterWidth=0.1, LineWidth=0.5);
            
            if iML > 1
                ylabel(ax, "");
            end
            if iDV > 1
                xlabel(ax, "");
            else
                xlabel(ax, 'ML');
            end
            title(ax, sprintf('%s %s', mlText, dvText))
            axis(ax, 'image')
            xlim(ax, [0.9, 1.7])
            ylim(ax, [-4.8, -3.7])
            xticks(ax, [1, 1.6])
            yticks(ax, [-4.7, -3.8])
            xlabel(ax, '')
            ylabel(ax, '')
            if iML == 1 && iDV == 1
                h(i).DisplayName = 'VMS';
            elseif iML == 1 && iDV == 4
                h(i).DisplayName = 'DMS';
            elseif iML == 2 && iDV == 1
                h(i).DisplayName = 'VLS';
            elseif iML == 2 && iDV == 4
                h(i).DisplayName = 'DLS';
            else
                h(i).DisplayName = '';
            end
        end
    end
    title(ax, TITLE{iFig})
    legend(ax, h([1, 4, 5, 8]))
%     suptitle(TITLE(iFig))
end
clear h

%% Functions


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
    p.addParameter('sz', 2.5, @isnumeric)
    p.parse(rd1, rd2, varargin{:});
    r = p.Results;
    rd(1) = r.rd1;
    rd(2) = r.rd2;
    label{1} = r.label1;
    label{2} = r.label2;
    maxTrials = p.Results.maxTrials;


    f = figure(Units='normalized', OuterPosition=[0, 0, 0.5, 1], DefaultAxesFontSize=14);
    nTrials(1) = min(length(rd(1).duration), maxTrials);
    nTrials(2) = min(length(rd(2).duration), maxTrials);
    xmargin = 0.16;
    ymargin = 0.09;
    disp(nTrials)
    ax(1) = axes(f, Position=[xmargin, 2*ymargin+nTrials(2)/sum(nTrials)*(1-0.09*3), 0.7, nTrials(1)/sum(nTrials)*(1-ymargin*3)]);
    ax(2) = axes(f, Position=[xmargin, ymargin, 0.7, nTrials(2)/sum(nTrials)*(1-ymargin*3)]);

    for i = 1:2
        EphysUnit.plotRaster(ax(i), rd(i), xlim=r.xlim, iti=r.iti, ...
            timeUnit=p.Results.timeUnit, maxTrials=maxTrials, sz=r.sz);
        if ~isempty(label{i})
            title(ax(i), label{i})
        else
            switch lower(rd(i).trialType)
                case 'press'
                    name = 'Reach';
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