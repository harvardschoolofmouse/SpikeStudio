
%%
sel = c.hasPress;
% response = transpose(meta.pressRaw(sel)*10 - msr(sel));
% response = msr(sel)';
response = meta.press(sel);
[~, animal] = ismember(cellfun(@lower, eu(sel).getAnimalName', UniformOutput=false), {ai.name}');
unit = zeros(size(response));
ncells = 29;
for ia = unique(animal)'
%     n = nnz(animal==ia);
    subsel = find(animal==ia);
    subsel = subsel(randi(length(subsel), ncells, 1));
    unit(subsel) = 1:ncells;
end
sel = unit ~= 0;

anovan(response(sel), {unit(sel), animal(sel)}, VarName={'unit', 'animal'})
clear I ia n sel subsel;

%% Just plot the damn thing
close all

[~, animal] = ismember(cellfun(@lower, eu.getAnimalName', UniformOutput=false), {ai.name}');
response = c.isPressUp;
response = response - c.isPressDown;
ax = axes(figure());
phat = NaN(length(unique(animal)), 1);
ci = NaN(length(unique(animal)), 2);
for ia = unique(animal)'
    sel = animal==ia;
    r = response(sel);
    r = r(r~=0);
    isUp = r == 1;
    nUp(ia) = nnz(isUp);
    N(ia) = length(isUp);
    [phat(ia), ci(ia, 1:2)] = binofit(nUp(ia), N(ia), 0.05);
end
[~, I] = sort(phat);
hold(ax, 'on')
bar(ax, phat(I), FaceColor='red', FaceAlpha=0.1)
er = errorbar(ax, 1:length(I), phat(I), ci(I, 1) - phat(I), ci(I, 2) - phat(I), Color='black', LineStyle='none');
hold(ax, 'off')
ylabel('pUp')
xlabel('animal')

ax = axes(figure);
scatter(N, nUp./N)
ylim(ax, [0, 1])
xlabel(ax, 'Sample Size')
ylabel('pUp')