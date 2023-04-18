%% Count nUp and nDown by animal, make animal x up/down contigency table
nUp = zeros(length(ai), 1);
nDown = zeros(length(ai), 1);
for ia = 1:length(ai)
    selUnits = strcmpi(ai(ia).name, eu.getAnimalName);
    nUp(ia) = nnz(c.isPressUp(selUnits));
    nDown(ia) = nnz(c.isPressDown(selUnits));
end

n = [nUp, nDown];

nBottom = sum(n, 1);
nRight = sum(n, 2);

nExpected = zeros(size(n));
for ic = 1:2
    nExpected(:, ic) = nBottom(ic) / sum(nBottom) .* nRight;
end

% Remove zeros
% toRemove = nRight == 0;
% n(toRemove, :) = [];
% nExpected(toRemove, :) = [];

chi2 = sum((nExpected - n).^2 ./ nExpected, 'all');
df = (size(n, 1) - 1) * (size(n, 2) - 1);
%
close all
ax = axes(figure(Units='inches', Position=[0 0 6 4]));
hold(ax, 'on')
plot(ax, 0:0.1:100, chi2pdf(0:0.1:100, df), 'k', DisplayName=sprintf('Chi^2 (df=%d)', df))
plot(ax, [chi2, chi2], [0, max(chi2pdf(0:0.1:100, df))], 'r', DisplayName=sprintf('Chi^2=%.2f', chi2))
ylim(ax, [0, max(chi2pdf(0:0.1:100, df))])
legend(ax)


clear ia selUnits ic nBottom nRight 