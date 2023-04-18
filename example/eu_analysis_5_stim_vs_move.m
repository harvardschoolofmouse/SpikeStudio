%% Bar graphs
%% Calculate max/mean stim response across sites, for reachON/lickON or reachOFF/lickOFF populations, what is fractions of iSPN on and dSPN off? (12)
%% For press-inhibited units, what is fraction of DLS/VLS dSPN/iSPN-inhibited/excited (8 conditions)
%% For lick-inhibited units, what is fraction of DLS/VLS dSPN/iSPN-inhibited/excited (8 conditions)


%% 4. Use bootstraping to find significant movement responses (loose crit)
p.minNumTrials = 5;

c.hasPress = arrayfun(@(e) nnz(e.getTrials('press').duration() >= p.minTrialDuration) >= p.minNumTrials, eu);
c.hasLick = arrayfun(@(e) nnz(e.getTrials('lick').duration() >= p.minTrialDuration) >= p.minNumTrials, eu);

p.bootAlpha = 0.01;
boot2.press = struct('h', NaN(length(eu), 1), 'muDiffCI', NaN(length(eu), 2), 'muDiffObs', NaN(length(eu), 1));
boot2.lick = struct('h', NaN(length(eu), 1), 'muDiffCI', NaN(length(eu), 2), 'muDiffObs', NaN(length(eu), 1));
sel = c.hasPress & c.hasPos;
[boot2.press.h(sel), boot2.press.muDiffCI(sel, :), boot2.press.muDiffObs(sel)] = bootstrapMoveResponse( ...
    eu(sel), 'press', alpha=p.bootAlpha, withReplacement=false, oneSided=false, ...
    responseWindow=[-0.5, -0.2]);
sel = c.hasLick & c.hasPos;
[boot2.lick.h(sel), boot2.lick.muDiffCI(sel, :), boot2.lick.muDiffObs(sel)] = bootstrapMoveResponse( ...
    eu(sel), 'lick', alpha=p.bootAlpha, withReplacement=false, oneSided=false, ...
    responseWindow=[-0.3, 0]);
fprintf(1, '\nAll done\n')

%% Report bootstraped movement response direction
assert(nnz(isnan(boot2.lick.h(c.hasLick & c.hasPos))) == 0)
assert(nnz(isnan(boot2.press.h(c.hasPress & c.hasPos))) == 0)

figure, histogram(boot2.press.h)
c.isPressUp = boot2.press.h' == 1 & c.hasPress;
c.isPressDown = boot2.press.h' == -1 & c.hasPress;
c.isPressResponsive = c.isPressUp | c.isPressDown;

figure, histogram(boot2.lick.h)
c.isLickUp = boot2.lick.h' == 1 & c.hasLick;
c.isLickDown = boot2.lick.h' == -1 & c.hasLick;
c.isLickResponsive = c.isLickUp | c.isLickDown;

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
    '\t%g (%.0f%%) are excited (p<%g);\n' ...
    '\t%g (%.0f%%) are inhibited (p<%g).\n'], ...
    nnz(c.hasPress), p.minNumTrials, p.minTrialDuration, ...
    nnz(c.isPressUp), 100*nnz(c.isPressUp)/nnz(c.isPressResponsive), p.bootAlpha, ...
    nnz(c.isPressDown), 100*nnz(c.isPressDown)/nnz(c.isPressResponsive), p.bootAlpha);

fprintf(1, ['%g units with %g+ lick trials (%gs or longer):\n' ...
    '\t%g (%.0f%%) are excited (p<%g);\n' ...
    '\t%g (%.0f%%) are inhibited (p<%g).\n'], ...
    nnz(c.hasLick), p.minNumTrials, p.minTrialDuration, ...
    nnz(c.isLickUp), 100*nnz(c.isLickUp)/nnz(c.isLickResponsive), p.bootAlpha, ...
    nnz(c.isLickDown), 100*nnz(c.isLickDown)/nnz(c.isLickResponsive), p.bootAlpha);

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
% clear nTotal


%%
% c.isStimUpSpatialAny = reshape(any(c.isStimUpSpatial, [1,2]), 1, []);
% c.isStimDownSpatialAny = reshape(any(c.isStimDownSpatial, [1,2]), 1, []);
% c.isStimResponsiveSpatialAny = (c.isStimUpSpatialAny | c.isStimDownSpatialAny);
% arrayfun(@(e) mean(e.X(:, e.t>0 & e.t<0.1), 2), eta.stimSpatial, 'UniformOutput', false);


stimDirSpatial = c.isStimUpSpatial - c.isStimDownSpatial;
meanStimDirSpatial = reshape(mean(stimDirSpatial, [1, 2]), 1, []);
c.isStimUpSpatialMean = meanStimDirSpatial > 0;
c.isStimDownSpatialMean = meanStimDirSpatial < 0;
c.isStimResponsiveSpatialMean = c.isStimUpSpatialMean | c.isStimDownSpatialMean;

fprintf(1, 'Ai80: %d responsive, %d up, %d down\n', ...
    nnz(c.isAi80 & c.isStimResponsiveSpatialMean), ...
    nnz(c.isAi80 & c.isStimUpSpatialMean), ...
    nnz(c.isAi80 & c.isStimDownSpatialMean) ...
    )

fprintf(1, 'A2A: %d responsive, %d up, %d down\n', ...
    nnz(c.isA2A & c.isStimResponsiveSpatialMean), ...
    nnz(c.isA2A & c.isStimUpSpatialMean), ...
    nnz(c.isA2A & c.isStimDownSpatialMean) ...
    )

%%
sel = c.hasPos & c.isAi80;

nTotal = nnz(sel & c.isPressResponsive & c.isLickResponsive);
fprintf(1, ['%g isAi80 units with %d+ press AND lick trials (%gs or longer):\n' ...
    '\t%g (%.0f%%) are press-excited AND lick-excited;\n' ...
    '\t%g (%.0f%%) are press-inhibited AND lick-inhibited;\n' ...
    '\t%g (%.0f%%) are press-excited AND lick-inhibited;\n' ...
    '\t%g (%.0f%%) are press-inhibited AND lick-excited;\n'], ...
    nnz(sel & c.hasPress & c.hasLick), p.minNumTrials, p.minTrialDuration, ...
    nnz(sel & c.isPressUp & c.isLickUp), 100*nnz(sel & c.isPressUp & c.isLickUp)/nTotal, ...
    nnz(sel & c.isPressDown & c.isLickDown), 100*nnz(sel & c.isPressDown & c.isLickDown)/nTotal, ...
    nnz(sel & c.isPressUp & c.isLickDown), 100*nnz(sel & c.isPressUp & c.isLickDown)/nTotal, ...
    nnz(sel & c.isPressDown & c.isLickUp), 100*nnz(sel & c.isPressDown & c.isLickUp)/nTotal)   

sel = c.hasPos & c.isA2A;

nTotal = nnz(sel & c.isPressResponsive & c.isLickResponsive);
fprintf(1, ['%g isA2A units with %d+ press AND lick trials (%gs or longer):\n' ...
    '\t%g (%.0f%%) are press-excited AND lick-excited;\n' ...
    '\t%g (%.0f%%) are press-inhibited AND lick-inhibited;\n' ...
    '\t%g (%.0f%%) are press-excited AND lick-inhibited;\n' ...
    '\t%g (%.0f%%) are press-inhibited AND lick-excited;\n'], ...
    nnz(sel & c.hasPress & c.hasLick), p.minNumTrials, p.minTrialDuration, ...
    nnz(sel & c.isPressUp & c.isLickUp), 100*nnz(sel & c.isPressUp & c.isLickUp)/nTotal, ...
    nnz(sel & c.isPressDown & c.isLickDown), 100*nnz(sel & c.isPressDown & c.isLickDown)/nTotal, ...
    nnz(sel & c.isPressUp & c.isLickDown), 100*nnz(sel & c.isPressUp & c.isLickDown)/nTotal, ...
    nnz(sel & c.isPressDown & c.isLickUp), 100*nnz(sel & c.isPressDown & c.isLickUp)/nTotal)   

%% DLS
selCommon = c.isAi80 & c.hasStim & c.hasPress;
selStim = {c.isStimUp, c.isStimDown};
selMove = {c.isLickUp, c.isLickDown};


n = zeros(2, 2);
for i = 1:2
    for j = 1:2
        n(i, j) = nnz(selCommon & selStim{i} & selMove{j});
    end
end

[fstest.h, fstest.p] = fishertest(n);
n, fstest

selStim = {~c.hasStimResponse, c.hasStimResponse};
selMove = {~c.isPressResponsive, c.isPressResponsive};

bar(n(:))

n = zeros(2, 2);
for i = 1:2
    for j = 1:2
        n(i, j) = nnz(selCommon & selStim{i} & selMove{j});
    end
end
[fstest.h, fstest.p] = fishertest(n);
n, fstest

bar(n(:))
%% DLS A2A
selCommon = c.isAi80 & c.hasStim & c.hasPress;
selStim = {c.isStimUp, c.isStimDown};
selMove = {c.isLickUp, c.isLickDown};


n = zeros(2, 2);
for i = 1:2
    for j = 1:2
        n(i, j) = nnz(selCommon & selStim{i} & selMove{j});
    end
end

[fstest.h, fstest.p] = fishertest(n);
n, fstest

selStim = {~c.hasStimResponse, c.hasStimResponse};
selMove = {~c.isPressResponsive, c.isPressResponsive};

bar(n(:))

n = zeros(2, 2);
for i = 1:2
    for j = 1:2
        n(i, j) = nnz(selCommon & selStim{i} & selMove{j});
    end
end
[fstest.h, fstest.p] = fishertest(n);
n, fstest

bar(n(:))

%% DLS Ai80
selCommon = c.isAi80 & c.hasPos & c.hasPress & c.hasLick;
selStim = {c.isStimUp, c.isStimDown};
selMove = {c.isLickUp & c.isPressDown, c.isLickDown & c.isPressUp};

n = zeros(2, 2);
for i = 1:2
    for j = 1:2
        n(i, j) = nnz(selCommon & selStim{i} & selMove{j});
    end
end

[fstest.h, fstest.p] = fishertest(n);
n, fstest


%% GALVO Ai80
close all
selCommon = c.isAi80 & c.hasStim & c.hasPress & c.hasLick;
selStim = {c.isStimDownSpatialMean, c.isStimUpSpatialMean};
selMove = {c.isLickDown & c.isPressDown, c.isLickUp & c.isPressUp};

figure(Units='inches', Position=[0, 0, 6.5, 4])
clear ax
ax(1) = subplot(2, 1, 1);
ax(2) = subplot(2, 1, 2);

n = zeros(2, 2);
for i = 1:2
    for j = 1:2
        n(i, j) = nnz(selCommon & selStim{i} & selMove{j});
    end
end

[fstest.h, fstest.p] = fishertest(n, Tail='right');
fprintf('Ai80 stim vs. movement, p=%g\n', fstest.p)
n

bar(ax(1), n)

% GALVO A2A
selCommon = c.isA2A & c.hasStim & c.hasPress & c.hasLick;

n = zeros(2, 2);
for i = 1:2
    for j = 1:2
        n(i, j) = nnz(selCommon & selStim{i} & selMove{j});
    end
end

[fstest.h, fstest.p] = fishertest(n, Tail='right');
fprintf('A2A stim vs. movement, p=%g\n', fstest.p)
n
bar(ax(2), n)


%% GALVO (each Str site)
for iML = 1:2
    for iDV = 1:4
        fprintf(1, 'ML=%d, DV=%d:\n', iML, iDV)
        selCommon = c.isAi80 & c.hasStim & c.hasPress & c.hasLick;
        selStim = {reshape(c.isStimDownSpatial(iML, iDV, :), 1, []), reshape(c.isStimUpSpatial(iML, iDV, :), 1, [])};
        selMove = {c.isLickDown & c.isPressDown, c.isLickUp & c.isPressUp};
        
        figure(Units='inches', Position=[0, 0, 6.5, 4])
        clear ax
        ax(1) = subplot(2, 1, 1);
        ax(2) = subplot(2, 1, 2);
        
        n = zeros(2, 2);
        for i = 1:2
            for j = 1:2
                n(i, j) = nnz(selCommon & selStim{i} & selMove{j});
            end
        end
        
        [fstest.h, fstest.p] = fishertest(n, Tail='right');
        fprintf(1, 'Ai80 stim vs. movement, p=%g\n', fstest.p)
        n
        
        bar(ax(1), n)
        
        % GALVO A2A
        selCommon = c.isA2A & c.hasStim & c.hasPress & c.hasLick;
        
        n = zeros(2, 2);
        for i = 1:2
            for j = 1:2
                n(i, j) = nnz(selCommon & selStim{i} & selMove{j});
            end
        end
        
        [fstest.h, fstest.p] = fishertest(n, Tail='right');
        fprintf(1, 'A2A stim vs. movement, p=%g\n', fstest.p)
        n
        bar(ax(2), n)
    end
end

%% ARE MOVEMENT-RESPONSIVE UNITS MORE LIKELY TO BE AVG STIM RESPONSIVE
close all
clc
selCommon = c.hasPos & c.isAi80 & c.hasPress & c.hasLick;
selStim = {~c.isStimResponsiveSpatialMean, c.isStimResponsiveSpatialMean};
selMove = {~(c.isPressResponsive | c.isLickResponsive), c.isPressResponsive | c.isLickResponsive};

n = zeros(2, 2);
for i = 1:2
    for j = 1:2
        n(i, j) = nnz(selCommon & selStim{i} & selMove{j});
    end
end

[fstest.h, fstest.p] = fishertest(n, Tail='right');
fprintf('Ai80 stim vs. movement, p=%g\n', fstest.p)
n

            figure()
            bar(n)
% GALVO A2A
selCommon = c.hasPos & c.isA2A & c.hasPress & c.hasLick;

n = zeros(2, 2);
for i = 1:2
    for j = 1:2
        n(i, j) = nnz(selCommon & selStim{j} & selMove{i});
    end
end

[fstest.h, fstest.p] = fishertest(n, Tail='right');
fprintf('A2A stim vs. movement, p=%g\n', fstest.p)
n

            figure()
            bar(n)

%% ARE MOVEMENT-RESPONSIVE UNITS MORE LIKELY TO BE DLS STIM RESPONSIVE
% close all
% clc
selCommon = c.isAi80 & c.hasStim & c.hasPress;
selStim = {~c.hasStimResponse, c.hasStimResponse};
% selMove = {~(c.isPressResponsive | c.isLickResponsive), c.isPressResponsive | c.isLickResponsive};
selMove = {~c.isLickResponsive, c.isLickResponsive};

n = zeros(2, 2);
for i = 1:2
    for j = 1:2
        n(i, j) = nnz(selCommon & selStim{i} & selMove{j});
    end
end

[fstest.h, fstest.p] = fishertest(n, Tail='right');
fprintf('Ai80 stim vs. movement, p=%g\n', fstest.p)
n

            figure()
            bar(n)
% GALVO A2A
selCommon = c.isA2A  & c.hasStim & c.hasPress & c.hasLick;

n = zeros(2, 2);
for i = 1:2
    for j = 1:2
        n(i, j) = nnz(selCommon & selStim{j} & selMove{i});
    end
end

[fstest.h, fstest.p] = fishertest(n, Tail='right');
fprintf('A2A stim vs. movement, p=%g\n', fstest.p)
n

            figure()
            bar(n)