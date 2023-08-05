function Nans = zero2nan(Zeros, onesMode)
	% 
	%  Convert all zeros to NaN
	% 		** Use onesMode to also convert 1s to nan. This is helpful if don't want to include bins already above thresh in the model
	% 
	if nargin < 3
		onesMode = false;
    end
    if sum(Zeros==0) > 0
    	Zeros(Zeros == 0) = nan;
    else
        Zeros = Zeros;
    end
	if onesMode
		Zeros(Zeros == 1) = nan;
	end
	Nans = Zeros;
end