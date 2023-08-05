% runningavetimeseries_movement -- built from v3x photometry sObj
% 
% 	We assume the sObj has everything we need. Now we grab the move controls...
% 
% grabMoveControls, n={gfitcell, binningMode, nbins, pad}
% grabMoveControls, n={{'multibaseline', 10}, 'times-lampoff', 68, 30000}
gfitStyle = obj.iv.n{1};
Mode = obj.iv.n{2};
nbins = obj.iv.n{3};
timePad = obj.iv.n{4};
stimMode = false; % if want to use stim mode in future, need to look here
%
sObj.addMoveControls;
% check if our dummy objs exist
if ~isfield(obj.analysis,'onFileNo')
	obj.analysis.onFileNo.gfit = 0;
	obj.analysis.onFileNo.X = 0;
	obj.analysis.onFileNo.tdt = 0;
	obj.analysis.onFileNo.EMG = 0;
end

hasPhot = isfield(sObj.GLM, 'gfit') && isfield(sObj.GLM, 'gfitStyle') && strcmp(sObj.GLM.gfitStyle{1},gfitStyle{1}) && sObj.GLM.gfitStyle{2} == gfitStyle{2};
hasX = isfield(sObj.GLM, 'gX');
hastdt = isfield(sObj.GLM, 'tdt') && isfield(sObj.GLM, 'gfitStyle') && strcmp(sObj.GLM.gfitStyle{1},gfitStyle{1}) && sObj.GLM.gfitStyle{2} == gfitStyle{2};
% if above throws errors, it's because you didnt use gfitStyle = {multibaseline,10}
hasEMG = isfield(sObj.GLM, 'EMG');

disp(['>> Detected: gfit ' num2str(hasPhot), ' | gX ' num2str(hasX), ' | tdt ', num2str(hastdt), ' | EMG ', num2str(hasEMG)])



% now we need to see what movement control channels we actually got
% 
% 	Now, execute binning...
% 
if strcmpi(stimMode, 'stim')
	disp('		Binning for Stim trials')
	if ~isfield(sObj.GLM, 'stimTrials')
		sObj.GLM.stimTrials = [];
	end
end

% sObj.getflickswrtc

% if sObj.Plot.samples_per_ms >1
% 	warning(['expected 1 sample/ms for gfit. got ' num2str(sObj.Plot.samples_per_ms) '. correcting'])
% 	sps = 1;
% else
% 	sps = sObj.Plot.samples_per_ms;
% end

if hasPhot
	obj.analysis.onFileNo.gfit = obj.analysis.onFileNo.gfit+1;
	if obj.analysis.onFileNo.gfit == 1
		% make a dummy obj
		obj.analysis.gfit = {};
		obj.analysis.gfit.iv.trialsIncluded = {'off'};
        obj.analysis.gfit.iv.num_trials = 0;
        obj.analysis.gfit.iv.num_trials_category.num_no_ex_trials = 0;
        obj.analysis.gfit.iv.num_trials_category.num_no_rxn_or_ex_trials = 0;
        obj.analysis.gfit.iv.num_trials_category.num_rxn_not_ex_trials = 0;
        obj.analysis.gfit.iv.num_trials_category.num_early_not_ex_trials = 0;
        obj.analysis.gfit.iv.num_trials_category.num_rew_not_ex_trials = 0;
        obj.analysis.gfit.iv.num_trials_category.num_ITI_not_ex_trials = 0;
        obj.analysis.gfit.iv.signaltype_ = 'photometry';
		obj.analysis.gfit.GLM = {};
	end
	% sObj.Plot.samples_per_ms = sps;
	Z = sObj.GLM.gfit;
	obj.analysis.gfit = obj.getavetimeseries(obj.analysis.gfit,sObj, Z, Mode, nbins, timePad, stimMode,obj.analysis.onFileNo.gfit);
end
if hasX
	obj.analysis.onFileNo.X = obj.analysis.onFileNo.X+1;
	if obj.analysis.onFileNo.X == 1
		% make a dummy obj
		obj.analysis.X = {};
		obj.analysis.X.iv.trialsIncluded = {'off'};
        obj.analysis.X.iv.num_trials = 0;
        obj.analysis.X.iv.num_trials_category.num_no_ex_trials = 0;
        obj.analysis.X.iv.num_trials_category.num_no_rxn_or_ex_trials = 0;
        obj.analysis.X.iv.num_trials_category.num_rxn_not_ex_trials = 0;
        obj.analysis.X.iv.num_trials_category.num_early_not_ex_trials = 0;
        obj.analysis.X.iv.num_trials_category.num_rew_not_ex_trials = 0;
        obj.analysis.X.iv.num_trials_category.num_ITI_not_ex_trials = 0;
        obj.analysis.X.iv.signaltype_ = 'accelerometer';
		obj.analysis.X.GLM = {};
	end
% 	sObj.Plot.samples_per_ms = sps;
	% Z = sObj.GLM.gX(1:2*sps:end);
	Z = sObj.GLM.gX(1:2:end);
	obj.analysis.X = obj.getavetimeseries(obj.analysis.X,sObj, Z, Mode, nbins, timePad, stimMode,obj.analysis.onFileNo.X);
end
if hastdt
	obj.analysis.onFileNo.tdt = obj.analysis.onFileNo.tdt+1;
	if obj.analysis.onFileNo.tdt == 1
		% make a dummy obj
		obj.analysis.tdt = {};
		obj.analysis.tdt.iv.trialsIncluded = {'off'};
        obj.analysis.tdt.iv.num_trials = 0;
        obj.analysis.tdt.iv.num_trials_category.num_no_ex_trials = 0;
        obj.analysis.tdt.iv.num_trials_category.num_no_rxn_or_ex_trials = 0;
        obj.analysis.tdt.iv.num_trials_category.num_rxn_not_ex_trials = 0;
        obj.analysis.tdt.iv.num_trials_category.num_early_not_ex_trials = 0;
        obj.analysis.tdt.iv.num_trials_category.num_rew_not_ex_trials = 0;
        obj.analysis.tdt.iv.num_trials_category.num_ITI_not_ex_trials = 0;
        obj.analysis.tdt.iv.signaltype_ = 'photometry';
		obj.analysis.tdt.GLM = {};
	end
	% sObj.Plot.samples_per_ms = sps;
	Z = sObj.GLM.tdt;
	obj.analysis.tdt = obj.getavetimeseries(obj.analysis.tdt,sObj, Z, Mode, nbins, timePad, stimMode,obj.analysis.onFileNo.tdt);
end
if hasEMG
	obj.analysis.onFileNo.EMG = obj.analysis.onFileNo.EMG+1;
	if obj.analysis.onFileNo.EMG == 1
		% make a dummy obj
		obj.analysis.EMG = {};
		obj.analysis.EMG.iv.trialsIncluded = {'off'};
        obj.analysis.EMG.iv.num_trials = 0;
        obj.analysis.EMG.iv.num_trials_category.num_no_ex_trials = 0;
        obj.analysis.EMG.iv.num_trials_category.num_no_rxn_or_ex_trials = 0;
        obj.analysis.EMG.iv.num_trials_category.num_rxn_not_ex_trials = 0;
        obj.analysis.EMG.iv.num_trials_category.num_early_not_ex_trials = 0;
        obj.analysis.EMG.iv.num_trials_category.num_rew_not_ex_trials = 0;
        obj.analysis.EMG.iv.num_trials_category.num_ITI_not_ex_trials = 0;
        obj.analysis.EMG.iv.signaltype_ = 'EMG';
		obj.analysis.EMG.GLM = {};
	end
% 	sObj.Plot.samples_per_ms = sps;
	Z = sObj.GLM.EMG(1:2:end);%*sps:end);
	obj.analysis.EMG = obj.getavetimeseries(obj.analysis.EMG,sObj, Z, Mode, nbins, timePad, stimMode,obj.analysis.onFileNo.EMG);
end

