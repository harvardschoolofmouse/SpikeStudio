
%% Lick vs. press vs. location
%% 1. Get position data
ar = AcuteRecording.load();
%%
euPos = NaN(length(eu), 3); % ml dv ap
c.hasPos = false(1, length(eu));
for iEu = 1:length(eu)
    iAr = find(strcmpi(eu(iEu).ExpName, {ar.expName}));
    if ~isempty(iAr)
        euPos(iEu, :) = ar(iAr).getProbeCoords(eu(iEu).Channel);
        c.hasPos(iEu) = true;
    end
end
clear iEu expName chn iAr

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

figure(Units='inches', Position=[0 0 6 6], DefaultAxesFontSize=9)

clear ax
% ax(1) = subplot(3, 2, 1);
N = histcounts2(yPos(c.hasPos & c.hasLick), xPos(c.hasPos & c.hasLick), yEdges, xEdges);
% bar(N(:))
% ylabel('Number of units')
% title('Sampling bias (lick-trials)')

ax(1) = subplot(3, 2, 1);
sel = c.hasPos & c.isLickDown;
n1 = histcounts2(yPos(sel), xPos(sel), yEdges, xEdges);
sel = c.hasPos & c.isLickUp;
n2 = histcounts2(yPos(sel), xPos(sel), yEdges, xEdges);
sel = c.hasPos & c.isLick & c.hasLick;
n3 = histcounts2(yPos(sel), xPos(sel), yEdges, xEdges);
bar([n1(:)./N(:), n2(:)./N(:), n3(:)./N(:)])
ylabel('Fraction of units')
title('Lick response')
legend({'suppressed (pre-move)', 'excited (pre-move)', 'oscillatory (lick)'}, FontSize=8, ...
    Orientation='horizontal', Position=[0.148341448746023,0.953484610393047,0.739583319208275,0.031249999275638])

xticklabels(ax, labels)
% ylim(ax(2:end), [0, 0.6]);
sum(N(:))

% 2. Plot press response by position
% ax(3) = subplot(3, 2, 3);
% N = histcounts2(yPos(c.hasPos & c.hasPress), xPos(c.hasPos & c.hasPress), yEdges, xEdges);
% bar(N(:))
% ylabel('Number of units')
% title('Sampling bias (reach-trials)')

ax(2) = subplot(3, 2, 2);
sel = c.hasPos & c.isPressDown;
n1 = histcounts2(yPos(sel), xPos(sel), yEdges, xEdges);
sel = c.hasPos & c.isPressUp;
n2 = histcounts2(yPos(sel), xPos(sel), yEdges, xEdges);
bar([n1(:)./N(:), n2(:)./N(:)])
ylabel('Fraction of units')
title('Reach response')
% legend({'suppressed (pre-move)', 'excited (pre-move)'}, FontSize=8)

xticklabels(ax, labels)
% ylim(ax(2:end), [0, 0.6]);
sum(N(:))

% Scatter move response vs lick response sactter by location
xEdges = [0 1300 2600];
yEdges = [0 4300 10000];
xPos = abs(euPos(:, 1))';
yPos = abs(euPos(:, 2))';

c.isM = xPos <= xEdges(2);
c.isL = xPos > xEdges(2);
c.isD = yPos <= yEdges(2);
c.isV = yPos > yEdges(2);


% figure(Units='pixels', Position=[0, 0, 600, 600], DefaultAxesFontSize=14);

% dmSNR
clear ax
if useNormalized
    yl = [-2.5, 4.5];
    xl = yl.*aspectRatio;
else
    yl = [-70, 110];
    xl = yl.*aspectRatio;
end

for i = 1:4
    clear h
    ax(i) = subplot(3, 2, 2+i); hold(ax(i), 'on');

    switch i
        case 1
            sel = c.hasPos & c.isD & c.isM & c.hasPress & c.hasLick;
            title('DM')
        case 2
            sel = c.hasPos & c.isD & c.isL & c.hasPress & c.hasLick;
            title('DL')
        case 3
            sel = c.hasPos & c.isV & c.isM & c.hasPress & c.hasLick;
            title('VM')
        case 4
            sel = c.hasPos & c.isV & c.isL & c.hasPress & c.hasLick;
            title('VL')
    end
    if useNormalized
        x = meta.press(sel);
        y = meta.lick(sel);
        srUnit = 'a.u.';
    else
        x = meta.pressRaw(sel)*10 - msr(sel);
        y = meta.lickRaw(sel)*10 - msr(sel);
        srUnit = '\Deltasp/s';
    end
    mdl = fitlm(x, y);
    h(1) = scatter(x, y, sz, 'filled', 'k', ...
        DisplayName=sprintf('N=%g', nnz(sel)));
    h(2) = plot(ax(i), xl, mdl.predict(xl'), 'k--', LineWidth=1, DisplayName=sprintf('R^2=%.2f', mdl.Rsquared.Ordinary));
    plot(ax(i), xl, [0, 0], 'k:')
    plot(ax(i), [0, 0], yl, 'k:')
%     axis(ax(i), 'image')
    if ismember(i, [1 3])
        ylabel(ax(i), sprintf('Lick response (%s)', srUnit))
    end
    if ismember(i, [3, 4])
        xlabel(ax(i), sprintf('Reach response (%s)', srUnit))
    end
    legend(ax(i), h, Location='southeast')
end

% Adjust x y lims
xlim(ax, xl);
ylim(ax, yl);
set(ax, FontSize=9)

%% Scatter move response vs stim response sactter by location
close all
xEdges = [0 1300 2600];
yEdges = [0 4300 10000];
xPos = abs(euPos(:, 1))';
yPos = abs(euPos(:, 2))';
sz = 25;

c.isM = xPos <= xEdges(2);
c.isL = xPos > xEdges(2);
c.isD = yPos <= yEdges(2);
c.isV = yPos > yEdges(2);


figure(Units='pixels', Position=[0, 0, 600, 600], DefaultAxesFontSize=14);

% dmSNR
xl = [-3.5, 4.5];
yl = [-3.5, 4.5];

for i = 1:4
    clear h
    ax(i) = subplot(2, 2, i); hold(ax(i), 'on');

    switch i
        case 1
            sel = c.hasPos & c.isD & c.isM & c.hasPress & c.hasLick & c.isA2A;
            title('DM')
        case 2
            sel = c.hasPos & c.isD & c.isL & c.hasPress & c.hasLick & c.isA2A;
            title('DL')
        case 3
            sel = c.hasPos & c.isV & c.isM & c.hasPress & c.hasLick & c.isA2A;
            title('VM')
        case 4
            sel = c.hasPos & c.isV & c.isL & c.hasPress & c.hasLick & c.isA2A;
            title('VL')
    end
%     x = meta.pressRaw(sel)*10 - msr(sel);
    x = meta.press(sel);
    y = meta.stim(sel);
    mdl = fitlm(x, y);
    h(1) = scatter(x, y, sz, 'filled', 'k', ...
        DisplayName=sprintf('N=%g', nnz(sel)));
    h(2) = plot(ax(i), xl, mdl.predict(xl'), 'k--', LineWidth=1, DisplayName=sprintf('R^2 = %.2f', mdl.Rsquared.Ordinary));
    plot(ax(i), xl, [0, 0], 'k:')
    plot(ax(i), [0, 0], yl, 'k:')
    if ismember(i, [1 3])
        ylabel(ax(i), 'iSPN response (a.u.)')
    end
    if ismember(i, [3, 4])
        xlabel(ax(i), 'Press response (a.u.)')
    end
    legend(ax(i), h, Location='southwest')
end

% Adjust x y lims
xlim(ax, xl);
ylim(ax, yl);

% Scatter move response vs lick response sactter by location
figure(Units='pixels', Position=[0, 0, 600, 600], DefaultAxesFontSize=14);

% dmSNR
xl = [-3.5, 4.5];
yl = [-3.5, 4.5];

for i = 1:4
    clear h
    ax(i) = subplot(2, 2, i); hold(ax(i), 'on');

    switch i
        case 1
            sel = c.hasPos & c.isD & c.isM & c.hasPress & c.hasLick & c.isAi80;
            title('DM')
        case 2
            sel = c.hasPos & c.isD & c.isL & c.hasPress & c.hasLick & c.isAi80;
            title('DL')
        case 3
%             sel = c.hasPos & c.isV & c.isM & c.hasPress & c.hasLick & c.isAi80;
            title('VM')
        case 4
            sel = c.hasPos & c.isV & c.isL & c.hasPress & c.hasLick & c.isAi80;
            title('VL')
    end
%     x = meta.pressRaw(sel)*10 - msr(sel);
    x = meta.press(sel);
    y = meta.stim(sel);
    mdl = fitlm(x, y);
    h(1) = scatter(x, y, sz, 'filled', 'k', ...
        DisplayName=sprintf('N=%g', nnz(sel)));
    h(2) = plot(ax(i), xl, mdl.predict(xl'), 'k--', LineWidth=1, DisplayName=sprintf('R^2 = %.2f', mdl.Rsquared.Ordinary));
    plot(ax(i), xl, [0, 0], 'k:')
    plot(ax(i), [0, 0], yl, 'k:')
    if ismember(i, [1 3])
        ylabel(ax(i), 'dSPN response (a.u.)')
    end
    if ismember(i, [3, 4])
        xlabel(ax(i), 'Press response (a.u.)')
    end
    legend(ax(i), h, Location='southwest')
end

% Adjust x y lims
xlim(ax, xl);
ylim(ax, yl);


figure(Units='pixels', Position=[0, 0, 600, 600], DefaultAxesFontSize=14);

% dmSNR
xl = [-3.5, 4.5];
yl = [-3.5, 4.5];

for i = 1:4
    clear h
    ax(i) = subplot(2, 2, i); hold(ax(i), 'on');

    switch i
        case 1
            sel = c.hasPos & c.isD & c.isM & c.hasPress & c.hasLick & c.isA2A;
            title('DM')
        case 2
            sel = c.hasPos & c.isD & c.isL & c.hasPress & c.hasLick & c.isA2A;
            title('DL')
        case 3
            sel = c.hasPos & c.isV & c.isM & c.hasPress & c.hasLick & c.isA2A;
            title('VM')
        case 4
            sel = c.hasPos & c.isV & c.isL & c.hasPress & c.hasLick & c.isA2A;
            title('VL')
    end
    x = meta.lick(sel);
    y = meta.stim(sel);
    mdl = fitlm(x, y);
    h(1) = scatter(x, y, sz, 'filled', 'k', ...
        DisplayName=sprintf('N=%g', nnz(sel)));
    h(2) = plot(ax(i), xl, mdl.predict(xl'), 'k--', LineWidth=1, DisplayName=sprintf('R^2 = %.2f', mdl.Rsquared.Ordinary));
    plot(ax(i), xl, [0, 0], 'k:')
    plot(ax(i), [0, 0], yl, 'k:')
    if ismember(i, [1 3])
        ylabel(ax(i), 'iSPN response (a.u.)')
    end
    if ismember(i, [3, 4])
        xlabel(ax(i), 'Lick response (a.u.)')
    end
    legend(ax(i), h, Location='southwest')
end

% Adjust x y lims
xlim(ax, xl);
ylim(ax, yl);

% Scatter move response vs lick response sactter by location
figure(Units='pixels', Position=[0, 0, 600, 600], DefaultAxesFontSize=14);

% dmSNR
xl = [-3.5, 4.5];
yl = [-3.5, 4.5];

for i = 1:4
    clear h
    ax(i) = subplot(2, 2, i); hold(ax(i), 'on');

    switch i
        case 1
            sel = c.hasPos & c.isD & c.isM & c.hasPress & c.hasLick & c.isAi80;
            title('DM')
        case 2
            sel = c.hasPos & c.isD & c.isL & c.hasPress & c.hasLick & c.isAi80;
            title('DL')
        case 3
            sel = c.hasPos & c.isV & c.isM & c.hasPress & c.hasLick & c.isAi80;
            title('VM')
        case 4
            sel = c.hasPos & c.isV & c.isL & c.hasPress & c.hasLick & c.isAi80;
            title('VL')
    end
    x = meta.lick(sel);
    y = meta.stim(sel);
    mdl = fitlm(x, y);
    h(1) = scatter(x, y, sz, 'filled', 'k', ...
        DisplayName=sprintf('N=%g', nnz(sel)));
    h(2) = plot(ax(i), xl, mdl.predict(xl'), 'k--', LineWidth=1, DisplayName=sprintf('R^2 = %.2f', mdl.Rsquared.Ordinary));
    plot(ax(i), xl, [0, 0], 'k:')
    plot(ax(i), [0, 0], yl, 'k:')
    if ismember(i, [1 3])
        ylabel(ax(i), 'dSPN response (a.u.)')
    end
    if ismember(i, [3, 4])
        xlabel(ax(i), 'Lick response (a.u.)')
    end
    legend(ax(i), h, Location='southwest')
end

% Adjust x y lims
xlim(ax, xl);
ylim(ax, yl);

