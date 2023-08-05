function pathstr = correctPathOS(pathstr)
	if ispc
		pathstr = strjoin(strsplit(pathstr, '/'), '\');
	else
		pathstr = [strjoin(strsplit(pathstr, '\'), '/')];
	end
end