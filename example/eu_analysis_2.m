%% 1.1 Make eu objects (SLOW, takes ~60min)
load('C:\SERVER\PETH_All_aggregate_20220201.mat')
ar = AcuteRecording.load();

eu = EphysUnit(PETH, 'cullITI', true, 'extendedWindow', [-1, 2], 'readWaveforms', true);
for i = 1:length(ar)
    clear eu
    try  
        eu = EphysUnit(ar(i), 'cullITI', true, 'extendedWindow', [-1, 2], 'readWaveforms', true);
    catch ME
        warning('Error while processing file %g (%s)', i, ar(i).expName);
    end
end

%% 1.2 Alternatively, load eu objects from disk (SLOW, ~20min)
eu = EphysUnit.load('C:\SERVER\Units', waveforms=false, spikecounts=false, spikerates=false);
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
p.cueEtaWindow = [-2, 4];
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
eta.press = eu.getETA('count', 'press', p.etaWindow, minTrialDuration=p.minTrialDuration, normalize=p.etaNorm);
eta.lick = eu.getETA('count', 'lick', p.etaWindow, minTrialDuration=p.minTrialDuration, normalize=p.etaNorm);
eta.pressRaw = eu.getETA('count', 'press', p.etaWindow, minTrialDuration=p.minTrialDuration, normalize='none');
eta.lickRaw = eu.getETA('count', 'lick', p.etaWindow, minTrialDuration=p.minTrialDuration, normalize='none');
eta.pressCue = eu.getETA('count', 'press', p.cueEtaWindow, alignTo='start', minTrialDuration=p.minTrialDuration, normalize=eta.press.stats, includeInvalid=true);
eta.lickCue = eu.getETA('count', 'lick', p.cueEtaWindow, alignTo='start', minTrialDuration=p.minTrialDuration, normalize=eta.lick.stats, includeInvalid=true);
eta.pressCueRaw = eu.getETA('count', 'press', p.cueEtaWindow, alignTo='start', minTrialDuration=p.minTrialDuration, normalize='none', includeInvalid=true);
eta.lickCueRaw = eu.getETA('count', 'lick', p.cueEtaWindow, alignTo='start', minTrialDuration=p.minTrialDuration, normalize='none', includeInvalid=true);

meta.press = transpose(mean(eta.press.X(:, eta.press.t >= p.metaWindowPress(1) & eta.press.t <= p.metaWindowPress(2)), 2, 'omitnan'));
meta.lick = transpose(mean(eta.lick.X(:, eta.lick.t >= p.metaWindowLick(1) & eta.lick.t <= p.metaWindowLick(2)), 2, 'omitnan'));
meta.pressRaw = transpose(mean(eta.pressRaw.X(:, eta.pressRaw.t >= p.metaWindowPress(1) & eta.pressRaw.t <= p.metaWindowPress(2)), 2, 'omitnan'));
meta.lickRaw = transpose(mean(eta.lickRaw.X(:, eta.lickRaw.t >= p.metaWindowLick(1) & eta.lickRaw.t <= p.metaWindowLick(2)), 2, 'omitnan'));


% 2.3.2 Basic summaries (fast)
% hasPress/hasLick
c.hasPress = arrayfun(@(e) nnz(e.getTrials('press').duration() >= p.minTrialDuration) >= p.minNumTrials, eu);
c.hasLick = arrayfun(@(e) nnz(e.getTrials('lick').duration() >= p.minTrialDuration) >= p.minNumTrials, eu);

% press/lick x Up/Down
% c.isPressUp =         c.hasPress & meta.press >= p.posRespThreshold;
% c.isPressDown =       c.hasPress & meta.press <= p.negRespThreshold;
% c.isPressResponsive = c.isPressUp | c.isPressDown;
% c.isLickUp =          c.hasLick & meta.lick >= p.posRespThreshold;
% c.isLickDown =        c.hasLick & meta.lick <= p.negRespThreshold;
% c.isLickResponsive =  c.isLickUp | c.isLickDown;

% animal info
c.isWT = arrayfun(@(eu) strcmpi(getAnimalInfo(eu, ai, 'strain'), 'wt'), eu);
c.isD1 = arrayfun(@(eu) strcmpi(getAnimalInfo(eu, ai, 'strain'), 'd1-cre'), eu);
c.isA2A = arrayfun(@(eu) strcmpi(getAnimalInfo(eu, ai, 'strain'), 'a2a-cre'), eu);
c.isAi80 = arrayfun(@(eu) strcmpi(getAnimalInfo(eu, ai, 'strain'), 'd1-cre;dlx-flp;ai80'), eu);
c.isDAT = arrayfun(@(eu) strcmpi(getAnimalInfo(eu, ai, 'strain'), 'dat-cre'), eu);
c.isAcute = ismember(eu.getAnimalName, {'daisy14', 'daisy15', 'daisy16', 'desmond23', 'desmond24', 'desmond25', 'desmond26', 'desmond27'});

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
    '\t%g (%.0f%%) are excited (meta>=%g);\n' ...
    '\t%g (%.0f%%) are inhibited (meta<=%g).\n'], ...
    nnz(c.hasPress), p.minNumTrials, p.minTrialDuration, ...
    nnz(c.isPressUp), 100*nnz(c.isPressUp)/nnz(c.isPressResponsive), p.posRespThreshold, ...
    nnz(c.isPressDown), 100*nnz(c.isPressDown)/nnz(c.isPressResponsive), p.negRespThreshold);

fprintf(1, ['%g units with %g+ lick trials (%gs or longer):\n' ...
    '\t%g (%.0f%%) are excited (meta>=%g);\n' ...
    '\t%g (%.0f%%) are inhibited (meta<=%g).\n'], ...
    nnz(c.hasLick), p.minNumTrials, p.minTrialDuration, ...
    nnz(c.isLickUp), 100*nnz(c.isLickUp)/nnz(c.isLickResponsive), p.posRespThreshold, ...
    nnz(c.isLickDown), 100*nnz(c.isLickDown)/nnz(c.isLickResponsive), p.negRespThreshold);

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
clear nTotal

%% Trial counting
close all
nPress2s = arrayfun(@(eu) nnz(eu.getTrials('press').duration > 2), eu);
nLick2s = arrayfun(@(eu) nnz(eu.getTrials('lick').duration > 2), eu);
nPress = arrayfun(@(eu) length(eu.getTrials('press')), eu);
nLick = arrayfun(@(eu) length(eu.getTrials('lick')), eu);

figure;
subplot(4, 1, 1);
histogram(nPress2s, 0:10:500)
title('Press (2s+)')
xlabel('Number of trials')
ylabel('Number of units')

subplot(4, 1, 2);
histogram(nLick2s, 0:10:500)
title('Lick (2s+)')
xlabel('Number of trials')
ylabel('Number of units')

subplot(4, 1, 3);
histogram(nPress, 0:10:500)
title('Press (any)')
xlabel('Number of trials')
ylabel('Number of units')

subplot(4, 1, 4);
histogram(nLick, 0:10:500)
title('Lick (any)')
xlabel('Number of trials')
ylabel('Number of units')

%% 2. Oscilatory lick analysis

eta.anyLick = eu.getETA('count', 'anylick', [-0.25, 0.25], resolution=0.01, normalize='iti');
eta.anyLickRaw = eu.getETA('count', 'anylick', [-0.25, 0.25], resolution=0.01, normalize='none');

close all
t = eta.anyLickRaw.t; 
x = eta.anyLickRaw.X'*100;
x = normalize(x, 1, 'zscore', 'robust');
eta.anyLickNorm = eta.anyLickRaw;
eta.anyLickNorm.X = x';

ax = axes();
hold(ax, 'on')
clear P8 P6 P10
for i = 1:size(x, 2)
    Y = fft(x(:, i));
    Fs = 100;            % Sampling frequency                    
    T = 1/Fs;             % Sampling period       
    L = length(t);             % Length of signal
    t = (0:L-1)*T;        % Time vector
    
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(L/2))/L;
    plot(ax, f,P1) 
    title('Single-Sided Amplitude Spectrum of X(t)')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
    P8(i) = P1(f==8);
    P6(i) = P1(f==6);
    P10(i) = P1(f==10);
    P16(i) = P1(f==16);
    P14(i) = P1(f==14);
    P18(i) = P1(f==18);
end

theta = 0.5;
relTheta = 0;
isLick = P8 > P6 + relTheta & P8 > P10 + relTheta & P16 > P14 + relTheta & P16 > P18 + relTheta & P8 > theta;
c.isLick = isLick;
nnz(isLick)
figure()
ax = subplot(1, 2, 1);
plot(t, x(:, isLick))
title(sprintf('N = %g (%.1f%%)', nnz(isLick), 100*nnz(isLick)/length(eu)))

ax = subplot(1, 2, 2); hold(ax, 'on')
Fs = 100;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = length(t);             % Length of signal
t = (0:L-1)*T;        % Time vector
f = Fs*(0:(L/2))/L;

P = zeros(26, nnz(isLick));
for i = find(isLick)
    Y = fft(x(:, i));
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    P(:, i) = P1;
end
plot(f, P1)
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

signWindow = [-0.13, -0.01];
sortWindow = [-0.13, -0.01];
plotWindow = [-0.25, 0.25];
EphysUnit.plotETA(eta.anyLickNorm, [], xlim=plotWindow, clim=[-2 2], sortWindow=sortWindow, signWindow=signWindow, sortThreshold=0.5, negativeSortThreshold=Inf); title('Lick ETA')
ax = EphysUnit.plotETA(eta.anyLickNorm, isLick, xlim=plotWindow, clim=[-2 2], sortWindow=sortWindow, signWindow=signWindow, sortThreshold=0.5, negativeSortThreshold=Inf); title('Lick ETA')
ax.Parent.Position(3) = 0.25;
ax.Parent.Position(4) = 0.4;%1*nnz(isLick)/nnz(c.hasLick);
xlabel(ax, 'Time to lick (s)')
title(ax, 'Lick ETA (ITI)')


% ax = EphysUnit.plotETA(eta.anyLickNorm, c.isLick & c.isLickResponsive, xlim=plotWindow, clim=[-4 4], sortWindow=sortWindow, signWindow=signWindow, sortThreshold=0.5, negativeSortThreshold=Inf); title('Lick ETA')
% ax.Parent.Position(3) = 0.25;
% ax.Parent.Position(4) = 1*nnz(c.isLick & c.isLickResponsive)/nnz(c.hasLick);
% xlabel(ax, 'Time relative to lick (s)')
% title(ax, 'Lick ETA (ITI)')

[ax, ~, ~, latency] = EphysUnit.plotDoubleETA(eta.anyLickNorm, eta.lick, c.isLick & c.isLickResponsive, 'Lick (ITI)', 'First Lick', xlim=[-4,0], clim=[-2, 2], sortWindow=sortWindow, signWindow=signWindow, sortThreshold=0.5, negativeSortThreshold=Inf); 
xlabel(ax(1), 'Time to lick (s)'); xlabel(ax(2), 'Time to first lick (s)')
xlim(ax(1), [-0.25, 0.25])
ax(1).FontSize=12;
ax(2).FontSize=12;
ax(1).Parent.Position(4) = 0.4;%1*nnz(c.isLick & c.isLickResponsive)/nnz(c.isLickResponsive & c.hasPress);


%%
fprintf(1, 'Out of %g units, %g (%.1f%%) has oscilatory lick-related activity.\n', length(eu), nnz(c.isLick), nnz(c.isLick) / length(eu) * 100);
fprintf(1, 'Out of %g lick-responsive units, %g (%.1f%%) has oscilatory lick-related activity.\n', nnz(c.isLickResponsive), nnz(c.isLick & c.isLickResponsive), nnz(c.isLick & c.isLickResponsive) / nnz(c.isLick) * 100)
fprintf(1, '\t%g (%.1f%%) are lick activated, %g(%.1f%%) are suppressed.\n', nnz(c.isLick & c.isLickUp), nnz(c.isLick & c.isLickUp) / nnz(c.isLick & c.isLickResponsive) * 100, ...
        nnz(c.isLick & c.isLickDown), nnz(c.isLick & c.isLickDown) / nnz(c.isLick & c.isLickResponsive) * 100)


t = eta.anyLickNorm.t;
meta.anyLickNorm = transpose(mean(eta.anyLickNorm.X(:, t >= -0.05 & t < 0), 2, 'omitnan'));


%% 4.1.1.2 Example stim responses (2dSPN 2iSPN)
close all
maxTrials = 200;
clear name
name{1} = 'daisy9_20211103_Electrode5_Unit1'; % ai80.inhibited
name{2} = 'daisy9_20211028_Electrode10_Unit1'; % ai80.excited

clear rrdd
for iUnit = 1:2
    iEu = find(strcmpi(name{iUnit}, eu.getName('_')));
%     rrdd(i) = rdStimFiltered(iEu);
    rrdd(iUnit) = eu(iEu).getRasterData('stim', window=[-0.1, 0.1], minTrialDuration=0.01, maxTrialDuration=0.01, sort=false, alignTo='start');
end


% 4.1.1.2 Select example units and plot stim raster (GALVO ACUTE UNITS)
clear selUnit
maxTrials = Inf;

selUnit(3).expName = 'daisy15_20220511'; %A2A
selUnit(3).channel = 37;
selUnit(3).unit = 1;

selUnit(4).expName = 'desmond24_20220510'; %A2A-suppressed, kind of weak
selUnit(4).channel = 52;
selUnit(4).unit = 1;

for iUnit = 3:4
    iEu = find(strcmpi(selUnit(iUnit).expName, {eu.ExpName}) & [eu.Channel] == selUnit(iUnit).channel & [eu.Unit] == selUnit(iUnit).unit);
    iAr = find(strcmpi(selUnit(iUnit).expName, {ar.expName}));
    iBsr = find([ar(iAr).bsr.channel] == selUnit(iUnit).channel & [ar(iAr).bsr.unit] == selUnit(iUnit).unit);
    [~, IPulse] = ar(iAr).selectStimResponse(Light=2, Duration=0.01, MLRank=2, DVRank=3);
    trials = Trial(ar(iAr).stim.tOn(IPulse), ar(iAr).stim.tOff(IPulse));
    assert(~isempty(iEu))
%     rrdd(i) = rdStimFiltered(iEu);
    rrdd(iUnit) = eu(iEu).getRasterData('stim', trials=trials, window=[-0.1, 0.1], minTrialDuration=0, maxTrialDuration=Inf, sort=false, alignTo='start');
end



ax = plotDoubleRaster(rrdd(1), rrdd(2), xlim=[-100, 100], timeUnit='ms', maxTrials=maxTrials);
fig = ax(1).Parent;
set(fig, Units='pixels', Position=[0, 0, 300, 600])
set(ax, FontSize=10)
xlabel(ax(1), '')
title(ax, '')
title(ax(1), 'dSPN stim')
ax(1).Legend.Orientation = 'horizontal';
ax(1).Legend.Location = 'southoutside';
ax(2).Legend.Visible = false;

% 4.1.1.2 Select example units and plot stim raster (GALVO ACUTE UNITS)
clear selUnit
maxTrials = 50;

selUnit(1).expName = 'daisy15_20220511';
selUnit(1).channel = 37;
selUnit(1).unit = 1;

selUnit(2).expName = 'desmond24_20220510';
selUnit(2).channel = 52;
selUnit(2).unit = 1;


clear rrdd
for i = 1:2
    iEu = find(strcmpi(selUnit(i).expName, {eu.ExpName}) & [eu.Channel] == selUnit(i).channel & [eu.Unit] == selUnit(i).unit);
    iAr = find(strcmpi(selUnit(i).expName, {ar.expName}));
    iBsr = find([ar(iAr).bsr.channel] == selUnit(i).channel & [ar(iAr).bsr.unit] == selUnit(i).unit);
    [~, IPulse] = ar(iAr).selectStimResponse(Light=2, Duration=0.01, MLRank=2, DVRank=3);
    trials = Trial(ar(iAr).stim.tOn(IPulse), ar(iAr).stim.tOff(IPulse));
    assert(~isempty(iEu))
%     rrdd(i) = rdStimFiltered(iEu);
    rrdd(i) = eu(iEu).getRasterData('stim', trials=trials, window=[-0.1, 0.1], minTrialDuration=0, maxTrialDuration=Inf, sort=false, alignTo='start');
end

ax = plotDoubleRaster(rrdd(1), rrdd(2), xlim=[-100, 100], timeUnit='ms', maxTrials=maxTrials);
fig = ax(1).Parent;
set(fig, Units='pixels', Position=[0, 0, 300, 600])
set(ax, FontSize=10)
xlabel(ax(1), '')
title(ax, '')
title(ax(1), 'iSPN stim')
ax(1).Legend.Orientation = 'horizontal';
ax(1).Legend.Location = 'southoutside';
ax(2).Legend.Visible = false;


%% 4.2 ISI analysis to find latencies
clear isi rdStim rdStimSpatial

if ~exist('ar')
    ar = AcuteRecording.load('C:\SERVER\Acute\AcuteRecording');
end

c.hasAnyStimTrials = arrayfun(@(eu) ~isempty(eu.getTrials('stim')), eu);
c.excludeD1 = strcmpi('daisy4_20190429', {eu.ExpName}) | strcmpi('daisy4_20190404', {eu.ExpName});% Bad timing alignment?
c.exclude = ...
    (strcmpi('desmond26_20220531', {eu.ExpName})  & [eu.Channel] == 13 & [eu.Unit] == 1) | ...
    (strcmpi('daisy16_20220502', {eu.ExpName})  & [eu.Channel] == 76 & [eu.Unit] == 1);% No spikes in DLS stim

xl = [-.2, .2]; % Extend left by an extra 100ms to get accurate ISI curves. 

rdStim(length(eu)) = struct('name', [], 'trialType', [], 'alignTo', [], 't', [], 'I', [], 'duration', [], 'iti', []);
rdStimSpatial(2, 4, length(eu)) = struct('name', [], 'trialType', [], 'alignTo', [], 't', [], 'I', [], 'duration', [], 'iti', []);
for iEu = find(c.hasAnyStimTrials & (c.isAi80 | c.isA2A) & ~c.exclude)
    % Attempt to select specific galvo trials to simplify conditions
    iAr = find(strcmpi(eu(iEu).ExpName, {ar.expName}));
    if isempty(iAr)
        rdStim(iEu) = eu(iEu).getRasterData('stim', window=xl, ...
            minTrialDuration=0.01, maxTrialDuration=0.01, sort=false, alignTo='start');
    else
        iBsr = find([ar(iAr).bsr.channel] == eu(iEu).Channel & [ar(iAr).bsr.unit] == eu(iEu).Unit);
        [~, IPulse] = ar(iAr).selectStimResponse(Light=2, Duration=0.01, MLRank=2, DVRank=3);
        trials = Trial(ar(iAr).stim.tOn(IPulse), ar(iAr).stim.tOff(IPulse));
        rdStim(iEu) = eu(iEu).getRasterData('stim', window=xl, sort=false, alignTo='start', trials=trials, minTrialDuration=0.01, maxTrialDuration=0.01);

        for iML = 1:2
            for iDV = 1:4
                [~, IPulse] = ar(iAr).selectStimResponse(Light=[0.28, 0.4, 0.5], Duration=0.01, MLRank=iML, DVRank=iDV);
                trials = Trial(ar(iAr).stim.tOn(IPulse), ar(iAr).stim.tOff(IPulse));
%                 fprintf(1, '%d trials at ML=%d, DV=%d.\n', length(trials), iML, iDV)
                rdStimSpatial(iML, iDV, iEu) = eu(iEu).getRasterData('stim', window=xl, sort=false, alignTo='start', trials=trials, minTrialDuration=0.01, maxTrialDuration=0.01);
            end
        end
    end
end

c.hasStim = arrayfun(@(rd) ~isempty(rd.I), rdStim);
c.hasStimSpatial = false(2, 4, length(eu));
c.hasStimSpatial = arrayfun(@(rd) ~isempty(rd.I), rdStimSpatial);

% D1 version (100ms pulses, 100ms ITI)
xlD1 = [-.2, .1]; % Extend left by an extra 100ms to get accurate ISI curves. 

for iEu = find(c.hasAnyStimTrials & c.isD1 & ~c.excludeD1)
    rdStim(iEu) = eu(iEu).getRasterData('stimfirstpulse', window=xlD1, ...
        minTrialDuration=0.01, maxTrialDuration=0.101, sort=false, alignTo='start');
end

c.hasStim = arrayfun(@(rd) ~isempty(rd.I), rdStim);

fprintf(1, '%d units with requested stim conditions.\n', nnz(c.hasStim))

 
warning('off')
close all
clear isi sel
sel = c.hasStim;
isi(sel) = getISILatencies(rdStim(sel), xlim=[-200, 200], peakThreshold=0.75, posMultiplier=1, minProminence=2, onsetThreshold=0.25, ...
    showPlots=false, savePlots=false, maxTrials=Inf);
c.isStimUp = false(1, length(eu));
c.isStimDown = false(1, length(eu));
for iEu = 1:length(isi)
    if ~isempty(isi(iEu).peak) && ~isnan(isi(iEu).peak)
        c.isStimUp(iEu) = isi(iEu).peak < isi(iEu).baseline;
        c.isStimDown(iEu) = isi(iEu).peak > isi(iEu).baseline;
    end
end
c.hasStimResponse = c.isStimUp | c.isStimDown;

% BUTTS
clear isiSpatial
isiSpatial(2, 4, length(eu)) = struct('t', [], 'isi', [], 'isi0', [], 'onsetLatency', [], 'peakLatency', [], ...
    'peak', [], 'baseline', [], 'baselineSD', [], 'width', []);
c.isStimUpSpatial = false(2, 4, length(eu));
c.isStimDownSpatial = false(2, 4, length(eu));
for iML = 1:2
    for iDV = 1:4
        sel = c.hasStimSpatial(iML, iDV, :);
        isiSpatial(iML, iDV, sel) = getISILatencies(rdStimSpatial(iML, iDV, sel), xlim=[-200, 200], peakThreshold=1, posMultiplier=1, minProminence=2, onsetThreshold=0.25, ...
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

clear iEu sel iML iDV

fprintf(1, '%d A2A units, %d up, %d down.\n', nnz(c.hasStim & c.isA2A), nnz(c.hasStim & c.isA2A & c.isStimUp), nnz(c.hasStim & c.isA2A & c.isStimDown))
fprintf(1, '%d Ai80 units, %d up, %d down.\n', nnz(c.hasStim & c.isAi80), nnz(c.hasStim & c.isAi80 & c.isStimUp), nnz(c.hasStim & c.isAi80 & c.isStimDown))
fprintf(1, '%d D1 units, %d up, %d down.\n', nnz(c.hasStim & c.isD1), nnz(c.hasStim & c.isD1 & c.isStimUp), nnz(c.hasStim & c.isD1 & c.isStimDown))
warning('on')

% Summarize responses
isiStim = isi(c.hasStim & c.hasStimResponse);
latencies = [isiStim.onsetLatency];
responses = [isiStim.peak] - [isiStim.isi0];

subplot(1, 2, 1)
histogram(latencies, 0:2:100)
title(sprintf('Distribution of latencies\nmin=%d, max=%d, mean=%.1f, median=%.1f', ...
    min(latencies), max(latencies), mean(latencies), median(latencies)))
subplot(1, 2, 2)
histogram(responses, 20)
title(sprintf('Distribution of responses\nMean=%.1f, %.1f, Median=%.1f, %.1f', mean(responses(responses<0)), mean(responses(responses>0)), median(responses(responses<0)), median(responses(responses>0))))

[~, pp] = ttest2(-responses(responses < 0), responses(responses > 0));
xlabel(sprintf('p=%.5f', pp))

%%
fprintf('Ai80:\n')
for iML = 1:2
    for iDV = 1:4
        isUp = reshape(c_0_5.isStimUpSpatial(iML, iDV, :), 1, []);
        isDown = reshape(c_0_5.isStimDownSpatial(iML, iDV, :), 1, []);
        isUp2 = reshape(c_2.isStimUpSpatial(iML, iDV, :), 1, []);
        isDown2 = reshape(c_2.isStimDownSpatial(iML, iDV, :), 1, []);
        isUp8 = reshape(c_8.isStimUpSpatial(iML, iDV, :), 1, []);
        isDown8 = reshape(c_8.isStimDownSpatial(iML, iDV, :), 1, []);
        pDown(iML, iDV) = nnz(isDown & c.isAi80) ./ nnz((isUp | isDown) & c.isAi80);
        pDown2(iML, iDV) = nnz(isDown2 & c.isAi80) ./ nnz((isUp2 | isDown2) & c.isAi80);
        pDown8(iML, iDV) = nnz(isDown8 & c.isAi80) ./ nnz((isUp8 | isDown8) & c.isAi80);
        fprintf('\t(%i, %i), %i (%.2f%%) down at 0.5mW, %i (%.2f%%) down at 2mW, %i (%.2f%%) down at 8mW\n', iML, iDV, ...
            nnz(isDown & c.isAi80), 100*pDown(iML, iDV), ...
            nnz(isDown2 & c.isAi80), 100*pDown2(iML, iDV), ...
            nnz(isDown8 & c.isAi80), 100*pDown8(iML, iDV) ...
            );
    end
end
% [h pp ci stats] = ttest2(pDown(:), pDown2(:))
mean([pDown(:), pDown2(:), pDown8(:)])

fprintf('A2A:\n')
for iML = 1:2
    for iDV = 1:4
        isUp = reshape(c_0_5.isStimUpSpatial(iML, iDV, :), 1, []);
        isDown = reshape(c_0_5.isStimDownSpatial(iML, iDV, :), 1, []);
        isUp2 = reshape(c_2.isStimUpSpatial(iML, iDV, :), 1, []);
        isDown2 = reshape(c_2.isStimDownSpatial(iML, iDV, :), 1, []);
        isUp8 = reshape(c_8.isStimUpSpatial(iML, iDV, :), 1, []);
        isDown8 = reshape(c_8.isStimDownSpatial(iML, iDV, :), 1, []);
        pUp(iML, iDV) = nnz(isUp & c.isA2A) ./ nnz((isUp | isDown) & c.isA2A);
        pUp2(iML, iDV) = nnz(isUp2 & c.isA2A) ./ nnz((isUp2 | isDown2) & c.isA2A);
        pUp8(iML, iDV) = nnz(isUp8 & c.isA2A) ./ nnz((isUp8 | isDown2) & c.isA2A);
        fprintf('\t(%i, %i), %i (%.2f%%) up at 0.5mW, %i (%.2f%%) up at 2mW, %i (%.2f%%) up at 8mW\n', iML, iDV, ...
            nnz(isUp & c.isA2A), 100*pUp(iML, iDV), ...
            nnz(isUp2 & c.isA2A), 100*pUp2(iML, iDV), ...
            nnz(isUp8 & c.isA2A), 100*pUp8(iML, iDV) ...
            );
    end
end
% [h pp ci stats] = ttest2(pUp(:), pUp2(:))
mean([pUp(:), pUp2(:), pUp8(:)])

clear isUp isDown isUp2 isDown2 iML iDV


%% Plot and save ISI analysis for manual checking
close all
sel = c.hasStimResponse;
getISILatencies(rdStim(sel), xlim=[-100, 100], peakThreshold=0.75, posMultiplier=1, minProminence=2, onsetThreshold=0.25, ...
    showPlots=true, savePlots=true, maxTrials=Inf);

%% Plot and save ISI analysis for manual checking
close all
sel = c.isAcute & c.isAi80 & c.isStimDown;
getISILatencies(rdStim(sel), xlim=[-100, 100], peakThreshold=0.75, posMultiplier=1, minProminence=2, onsetThreshold=0.25, ...
    showPlots=true, savePlots=true, maxTrials=Inf);

%% Plot and save ISI analysis for manual checking
close all
sel = squeeze(c.isStimDownSpatial(2, 1, :))' & c.isAi80;
getISILatencies(rdStimSpatial(2, 1, sel), xlim=[-100, 100], peakThreshold=0.75, posMultiplier=1, minProminence=2, onsetThreshold=0.25, ...
    showPlots=true, savePlots=true, maxTrials=Inf);

%% Example plots, ISI analysis for 2 example units
close all
clear selUnits
clear selEu
selUnits(1).expName = 'daisy9_20211028';
selUnits(2).expName = 'daisy9_20211028';

selUnits(1).electrode = 4;
selUnits(2).electrode = 10;
selUnits(1).unit = 1;
selUnits(2).unit = 1;


for i = 1:length(selUnits)
    if ~isempty(selUnits(i).electrode)
        selEu(i) = find(strcmpi({eu.ExpName}, selUnits(i).expName) & [eu.Electrode] == selUnits(i).electrode & [eu.Unit] == selUnits(i).unit);
    else
        selEu(i) = find(strcmpi({eu.ExpName}, selUnits(i).expName) & [eu.Channel] == selUnits(i).channel & [eu.Unit] == selUnits(i).unit);
    end
end
I = find(c.hasStim);
selEu = [selEu, I([isi(c.hasStim).baseline] > 1000/15)];

[~, ax] = getISILatencies(rdStim(selEu), xlim=[-100, 100], peakThreshold=0.75, posMultiplier=1, minProminence=2, onsetThreshold=0.25, ...
    showPlots=true, savePlots=false, maxTrials=Inf);
% ax(1).Legend.FontSize=12;
% ax(2).Legend.FontSize=12;

% clear selUnits i

%% Calculate ETAs
p.binWidthStim = 0.01;

eta.stim = eu.getETA('count', 'stim', [-0.5, 0.5], ...
    resolution=p.binWidthStim, ...
    minTrialDuration=0.01, maxTrialDuration=0.01, ...
    findSingleTrialDuration='min', normalize=[-0.2, 0], includeInvalid=false);

eta.stimD1 = eu.getETA('count', 'stimfirstpulse', [-0.5, 0.5], ...
    resolution=p.binWidthStim, ...
    minTrialDuration=0.01, maxTrialDuration=0.101, ...
    findSingleTrialDuration='max', normalize=[-0.2, 0], includeInvalid=false);

if isfield(eta, 'stimSpatial')
    eta = rmfield(eta, 'stimSpatial');
end

% For acute recording, pick DLS at 2.8DV
for iEu = 1:length(eu)
    iAr = find(strcmpi(eu(iEu).ExpName, {ar.expName}));
    if ~isempty(iAr)
        iBsr = find([ar(iAr).bsr.channel] == eu(iEu).Channel & [ar(iAr).bsr.unit] == eu(iEu).Unit);
        [~, IPulse] = ar(iAr).selectStimResponse(Light=2, Duration=0.01, MLRank=2, DVRank=3);
        trials = Trial(ar(iAr).stim.tOn(IPulse), ar(iAr).stim.tOff(IPulse));
        tempEta = eu(iEu).getETA('count', 'stim', [-0.5, 0.5], ...
            trials=trials, resolution=p.binWidthStim, ...
            minTrialDuration=0.01, maxTrialDuration=0.01, findSingleTrialDuration='min', ...
            normalize=[-0.2, 0], includeInvalid=false);
        eta.stim.X(iEu, :) = tempEta.X;
        eta.stim.N(iEu) = tempEta.N;
        eta.stim.D(iEu) = tempEta.D;
        eta.stim.stats(iEu) = tempEta.stats;
        clear tempEta

        for iML = 1:2
            for iDV = 1:4
                [~, IPulse] = ar(iAr).selectStimResponse(Light=[0.28, 0.4, 0.5], Duration=0.01, MLRank=iML, DVRank=iDV);
                trials = Trial(ar(iAr).stim.tOn(IPulse), ar(iAr).stim.tOff(IPulse));
                tempEta = eu(iEu).getETA('count', 'stim', [-0.5, 0.5], ...
                    trials=trials, resolution=p.binWidthStim, ...
                    minTrialDuration=0.01, maxTrialDuration=0.01, findSingleTrialDuration='min', ...
                    normalize=[-0.2, 0], includeInvalid=false);
                eta.stimSpatial(iML, iDV).X(iEu, :) = tempEta.X;
                eta.stimSpatial(iML, iDV).N(iEu) = tempEta.N;
                eta.stimSpatial(iML, iDV).D(iEu) = tempEta.D;
                eta.stimSpatial(iML, iDV).stats(iEu) = tempEta.stats;
                eta.stimSpatial(iML, iDV).t = tempEta.t;
                clear tempEta
            end
        end
    end
end


%% Summarize and plot stim ETAs, latencies
close all
N = nnz(c.hasStimResponse & c.isA2A);
fprintf(1, 'Out of %g tested units, %g are responsive.\n\t%g (%.2f%%) were excited by A2A, %g(%.2f%%) were inhibited by A2A.\n', ...
    nnz(c.hasStim & c.isA2A), N, ...
    nnz(c.isStimUp & c.isA2A), nnz(c.isStimUp & c.isA2A) / N * 100, ...
    nnz(c.isStimDown & c.isA2A), nnz(c.isStimDown & c.isA2A) / N * 100);

N = nnz(c.hasStimResponse & c.isAi80);
fprintf(1, 'Out of %g tested units, %g are responsive.\n\t%g (%.2f%%) were excited by Ai80, %g(%.2f%%) were inhibited by Ai80.\n', ...
    nnz(c.hasStim & c.isAi80), N, ...
    nnz(c.isStimUp & c.isAi80), nnz(c.isStimUp & c.isAi80) / N * 100, ...
    nnz(c.isStimDown & c.isAi80), nnz(c.isStimDown & c.isAi80) / N * 100);

N = nnz(c.hasStimResponse & c.isD1);
fprintf(1, 'Out of %g tested units, %g are responsive.\n\t%g (%.2f%%) were excited by D1 (100ms), %g(%.2f%%) were inhibited by D1 (100ms).\n', ...
    nnz(c.hasStim & c.isD1), N, ...
    nnz(c.isStimUp & c.isD1), nnz(c.isStimUp & c.isD1) / N * 100, ...
    nnz(c.isStimDown & c.isD1), nnz(c.isStimDown & c.isD1) / N * 100);
clear N

% 4.2.2 Plot stim heatmap
SEL = { ...
    c.hasStimResponse & c.isA2A; ...
    c.hasStimResponse & c.isAi80; ...
    c.hasStimResponse & c.isD1};
ETA = {eta.stim, eta.stim, eta.stimD1};
NAME = {'iSPN', 'dSPN', 'Drd1-Cre'};

for i = 1:3
    sel = SEL{i};

    dmin = min(ETA{i}.D(sel));
    dmax = max(ETA{i}.D(sel));
    if dmin==dmax
        text = sprintf('%s stim (%g ms)', NAME{i}, 1000*dmin);
    else
        text = sprintf('%s stim (%g-%g ms)', NAME{i}, 1000*dmin, 1000*dmax);
    end
    
    latencies = [isi(sel).onsetLatency];
    responses = [isi(sel).peak] - [isi(sel).isi0];
    responseSigns = sign(responses);
    peakLatencies = [isi(sel).peakLatency];
    [~, ISort] = sort(responseSigns.*(latencies.*1e4 + peakLatencies*1e3 + abs(responses)), 'ascend');
    
    ax = EphysUnit.plotETA(ETA{i}, sel, xlim=[-100, 100], clim=[-1, 1], ...
        timeUnit='ms', order=ISort, ...
        event='opto onset'); 
    title(ax, text)
    ax.FontSize = 10;
    hold(ax, 'on')
    if dmin==dmax
        yl = ax.YLim;
        patch(ax, [0, dmin, dmin, 0].*1000, [yl(1), yl(1), yl(2), yl(2)], 'b', FaceAlpha=0.1, EdgeAlpha=0)
    end
    hold(ax, 'off')
    title(ax, text)
    ax.Parent.OuterPosition(3) = 0.2;
    ax.Parent.OuterPosition(4) = 0.5;
end

SEL = { ...
    c.isStimUp & c.isA2A; ...
    c.isStimUp & c.isAi80; ...
    c.isStimUp & c.isD1; ...
    c.isStimDown & c.isA2A; ...
    c.isStimDown & c.isAi80; ...
    c.isStimDown & c.isD1; ...
    };
NAME = { ...
    'iSPN-excited';
    'dSPN-excited';
    'Drd1-excited';
    'iSPN-inhibited';
    'dSPN-inhibited';
    'Drd1-inhibited';
    };
COLOR = {'red', 'red', 'red', 'default', 'default', 'default'};

figure(DefaultAxesFontSize=12, Units='normalized', OuterPosition=[0, 0, 0.55, 0.35])

latencies = cell(6, 1);
for i = 1:6
    subplot(2, 3, i)
    latencies{i} = [isi(SEL{i}).onsetLatency];
    histogram(latencies{i}, 1:4:100, DisplayName=sprintf('N=%g', length(latencies{i})), FaceColor=COLOR{i})
    title(sprintf('%s, median=%.0fms', NAME{i}, median(latencies{i})))
    legend()
    ylabel('Count')

    if i >= 4
        xlabel('SNr response latency (ms)')
    end
    if i == 1 || i == 4
        ylabel('Count')
    end
end

p1 = ranksum(latencies{1}, latencies{4}, tail='left')
p2 = ranksum(latencies{2}, latencies{5}, tail='right')
p3 = ranksum(latencies{3}, latencies{6}, tail='right')


%% Additional threshold with METAs, on top of ISI peaks
% meta.stimSpatial = NaN(2, 4, length(eu));
% for iML = 1:2
%     for iDV = 1:4
%         t = eta.stimSpatial(iML, iDV).t;
%         meta.stimSpatial(iML, iDV, :) = transpose(mean(eta.stimSpatial(iML, iDV).X(:, t >= 0.01 & t <= 0.03), 2, 'omitnan'));
%     end
% end
% clear t
% histogram(meta.stimSpatial(1, 1, c.isAi80), 50)

% Max eta from onset to peak (peak/onset time determined by ISI)
peta.stimSpatial = NaN(2, 4, length(eu));
for iML = 1:2
    for iDV = 1:4
        t = eta.stimSpatial(iML, iDV).t;
        for iEu = find(c.hasStimResponseSpatial(iML, iDV, :))'
            peta.stimSpatial(iML, iDV, iEu) = mean(eta.stimSpatial(iML, iDV).X(iEu, t >= 0.01 & t <= 0.03), 2, 'omitnan');
%             tOnset = round(isiSpatial(iML, iDV, iEu).onsetLatency / 10) / 100;
%             tPeak = round(isiSpatial(iML, iDV, iEu).peakLatency / 10) / 100;
%             thisETA = eta.stimSpatial(iML, iDV).X(iEu, t >= tOnset & t <= tPeak);
%             [~, iMax] = max(abs(thisETA), [], 2, 'omitnan');
%             peta.stimSpatial(iML, iDV, iEu) = thisETA(iMax);
%             thisETA = eta.stimSpatial(iML, iDV).X(iEu, t >= tOnset & t <= tPeak);
        end
    end
end
clear thisEta iMax tOnset tPeak iML iDV t
sel = squeeze(c.hasStimSpatial(1, 1, :))' & c.isAi80;
histogram(peta.stimSpatial(1, 1, sel), 50)
% scatter(squeeze(peta.stimSpatial(1, 1, sel)), squeeze([isiSpatial(1, 1, sel).peak]))
c.isStimUpSpatialPETA = peta.stimSpatial >= 0.2;
c.isStimDownSpatialPETA = peta.stimSpatial <= -0.2;
c.hasStimResponseSpatialPETA = c.isStimUpSpatialPETA | c.isStimDownSpatialPETA;

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
    fig = figure(Units='inches', Position=[0, 0, 3.25, 7], DefaultAxesFontSize=9);
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
        end
    end
%     suptitle(TITLE(iFig))
end

%% Movement response maps in SNr
MOVETYPE = {'press', 'lick', 'lickosci'};
SEL = {c.isPressResponsive; c.isLickResponsive; c.isLick};
STATS = {meta.press, meta.lick, meta.anyLickNorm};
TITLE = {'Reach', 'Lick', 'Osci Lick'};

fig = figure(Units='inches', Position=[0, 0, 6.5/4*3, 3], DefaultAxesFontSize=9);
for iMove = 1:length(MOVETYPE)
    ax = subplot(1, length(MOVETYPE), iMove);
    sel = SEL{iMove};
    coords = euPos(sel, :);
    stats = STATS{iMove}(sel);
    AcuteRecording.plotMap(ax, coords, stats, [0 5], 0, UseSignedML=false, BubbleSize=[1 7.5], MarkerAlpha=0.25);
    title(ax, TITLE{iMove})
    axis(ax, 'image')
    xlim(ax, [0.9, 1.7])
    ylim(ax, [-4.8, -3.7])
    if iMove > 1
        ylabel(ax, "");
    end
    xlabel(ax, 'ML');
    set(ax, FontSize=9)
end

%% Summarize and plot stim ETAs, latencies (For 8 acute sites)
close all
clc
p1 = NaN(2, 4);
p2 = NaN(2, 4);
for iML = 1:2
    for iDV = 1:4
        fprintf(1, 'ML = %d, DV = %d:\n', iML, iDV)
        N = nnz(squeeze(c.hasStimResponseSpatialPETA(iML, iDV, :)) & c.isA2A');
        fprintf(1, '\tOut of %g tested units, %g are responsive.\n\t\t%g (%.2f%%) were excited by A2A, %g(%.2f%%) were inhibited by A2A.\n', ...
            nnz(squeeze(c.hasStimSpatial(iML, iDV, :)) & c.isA2A'), N, ...
            nnz(squeeze(c.isStimUpSpatialPETA(iML, iDV, :)) & c.isA2A'), nnz(squeeze(c.isStimUpSpatialPETA(iML, iDV, :)) & c.isA2A') / N * 100, ...
            nnz(squeeze(c.isStimDownSpatialPETA(iML, iDV, :)) & c.isA2A'), nnz(squeeze(c.isStimDownSpatialPETA(iML, iDV, :)) & c.isA2A') / N * 100);
        
        N = nnz(squeeze(c.hasStimResponseSpatialPETA(iML, iDV, :)) & c.isAi80');
        fprintf(1, '\tOut of %g tested units, %g are responsive.\n\t\t%g (%.2f%%) were excited by Ai80, %g(%.2f%%) were inhibited by Ai80.\n', ...
            nnz(squeeze(c.hasStimSpatial(iML, iDV, :)) & c.isAi80'), N, ...
            nnz(squeeze(c.isStimUpSpatialPETA(iML, iDV, :)) & c.isAi80'), nnz(squeeze(c.isStimUpSpatialPETA(iML, iDV, :)) & c.isAi80') / N * 100, ...
            nnz(squeeze(c.isStimDownSpatialPETA(iML, iDV, :)) & c.isAi80'), nnz(squeeze(c.isStimDownSpatialPETA(iML, iDV, :)) & c.isAi80') / N * 100);
        fprintf(1, '\n')

        clear N

        fig = figure(Position=[100, 100, 400, 400]);
        AX_ALL = gobjects(1, 6);
        AX_ALL(1) = axes(fig, OuterPosition=[0.0, 0.5, 0.5, 0.5]);
        AX_ALL(2) = axes(fig, OuterPosition=[0.5, 0.5, 0.5, 0.5]);
        AX_ALL(3) = axes(fig, OuterPosition=[0.0, 0.25, 0.5, 0.25]);
        AX_ALL(4) = axes(fig, OuterPosition=[0.5, 0.25, 0.5, 0.25]);
        AX_ALL(5) = axes(fig, OuterPosition=[0.0, 0, 0.5, 0.25]);
        AX_ALL(6) = axes(fig, OuterPosition=[0.5, 0.0, 0.5, 0.25]);
        
        % 4.2.2 Plot stim heatmap
        SEL = { ...
            squeeze(c.hasStimResponseSpatialPETA(iML, iDV, :)) & c.isA2A'; ...
            squeeze(c.hasStimResponseSpatialPETA(iML, iDV, :)) & c.isAi80'};
        ETA = {eta.stimSpatial(iML, iDV), eta.stimSpatial(iML, iDV)};
        NAME = {'iSPN', 'dSPN'};
        AX = AX_ALL(1:2);
        
        for i = 1:length(SEL)
            sel = SEL{i};
        
            dmin = min(ETA{i}.D(sel));
            dmax = max(ETA{i}.D(sel));
            if dmin==dmax
                text = sprintf('%s stim (%g ms)', NAME{i}, 1000*dmin);
            else
                text = sprintf('%s stim (%g-%g ms)', NAME{i}, 1000*dmin, 1000*dmax);
            end
            
            latencies = [isiSpatial(iML, iDV, sel).onsetLatency];
            responses = [isiSpatial(iML, iDV, sel).peak] - [isiSpatial(iML, iDV, sel).isi0];
            responseSigns = sign(responses);
            peakLatencies = [isiSpatial(iML, iDV, sel).peakLatency];
            [~, ISort] = sort(responseSigns.*(latencies.*1e4 + peakLatencies*1e3 + abs(responses)), 'ascend');
            
            ax = AX(i);
            axETA = EphysUnit.plotETA(ax, ETA{i}, sel, xlim=[-100, 100], clim=[-1, 1], ...
                timeUnit='ms', order=ISort, ...
                event='opto onset'); 
            colorbar(axETA, 'off')
            title(ax, text)
            ax.FontSize = 10;
            hold(ax, 'on')
            if dmin==dmax
                yl = ax.YLim;
                patch(ax, [0, dmin, dmin, 0].*1000, [yl(1), yl(1), yl(2), yl(2)], 'b', FaceAlpha=0.1, EdgeAlpha=0)
            end
            hold(ax, 'off')
            title(ax, text)
%             ax.Parent.OuterPosition(3) = 0.2;
%             ax.Parent.OuterPosition(4) = 0.5;
        end
        
        SEL = { ...
            squeeze(c.isStimUpSpatialPETA(iML, iDV, :)) & c.isA2A'; ...
            squeeze(c.isStimUpSpatialPETA(iML, iDV, :)) & c.isAi80'; ...
            squeeze(c.isStimDownSpatialPETA(iML, iDV, :)) & c.isA2A'; ...
            squeeze(c.isStimDownSpatialPETA(iML, iDV, :)) & c.isAi80'; ...
            };
        NAME = { ...
            'iSPN-excited';
            'dSPN-excited';
            'iSPN-inhibited';
            'dSPN-inhibited';
            };
        COLOR = {'red', 'red', 'default', 'default'};
        AX = AX_ALL(3:6);
        
%         figure(DefaultAxesFontSize=12, Units='normalized', OuterPosition=[0, 0, 0.55/3*2, 0.35])
        
        latencies = cell(length(SEL), 1);
        for i = 1:length(SEL)
            ax = AX(i);
            latencies{i} = [isiSpatial(iML, iDV, SEL{i}).onsetLatency];
            histogram(ax, latencies{i}, 1:4:100, DisplayName=sprintf('N=%g', length(latencies{i})), FaceColor=COLOR{i})
            title(ax, sprintf('%s, median=%.0fms', NAME{i}, median(latencies{i})))
            legend(ax)
            ylabel(ax, 'Count')
        
            if i > 2
                xlabel(ax, 'SNr response latency (ms)')
            end
            if i == 1 || i == 3
                ylabel(ax, 'Count')
            end
        end

        set(AX_ALL, FontSize=9)

        p1(iML, iDV) = ranksum(latencies{1}, latencies{3}, tail='left');
        p2(iML, iDV) = ranksum(latencies{2}, latencies{4}, tail='right');
        
    end
end

%% 4.3 Bargraph showing unit counts grouped by movement selectivity, then dSPN on/off.
close all

% SEL1 x SEL2 makes a matrix of press/lick selectivity
SEL1 = { ...
    c.isPressUp; ...
    c.hasPress & ~c.isPressResponsive; ...
    c.isPressDown; ...
    };

SEL2 = { ...
    c.isLickDown; ...
    c.hasLick & ~c.isLickResponsive; ...
    c.isLickUp; ...
%     c.isLick; ...
    };
       
CATNAMES1 = {'Press ON', 'Press NONE', 'Press OFF'};
CATNAMES2 = {'Lick OFF', 'Lick NONE', 'Lick ON'};%, 'Lick OSCI'};

fig = figure(InnerPosition=[0, 0, 600, 1080]);
for iML = 1:2
    for iDV = 1:4
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

        % iRow = 4*(iML-1) + iDV;
        iRow = 4*(iML-1) + (5-iDV);

        n = zeros(length(SEL1), length(SEL2));
        N = struct('ispnOn', n, 'ispnOff', n, 'dspnOn', n, 'dspnOff', n);
        N.base = zeros(3, 4);
        for i = 1:length(SEL1)
            for j = 1:length(SEL2)
                N.total(i, j) = 1 + nnz(SEL1{i} & SEL2{j});
                N.ispnOn(i, j) = 1 + nnz(SEL1{i} & SEL2{j} & c.isA2A & squeeze(c.isStimUpSpatial(iML, iDV, :))');
                N.ispnOff(i, j) = 1 + nnz(SEL1{i} & SEL2{j} & c.isA2A & squeeze(c.isStimDownSpatial(iML, iDV, :))');
                N.dspnOn(i, j) = 1 + nnz(SEL1{i} & SEL2{j} & c.isAi80 & squeeze(c.isStimUpSpatial(iML, iDV, :))');
                N.dspnOff(i, j) = 1 + nnz(SEL1{i} & SEL2{j} & c.isAi80 & squeeze(c.isStimDownSpatial(iML, iDV, :))');
            end
        end
        VARNAMES = {'ispnOff', 'ispnOn', 'dspnOff', 'dspnOn'};
        NAMES = {'iSPN-inhibited', 'iSPN-excited', 'dSPN-inhibited', 'dSPN-excited'};
        w = 250; h = 250;
        for i = 1:length(VARNAMES)
            n = N.(VARNAMES{i});
            n = round(n ./ sum(n, 'all') * 1000)./10;    
            n0 = N.total;
            n0 = round(n0 ./ sum(n0, 'all') * 1000)./10;
            n = n - n0;
            ax = subplot(8, length(VARNAMES), length(VARNAMES)*(iRow-1) + i);
            imagesc(ax, n);
            clear text
            for ii = 1:length(SEL1)
                for jj = 1:length(SEL2)
                    text(ii, jj, sprintf('%.0f', N.(VARNAMES{i})(ii, jj)), FontSize=9, VerticalAlignment='middle', HorizontalAlignment='center')
                end
            end
            xticks(ax, 1:3);
            yticks(ax, 1:3);
            xticklabels(ax, CATNAMES2);
            yticklabels(ax, CATNAMES1);
            title(NAMES{i});
            axis(ax, 'image')
            if i > 1
                yticks(ax, [])
            end
            if iRow < 8
                xticks(ax, [])
            end
            ngrades = 100;
            colormap(hsl2rgb([[0.7*ones(ngrades, 1); 0*ones(ngrades, 1)], ones(ngrades*2, 1), [linspace(0.5, 1, ngrades)'; linspace(1, 0.5, ngrades)']]))
            clim([-30, 30])

            if i == length(VARNAMES)
                textPos = ax.Position;
                textPos(3) = 0.075;
                textPos(1) = ax.Position(1) + ax.Position(3);
                annotation(fig, 'textbox', textPos, String=sprintf('%s\n%s', mlText, dvText), ...
                    HorizontalAlignment='center', VerticalAlignment='middle', LineStyle='none', FontSize=11);
            end
%             colorbar()
        end
        clear ax i n
    end
end

%% 6.1 Scatter press vs lick, color by stim response 
SEL = { ...
    c.hasPress & c.hasLick & c.isA2A, c.hasPress & c.hasLick & c.isAi80; ...
    c.hasPress & c.hasLick & c.isA2A, c.hasPress & c.hasLick & c.isAi80; ...
    };
XDATA = { ...
    meta.lickRaw*10, meta.lickRaw*10; ...
    meta.lickRaw*10 - msr, meta.lickRaw*10 - msr; ...
    };
YDATA = { ...
    meta.pressRaw*10, meta.pressRaw*10; ...
    meta.pressRaw*10 - msr, meta.pressRaw*10 - msr; ...
    };
XNAME = { ...
    'Absolute lick response (sp/s)', 'Absolute lick response (sp/s)'; ...
    'Relative lick response (\Deltasp/s)', 'Relative lick response (\Deltasp/s)'; ...
    };
YNAME = { ...
    'Absolute press response (sp/s)', 'Absolute press response (sp/s)'; ...
    'Relative press response (\Deltasp/s)', 'Relative press response (\Deltasp/s)'; ...
    };
TITLE = { ...
    'iSPN-stim', 'dSPN-stim'; ...
    '', ''; ...
    };
AXIS = { ...
    msr, msr; ...
    zeros(size(msr)), zeros(size(msr)); ...
    };

% Same as above but as scatter
fig = figure(Position=[200 200 600 600]);
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
        h(1) = bubblechart(x(selUp), y(selUp), s(selUp), 'red', MarkerFaceAlpha=0.5, DisplayName='stim-excited');
        h(2) = bubblechart(x(selDown), y(selDown), s(selDown), 'blue', MarkerFaceAlpha=0.5, DisplayName='stim-suppressed');
        bubblesize(ax, [1 10])
        bubblelim(ax, [5, 100])
        bubblelegend(ax, '\Deltasp/s')
        
        xl = ax.XLim;
        yl = ax.YLim;
        
        plot(ax, xl, mean(AXIS{i, j}(sel))*ones(1, 2), 'k:')
        plot(ax, mean(AXIS{i, j}(sel))*ones(1, 2), yl, 'k:')
        
        xlabel(ax, XNAME{i, j})
        ylabel(ax, YNAME{i, j})

        xlim(ax, xl);
        ylim(ax, yl);

        title(ax, TITLE{i, j})
        if i > 1 && j > 1
            legend(ax, h, Orientation='horizontal')
        end
    end
end

%% 6.2 (8 sites) Scatter press vs lick, color by stim response 
SEL = { ...
    c.hasPress & c.hasLick & c.isA2A, c.hasPress & c.hasLick & c.isAi80; ...
    c.hasPress & c.isA2A, c.hasPress & c.isAi80; ...
    c.hasLick & c.isLick & c.isA2A, c.hasLick & c.isLick & c.isAi80; ...
    c.hasPress & c.isLick & c.isA2A, c.hasPress & c.isLick & c.isAi80; ...
    };
XDATA = { ...
    meta.lickRaw*10 - msr; ...
    msr; ...
    meta.anyLickNorm; ...
    meta.anyLickNorm; ...
    };
YDATA = { ...
    meta.pressRaw*10 - msr; ...
    meta.pressRaw*10 - msr; ...
    meta.lickRaw*10 - msr; ...
    meta.pressRaw*10 - msr; ...
    };
XNAME = { ...
    'lick resp (\Deltasp/s)'; ...
    'baseline (sp/s)'; ...
    'osci lick (a.u.)'; ...
    'osci lick (a.u.)'; ...
    };
YNAME = { ...
    'press resp (\Deltasp/s)'; ...
    'press resp (\Deltasp/s)'; ...
    'lick resp (\Deltasp/s)'; ...
    'press resp (\Deltasp/s)'; ...
    };
TITLE = { ...
    'iSPN-stim', 'dSPN-stim'; ...
    'iSPN-stim', 'dSPN-stim'; ...
    'iSPN-stim', 'dSPN-stim'; ...
    'iSPN-stim', 'dSPN-stim'; ...
    };
XAXIS = { ...
    zeros(size(msr)); ...
    zeros(size(msr)); ...
    zeros(size(msr)); ...
    zeros(size(msr)); ...
    };
YAXIS = { ...
    zeros(size(msr)); ...
    msr; ...
    zeros(size(msr)); ...
    zeros(size(msr)); ...
    };
EQUAL_AXES = [true; false; false; false];
YAXIS_MARGIN = [10; 10; 10; 10];
XAXIS_MARGIN = [10; 10; 0; 0];
XLIM = {[]; []; [-2, 2]; [-2, 2]};
YLIM = {[]; []; []; []};
BUBBLELIM = {[2, 50]; [2, 50]; [2, 25]; [2, 25]};

close all

for iFig = 1:size(SEL, 1)
    w = 200; h = 200;
    fig = figure(Position=[0, 0, w*4, h*4]);
    axAll = gobjects(4, 4);
    for iML = 1:2
        for iDV = 1:4
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
            
            % Same as above but as scatter
            for iStim = 1:2
                iRow = (4-iDV) + 1;
                iCol = (iStim-1)*2 + iML;
                iAx = (iRow-1)*4 + iCol;
                %iCol = 2*(iML-1) + iStim;
                % iAx = 4*(4-iDV) + 2*(iML-1) + iStim;
                ax = subplot(4, 4, iAx);
                axAll(iRow, iCol) = ax;
                hold(ax, 'on')
                
                x = XDATA{iFig};
                y = YDATA{iFig};

                stimSel = squeeze(c.hasStimResponseSpatial(iML, iDV, :))';
                baselineSR = NaN(1, length(eu));
                peakSR = baselineSR;
                baselineSR(stimSel) = 1000./[isiSpatial(iML, iDV, stimSel).isi0];
                peakSR(stimSel) = 1000./[isiSpatial(iML, iDV, stimSel).peak];
                stimResponse = peakSR - baselineSR;
                s = abs(stimResponse);% ./ max(abs(stimResponse));
%                 s(stimResponse<0) = s(stimResponse<0) * 3;
        
                selUp = SEL{iFig, iStim} & squeeze(c.isStimUpSpatial(iML, iDV, :))';
                selDown = SEL{iFig, iStim} & squeeze(c.isStimDownSpatial(iML, iDV, :))';
        
                h = gobjects(1, 2);
                h(1) = bubblechart(x(selUp), y(selUp), s(selUp), 'red', MarkerFaceAlpha=0.5, DisplayName='stim-excited');
                h(2) = bubblechart(x(selDown), y(selDown), s(selDown), 'blue', MarkerFaceAlpha=0.5, DisplayName='stim-suppressed');
                bubblesize([1 7.5])
                bubblelim(ax, BUBBLELIM{iFig})

                if iRow == 4
                    xlabel(ax, XNAME{iFig})
                end
                if iCol == 1
                    ylabel(ax, YNAME{iFig})
                end
        
                if ~isempty(TITLE{iFig})
                    title(ax, sprintf('%s\n%s %s', TITLE{iFig, iStim}, mlText, dvText))
                end
                if iAx == 1
                    legend(ax, h, Orientation='vertical', AutoUpdate=false)
                    bubblelegend(ax, 'stim resp (\Deltasp/s)')
                end
                if ismember(iAx, [14, 16]) && iFig == 3
                    xl = ax.XLim;
                    clear text
                    text(ax, 0.5*xl(1), 0.5, num2str(nnz(c.isM(selDown) & c.hasPress(selDown))))
                    text(ax, 0.5*xl(2), 0.5, num2str(nnz(c.isL(selDown) & c.hasPress(selDown))))
                    text(ax, 0.5*xl(1), 0, num2str(nnz(c.isPressUp(selUp))))
                    text(ax, 0.5*xl(2), 0, num2str(nnz(c.isPressDown(selUp))))
                end
            end
        end
    end

    % Unify xlims
    if isempty(XLIM{iFig})
        xl = [min([ax.XLim]) - XAXIS_MARGIN(iFig), max([ax.XLim]) + XAXIS_MARGIN(iFig)];
    else
        xl = XLIM{iFig};
    end
    if isempty(YLIM{iFig})
        yl = [min([ax.YLim]) - YAXIS_MARGIN(iFig), max([ax.YLim]) + YAXIS_MARGIN(iFig)];
    else
        yl = YLIM{iFig};
    end
    if EQUAL_AXES(iFig)
        xl = [min([xl, yl]), max([xl, yl])];
        yl = xl;
    end
    for iML = 1:2
        for iDV = 1:4
            for iStim = 1:2
                iRow = (4-iDV) + 1;
                iCol = 2*(iML-1) + iStim;
                ax = axAll(iRow, iCol);
                plot(ax, xl, mean(XAXIS{iFig}(sel))*ones(1, 2), 'k:')
                plot(ax, mean(YAXIS{iFig}(sel))*ones(1, 2), yl, 'k:')
                xlim(ax, xl)
                ylim(ax, yl)
            end
        end
    end
end


%% 6.4 Scatter self-timed press vs self-timed lick, color by osci lick

        
%% 4.3 Stim response analysis by ISI analysis, instead of ETA
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

close all
% 4.3.1 Plot 
wPlot = 350;
hPlot = 175;
figure(Units='pixels', Position=[200, 100, wPlot*2, hPlot*2]);

YNAME = { ...
    'Lick response (\Deltasp/s)'; ...
    ''; ... % 'Lick response (\Deltasp/s)'; ...
    'Press response (\Deltasp/s)'; ...
    ''; ... % 'Press response (\Deltasp/s)'; ...
    };

XNAME = { ...
    ''; ... % 'iSPN response (\Deltasp/s)'; ...
    ''; ... % 'dSPN response (\Deltasp/s)'; ...
    'DLS iSPN response (\Deltasp/s)'; ...
    'DLS dSPN response (\Deltasp/s)'; ...
    };

DATA = { ...
    r.stim, r.lick; ...
    r.stim, r.lick; ...
    r.stim, r.press; ...
    r.stim, r.press; ...
    };

SEL = { ...
    c.hasPos & c.hasStimResponse & c.isLickResponsive & c.isA2A & c.hasLick; ...
    c.hasPos & c.hasStimResponse & c.isLickResponsive & c.isAi80 & c.hasLick; ...
    c.hasPos & c.hasStimResponse & c.isPressResponsive & c.isA2A & c.hasPress; ...
    c.hasPos & c.hasStimResponse & c.isPressResponsive & c.isAi80 & c.hasPress; ...
    };

LEGEND_LOC = {'northeast'; 'northeast'; 'northeast'; 'northeast'};

ax = gobjects(4, 1);
h = gobjects(4, 2);
for i = 1:4
    ax(i) = subplot(2, 2, i);
    hold(ax(i), 'on')
    sel = SEL{i};
    hold(ax(i), 'on');
    x = DATA{i, 2}(sel);
    y = DATA{i, 1}(sel);
    h(i, 1) = scatter(x, y, sz, 'filled', 'k', ...
        DisplayName=sprintf('N=%g', nnz(sel)));
    xlabel(ax(i), XNAME{i})
    ylabel(ax(i), YNAME{i})
end

xl = [min(horzcat(ax.XLim)), max(horzcat(ax.XLim))];
yl = [min(horzcat(ax.YLim)), max(horzcat(ax.YLim))];

for i = 1:4
    sel = SEL{i};
    x = DATA{i, 2}(sel);
    y = DATA{i, 1}(sel);
    mdl = fitlm(x, y);
    h(i, 2) = plot(ax(i), xl, mdl.predict(xl'), 'k--', LineWidth=1, DisplayName=sprintf('R^2=%.2f', mdl.Rsquared.Ordinary));
    legend(ax(i), h(i, :), Location=LEGEND_LOC{i}, AutoUpdate='off')
    plot(ax(i), xl, [0, 0], 'k:')
    plot(ax(i), [0, 0], yl, 'k:')
    hold(ax(i), 'off')
end
xlim(ax, xl)
ylim(ax, yl)


%% 4.3.2 Stim vs Move by SNr location
sz = 25;

xEdges = [0 1300 2600];
yEdges = [0 4300 10000];
xPos = abs(euPos(:, 1))';
yPos = abs(euPos(:, 2))';
c.isM = xPos <= xEdges(2);
c.isL = xPos > xEdges(2);
c.isD = yPos <= yEdges(2);
c.isV = yPos > yEdges(2);

YNAME = { ...
%     'Lick response (\Deltasp/s)'; ...
    'Lick response (\Deltasp/s)'; ...
    'Lick response (\Deltasp/s)'; ...
    'Lever-press response (\Deltasp/s)'; ...
    'Lever-press response (\Deltasp/s)'; ...
    };

XNAME = { ...
%     'Lever-press response (\Deltasp/s)'; ...
    'iSPN-stim response (\Deltasp/s)'; ...
    'dSPN-stim response (\Deltasp/s)'; ...
    'iSPN-stim response (\Deltasp/s)'; ...
    'dSPN-stim response (\Deltasp/s)'; ...
    };

DATA = { ...
%     r.press, r.lick; ...
    r.lick, r.stim; ...
    r.lick, r.stim; ...
    r.press, r.stim; ...
    r.press, r.stim; ...
    };

SEL = { ...
%     c.hasPos & c.hasPress & c.hasLick; ...
    c.hasPos & c.hasStimResponse & c.isLickResponsive & c.isA2A & c.hasLick; ...
    c.hasPos & c.hasStimResponse & c.isLickResponsive & c.isAi80 & c.hasLick; ...
    c.hasPos & c.hasStimResponse & c.isPressResponsive & c.isA2A & c.hasPress; ...
    c.hasPos & c.hasStimResponse & c.isPressResponsive & c.isAi80 & c.hasPress; ...
    };

for iFig = 1:length(TITLE)
    fig = figure(Units='pixels', Position=[200, 200, wPlot*2, hPlot*2], DefaultAxesFontSize=10);
    ax = gobjects(4, 1);
    h = gobjects(4, 2);
    for i = 1:4
        ax(i) = subplot(2, 2, i);
        hold(ax(i), 'on');
        switch i
            case 1
                sel = SEL{iFig} & c.isD & c.isM;
                title('DM')
            case 2
                sel = SEL{iFig} & c.isD & c.isL;
                title('DL')
            case 3
                sel = SEL{iFig} & c.isV & c.isM;
                title('VM')
            case 4
                sel = SEL{iFig} & c.isV & c.isL;
                title('VL')
        end
        x = DATA{iFig, 2}(sel);
        y = DATA{iFig, 1}(sel);
        h(i, 1) = scatter(x, y, sz, 'filled', 'k', ...
            DisplayName=sprintf('N=%g', nnz(sel)));
    end

    xl = [min(horzcat(ax.XLim)), max(horzcat(ax.XLim))];
    yl = [min(horzcat(ax.YLim)), max(horzcat(ax.YLim))];
    for i = 1:4
        switch i
            case 1
                sel = SEL{iFig} & c.isD & c.isM;
                title('DM')
            case 2
                sel = SEL{iFig} & c.isD & c.isL;
                title('DL')
            case 3
                sel = SEL{iFig} & c.isV & c.isM;
                title('VM')
            case 4
                sel = SEL{iFig} & c.isV & c.isL;
                title('VL')
        end
        if any(sel)
            x = DATA{iFig, 2}(sel);
            y = DATA{iFig, 1}(sel);
            mdl = fitlm(x, y);
            h(i, 2) = plot(ax(i), xl, mdl.predict(xl'), 'k--', LineWidth=1, DisplayName=sprintf('R^2=%.2f', mdl.Rsquared.Ordinary));
            legend(ax(i), h(i, :), Location='best', AutoUpdate='off')
        end
        plot(ax(i), xl, [0, 0], 'k:')
        plot(ax(i), [0, 0], yl, 'k:')
    end
    xlim(ax, xl);
    ylim(ax, yl);

    annotation(fig, 'textbox', [0.1, 0.02, 0.9, 0.05], String=XNAME{iFig}, ...
        HorizontalAlignment='center', LineStyle='none', FontSize=12);

%     annotation(fig, 'textbox', [0.075, 0.1, 1, 0.05], String=YNAME{iFig}, ...
%         HorizontalAlignment='center', LineStyle='none', FontSize=12, Rotation=90);

    annotation(fig, 'textbox', [0.075,0.05,0.45,0.05], String=YNAME{iFig}, ...
        HorizontalAlignment='center', LineStyle='none', FontSize=12, Rotation=90);
   
end


%% 4.3.2 Press vs Lick by SNr location, color by oscillatory licking
close all

xEdges = [0 1300 2600];
yEdges = [0 4300 10000];
xPos = abs(euPos(:, 1))';
yPos = abs(euPos(:, 2))';
c.isM = xPos <= xEdges(2);
c.isL = xPos > xEdges(2);
c.isD = yPos <= yEdges(2);
c.isV = yPos > yEdges(2);

YNAME = { ...
    'Lick response (\Deltasp/s)'; ...
    };

XNAME = { ...
    'Lever-press response (\Deltasp/s)'; ...
    };

DATA = { ...
    r.press, r.lick; ...
    };

SCDATA = { ...
    meta.anyLickNorm; ...
    };

SEL = { ...
    c.hasPos & c.hasPress & c.hasLick & c.isLick; ...
    };

TITLE = { ...
    'Self-timed lick vs press, color by osci lick'; ...
    };

% First combined SNr plot
fig = figure(Unit='pixels', Position=[200 200 wPlot hPlot], DefaultAxesFontSize=12);
ax = axes(fig);
hold(ax, 'on')
h = gobjects(1, 3);

sel = c.hasPress & c.hasLick & c.isLick;
x = DATA{1, 2}(sel);
y = DATA{1, 1}(sel);
sc = SCDATA{1}(sel); % Size and color
sz = 25*abs(sc); % Size
sg = sign(sc); % Sign/color
h(1, 1) = scatter(ax, x(sg>0), y(sg>0), sz(sg>0), 'red', 'filled', ...
    DisplayName=sprintf('N=%g', nnz(sg>0)));
h(1, 2) = scatter(ax, x(sg<0), y(sg<0), sz(sg<0), 'blue', 'filled', ...
    DisplayName=sprintf('N=%g', nnz(sg<0)));

xl = [min(horzcat(ax.XLim)), max(horzcat(ax.XLim))];
yl = [min(horzcat(ax.YLim)), max(horzcat(ax.YLim))];

mdl = fitlm(x, y);
h(1, 3) = plot(ax, xl, mdl.predict(xl'), 'k--', LineWidth=1, DisplayName=sprintf('R^2=%.2f', mdl.Rsquared.Ordinary));
legend(ax, h, Location='best', AutoUpdate='off')
plot(ax, xl, [0, 0], 'k:')
plot(ax, [0, 0], yl, 'k:')
xlim(ax, xl);
ylim(ax, yl);
xlabel(ax, XNAME{1})
ylabel(ax, YNAME{1})

% Broken down 4 SNr plots
for iFig = 1:length(TITLE)
    fig = figure(Units='pixels', Position=[200, 200, wPlot*2, hPlot*2], DefaultAxesFontSize=10);
    ax = gobjects(4, 1);
    h = gobjects(4, 3);
    for i = 1:4
        ax(i) = subplot(2, 2, i);
        hold(ax(i), 'on');
        switch i
            case 1
                sel = SEL{iFig} & c.isD & c.isM;
                title('DM')
            case 2
                sel = SEL{iFig} & c.isD & c.isL;
                title('DL')
            case 3
                sel = SEL{iFig} & c.isV & c.isM;
                title('VM')
            case 4
                sel = SEL{iFig} & c.isV & c.isL;
                title('VL')
        end
        x = DATA{iFig, 2}(sel);
        y = DATA{iFig, 1}(sel);
        sc = SCDATA{iFig}(sel); % Size and color
        sz = 25*abs(sc); % Size
        sg = sign(sc); % Sign/color
        h(i, 1) = scatter(x(sg>0), y(sg>0), sz(sg>0), 'red', 'filled', ...
            DisplayName=sprintf('N=%g', nnz(sg>0)));
        h(i, 2) = scatter(x(sg<0), y(sg<0), sz(sg<0), 'blue', 'filled', ...
            DisplayName=sprintf('N=%g', nnz(sg<0)));
    end

    xl = [min(horzcat(ax.XLim)), max(horzcat(ax.XLim))];
    yl = [min(horzcat(ax.YLim)), max(horzcat(ax.YLim))];
    for i = 1:4
        switch i
            case 1
                sel = SEL{iFig} & c.isD & c.isM;
                title('DM')
            case 2
                sel = SEL{iFig} & c.isD & c.isL;
                title('DL')
            case 3
                sel = SEL{iFig} & c.isV & c.isM;
                title('VM')
            case 4
                sel = SEL{iFig} & c.isV & c.isL;
                title('VL')
        end
        if any(sel)
            x = DATA{iFig, 2}(sel);
            y = DATA{iFig, 1}(sel);
            mdl = fitlm(x, y);
            h(i, 3) = plot(ax(i), xl, mdl.predict(xl'), 'k--', LineWidth=1, DisplayName=sprintf('R^2=%.2f', mdl.Rsquared.Ordinary));
            legend(ax(i), h(i, :), Location='best', AutoUpdate='off')
        end
        plot(ax(i), xl, [0, 0], 'k:')
        plot(ax(i), [0, 0], yl, 'k:')
    end
    xlim(ax, xl);
    ylim(ax, yl);

    annotation(fig, 'textbox', [0.1, 0.02, 0.9, 0.05], String=XNAME{iFig}, ...
        HorizontalAlignment='center', LineStyle='none', FontSize=12);

%     annotation(fig, 'textbox', [0.075, 0.1, 1, 0.05], String=YNAME{iFig}, ...
%         HorizontalAlignment='center', LineStyle='none', FontSize=12, Rotation=90);

    annotation(fig, 'textbox', [0.075,0.05,0.45,0.05], String=YNAME{iFig}, ...
        HorizontalAlignment='center', LineStyle='none', FontSize=12, Rotation=90);
   
end
clear xPos yPos x y mdl h ax fig xl yl sel i iFig sc sz sg

%% TODO: Embed in EphysUnit as static method
function info = getAnimalInfo(eu, ai, field)
    i = find(strcmpi({ai.name}, eu.getAnimalName()));
    assert(length(i) == 1, eu.getAnimalName())
    info = ai(i).(field);
end

function ax = plotRasterAndISI(rd, isi, xl)
    figure(Position=[200, 200, 300, 600], DefaultAxesFontSize=11);
    ax(1) = subplot(2, 1, 1);
    ax(2) = subplot(2, 1, 2);
    hold(ax(2), 'on')
    EphysUnit.plotRaster(ax(1), rd, xlim=xl, timeUnit='ms');

    t = isi.t;
    x = isi.isi;
    isiBaseline = isi.baseline;
    isiStd = isi.baselineSD;

    h(1) = plot(ax(2), t, x, 'k', LineWidth=2, DisplayName='ISI');
    xlim(xl)
    h(2) = patch(ax(2), [xl, flip(xl)], [isiBaseline + isiStd, isiBaseline + isiStd, isiBaseline - isiStd, isiBaseline - isiStd], 'k', FaceAlpha=0.2, DisplayName='std');
    h(3) = plot(ax(2), xl, [isiBaseline, isiBaseline], 'k:', LineWidth=2, DisplayName='baseline');
    if ~isempty(isi.peak) && ~isnan(isi.peak)
        tPeak = isi.peakLatency;
        xPeak = isi.peak;
        tOnset = isi.onsetLatency;
        xOnset = x(t==tOnset);
        h(end+1) = scatter(ax(2), tPeak, xPeak, 100, 'g', 'filled', DisplayName='peak');
        h(end+1) = scatter(tOnset, xOnset, 100, 'yellow', 'filled', DisplayName='onset');
        text(tPeak, xPeak, sprintf('%.0fms', tPeak))
        text(tOnset, xOnset, sprintf('%.0fms', tOnset));
    end
    plot(ax(2), [0, 0], ax(2).YLim, 'k:')
    title('ISI (Time since previous spike)')
    ylabel('ISI (ms)')
    yl = ax(2).YLim;
    plot(ax(2), [0, 0], ax(2).YLim, 'k:')
    ax(2).YLim = yl;
    xlabel('Time from opto onset (ms)')
    legend(ax(2), h, Location='best', FontSize=9)
        
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


    f = figure(Units='normalized', OuterPosition=[0, 0, 0.5, 1], DefaultAxesFontSize=14);
    nTrials(1) = min(length(rd(1).duration), maxTrials);
    nTrials(2) = min(length(rd(2).duration), maxTrials);
    xmargin = 0.16;
    ymargin = 0.09;
    ax(1) = axes(f, Position=[xmargin, 2*ymargin+nTrials(2)/sum(nTrials)*(1-0.09*3), 0.7, nTrials(1)/sum(nTrials)*(1-ymargin*3)]);
    ax(2) = axes(f, Position=[xmargin, ymargin, 0.7, nTrials(2)/sum(nTrials)*(1-ymargin*3)]);

    for i = 1:2
        EphysUnit.plotRaster(ax(i), rd(i), xlim=r.xlim, iti=r.iti, ...
            timeUnit=p.Results.timeUnit, maxTrials=maxTrials);
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
                fig = figure(Units='inches', Position=[0 0 3.5 7], DefaultAxesFontSize=14);
                ax = subplot(2, 1, 1);
                try
                    EphysUnit.plotRaster(ax, rd(iUnit), xlim=xl, ...
                        timeUnit='ms', maxTrials=p.Results.maxTrials);
                catch
                    disp()
                end
                ax.Legend.FontSize=12;
            
                ax = subplot(2, 1, 2);
                hold on
                h = gobjects(3, 1);
                h(1) = plot(ax, t, x, 'k', LineWidth=2, DisplayName='ISI');
                xlim(xl)
                h(2) = patch(ax, [xl, flip(xl)], [isiBaseline + isiStd, isiBaseline + isiStd, isiBaseline - isiStd, isiBaseline - isiStd], 'k', FaceAlpha=0.2);
                h(3) = plot(ax, xl, [isiBaseline, isiBaseline], 'k:', LineWidth=2, DisplayName='baseline');
                plot(ax, [0, 0], ax.YLim, 'k:')
                title('ISI (Time since previous spike)')
                ylabel('ISI (ms)')
                yl = ax.YLim;
                plot(ax, [0, 0], ax.YLim, 'k:')
                ax.YLim = yl;
                xlabel('Time from opto on (ms)')
                legend(ax, h, Location='best', FontSize=12)
                ax.FontSize=14;
        
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
                ax.Legend.FontSize = 11;
                ax.FontSize=13;

            
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
                legend(ax, h, Location='best', FontSize=11)
                ax.FontSize=13;

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
