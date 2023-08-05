sNc = cell(1, nbins);
sNl = cell(1, nbins);
% 
% 	Now binning is simple...
% 		CTA 				LTA 				siITI
% 1| 	1:500 sorted_lt	 	1:500 sorted_lt		1:500 sorted_siITI
% 2| 	501:1000 sorted_lt	501:1000 sorted_lt	501:1000 sorted_siITI
% ...
% 
trials_in_each_bin = cell(nbins, 1);
% 
% 	Find the lick times in ms wrt cue for each trial
% 
for ibin = 1:nbins
	if verbose && rem(ibin, nbins*.1) == 0
		disp(['Processing bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ')']);
	end
	trials_in_each_bin{ibin} = sorted_lt_wrtc_ms(2, binEdges(ibin):binEdges(ibin+1)-1);

	%
	% new for 2023: let's get the lick times in this bin as well as lick time next trial and del:
	%
	warning('haven''t tested trials_in_each_bin methods 2023 for by trials mode...')
	teb = trials_in_each_bin{ibin};
	lick_times_in_each_bin{ibin} = obj.GLM.flick_s_wrtc(teb);
	lick_times_next_trial{ibin} = nan(size(lick_times_in_each_bin{ibin}));
	mask = ~ismember(teb, numel(obj.GLM.flick_s_wrtc));
	lick_times_next_trial{ibin}(mask) = obj.GLM.flick_s_wrtc(teb(mask)+1); 
	lick_time_tp1_minus_tn{ibin} = lick_times_next_trial{ibin} - lick_times_in_each_bin{ibin};
	% 
	% 	Get CTA running average for this bin...
	% 
    obj.ts.BinnedData.CTA{ibin} = zeros(1,2*timePad + obj.iv.total_time_ + 1);
	obj.ts.BinnedData.LTA{ibin} = zeros(1,2*timePad + 1);
	nC = nan(size(obj.ts.BinnedData.CTA{ibin}));
	nL = nan(size(obj.ts.BinnedData.LTA{ibin}));
	for n = 1:numel(trials_in_each_bin{ibin})
		c1 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) - timePad;
		c2 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
		if c1 < 0
			trimTS = [nan(-c1 + 1, 1); ts]; 
			nxt = [trimTS(1:c2-c1+1)]';
			nC(isnan(nC)) = 0;
			nC = nC+1;
			nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
			nC(nC==0) = nan;
			nxt = nxt./nC; % keeps nan in place	
			obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]);
        elseif c2 > numel(ts)
            extraelements = c2 - numel(ts);
            % trimTS = [ts; nan(extraelements, 1)];
            % nxt = [trimTS(c1:c2) ./n]'; % keeps nan in place	
            trimTS = [ts; nan(extraelements, 1)];
            nxt = [trimTS(c1:c2)]'; % keeps nan in place	
            nC(isnan(nC)) = 0;
			nC = nC+1;
			nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
			nC(nC==0) = nan;
			nxt = nxt./nC; % keeps nan in place
			obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]);
		else
			% nxt = [ts(c1:c2) ./n]'; % keeps nan in place
			nxt = [ts(c1:c2)]'; % keeps nan in place	
            nC(isnan(nC)) = 0;
			nC = nC+1;
			nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
			nC(nC==0) = nan;
			nxt = nxt./nC; % keeps nan in place
			obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]); % ignores the nans
			% obj.ts.BinnedData.CTA{ibin} = obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n) + [ts(c1:c2) ./n]';
		end
		%
		l1 = fLick(trials_in_each_bin{ibin}(n)) - timePad;
		l2 = fLick(trials_in_each_bin{ibin}(n)) + timePad;
        if isnan(l1) || isnan(l2)
			% if no-licks in bin, don't include the bin!
			obj.ts.BinnedData.LTA{ibin} = nan(size(obj.ts.BinnedData.LTA{ibin}));
        elseif l1 < 0
			trimTS = [nan(-l1 + 1, 1); ts];
			% nxt = [trimTS(1:l2-l1+1)./n]'; % keeps nan in place
			nxt = [trimTS(1:l2-l1+1)]'; % keeps nan in place	
            nL(isnan(nL)) = 0;
			nL = nL+1;
			nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
			nL(nL==0) = nan;
			nxt = nxt./nL; % keeps nan in place
			obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
        elseif l2 > numel(ts)
            extraelements = l2 - numel(ts);
            trimTS = [ts; nan(extraelements, 1)];
			% nxt = [trimTS(l1:l2)./n]'; % keeps nan in place
			nxt = [trimTS(l1:l2)]'; % keeps nan in place
            nL(isnan(nL)) = 0;
			nL = nL+1;
			nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
			nL(nL==0) = nan;
			nxt = nxt./nL; % keeps nan in place
			obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
        else
			% nxt = [ts(l1:l2)./n]'; % keeps nan in place
			nxt = [ts(l1:l2)]'; % keeps nan in place
            nL(isnan(nL)) = 0;
			nL = nL+1;
			nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
			nL(nL==0) = nan;
			nxt = nxt./nL; % keeps nan in place
			obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
			% obj.ts.BinnedData.LTA{ibin} = obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n) + [ts(l1:l2)./n]';
		end
		sNc{ibin} = nC;
		sNl{ibin} = nL;
    end
	% 
	% 	Append the legend
	% 
	obj.ts.BinParams.Legend_s.CLTA{ibin} = [num2str(round((sorted_lt_wrtc_ms(1, binEdges(ibin))/1000),3)) 's - ' num2str(round((sorted_lt_wrtc_ms(1, binEdges(ibin+1)-1)/1000),3)) 's | n=' num2str(numel(trials_in_each_bin{ibin}))];
	% 
	% 	Get Bin Time Centers and Ranges
	% 
	obj.ts.BinParams.s(ibin).CLTA_Min = sorted_lt_wrtc_ms(1, binEdges(ibin))/1000;
	obj.ts.BinParams.s(ibin).CLTA_Max = sorted_lt_wrtc_ms(1, binEdges(ibin+1))/1000;
	obj.ts.BinParams.s(ibin).CLTA_Center = sorted_lt_wrtc_ms(1, binEdges(ibin))/1000 + (sorted_lt_wrtc_ms(1, binEdges(ibin+1))/1000 - sorted_lt_wrtc_ms(1, binEdges(ibin))/1000)/2;
end
obj.ts.BinParams.binEdges_CLTA = binEdges;
obj.ts.BinParams.trials_in_each_bin = trials_in_each_bin;
obj.ts.BinParams.ntrials_per_bin_CLTA = ntrials_per_bin;
obj.ts.BinParams.nbins_CLTA = nbins;
% new for 2023
obj.ts.BinParams.lick_times_in_each_bin = lick_times_in_each_bin;
obj.ts.BinParams.lick_times_next_trial = lick_times_next_trial;
obj.ts.BinParams.lick_time_tp1_minus_tn = lick_time_tp1_minus_tn;
%
obj.ts.Plot.CTA.xticks.s = [-timePad:timePad+obj.iv.total_time_]/1000/samples_per_ms_xticks;
obj.ts.Plot.LTA.xticks.s = [-timePad:timePad]/1000/samples_per_ms_xticks;