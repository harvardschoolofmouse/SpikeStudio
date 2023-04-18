
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
    [r{iExp}, lags{iExp}] = eu(iEus).xcorr('count', resolution=0.005, maxlag=10, normalize=true);
    fprintf(1, 'Done (%.2f sec).\n', toc(tTic))
end

clear iExp tTic iEus