% getavetimeseries.m

% 
% 	we'll input a dummy obj which is a field of obj.analysis to do this collation with...
% 
divideByNTrialsPerBin = true;
gfitStyle = sObj.GLM.gfitStyle;
nm1conditioning = ''; % this method not currently built for partitioning

if strcmpi(stimMode, 'stim')
    disp('     Binning for Stim trials')
    if ~isfield(sObj.GLM, 'stimTrials')
        sObj.GLM.stimTrials = [];
    end
    [sNc, sNl] = sObj.getBinnedTimeseries(Z, Mode, nbins, timePad, sObj.GLM.stimTrials,[],false,[],nm1conditioning);
elseif strcmpi(stimMode, 'noStim')
    disp('     Binning for noStim trials')
    if ~isfield(sObj.GLM, 'noStimTrials')
        sObj.GLM.noStimTrials = 1:numel(sObj.GLM.cue_s);
    end
    % correct sampling rate...
    sObj.correctSamplingRate();
    [sNc, sNl] = sObj.getBinnedTimeseries(Z, Mode, nbins, timePad, sObj.GLM.noStimTrials,[],false,[],nm1conditioning);
elseif strcmpi(gfitStyle{1}, 'none') 
    disp('     behavior only')
    % correct sampling rate...
    sNc = [];
    sNl = [];
    if ~isfield(dummyobj.GLM,'flick_s_wrtc')
        dummyobj.GLM.flick_s_wrtc = {};
    end
    sObj.getflickswrtc
    sObj.getRxnPermittedFlicks(0.5)
    if isfield(dummyobj.GLM,'flick_s_wrtc_rxnPermitted')
        dummyobj.GLM.flick_s_wrtc_rxnPermitted = [dummyobj.GLM.flick_s_wrtc_rxnPermitted;sObj.GLM.flick_s_wrtc_rxnPermitted];
    else
        dummyobj.GLM.flick_s_wrtc_rxnPermitted = sObj.GLM.flick_s_wrtc_rxnPermitted;
    end
    if numel(dummyobj.iv.trialsIncluded) == 1 && strcmpi(dummyobj.iv.trialsIncluded, 'off')
        if isempty(dummyobj.GLM.flick_s_wrtc)
            dummyobj.GLM.flick_s_wrtc{1} = sObj.GLM.flick_s_wrtc;
        else
            dummyobj.GLM.flick_s_wrtc{1} = [dummyobj.GLM.flick_s_wrtc{1};sObj.GLM.flick_s_wrtc];
        end            
    elseif numel(dummyobj.iv.trialsIncluded) == 2
        %
        % We will gather trials by percentile in session
        %   trialsIncluded = {fraction, partition#toplot}
        %
        if dummyobj.iv.trialsIncluded{1} < 1, error('partitions should be a whole number. Use {4, 1} not {.25, 1}'), end
        npartitions = dummyobj.iv.trialsIncluded{1};
        for iipart = 1:npartitions
            p1Idx = 1+floor(numel(sObj.GLM.fLick_trial_num)/npartitions)*(iipart-1);
            if iipart == npartitions
                p2Idx = numel(sObj.GLM.fLick_trial_num);
            else
                p2Idx = floor(numel(sObj.GLM.fLick_trial_num)/npartitions)*(iipart);
            end
            disp(['div#' num2str(iipart) ':' num2str(p1Idx) '-' num2str(p2Idx)])
            trialsIncluded = sObj.GLM.fLick_trial_num(p1Idx:p2Idx);
            if numel(dummyobj.GLM.flick_s_wrtc) < iipart || isempty(dummyobj.GLM.flick_s_wrtc{iipart})
                dummyobj.GLM.flick_s_wrtc{iipart} = sObj.GLM.flick_s_wrtc(trialsIncluded);
            else
                dummyobj.GLM.flick_s_wrtc{iipart} = [dummyobj.GLM.flick_s_wrtc{iipart};sObj.GLM.flick_s_wrtc(trialsIncluded)];
            end  
        end
    elseif numel(dummyobj.iv.trialsIncluded) == 1
        trialsIncluded = dummyobj.iv.trialsIncluded{1};
        if isempty(dummyobj.GLM.flick_s_wrtc{ii})
                dummyobj.GLM.flick_s_wrtc{1} = sObj.GLM.flick_s_wrtc(trialsIncluded);
        else
            dummyobj.GLM.flick_s_wrtc{1} = [dummyobj.GLM.flick_s_wrtc{1};sObj.GLM.flick_s_wrtc(trialsIncluded)];
        end
    else
        error('trialsIncluded not initialized properly. Should be {''off''}, {# of partitions, partition2plot}, or {specific trial numbers} to include). Added 10/11/2020')
    end
else
    % disp('     Stim mode is OFF')
    if sObj.Plot.samples_per_ms>1
        warning('unexpected sampling rate!! setting to 1. We assume we downsampled the move controls')
        sObj.correctSamplingRate(true);
    end       

    if ~isfield(dummyobj.GLM,'flick_s_wrtc')
        dummyobj.GLM.flick_s_wrtc = {};
    end
    if numel(dummyobj.iv.trialsIncluded) == 1 && strcmpi(dummyobj.iv.trialsIncluded, 'off')
        [sNc, sNl] = sObj.getBinnedTimeseries(Z, Mode, nbins, timePad,[],[],false,[],nm1conditioning);
        if isempty(dummyobj.GLM.flick_s_wrtc)
            dummyobj.GLM.flick_s_wrtc{1} = sObj.GLM.flick_s_wrtc;
        else
            dummyobj.GLM.flick_s_wrtc{1} = [dummyobj.GLM.flick_s_wrtc{1};sObj.GLM.flick_s_wrtc];
        end            
    elseif numel(dummyobj.iv.trialsIncluded) == 2
        error('rbf -- i didnt design this function to handle this specifically')
        %
        % We will gather trials by percentile in session
        %   trialsIncluded = {fraction, partition#toplot}
        %
        if dummyobj.iv.trialsIncluded{1} < 1, error('partitions should be a whole number. Use {4, 1} not {.25, 1}'), end
        npartitions = dummyobj.iv.trialsIncluded{1};
        for iipart = 1:npartitions
            p1Idx = 1+floor(numel(sObj.GLM.fLick_trial_num)/npartitions)*(iipart-1);
            if iipart == npartitions
                p2Idx = numel(sObj.GLM.fLick_trial_num);
            else
                p2Idx = floor(numel(sObj.GLM.fLick_trial_num)/npartitions)*(iipart);
            end
            disp(['div#' num2str(iipart) ':' num2str(p1Idx) '-' num2str(p2Idx)])
            trialsIncluded = sObj.GLM.fLick_trial_num(p1Idx:p2Idx);
            if numel(dummyobj.GLM.flick_s_wrtc) < iipart || isempty(dummyobj.GLM.flick_s_wrtc{iipart})
                dummyobj.GLM.flick_s_wrtc{iipart} = sObj.GLM.flick_s_wrtc(trialsIncluded);
            else
                dummyobj.GLM.flick_s_wrtc{iipart} = [dummyobj.GLM.flick_s_wrtc{iipart};sObj.GLM.flick_s_wrtc(trialsIncluded)];
            end
            if iipart == dummyobj.iv.trialsIncluded{2}
                %function [sNc, sNl] = getBinnedTimeseries(dummyobj, ts, Mode, nbins, timePad, trialsIncluded, samples_per_ms_xticks, verbose, handles, conditionNm1RewOrEarly)
                [sNc, sNl] = sObj.getBinnedTimeseries(Z, Mode, nbins, timePad, trialsIncluded,[],false,[],nm1conditioning);
            end   
        end
    elseif numel(dummyobj.iv.trialsIncluded) == 1
        trialsIncluded = dummyobj.iv.trialsIncluded{1};
        [sNc, sNl] = sObj.getBinnedTimeseries(Z, Mode, nbins, timePad, trialsIncluded,[],false,[],nm1conditioning);
        if isempty(dummyobj.GLM.flick_s_wrtc{ii})
                dummyobj.GLM.flick_s_wrtc{1} = sObj.GLM.flick_s_wrtc(trialsIncluded);
        else
            dummyobj.GLM.flick_s_wrtc{1} = [dummyobj.GLM.flick_s_wrtc{1};sObj.GLM.flick_s_wrtc(trialsIncluded)];
        end
    else
        error('trialsIncluded not initialized properly. Should be {''off''}, {# of partitions, partition2plot}, or {specific trial numbers} to include). Added 10/11/2020')
    end
end

% 
% 	Now update the main dummy's ts:
% 
if strcmpi(Mode, 'paired-nLicksBaseline') || strcmpi(Mode, 'paired-nLicksBaseline-LOTA'), nnbins=nbins; nbins=8; end
if strcmpi(Mode, 'custom'), nnbins=nbins; nbins=numel(nnbins)-1; end
if iset == 1 && ~strcmpi(gfitStyle{1}, 'none') 
	% 
	% 	Initialize the ts structure. We won't bother filling the others, since this won't be used to GLM yet and the ts binning fxs work better
	% 
	for ibin = 1:nbins
	    dummyobj.ts.BinnedData.CTA{1,ibin} = nan(size(sObj.ts.BinnedData.CTA{1,ibin}));
	    dummyobj.ts.BinnedData.LTA{1,ibin} = nan(size(sObj.ts.BinnedData.LTA{1,ibin}));
	    dummyobj.ts.BinnedData.CTA{1,ibin} = nan(size(sObj.ts.BinnedData.CTA{1,ibin}));
	    dummyobj.ts.BinnedData.LTA{1,ibin} = nan(size(sObj.ts.BinnedData.LTA{1,ibin}));
	    dummyobj.ts.BinParams.Legend_s = sObj.ts.BinParams.Legend_s;
        dummyobj.ts.BinParams.s = sObj.ts.BinParams.s;
        dummyobj.ts.BinParams.binEdges_CLTA = sObj.ts.BinParams.binEdges_CLTA;
        dummyobj.ts.BinParams.trials_in_each_bin{ibin} = 0;
	    dummyobj.ts.BinParams.trials_in_each_bin{ibin} = numel(sObj.ts.BinParams.trials_in_each_bin{ibin});
	    % new for 2023: keeping track of times of licks on this trial and next
	    dummyobj.ts.BinParams.lick_times_in_each_bin{ibin} = [];
	    dummyobj.ts.BinParams.lick_times_next_trial{ibin} = [];
	    dummyobj.ts.BinParams.lick_time_tp1_minus_tn{ibin} = [];
	    dummyobj.ts.BinParams.lick_times_previous_trial{ibin} = [];
	    dummyobj.ts.BinParams.lick_time_tn_minus_tprev1{ibin} = [];
	    %
        dummyobj.ts.BinParams.nbins_CLTA = sObj.ts.BinParams.nbins_CLTA;
        dummyobj.Plot.samples_per_ms = sObj.Plot.samples_per_ms;
        dummyobj.Plot.wrtCTAArray = sObj.Plot.wrtCTAArray;
        dummyobj.Plot.wrtCue = sObj.Plot.wrtCue;
        dummyobj.Plot.CTA = sObj.Plot.CTA;
        dummyobj.Plot.LTA = sObj.Plot.LTA;
        dummyobj.Plot.smooth_kernel = sObj.Plot.smooth_kernel;
	    dummyobj.ts.Plot = sObj.ts.Plot;
        if ~isempty(sNc{ibin})
            sNc_total{ibin} = sNc{ibin};
            sNl_total{ibin} = sNl{ibin};
        else
            sNc_total{ibin} = nan(size(sNc_total{1}));
            sNl_total{ibin} = nan(size(sNl_total{1}));
        end
	end				
end
% 
% 	Updae our numbers...
% 
if ~isfield(sObj.iv.num_trials_category, 'num_no_ex_trials')
    sObj.iv.num_trials_category.num_no_ex_trials = sObj.iv.num_trials_category.num_trials_category.num_no_ex_trials;
end
dummyobj.iv.num_trials = dummyobj.iv.num_trials + sObj.iv.num_trials;
dummyobj.iv.num_trials_category.num_no_ex_trials = dummyobj.iv.num_trials_category.num_no_ex_trials + sObj.iv.num_trials_category.num_no_ex_trials;
dummyobj.iv.num_trials_category.num_no_rxn_or_ex_trials = dummyobj.iv.num_trials_category.num_no_rxn_or_ex_trials + sObj.iv.num_trials_category.num_no_rxn_or_ex_trials;
dummyobj.iv.num_trials_category.num_rxn_not_ex_trials = dummyobj.iv.num_trials_category.num_rxn_not_ex_trials + sObj.iv.num_trials_category.num_rxn_not_ex_trials;
dummyobj.iv.num_trials_category.num_early_not_ex_trials = dummyobj.iv.num_trials_category.num_early_not_ex_trials + sObj.iv.num_trials_category.num_early_not_ex_trials;
dummyobj.iv.num_trials_category.num_rew_not_ex_trials = dummyobj.iv.num_trials_category.num_rew_not_ex_trials + sObj.iv.num_trials_category.num_rew_not_ex_trials;
dummyobj.iv.num_trials_category.num_ITI_not_ex_trials = dummyobj.iv.num_trials_category.num_ITI_not_ex_trials + sObj.iv.num_trials_category.num_ITI_not_ex_trials;
dummyobj.iv.num_trials_category.note = 'numbers accurate if no additional excl taken in v3x';
%
%   Running mean of all the datasets for each bins
%
if iset == 1 && ~strcmpi(gfitStyle{1}, 'none') 
	% 	To be used in running ave (see below): Initialize our counters for the number of trials in the dummyobj
	s1c = cellfun(@(x) x./nan, sNc, 'UniformOutput', 0);
	s1l = cellfun(@(x) x./nan, sNl, 'UniformOutput', 0);
	for ibin = 1:numel(s1c)
		if isempty(s1c{ibin})
			s1c{ibin} = s1c{1};
		end
		if isempty(s1l{ibin})
			s1l{ibin} = s1l{1};
		end
	end
end
if ~strcmpi(gfitStyle{1}, 'none') 
    if iset~=1
        s1c = dummyobj.n.s1c;
        s1l = dummyobj.n.s1l;
        % get back the data
        sNc_total = dummyobj.n.sNc_total;
        sNl_total = dummyobj.n.sNl_total;
    end
    for ibin = 1:nbins
    	if iset ~= 1
            if ~isempty(sNc{ibin})
	    		sNc_total{ibin} = nansum([sNc{ibin}; sNc_total{ibin}], 1);
                sNl_total{ibin} = nansum([sNl{ibin}; sNl_total{ibin}], 1);

                sNc_total{ibin}(sNc_total{ibin} == 0) = nan;
                sNl_total{ibin}(sNl_total{ibin} == 0) = nan;
            end
            nt_thissobj_thisbin = numel(sObj.ts.BinParams.trials_in_each_bin{ibin});
		    dummyobj.ts.BinParams.trials_in_each_bin{ibin} = dummyobj.ts.BinParams.trials_in_each_bin{ibin} + nt_thissobj_thisbin;
		end
		%
	    % new for 2023: update the lick times...
	    %
	    nlt_thisobj_thisbin = numel(sObj.ts.BinParams.lick_times_in_each_bin{ibin});
	    if nlt_thisobj_thisbin >0
		    dummyobj.ts.BinParams.lick_times_in_each_bin{ibin} = [dummyobj.ts.BinParams.lick_times_in_each_bin{ibin};sObj.ts.BinParams.lick_times_in_each_bin{ibin}];
		    dummyobj.ts.BinParams.lick_times_next_trial{ibin} = [dummyobj.ts.BinParams.lick_times_next_trial{ibin};sObj.ts.BinParams.lick_times_next_trial{ibin}];
		    dummyobj.ts.BinParams.lick_time_tp1_minus_tn{ibin} = [dummyobj.ts.BinParams.lick_time_tp1_minus_tn{ibin};sObj.ts.BinParams.lick_time_tp1_minus_tn{ibin}];
            if isfield(sObj.ts.BinParams, 'lick_times_previous_trial')
                dummyobj.ts.BinParams.lick_times_previous_trial{ibin} = [dummyobj.ts.BinParams.lick_times_previous_trial{ibin};sObj.ts.BinParams.lick_times_previous_trial{ibin}];
                dummyobj.ts.BinParams.lick_time_tn_minus_tprev1{ibin} = [dummyobj.ts.BinParams.lick_time_tn_minus_tprev1{ibin};sObj.ts.BinParams.lick_time_tn_minus_tprev1{ibin}];
            end
	    end
        % 
		% 	Fix the legend
		% 
		npos = strsplit(dummyobj.ts.BinParams.Legend_s.CLTA{ibin}, 'n='); 
		dummyobj.ts.BinParams.Legend_s.CLTA{ibin} = [npos{1}, 'n=', num2str(dummyobj.ts.BinParams.trials_in_each_bin{ibin})];
    	% 
    	% 	First, multiply each sObj bin by the number of samples so we can combine correctly
    	% 
        if divideByNTrialsPerBin && ~isempty(sNc{ibin}) && ~isempty(sNl{ibin})
            % 
            % 	Multirunning ave: must multiply each existing ave by its total components first, then divide by overall total
            % 		eg:
            % 			ave n1: nbar1 = sum(n1)/s1, where s1 is the number of samples in set n1
            % 			ave n2: nbar2 = sum(n2)/s2, where s2 is the number of samples in set n2
            % 			ave (n1, n2): [(s1 * nbar1) + (s2 * nbar2)]/(s1 + s2)
            % 						= [N1 + N2]
            % 
            % 	n1 is the set of trials already in dummyobj
            % 	n2 is the set of trials to be added from sObj
            % 
            s1c{ibin} = s1c{ibin}; % defined in last iter as # of trials in dummyobj
            s2c = sNc{ibin};

            if ~strcmp(dummyobj.iv.signaltype_, 'camera') && ~isfield(sObj.GLM, 'ChR2_s')
                assert([sum(sNc_total{ibin} == nansum([s1c{ibin}; s2c])) == numel(s1c{ibin})]); % debug
            elseif isfield(sObj.GLM, 'ChR2_s') && ~strcmp(dummyobj.iv.signaltype_, 'camera')
                warning('modified assertion for chr2 case--will fail otherwise because of chop - 7/27/2020')
            else
                
                if max(max(sNc{ibin})) == 1
                    warning('added 3/17/20-to solve problem with edges with no trials-seems to be ok')
                    s2c(isnan(s2c))=0;
                end
            end
            if ~isempty(sNc_total{ibin})
                N1c = [dummyobj.ts.BinnedData.CTA{1,ibin} .* s1c{ibin}]./sNc_total{ibin}; 
                N2c = [sObj.ts.BinnedData.CTA{1,ibin} .* s2c]./sNc_total{ibin};
                dummyobj.ts.BinnedData.CTA{1,ibin} = nansum([N1c; N2c]);
            else
                dummyobj.ts.BinnedData.CTA{1,ibin} = [];
            end


            s1l{ibin} = s1l{ibin}; % defined in last iter as # of trials in dummyobj
            s2l = sNl{ibin};
            % assert([sNc_total{ibin} == s1l(ibin) + s2l]); % debug
            N1l = [dummyobj.ts.BinnedData.LTA{1,ibin} .* s1l{ibin}]./sNl_total{ibin}; 
            N2l = [sObj.ts.BinnedData.LTA{1,ibin} .* s2l]./sNl_total{ibin};
            dummyobj.ts.BinnedData.LTA{1,ibin} = nansum([N1l; N2l]);

            %  Update the number of trials in the dummyobj:
            s1c{ibin} = sNc_total{ibin}; 
            s1l{ibin} = sNl_total{ibin}; 

        elseif ~divideByNTrialsPerBin && ~isempty(sNc{ibin}) && ~isempty(sNl{ibin})
				% 
				% 	If we don't want to normalize to the number of trials included in the bin, we just want to running average
				% 
				error('Obsolete! 6-20-19')
            nxt = sObj.ts.BinnedData.CTA{1,ibin}; % keeps nan in place
            dummyobj.ts.BinnedData.CTA{1,ibin} = nanmean([dummyobj.ts.BinnedData.CTA{1,ibin}; nxt]); 

            nxt = sObj.ts.BinnedData.LTA{1,ibin}; % keeps nan in place
            dummyobj.ts.BinnedData.LTA{1,ibin} = nanmean([dummyobj.ts.BinnedData.LTA{1,ibin}; nxt]); % ignores the nans  
        	
        else
%             disp(['				This bin was empty: ' num2str(ibin)]);
        end
    end
end
if strcmpi(Mode, 'paired-nLicksBaseline') || strcmpi(Mode, 'paired-nLicksBaseline-LOTA')|| strcmpi(Mode, 'custom'), nbins=nnbins; end
% send these forward to next iter...
dummyobj.n.sNc_total = sNc_total;
dummyobj.n.sNl_total = sNl_total;
dummyobj.n.s1c = s1c;
dummyobj.n.s1l = s1l;