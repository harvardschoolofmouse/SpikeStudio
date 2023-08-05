function [Z] = normalize_0_1(vec)
	a = vec - min(vec);
	Z = a ./ max(a);
end