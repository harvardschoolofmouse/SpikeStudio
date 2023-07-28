function [f, axs] = makeStandardFigure(naxes,subplots)
	%   [f, axs] = makeStandardFigure(naxes=1,subplots=[1,1])
	% 	subplots is total rows, columns
	% 		e.g., [2,3]
	% 
    if nargin < 2
        naxes = 1;
        subplots = [1,1];
    end
	f = figure;
	set(f, 'color', 'white')
	for ii = 1:naxes
		axs(ii) = subplot(subplots(1), subplots(2),ii);
		hold(axs(ii), 'on');
		set(axs(ii), 'fontsize', 12)
	end
end