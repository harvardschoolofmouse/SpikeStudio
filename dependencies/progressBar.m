function progressBar(iter, total, nested, cutter)
	if nargin < 4
		cutter = 1000;
	end
	if nargin < 3
		nested = false;
	end
	if nested
		prefix = '		';
	else
		prefix = '';
	end
	if rem(iter,total*.1) == 0 || rem(iter, cutter) == 0
		done = {'=', '=', '=', '=', '=', '=', '=', '=', '=', '='};
		incomplete = {'-', '-', '-', '-', '-', '-', '-', '-', '-', '-'};
		ndone = round(iter/total * 10);
		nincomp = round((1 - iter/total) * 10);
		disp([prefix '	*' horzcat(done{1:ndone}) horzcat(incomplete{1:nincomp}) '	(' num2str(iter) '/' num2str(total) ') ' datestr(now)]);
	end
end