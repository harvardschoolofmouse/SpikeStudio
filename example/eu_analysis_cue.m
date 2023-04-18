% EphysUnit.plotETA(eta.pressCue, c.hasPress, xlim=[-1,2], clim=[-1.5, 1.5], sortWindow=[-0.8, 0.8], signWindow=[-0.8, 0], sortThreshold=0.3, negativeSortThreshold=0.15); title('Reach Cue ETA')

close all
EphysUnit.plotDoubleETA(eta.pressCue, eta.press, c.hasPress & c.hasLick, 'Cue (reach trials)', 'Reach', xlim={[-1,2], [-3, 0]}, clim=[-1.5, 1.5], sortWindow=[-0.8, 0], signWindow=[-0.4, -0.2], sortThreshold=0.01, negativeSortThreshold=[]);
EphysUnit.plotDoubleETA(eta.lickCue, eta.lick, c.hasPress & c.hasLick, 'Cue (lick trials)', 'Lick', xlim={[-1,2], [-3, 0]}, clim=[-1.5, 1.5], sortWindow=[-0.8, 0], signWindow=[-0.4, -0.2], sortThreshold=0.01, negativeSortThreshold=[]);
EphysUnit.plotDoubleETA(eta.pressCue, eta.lickCue, c.hasPress & c.hasLick, 'Cue (reach trials)', 'Cue (lick trials)', xlim=[-1,2], clim=[-1.5, 1.5], sortWindow=[-0.8, 0.6], signWindow=[-0.8, 0.6], sortThreshold=0.01, negativeSortThreshold=[]);
EphysUnit.plotDoubleETA(eta.lickCue, eta.reachCue, c.hasPress & c.hasLick, 'Cue (lick trials)', 'Cue (reach trials)', xlim=[-1,2], clim=[-1.5, 1.5], sortWindow=[-0.8, 0.6], signWindow=[-0.8, 0.6], sortThreshold=0.01, negativeSortThreshold=[]);



%% DO NOT SORT
close all
% EphysUnit.plotETA(eta.pressCue, c.hasPress, order=1:nnz(c.hasPress), xlim=[-1,2], clim=[-1.5, 1.5], sortWindow=[-0.8, 0.8], signWindow=[-0.8, 0.6], sortThreshold=0.3, negativeSortThreshold=0.15); title('Reach Cue ETA')
EphysUnit.plotETA(eta.press, c.hasPress & c.hasLick, order=1:nnz(c.hasPress & c.hasLick), xlim=[-4,0], clim=[-1.5, 1.5], sortWindow=[-2, 0], signWindow=[-0.5, -0.2], sortThreshold=0.01, negativeSortThreshold=[]); title('Reach ETA')
EphysUnit.plotETA(eta.lick, c.hasPress & c.hasLick, order=1:nnz(c.hasPress & c.hasLick), xlim=[-4,0], clim=[-1.5, 1.5], sortWindow=[-2, 0], signWindow=[-0.5, -0.2], sortThreshold=0.01, negativeSortThreshold=[]); title('Lick ETA')
EphysUnit.plotETA(eta.pressCue, c.hasPress & c.hasLick, order=1:nnz(c.hasPress & c.hasLick), xlim=[-1,2], clim=[-1.5, 1.5], sortWindow=[-0.8, 0.6], signWindow=[-0.8, 0.6], sortThreshold=0.01, negativeSortThreshold=[]); title('Reach Cue ETA')
EphysUnit.plotETA(eta.lickCue, c.hasPress & c.hasLick, order=1:nnz(c.hasPress & c.hasLick), xlim=[-1,2], clim=[-1.5, 1.5], sortWindow=[-0.8, 0.6], signWindow=[-0.8, 0.6], sortThreshold=0.01, negativeSortThreshold=[]); title('Lick Cue ETA')

%% Bootstrap cue response
p.bootAlpha = 0.01;
boot.pressCue = struct('h', NaN(length(eu), 1), 'muDiffCI', NaN(length(eu), 2), 'muDiffObs', NaN(length(eu), 1));
boot.lickCue = struct('h', NaN(length(eu), 1), 'muDiffCI', NaN(length(eu), 2), 'muDiffObs', NaN(length(eu), 1));
[boot.pressCue.h(c.hasPress), boot.pressCue.muDiffCI(c.hasPress, :), boot.pressCue.muDiffObs(c.hasPress)] = bootstrapCueResponse( ...
    eu(c.hasPress), 'press', alpha=p.bootAlpha, withReplacement=false, oneSided=false, ...
    baselineWindow=[-4, -2], responseWindow=[-0.8, 0]);
[boot.lickCue.h(c.hasLick), boot.lickCue.muDiffCI(c.hasLick, :), boot.lickCue.muDiffObs(c.hasLick)] = bootstrapCueResponse( ...
    eu(c.hasLick), 'lick', alpha=p.bootAlpha, withReplacement=false, oneSided=false, ...
    baselineWindow=[-4, -2], responseWindow=[-0.8, 0]);
fprintf(1, '\nAll done\n')

%% Report results
assert(nnz(isnan(boot.lickCue.h(c.hasLick))) == 0)
assert(nnz(isnan(boot.pressCue.h(c.hasPress))) == 0)

figure, histogram(boot.pressCue.h)
c.isPressCueUp = boot.pressCue.h' == 1 & c.hasPress;
c.isPressCueDown = boot.pressCue.h' == -1 & c.hasPress;
c.isPressCueResponsive = c.isPressCueUp | c.isPressCueDown;

figure, histogram(boot.lickCue.h)
c.isLickCueUp = boot.lickCue.h' == 1 & c.hasLick;
c.isLickCueDown = boot.lickCue.h' == -1 & c.hasLick;
c.isLickCueResponsive = c.isLickCueUp | c.isLickCueDown;

fprintf(1, ['%g units with %g+ press trials (%gs or longer):\n' ...
    '\t%g (%.0f%%) are cue-excited (p<%g);\n' ...
    '\t%g (%.0f%%) are cue-inhibited (p<%g).\n'], ...
    nnz(c.hasPress), p.minNumTrials, p.minTrialDuration, ...
    nnz(c.isPressCueUp), 100*nnz(c.isPressCueUp)/nnz(c.isPressCueResponsive), p.bootAlpha, ...
    nnz(c.isPressCueDown), 100*nnz(c.isPressCueDown)/nnz(c.isPressCueResponsive), p.bootAlpha);

fprintf(1, ['%g units with press&cue responses:\n' ...
    '\t%g (%.0f%%) are cue-excited & press-excited (p<%g);\n' ...
    '\t%g (%.0f%%) are cue-inhibited & press-inhibited (p<%g).\n' ...
    '\t%g (%.0f%%) are cue-excited & press-inhibited (p<%g).\n' ...
    '\t%g (%.0f%%) are cue-inhibited & press-excited (p<%g).\n'], ...
    nnz(c.hasPress & c.isPressCueResponsive & c.isPressResponsive), ...
    nnz(c.isPressCueUp & c.isPressUp), 100*nnz(c.isPressCueUp & c.isPressUp)/nnz(c.isPressCueResponsive & c.isPressResponsive), p.bootAlpha, ...
    nnz(c.isPressCueDown & c.isPressDown), 100*nnz(c.isPressCueDown & c.isPressDown)/nnz(c.isPressCueResponsive & c.isPressResponsive), p.bootAlpha, ...
    nnz(c.isPressCueUp & c.isPressDown), 100*nnz(c.isPressCueUp & c.isPressDown)/nnz(c.isPressCueResponsive & c.isPressResponsive), p.bootAlpha, ...
    nnz(c.isPressCueDown & c.isPressUp), 100*nnz(c.isPressCueDown & c.isPressUp)/nnz(c.isPressCueResponsive & c.isPressResponsive), p.bootAlpha);

fprintf(1, ['%g units with %g+ lick trials (%gs or longer):\n' ...
    '\t%g (%.0f%%) are cue-excited (p<%g);\n' ...
    '\t%g (%.0f%%) are cue-inhibited (p<%g).\n'], ...
    nnz(c.hasLick), p.minNumTrials, p.minTrialDuration, ...
    nnz(c.isLickCueUp), 100*nnz(c.isLickCueUp)/nnz(c.isLickCueResponsive), p.bootAlpha, ...
    nnz(c.isLickCueDown), 100*nnz(c.isLickCueDown)/nnz(c.isLickCueResponsive), p.bootAlpha);

fprintf(1, ['%g units with lick&cue responses:\n' ...
    '\t%g (%.0f%%) are cue-excited & lick-excited (p<%g);\n' ...
    '\t%g (%.0f%%) are cue-inhibited & lick-inhibited (p<%g).\n' ...
    '\t%g (%.0f%%) are cue-excited & lick-inhibited (p<%g).\n' ...
    '\t%g (%.0f%%) are cue-inhibited & lick-excited (p<%g).\n'], ...
    nnz(c.hasLick & c.isLickCueResponsive & c.isLickResponsive), ...
    nnz(c.isLickCueUp & c.isLickUp), 100*nnz(c.isLickCueUp & c.isLickUp)/nnz(c.isLickCueResponsive & c.isLickResponsive), p.bootAlpha, ...
    nnz(c.isLickCueDown & c.isLickDown), 100*nnz(c.isLickCueDown & c.isLickDown)/nnz(c.isLickCueResponsive & c.isLickResponsive), p.bootAlpha, ...
    nnz(c.isLickCueUp & c.isLickDown), 100*nnz(c.isLickCueUp & c.isLickDown)/nnz(c.isLickCueResponsive & c.isLickResponsive), p.bootAlpha, ...
    nnz(c.isLickCueDown & c.isLickUp), 100*nnz(c.isLickCueDown & c.isLickUp)/nnz(c.isLickCueResponsive & c.isLickResponsive), p.bootAlpha);

%% Replot (cue vs. move, only responsive ones)
close all
ax = EphysUnit.plotDoubleETA(eta.pressCue, eta.press, c.hasPress & c.isPressCueResponsive & c.isPressResponsive, 'Cue (reach trials)', 'Reach', ...
    xlim={[-1, 1], [-2, 0]}, clim=[-1.5, 1.5], sortWindow=[-0.8, 0], signWindow=[-0.8, -0], sortThreshold=0.2, negativeSortThreshold=0.1);
set(ax(1).Parent, Units='inches', Position=[0 0 4 6])
delete(ax(2).Colorbar)
ylabel(ax(2), '')


ax = EphysUnit.plotDoubleETA(eta.press, eta.pressCue, c.hasPress & c.isPressCueResponsive & c.isPressResponsive, 'Reach', 'Cue (reach trials)', ...
    xlim={[-2, 0], [-1, 1]}, clim=[-1.5, 1.5], sortWindow=[-2, 0], signWindow=[-0.5, -0.2], sortThreshold=0.5, negativeSortThreshold=0.25);
set(ax(1).Parent, Units='inches', Position=[4 0 4 6])
delete(ax(2).Colorbar)
ylabel(ax(2), '')


ax = EphysUnit.plotDoubleETA(eta.lickCue, eta.lick, c.hasLick & c.isLickCueResponsive & c.isLickResponsive, 'Cue (lick trials)', 'Lick', ...
    xlim={[-1, 1], [-2, 0]}, clim=[-1.5, 1.5], sortWindow=[-0.8, 0], signWindow=[-0.8, -0], sortThreshold=0.2, negativeSortThreshold=0.1);
set(ax(1).Parent, Units='inches', Position=[8 0 4 6])
delete(ax(2).Colorbar)
ylabel(ax(2), '')


ax = EphysUnit.plotDoubleETA(eta.lick, eta.lickCue, c.hasLick & c.isLickCueResponsive & c.isLickResponsive, 'Lick', 'Cue (lick trials)', ...
    xlim={[-2, 0], [-1, 1]}, clim=[-1.5, 1.5], sortWindow=[-2, 0], signWindow=[-0.3, -0], sortThreshold=0.5, negativeSortThreshold=0.25);
set(ax(1).Parent, Units='inches', Position=[12 0 4 6])
delete(ax(2).Colorbar)
ylabel(ax(2), '')
clear ax

%% Replot (cue vs. move, only responsive ones)
close all
COMMON_SEL = c.hasPress & c.hasLick;

ax = EphysUnit.plotDoubleETA(eta.pressCue, eta.press, COMMON_SEL, 'Cue (reach trials)', 'Reach', ...
    xlim={[-1, 1], [-2, 0]}, clim=[-1.5, 1.5], sortWindow=[-1, 0], signWindow=[-0.8, -0], sortThreshold=0.21, negativeSortThreshold=0.05);
set(ax(1).Parent, Units='inches', Position=[0 0 4 6])
delete(ax(2).Colorbar)
ylabel(ax(2), '')


ax = EphysUnit.plotDoubleETA(eta.press, eta.pressCue, COMMON_SEL, 'Reach', 'Cue (reach trials)', ...
    xlim={[-2, 0], [-1, 1]}, clim=[-1.5, 1.5], sortWindow=[-2, 0], signWindow=[-0.5, -0.2], sortThreshold=0.5, negativeSortThreshold=0.25);
set(ax(1).Parent, Units='inches', Position=[4 0 4 6])
delete(ax(2).Colorbar)
ylabel(ax(2), '')


ax = EphysUnit.plotDoubleETA(eta.lickCue, eta.lick, COMMON_SEL, 'Cue (lick trials)', 'Lick', ...
    xlim={[-1, 1], [-2, 0]}, clim=[-1.5, 1.5], sortWindow=[-1, 0], signWindow=[-0.8, -0], sortThreshold=0.1, negativeSortThreshold=0.05);
set(ax(1).Parent, Units='inches', Position=[8 0 4 6])
delete(ax(2).Colorbar)
ylabel(ax(2), '')


ax = EphysUnit.plotDoubleETA(eta.lick, eta.lickCue, COMMON_SEL, 'Lick', 'Cue (lick trials)', ...
    xlim={[-2, 0], [-1, 1]}, clim=[-1.5, 1.5], sortWindow=[-2, 0], signWindow=[-0.3, -0], sortThreshold=0.5, negativeSortThreshold=0.25);
set(ax(1).Parent, Units='inches', Position=[12 0 4 6])
delete(ax(2).Colorbar)
ylabel(ax(2), '')
clear ax COMMON_SEL

%% Get single number response estimate
clear peakResp peakRespTime
defaultArray = NaN(size(msr));
peakResp = struct('press', defaultArray, 'lick', defaultArray, 'pressCue', defaultArray, 'lickCue', defaultArray);
peakRespTime = struct('press', defaultArray, 'lick', defaultArray, 'pressCue', defaultArray, 'lickCue', defaultArray);

[peakResp.pressCue(c.hasPress), peakRespTime.pressCue(c.hasPress)] = getPeakResponse(eta.pressCueRaw, c.hasPress, window=[-0.8, 0], direction=boot.lickCue.h, scale=10, center=msr);
[peakResp.lickCue(c.hasLick), peakRespTime.lickCue(c.hasLick)] = getPeakResponse(eta.lickCueRaw, c.hasLick, window=[-0.8, 0], direction=boot.lickCue.h, scale=10, center=msr);
[peakResp.press(c.hasPress), peakRespTime.press(c.hasPress)] = getPeakResponse(eta.pressRaw, c.hasPress, window=[-0.5, -0.2], direction=boot.lickCue.h, scale=10, center=msr);
[peakResp.lick(c.hasLick), peakRespTime.lick(c.hasLick)] = getPeakResponse(eta.lickRaw, c.hasLick, window=[-0.3, 0], direction=boot.lickCue.h, scale=10, center=msr);

% Make some histograms
DATA1 = {peakResp.pressCue, peakResp.press, peakResp.lickCue, peakResp.lick};
DATA2 = {peakRespTime.pressCue, peakRespTime.press, peakRespTime.lickCue, peakRespTime.lick};
SEL = {c.isPressCueResponsive, c.isPressResponsive, c.isLickCueResponsive, c.isLickResponsive};
COMMON_SEL = c.hasPress & c.hasLick & c.isPressResponsive & c.isLickResponsive & c.isPressCueResponsive & c.isLickCueResponsive;
TITLE = {'Cue (reach trials)', 'Reach', 'Cue (lick trials)', 'Lick'};

figure(Units='inches', Position=[0 0 6 6], DefaultAxesFontSize=13)
ax = gobjects(1, 4);
for i = 1:4
    ax(i) = subplot(4, 1, i);
    histogram(ax(i), DATA1{i}(SEL{i} & COMMON_SEL), -100:5:100)
    title(ax(i), TITLE{i})
end
xlabel(ax(4), '\Deltasp/s')

figure(Units='inches', Position=[6 0 6 6], DefaultAxesFontSize=13)
ax = gobjects(1, 4);
for i = 1:4
    ax(i) = subplot(4, 1, i);
    histogram(ax(i), 1000.*DATA2{i}(SEL{i} & COMMON_SEL), -800:100:0)
    title(ax(i), TITLE{i})
end
xlabel(ax(4), 'ms')


clear i ax DATA1 DATA2 SEL TITLE

%% Do scatter plot (cue vs move)
XDATA = {peakResp.pressCue, peakResp.lickCue};
YDATA = {peakResp.press, peakResp.lick};
% SEL = {c.isPressCueResponsive & c.isPressResponsive & c.hasPress, c.isLickCueResponsive & c.isLickResponsive & c.hasLick};
SEL = {c.isPressCueResponsive & c.isPressResponsive & c.hasPress & c.hasLick, c.isLickCueResponsive & c.isLickResponsive & c.hasPress & c.hasLick};
TITLE = {'Reach', 'Lick'};

figure(Units='inches', Position=[0, 0, 8, 4], DefaultAxesFontSize=13);
for i = 1:length(XDATA)
    ax(i) = subplot(1, 2, i);
    hold(ax(i), 'on')
    lm = fitlm(XDATA{i}(SEL{i}), YDATA{i}(SEL{i}));
    scatter(ax(i), XDATA{i}(SEL{i}), YDATA{i}(SEL{i}), 5, 'black', Displayname=sprintf('N=%d', nnz(SEL{i})))
    plot(ax(i), [-100, 100], predict(lm, [-100; 100]), 'k--', DisplayName=sprintf('R^2=%g', lm.Rsquared.Ordinary))
    legend(ax(i), AutoUpdate=false, Location='southeast')
    plot(ax(i), [0, 0], [-100, 100], 'k:')
    plot(ax(i), [-100, 100], [0, 0], 'k:')
    title(ax(i), TITLE{i})
    hold(ax(i), 'off')
end
xlabel(ax, 'Cue')
ylabel(ax, 'Move')
xlim(ax, [-100, 100])
ylim(ax, [-100, 100])

% clear XDATA YDATA SEL TITLE i ax

%%
function [h, muDiffCI, muDiffObs] = bootstrapCueResponse(eu, trialType, varargin)
    p = inputParser();
    p.addRequired('eu', @(x) length(x) >= 1 && isa(x, 'EphysUnit'));
    p.addRequired('trialType', @(x) ismember(x, {'press', 'lick'}));
    p.addParameter('nboot', 10000, @isnumeric)
    p.addParameter('baselineWindow', [-4, -2], @(x) isnumeric(x) && length(x) == 2)
    p.addParameter('responseWindow', [-0.8, 0], @(x) isnumeric(x) && length(x) == 2)
    p.addParameter('alignToForBaseline', 'stop', @(x) ischar(x) && ismember(lower(x), {'start', 'stop'}))
    p.addParameter('alignToForResponse', 'start', @(x) ischar(x) && ismember(lower(x), {'start', 'stop'}))
    p.addParameter('allowedTrialDuration', [2, Inf], @(x) isnumeric(x) && length(x) >= 2 && x(2) >= x(1))
    p.addParameter('trialDurationError', 1e-3, @isnumeric) % Used for opto, error allowed when finding identical trial durations.
    p.addParameter('alpha', 0.01, @isnumeric)
    p.addParameter('withReplacement', false, @islogical)
    p.addParameter('oneSided', false, @islogical)
    p.parse(eu, trialType, varargin{:});
    r = p.Results;
    eu = r.eu;

    h = NaN(length(eu), 1);
    muDiffCI = NaN(length(eu), 2);
    muDiffObs = NaN(length(eu), 1);
    for iEu = 1:length(eu)
        fprintf(1, '%d/%d ', iEu, length(eu))
        if mod(iEu, 15) == 0
            fprintf(1, '\n')
        end

        [srResp, ~] = eu(iEu).getTrialAlignedData('count', r.responseWindow, r.trialType, alignTo=r.alignToForResponse, ...
            allowedTrialDuration=r.allowedTrialDuration, trialDurationError=r.trialDurationError, ...
            includeInvalid=false, resolution=0.1);

        [srBase, ~] = eu(iEu).getTrialAlignedData('count', r.baselineWindow, r.trialType, alignTo=r.alignToForBaseline, ...
            allowedTrialDuration=r.allowedTrialDuration, trialDurationError=r.trialDurationError, ...
            includeInvalid=true, resolution=0.1);

        if isempty(srResp) || isempty(srBase)
            warning('Spike rate for %d - %s is empty.', iEu, eu(iEu).getName('_'));
            continue
        end

        response = srResp(:);
        baseline = srBase(:);
        combined = [baseline; response];
        nBase = length(baseline);
        
        % With replacement
        if r.withReplacement
            [~, bsample] = bootstrp(r.nboot, [], combined);
        else
            bsample = zeros(length(combined), r.nboot);
            for iboot = 1:r.nboot
                bsample(:, iboot) = randperm(length(combined));
            end
        end
        baselineSamples = combined(bsample(1:nBase, :));
        responseSamples = combined(bsample(nBase+1:end, :));
        muDiffObs(iEu) = mean(response, 'omitnan') - mean(baseline, 'omitnan');
        if muDiffObs(iEu) > 0
            direction = 1;
        else
            direction = -1;
        end
        muDiffBoot = mean(responseSamples, 1, 'omitnan') - mean(baselineSamples, 1, 'omitnan');
        if r.oneSided
            if direction == 1
                muDiffCI(iEu, :) = prctile(muDiffBoot, [0, 100 - r.alpha*100]);
            elseif direction == -1
                muDiffCI(iEu, :) = prctile(muDiffBoot, [r.alpha*100, 100]);
            end
        else
            muDiffCI(iEu, :) = prctile(muDiffBoot, [r.alpha*50, 100 - r.alpha*50]);
        end
        if direction == 1
            h(iEu) = muDiffObs(iEu) > muDiffCI(iEu, 2);
        elseif direction == -1
            h(iEu) = -(muDiffObs(iEu) < muDiffCI(iEu, 1));
        end
    end
end

function [resp, tPeak] = getPeakResponse(eta, varargin)
    p = inputParser();
    p.addRequired('eta', @isstruct)
    p.addOptional('sel', [], @(x) isnumeric(x) || islogical(x))
    p.addParameter('window', [-0.8, 0], @(x) isnumeric(x) && length(x) == 2 && x(1) < x(2))
    p.addParameter('direction', 'maxabs', @(x) isnumeric(x) || ismember(x, {'maxabs', 'mean'})) % -1 or 1 (array), or 'maxabs', 'mean'
    p.addParameter('scale', 1, @isnumeric) % 1/binWidth (e.g. 10) for raw spike counts
    p.addParameter('center', 0, @isnumeric) % use baseline rate for raw spike counts
    p.parse(eta, varargin{:})
    r = p.Results;
    eta = r.eta;
    sel = r.sel;
    direction = r.direction;
    X = eta.X;
    t = eta.t;
    if ~isempty(sel)
        X = X(sel, :);
        if isnumeric(direction) && length(direction) > 1
            direction = direction(sel);
        end
        if length(r.center) > 1
            r.center = r.center(sel);
        end
    end

    X = X(:, t >= r.window(1) & t <= r.window(2));
    X = X .* r.scale - r.center(:);

    if ischar(direction)
        switch(direction)
            case 'mean'
                direction = ones(size(X, 1), 1);
                direction(mean(X, 2, 'omitnan') < 0) = -1;
            case 'maxabs'
                [~, I] = max(abs(X), [], 2, 'omitnan');
        end
    end

    if isnumeric(direction)
        direction = direction(:);
        assert(length(direction) == size(X, 1))
        [~, I] = max(X .* direction, [], 2, 'omitnan');
    end

    resp = transpose(diag(X(:, I)));
    t = t(t >= r.window(1) & t <= r.window(2));
    tPeak = t(I);
end
