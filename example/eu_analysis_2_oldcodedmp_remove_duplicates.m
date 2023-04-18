
%% 2.2.2 Cull duplicate units by thresholding cross-correlation of binned spike counts
clearvars -except eu ai p
[uniqueExpNames, ~, ic] = unique({eu.ExpName});
nUniqueExps = length(uniqueExpNames);
r = cell(nUniqueExps, 1);
lags = cell(nUniqueExps, 1);
pairIndices = cell(nUniqueExps, 1);
for iExp = 1:nUniqueExps
    iEus = find(ic == iExp);
    tTic = tic();
    if length(iEus) <= 1
        fprintf(1, 'Session %g (of %g) has only %g unit, no calculation needed.\n', iExp, nUniqueExps, length(iEus));
        continue;
    end
    fprintf(1, 'Session %g (of %g), calculating %g pair-wise correlations...', iExp, nUniqueExps, nchoosek(length(iEus), 2));
    [r{iExp}, lags{iExp}, pairIndices{iExp}] = eu(iEus).xcorr('count', resolution=0.005, maxlag=10, normalize=true);

    pairIndices{iExp} = iEus(pairIndices{iExp});

    fprintf(1, 'Done (%.2f sec).\n', toc(tTic))
end

assert(size(unique(cat(1, lags{:}), 'rows'), 1) == 1)
lags = unique(cat(1, lags{:}), 'rows');
pairIndices = cat(1, pairIndices{:});
r = cat(1, r{:});
clearvars -except eu ai p lags pairIndices r 


%% 2.2.2.1 Plot a distribution of all pairwise correlations, for all experiments
close all
ax = axes(figure());
hold(ax, 'on')
r0 = r(:, lags==0);
h(1) = histogram(ax, r(:, lags==0), 0:0.01:1, DisplayName='R(0)', Normalization='probability');
yrange = ax.YLim;
h(2) = plot(ax, repmat(mean(r0), [2, 1]), yrange, DisplayName=sprintf('mean=%.2f', mean(r0)), LineWidth=2);
h(3) = plot(ax, repmat(median(r0), [2, 1]), yrange, DisplayName=sprintf('median=%.2f', median(r0)), LineWidth=2);
h(4) = plot(ax, repmat(mean(r0)+2*std(r0, 0), [2, 1]), yrange, DisplayName=sprintf('mean+2*std=%.2f', mean(r0)++2*std(r0, 0)), LineWidth=2);
h(5) = plot(ax, repmat(median(r0)+2*mad(r0, 1)/0.6745, [2, 1]), yrange, DisplayName=sprintf('median+2*mad//0.6745=%.2f', median(r0)++2*mad(r0, 1)/0.6745), LineWidth=2);
h(6) = plot(ax, repmat(prctile(r0, 95), [2, 1]), yrange, DisplayName=sprintf('95 percentile=%.2f', prctile(r0, 95)), LineWidth=2);
ax.YLim = yrange;
hold(ax, 'off')
legend(ax, h)

clear ax h yrange r0

%%
rd.press = eu.getRasterData('press');
rd.lick = eu.getRasterData('lick');


%% Choose a threshold and plot double rasters to compare
clear ax figname fig iPair dirname r0 nPairs i j rrddi rrddj ifig ME

rTheta = 0.40;
dirname = sprintf('C:\\SERVER\\Figures\\duplicate_detect_xcorr\\rTheta=%.2f', rTheta);

nPairs = size(pairIndices, 1);
r0 = r(:, lags==0);
for iPair = find(r0 > rTheta)'
    assert(numel(iPair) == 1)
    try
        i = pairIndices(iPair, 1);
        j = pairIndices(iPair, 2);
    
        if ~isempty(rd.press(i).t) && ~isempty(rd.press(j).t)
            rrddi = rd.press(i);
            rrddj = rd.press(j);
        elseif ~isempty(rd.lick(i).t) && ~isempty(rd.lick(j).t)
            rrddi = rd.lick(i);
            rrddj = rd.lick(j);
        else
            warning('No lick or press raster data found for units %s and %s', eu(i).getName(), eu(j).getName())
            continue
        end
    
        figname{1} = sprintf('r=%.2f (%g=%g+%g)', r0(iPair), iPair, i, j);
        figname{2} = sprintf('r=%.2f (%g=%g+%g) (i=%g)', r0(iPair), iPair, i, j, i);
        figname{3} = sprintf('r=%.2f (%g=%g+%g) (j=%g)', r0(iPair), iPair, i, j, j);

        % Plot double raster
        ax = plotDoubleRaster(rrddi, rrddj, ...
            sprintf('%g_%s', i, eu(i).getName('_')), ...
            sprintf('%g_%s', j, eu(j).getName('_')));
        fig(1) = ax(1).Parent;
        suptitle(figname{1})

        % Plot single figures
        ax = EphysUnit.plotRaster(rrddi);
        fig(2) = ax.Parent;
        ax = EphysUnit.plotRaster(rrddj);
        fig(3) = ax.Parent;

        if ~isfolder(dirname)
            mkdir(dirname);
        end
        
        for ifig = 1:3
            print(fig(ifig), sprintf('%s\\%s.jpg', dirname, figname{ifig}), '-djpeg');
        end
    catch ME
        warning('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message)
    end
    close all
end

clear ax figname fig iPair dirname r0 nPairs i j rrddi rrddj ifig ME

% Observations:
% With 5ms binning:
% rTheta > 0.8: definitely duplicate units
% rTheta in [0.6, 0.8] could be multiunits, or one channel (singleunit) is 
% a subset of another (multiunit), consider keeping the one with lower 
% firing rate? Might need to check waveforms and ISI first to verify this.

%% Filter out duplicate units with high correlation. 
% Keep the one with the lower unit index. This ensures when there are more
% than 2 duplicates, all duplicates are removed. 
rTheta = 0.7;
duplicatePairs = pairIndices(r(:, lags==0) > rTheta, :);

isDuplicate = false(length(eu), 1);
for iPair = 1:size(duplicatePairs, 1)
    isDuplicate(duplicatePairs(iPair, 2)) = true;
end
disp(find(isDuplicate))

eu = eu(~isDuplicate);

fprintf(1, 'Removed %g putative duplicate units with R(0) > %.2f.\n', nnz(isDuplicate), rTheta);

clearvars -except eu p ai
