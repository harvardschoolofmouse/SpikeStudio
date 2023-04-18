% plot_stim_response(PETHStim, 'D1-ChR2', 2, 0.025, 0.1, [-0.1, 0.2])
function plot_stim_response(PETHStim, titletext, sigma_threshold, latency_threshold, stim_length, xrange, stimType)% Sorted stim PETHStim
	
	% Sorted stim PETHStim
	for i = 1:length(PETHStim)
		Stim = PETHStim(i).Stim;
		if nargin < 7
			[~, iStimType] = max([Stim.NumTrains]);
		else
			iStimType = find([Stim.TrainType] == stimType);
			if isempty(iStimType)
				error('Cannot find stim type %d', stimType)
			end
			stim_length = Stim(iStimType).PulseOff(1) - Stim(iStimType).PulseOn(1);
		end
		sel = Stim(iStimType).Timestamps <= xrange(2);
		t = Stim(iStimType).Timestamps(sel);
		pethStim(i, 1:length(t)) = Stim(iStimType).SpikeRate(sel);
	end
	%%
	[pethSorted, ~, ~] =  TetrodeRecording.SortPETH(pethStim, 'Method', 'latency', 'LatencyThreshold', 0.675);
	pethSortedNorm = TetrodeRecording.NormalizePETH(pethSorted, 'Method', 'zscore', 'BaselineSamples', t < 0);


	figure()
	axes('FontSize', 14)
	hold on
	sel = t >= xrange(1);
	for i = 1:size(pethSortedNorm, 1)
		isDec = any(pethSortedNorm(i, t>0 & t <= latency_threshold) < -sigma_threshold);
	    isInc = any(pethSortedNorm(i, t>0 & t <= latency_threshold) > sigma_threshold);
		if isDec
			h = plot(t(sel)*1000, pethSortedNorm(i, sel), 'color', [.2, .8, .2, 0.67]);
	    elseif isInc
			h = plot(t(sel)*1000, pethSortedNorm(i, sel), 'color', [.8, .2, .2, 0.67]);
	    else
			h = plot(t(sel)*1000, pethSortedNorm(i, sel), 'color', [.2, .2, .2, 0.67]);
	    end
	    h.DisplayName = num2str(i);
	end
	max_height = max(max(pethSortedNorm(:, sel))) + 5;
	plot([0, stim_length * 1000], [max_height, max_height], 'b', 'LineWidth', 3)
	hold off
	title(char(sprintf("%s stim response of %d SNr units", titletext, size(pethStim, 1))), 'FontSize', 14)
	xlabel("Time (ms)", 'FontSize', 14)
	ylabel("Spike rate (z-score)", 'FontSize', 14)
	xlim(xrange * 1000)
