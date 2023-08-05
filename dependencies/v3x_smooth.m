function sts = v3x_smooth(ts, OnOff, method)
	%  this is the smoothing method from CLASS_photometry_roadmapv1_4
	% OnOff = 0: no smoothing
	% OnOff > 0: the kernel is OnOff
	% 
	if nargin < 4
		method = 'gausssmooth';
	end
	if nargin < 3 || OnOff < 0
		OnOff = 100;
    end
    
    if isempty(ts), sts = []; return, end

	if strcmp(method, 'gausssmooth')
		if OnOff
			sts = gausssmooth(ts, round(OnOff), 'gauss');
		else
			sts = ts;
		end
	else
		if OnOff
			sts = smooth(ts, round(OnOff), 'moving');
		else
			sts = ts;
		end
	end
end