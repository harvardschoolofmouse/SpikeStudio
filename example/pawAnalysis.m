%%
load('\\research.files.med.harvard.edu\neurobio\NEUROBIOLOGY SHARED\Assad Lab\Lingfeng\Data\PawAnalysis\expName.mat')
load('\\research.files.med.harvard.edu\neurobio\NEUROBIOLOGY SHARED\Assad Lab\Lingfeng\Data\PawAnalysis\frames.mat')


while ~isempty(expNames)
    if ~isempty(frames{1})
        ps = PawnalyzerSession(expNames{1}, frames{1});
        ps.save();
    end
    expNames(1) = [];
    frames(1) = [];
end
clear ps

%%

clear, clc
load('C:\SERVER\PawAnalysis\expName.mat')

frames = cell(1, length(expNames));
for iExp = 1:length(expNames)
    fprintf(1, 'Extracting frames from session %i (%s)...', iExp, expNames{iExp})
    try
        tTic = tic();
        rs = RecordingSession(expNames{iExp});
        frames{iExp} = rs.extractFrames([rs.trials('press').Stop]);
        fprintf('Done (%.1fs)\n', toc(tTic));
    catch ME
        fprintf('\n')
        warning('Error when processing session %i (%s) - this one will be skipped.', iExp, expNames{iExp})
        warning('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message)
    end
end
%%
frames = cat(4, frames{:});
implay(frames)

%% Export manually labeled data
for i = 1:pa.sessionCount
    data = pa.sessions(i).pawMask;
    data(data>2) = 0;
    fid = fopen(sprintf('%s\\%s.bin', 'C:\SERVER\PawAnalysis\Data\Predicted\resnet50_50', pa.sessions(i).expName),'w');
    fwrite(fid, data, 'uint8');
    fclose(fid);
end
clear i data fid

%% Load keras results
files = dir('C:\SERVER\PawAnalysis\Data\Predicted\resnet50_50\*.bin');
name = cell(length(files), 1);
label = name;
percentLabelled = zeros(length(files), 1);
nLabelled = percentLabelled;
nLeft = percentLabelled;
nRight = percentLabelled;
for i = 1:length(files)
    try
        n = strsplit(files(i).name, '.bin');
        name{i} = n{1};
        fid = fopen(sprintf('%s\\%s', files(i).folder, files(i).name), 'r');
        label{i} = fread(fid, 'uint8');
        fclose(fid);
        nLabelled(i) = nnz(label{i});
        nLeft(i) = nnz(label{i} == 1);
        nRight(i) = nnz(label{i} == 2);
        percentLabelled(i) = nnz(label{i})./length(label{i})*100;
    catch
        fprintf(1, 'Failed to do %s\n', files(i).name)
    end
end
tbl = table(name, label, nLabelled, nLeft, nRight, percentLabelled);

for i = 1:height(tbl)
    if nLeft(i) > 0 && nRight(i) > 0
        tbl.vs{i} = VideoSession(tbl.name{i});
    end
end

%% Implant sides
namesAndSides = { ...
    'daisy4', 'L'; ...
    'daisy5', 'R'; ...
    'daisy7', 'R'; ...
    'daisy8', 'R'; ...
    'daisy9', 'R'; ...
    'daisy10', 'L'; ...
    'daisy12', 'R'; ...
    'daisy13', 'L'; ...
    'daisy14', 'R'; ...
    'daisy15', 'R'; ...
    'daisy16', 'L'; ...
    'desmond10', 'L'; ...
    'desmond11', 'R'; ...
    'desmond12', 'L'; ...
    'desmond13', 'R'; ...
    'desmond15', 'L'; ...
    'desmond16', 'R'; ...
    'desmond17', 'R'; ...
    'desmond18', 'R'; ...
    'desmond21', 'L'; ...
    'desmond22', 'L'; ...
    'desmond24', 'R'; ...
    'desmond25', 'L'; ...
    'desmond26', 'R'; ...
    'desmond27', 'L'; ...
    };

name = namesAndSides(:, 1);
side = vertcat(namesAndSides{:, 2});
animals = table(name, side);
clear namesAndSides name side

%%
clear p
p.etaWindow = [-4, 0];
p.permTestWindow = [-1, 0];
p.minTrialDuration = 1;
p.baselineWindow = [-4, -2];

close all
clear fig
nTotal = 0;
nDifferent = 0;
for i = 1:height(tbl)
    if tbl.nLeft(i) > 5 && tbl.nRight(i) > 5
        fprintf('\n %i:\n', i)
        for iEu = 1:length(tbl.vs{i}.eu)
            nTotal = nTotal + 1;
            fprintf('\t%i ', iEu)
            eu = tbl.vs{i}.eu(iEu);
            side = animals.side(strcmpi(animals.name, eu.getAnimalName()));
            switch side
                case 'L'
                    side = 'Left';
                    trialsContra = eu.Trials.Press(tbl.label{i}==2);
                    trialsIpsi = eu.Trials.Press(tbl.label{i}==1);
                case 'R'
                    side = 'Right';
                    trialsContra = eu.Trials.Press(tbl.label{i}==1);
                    trialsIpsi = eu.Trials.Press(tbl.label{i}==2);
            end
            titleText = sprintf('%s (%s implant)', eu.getName(), side);

            % Perm test to determine if ETA traces are significantly different
            clear pt baseline
            [pt.h, pt.p, pt.ci, pt.obs, baseline(1), baseline(2)] = permTestETADistance(eu, trialsContra, trialsIpsi, 100000, 0.01, ...
                p.permTestWindow, p.minTrialDuration, p.baselineWindow);
            if pt.h
                titleText = sprintf('%s (**, p < %.5f)', titleText, pt.p);
            else
                titleText = sprintf('%s (p < %.5f)', titleText, pt.p);
            end

            if pt.h
                nDifferent = nDifferent + 1;
                fig(nTotal) = figure(Units='normalized', Position=[0 0.2 0.5 0.6], DefaultAxesFontSize=11);
            else
                fig(nTotal) = figure(Units='normalized', Position=[0.5 0.2 0.5 0.6], DefaultAxesFontSize=11);
            end
            plotDoubleRasterAndETA(fig(nTotal), eu, {trialsContra, trialsIpsi}, {'Contra', 'Ipsi'}, ...
                baseline=baseline, title=titleText, window=p.etaWindow, minTrialDuration=p.minTrialDuration);
            if pt.h
                print(fig(nTotal), sprintf('C:\\SERVER\\Figures\\Left_vs_Right\\Different\\%s (%s implant)', eu.getName(), side), '-dpng')
            else
                print(fig(nTotal), sprintf('C:\\SERVER\\Figures\\Left_vs_Right\\Same\\%s (%s implant)', eu.getName(), side), '-dpng')
            end
        end
    end
end

fprintf('\n%i / %i (%.2f%%) of total units are different (p < 0.01). \n', nDifferent, nTotal, nDifferent/nTotal*100)

% clear ax i iEu eu label trialsLeft trialsRight etaLeft etaRight

function [fig, ax] = plotDoubleRasterAndETA(varargin)
    p = inputParser();
    if isgraphics(varargin{1}, 'Figure')
        p.addRequired('fig')
    end
    p.addRequired('eu', @(x) isa(x, 'EphysUnit'))
    p.addRequired('trials', @(x) iscell(x) && length(x) == 2)
    p.addRequired('labels', @(x) iscell(x) && length(x) == 2)
    p.addParameter('baseline', [0, 0], @(x) isnumeric(x) && length(x) == 2)
    p.addParameter('title', @ischar)
    p.addParameter('window', [-4, 0], @(x) isnumeric(x) && length(x) == 2 && x(2) > x(1));
    p.addParameter('minTrialDuration', 2, @isnumeric)
    p.addParameter('iti', false, @islogical);
    p.parse(varargin{:});
    r = p.Results;
    eu = r.eu;
    trials = r.trials;
    labels = r.labels;
    if ~isfield(r, 'fig')
        fig = figure(Units='normalized', Position=[0, 0, 1, 1], DefaultAxesFontSize=12);
    else
        fig = r.fig;
    end

    figPos = fig.Position;
    eta = cell(1, 2);
    rd = cell(1, 2);
    nTrials = zeros(1, 2);
    for i = 1:2
        trials{i} = trials{i}(trials{i}.duration() >= r.minTrialDuration);
        eta{i} = eu.getETA('count', 'press', r.window, trials=trials{i}, normalize='none');
        rd{i} = eu.getRasterData('press', window=r.window, sort=true, alignTo='stop', trials=trials{i});
        nTrials(i) = length(trials{i});
    end

    % Figure layout
    xmargin = 0.16;
    ymargin = 0.09;
    h(1) = nTrials(1)/sum(nTrials)*(0.67-ymargin*3);
    h(2) = nTrials(2)/sum(nTrials)*(0.67-ymargin*3);
    h(3) = 0.33-ymargin;
    ax(1) = axes(fig, Units='normalized', Position=[xmargin, 3*ymargin+h(2)+h(3), 0.7, h(1)]);
    ax(2) = axes(fig, Units='normalized', Position=[xmargin, 2*ymargin+h(3), 0.7, h(2)]);
    ax(3) = axes(fig, Units='normalized', Position=[xmargin, ymargin, 0.7, h(3)]);

    % Plot 3 subplots
    for i = 1:2
        EphysUnit.plotRaster(ax(i), rd{i}, xlim=r.window, iti=r.iti, timeUnit='s');
        title(ax(i), sprintf('Raster (%s)', labels{i}))
    end

    hold(ax(3), 'on')
    colors = {'r', 'b'};
    for i = 1:2
        plot(ax(3), eta{i}.t, (eta{i}.X - r.baseline(i))*10, LineWidth=2, Color=colors{i}, DisplayName=sprintf('%s (N=%i)', labels{i}, nTrials(i)))
    end
    hold(ax(3), 'off')
    legend(ax(3), Location='northwest')
    title('PETH')
    xlabel(ax(1:2), '')
    xlabel(ax(3), 'Time to contact (s)')
    ylabel(ax(3), '\DeltaFR (sp/s)')
    fig.Position = figPos;

    suptitle(r.title)

    set(ax, FontSize=11)
end


function [h, p, ci, obs, baselineLeft, baselineRight] = permTestETADistance(eu, trialsLeft, trialsRight, nPerm, alpha, window, minTrialDuration, baselineWindow)
    [xLeft, ~] = eu.getTrialAlignedData('count', window, 'press', trials=trialsLeft, allowedTrialDuration=[minTrialDuration, Inf], align='stop', resolution=0.1, includeInvalid=false);
    [xRight, ~] = eu.getTrialAlignedData('count', window, 'press', trials=trialsRight, allowedTrialDuration=[minTrialDuration, Inf], align='stop', resolution=0.1, includeInvalid=false);
    
    [xLeftBaseline, ~] = eu.getTrialAlignedData('count', baselineWindow, 'press', trials=trialsLeft, allowedTrialDuration=[minTrialDuration, Inf], align='stop', resolution=0.1, includeInvalid=false);
    [xRightBaseline, ~] = eu.getTrialAlignedData('count', baselineWindow, 'press', trials=trialsRight, allowedTrialDuration=[minTrialDuration, Inf], align='stop', resolution=0.1, includeInvalid=false);
    
    % Substract baseline firing rate to account for drift
    baselineLeft = mean(xLeftBaseline, 'all', 'omitnan');
    baselineRight = mean(xRightBaseline, 'all', 'omitnan');
    xLeft = xLeft - baselineLeft;
    xRight = xRight - baselineRight;

    xAll = vertcat(xLeft, xRight);
    nLeft = height(xLeft);
    nRight = height(xRight);
    nAll = nLeft + nRight;

    permDist = NaN(nPerm, 1);
    for iPerm = 1:nPerm
        permSample = randperm(nAll);
        xPermLeft = mean(xAll(permSample(1:nLeft), :), 1, 'omitnan');
        xPermRight = mean(xAll(permSample(nLeft + 1:end), :), 1, 'omitnan');
        permDist(iPerm) = mean((xPermLeft - xPermRight).^2, 'omitnan');
    end
    ci = prctile(permDist, 100*(1 - alpha));
    obs = mean((mean(xLeft, 1, 'omitnan') - mean(xRight, 1, 'omitnan')).^2, 'omitnan');
    h = obs > ci;
    ci = [0, ci];

    nGreater = nnz(permDist > obs);
    nEqual = nnz(permDist == obs);
    p = (nGreater + 0.5.*nEqual) / nPerm;
end
