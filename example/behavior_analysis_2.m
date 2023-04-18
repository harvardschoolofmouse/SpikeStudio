% clear
p.fontSize = 13;
%% Filter out bad animals
whitelist = ...
[ ...
    {'daisy2'   }; ...
    {'daisy3'   }; ...
    {'daisy10'  }; ...
    {'daisy12'  }; ...
    {'daisy13'  }; ...
    {'daisy14'  }; ...
    {'daisy15'  }; ...
    {'daisy16'  }; ...
    {'daisy4'   }; ...
    {'daisy5'   }; ...
    {'daisy7'   }; ...
    {'daisy8'   }; ...
    {'daisy9'   }; ...
    {'desmond10'}; ...
    {'desmond11'}; ...
    {'desmond12'}; ...
    {'desmond13'}; ...
    {'desmond15'}; ...
    {'desmond16'}; ...
    {'desmond17'}; ...
    {'desmond18'}; ...
    {'desmond20'}; ...
    {'desmond21'}; ...
    {'desmond22'}; ...
    {'desmond23'}; ...
    {'desmond24'}; ...
    {'desmond25'}; ...
    {'desmond26'}; ...
    {'desmond27'}; ...
];

S = load('E:\Data\bs.mat');
bs = S.bs;
clear S
bs = cellfun(@(x) x(x.isvalid()), bs, 'UniformOutput', false);
animalNames = cellfun(@(bs) bs.animalName, bs, UniformOutput=false);
isWhitelisted = ismember(animalNames, whitelist);
bs = bs(isWhitelisted);
nAnimals = length(bs);

%% Extract data
interval = cellfun(@(bs) arrayfun(@(bs) mean(bs.getParams('INTERVAL_MIN')), bs), bs, 'UniformOutput', false);
maxInterval = cellfun(@(x) max(x), interval);
lastInterval = cellfun(@(x) x(end), interval);
nPressTrials = cellfun(@(bs) bs.countTrials('press'), bs, UniformOutput=false);
nPressTrialsAggr = cat(1, nPressTrials{:});
nPressTrialsAggr(nPressTrialsAggr == 0) = [];
fprintf(1, '%g animals, %g to %g press trials, median %g.\n', length(bs), prctile(nPressTrialsAggr, 5), prctile(nPressTrialsAggr, 95), median(nPressTrialsAggr))

intervalAggr = cat(1, interval{:});

pressTimes = cellfun(@(x) arrayfun(@(y) y.getEventTimesRelative('LEVER_PRESSED', RequireTrialType='lever'), x, 'UniformOutput', false, 'ErrorHandler', @(varargin) []), bs, 'UniformOutput', false);
pressTimesAggr = cat(1, pressTimes{:});
nPressTrialsActual = nonzeros(cellfun(@length, pressTimesAggr));

nPressTrialsEarly = cellfun(@(bs) bs.countTrials('press', 'early'), bs, UniformOutput=false);
nPressTrialsCorrect = cellfun(@(bs) bs.countTrials('press', 'correct'), bs, UniformOutput=false);
nPressTrialsNoMove = cellfun(@(bs) bs.countTrials('press', 'nomove'), bs, UniformOutput=false);

nPressTrialsEarly = nonzeros(cat(1, nPressTrialsEarly{:}));
nPressTrialsCorrect = nonzeros(cat(1, nPressTrialsCorrect{:}));
nPressTrialsNoMove = nonzeros(cat(1, nPressTrialsNoMove{:}));

fprintf(1, '%g to %g early press trials, median %g.\n', prctile(nPressTrialsEarly, 5), prctile(nPressTrialsEarly, 95), median(nPressTrialsEarly))
fprintf(1, '%g to %g correct press trials, median %g.\n', prctile(nPressTrialsCorrect, 5), prctile(nPressTrialsCorrect, 95), median(nPressTrialsCorrect))
fprintf(1, '%g to %g nomove press trials, median %g.\n', prctile(nPressTrialsNoMove, 5), prctile(nPressTrialsNoMove, 95), median(nPressTrialsNoMove))


%% Plot training progress for lever press
minTrials = 30;
nPressTrials = cellfun(@(x) x.countTrials('press'), bs, 'UniformOutput', false);
nLickTrials = cellfun(@(x) x.countTrials('lick'), bs, 'UniformOutput', false);
selPress = cellfun(@(x) x>minTrials, nPressTrials, UniformOutput=false);
selLick = cellfun(@(x) x>minTrials, nLickTrials, UniformOutput=false);
bsPress = cellfun(@(x, y) x(y), bs, selPress, UniformOutput=false);
bsLick = cellfun(@(x, y) x(y), bs, selLick, UniformOutput=false);
pressTimes = cellfun(@(x) arrayfun(@(y) y.getEventTimesRelative('LEVER_PRESSED', RequireTrialType='lever'), x, 'UniformOutput', false, 'ErrorHandler', @(varargin) []), bsPress, 'UniformOutput', false);
lickTimes = cellfun(@(x) arrayfun(@(y) y.getEventTimesRelative('LICK', RequireTrialType='lick'), x, 'UniformOutput', false, 'ErrorHandler', @(varargin) []), bsLick, 'UniformOutput', false);


%% Collect data from certain days
daysPress = 1:50;
daysLick = 1:30;
ndaysPress = length(daysPress);
ndaysLick = length(daysLick);
ndays = max(ndaysPress, ndaysLick);
pt = cell(nAnimals, ndays);
lt = cell(nAnimals, ndays);
for ia = 1:nAnimals
    for id = 1:ndays
        try
            pt{ia, id} = pressTimes{ia}{daysPress(id)};
        catch
            pt{ia, id} = [];
        end
    end
end
for ia = 1:nAnimals
    for id = 1:ndays
        try
            lt{ia, id} = lickTimes{ia}{daysLick(id)};
        catch
            lt{ia, id} = [];
        end
    end
end
[mPress, nSessionsPress] = max(cellfun(@isempty, pt), [], 2);
[mLick, nSessionsLick] = max(cellfun(@isempty, lt), [], 2);
nSessionsPress = nSessionsPress - 1;
nSessionsLick = nSessionsLick - 1;
nSessionsPress(mPress == 0 & nSessionsPress == 0) = size(pt, 2);
nSessionsLick(mLick == 0 & nSessionsLick == 0) = size(lt, 2);

nAnimalsPress = nnz(nSessionsPress ~= 0);
nAnimalsLick = nnz(nSessionsLick ~= 0);

ptcat = cell(1, ndaysPress);
ltcat = cell(1, ndaysLick);
for id = 1:ndaysPress
    ptcat{id} = cat(1, pt{:, id});
end
for id = 1:ndaysLick
    ltcat{id} = cat(1, lt{:, id});
end
nTrialsPress = cellfun(@length, ptcat);
nTrialsLick = cellfun(@length, ltcat);
%% Plot aggregate histograms
close all
clear fig ax
edges = 0:0.5:10;

% Plot aggregate histograms as line plots
fig = figure(Units='inches', Position=[0, 0, 6.5, 3.5], DefaultAxesFontSize=p.fontSize);
ax = axes(fig);
centers = 0.5*(edges(2:end) + edges(1:end-1));
hold(ax, 'on')
ndayshown = 18;
for id = 1:ndayshown
    N = histcounts(ptcat{id}, edges, Normalization='probability');
    plot(ax, centers, N, Color=hsl2rgb([0.7*(id-1)/(ndayshown-1), 1, 0.5]), LineWidth=1, DisplayName=sprintf('Day %g (%g trials)', daysPress(id), nTrialsPress(id)))
    xlabel(ax, 'Contact time (s)')
    ylabel(ax, 'Probability')
end
hold(ax, 'off')
legend(ax, Location='northeast', NumColumns=2)
title(ax, sprintf('Reach task training progress (%g animals)', nAnimalsPress))
set(ax, FontSize=p.fontSize);
clear ax fig id

fig = figure(Units='inches', Position=[0, 0, 6.5, 3.5], DefaultAxesFontSize=p.fontSize);
ax = axes(fig);
hold(ax, 'on')
for id = 1:ndayshown
    N = histcounts(ltcat{id}, edges, Normalization='probability');
    plot(ax, centers, N, Color=hsl2rgb([0.7*(id-1)/(ndayshown-1), 1, 0.5]), LineWidth=1, DisplayName=sprintf('Day %g (%g trials)', daysPress(id), nTrialsLick(id)))
    xlabel(ax, 'Contact time (s)')
    ylabel(ax, 'Probability')
end
hold(ax, 'off')
legend(ax, Location='northeast', NumColumns=2)
title(ax, sprintf('Lick task training progress (%g animals)', nAnimalsLick))
set(ax, FontSize=p.fontSize);
clear ax fig id

%% Plot all sessions for some animals
close all
for ia = 1:29
    
    ncols = 6;
    nrows = ceil(nSessionsPress(ia)/ncols);
    fig = figure(Units='inches', Position=[0, 0, 6.5, 9], DefaultAxesFontSize=p.fontSize, Name='Reach task training progress');
    
%     [~, bestDay] = sort(abs(cellfun(@median, pt) - 3.5) + 0.5*cellfun(@std, pt) - cellfun(@(pt) nnz(pt <= 1) / length(pt), pt), 2);
    [~, bestDayPress] = sort(-cellfun(@(pt) nnz(pt >= 3 & pt <= 7) / nnz(pt >= 1), pt), 2);
    for id = 1:nSessionsPress(ia)
        ax = subplot(nrows, ncols, id);
        histogram(ax, pt{ia, id}, edges);
        if ismember(id, bestDayPress(ia, 1))
            title(ax, sprintf('%g-day %g', ia, id), Color='red')
        else
            title(ax, sprintf('%g-day %g', ia, id), Color='black')
        end
    end
    suptitle(animalNames{ia})
end

%% Plot individual histograms as line plots
close all
animalNames = cellfun(@(bs) bs(1).animalName, bs, UniformOutput=false);


edges = 1:1:10;
centers = 0.5*(edges(2:end) + edges(1:end-1));

ncols = 5;
nrows = ceil(nAnimalsPress/ncols);
fig = figure(Units='inches', Position=[0, 0, 6.5, 6], DefaultAxesFontSize=p.fontSize, Name='Reach task training progress');

hasPress = nSessionsPress > 0;
hasLick = nSessionsLick > 0;

[~, bestDayPress] = sort(-cellfun(@(t) nnz(t >= 3 & t <= 7) / nnz(t >= 1), pt), 2);
[~, bestDayLick] = sort(-cellfun(@(t) nnz(t >= 3 & t <= 7) / nnz(t >= 1), lt), 2);


for ia = find(hasPress(:)')
    ax = subplot(nrows, ncols, ia);
    hold(ax, 'on')
    ptsel = pt(ia, bestDayPress(ia, 1:3));
    ptsel = cat(1, ptsel{:});
    ptsel = ptsel(ptsel >= edges(1));
    N = histcounts(ptsel, edges, Normalization='probability');
    plot(ax, centers, N, 'r', LineWidth=2)
    ylim(ax, [0, max(N) + 0.01])
    
%     ndays = nSessionsPress(ia);
%     for id = 1:ndays
%         N = histcounts(pt{ia, id}, edges, Normalization='probability');
%         plot(ax, centers, N, Color=hsl2rgb([0.7*(id-1)/(ndays-1), 0.1, 0.5]), LineWidth=0.1, DisplayName=sprintf('Day %g', daysPress(id)))
%     end
    hold(ax, 'off')
    set(ax, FontSize=p.fontSize);
    if contains(lower(animalNames{ia}), 'daisy')
        title(ax, sprintf('%d (F)', ia))
    else
        title(ax, sprintf('%d (M)', ia))
    end

end

% for ia = find(hasLick(:)')
%     ax = subplot(nrows, ncols, ia);
%     hold(ax, 'on')
%     ltsel = lt(ia, bestDayLick(ia, 1:5));
%     ltsel = cat(1, ltsel{:});
%     N = histcounts(ltsel, edges, Normalization='probability');
%     plot(ax, centers, N, 'b', LineWidth=2)
% end

annotation(fig, 'textbox', [0.064397435897436,0.030638888888889,0.9,0.05], String='Time to contact (s)', ...
    HorizontalAlignment='center', LineStyle='none', FontSize=11);
annotation(fig, 'textbox', [0.093576923076923,0.264583333333332,0.45,0.05], String='Probability', ...
    HorizontalAlignment='center', LineStyle='none', FontSize=11, Rotation=90);
clear ax fig id


%% Plot individual histograms as line plots (press vs lick
% close all


edges = 1:1:10;
centers = 0.5*(edges(2:end) + edges(1:end-1));

hasPress = nSessionsPress > 0;
hasLick = nSessionsLick > 0;

ncols = 4;
nrows = ceil(nnz(hasPress & hasLick)/ncols);
fig = figure(Units='inches', Position=[0, 0, 6.5, 4.5], DefaultAxesFontSize=p.fontSize, Name='Reach task training progress');

hasPress = nSessionsPress > 0;
hasLick = nSessionsLick > 0;

[~, bestDay] = sort(-cellfun(@(t) nnz(t >= 3 & t <= 7) / nnz(t >= 1), pt) - cellfun(@(t) nnz(t >= 3 & t <= 7) / nnz(t >= 1), lt), 2);

i = 0;
for ia = find(hasPress(:)' & hasLick(:)')
    i = i + 1;
    ax = subplot(nrows, ncols, i);
    hold(ax, 'on')
    ptsel = pt(ia, bestDay(ia, 1:3));
    ptsel = cat(1, ptsel{:});
    ptsel(ptsel < edges(1)) = [];
    N1 = histcounts(ptsel, edges, Normalization='probability');
    plot(ax, centers, N1, 'r', LineWidth=2, DisplayName='Reach')

    ltsel = lt(ia, bestDay(ia, 1:3));
    ltsel = cat(1, ltsel{:});
    ltsel(ltsel < edges(1)) = [];
    N2 = histcounts(ltsel, edges, Normalization='probability');
    plot(ax, centers, N2, 'b', LineWidth=2, DisplayName='Lick')

    ylim(ax, [0, max([N1, N2]) + 0.01])
    
%     ndays = nSessionsPress(ia);
%     for id = 1:ndays
%         N = histcounts(pt{ia, id}, edges, Normalization='probability');
%         plot(ax, centers, N, Color=hsl2rgb([0.7*(id-1)/(ndays-1), 0.1, 0.5]), LineWidth=0.1, DisplayName=sprintf('Day %g', daysPress(id)))
%     end
    hold(ax, 'off')
    set(ax, FontSize=p.fontSize);
    if contains(lower(animalNames{ia}), 'daisy')
        title(ax, sprintf('%d (F)', ia))
    else
        title(ax, sprintf('%d (M)', ia))
    end

end
legend(ax, Position=[0.353156636288793,0.946397568363208,0.308617231363285,0.046874998913457], Orientation='horizontal')

% for ia = find(hasLick(:)')
%     ax = subplot(nrows, ncols, ia);
%     hold(ax, 'on')
%     ltsel = lt(ia, bestDayLick(ia, 1:5));
%     ltsel = cat(1, ltsel{:});
%     N = histcounts(ltsel, edges, Normalization='probability');
%     plot(ax, centers, N, 'b', LineWidth=2)
% end

annotation(fig, 'textbox', [0.062393427881404,0.028034722222222,0.899999999999997,0.05], String='Time to contact (s)', ...
    HorizontalAlignment='center', LineStyle='none', FontSize=11);
annotation(fig, 'textbox', [0.06151279482041,0.202083333333332,0.449999999999998,0.05], String='Probability', ...
    HorizontalAlignment='center', LineStyle='none', FontSize=11, Rotation=90);
clear ax fig id