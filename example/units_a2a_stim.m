daisy7 = load("C:\SERVER\daisy7\PETH.mat");
desmond20 = load("C:\SERVER\desmond20\PETH.mat");
PETHStim = horzcat(desmond20.PETH, daisy7.PETH);
clear daisy7 desmond20
% Sorted stim PETHStim
for i = 1:length(PETHStim)
	Stim = PETHStim(i).Stim;
	sel = Stim(1).Timestamps <= 0.2;
	t = Stim(1).Timestamps(sel);
	thisPeth = zeros(1, sum(sel));
	for j = 1:length(Stim)
		thisPeth = thisPeth + Stim(j).SpikeRate(sel) * Stim(j).NumTrains;
	end
	pethStim(i, 1:length(t)) = thisPeth ./ sum([Stim.NumTrains]);
end
clear i sel Stim
%%
[pethStimSorted, Istim, whenDidFiringRateChange] =  TetrodeRecording.SortPETH(pethStim, 'Method', 'latency', 'LatencyThreshold', 0.675);
pethStimSortedNorm = TetrodeRecording.NormalizePETH(pethStimSorted, 'Method', 'zscore', 'BaselineSamples', t < 0);


figure()
axes()
hold on
for i = 1:size(pethStimSortedNorm, 1)
	sel = t >= -0.2;
	isDec = any(pethStimSortedNorm(i, t>=0 & t < 0.03) < -2);
    isInc = any(pethStimSortedNorm(i, t>=0 & t < 0.03) > 2);
	if isDec
		plot(t(sel)*1000, pethStimSortedNorm(i, sel), 'color', [.2, .8, .2, 0.67])
    elseif isInc
		plot(t(sel)*1000, pethStimSortedNorm(i, sel), 'color', [.8, .2, .2, 0.67])
    else
		plot(t(sel)*1000, pethStimSortedNorm(i, sel), 'color', [.2, .2, .2, 0.67])
    end
end
plot([0, 10], [55, 55], 'b', 'LineWidth', 3)
hold off
title(char(sprintf("Adora2a-ChR2 stim response of %d SNr units", size(pethStim, 1))))
xlabel("Time (ms)")
ylabel("Spike rate (z-score)")
xlim([-100, 100])


%% Contingency table
% Normalize rates
pethStimNorm = TetrodeRecording.NormalizePETH(pethStim, 'Method', 'zscore', 'BaselineSamples', t < 0);


tPress = PETHStim(1).Time;
pethPress = transpose(reshape([PETHStim.Press], [length(tPress), length(PETHStim)]));
pethPressNorm = TetrodeRecording.NormalizePETH(pethPress, 'Method', 'zscore', 'BaselineSamples', tPress < -2 & tPress > -4);

% Find isDec/isInc
for i = 1:length(PETHStim)
	PETHStim(i).IsDecStim = any(pethStimNorm(i, t>=0 & t <= 0.025) < -2);
	PETHStim(i).IsIncStim = any(pethStimNorm(i, t>=0 & t <= 0.025) > 2);
	PETHStim(i).IsDecPress = any(pethPressNorm(i, tPress>=-2 & tPress <= 0) < -3);
	PETHStim(i).IsIncPress = any(pethPressNorm(i, tPress>=-2 & tPress <= 0) > 3);

	normStim = pethStimNorm(i, t>=0 & t <= 0.02);
	[~, iMaxStimEffect] = max(abs(normStim));
	PETHStim(i).MaxStimEffect = normStim(iMaxStimEffect);

	normPress = pethPressNorm(i, tPress>=-2 & tPress <= 0);
	[~, iMaxPressEffect] = max(abs(normPress));
	PETHStim(i).MaxPressEffect = normPress(iMaxPressEffect);
end

sigma_threshold = 2;
maxPressEffect = [PETHStim.MaxPressEffect];
maxStimEffect = [PETHStim.MaxStimEffect];
sel = abs(maxPressEffect) > sigma_threshold & abs(maxStimEffect) > sigma_threshold;
f = figure;
ax = axes(f);
hold on
plot(ax, maxPressEffect(sel), maxStimEffect(sel), 'o')
plot(ax, ax.XLim, [0, 0], 'k:')
plot(ax, [0, 0], ax.YLim, 'k:')
hold off
xlabel('Press effect (\sigma) ([-2s, 0])')
ylabel('Stim effect (\sigma) ([0, 25ms]')

% sum([PETHStim.IsDecPress])
% sum([PETHStim.IsIncPress])

contTable = zeros(3);
contTable(1, 1) = sum([PETHStim.IsDecPress] & [PETHStim.IsDecStim]);
contTable(1, 2) = sum([PETHStim.IsDecPress] & [PETHStim.IsIncStim]);
contTable(1, 3) = sum([PETHStim.IsDecPress] & ~([PETHStim.IsDecStim] | [PETHStim.IsIncStim]));
contTable(2, 1) = sum([PETHStim.IsIncPress] & [PETHStim.IsDecStim]);
contTable(2, 2) = sum([PETHStim.IsIncPress] & [PETHStim.IsIncStim]);
contTable(2, 3) = sum([PETHStim.IsIncPress] & ~([PETHStim.IsDecStim] | [PETHStim.IsIncStim]));
contTable(3, 1) = sum(~([PETHStim.IsDecPress] | [PETHStim.IsIncPress]) & [PETHStim.IsDecStim]);
contTable(3, 2) = sum(~([PETHStim.IsDecPress] | [PETHStim.IsIncPress]) & [PETHStim.IsIncStim]);
contTable(3, 3) = sum(~([PETHStim.IsDecPress] | [PETHStim.IsIncPress]) & ~([PETHStim.IsDecStim] | [PETHStim.IsIncStim]));
contTable(4, 1:3) = sum(contTable, 1);
contTable(1:3, 4) = sum(contTable(1:3, 1:3), 2);

% Heatmap of contingency table
cmap = zeros(33, 3);
color1 = [1, 0, 0];
color2 = [0, 1, 0];
for i = 1:33
	t = (i - 1) / 32;
	c = color1 * (1 - t) + color2 * t;
	c = c / norm(c);
	cmap(i, :) = c;
end

heatmap = contTable(1:3, 1:3);
for irow = 1:3
	heatmap(irow, :) = heatmap(irow, :) / sum(heatmap(irow, :));
end
imagesc(heatmap)
colormap(cmap);
caxis([0, 1])
colorbar

% 3 hists
f = figure;
ax = subplot(3, 1, 1)
bar(contTable(1, 1:3))
ylabel(ax, 'Move OFF')
ax.FontSize = 12;

ax = subplot(3, 1, 2)
bar(contTable(2, 1:3))
ylabel(ax, 'Move ON')
ax.FontSize = 12;

ax = subplot(3, 1, 3)
bar(contTable(3, 1:3))
ylabel(ax, 'Move FLAT')
ax.XTickLabels = {'Inhibited', 'Excited', 'No effect'}
xlabel(ax, 'ChR2 stim response')
ax.FontSize = 12;