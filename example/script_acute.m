%% Define animal/expname
fdir = uigetdir('C:\SERVER\');
assert(ischar(fdir) && isfolder(fdir), 'No directory selected.')
expName = strsplit(fdir, '\');
expName = expName{end};
animalName = strsplit(expName, '_');
animalName = animalName{1};

%% Read auto-sorted(crude) intan data and combine with analog data from blackrock
br = readBlackRock(fdir);
tr = readIntan(fdir);
appendBRtoTR(br, tr);

tr.SpikeClusterAutoReorder([], 'range')
tr.PlotAllChannels('plotMethod', 'mean')

%% Do manual spike sorting
tr.PlotChannel([], 'Reference', 'CueOn', 'Event', 'PressOn', 'Exclude', 'LickOn', 'Event2', '', 'Exclude2', '', 'RasterXLim', [-6, 1], 'ExtendedWindow', [-1, 1], 'PlotStim', true);

%% Save manually sorted units
TetrodeRecording.BatchSave(tr, 'Prefix', 'tr_sorted_', 'DiscardData', false);

%% Load manually sorted results
f = dir(sprintf('C:\\SERVER\\%s\\%s\\SpikeSort\\tr_sorted_%s*.mat', animalName, expName, expName));
load(sprintf('%s\\%s', f.folder, f.name));
clear f

%% Extract stim response and save to file
clear ar bsr probeMap stim sessionInfo
sessionInfo.expName = expName;
sessionInfo.strain = 'A2A-Cre'; % A2A-Cre or D1-Cre;Dlx-Flp;Ai80
sessionInfo.orientation = 'front'; % Whether probe is anterior (front) or posterior (back) to the headstage. Usually this is back, unless recording in anterior SNr.
sessionInfo.ml = -1300; % Center of probe. Negative for left hemisphere.
sessionInfo.dv = -4600; % From surface of brain, not bregma. Assumes Bregma is 200um above brain surface unless otherwise specified for `importProbeMap`.
sessionInfo.ap = -3280+350;
sessionInfo.firstFiber = 'B'; % 'A' or 'B', name of the first patch cable
sessionInfo.firstLight = 0.1; % 

window = [0 0.05];

ar = AcuteRecording(tr, sessionInfo.strain);
stim = ar.extractAllPulses(tr, sessionInfo.firstFiber, sessionInfo.firstLight);
probeMap = ar.importProbeMap(sessionInfo.orientation, sessionInfo.ml, sessionInfo.dv, sessionInfo.ap);
ar.binStimResponse(tr, [], 'Store', true);
ar.summarize(ar.bsr, 'peak', [0, 0.05], 'Store', true);

ar.save();
save(sprintf('C:\\SERVER\\%s\\%s\\AcuteRecording\\sessionInfo_%s.mat', animalName, expName, expName), 'sessionInfo');


%% Load AR file (much faster than loading TR and rebuilding AR)
ar = AcuteRecording.load(sprintf('C:\\SERVER\\%s\\%s\\AcuteRecording\\ar_%s.mat', animalName, expName, expName));

%% One SNr map per Str site (1 figure)
ar = exp_A2A.ar(1);
window = [0, 0.05];
[bsr, ~] = ar.selectStimResponse('Light', 0.5, 'Duration', 0.01);
[statsPeak, conditions] = ar.summarize(bsr, 'peak', window);
statsFirstPeak = ar.summarize(bsr, 'firstPeak', window, 0.25);
statsMean = ar.summarize(bsr, 'mean', window, 0.25);

% Plot and compare mean vs peak response. Check that mean and peak has same sign.
nConditions = length(conditions);
figure;
for i = 1:nConditions
    ax = subplot(nConditions, 1, i);
    hold(ax, 'on')
    plot(ax, statsPeak(:, i), 'DisplayName', sprintf('peak %i-%ims', window(1)*1000, window(2)*1000));
    plot(ax, statsFirstPeak(:, i), 'DisplayName', sprintf('first Peak %i-%ims', window(1)*1000, window(2)*1000));
    plot(ax, statsMean(:, i), 'DisplayName', sprintf('mean %i-%ims', window(1)*1000, window(2)*1000));
    ylabel(ax, '\DeltaActivity')
    xlabel(ax, 'Unit')
    title(ax, conditions(i).label)
    hold(ax, 'off');
    legend(ax);
end
clear ax i nConditions statsPeak statsFirstPeak statsMean

% Plot probe map per stim condition
ar.plotStimResponseMap(bsr, [0.25, 3], 0.25, 'peak', window, 0.25);

%% One Str map per SNr unit (WARNING: MANY FIGURES)
ar.plotStimResponse(bsr, 'CLim', [-.5, .5]);


%% Read multiple files, pool stats and plot in same map.
plotD1(-3280)
% plotD1(-3280+350) 
% plotD1([])
% 
plotA2A(-3280)
% plotA2A([])

%% Analyze movement responses 
% (Step 1. Load Data)
if ~exist('ar', 'var') || ~strcmpi(ar.expName, expName)
    ar = AcuteRecording.load(sprintf('C:\\SERVER\\%s\\%s\\AcuteRecording\\ar_%s.mat', animalName, expName, expName));
end

if ~exist('tr', 'var') || ~contains(lower(tr.GetExpName()), lower(expName))
    f = dir(sprintf('C:\\SERVER\\%s\\%s\\SpikeSort\\tr_sorted_%s*.mat', animalName, expName, expName));
    load(sprintf('%s\\%s', f.folder, f.name));
    clear f
end

% Analyze movement responses (Step 2. Summarize)
[bmrPress, ~, ~] = ar.binMoveResponse(tr, 'Press', 'Window', [-6, 1], 'BaselineWindow', [-6, -2], 'Store', true);
[bmrLick, ~, ~] = ar.binMoveResponse(tr, 'Lick', 'Window', [-6, 1], 'BaselineWindow', [-6, -2], 'Store', true);
statsPress = ar.summarizeMoveResponse('Press', 'peak', [-1, 0], 'AllowedTrialLength', [2, Inf], 'Store', true);
statsLick = ar.summarizeMoveResponse('Lick', 'peak', [-1, 0], 'AllowedTrialLength', [2, Inf], 'Store', true);

%% Batch process movement responses, append to AR and save to disk
% (Step 1. Load Data)
ar = AcuteRecording.load();

for i = 1:length(ar)
    % Load related TetrodeRecording file.
    expName = ar(i).expName;
    animalName = strsplit(expName, '_');
    animalName = animalName{1};
    f = dir(sprintf('C:\\SERVER\\%s\\%s\\SpikeSort\\tr_sorted_%s*.mat', animalName, expName, expName));
    assert(length(f) == 1)
    S = load(sprintf('%s\\%s', f.folder, f.name));
    tr = S.tr;

    % Analyze movement responses (Step 2. Summarize)
    ar(i).binMoveResponse(tr, 'Press', 'Window', [-6, 1], 'BaselineWindow', [-6, -2], 'Store', true);
    ar(i).binMoveResponse(tr, 'Lick', 'Window', [-6, 1], 'BaselineWindow', [-6, -2], 'Store', true);
    ar(i).summarizeMoveResponse('Press', 'peak', [-1, 0], 'AllowedTrialLength', [2, Inf], 'Store', true);
    ar(i).summarizeMoveResponse('Lick', 'peak', [-1, 0], 'AllowedTrialLength', [2, Inf], 'Store', true);

    clear tr

    if strcmpi(ar(i).strain, 'A2A-Cre')
        path = 'C:\SERVER\Experiment_Galvo_A2ACre';
    elseif strcmpi(ar(i).strain, 'D1-Cre;Dlx-Flp;Ai80')
        path = 'C:\SERVER\Experiment_Galvo_D1Cre;DlxFlp;Ai80';
    else
        error('Unrecognized strain %s', ar(i).strain);
    end
    ar(i).save('ar_', path);
end

clear i expName animalName f S


%% Load
close all
% Load data if necessary
if ~exist('exp_D1', 'var')
    exp_D1 = readdir('C:\SERVER\Experiment_Galvo_D1Cre;DlxFlp;Ai80\AcuteRecording', 'D1');
end
if ~exist('exp_A2A', 'var')
    exp_A2A = readdir('C:\SERVER\Experiment_Galvo_A2ACre\AcuteRecording', 'A2A');
end

%%
close all
clear fig ax
fig(1) = figure('Units', 'Normalized', 'Position', [0, 0, 0.5, 0.5]);
for i = 1:8
    figure(fig(1));
    ax(i) = subplot(4, 2, i, 'Tag', 'scatter');
end
fig(2) = figure('Units', 'Normalized', 'Position', [0, 0, 0.5, 0.5]);
for i = 9:16
    figure(fig(2));
    ax(i) = subplot(4, 2, i - 8, 'Tag', 'scatter');
end
plotMoveVsStim(ax(1:2), exp_A2A, 1, 0.5, [0.05, 0.1], 0.01);
plotMoveVsStim(ax(3:4), exp_A2A, 1, 0.5, [0.4, 0.5], 0.01);  
plotMoveVsStim(ax(5:6), exp_A2A, 1, 0.5, 2, 0.01);
plotMoveVsStim(ax(7:8), exp_A2A, 1, 0.5, 8, 0.01);
plotMoveVsStim(ax(9:10), exp_D1, 1, 0.5, [0.05, 0.1], 0.01);
plotMoveVsStim(ax(11:12), exp_D1, 1, 0.5, [0.4, 0.5], 0.01);
plotMoveVsStim(ax(13:14), exp_D1, 1, 0.5, 2, 0.01);
plotMoveVsStim(ax(15:16), exp_D1, 1, 0.5, 8, 0.01);

AcuteRecording.unifyAxesLims(ax(1:8))
AcuteRecording.unifyAxesLims(ax(9:16))
AcuteRecording.drawLines(ax(1:8), true, true)
AcuteRecording.drawLines(ax(9:16), true, true)

%% Compare 0.5mW to 2mW, plot in same figure, different colors
close all
clear ax fig

lights = {[0.4, 0.5], 2};
duration = 0.01;

[~, ax{1}] = exp_D1.ar.plotStimResponseVsLight(lights, duration);
[~, ax{2}] = exp_A2A.ar.plotStimResponseVsLight(lights, duration);

figure();
ax{3}(1) = subplot(1, 2, 1);
ax{3}(2) = subplot(1, 2, 2);
exp_D1.ar.plotStimResponseVsLight(ax{3}(1), lights, duration, 'MergeGroups', 'max');
exp_A2A.ar.plotStimResponseVsLight(ax{3}(2), lights, duration, 'MergeGroups', 'max');

AcuteRecording.unifyAxesLims(ax{1});
AcuteRecording.unifyAxesLims(ax{2});
AcuteRecording.drawLines(ax{1}, true, true)
AcuteRecording.drawLines(ax{2}, true, true)
AcuteRecording.unifyAxesLims(ax{3});
AcuteRecording.drawLines(ax{3}(1), true, true)
AcuteRecording.drawLines(ax{3}(2), true, true)

clear ax fig

%% Read multiple files, pool stats and plot in same map.
close all
plotD1(-3280)
plotA2A(-3280)
% plotD1(-3280+350) 
% plotD1([])
% plotA2A([])

%% Plot latencies by location

%% TCA
close all
clear figs_D1 figs_A2A
w = 1/3; h = 0.95/2;
iters = 9; figs_D1 = gobjects(1, iters); figs_A2A = gobjects(1, iters);
for iter = 1:9
    figs_D1(iter) = figure('Units', 'normalized', 'OuterPosition', [w*(iter-1), h+0.05, w, h]);
    figs_A2A(iter) = figure('Units', 'normalized', 'OuterPosition', [w*(iter-1), 0.05, w, h]);
end
plotTCA(figs_D1, exp_D1.ar([1 2 4 6 7]), 0.5, [0 0.2]);
plotTCA(figs_A2A, exp_A2A.ar, 0.5, [0 0.2]);
%%

function [data, sel, model] = plotTCA(figs, ars, theta, window)
    for iExp = 1:length(ars)
        ar = ars(iExp);
        % [bsr, ~] = ar.selectStimResponse('Light', 0.5, 'Duration', 0.01);
    
        [~, I] = ar.selectStimResponse('Light', [0.4, 0.5], 'Duration', 0.01);
        groups = ar.groupByStimCondition(I, {'light', 'duration', 'ml', 'dv'}); 
        stats{iExp} = ar.summarizeStimResponse(groups, 'none');
    end
    data = cat(1, stats{:});
    t = ars(1).bsr(1).t;
    sel = max(max(abs(data(:, t > window(1) & t < window(2), :)), [], 2), [], 3) > theta;
    R = 8;
    for iter = 1:length(figs)
        model = cp_als(tensor(data(sel, :, :)), R);
        viz_ktensor(model, ...
            'Figure', figs(iter), ...
            'Plottype', {'bar', 'line', 'bar'}, ...
            'Modetitles', {'neurons', 'time', 'striatum site'});
    end
end

function m = max2(x)
    [~, I] = max(abs(x), [], 2);
    m = diag(x(:, I));
end
            
function plotMoveVsStim(ax, exp, moveThreshold, stimThreshold, critLight, critDuration)
    % Visualize movement response data
    exp.ar.plotStimVsMoveResponse(ax(1), 'Press', 'Light', critLight, 'Duration', critDuration, 'StimThreshold', stimThreshold, 'MoveThreshold', moveThreshold, 'Highlight', 'stim', 'MergeGroups', 'max', 'Hue', 'ml');
    exp.ar.plotStimVsMoveResponse(ax(2), 'Lick', 'Light', critLight, 'Duration', critDuration, 'StimThreshold', stimThreshold, 'MoveThreshold', moveThreshold, 'Highlight', 'stim', 'MergeGroups', 'max', 'Hue', 'ml');
end



%% 
function exp = readdir(fdir, label)
    exp.fdir = fdir;
    exp.ar = AcuteRecording.load(fdir);
    exp.sessionInfo = readSessionInfo(fdir);
    exp.crit = inferCriteria(exp.ar, [0.5, 0.4], 0.01);
    exp.label = label;
end

function sessionInfo = readSessionInfo(fdir)
    fileinfo = dir(sprintf('%s\\sessionInfo_*.mat', fdir));
    for i = 1:length(fileinfo)
        S(i) = load(sprintf('%s\\%s', fileinfo(i).folder, fileinfo(i).name), 'sessionInfo');
    end
    sessionInfo = [S.sessionInfo];
end

function crit = inferCriteria(ar, varargin)
    p = inputParser();
    p.addRequired('AcuteRecording', @(x) isa(x, 'AcuteRecording'));
    p.addOptional('Light', [0.5, 0.4], @isnumeric);
    p.addOptional('Duration', 0.01, @(x) isnumeric(x) && length(x) == 1);
    p.parse(ar, varargin{:});
    ar = p.Results.AcuteRecording;

    crit(length(ar)) = struct('light', [], 'duration', []);
    for i = 1:length(ar)
        critFound = false;
        for light = p.Results.Light(:)'
            if any([ar(i).conditions.light] == light & [ar(i).conditions.duration] == p.Results.Duration)
                crit(i).light = light;
                critFound = true;
                break
            end
        end
        crit(i).duration = p.Results.Duration;
        assert(critFound, 'Criteria (Light=%s, Duration=%s) not matched for experiment %i: %s.', num2str(p.Results.Light), num2str(p.Results.Duration), i, ar(i).expName)
    end
end

%%
function plotD1(ap, useSignedML)
    if nargin < 1
        ap = [];
    end
    if nargin < 3
        useSignedML = false;
    end

    window = [0, 0.05];

    fdir = 'C:\SERVER\Experiment_Galvo_D1Cre;DlxFlp;Ai80\AcuteRecording';
    ar = AcuteRecording.load(fdir);
    sessionInfo = readSessionInfo(fdir);
    crit = inferCriteria(ar);
    assert(all(strcmp({ar.expName}, {sessionInfo.expName})))
    
    if ~isempty(ap)
        sel = [sessionInfo.ap] == ap;
        ar = ar(sel);
        crit = crit(sel);
        sessionInfo = sessionInfo(sel);
    end

    for i = 1:length(ar)
        % ar(i).importProbeMap(sessionInfo(i).orientation, sessionInfo(i).ml, sessionInfo(i).dv, sessionInfo(i).ap);
        bsr{i} = ar(i).selectStimResponse('Light', crit(i).light, 'Duration', crit(i).duration);
        [stats{i}, conditions{i}] = ar(i).summarize(bsr{i}, 'peak', window);
        % ar(i).plotStimResponseMap(bsr{i}, [0.25, 1], 0.25, 'peak', window, 0.25, 'UseSignedML', useSignedML);
        % print(sprintf('%s (%.2f AP).png', ar(i).getLabel, ap/1000), '-dpng');
    end
    ar.plotStimResponseMap(bsr, [0.25, 1], 0.25, 'peak', window, 0.25, 'HideFlatUnits', true, 'UseSignedML', useSignedML);
    print(sprintf('%s (%.2f AP).png', ar.getLabel, ap/1000), '-dpng');
end

function plotA2A(ap, useSignedML)
    if nargin < 1
        ap = [];
    end
    if nargin < 3
        useSignedML = false;
    end

    window = [0, 0.05];

    fdir = 'C:\SERVER\Experiment_Galvo_A2ACre\AcuteRecording';
    ar = AcuteRecording.load(fdir);
    sessionInfo = readSessionInfo(fdir);
    crit = inferCriteria(ar);
    assert(all(strcmp({ar.expName}, {sessionInfo.expName})))
    
    if ~isempty(ap)
        sel = [sessionInfo.ap] == ap;
        ar = ar(sel);
        crit = crit(sel);
        sessionInfo = sessionInfo(sel);
    end

    for i = 1:length(ar)
        % ar(i).importProbeMap(sessionInfo(i).orientation, sessionInfo(i).ml, sessionInfo(i).dv, sessionInfo(i).ap);
        bsr{i} = ar(i).selectStimResponse('Light', crit(i).light, 'Duration', crit(i).duration);
        [stats{i}, conditions{i}] = ar(i).summarize(bsr{i}, 'peak', window);
%         ar(i).plotStimResponseMap(bsr{i}, [0.25, 1], 0.25, 'peak', window, 0.25, 'UseSignedML', useSignedML);
%         print(sprintf('%s (%.2f AP).png', ar(i).getLabel, ap/1000), '-dpng');
    end
    ar.plotStimResponseMap(bsr, [0.25, 1], 0.25, 'peak', window, 0.25, 'HideFlatUnits', true, 'UseSignedML', useSignedML);
%     print(sprintf('%s (%.2f AP).png', ar.getLabel, ap/1000), '-dpng');
end

function tr = readIntan(fdir)
    if nargin < 1
        fdir = uigetdir('C:\SERVER\');
    end
    expName = strsplit(fdir, '\');
    expName = expName{end};
    tr = TetrodeRecording.BatchLoadSimple(expName, true);
end

function br = readBlackRock(fdir)
    if nargin < 1
        fdir = uigetdir('C:\SERVER\');
    end

    % Read BlackRock files
    nsx = dir(sprintf('%s\\*.ns?', fdir));
    nev = dir(sprintf('%s\\*.nev', fdir));
    nsx = openNSx(sprintf('%s\\%s', nsx.folder, nsx.name));
    nev = openNEV(sprintf('%s\\%s', nev.folder, nev.name), 'nosave', 'nomat');

    % Parse digital data
    digitalChannels = {'Laser', 0; 'Galvo', 1};
    digitalData = flip(dec2bin(nev.Data.SerialDigitalIO.UnparsedData), 2);
    digitalTimestamps = nev.Data.SerialDigitalIO.TimeStampSec;
    digitalSampleIndices = nev.Data.SerialDigitalIO.TimeStamp;
    digitalSamplingRate = nev.MetaTags.TimeRes;
    digitalStartDateTime = nev.MetaTags.DateTimeRaw;


    for iChannel = 1:size(digitalChannels, 1)
        iBit = digitalChannels{iChannel, 2} + 1;
        channelName = digitalChannels{iChannel, 1};
        [digitalEvents.([channelName, 'On']), digitalEvents.([channelName, 'Off'])] = TetrodeRecording.FindEdges(transpose(digitalData(:, iBit)), digitalTimestamps);
    end
    clear iBit channelName

    % Parse analog data
    analogChannels = {'Laser', 1; 'Galvo', 2};
    analogConversionFactor = double([nsx.ElectrodesInfo.MaxAnalogValue])./double([nsx.ElectrodesInfo.MaxDigiValue]);
    analogData = double(nsx.Data) .* analogConversionFactor';
    analogSamplingRate = nsx.MetaTags.SamplingFreq;
    analogTimestamps = (0:nsx.MetaTags.DataPoints - 1) / analogSamplingRate;
    
    br.digitalEvents = digitalEvents;
    br.digitalChannels = digitalChannels;
    br.analogData = analogData;
    br.analogChannels = analogChannels;
    br.analogTimestamps = analogTimestamps;
end

% Append blackrock/galvo digital events to TR object (intan recording),
% align to intan file timestamps.
function appendBRtoTR(br, tr)
    brTimeOffset = tr.DigitalEvents.StimOn - br.digitalEvents.LaserOn;
    tr.DigitalEvents.LaserOn = br.digitalEvents.LaserOn + brTimeOffset;
    tr.DigitalEvents.LaserOff = br.digitalEvents.LaserOff + brTimeOffset;
    tr.DigitalEvents.GalvoOn = br.digitalEvents.GalvoOn + interp1(br.digitalEvents.LaserOn, brTimeOffset, br.digitalEvents.GalvoOn, 'linear', 'extrap');
    tr.DigitalEvents.GalvoOff = br.digitalEvents.GalvoOff + interp1(br.digitalEvents.LaserOn, brTimeOffset, br.digitalEvents.GalvoOff, 'linear', 'extrap');
    tr.AnalogIn.Channels = br.analogChannels;
    tr.AnalogIn.Timestamps = br.analogTimestamps + interp1(br.digitalEvents.LaserOn, brTimeOffset, br.analogTimestamps, 'linear', 'extrap');
    tr.AnalogIn.Data = br.analogData;
end