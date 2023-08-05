% printFigure.m
function printFigure(name, f)
	% 
	% 	Created 2/2020	Allison Hamilos 	ahamilos{at}g.harvard.edu
	% 
	if nargin < 2
		f = gcf;
	end
	print(f,'-depsc','-painters', [name, '.eps'])
    saveas(f,[name, '.png'])
	savefig(f, [name, '.fig']);
end