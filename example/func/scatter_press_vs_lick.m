% scatter_press_vs_lick(PETH, 'Title', 2)
function scatter_press_vs_lick(PETH, titletext, sigma_threshold, moveEffectWindow, colorByProbePos, useCol)% Sorted stim PETH
	if nargin < 6
		useCol = true;
    end
    if nargin < 5
		colorByProbePos = true;
	end
	if nargin < 4
		moveEffectWindow = [-0.5, 0];
	end

	if colorByProbePos
		for i = 1:length(PETH)
			[PETH(i).ProbeRow, PETH(i).ProbeCol, PETH(i).ProbeNRows, PETH(i).ProbeNCols] = get_channel_pos_on_probe(PETH(i).ExpName, PETH(i).Channel);
% 			switch PETH(i).ProbeCol
% 				case 1
% 					PETH(i).ProbeColor = [1 0 0];
% 				case 2
% 					PETH(i).ProbeColor = [1 .5 0];
% 				case 3
% 					PETH(i).ProbeColor = [.5 1 0];
% 				case 4
% 					PETH(i).ProbeColor = [0 1 0];
%             end
            if useCol
                f = PETH(i).ProbeCol / PETH(i).ProbeNCols;
                g = PETH(i).ProbeRow / PETH(i).ProbeNRows;
            else
                f = PETH(i).ProbeRow / PETH(i).ProbeNRows;
                g = PETH(i).ProbeCol / PETH(i).ProbeNCols;
            end
            PETH(i).ProbeColor = [1-f^2, f^2, 0];
			PETH(i).ProbeAlpha = 0.5 + 0.5 * g;
		end
	end

	tMove = PETH(1).Time;
	pethPress = transpose(reshape([PETH.Press], [length(tMove), length(PETH)]));
	pethLick = transpose(reshape([PETH.Lick], [length(tMove), length(PETH)]));
	pethPressNorm = TetrodeRecording.NormalizePETH(pethPress, 'Method', 'zscore', 'BaselineSamples', tMove < -2 & tMove > -4);
	pethLickNorm = TetrodeRecording.NormalizePETH(pethLick, 'Method', 'zscore', 'BaselineSamples', tMove < -2 & tMove > -4);


	% Find Max effect
	for i = 1:length(PETH)
		normPress = pethPressNorm(i, tMove>=moveEffectWindow(1) & tMove <= moveEffectWindow(2));
        PETH(i).MaxPressEffect = mean(normPress);
% 		[~, iMaxPressEffect] = max(abs(normPress));
% 		PETH(i).MaxPressEffect = normPress(iMaxPressEffect);

		normLick = pethLickNorm(i, tMove>=moveEffectWindow(1) & tMove <= moveEffectWindow(2));
        PETH(i).MaxLickEffect = mean(normLick);
% 		[~, iMaxLickEffect] = max(abs(normLick));
% 		PETH(i).MaxLickEffect = normLick(iMaxLickEffect);
	end

	maxPressEffect = [PETH.MaxPressEffect];
	maxLickEffect = [PETH.MaxLickEffect];
	f = figure;
	ax = axes(f);
	hold on
	if colorByProbePos
        probeColors = vertcat(PETH.ProbeColor);
        if useCol
            for iShank = 1:4
                % Plot units by shank
                sel = [PETH.ProbeCol] == iShank;
                hItems(iShank) = scatter(ax, maxPressEffect(sel), maxLickEffect(sel), 30, probeColors(sel, :), 'filled', 'DisplayName', sprintf('shank %d - %d units', iShank, sum(sel)));
            end
        else
            hItems = scatter(ax, maxPressEffect, maxLickEffect, 30, probeColors, 'filled', 'DisplayName', sprintf('%d units', length(PETH)));
        end
	else
		% Accentuate responsive units
		sel = abs(maxPressEffect) > sigma_threshold & abs(maxLickEffect) > sigma_threshold;
		hLine1 = plot(ax, maxPressEffect(~sel), maxLickEffect(~sel), 'o', 'MarkerSize', 4, 'MarkerEdgeColor', '#808080', 'DisplayName', sprintf('%d unresponsive units', sum(~sel)));
		hLine2 = plot(ax, maxPressEffect(sel), maxLickEffect(sel), 'o', 'MarkerSize', 4, 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'black', 'DisplayName', sprintf('%d responsive units', sum(sel)));
		hItems = [hLine1, hLine2];
	end
	plot(ax, ax.XLim, [0, 0], 'k:')
	plot(ax, [0, 0], ax.YLim, 'k:')
	hold off
	xlabel(sprintf('Mean PRESS effect (\\sigma) ([%gs, %gs])', moveEffectWindow(1), moveEffectWindow(2)), 'FontSize', 14)
	ylabel(sprintf('Mean LICK effect (\\sigma) ([%gs, %gs])', moveEffectWindow(1), moveEffectWindow(2)), 'FontSize', 14)
	title(sprintf('%s', titletext), 'FontSize', 14)
	legend(hItems, 'Location', 'northwest', 'FontSize', 14)
