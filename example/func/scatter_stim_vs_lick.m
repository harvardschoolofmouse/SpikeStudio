function scatter_stim_vs_lick(PETH, titletext, sigma_threshold, stimType, moveEffectWindow, stimEffectWindow, colorByProbePos)% Sorted stim PETH
	if nargin < 7
		colorByProbePos = true;
	end
	if nargin < 6
		stimEffectWindow = [0, 0.02];
	end
	if nargin < 5
		moveEffectWindow = [-2, 0];
	end

	if colorByProbePos
		for i = 1:length(PETH)
			[PETH(i).ProbeRow, PETH(i).ProbeCol] = get_channel_pos_on_probe(PETH(i).ExpName, PETH(i).Channel);
			switch PETH(i).ProbeCol
				case 1
					PETH(i).ProbeColor = [1 0 0];
				case 2
					PETH(i).ProbeColor = [1 .5 0];
				case 3
					PETH(i).ProbeColor = [.5 1 0];
				case 4
					PETH(i).ProbeColor = [0 1 0];
			end
			PETH(i).ProbeAlpha = 0.5 + 0.5 * (PETH(i).ProbeRow - 1) / 7;
		end
	end

	for i = 1:length(PETH)
		Stim = PETH(i).Stim;
		% Add up all stim types
		if nargin < 4
			sel = Stim(1).Timestamps <= 0.2;
			t = Stim(1).Timestamps(sel);
			thisPeth = zeros(1, sum(sel));
			for j = 1:length(Stim)
				thisPeth = thisPeth + Stim(j).SpikeRate(sel) * Stim(j).NumTrains;
			end
			pethStim(i, 1:length(t)) = thisPeth ./ sum([Stim.NumTrains]);
		% Use specific stim type
		else
			iStimType = find([Stim.TrainType] == stimType);
			if isempty(iStimType)
				error('Cannot find stim type %d', stimType)
			end
			sel = Stim(iStimType).Timestamps <= 0.2;
			t = Stim(iStimType).Timestamps(sel);
			pethStim(i, 1:length(t)) = Stim(iStimType).SpikeRate(sel);
		end
	end

	% Normalize rates
	pethStimNorm = TetrodeRecording.NormalizePETH(pethStim, 'Method', 'zscore', 'BaselineSamples', t < 0);

	tLick = PETH(1).Time;
	pethLick = transpose(reshape([PETH.Lick], [length(tLick), length(PETH)]));
	pethLickNorm = TetrodeRecording.NormalizePETH(pethLick, 'Method', 'zscore', 'BaselineSamples', tLick < -2 & tLick > -4);

	% Find Max effect
	for i = 1:length(PETH)
		normStim = pethStimNorm(i, t >= stimEffectWindow(1) & t <= stimEffectWindow(2));
		[~, iMaxStimEffect] = max(abs(normStim));
		PETH(i).MaxStimEffect = normStim(iMaxStimEffect);

		normLick = pethLickNorm(i, tLick >= moveEffectWindow(1) & tLick <= moveEffectWindow(2));
		[~, iMaxLickEffect] = max(abs(normLick));
		PETH(i).MaxLickEffect = normLick(iMaxLickEffect);
	end

	maxLickEffect = [PETH.MaxLickEffect];
	maxStimEffect = [PETH.MaxStimEffect];
	sel = abs(maxLickEffect) > sigma_threshold & abs(maxStimEffect) > sigma_threshold;
	f = figure;
	ax = axes(f);
	hold on
	if colorByProbePos
        probeColors = vertcat(PETH.ProbeColor);
		for iShank = 1:4
			% Plot units by shank
			sel = [PETH.ProbeCol] == iShank;
			hItems(iShank) = scatter(ax, maxLickEffect(sel), maxStimEffect(sel), 30, probeColors(sel, :), 'filled', 'DisplayName', sprintf('shank %d - %d units', iShank, sum(sel)));
		end
	else
		hLine1 = plot(ax, maxLickEffect(~sel), maxStimEffect(~sel), 'o', 'MarkerEdgeColor', '#808080', 'DisplayName', sprintf('%d unresponsive units', sum(~sel)));
		hLine2 = plot(ax, maxLickEffect(sel), maxStimEffect(sel), 'o', 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'black', 'DisplayName', sprintf('%d responsive units', sum(sel)));
		hItems = [hLine1, hLine2];
	end
	plot(ax, ax.XLim, [0, 0], 'k:')
	plot(ax, [0, 0], ax.YLim, 'k:')
	hold off
	xlabel(sprintf('Peak LICK effect (\\sigma) ([%gs, %gs])', moveEffectWindow(1), moveEffectWindow(2)), 'FontSize', 14)
	ylabel(sprintf('Peak STIM effect (\\sigma) ([%gms, %gms]', stimEffectWindow(1)*1e3, stimEffectWindow(2)*1e3), 'FontSize', 14)
	title(sprintf('%s', titletext), 'FontSize', 14)
	legend(hItems, 'FontSize', 14)
