%% Read all Experiments
dirs = dir('C:\SERVER'); 
dirs = cellfun(@(x, y) sprintf('%s\\%s', x, y), {dirs.folder}, {dirs.name}, 'UniformOutput', false); 
dirs = dirs(isfolder(dirs) & contains(dirs, {'daisy', 'desmond'}) & ~contains(dirs, 'unfinished'));

for iAnimal = 1:length(dirs)
    animalName = strsplit(dirs{iAnimal}, '\');
    animalName = animalName{end};
    f = dir(sprintf('C:\\SERVER\\%s\\%s_*\\%s_*.mat', animalName, animalName, animalName));
    startIndex = regexpi({f.name}, '(daisy|desmond).*[0-9]{8}\.mat$');
    isMatch = ~cellfun(@isempty, startIndex);
    f = f(isMatch);
    files = cellfun(@(x, y) sprintf('%s\\%s', x, y), {f.folder}, {f.name}, 'UniformOutput', false);
    bs{iAnimal} = BehaviorSession(files);
end

save('E:\DATA\bs.mat', 'bs');

%% Filter out bad animals
close all; clear; clc;
S = load('E:\Data\bs.mat');
bs = S.bs;
clear S
minSessions = 7;
minTrials = 30;
bs = cellfun(@(x) x(x.isvalid()), bs, 'UniformOutput', false);
nPressTrials = cellfun(@(x) x.countTrials('press'), bs, 'UniformOutput', false);
nLickTrials = cellfun(@(x) x.countTrials('lick'), bs, 'UniformOutput', false);
selPress = cellfun(@(x) x>minTrials, nPressTrials, UniformOutput=false);
selLick = cellfun(@(x) x>minTrials, nLickTrials, UniformOutput=false);
bsPress = cellfun(@(x, y) x(y), bs, selPress, UniformOutput=false);
bsLick = cellfun(@(x, y) x(y), bs, selLick, UniformOutput=false);
bsPress = bsPress(cellfun(@(x) length(x) >= minSessions, bsPress));
bsLick = bsLick(cellfun(@(x) length(x) >= minSessions, bsLick));
pressTimes = cellfun(@(x) arrayfun(@(y) y.getEventTimesRelative('LEVER_PRESSED', RequireTrialType='lever'), x, 'UniformOutput', false, 'ErrorHandler', @(varargin) []), bsPress, 'UniformOutput', false);
lickTimes = cellfun(@(x) arrayfun(@(y) y.getEventTimesRelative('LICK', RequireTrialType='lick'), x, 'UniformOutput', false, 'ErrorHandler', @(varargin) []), bsLick, 'UniformOutput', false);
clear sel


%% Collect data from certain days
days = 1:14;
ndays = length(days);
nAnimalsPress = length(pressTimes);
nAnimalsLick = length(lickTimes);
pt = cell(nAnimalsPress, ndays);
lt = cell(nAnimalsLick, ndays);
for ia = 1:nAnimalsPress
    for id = 1:ndays
        try
            pt{ia, id} = pressTimes{ia}{days(id)};
        end
    end
end
for ia = 1:nAnimalsLick
    for id = 1:ndays
        try
            lt{ia, id} = lickTimes{ia}{days(id)};
        end
    end
end

% Ensure requested sessions exist.
% assert(all(all(~cellfun(@isempty, pt), 2)))
% assert(all(all(~cellfun(@isempty, lt), 2)))
ptcat = cell(1, ndays);
ltcat = cell(1, ndays);
for id = 1:ndays
    ptcat{id} = cat(1, pt{:, id});
    ltcat{id} = cat(1, lt{:, id});
end
nTrialsPress = cellfun(@length, ptcat);
nTrialsLick = cellfun(@length, ltcat);
animalNamesPress = cellfun(@(x) x(days(1)).animalName, bsPress, 'UniformOutput', false);
animalNamesLick = cellfun(@(x) x(days(1)).animalName, bsLick, 'UniformOutput', false);

%% Plot aggregate histograms
close all
clear fig ax
edges = 0:0.5:10;

figure(Units='normalized', Position=[0, 0.2, 0.15*ndays, 0.5], DefaultAxesFontSize=14);
for id = 1:ndays
    ax = subplot(1, ndays, id);
    histogram(ax, ptcat{id}, edges, Normalization='probability');
    title(ax, sprintf('Day %g (%g trials)', days(id), nTrialsPress(id)));
    xlabel(ax, 'Press time (s)')
    if id  == 1
        ylabel(ax, 'Frequency')
    end
    ylim(ax, [0, 0.25])
end
suptitle(sprintf('Lever-press training progress (%g animals)', nAnimalsPress))
clear ax fig id

figure(Units='normalized', Position=[0, 0.2, 0.15*ndays, 0.5], DefaultAxesFontSize=14);
for id = 1:ndays
    ax = subplot(1, ndays, id);
    histogram(ax, ltcat{id}, edges, Normalization='probability');
    title(ax, sprintf('Day %g (%g trials)', days(id), nTrialsLick(id)));
    xlabel(ax, 'Lick time (s)')
    if id  == 1
        ylabel(ax, 'Frequency')
    end
    ylim(ax, [0, 0.16])
end
suptitle(sprintf('Lick training progress (%g animals)', nAnimalsLick))
clear ax fig id

% Plot aggregate histograms as line plots
fig = figure(Units='normalized', Position=[0, 0.4, 0.4, 0.5], DefaultAxesFontSize=14);
ax = axes(fig);
edges = 0:0.5:10;
centers = 0.5*(edges(2:end) + edges(1:end-1));
hold(ax, 'on')
for id = 1:ndays
    N = histcounts(ptcat{id}, edges, Normalization='probability');
    plot(ax, centers, N, Color=hsl2rgb([0.7*(id-1)/(ndays-1), 1, 0.5]), LineWidth=4, DisplayName=sprintf('Day %g (%g trials)', days(id), nTrialsPress(id)))
    xlabel(ax, 'Press time (s)')
    ylabel(ax, 'Frequency')
end
hold(ax, 'off')
legend(ax)
title(ax, sprintf('Lever-press training progress (%g animals)', nAnimalsPress))
clear ax fig id

fig = figure(Units='normalized', Position=[0, 0.2, 0.4, 0.5], DefaultAxesFontSize=14);
ax = axes(fig);
hold(ax, 'on')
for id = 1:ndays
    N = histcounts(ltcat{id}, edges, Normalization='probability');
    plot(ax, centers, N, Color=hsl2rgb([0.7*(id-1)/(ndays-1), 1, 0.5]), LineWidth=4, DisplayName=sprintf('Day %g (%g trials)', days(id), nTrialsLick(id)))
    xlabel(ax, 'Lick time (s)')
    ylabel(ax, 'Frequency')
end
hold(ax, 'off')
legend(ax)
title(ax, sprintf('Lick training progress (%g animals)', nAnimalsLick))
clear ax fig id

% Plot individual histograms as line plots
edges = 0:0.5:10;
centers = 0.5*(edges(2:end) + edges(1:end-1));

ncols = 4;
nrows = ceil(nAnimalsPress/ncols);
fig = figure(Units='normalized', Position=[0, 0.05, 0.133*ncols, nrows*0.125], DefaultAxesFontSize=10, Name='Lever-press training progress');

for ia = 1:nAnimalsPress
    ax = subplot(nrows, ncols, ia);
    hold(ax, 'on')
    for id = 1:ndays
        N = histcounts(pt{ia, id}, edges, Normalization='probability');
        plot(ax, centers, N, Color=hsl2rgb([0.7*(id-1)/(ndays-1), 1, 0.5]), LineWidth=2, DisplayName=sprintf('Day %g', days(id)))
        xlabel(ax, 'Press time (s)')
        ylabel(ax, 'Frequency')
%         ylim(ax, [0, 0.25])
    end
    hold(ax, 'off')
    title(ax, animalNamesPress{ia})
end
legend(ax)
clear ax fig id

fincols = 3;
nrows = ceil(nAnimalsLick/ncols);
g = figure(Units='normalized', Position=[0, 0.05, 0.133*ncols, nrows*0.125], DefaultAxesFontSize=10, Name='Lick training progress');
for ia = 1:nAnimalsLick
    ax = subplot(nrows, ncols, ia);
    hold(ax, 'on')
    for id = 1:ndays
        N = histcounts(lt{ia, id}, edges, Normalization='probability');
        plot(ax, centers, N, Color=hsl2rgb([0.7*(id-1)/(ndays-1), 1, 0.5]), LineWidth=2, DisplayName=sprintf('Day %g', days(id)))
        xlabel(ax, 'Lick time (s)')
        ylabel(ax, 'Frequency')
%         ylim(ax, [0, 0.25])
    end
    hold(ax, 'off')
    title(ax, animalNamesLick{ia})
end
legend(ax)
clear ax fig id