%% Load
% clear
% Load data if necessary
if ~exist('exp_D1', 'var')
    exp_D1.ar = AcuteRecording.load('C:\SERVER\Experiment_Galvo_D1Cre;DlxFlp;Ai80\AcuteRecording');
end
if ~exist('exp_A2A', 'var')
    exp_A2A.ar = AcuteRecording.load('C:\SERVER\Experiment_Galvo_A2ACre\AcuteRecording');
end

%% Plot basic stim response save to disk
cd('C:\SERVER\Figures\Acute\A2A\');
exp_A2A.ar.plotStimResponse([0.4 0.5 2], [0.01 0.05], {'line', 'heatmap'}, 'HeatmapCLim', [-1, 1], 'Print', true);
cd('C:\SERVER\Figures\Acute\D1\');
exp_D1.ar.plotStimResponse([0.4 0.5 2], [0.01 0.05], {'line', 'heatmap'}, 'HeatmapCLim', [-1, 1], 'Print', true);

%% Plot basic stim response save to disk
cd('C:\SERVER\Figures\Acute\A2A\');
exp_A2A.ar.plotStimResponse([0.4 0.5 2], [0.01 0.05], {'heatmap'}, HeatmapCLim=[-1, 1], Print=false, Position=[0 0 0.75 0.5]);
cd('C:\SERVER\Figures\Acute\D1\');
exp_D1.ar.plotStimResponse([0.4 0.5 2], [0.01 0.05], {'heatmap'}, HeatmapCLim=[-1, 1], Print=false, Position=[0 0 0.75 0.5]);

%% Find 2 example units to plot
clear selUnit
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

%% Extract data
[exp_D1.sr, ~, exp_D1.groups] = exp_D1.ar.getStimResponse([0.4 0.5], 0.01);
exp_D1.pr = exp_D1.ar.getMoveResponse('Press');
exp_D1.lr = exp_D1.ar.getMoveResponse('Lick');
exp_D1.pos = exp_D1.ar.getProbeCoords();

[exp_A2A.sr, ~, exp_A2A.groups] = exp_A2A.ar.getStimResponse([0.4 0.5], 0.01);
exp_A2A.pr = exp_A2A.ar.getMoveResponse('Press');
exp_A2A.lr = exp_A2A.ar.getMoveResponse('Lick');
exp_A2A.pos = exp_A2A.ar.getProbeCoords();

ar = [exp_A2A.ar, exp_D1.ar];
[~, ax(1)] = ar.plotPressVsLickResponse('Hue', 'ml', 'PressThreshold', 0.67, 'LickThreshold', 0.67);
[~, ax(2)] = ar.plotPressVsLickResponse('Hue', 'dv', 'PressThreshold', 0.67, 'LickThreshold', 0.67);
AcuteRecording.unifyAxesLims(ax)
AcuteRecording.drawLines(ax, true, true)
clear ar ax

%%
sel = max(abs(stimResp), [], 2, 'omitnan') > 0.5;
stimResp = stimResp(sel, :);
coords = coords(sel, :);
normStimResp = stimResp ./ max(abs(stimResp), [], 2, 'omitnan');

bar(mean(stimResp, 'omitnan'));
hold on
errorbar(1:8, mean(stimResp, 'omitnan'), std(stimResp, 'omitnan'))
xticks(1:8)
xticklabels({stimGroups.label})

strCoords = [1.3, -4.15; 1.3, -3.48; 1.3, -2.81; 1.3, -2.15; 3.4, -4.15; 3.4, -3.48; 3.4, -2.81; 3.4, -2.15];

[dr, d] = rfscore(normStimResp, strCoords);

%%
chunkSize = 10;
for i = 1:chunkSize:length(normStimResp)
    figure()
    plot(normStimResp(i:min(i+chunkSize-1, length(normStimResp)), :)');
end

%%
data = [0 0 0 0 0 0 0 0;
    0 0 0 0 2 2 2 2;
    0 0 0 0 0 2 0 0;
    0 0 2 0 0 0 0 0;
    0 2 0 0 0 0 0 0;];
pos = (1:8)';

[score, deltaR, dist] = rfscore(data, pos);

tbl = table(data, deltaR, deltaR./dist, score);

%%
function [score, deltaR, dist] = rfscore(data, pos)
    p = 0;
    for i = 1:size(data, 2)-1
        for j = i+1:size(data, 2)
            p = p + 1;
            dist(p) = sqrt(sum((pos(j, :) - pos(i, :)).^2));
            deltaR(:, p) = abs(data(:, j) - data(:, i));
        end
    end
    score = sum(deltaR ./ dist, 2, 'omitnan');
end