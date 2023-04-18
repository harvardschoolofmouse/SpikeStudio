
%% Cull AR duplicate/multiunits from AR. Use eu as reference
ar = AcuteRecording.load();
SEL = cell(1, length(ar));
for iAr = 1:length(ar)
    bsr = ar(iAr).bsr;
    found = false(1, length(bsr));
    for iBsr = 1:length(bsr)
        expName = bsr(iBsr).expName;
        channel = bsr(iBsr).channel;
        unit = bsr(iBsr).unit;
        found(iBsr) = any(strcmpi(expName, {eu.ExpName}) & [eu.Channel] == channel & [eu.Unit] == unit);
    end
    ar(iAr).bsr = bsr(found);
    ar(iAr).bmrPress = ar(iAr).bmrPress(found);
    ar(iAr).bmrLick = ar(iAr).bmrLick(found);
    ar(iAr).stats = ar(iAr).stats(found, :);
    ar(iAr).statsPress = ar(iAr).statsPress(found, :);
    ar(iAr).statsLick = ar(iAr).statsLick(found, :);
    SEL{iAr} = found;
end
clear found


%% Load
clear
% Load data if necessary
if ~exist('exp_D1', 'var')
    exp_D1.ar = AcuteRecording.load('C:\SERVER\Experiment_Galvo_D1Cre;DlxFlp;Ai80\AcuteRecording');
end
if ~exist('exp_A2A', 'var')
    exp_A2A.ar = AcuteRecording.load('C:\SERVER\Experiment_Galvo_A2ACre\AcuteRecording');
end

%% Plot move vs stim, color by ml
clear ax
close all
[~, ax{1}] = exp_D1.ar.plotStimVsMoveResponse('Lick', 'Light', [0.4, 0.5], 'Duration', 0.01, 'StimThreshold', 0.5, 'MoveThreshold', 0.5, 'Highlight', 'union', 'MergeGroups', 'off', 'Hue', 'dv');
[~, ax{2}] = exp_A2A.ar.plotStimVsMoveResponse('Lick', 'Light', [0.4, 0.5], 'Duration', 0.01, 'StimThreshold', 0.5, 'MoveThreshold', 0.5, 'Highlight', 'union', 'MergeGroups', 'off', 'Hue', 'dv');
[~, ax{3}] = exp_D1.ar.plotStimVsMoveResponse('Press', 'Light', [0.4, 0.5], 'Duration', 0.01, 'StimThreshold', 0.5, 'MoveThreshold', 0.5, 'Highlight', 'union', 'MergeGroups', 'off', 'Hue', 'dv');
[~, ax{4}] = exp_A2A.ar.plotStimVsMoveResponse('Press', 'Light', [0.4, 0.5], 'Duration', 0.01, 'StimThreshold', 0.5, 'MoveThreshold', 0.5, 'Highlight', 'union', 'MergeGroups', 'off', 'Hue', 'dv');
for i = 1:4
    AcuteRecording.unifyAxesLims(ax{i})
    AcuteRecording.drawLines(ax{i}, true, true)
end
clear ax i


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

%% H1a: Cells excited by lStr A2A (max delta norm spike rate > 0.5) are in lateral SNr.
% H1b: Cells excited by lStr A2A (max delta norm spike rate > 0.5) are in ventral SNr.
theta = 0.5;

clear H1
close all

H1.sel = any(exp_A2A.sr(:, 5:8) >= theta, 2);
figure, ax(1) = subplot(1, 2, 1); ax(2) = subplot(1, 2, 2);
histogram(ax(1), exp_A2A.pos(H1.sel, 1), [1000, 1150, 1300, 1450, 1600])
xlabel(ax(1), 'ML')
histogram(ax(2), exp_A2A.pos(H1.sel, 2), -4800:100:-3800)
xlabel(ax(2), 'DV')
suptitle('lStr-A2A excited units')

figure, ax(1) = subplot(1, 2, 1); ax(2) = subplot(1, 2, 2);
histogram(ax(1), exp_A2A.pos(:, 1), [1000, 1150, 1300, 1450, 1600])
xlabel(ax(1), 'ML')
histogram(ax(2), exp_A2A.pos(:, 2), -4800:100:-3800)
xlabel(ax(2), 'DV')
suptitle('All units')

H1.mml_sel = median(exp_A2A.pos(H1.sel, 1));
H1.mdv_sel = median(exp_A2A.pos(H1.sel, 2));
H1.mml_all = median(exp_A2A.pos(:, 1));
H1.mdv_all = median(exp_A2A.pos(:, 2));
H1.mml_ci = bootci(nnz(H1.sel), @median, exp_A2A.pos(:, 1));
H1.mdv_ci = bootci(nnz(H1.sel), @median, exp_A2A.pos(:, 2));

fprintf(1, 'H1a: Cells excited by lStr A2A (max delta norm spike rate > %g) are in LATERAL SNr.\n', theta);
if H1.mml_sel > H1.mml_ci(2)
    fprintf('\tPassed!!!\n')
else
    fprintf('\tFailed...\n')
end
fprintf(1, '\t\tMedian ML: all=%.3g, subpopulation=%.3g, 95CI=[%.4g, %.4g]\n\n', ...
    H1.mml_all/1000, H1.mml_sel, H1.mml_ci(1)/1000, H1.mml_ci(2)/1000)

fprintf(1, 'H1b: Cells excited by lStr A2A (max delta norm spike rate > %g) are in VENTRAL SNr.\n', theta);
if H1.mdv_sel < H1.mdv_ci(1)
    fprintf('\tPassed!!!\n')
else
    fprintf('\tFailed...\n')
end
fprintf(1, '\t\tMedian DV: all=%.3g, subpopulation=%.3g, 95CI=[%.4g, %.4g]\n\n', ...
    H1.mdv_all/1000, H1.mdv_sel, H1.mdv_ci(1)/1000, H1.mdv_ci(2)/1000)

clear ax ci

%% H2: Cells excited by lStr A2A are less excited during pressing than licking.
clear H2
close all

H2.sel = H1.sel;
figure, ax(1) = subplot(1, 2, 1); ax(2) = subplot(1, 2, 2);
histogram(ax(1), exp_A2A.pr(H2.sel), -6:0.5:6)
xlabel(ax(1), 'Press')
histogram(ax(2), exp_A2A.lr(H2.sel), -6:0.5:6)
xlabel(ax(2), 'Lick')
suptitle('lStr-A2A excited units')

figure, ax(1) = subplot(1, 2, 1); ax(2) = subplot(1, 2, 2);
histogram(ax(1), exp_A2A.pr, -6:0.5:6)
xlabel(ax(1), 'Press')
histogram(ax(2), exp_A2A.lr, -6:0.5:6)
xlabel(ax(2), 'Lick')
suptitle('All units')

H2.ci = bootci(nnz(H2.sel), @median, exp_A2A.pr - exp_A2A.lr);
H2.mdf_all = median(exp_A2A.pr - exp_A2A.lr);
H2.mdf_sel = median(exp_A2A.pr(H2.sel) - exp_A2A.lr(H2.sel));


fprintf(1, 'H2: Cells excited by lStr A2A are less excited during pressing than licking.\n');
if H2.mdf_sel < H2.ci(1)
    fprintf('\tPassed!!!\n')
else
    fprintf('\tFailed...\n')
end
fprintf(1, '\t\tMedian(press - lick): all=%.4g, subpopulation=%.4g, ci=[%.4g, %.4g]\n\n', H2.mdf_all, H2.mdf_sel, H2.ci(1), H2.ci(2))


clear ax ci mdf_all mdf_sel

%% H3a: Cells excited by lStr D1 (max delta norm spike rate > 0.5) are in lateral SNr.
% H3b: Cells excited by lStr D1 (max delta norm spike rate > 0.5) are in dorsal SNr.
clear H3
close all

H3.sel = any(exp_D1.sr(:, 5:8) >= theta, 2);
figure, ax(1) = subplot(1, 2, 1); ax(2) = subplot(1, 2, 2);
histogram(ax(1), exp_D1.pos(H3.sel, 1), [1000, 1150, 1300, 1450, 1600])
xlabel(ax(1), 'ML')
histogram(ax(2), exp_D1.pos(H3.sel, 2), -4800:100:-3800)
xlabel(ax(2), 'DV')
suptitle('lStr-D1 excited units')

figure, ax(1) = subplot(1, 2, 1); ax(2) = subplot(1, 2, 2);
histogram(ax(1), exp_D1.pos(:, 1), [1000, 1150, 1300, 1450, 1600])
xlabel(ax(1), 'ML')
histogram(ax(2), exp_D1.pos(:, 2), -4800:100:-3800)
xlabel(ax(2), 'DV')
suptitle('All units')

H3.mml_sel = median(exp_D1.pos(H3.sel, 1));
H3.mdv_sel = median(exp_D1.pos(H3.sel, 2));
H3.mml_all = median(exp_D1.pos(:, 1));
H3.mdv_all = median(exp_D1.pos(:, 2));
H3.mml_ci = bootci(nnz(H3.sel), @median, exp_D1.pos(:, 1));
H3.mdv_ci = bootci(nnz(H3.sel), @median, exp_D1.pos(:, 2));

fprintf(1, 'H3a: Cells excited by lStr D1 (max delta norm spike rate > %g) are in LATERAL SNr.\n', theta);
if H3.mml_sel > H3.mml_ci(2)
    fprintf('\tPassed!!!\n')
else
    fprintf('\tFailed...\n')
end
fprintf(1, '\t\tMedian ML: all=%.3g, subpopulation=%.3g, 95CI=[%.4g, %.4g]\n\n', ...
    H3.mml_all/1000, H3.mml_sel, H3.mml_ci(1)/1000, H3.mml_ci(2)/1000)

fprintf(1, 'H3b: Cells excited by lStr D1 (max delta norm spike rate > %g) are in DORSAL SNr.\n', theta);
if H3.mdv_sel > H3.mdv_ci(2)
    fprintf('\tPassed!!!\n')
else
    fprintf('\tFailed...\n')
end
fprintf(1, '\t\tMedian DV: all=%.3g, subpopulation=%.3g, 95CI=[%.4g, %.4g]\n\n', ...
    H3.mdv_all/1000, H3.mdv_sel, H3.mdv_ci(1)/1000, H3.mdv_ci(2)/1000)

clear ax

%% H4: Cells excited by lStr D1 are less excited during pressing than licking.
clear H4
close all

H4.sel = H3.sel;
figure, ax(1) = subplot(1, 2, 1); ax(2) = subplot(1, 2, 2);
histogram(ax(1), exp_D1.pr(H4.sel), -6:0.5:6)
xlabel(ax(1), 'Press')
histogram(ax(2), exp_D1.lr(H4.sel), -6:0.5:6)
xlabel(ax(2), 'Lick')
suptitle('lStr-D1 excited units')

figure, ax(1) = subplot(1, 2, 1); ax(2) = subplot(1, 2, 2);
histogram(ax(1), exp_D1.pr, -6:0.5:6)
xlabel(ax(1), 'Press')
histogram(ax(2), exp_D1.lr, -6:0.5:6)
xlabel(ax(2), 'Lick')
suptitle('All units')

H4.ci = bootci(nnz(H4.sel), @median, exp_D1.pr - exp_D1.lr);
H4.mdf_all = median(exp_D1.pr - exp_D1.lr);
H4.mdf_sel = median(exp_D1.pr(H4.sel) - exp_D1.lr(H4.sel));


fprintf(1, 'H4: Cells excited by lStr A2A are less excited during pressing than licking.\n');
if H4.mdf_sel < H4.ci(1)
    fprintf('\tPassed!!!\n')
else
    fprintf('\tFailed...\n')
end
fprintf(1, '\t\tMedian(press - lick): all=%.4g, subpopulation=%.4g, ci=[%.4g, %.4g]\n\n', H4.mdf_all, H4.mdf_sel, H4.ci(1), H4.ci(2))

%% H5: Of the cells excited by lStr D1, subppulation a (excited by press) are dorsal-lateral SNr, subpopulation b (inhibited by press) are ventral-lateral SNr.
close all
clear ax

H5.sela = H3.sel & exp_D1.pr > 0;
H5.selb = H3.sel & exp_D1.pr < 0;

figure, ax(1) = subplot(1, 2, 1); ax(2) = subplot(1, 2, 2);
histogram(ax(1), exp_D1.pos(H5.sela, 1), [1000, 1150, 1300, 1450, 1600])
xlabel(ax(1), 'ML')
histogram(ax(2), exp_D1.pos(H5.sela, 2), -4800:100:-3800)
xlabel(ax(2), 'DV')
suptitle('lStr-D1 excited && press-excited units')

figure, ax(1) = subplot(1, 2, 1); ax(2) = subplot(1, 2, 2);
histogram(ax(1), exp_D1.pos(H5.selb, 1), [1000, 1150, 1300, 1450, 1600])
xlabel(ax(1), 'ML')
histogram(ax(2), exp_D1.pos(H5.selb, 2), -4800:100:-3800)
xlabel(ax(2), 'DV')
suptitle('lStr-D1 excited && press-inhibited units')

H5.mmlall = median(exp_D1.pos(:, 1));
H5.mdvall = median(exp_D1.pos(:, 2));
H5.mmla = median(exp_D1.pos(H5.sela, 1));
H5.mdva = median(exp_D1.pos(H5.sela, 2));
H5.mmlb = median(exp_D1.pos(H5.selb, 1));
H5.mdvb = median(exp_D1.pos(H5.selb, 2));
H5.mmlcia = bootci(nnz(H5.sela), @median, exp_D1.pos(:, 1));
H5.mdvcia = bootci(nnz(H5.sela), @median, exp_D1.pos(:, 2));
H5.mmlcib = bootci(nnz(H5.selb), @median, exp_D1.pos(:, 1));
H5.mdvcib = bootci(nnz(H5.selb), @median, exp_D1.pos(:, 2));

fprintf(1, 'H5a: Of the cells excited by lStr D1, subppulation a (excited by press) are dorsal-lateral SNr.\n');
if H5.mmla > H5.mmlcia(2) && H5.mdva > H5.mdvcia(2)
    fprintf('\tPassed!!!\n')
else
    fprintf('\tFailed...\n')
end
fprintf(1, '\t\tMedian ML: all=%.3g, subpopulation=%.3g, 95CI=[%.4g, %.4g]\n\n', ...
    H5.mmlall/1000, H5.mmla, H5.mmlcia(1)/1000, H5.mmlcia(2)/1000)
fprintf(1, '\t\tMedian DV: all=%.3g, subpopulation=%.3g, 95CI=[%.4g, %.4g]\n\n', ...
    H5.mdvall/1000, H5.mdva, H5.mdvcia(1)/1000, H5.mdvcia(2)/1000)

fprintf(1, 'H5b: Of the cells excited by lStr D1, subppulation b (inhibited by press) are ventral-lateral SNr.\n');
if H5.mmlb > H5.mmlcib(2) && H5.mdvb < H5.mdvcib(1)
    fprintf('\tPassed!!!\n')
else
    fprintf('\tFailed...\n')
end
fprintf(1, '\t\tMedian ML: all=%.3g, subpopulation=%.3g, 95CI=[%.4g, %.4g]\n\n', ...
    H5.mmlall/1000, H5.mmlb, H5.mmlcib(1)/1000, H5.mmlcib(2)/1000)
fprintf(1, '\t\tMedian DV: all=%.3g, subpopulation=%.3g, 95CI=[%.4g, %.4g]\n\n', ...
    H5.mdvall/1000, H5.mdvb, H5.mdvcib(1)/1000, H5.mdvcib(2)/1000)

%% H6a: Cells inhibited by lStr A2A (max delta norm spike rate > 0.5) are in lateral SNr.
theta = 0.5;

clear H6
close all

H6.sel = any(exp_A2A.sr(:, 5:8) <= -theta, 2);
figure, ax(1) = subplot(1, 2, 1); ax(2) = subplot(1, 2, 2);
histogram(ax(1), exp_A2A.pos(H6.sel, 1), [1000, 1150, 1300, 1450, 1600])
xlabel(ax(1), 'ML')
histogram(ax(2), exp_A2A.pos(H6.sel, 2), -4800:100:-3800)
xlabel(ax(2), 'DV')
suptitle('lStr-A2A inhibited units')

figure, ax(1) = subplot(1, 2, 1); ax(2) = subplot(1, 2, 2);
histogram(ax(1), exp_A2A.pos(:, 1), [1000, 1150, 1300, 1450, 1600])
xlabel(ax(1), 'ML')
histogram(ax(2), exp_A2A.pos(:, 2), -4800:100:-3800)
xlabel(ax(2), 'DV')
suptitle('All units')

H6.mml_sel = median(exp_A2A.pos(H6.sel, 1));
H6.mdv_sel = median(exp_A2A.pos(H6.sel, 2));
H6.mml_all = median(exp_A2A.pos(:, 1));
H6.mdv_all = median(exp_A2A.pos(:, 2));
H6.mml_ci = bootci(nnz(H6.sel), @median, exp_A2A.pos(:, 1));
H6.mdv_ci = bootci(nnz(H6.sel), @median, exp_A2A.pos(:, 2));

fprintf(1, 'H1a: Cells excited by lStr A2A (max delta norm spike rate > %g) are in LATERAL SNr.\n', theta);
if H6.mml_sel > H6.mml_ci(2)
    fprintf('\tPassed!!!\n')
else
    fprintf('\tFailed...\n')
end
fprintf(1, '\t\tMedian ML: all=%.3g, subpopulation=%.3g, 95CI=[%.4g, %.4g]\n\n', ...
    H6.mml_all/1000, H6.mml_sel, H6.mml_ci(1)/1000, H6.mml_ci(2)/1000)

fprintf(1, 'H1b: Cells excited by lStr A2A (max delta norm spike rate > %g) are in DORSAL SNr.\n', theta);
if H6.mdv_sel > H6.mdv_ci(2)
    fprintf('\tPassed!!!\n')
else
    fprintf('\tFailed...\n')
end
fprintf(1, '\t\tMedian DV: all=%.3g, subpopulation=%.3g, 95CI=[%.4g, %.4g]\n\n', ...
    H6.mdv_all/1000, H6.mdv_sel, H6.mdv_ci(1)/1000, H6.mdv_ci(2)/1000)

clear ax 

%%
H7.pos = vertcat(exp_A2A.pos, exp_D1.pos);
H7.lr = vertcat(exp_A2A.lr, exp_D1.lr);
H7.pr = vertcat(exp_A2A.pr, exp_D1.pr);

H7.selv = H7.pos(:, 2) < median(H7.pos(:, 2));
H7.seld = H7.pos(:, 2) >= median(H7.pos(:, 2));
H7.selm = abs(H7.pos(:, 1)) < 1300;
H7.sell = abs(H7.pos(:, 1)) >= 1300;

figure, 
ax(1) = subplot(2, 2, 1);
scatter(ax(1), H7.lr(H7.seld & H7.selm), H7.pr(H7.seld & H7.selm), 'filled');
xlabel(ax(1), 'Lick'), ylabel(ax(1), 'Press'), title(ax(1), 'Dorsal-Medial SNr');

ax(2) = subplot(2, 2, 2);
scatter(ax(2), H7.lr(H7.seld & H7.sell), H7.pr(H7.seld & H7.sell), 'filled');
xlabel(ax(2), 'Lick'), ylabel(ax(2), 'Press'), title(ax(2), 'Dorsal-Lateral SNr');

ax(3) = subplot(2, 2, 3);
scatter(ax(3), H7.lr(H7.selv & H7.selm), H7.pr(H7.selv & H7.selm), 'filled');
xlabel(ax(3), 'Lick'), ylabel(ax(3), 'Press'), title(ax(3), 'Ventral-Medial SNr');

ax(4) = subplot(2, 2, 4);
scatter(ax(4), H7.lr(H7.selv & H7.sell), H7.pr(H7.selv & H7.sell), 'filled');
xlabel(ax(4), 'Lick'), ylabel(ax(4), 'Press'), title(ax(4), 'Ventral-Lateral SNr');



AcuteRecording.unifyAxesLims(ax);
AcuteRecording.drawLines(ax, true, true);