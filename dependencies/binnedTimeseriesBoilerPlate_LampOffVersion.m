sNc = cell(1, nbins);
sNl = cell(1, nbins);
% 
% 	Find which trials go in each bin:
% 		CTA 			LTA 			siITI
% 1| 0:1s wrtCue 	0:1s wrtCue		0:1s wrtLastLick
% 2| 1:2s wrtCue 	1:2s wrtCue		1:2s wrtLastLick
% ...
% 
% 
% 	Find the lick times in ms wrt cue for each trial
% 
trials_in_each_bin = cell(nbins, 1);
for ibin = 1:nbins
	if verbose && rem(ibin, nbins*.1) == 0
		disp(['Processing bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ')']);
	end
	ll = find(all_fl_wrtc_ms >= binEdges(ibin));
	ul = find(all_fl_wrtc_ms < binEdges(ibin + 1));
	trials_in_each_bin{ibin} =  ll(ismember(ll, ul));
	%
	% new for 2023: let's get the lick times in this bin as well as lick time next trial and del:
	%
	teb = trials_in_each_bin{ibin};
	lick_times_in_each_bin{ibin} = obj.GLM.flick_s_wrtc(teb);

	lick_times_previous_trial{ibin} = nan(size(lick_times_in_each_bin{ibin}));
	mask = ~ismember(teb, 1);
	lick_times_previous_trial{ibin}(mask) = obj.GLM.flick_s_wrtc(teb(mask)-1);
	lick_time_tn_minus_tprev1{ibin} = lick_times_in_each_bin{ibin} - lick_times_previous_trial{ibin};


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
		c1 = obj.GLM.pos.lampOff(trials_in_each_bin{ibin}(n)) - timePad;
		c2 = obj.GLM.pos.lampOff(trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
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
		if l1 < 0
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
	obj.ts.BinParams.Legend_s.CLTA{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's | n=' num2str(numel(trials_in_each_bin{ibin}))];
	% 
	% 	Get Bin Time Centers and Ranges
	% 
	obj.ts.BinParams.s(ibin).CLTA_Min = binEdges(ibin)/1000;
	obj.ts.BinParams.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
	obj.ts.BinParams.s(ibin).CLTA_Center = (binEdges(ibin)/1000 + (binEdges(ibin+1) - binEdges(ibin))/1000/2);
end
obj.ts.BinParams.binEdges_CLTA = binEdges;
obj.ts.BinParams.trials_in_each_bin = trials_in_each_bin;
obj.ts.BinParams.nbins_CLTA = nbins;
                
                




% new for 2023
obj.ts.BinParams.lick_times_in_each_bin = lick_times_in_each_bin;
obj.ts.BinParams.lick_times_next_trial = lick_times_next_trial;
obj.ts.BinParams.lick_time_tp1_minus_tn = lick_time_tp1_minus_tn;
obj.ts.BinParams.lick_times_previous_trial = lick_times_previous_trial;
obj.ts.BinParams.lick_time_tn_minus_tprev1 = lick_time_tn_minus_tprev1;
%
obj.ts.Plot.CTA.xticks.s = [-timePad:timePad+obj.iv.total_time_]/1000/samples_per_ms_xticks;
obj.ts.Plot.LTA.xticks.s = [-timePad:timePad]/1000/samples_per_ms_xticks;
obj.ts.BinnedData.warning = 'CTA is aligned to LAMPOFF!!!!!!!!!';







% outcome version had:
 % figure,
                    % subplot(1,2,1)
                    % nL(isnan(nL)) = 0;
                    % nC(isnan(nC)) = 0;
                    % histogram(nC), title('number of trials per sample distribution - CTA')
                    % subplot(1,2,2)
                    % histogram(nL), title('number of trials per sample distribution - LTA')
					% for n = 1:numel(trials_in_each_bin{ibin})
					% 	c1 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) - timePad;
					% 	c2 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
					% 	if c1 < 0
					% 		trimTS = [nan(-c1 + 1, 1); ts];
					% 		nxt = [trimTS(1:c2-c1+1) ./n]'; % keeps nan in place	
					% 		obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n); nxt]);
     %                    elseif c2 > numel(ts)
     %                        extraelements = c2 - numel(ts);
     %                        trimTS = [ts; nan(extraelements, 1)];
     %                        nxt = [trimTS(c1:c2) ./n]'; % keeps nan in place	
					% 		obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n); nxt]);
					% 	else
					% 		nxt = [ts(c1:c2) ./n]'; % keeps nan in place
					% 		obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n); nxt]); % ignores the nans
					% 		% obj.ts.BinnedData.CTA{ibin} = obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n) + [ts(c1:c2) ./n]';
					% 	end
					% 	%
					% 	l1 = fLick(trials_in_each_bin{ibin}(n)) - timePad;
					% 	l2 = fLick(trials_in_each_bin{ibin}(n)) + timePad;
					% 	if l1 < 0
					% 		trimTS = [nan(-l1 + 1, 1); ts];
					% 		nxt = [trimTS(1:l2-l1+1)./n]'; % keeps nan in place
					% 		obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n); nxt]); % ignores the nans
     %                    elseif l2 > numel(ts)
     %                        extraelements = l2 - numel(ts);
     %                        trimTS = [ts; nan(extraelements, 1)];
					% 		nxt = [trimTS(l1:l2)./n]'; % keeps nan in place
					% 		obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n); nxt]); % ignores the nans
     %                    else
					% 		nxt = [ts(l1:l2)./n]'; % keeps nan in place
					% 		obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n); nxt]); % ignores the nans
					% 		% obj.ts.BinnedData.LTA{ibin} = obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n) + [ts(l1:l2)./n]';
					% 	end
					% end