classdef AcuteRecording < handle
    properties
        expName = ''
        path = ''
        strain = ''
        stim = struct([])
        probeMap = struct([])
        bsr = struct([])
        bmrPress = struct([])
        bmrLick = struct([])
        conditions = struct([])
        stats = []
        statsInfo = struct([])
        statsPress = []
        statsLick = []
        statsInfoPress = struct([])
        statsInfoLick = struct([])
    end

    methods
        function obj = AcuteRecording(tr, strain)
            obj.strain = strain;

            splitPath = strsplit(tr.Path, '\');
            path = strjoin(splitPath(1:end-2), '\');
            if tr.Path(1) == '\'
                path = ['\', path];
            end
            obj.path = path;

            expName = strsplit(tr.GetExpName(), '_');
            obj.expName = strjoin(expName(1:2), '_');
        end

        function label = getLabel(obj)
            if length(obj) == 1
                label = sprintf('%s (%s)', obj.strain, obj.expName);
                return
            else
                nAnimals = length(unique(obj.getAnimalName()));
                strains = unique({obj.strain});
                if length(strains) == 1
                    label = sprintf('%s (%g animals, %g sessions)', strains{1}, nAnimals, length(obj));
                    return
                else
                    label = sprintf('%g strains, %g animals, %g sessions', length(strains), nAnimals, length(obj));
                end
            end
        end

        function animalName = getAnimalName(obj)
            if length(obj) == 1
                splitExpName = strsplit(obj.expName, '_');
                animalName = splitExpName{1};
            else
                animalName = arrayfun(@(x) x.getAnimalName(), obj, 'UniformOutput', false);
            end
        end

        function save(obj, varargin)
            p = inputParser();
            p.addOptional('Prefix', 'ar_', @ischar)
            p.addOptional('Path', '', @ischar)
            p.parse(varargin{:})
            folder = sprintf('%s\\AcuteRecording', p.Results.Path);
            if ~isdir(folder)
                mkdir(folder)
            end
            file = sprintf('%s\\%s%s.mat', folder, p.Results.Prefix, obj.expName);
            tTic = tic();
            fprintf(1, 'Saving to file %s...', file)
            save(file, 'obj', '-v7.3');
            f = dir(file);
            fprintf(1, '(%.2fsec, %.2fMB)\n', toc(tTic), f.bytes*1e-6)
        end

        function stim = extractAllPulses(obj, tr, varargin)
            p = inputParser();
            p.addRequired('TetrodeRecording', @(x) isa(x, 'TetrodeRecording'))
            p.addOptional('FirstFiber', 'B', @(x) ismember(x, {'A', 'B'}))
            p.addOptional('FirstLight', 0.1, @(x) isnumeric(x) && length(x) == 1 && x > 0)
            p.parse(tr, varargin{:})
            tr = p.Results.TetrodeRecording;
            firstFiber = p.Results.FirstFiber;
            firstLight = p.Results.FirstLight;

            stim.calibration = obj.importCalibrationData();
            refPower = stim.calibration.(['Power_', firstFiber]);
            refLight = stim.calibration.(['Light_', firstFiber]);
            refGalvo = stim.calibration.(['Galvo_', firstFiber]);
            refPower = refPower(find(refLight == firstLight, 1));
            refGalvo = refGalvo(find(refLight == firstLight, 1));

            [stim.power, stim.galvo, ~, ~] = AcuteRecording.extractPulse(tr.DigitalEvents.LaserOn, tr.DigitalEvents.LaserOff, tr.AnalogIn.Timestamps, tr.AnalogIn.Data, 1);
            assert(stim.galvo == refGalvo);

            stim.powerCorrection = refPower - stim.power;

            nPulses = length(tr.DigitalEvents.LaserOn);
            stim.tOn = NaN(nPulses, 1);
            stim.tOff = NaN(nPulses, 1);
            stim.power = NaN(nPulses, 1);
            stim.galvo = NaN(nPulses, 1);
            stim.dvRank = NaN(nPulses, 1);
            stim.mlRank = NaN(nPulses, 1);
            stim.fiber = repmat('?', nPulses, 1);
            stim.light = NaN(nPulses, 1);
            stim.powerError = NaN(nPulses, 1);
            
            % Trim analog data where laser was off
            t = tr.AnalogIn.Timestamps;
            data = tr.AnalogIn.Data;
            sel = data(1, :) > 1000;
            t = t(sel);
            data = data(:, sel);
            
            for iPulse = 1:nPulses
                [stim.power(iPulse), stim.galvo(iPulse), stim.tOn(iPulse), stim.tOff(iPulse)] = AcuteRecording.extractPulse(tr.DigitalEvents.LaserOn, tr.DigitalEvents.LaserOff, t, data, iPulse, stim.powerCorrection);
                [stim.light(iPulse), stim.fiber(iPulse), stim.powerError(iPulse)] = AcuteRecording.findMatchingCalibration(stim.calibration, stim.power(iPulse), stim.galvo(iPulse));
            end
            
            isFiberA = stim.fiber == 'A';
            isFiberB = ~isFiberA;
            stim.mlRank(isFiberA) = 1;
            stim.mlRank(isFiberB) = 2;
            [~, stim.dvRank(isFiberA)] = ismember(abs(stim.galvo(isFiberA)), unique(abs(stim.galvo(isFiberA))));
            [~, stim.dvRank(isFiberB)] = ismember(abs(stim.galvo(isFiberB)), unique(abs(stim.galvo(isFiberB))));
            
            % Figure out iTrain and iPulseInTrain
            edges = transpose([tr.DigitalEvents.GalvoOn(:), tr.DigitalEvents.GalvoOff(:)]);
            edges = edges(:);
            [N, ~, bins] = histcounts(stim.tOn, edges); % Odd bins are in train, 1 -> 1st train, 3 -> 2nd, 5 -> 3rd, k -> (k + 1)/2
            stim.train = (bins + 1) / 2;
            N = N(1:2:end);
            assert(all(N>0), 'Not implemented: Handling trains with zero pulses.')
            stim.pulse = zeros(nPulses, 1);
            i = 0;
            for iTrain = 1:length(N)
                n = N(iTrain);
                stim.pulse(i + 1:i + n) = 1:n;
                i = i + n;
            end

            stim.duration = round((stim.tOff - stim.tOn) .* 1000) ./ 1000;

            obj.stim = stim;
        end

        function calibrationData = importCalibrationData(obj)
            filename = sprintf('%s\\GalvoCalibration_%s.csv', obj.path, obj.expName);

            % Set up the Import Options and import the data
            opts = delimitedTextImportOptions("NumVariables", 7);

            % Specify range and delimiter
            opts.DataLines = [2, Inf];
            opts.Delimiter = ",";

            % Specify column names and types
            opts.VariableNames = ["Light_A", "Power_A", "Galvo_A", "Light_B", "Power_B", "Galvo_B", "Var7"];
            opts.SelectedVariableNames = ["Light_A", "Power_A", "Galvo_A", "Light_B", "Power_B", "Galvo_B"];
            opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "string"];

            % Specify file level properties
            opts.ExtraColumnsRule = "ignore";
            opts.EmptyLineRule = "read";

            % Specify variable properties
            opts = setvaropts(opts, "Var7", "WhitespaceRule", "preserve");
            opts = setvaropts(opts, "Var7", "EmptyFieldRule", "auto");

            % Import the data
            calibrationData = readtable(filename, opts);
        end      

        function plotPowerError(obj)
            fig = figure();
            ax = axes(fig);
            hold(ax, 'on');
            plot(obj.stim.power, 'k', 'DisplayName', 'Recorded');
            plot(obj.stim.power - obj.stim.powerError, 'r', 'DisplayName', 'Corrected');
            hold(ax, 'off');
            legend(ax);
        end

        function probeMap = importProbeMap(obj, frontOrBack, varargin)
            p = inputParser();
            p.addRequired('FrontOrBack', @(x) ischar(x) && ismember(x, {'front', 'back'})); % Whether probe is anterior (front) or posterior (back) to the headstage. Usually this is back, unless recording in anterior SNr, and probe needed to be reversed (front) to make space for fiber optics.
            p.addOptional('ML', 1300, @isnumeric); % Center of probe. Negative for left hemisphere.
            p.addOptional('DV', -4600, @isnumeric); % From surface of brain, not bregma. Bregma is usually 200um above surface here.
            p.addOptional('AP', -3280, @isnumeric);
            p.addParameter('DVOffset', -200, @isnumeric); % Distance from bregma to surface of brain at SNr.
            p.parse(frontOrBack, varargin{:});
            front = strcmpi(p.Results.FrontOrBack, 'front');
            back = ~front;
            ml = p.Results.ML;
            dv = p.Results.DV + p.Results.DVOffset;
            ap = p.Results.AP;
            left = ml < 0;
            right = ~left;
            
            load('128DN_bottom.mat', 's');
            % Determine whether to flip the probe x positions/shank number
            % For the probe, when viewed from the front (black epoxy visible), shank=1, x=0 is left-most shank, z=0 is deepest in brain.
            % For our convention, we want to convert to brain coordinates (ml/dv) (shank=1 is medial)
            flipDir = 1;
            if right
                flipDir = flipDir * -1;
            end
            if back
                flipDir = flipDir * -1;
            end
            
            if flipDir == -1
                s.shaft = 5 - s.shaft;
                s.x = 450 - s.x;
            end
            
            map = zeros(32, 4);
            for iShaft = 1:4
                inShaft = s.shaft == iShaft;
                [~, I] = sort(s.z(inShaft), 'descend');
                channels = find(inShaft);
                channels = channels(I);
                map(:, iShaft) = channels;
            end
            
            probeMap.channel = s.channels + 1;
            probeMap.ml = ml - 225 + s.x;
            probeMap.dv = dv + s.tipelectrode + s.z;
            probeMap.ap = repmat(ap, size(s.x));
            probeMap.shaft = s.shaft;
            probeMap.map = map;
            
            obj.probeMap = probeMap;
        end

        function coords = getProbeCoords(obj, channels)
            if nargin < 2
                channels = [];
            end

            if length(obj) > 1
                coords = cell(length(obj), 1);
                for i = 1:length(obj)
                    coords{i} = obj(i).getProbeCoords(channels);
                end
                coords = cat(1, coords{:});
                return
            end
            
            if isempty(channels)
                channels = [obj.bsr.channel];
            end

            map = obj.probeMap;
            coords = zeros(length(channels), 3);
            for i = 1:length(channels)
                I = find(map.channel == channels(i), 1);
                assert(~isempty(I))
                coords(i, 1) = map.ml(I);
                coords(i, 2) = map.dv(I);
                coords(i, 3) = map.ap(I);
            end
        end

        function varargout = binMoveResponse(obj, tr, moveType, varargin)
            p = inputParser();
            p.addRequired('TetrodeRecording', @(x) isa(x, 'TetrodeRecording'))
            p.addRequired('MoveType', @(x) ismember(lower(x), {'press', 'lick'}))
            p.addOptional('Channels', [], @isnumeric);
            p.addOptional('Units', [], @isnumeric);
            p.addParameter('BinWidth', 0.1, @isnumeric); % Bin width in seconds
            p.addParameter('Window', [-6, 1]); % Additional seconds before and after tMove
            p.addParameter('BaselineWindow', [-6, -2]); % Window used for normalization, relative to move time
            p.addParameter('Store', false, @islogical);
            p.parse(tr, moveType, varargin{:})
            tr = p.Results.TetrodeRecording;
            moveType = p.Results.MoveType;
            channels = p.Results.Channels;
            units = p.Results.Units;
            binWidth = p.Results.BinWidth;
            window = p.Results.Window;
            baselineWindow = p.Results.BaselineWindow;
            store = p.Results.Store;

            % Do all channels
            if isempty(channels)
                channels = [tr.Spikes.Channel];
            end
            
            nChannels = length(channels);
            nUnitsInChannel = zeros(nChannels, 1);
            for i = 1:nChannels
                nUnitsInChannel(i) = max(tr.Spikes(channels(i)).Cluster.Classes) - 1;
            end
            assert(isempty(units) || max(nUnitsInChannel) >= max(units), 'Requested units (%s) exceeds total number of units (%g) in data.', num2str(units), max(units));
            
            if isempty(units)
                nUnits = sum(nUnitsInChannel);
            else
                nUnits = length(units) * nChannels;
            end
            
            bmr(nUnits) = struct('expName', '', 'channel', [], 'unit', [], 't', [], 'tRight', [], 'spikeRates', [], 'normalizedSpikeRates', [], 'trialLength', []);
            m = zeros(nUnits, 1);
            s = zeros(nUnits, 1);

            tRef = tr.DigitalEvents.CueOn;
            switch lower(moveType)
                case 'press'
                    tMove = tr.DigitalEvents.PressOn;
                    tExclude = sort([tr.DigitalEvents.LickOn, tr.DigitalEvents.RewardOn]);
                case 'lick'
                    tMove = tr.DigitalEvents.LickOn;
                    tExclude = sort([tr.DigitalEvents.PressOn, tr.DigitalEvents.RewardOn]);
                otherwise
                    error('Unrecognized move type: %s', lower(moveType))
            end

            [tRef, tMove] = tr.FindFirstInTrial(tRef, tMove, tExclude);

            % Bin spikes
            nTrials = length(tMove);
            t = window(1):binWidth:window(2);
            tBaseline = baselineWindow(1):binWidth:baselineWindow(2);
            nBins = length(t) - 1;
            nBaselineBins = length(tBaseline) - 1;

            iUnit = 0;
            for iChn = 1:nChannels
                channel = channels(iChn);
                
                if isempty(units)
                    selUnits = 1:nUnitsInChannel(iChn);
                else
                    selUnits = units;
                end
                
                for iUnitInChannel = 1:length(selUnits)
                    iUnit = iUnit + 1;
                    unit = selUnits(iUnitInChannel);

                    % Extract unit spike times
                    sel = tr.Spikes(channel).Cluster.Classes == unit;
                    spikeTimes = tr.Spikes(channel).Timestamps(sel);

                    % Stats for selecting units (session-mean firing rate 
                    spikeRates = histcounts(spikeTimes, spikeTimes(1):binWidth:spikeTimes(end)) ./ binWidth;
                    m(iUnit) = mean(spikeRates);
                    s(iUnit) = mad(spikeRates, 0) / 0.6745;
                    bmr(iUnit).expName = obj.expName;
                    bmr(iUnit).channel = channel;
                    bmr(iUnit).unit = unit;
                    bmr(iUnit).spikeRates = zeros(nTrials, nBins);
                    bmr(iUnit).normalizedSpikeRates = zeros(nTrials, nBins);
                    bmr(iUnit).trialLength = tMove - tRef;
                    for iTrial = 1:nTrials
                        edges = tMove(iTrial) + window(1):binWidth:tMove(iTrial) + window(2);
                        baselineEdges = tMove(iTrial) + baselineWindow(1):binWidth:tMove(iTrial) + baselineWindow(2);
                        bmr(iUnit).tRight = edges(2:end) - tMove(iTrial);
                        bmr(iUnit).t = (edges(1:end-1) + edges(2:end))/2 - tMove(iTrial);
                        bmr(iUnit).spikeRates(iTrial, :) = histcounts(spikeTimes, edges) ./ binWidth;
                        baselineSpikeRates = histcounts(spikeTimes, baselineEdges) ./ binWidth;
                        % Normalize by substracting mean norm window and dividing by global MAD
                        bmr(iUnit).normalizedSpikeRates(iTrial, :) = (bmr(iUnit).spikeRates(iTrial, :) - mean(baselineSpikeRates)) ./ s(iUnit);
                    end
                end
            end

            if store
                switch lower(moveType)
                    case 'press'
                        obj.bmrPress = bmr;
                    case 'lick'
                        obj.bmrLick = bmr;
                end
            end

            varargout = {bmr, m, s};
        end

        function stats = summarizeMoveResponse(obj, bmrOrType, varargin)
            % stats = ar.summarizeMoveResponse('press', 'peak', [-1, 0], 'AllowedTrialLength', [2, Inf])
            p = inputParser();
            if ischar(bmrOrType)
                p.addRequired('MoveType', @(x) ismember(lower(x), {'press', 'lick'}))
            else
                p.addRequired('BinnedMoveResponse', @isstruct)
            end
            p.addOptional('Method', 'peak', @(x) ismember(x, {'peak', 'mean'}));
            p.addOptional('Window', [-1, 0], @(x) isnumeric(x) && length(x) == 2);
            p.addParameter('AllowedTrialLength', [0, Inf], @(x) isnumeric(x) && length(x) == 2);
            p.addParameter('Store', false, @islogical);
            p.parse(bmrOrType, varargin{:});

            if ischar(bmrOrType)
                switch lower(p.Results.MoveType)
                    case 'press'
                        bmr = obj.bmrPress;
                    case 'lick'
                        bmr = obj.bmrLick;
                    otherwise
                        error()
                end
            else
                bmr = p.Results.BinnedMoveResponse;
            end

            nUnits = length(bmr);
            stats = NaN(nUnits, 1);
            for i = 1:length(bmr)
                sel = bmr(i).trialLength >= p.Results.AllowedTrialLength(1) & bmr(i).trialLength <= p.Results.AllowedTrialLength(2);
                meanNSR = mean(bmr(i).normalizedSpikeRates(sel, :), 1);
                stats(i, :) = AcuteRecording.summarizeMeanSpikeRates(meanNSR, bmr(i).t, p.Results.Method, p.Results.Window);
            end

            if p.Results.Store && isfield(p.Results, 'MoveType')
                switch lower(p.Results.MoveType)
                    case 'press'
                        obj.statsPress = stats;
                        obj.statsInfoPress = struct('Method', p.Results.Method, 'Window', p.Results.Window, 'AllowedTrialLength', p.Results.AllowedTrialLength);
                    case 'lick'
                        obj.statsLick = stats;
                        obj.statsInfoLick = struct('Method', p.Results.Method, 'Window', p.Results.Window, 'AllowedTrialLength', p.Results.AllowedTrialLength);
                end
            end
        end

        function varargout = binStimResponse(obj, tr, varargin)
            p = inputParser();
            p.addRequired('TetrodeRecording', @(x) isa(x, 'TetrodeRecording'))
            p.addOptional('Channels', @isnumeric);
            p.addOptional('Units', [], @isnumeric);
            p.addParameter('BinWidth', 0.01, @isnumeric); % Bin width in seconds
            p.addParameter('Window', [-0.2, 0.5]); % Additional seconds before and after tOn
            p.addParameter('Store', false, @islogical);
            p.parse(tr, varargin{:});
            tr = p.Results.TetrodeRecording;
            channels = p.Results.Channels;
            units = p.Results.Units;
            binWidth = p.Results.BinWidth;
            window = p.Results.Window;
            store = p.Results.Store;
            
            % Do all channels
            if isempty(channels)
                channels = [tr.Spikes.Channel];
            end
            
            nChannels = length(channels);
            nUnitsInChannel = zeros(nChannels, 1);
            for i = 1:nChannels
                nUnitsInChannel(i) = max(tr.Spikes(channels(i)).Cluster.Classes) - 1;
            end
            assert(isempty(units) || max(nUnitsInChannel) >= max(units), 'Requested units (%s) exceeds total number of units (%g) in data.', num2str(units), max(units));
            
            if isempty(units)
                nUnits = sum(nUnitsInChannel);
            else
                nUnits = length(units) * nChannels;
            end
            
            bsr(nUnits) = struct('expName', '', 'channel', [], 'unit', [], 't', [], 'tRight', [], 'spikeRates', [], 'normalizedSpikeRates', []);
            m = zeros(nUnits, 1);
            s = zeros(nUnits, 1);

            % Bin spikes
            nPulses = length(obj.stim.tOn);
            t = window(1):binWidth:window(2);
            nBins = length(t) - 1;

            iUnit = 0;
            for iChn = 1:nChannels
                channel = channels(iChn);
                
                if isempty(units)
                    selUnits = 1:nUnitsInChannel(iChn);
                else
                    selUnits = units;
                end
                
                for iUnitInChannel = 1:length(selUnits)
                    iUnit = iUnit + 1;
                    unit = selUnits(iUnitInChannel);

                    % Extract unit spike times
                    sel = tr.Spikes(channel).Cluster.Classes == unit;
                    spikeTimes = tr.Spikes(channel).Timestamps(sel);

                    % Stats for normalizing spike rates
                    spikeRates = histcounts(spikeTimes, spikeTimes(1):binWidth:spikeTimes(end)) ./ binWidth;
                    m(iUnit) = mean(spikeRates);
                    s(iUnit) = mad(spikeRates, 0) / 0.6745;
                    bsr(iUnit).expName = obj.expName;
                    bsr(iUnit).channel = channel;
                    bsr(iUnit).unit = unit;
                    bsr(iUnit).spikeRates = zeros(nPulses, nBins);
                    bsr(iUnit).normalizedSpikeRates = zeros(nPulses, nBins);
                    isPreWindow = t < 0;
                    for iPulse = 1:nPulses
                        edges = obj.stim.tOn(iPulse) + window(1):binWidth:obj.stim.tOn(iPulse) + window(2);
                        % bsr(iUnit).t = (edges(1:end - 1) + edges(2:end))/2 - obj.stim.tOn(iPulse);
                        bsr(iUnit).tRight = edges(2:end) - obj.stim.tOn(iPulse);
                        bsr(iUnit).t = (edges(1:end-1) + edges(2:end))/2 - obj.stim.tOn(iPulse);
                        bsr(iUnit).spikeRates(iPulse, :) = histcounts(spikeTimes, edges) ./ binWidth;
                        % Normalize by substracting pre stim window and dividing by global MAD
                        bsr(iUnit).normalizedSpikeRates(iPulse, :) = (bsr(iUnit).spikeRates(iPulse, :) - mean(bsr(iUnit).spikeRates(iPulse, isPreWindow))) ./ s(iUnit);
                    end
                end
            end

            if store
                obj.bsr = bsr;
            end
            
            varargout = {bsr, m, s};
        end

        function [bsr, IPulse] = selectStimResponse(obj, varargin)
            p = inputParser();
            p.addParameter('Light', [], @isnumeric);
            p.addParameter('Duration', [], @isnumeric);
            p.addParameter('MLRank', [], @isnumeric); % 1: most medial, 4: most lateral
            p.addParameter('DVRank', [], @isnumeric); % 1: most ventral, 4: most dorsal
            p.addParameter('Fiber', {}, @(x) ischar(x) || iscell(x));
            p.addParameter('Galvo', [], @isnumeric);
            p.parse(varargin{:});
            crit.light = p.Results.Light;
            crit.duration = p.Results.Duration;
            crit.mlRank = p.Results.MLRank;
            crit.dvRank = p.Results.DVRank;
            crit.fiber = p.Results.Fiber;
            crit.galvo = p.Results.Galvo;
            
            sel = true(size(obj.stim.tOn));
            if ~isempty(crit.light)
                sel = sel & ismember(round(1000*obj.stim.light), round(1000*crit.light));
            end
            if ~isempty(crit.duration)
                sel = sel & ismember(round(1000*obj.stim.duration), round(1000*crit.duration));
            end
            if ~isempty(crit.mlRank)
                sel = sel & ismember(obj.stim.mlRank, crit.mlRank);
            end
            if ~isempty(crit.dvRank)
                sel = sel & ismember(obj.stim.dvRank, crit.dvRank);
            end
            if ~isempty(crit.fiber)
                sel = sel & ismember(obj.stim.fiber, crit.fiber);
            end
            if ~isempty(crit.galvo)
                sel = sel & ismember(obj.stim.galvo, crit.galvo);
            end
            
            bsr = obj.bsr;
            IPulse = find(sel);
            for i = 1:length(obj.bsr)
                bsr(i).spikeRates = bsr(i).spikeRates(sel, :);
                bsr(i).normalizedSpikeRates = bsr(i).normalizedSpikeRates(sel, :);
                bsr(i).IPulse = IPulse;
            end
            
%             if isempty(IPulse) && length(crit.light) > 1
%                 warning('Requested conditions not found in experiment.')
%                 selCond = [obj.conditions.mlRank] == crit.mlRank & [obj.conditions.dvRank] == crit.dvRank;
%                 availableConditions = {obj.conditions(selCond).label}'
%             end
%             fprintf(1, '%g trials selected with provided criteria.\n', length(IPulse))
        end

        function groups = groupByStimCondition(obj, bsrOrIPulse, groupBy, varargin)
            function y = tryConsolidate(x)
                if length(unique(x)) == 1
                    y = x(1);
                else
                    y = x;
                end
            end

            p = inputParser();
            if isstruct(bsrOrIPulse)
                p.addRequired('BinnedStimResponse', @isstruct);
                if isfield(bsrOrIPulse, 'IPulse')
                    IPulse = bsrOrIPulse(1).IPulse;
                else
                    IPulse = 1:length(obj.stim.tOn);
                end
            else
                p.addRequired('IPulse', @isnumeric);
                if ~isempty(bsrOrIPulse)
                    IPulse = bsrOrIPulse;
                else
                    IPulse = 1:length(obj.stim.tOn);
                end
            end
            p.addRequired('GroupBy', @(x) all(ismember(x, {'light', 'duration', 'ml', 'dv'})))
            p.addParameter('HashBase', 10, @isnumeric);
            p.parse(bsrOrIPulse, groupBy, varargin{:});
            groupBy = p.Results.GroupBy;
            hashBase = p.Results.HashBase;

            % Find total number of unique conditions
            light = obj.stim.light(IPulse);
            duration = obj.stim.duration(IPulse);
            fiber = obj.stim.fiber(IPulse);
            galvo = obj.stim.galvo(IPulse);
            [~, lightRank] = ismember(light, unique(light));
            [~, durationRank] = ismember(duration, unique(duration));
            mlRank = obj.stim.mlRank(IPulse);
            dvRank = obj.stim.dvRank(IPulse);
            
            suggestedHashBase = max([max(lightRank), max(durationRank), max(mlRank), max(dvRank)]);
            if hashBase < suggestedHashBase
                error('Using hash base %g will cause problems, suggest using %g or higher.', hashBase, suggestedHashBase);
            end
            
            % Hash for each stim pulse, identical conditions should
            % generate same hash. This will NOT hold up across sessions
            % though.
            hash = lightRank*(hashBase^3) + durationRank*(hashBase^2) + mlRank*(hashBase^1) + dvRank*(hashBase^0);
            
            % Hash for each group. Ignored critera do not add to hash.
            groupHash = 0;
            if ismember('light', groupBy)
                groupHash = groupHash + lightRank*(hashBase^3);
            end
            if ismember('duration', groupBy)
                groupHash = groupHash + durationRank*(hashBase^2);
            end
            if ismember('ml', groupBy)
                groupHash = groupHash + mlRank*(hashBase^1);
            end
            if ismember('dv', groupBy)
                groupHash = groupHash + dvRank*(hashBase^0);
            end

            [uniqueGroupHash, ia] = unique(groupHash);
            nGroups = length(uniqueGroupHash);
            groups(nGroups) = struct('groupHash', [], 'hash', [], 'label', '', 'numTrials', [], 'light', [], 'duration', [], 'mlRank', [], 'dvRank', [], 'fiber', '', 'galvo', [], 'IPulse', []);

            for iGrp = 1:nGroups
                i = ia(iGrp);
                groups(iGrp).groupHash = groupHash(i);
                sel = groupHash == groupHash(i);
                groups(iGrp).IPulse = IPulse(sel);
                groups(iGrp).hash = tryConsolidate(hash(sel));
                groups(iGrp).numTrials = nnz(sel);
                groups(iGrp).light = tryConsolidate(light(sel));
                groups(iGrp).duration = tryConsolidate(duration(sel));
                groups(iGrp).mlRank = tryConsolidate(mlRank(sel));
                groups(iGrp).dvRank = tryConsolidate(dvRank(sel));
                groups(iGrp).fiber = tryConsolidate(fiber(sel));
                groups(iGrp).galvo = tryConsolidate(galvo(sel));
                groups(iGrp).label = AcuteRecording.makeGroupLabel(groups(iGrp).light, groups(iGrp).duration, groups(iGrp).mlRank, groups(iGrp).dvRank);
            end
        end

        function [stats, t] = summarizeStimResponse(obj, groups, varargin)
            p = inputParser();
            p.addRequired('Groups', @isstruct)
            p.addOptional('Method', 'peak', @(x) ismember(x, {'none', 'peak', 'mean', 'firstPeak'}))
            p.addOptional('Window', [0, 0.05], @(x) isnumeric(x) && length(x) == 2)
            p.addOptional('FirstPeakThreshold', 0, @isnumeric)
            p.addOptional('Normalized', true, @islogical);
            p.parse(groups, varargin{:})
            groups = p.Results.Groups;
            normalized = p.Results.Normalized;

            nGroups = length(groups);
            nUnits = length(obj.bsr);
            switch p.Results.Method
                case 'mean'
                    stats = NaN(nUnits, nGroups);
                    for iUnit = 1:nUnits
                        for iGrp = 1:nGroups
                            if normalized
                                msr = mean(obj.bsr(iUnit).normalizedSpikeRates(groups(iGrp).IPulse, :), 1);
                            else
                                msr = mean(obj.bsr(iUnit).spikeRates(groups(iGrp).IPulse, :), 1);
                            end
                            [stats(iUnit, iGrp), t] = AcuteRecording.summarizeMeanSpikeRates(msr, obj.bsr(iUnit).t, p.Results.Method, p.Results.Window);
                        end
                    end
                case {'peak', 'firstPeak'}
                    t = NaN(nUnits, nGroups);
                    stats = NaN(nUnits, nGroups);
                    for iUnit = 1:nUnits
                        for iGrp = 1:nGroups
                            if normalized
                                msr = mean(obj.bsr(iUnit).normalizedSpikeRates(groups(iGrp).IPulse, :), 1);
                            else
                                msr = mean(obj.bsr(iUnit).spikeRates(groups(iGrp).IPulse, :), 1);
                            end
                            [stats(iUnit, iGrp), t(iUnit, iGrp)] = AcuteRecording.summarizeMeanSpikeRates(msr, obj.bsr(iUnit).t, p.Results.Method, p.Results.Window, p.Results.FirstPeakThreshold);
                        end
                    end
                case 'none'
                    t = obj.bsr(1).t;
                    stats = NaN(nUnits, length(t), nGroups);
                    for iUnit = 1:nUnits
                        for iGrp = 1:nGroups
                            if normalized
                                stats(iUnit, :, iGrp) = mean(obj.bsr(iUnit).normalizedSpikeRates(groups(iGrp).IPulse, :), 1);
                            else
                                stats(iUnit, :, iGrp) = mean(obj.bsr(iUnit).spikeRates(groups(iGrp).IPulse, :), 1);
                            end
                        end
                    end
            end
        end

        function [stats, conditions] = summarize(obj, bsr, varargin)
            p = inputParser();
            p.addRequired('BinnedStimResponse', @isstruct)
            p.addOptional('Method', 'peak', @(x) ismember(x, {'peak', 'mean', 'firstPeak'}))
            p.addOptional('Window', [0, 0.05], @(x) isnumeric(x) && length(x) == 2)
            p.addOptional('FirstPeakThreshold', 0, @isnumeric)
            p.addParameter('Store', false, @islogical)
            p.parse(bsr, varargin{:})
            bsr = p.Results.BinnedStimResponse;

            [conditions, ~, ~, ~] = obj.groupByConditions(bsr(1));
            nConditions = length(conditions);
            nUnits = length(bsr);
            stats = NaN(nUnits, nConditions);
            for i = 1:length(bsr)
                [~, ~, condNSR, ~] = obj.groupByConditions(bsr(i));
                stats(i, :) = AcuteRecording.summarizeMeanSpikeRates(condNSR, bsr(i).t, p.Results.Method, p.Results.Window, p.Results.FirstPeakThreshold);
            end

            if p.Results.Store
                obj.conditions = conditions;
                obj.stats = stats;
                obj.statsInfo = struct('Method', p.Results.Method, 'Window', p.Results.Window, 'FirstPeakThreshold', p.Results.FirstPeakThreshold);
            end
        end

        function varargout = groupByConditions(obj, bsr, base)
            assert(length(bsr) == 1)

            spikeRates = bsr.spikeRates;
            normalizedSpikeRates = bsr.normalizedSpikeRates;
            if isfield(bsr, 'IPulse')
                I = bsr.IPulse;
            else
                I = 1:length(obj.stim.tOn);
            end

            % Find total number of unique conditions
            light = obj.stim.light(I);
            duration = obj.stim.duration(I);
            fiber = obj.stim.fiber(I);
            galvo = obj.stim.galvo(I);
            [~, lightRank] = ismember(light, unique(light));
            [~, durationRank] = ismember(duration, unique(duration));
            mlRank = obj.stim.mlRank(I);
            dvRank = obj.stim.dvRank(I);
            
            if nargin < 3
                base = max([max(lightRank), max(durationRank), max(mlRank), max(dvRank)]);
            end
            condId = lightRank*(base^3) + durationRank*(base^2) + mlRank*(base^1) + dvRank*(base^0);
            [uniqueConditions, ia] = unique(condId);
            nConditions = length(uniqueConditions);
            nColorsA = length(unique(dvRank(mlRank==1)));
            nColorsB = length(unique(dvRank(mlRank==2)));
            conditions(nConditions) = struct('id', [], 'label', '', 'numTrials', [], 'light', [], 'duration', [], 'fiber', '', 'galvo', [], 'mlRank', [], 'dvRank', [] , 'linewidth', '');
            condSR = NaN(nConditions, size(spikeRates, 2));
            condNSR = NaN(nConditions, size(spikeRates, 2));
            for iCond = 1:nConditions
                i = ia(iCond);
                conditions(iCond).light = light(i);
                conditions(iCond).duration = duration(i);
                conditions(iCond).mlRank = mlRank(i);
                conditions(iCond).dvRank = dvRank(i);
                conditions(iCond).fiber = fiber(i);
                conditions(iCond).galvo = galvo(i);
                conditions(iCond).id = condId(i);
                switch mlRank(i)
                    case 1
                        mlText = 'mStr';
                    case 2
                        mlText = 'lStr';
                end
                switch dvRank(i)
                    case 1
                        dvText = '-4.15';
                    case 2
                        dvText = '-3.48';
                    case 3
                        dvText = '-2.81';
                    case 4
                        dvText = '-2.15';
                end
                conditions(iCond).label = sprintf('%.1fmW, %.0fms (%s %s)', light(i), duration(i)*1000, mlText, dvText);
                conditions(iCond).linewidth = AcuteRecording.lerp(1, 2, (lightRank(i) - 1)/(max(lightRank) - 1));
                if mlRank(i) == 1
                    conditions(iCond).linecolor = [0.9, AcuteRecording.lerp(0.1, 0.9, (dvRank(i)-1)/(nColorsA-1)), 0.1];
                elseif mlRank(i) == 2
                    conditions(iCond).linecolor = [AcuteRecording.lerp(0.1, 0.9, (dvRank(i)-1)/(nColorsB-1)), 0.9, 0.1];
                else
                    error('ml rank must be 1 or 2, got %g instead', mlrank(i));
                end
                condSel = condId == condId(ia(iCond));
                conditions(iCond).numTrials = nnz(condSel);
                condSR(iCond, :) = mean(spikeRates(condSel, :), 1);
                condNSR(iCond, :) = mean(normalizedSpikeRates(condSel, :), 1);
            end
            
            varargout = {conditions, condSR, condNSR, condId};
        end
        
        function pooledStats = getMoveResponse(obj, moveType)
            stats = cell(length(obj), 1);
            for iExp = 1:length(obj)
                stats{iExp} = obj(iExp).summarizeMoveResponse(moveType, 'peak', [-1, 0], 'AllowedTrialLength', [1, Inf]);
            end
            pooledStats = cat(1, stats{:});
        end
        
        function [pooledStats, pooledTimestamps, pooledGroups] = getStimResponse(obj, light, duration, varargin)
            p = inputParser();
            p.addRequired('Light', @isnumeric);
            p.addRequired('Duration', @isnumeric);
            p.addOptional('Stat', 'peak', @(x) ismember(lower(x), {'mean', 'peak', 'firstpeak', 'none'}))
            p.addParameter('StatWindow', [0, 0.05], @isnumeric)
            p.addParameter('FirstPeakThreshold', 0, @isnumeric)
            p.addParameter('Normalized', true, @islogical)
            p.parse(light, duration, varargin{:})

            % Extract groups and grouped stats for each experiment
            groups = cell(length(obj), 1);
            stats = cell(length(obj), 1);
            t = cell(length(obj), 1);
            for iExp = 1:length(obj)
                [~, I] = obj(iExp).selectStimResponse('Light', p.Results.Light, 'Duration', p.Results.Duration);
                if ~isempty(I)
                    groups{iExp} = obj(iExp).groupByStimCondition(I, {'light', 'duration', 'ml', 'dv'});
                    [stats{iExp}, t{iExp}] = obj(iExp).summarizeStimResponse(groups{iExp}, p.Results.Stat, p.Results.StatWindow, p.Results.FirstPeakThreshold, p.Results.Normalized);
                end
            end
            
            % Find all unique group hashes across experiments and prepare for data merging. 
            % If a condition is not tested in certain experiments, missing data will be padded with NaNs.
            h = cellfun(@(g) [g.groupHash], groups(~cellfun(@isempty, groups)), 'UniformOutput', false);
            uniqueHashes = unique(cat(2, h{:}));
            nGroups = length(uniqueHashes);
            switch lower(p.Results.Stat)
                case {'mean', 'peak', 'firstpeak'}
                    nStats = 1;
                case 'none'
                    nStats = length(obj(1).bsr(1).t);
            end
            pooledStats = cell(length(obj), 1);
            
            if ismember(lower(p.Results.Stat), {'peak', 'firstpeak'})
                pooledTimestamps = cell(length(obj), 1);
            end
            for iExp = 1:length(obj)
                nUnits = length(obj(iExp).bsr); % size(stats{iExp}, 1);
                pooledStats{iExp} = NaN(nUnits, nStats, nGroups);
                if ismember(lower(p.Results.Stat), {'peak', 'firstpeak'})
                    pooledTimestamps{iExp} = NaN(nUnits, nGroups);
                end
                for iGrp = 1:nGroups
                    if ~isempty(groups{iExp}) && ~isempty(stats{iExp})
                        sel = [groups{iExp}.groupHash] == uniqueHashes(iGrp);
                        if any(sel)
                            assert(nnz(sel) == 1)
                            if nStats == 1
                                pooledStats{iExp}(:, :, iGrp) = stats{iExp}(:, sel);
                            else
                                pooledStats{iExp}(:, :, iGrp) = stats{iExp}(:, :, sel);
                            end
                            if ismember(lower(p.Results.Stat), {'peak', 'firstpeak'})
                                pooledTimestamps{iExp}(:, iGrp) = t{iExp}(:, sel);
                            end
                        end
                    end
                end
            end
            
            pooledGroups = AcuteRecording.poolGroups(groups);
            pooledStats = cat(1, pooledStats{:});
            if nStats == 1
                pooledStats = squeeze(pooledStats);
            end
            if ismember(lower(p.Results.Stat), {'peak', 'firstpeak'})
                pooledTimestamps = cat(1, pooledTimestamps{:});
            else
                pooledTimestamps = t{1};
                assert(all(cellfun(@(x) all(abs(x - t{1}) < 1e-4), t)), 'Timestamps not identical.');
            end
        end

        function [figs, axs] = plotStimResponse(obj, light, duration, varargin)
            p = inputParser();
            p.addRequired('Light', @isnumeric);
            p.addRequired('Duration', @isnumeric);
            p.addOptional('Modes', {'line', 'heatmap'}, @(x) all(ismember(lower(x), {'line', 'heatmap', 'staggeredline'})));
            p.addParameter('HeatmapCLim', [], @isnumeric);
            p.addParameter('Print', false, @islogical);
            p.addParameter('Position', [0, 0.1, 0.9, 0.9], @isnumeric)
            p.addParameter('Units', [], @isnumeric)
            p.parse(light, duration, varargin{:});
            light = p.Results.Light;
            duration = p.Results.Duration;
            modes = p.Results.Modes;
            if ~iscell(modes)
                modes = {modes};
            end
            units = p.Results.Units;

            [msr, t, groups] = obj.getStimResponse(light, duration, 'none', 'Normalized', false);
            [mnsr, ~, ~] = obj.getStimResponse(light, duration, 'none', 'Normalized', true);
            tRight = t + (t(2) - t(1)) / 2;
            [nUnits, nTimes, nGroups] = size(msr);
            bsr = [obj.bsr];
            channels = [bsr.channel];
            channelUnits = [bsr.unit];
            expName = {bsr.expName};

            nPlots = length(modes);
            
            figs = gobjects(nUnits, 1);
            axs = gobjects(nUnits, nPlots);

            if isempty(units)
                units = 1:nUnits;
            else
                units = units(:)';
            end
            for iUnit = units
                label = sprintf('%s Chn%g Unit %g', expName{iUnit}, channels(iUnit), channelUnits(iUnit));
%                 figs(iUnit) = figure('Units', 'normalized', 'OuterPosition', p.Results.Position, 'Name', label, 'DefaultAxesFontSize', 10);
                figs(iUnit) = figure('Units', 'inches', 'Position', [0 0 13, 7], 'Name', label, 'DefaultAxesFontSize', 14);
                for iPlot = 1:nPlots
                    axs(iUnit, iPlot) = subplot(nPlots, 1, iPlot);
                    ax = axs(iUnit, iPlot);
                    hold(ax, 'on')
                    switch(lower(modes{iPlot}))
                        case 'line'
                            h = gobjects(nGroups, 1);
                            for iGrp = 1:nGroups
                                h(iGrp) = plot(ax, tRight * 1000, msr(iUnit, :, iGrp), 'DisplayName', groups(iGrp).label);
                            end
                            xlabel(ax, 'Time (ms)')
                            ylabel(ax, 'Spike Rate (sp/s)')
                            legend(ax, flip(h), 'Orientation', 'vertical', 'Location', 'east')
                        case 'staggeredline'
                            h = gobjects(nGroups, 1);
                            offset = range(msr(iUnit, :, :), 'all') / nGroups;
                            for iGrp = 1:nGroups
                                h(iGrp) = plot(ax, tRight * 1000, msr(iUnit, :, iGrp) + (iGrp-1)*offset, 'DisplayName', groups(iGrp).label);
                            end
                            xlabel(ax, 'Time (ms)')
                            ylabel(ax, 'Spike Rate (sp/s)')
                            yticks(ax, [])
                            legend(ax, flip(h), 'Orientation', 'vertical', 'Location', 'east')
                        case 'heatmap'
                            imagesc(ax, t * 1000, 1:nGroups, transpose(squeeze(mnsr(iUnit, :, :))))
                            colormap(ax, 'jet');
                            cb = colorbar(ax, Location='southoutside');
                            cb.Label.String = 'Normalized \DeltaSpike Rate (a.u.)';
                            cb.Label.FontSize = 14;
                            if ~isempty(p.Results.HeatmapCLim)
                                ax.CLim = p.Results.HeatmapCLim;
                            end
                            xlabel('Time (ms)')
                            ylabel('Condition')
                            yticks(ax, 1:nGroups);
%                             yticklabels(ax, {groups.label});
                            sides = 'ML';
                            labels = arrayfun(@(g) sprintf('%s%d', sides(g.mlRank), g.dvRank), groups, UniformOutput=false);
%                             yticklabels(ax, {groups.label});
                            yticklabels(ax, labels);
                            axis(ax, 'tight')
                    end
                    hold(ax, 'off')
                end
%                 suptitle(label)
                if p.Results.Print
                    print(figs(iUnit), label, '-djpeg')
                    close(figs(iUnit))
                end
            end
        end

        function plotStimResponseMap(obj, bsr, varargin)
            p = inputParser();
            p.addRequired('BinnedStimResponse', @(x) isstruct(x) || iscell(x));
            p.addOptional('SRange', [0.25, 3], @(x) isnumeric(x) && length(x)==2);
            p.addOptional('Threshold', 0.25, @isnumeric);
            p.addOptional('Method', 'peak', @(x) ismember(x, {'peak', 'firstPeak', 'mean'}));
            p.addOptional('Window', [0, 0.05], @(x) isnumeric(x) && length(x)==2);
            p.addOptional('FirstPeakThreshold', [], @isnumeric);
            p.addParameter('UseSignedML', false, @islogical);
            p.addParameter('HideFlatUnits', false, @islogical);
            p.addParameter('ConditionBase', 4, @isnumeric); % Max number of stim conditions per category (e.g. if there are 2 durations, 3 light levels, 2 fibers and 4 galvo voltages, then use base 4 = max([2, 3, 2, 4])). Suggest 4, or [] to autocalculate.            
            p.parse(bsr, varargin{:});
            srange = p.Results.SRange;
            threshold = p.Results.Threshold;
            method = p.Results.Method;
            window = p.Results.Window;
            firstPeakThreshold = p.Results.FirstPeakThreshold;
            if isempty(firstPeakThreshold)
                firstPeakThreshold = threshold;
            end

            % Single experiment
            if length(obj) == 1
                coords = obj.getProbeCoords([bsr.channel]);
                [stats, conditions] = obj.summarize(bsr, method, window, firstPeakThreshold);
                nConditions = length(conditions);
                nCols = max(1, floor(sqrt(nConditions)));
                nRows = max(4, ceil(nConditions / nCols));
                fig = figure('Units', 'normalized', 'Position', [0, 0, 0.4, 1]);
                ax = gobjects(nConditions, 1);
                methodLabel = method;
                methodLabel(1) = upper(method(1));
                for iCond = 1:nConditions
                    [i, j] = ind2sub([nRows, nCols], iCond);
                    iSubplot = sub2ind([nCols, nRows], j, nRows + 1 - i);
                    ax(iCond) = subplot(nRows, nCols, iSubplot);
                    h = AcuteRecording.plotMap(ax(iCond), coords, stats(:, iCond), srange, threshold, [bsr.channel], methodLabel, 'UseSignedML', p.Results.UseSignedML);
                    title(ax(iCond), conditions(iCond).label)
                    axis(ax(iCond), 'equal')
                end
                figure(fig);
                suptitle(obj.getLabel());
            elseif length(obj) > 1
                assert(iscell(bsr) && length(obj) == length(bsr))
                
                % Pool experiments
                for i = 1:length(obj)
                    coords{i} = obj(i).getProbeCoords([bsr{i}.channel]);
                    [stats{i}, conditions{i}] = obj(i).summarize(bsr{i}, method, window, firstPeakThreshold);
                end
                pooledConditions = AcuteRecording.poolConditions(conditions, p.Results.ConditionBase);
                nConditions = length(pooledConditions);
                pooledCoords = cell(1, nConditions);
                pooledStats = cell(1, nConditions);
                pooledChannels = cell(1, nConditions);
                for iCond = 1:nConditions
                    id = pooledConditions(iCond).id;
                    for iExp = 1:length(obj)
                        iCondInExp = find([conditions{iExp}.id] == id);
                        if ~isempty(iCondInExp)
                            pooledCoords{iCond} = vertcat(pooledCoords{iCond}, coords{iExp});
                            pooledStats{iCond} = vertcat(pooledStats{iCond}, stats{iExp}(:, iCondInExp));
                            pooledChannels{iCond} = vertcat(pooledChannels{iCond}, [bsr{iExp}.channel]');
                        end
                    end
                end
                
                % Plot
                nCols = max(1, floor(sqrt(nConditions)));
                nRows = max(4, ceil(nConditions / nCols));
                fig = figure('Units', 'normalized', 'Position', [0, 0, 0.2, 0.8], 'DefaultAxesFontSize', 12);
                ax = gobjects(nConditions, 1);
                methodLabel = method;
                methodLabel(1) = upper(method(1));
                for iCond = 1:nConditions
                    [i, j] = ind2sub([nRows, nCols], iCond);
                    iSubplot = sub2ind([nCols, nRows], j, nRows + 1 - i);
                    ax(iCond) = subplot(nRows, nCols, iSubplot);
                    h = AcuteRecording.plotMap(ax(iCond), pooledCoords{iCond}, pooledStats{iCond}, srange, threshold, pooledChannels{iCond}, methodLabel, 'UseSignedML', p.Results.UseSignedML, 'HideFlatUnits', p.Results.HideFlatUnits);
                    switch pooledConditions(iCond).mlRank
                        case 1
                            mlText = 'mStr';
                        case 2
                            mlText = 'lStr';
                    end
                    switch pooledConditions(iCond).dvRank
                        case 4
                            dvText = '-2.15';
                        case 3
                            dvText = '-2.81';
                        case 2
                            dvText = '-3.48';
                        case 1
                            dvText = '-4.15';
                    end
                    if pooledConditions(iCond).mlRank == 2 && pooledConditions(iCond).dvRank > 1
                        xlabel(ax(iCond), "");
                        ylabel(ax(iCond), "");
                    end
                    if pooledConditions(iCond).dvRank > 1
                        xlabel(ax(iCond), "");
                    end
                    title(ax(iCond), sprintf('%s %s', mlText, dvText))
                    axis(ax(iCond), 'image')
                    xlim(ax(iCond), [0.9, 1.7])
                    ylim(ax(iCond), [-4.8, -3.7])
                end
                
                strain = unique({obj.strain});
                if length(strain) == 1
                    strain = strain{1};
                else
                    strain = 'Multiple Strains';
                end
                suptitle(obj.getLabel());
            end
        end

        function [fig, ax] = plotPressVsLickResponse(obj, varargin)
            p = inputParser();
            if isgraphics(varargin{1})
                p.addRequired('Ax', @(x) strcmp(varargin{1}.Type, 'axes'));
            end
            p.addParameter('PressThreshold', 1, @isnumeric);
            p.addParameter('LickThreshold', 1, @isnumeric);
            p.addParameter('Highlight', 'union', @(x) ismember(lower(x), {'press', 'lick', 'union', 'intersect'}))
            p.addParameter('Hue', 2/3, @(x) isnumeric(x) || ismember(x, {'ml', 'dv'}));
            p.parse(varargin{:});
            switch p.Results.Highlight
                case 'lick'
                    highlight = 'x';
                case 'press'
                    highlight = 'y';
                otherwise
                    highlight = p.Results.Highlight;
            end

            pressStats = obj.getMoveResponse('Press');
            lickStats = obj.getMoveResponse('Lick');

            % Color by SNr coordinates (ML/DV) or use specific Hue.
            if isnumeric(p.Results.Hue)
                hue = p.Results.Hue;
                hdr = [];
            else
                coords = obj.getProbeCoords();
                switch p.Results.Hue
                    case 'ml'
                        hue = abs(coords(:, 1));
                        hdr = [1075, 1525];
                    case 'dv'
                        hue = abs(coords(:, 2));
                        hdr = [3800, 4800];
                    otherwise
                        error('Hue must be ''ml'', ''dv'', or a numeric value between 0 and 1.')
                end
            end

            if isfield(p.Results, 'Ax')
                ax = p.Results.Ax;
                fig = ax.Parent;
            else
                fig = figure('Units', 'normalized', 'Position', [0, 0, 0.25, 0.4]);
                ax = axes(fig, 'Tag', 'scatter');
            end
   
            AcuteRecording.plotScatter(ax, lickStats, pressStats, p.Results.LickThreshold, p.Results.PressThreshold, ...
                'XLabel', 'Lick', 'YLabel', 'Press', 'Highlight', highlight, ...
                'Title', obj.getLabel(), 'Hue', hue, 'HueDataRange', hdr);
        end

        function [fig, ax] = plotStimVsMoveResponse(obj, varargin)
            p = inputParser();
            if isgraphics(varargin{1})
                p.addRequired('Ax', @(x) strcmp(varargin{1}.Type, 'axes'));
            end
            p.addRequired('MoveType', @(x) ismember(lower(x), {'press', 'lick'}));
            p.addParameter('StimThreshold', 0.5, @isnumeric);
            p.addParameter('MoveThreshold', 1, @isnumeric);
            p.addParameter('Highlight', 'stim', @(x) ismember(lower(x), {'move', 'stim', 'union', 'intersect'}))
            p.addParameter('Light', [0.4 0.5 2], @isnumeric);
            p.addParameter('Duration', 0.01, @isnumeric);
            p.addParameter('MergeGroups', 'off', @(x) ismember(lower(x), {'off', 'mean', 'max'})) % Should all condition groups be merged into one by taking the mean or max across groups?
            p.addParameter('Hue', 2/3, @(x) isnumeric(x) || ismember(x, {'ml', 'dv'}));
            p.parse(varargin{:});
            switch p.Results.Highlight
                case 'move'
                    highlight = 'x';
                case 'stim'
                    highlight = 'y';
                otherwise
                    highlight = p.Results.Highlight;
            end

            [stimStats, ~, groups] = obj.getStimResponse(p.Results.Light, p.Results.Duration);
            moveStats = obj.getMoveResponse(p.Results.MoveType);

            % Color by SNr coordinates (ML/DV) or use specific Hue.
            if isnumeric(p.Results.Hue)
                hue = p.Results.Hue;
                hdr = [];
            else
                coords = obj.getProbeCoords();
                switch p.Results.Hue
                    case 'ml'
                        hue = abs(coords(:, 1));
                        hdr = [1075, 1525];
                    case 'dv'
                        hue = abs(coords(:, 2));
                        hdr = [3800, 4800];
                    otherwise
                        error('Hue must be ''ml'', ''dv'', or a numeric value between 0 and 1.')
                end
            end

            if strcmp(p.Results.MergeGroups, 'off')
                nGroups = length(groups);
                if isfield(p.Results, 'Ax')
                    ax = p.Results.Ax;
                    fig = ax.Parent;
                    assert(length(ax) >= nGroups, '%g axes provided, insuficcient for %g stim groups.', length(ax), nGroups)
                else
                    fig = figure('Units', 'normalized', 'Position', [0, 0, 0.4, 1]);
                    [ax, fig] = AcuteRecording.makeSubplots(nGroups, fig);
                end
                for iGrp = 1:nGroups
                    AcuteRecording.plotScatter(ax(iGrp), moveStats, stimStats(:, iGrp), p.Results.MoveThreshold, p.Results.StimThreshold, ...
                        'XLabel', p.Results.MoveType, 'YLabel', 'Stim', 'Highlight', highlight, ...
                        'Title', groups(iGrp).label, 'Hue', hue, 'HueDataRange', hdr);
                end
                figure(fig);
                suptitle(obj.getLabel());
            else
                if isfield(p.Results, 'Ax')
                    ax = p.Results.Ax;
                    fig = ax.Parent;
                else
                    fig = figure('Units', 'normalized', 'Position', [0, 0, 0.25, 0.4]);
                    ax = axes(fig, 'Tag', 'scatter');
                end
       
                switch p.Results.MergeGroups
                    case 'mean'
                        stimStats = mean(stimStats, 2, 'omitnan');
                    case 'max'
                        [~, I] = max(abs(stimStats), [], 2, 'omitnan');
                        stimStats = diag(stimStats(:, I));
                end
                AcuteRecording.plotScatter(ax, moveStats, stimStats, p.Results.MoveThreshold, p.Results.StimThreshold, ...
                    'XLabel', p.Results.MoveType, 'YLabel', 'Stim', 'Highlight', highlight, ...
                    'Title', AcuteRecording.makeGroupLabel([groups.light], [groups.duration]), 'Hue', hue, 'HueDataRange', hdr);
            end
        end

        function [fig, ax] = plotStimResponseVsLight(obj, varargin)
            function sliderValueChanged(src, ev)
                src.Value = round(src.Value);
                for i = 1:nPairs
                    pnl(i).Visible = false;
                end
                pnl(src.Value).Visible = true;
            end

            p = inputParser();
            if isgraphics(varargin{1}(1))
                if strcmp(varargin{1}(1).Type, 'axes')
                    p.addRequired('Ax', @(x) strcmp(varargin{1}(1).Type, 'axes'));
                else
                    p.addRequired('Fig');
                end
            end
            p.addRequired('Lights', @(x) iscell(x) && length(x) >= 2)
            p.addRequired('Duration', @(x) isnumeric(x) && length(x) == 1);
            p.addParameter('MergeGroups', 'off', @(x) ismember(x, {'off', 'max', 'mean'}))
            p.parse(varargin{:});
            lights = p.Results.Lights;
            duration = p.Results.Duration;

            nLights = length(lights);
            if nLights > 2
                nPairs = nchoosek(nLights, 2);
                switch p.Results.MergeGroups
                    case 'off'
                        fig = uifigure('Units', 'normalized', 'Position', [0, 0.1, 0.4, 0.8]);
                    case {'mean', 'max'}
                        fig = uifigure('Units', 'normalized', 'Position', [0, 0.1, 0.25, 0.4]);
                end

                iPair = 1;
                for ix = 1:nLights-1
                    for iy = ix+1:nLights
                        pnl(iPair) = uipanel(fig, 'Units', 'normalized', 'Position', [0, 0.1, 1, 0.9], 'Visible', false);
                        obj.plotStimResponseVsLight(pnl(iPair), lights([ix, iy]), duration, 'MergeGroups', p.Results.MergeGroups);
                        iPair = iPair + 1;
                    end
                end
                slider = uislider(fig, 'Value', 1, 'Limits', [1, nPairs], 'MajorTicks', 1:nPairs, 'MinorTicks', [], 'Position', [100, 50, 150, 3]);
                slider.ValueChangedFcn = @sliderValueChanged;
                pnl(1).Visible = true;
                return
            end
   

            % Step 1: Make two versions of stimStats, one for each light level
            groups = cell(length(obj), nLights);
            stimStats = cell(length(obj), nLights);
            for iExp = 1:length(obj)
                for iLi = 1:nLights
                    [~, I] = obj(iExp).selectStimResponse('Light', lights{iLi}, 'Duration', duration);
                    groups{iExp, iLi} = obj(iExp).groupByStimCondition(I, {'light', 'duration', 'ml', 'dv'});
                    stimStats{iExp, iLi} = obj(iExp).summarizeStimResponse(groups{iExp, iLi}, 'peak');
                end
            end
            
            % Find all unique group hashes
            h = cellfun(@(g) [g.groupHash], groups, 'UniformOutput', false);
            uniqueHashes = unique(cat(2, h{:}));
            nGroups = length(uniqueHashes);
            stimStatsPadded = cell(length(obj), 1);
            for iExp = 1:length(obj)
                nUnits = size(stimStats{iExp, 1}, 1);
                stimStatsPadded{iExp} = NaN(nUnits, nGroups, nLights);
                for iLi = 1:nLights
                    for iGrp = 1:nGroups
                        sel = [groups{iExp, iLi}.groupHash] == uniqueHashes(iGrp);
                        if nnz(sel) > 0
                            assert(nnz(sel) == 1)
                            stimStatsPadded{iExp}(:, iGrp, iLi) = stimStats{iExp, iLi}(:, sel);
                        end
                    end
                end
            end
            
            pooledGroups = cell(1, nLights);
            for iLi = 1:nLights
                pooledGroups{iLi} = AcuteRecording.poolGroups(groups(:, iLi));
                for iGrp = 1:nGroups
                    sel = find([pooledGroups{iLi}.groupHash] == uniqueHashes(iGrp));
                    if ~isempty(sel)
                        pooledGroupsPadded(iGrp, iLi) = pooledGroups{iLi}(sel);
                    end
                end
            end
            
            % Now we have stimStatsPadded (non existing conditions are padded with NaN) and pooledGroupsPadded. 
            stimStatsPadded = cat(1, stimStatsPadded{:});

            % Step 2. Plot
            if nLights == 2
                switch p.Results.MergeGroups
                    case 'mean'
                        stimStatsPadded = squeeze(mean(stimStatsPadded, 2, 'omitnan'));
                    case 'max'
                        m = NaN(size(stimStatsPadded, [1 3]));
                        [~, IMax] = max(abs(stimStatsPadded), [], 2);
                        for iLi = 1:nLights
                            m(:, iLi) = diag(stimStatsPadded(:, IMax(:, :, iLi), iLi));
                        end
                        stimStatsPadded = m;
                end
                switch p.Results.MergeGroups
                    case 'off'
                        if isfield(p.Results, 'Ax') && length(p.Results.Ax) == nGroups
                            ax = p.Results.Ax;
                            fig = ax(1).Parent;
                        elseif isfield(p.Results, 'Fig')
                            [ax, fig] = AcuteRecording.makeSubplots(nGroups, p.Results.Fig);
                        else
                            [ax, fig] = AcuteRecording.makeSubplots(nGroups);
                        end
                        for iGrp = 1:nGroups
                            AcuteRecording.plotScatter(ax(iGrp), stimStatsPadded(:, iGrp, 1), stimStatsPadded(:, iGrp, 2), 0.5, 0.5, ...
                                'XLabel', pooledGroupsPadded(iGrp, 1).label, 'YLabel', pooledGroupsPadded(iGrp, 2).label, ...
                                'Highlight', 'intersect');
                        end
                        try
                            suptitle(obj.getLabel());
                        end
                    case {'mean', 'max'}
                        if isfield(p.Results, 'Ax')
                            ax = p.Results.Ax;
                            fig = ax.Parent;
                        else
                            if isfield(p.Results, 'Fig')
                                fig = p.Results.Fig;
                            else
                                fig = figure;
                            end
                            ax = axes(figure);
                        end
                        xname = sprintf('%s (%s)', AcuteRecording.makeGroupLabel([pooledGroupsPadded(:, 1).light], [pooledGroupsPadded(:, 1).duration]), p.Results.MergeGroups);
                        yname = sprintf('%s (%s)', AcuteRecording.makeGroupLabel([pooledGroupsPadded(:, 2).light], [pooledGroupsPadded(:, 2).duration]), p.Results.MergeGroups);
                        AcuteRecording.plotScatter(ax, stimStatsPadded(:, 1), stimStatsPadded(:, 2), 0.5, 0.5, ...
                                'XLabel', xname, 'YLabel', yname, ...
                                'Highlight', 'intersect', 'Title', obj.getLabel());
                end
            end
        end
    end

    methods (Static)
        function obj = load(varargin)
            p = inputParser();
            p.addOptional('FilesOrDirs', '', @(x) ischar(x) || iscell(x))
            p.parse(varargin{:})
            filesOrDirs = p.Results.FilesOrDirs;

            if isempty(filesOrDirs)
                filesOrDirs = uipickfiles('FilterSpec', '*.mat');
            end
            
            % Read all files in folder (string, dir path)
            files = {};
            if ~iscell(filesOrDirs)
                assert(ischar(filesOrDirs));
                filesOrDirs = {filesOrDirs};
            end


            for i = 1:length(filesOrDirs)
                thisPath = filesOrDirs{i};
                if isfile(thisPath)
                    files = [files, thisPath];
                elseif isdir(thisPath)
                    if thisPath(end) == '\'
                        thisPath = thisPath(1:end-1);
                    end
                    filesInPath = dir(sprintf('%s\\ar_*.mat', thisPath));
                    filesInPath = cellfun(@(x) sprintf('%s\\%s', thisPath, x), {filesInPath.name}, 'UniformOutput', false);
                    files = [files, filesInPath];
                else
                    error('Path %g of %g (''%s'') cannot be read because it is neither a file or an directory.', i, length(filesOrDirs), thisPath)
                end
            end

            tTic = tic();
            S(length(files)) = struct('obj', []);
            for i = 1:length(files)
                fprintf(1, 'Loading file %g of %g (%s)...\n', i, length(files), files{i});
                S(i) = load(files{i}, 'obj');
            end
            obj = [S.obj];
            fprintf(1, 'Loaded %g files in %.2f seconds.\n', length(files), toc(tTic));
        end

        % TODO: Return iPulseInTrain
        function [power, galvo, tOn, tOff] = extractPulse(laserOn, laserOff, analogTimestamps, analogData, iPulse, offset, threshold)
            if nargin < 6
                offset = 0;
            end
            if nargin < 7
                threshold = 1000;
            end

            sel = analogTimestamps >= laserOn(iPulse) & analogTimestamps <= laserOff(iPulse) + 0.005;
            t = analogTimestamps(sel);
            power = analogData(1, sel);
            galvo = round(analogData(2, sel) / 100) * 100;

            iOn = find(power > threshold, 1);
            iOff = find(power > threshold, 1, 'last');
            power = mean(power(iOn:iOff)) + offset;
            galvo = mean(galvo);
            tOn = t(iOn);
            tOff = t(iOff);
        end

        function [light, fiber, powerOffset] = findMatchingCalibration(data, power, galvo)
            % A
            sel_A = data.Galvo_A == galvo;
            sel_B = data.Galvo_B == galvo;

            if any(sel_A) && any(sel_B)
                power_A = data.Power_A(sel_A);
                light_A = data.Light_A(sel_A);
                [df_A, i] = min(abs(power_A - power));
                light_A = light_A(i);
                powerOffset_A = power - power_A(i);

                power_B = data.Power_B(sel_B);
                light_B = data.Light_B(sel_B);
                [df_B, i] = min(abs(power_B - power));
                light_B = light_B(i);
                powerOffset_B = power - power_B(i);

                if df_A < df_B
                    fiber = 'A';
                    light = light_A;
                    powerOffset = powerOffset_A;
                else
                    fiber = 'B';
                    light = light_B;
                    powerOffset = powerOffset_B;
                end
            elseif any(sel_A)
                fiber = 'A';
                power_A = data.Power_A(sel_A);
                light_A = data.Light_A(sel_A);
                [~, i] = min(abs(power_A - power));
                light = light_A(i);
                powerOffset = power - power_A(i);
            elseif any(sel_B)
                fiber = 'B';
                power_B = data.Power_B(sel_B);
                light_B = data.Light_B(sel_B);
                [~, i] = min(abs(power_B - power));
                light = light_B(i);
                powerOffset = power - power_B(i);
            else
                error('No galvo voltage matches %f in calibration data.', galvo);
            end
        end

        function [stats, t, info] = summarizeMeanSpikeRates(msr, t, varargin)
            p = inputParser();
            p.addRequired('MeanSpikeRates', @isnumeric)
            p.addRequired('Timestamps', @isnumeric)
            p.addOptional('Method', 'peak', @(x) ismember(x, {'peak', 'mean', 'firstPeak'}))
            p.addOptional('Window', [0, 0.05], @(x) isnumeric(x) && length(x) == 2)
            p.addOptional('FirstPeakThreshold', 0, @isnumeric)
            p.parse(msr, t, varargin{:});
            msr = p.Results.MeanSpikeRates;
            t = p.Results.Timestamps;
            window = p.Results.Window;

            N = size(msr, 1);
            sel = t <= window(2) & t >= window(1);
            msr = msr(:, sel); % Truncate by window
            t = t(sel);
            switch p.Results.Method
                case 'mean'
                    stats = mean(msr, 2);
                case 'peak'
                    [~, I] = max(abs(msr), [], 2);
                    stats = diag(msr(:, I));
                    T = repmat(t(:)', [size(msr, 1), 1]);
                    t = diag(T(:, I));
                case 'firstPeak'
                    stats = NaN(N, 1);
                    for i = 1:N
                        [peaks, ipk] = AcuteRecording.findpeaks(msr(i, :), p.Results.FirstPeakThreshold);
                        stats(i) = peaks(1);
                        I(i) = ipk(1);
                    end
                    t = t(I);
                otherwise
                    error('Not implemented method %s', p.Results.Method)
            end
            info.name = p.Results.Method;
            info.window = window;
        end

        function h = plotMap(varargin)
            p = inputParser();
            if isgraphics(varargin{1})
                p.addRequired('ax', @isgraphics)
                ax = varargin{1};
            else
                ax = gca();
            end
            p.addRequired('coords', @isnumeric)
            p.addRequired('stats', @isnumeric)
            p.addOptional('srange', [0.25, 3], @(x) isnumeric(x) && length(x) == 2)
            p.addOptional('threshold', 0.25, @isnumeric)
            p.addOptional('channels', [], @isnumeric)
            p.addOptional('method', 'Stat', @ischar)
            p.addParameter('SLim', [1 10], @isnumeric) % [9 72]
            p.addParameter('ARange', [0.25, 1], @isnumeric)
            p.addParameter('HideFlatUnits', false, @islogical)
            p.addParameter('UseSignedML', false, @islogical);
            p.addParameter('BubbleSize', [1 10], @(x) isnumeric(x) && length(x) == 2)
            p.addParameter('MarkerAlpha', 0.5, @isnumeric)
            p.addParameter('Color', [], @isnumeric)
            p.addParameter('XJitter', 'density') % 'none' | 'density' | 'rand' | 'randn'
            p.addParameter('XJitterWidth', 0, @isnumeric)
            p.addParameter('LineWidth', 0.5, @isnumeric)
            p.parse(varargin{:})
            
            coords = p.Results.coords;
            stats = p.Results.stats;
            srange = p.Results.srange;
            threshold = p.Results.threshold;
            channels = p.Results.channels;
            method = p.Results.method;

            t = AcuteRecording.inverseLerp(srange(1), srange(2), abs(stats));
            if isempty(p.Results.Color)
                C = zeros(length(stats), 3);
                isUp = stats>=threshold;
                isDown = stats<=-threshold;
                isFlat = ~(isUp | isDown);
                C(isUp, 1) = 1;
                C(isDown, 3) = 1;
                C(isFlat, :) = 0.5;
            else
                C = repmat(p.Results.Color, [length(stats), 1]);
            end
            S = AcuteRecording.lerp(p.Results.SLim(1), p.Results.SLim(2), t);
            A = ones(size(S)) * 40;
            if p.Results.HideFlatUnits
                A(isFlat) = 1;
            end
            ml = coords(:, 1) / 1000;
            dv = coords(:, 2) / 1000;
            ap = coords(:, 3) / 1000;
            if ~p.Results.UseSignedML
                ml = abs(ml);
            end
%             h = scatter3(ax, ml, dv, ap, S, C, 'filled', 'MarkerFaceAlpha', 'flat', 'AlphaData', A, 'AlphaDataMapping', 'direct');
            h = bubblechart3(ax, ml, dv, ap, S, C, MarkerFaceAlpha=p.Results.MarkerAlpha, MarkerEdgeAlpha=0.8, ...
                XJitter=p.Results.XJitter, XJitterWidth=p.Results.XJitterWidth, LineWidth=p.Results.LineWidth);
            bubblesize(ax, p.Results.BubbleSize)
            bubblelim(ax, srange)
%             bubblelegend(ax, '\Deltasp/s')
            view(ax, 0, 90)
            if p.Results.UseSignedML
                mlLabel = 'ML';
            else
                mlLabel = 'ML (abs)';
            end
            xlabel(ax, mlLabel)
            ylabel(ax, 'DV')
            zlabel(ax, 'AP')
            
            try
                h.DataTipTemplate.DataTipRows(1).Label = mlLabel;
                h.DataTipTemplate.DataTipRows(2).Label = 'DV';
                h.DataTipTemplate.DataTipRows(3).Label = 'AP';
                h.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Channel', channels);
                h.DataTipTemplate.DataTipRows(end+2) = dataTipTextRow(method, stats);
                h.DataTipTemplate.DataTipRows(end+3) = dataTipTextRow('Index', 1:length(stats));
            end
        end

        function varargout = plotScatter(varargin)
            p = inputParser();
            if isgraphics(varargin{1})
                p.addRequired('ax', @isgraphics)
                ax = varargin{1};
            else
                ax = gca();
            end
            p.addRequired('x', @isnumeric)
            p.addRequired('y', @isnumeric)
            p.addOptional('xThreshold', 0.5, @isnumeric)
            p.addOptional('yThreshold', 0.5, @isnumeric)
            p.addParameter('XLabel', '', @ischar)
            p.addParameter('YLabel', '', @ischar)
            p.addParameter('Highlight', 'intersect', @(x) ismember(lower(x), {'x', 'y', 'union', 'intersect'}))
            p.addParameter('Hue', 2/3, @isnumeric);
            p.addParameter('HueDataRange', [], @isnumeric);
            p.addParameter('Title', '', @ischar)
            p.addParameter('Verbose', false, @islogical)
            p.parse(varargin{:})
            
            x = p.Results.x;
            y = p.Results.y;
            xThreshold = p.Results.xThreshold;
            yThreshold = p.Results.yThreshold;
            xname = p.Results.XLabel;
            yname = p.Results.YLabel;
            verbose = p.Results.Verbose;


            hold(ax, 'on')
    
            switch lower(p.Results.Highlight)
                case 'x'
                    sel = abs(x) >= xThreshold; 
                    if verbose
                        labelSig = sprintf('N=%g (%s)', nnz(sel), xname);
                    else
                        labelSig = sprintf('N=%g (x)', nnz(sel));
                    end
                case 'y'
                    sel = abs(y) >= yThreshold;    
                    if verbose
                        labelSig = sprintf('N=%g (%s)', nnz(sel), yname);
                    else
                        labelSig = sprintf('N=%g (y)', nnz(sel));
                    end
                case 'union'
                    sel = abs(x) >= xThreshold | abs(y) >= yThreshold;
                    if verbose
                        labelSig = sprintf('N=%g (%s or %s)', nnz(sel), xname, yname);
                    else
                        labelSig = sprintf('N=%g (x|y)', nnz(sel));
                    end
                case 'intersect'
                    sel = abs(x) >= xThreshold & abs(y) >= yThreshold;
                    if verbose
                        labelSig = sprintf('N=%g (%s and %s)', nnz(sel), xname, yname);
                    else
                        labelSig = sprintf('N=%g (x&y)', nnz(sel));
                    end
            end
            labelInsig = sprintf('N=%g', nnz(~sel));

            if length(p.Results.Hue) > 1
                hdata = p.Results.Hue(:);
                assert(length(hdata) == length(x))
                if ~isempty(p.Results.HueDataRange)
                    hdr = p.Results.HueDataRange;
                    maxHue = 2/3;
                    hdata = (hdata - hdr(1)) / (hdr(2) - hdr(1));
                    hdata = hdata * maxHue;
                end
                % hdata = (hdata - min(hdata))./(max(hdata) - min(hdata) + 1);
                hsl = [hdata, ones(length(x), 1), 0.5*ones(length(x), 1)];
                % Lower saturation for insig units.
                hsl(~sel, 2) = 0.2;
                colorSig = hsl2rgb(hsl(sel, :));
                colorInsig = hsl2rgb(hsl(~sel, :));
            else
                colorSig = hsl2rgb([p.Results.Hue, 1, 0.5]);
                colorInsig = hsl2rgb([p.Results.Hue, 0.2, 0.5]);
            end
            hSig = scatter(ax, x(sel), y(sel), 15, colorSig, 'filled', 'DisplayName', labelSig);
            hInsig = scatter(ax, x(~sel), y(~sel), 8, colorInsig, 'DisplayName', labelInsig);
            title(ax, p.Results.Title)
            xlabel(ax, xname)
            ylabel(ax, yname)
            hold(ax, 'off')
            hLegend = legend(ax, [hSig, hInsig], 'Location', 'northoutside', 'Orientation', 'horizontal', 'AutoUpdate', 'off');
            varargout = {ax, hSig, hInsig, hLegend};
        end

        function id = calculateConditionID(conditions, base)
            light = [conditions.light];
            duration = [conditions.duration];
            [~, lightRank] = ismember(light, unique(light));
            [~, durationRank] = ismember(duration, unique(duration));
            mlRank = [conditions.mlRank];
            dvRank = [conditions.dvRank];
            
            if nargin < 2
                base = max([max(lightRank), max(durationRank), max(mlRank), max(dvRank)]);
            end
            id = lightRank*(base^3) + durationRank*(base^2) + mlRank*(base^1) + dvRank*(base^0);
        end

        function pg = poolGroups(groups)
            function r = range(x)
                r = [min(x), max(x)];
                if r(1) == r(2)
                    r = r(1);
                end
            end

            if iscell(groups)
                allGroups = cat(2, groups{:});
            else
                allGroups = groups;
            end
            uniqueGroupHashes = unique([allGroups.groupHash]);
            pg(length(uniqueGroupHashes)) = struct('groupHash', [], 'hash', [], 'label', '', 'numTrials', [], 'light', [], 'duration', [], 'mlRank', [], 'dvRank', [], 'fiber', '', 'galvo', []);

            for i = 1:length(uniqueGroupHashes)
                groupHash = uniqueGroupHashes(i);
                sel = [allGroups.groupHash] == groupHash;
                pg(i).groupHash = groupHash;
                pg(i).hash = unique(cat(1, allGroups(sel).hash));
                pg(i).numTrials = range([allGroups(sel).numTrials]);
                pg(i).light = unique([allGroups(sel).light]);
                pg(i).duration = unique([allGroups(sel).duration]);
                pg(i).mlRank = unique([allGroups(sel).mlRank]);
                pg(i).dvRank = unique([allGroups(sel).dvRank]);
                pg(i).fiber = unique([allGroups(sel).fiber]);
                pg(i).galvo = unique([allGroups(sel).galvo]);
                pg(i).label = AcuteRecording.makeGroupLabel(pg(i).light, pg(i).duration, pg(i).mlRank, pg(i).dvRank);
            end
        end

        function pc = poolConditions(conditions, base)
            if nargin < 2
                base = []; % Use base >= 4, suggest 10 for readability, or leave empty to autocalculate.
            end

            assert(iscell(conditions) && length(conditions) > 1)
            for i = 1:length(conditions)
                id = AcuteRecording.calculateConditionID(conditions{i}, base);
                for j = 1:length(conditions{i})
                    conditions{i}(j).id = id(j);
                end
            end

            allConditions = conditions{1};
            for i = 2:length(conditions)
                allConditions = [allConditions, conditions{i}];
            end
            uniqueIDs = unique([allConditions.id]);
            pc(length(uniqueIDs)) = struct('id', [], 'label', [], 'numTrials', [], 'light', [], 'duration', [], 'fiber', [], 'galvo', [], 'mlRank', [], 'dvRank', [], 'linewidth', [], 'linecolor', []);
            for i = 1:length(uniqueIDs)
                id = uniqueIDs(i);
                sel = [allConditions.id] == id;
                pc(i).id = id;
                pc(i).numTrials = range([allConditions(sel).numTrials]);
                pc(i).light = range([allConditions(sel).light]);
                pc(i).duration = range([allConditions(sel).duration]);
                pc(i).fiber = unique([allConditions(sel).fiber]);
                pc(i).galvo = unique([allConditions(sel).galvo]);
                pc(i).mlRank = unique([allConditions(sel).mlRank]);
                pc(i).dvRank = unique([allConditions(sel).dvRank]);
                pc(i).linewidth = mean(unique([allConditions(sel).linewidth]));
                pc(i).linecolor = mean(vertcat(allConditions(sel).linecolor), 1);
                
                assert(length(pc(i).fiber) == 1)
                assert(length(pc(i).mlRank) == 1)
                assert(length(pc(i).dvRank) == 1)
                
                switch pc(i).mlRank
                    case 1
                        mlText = 'mStr';
                    case 2
                        mlText = 'lStr';
                end
                switch pc(i).dvRank
                    case 1
                        dvText = '-4.15';
                    case 2
                        dvText = '-3.48';
                    case 3
                        dvText = '-2.81';
                    case 4
                        dvText = '-2.15';
                end
                lightText = range2text(pc(i).light, '%.1f');
                durationText = range2text(pc(i).duration*1000, '%.0f');
                numTrialsText = range2text(pc(i).numTrials, '%.0f');
                
                pc(i).label = sprintf('%smW, %sms (%s %s) (%s trials)', lightText, durationText, mlText, dvText, numTrialsText);
            end
            
            function r = range(x)
                r = [min(x), max(x)];
                if r(1) == r(2)
                    r = r(1);
                end
            end
            
            function s = range2text(r, formatSpec)
                if length(r) == 1
                    s = sprintf(formatSpec, r);
                else
                    s = sprintf([formatSpec, '-', formatSpec], r(1), r(2));
                end
            end
        end

        function s = makeSelection(varargin)
            p = inputParser();
            p.addParameter('Light', [], @isnumeric);
            p.addParameter('Duration', [], @isnumeric);
            p.addParameter('ML', [], @isnumeric);
            p.addParameter('DV', [], @isnumeric);
            p.addParameter('Fiber', '', @ischar);
            p.addParameter('Galvo', [], @isnumeric);
            p.parse(varargin{:});

            s = struct('light', p.Results.Light, 'duration', p.Results.Duration, 'ml', p.Results.ML, 'dv', p.Results.DV, 'fiber', p.Results.Fiber, 'galvo', p.Results.Galvo);
        end

        function [ax, fig, nCols, nRows] = makeSubplots(nGroups, fig)
            if nargin < 2
                fig = figure('Units', 'normalized', 'Position', [0, 0, 0.4, 1]);
            end

            set(fig, 'Units', 'normalized');
            nCols = max(1, floor(sqrt(nGroups)));
            nRows = max(4, ceil(nGroups/nCols));
            ax = gobjects(nGroups, 1);
            spc = 0.075;
            w = (1 - spc*(nCols+1)) / nCols;
            h = (1 - spc*(nRows+1)) / nRows;
            for iGrp = 1:nGroups
                [row, col] = ind2sub([nRows, nCols], iGrp);
                ax(iGrp) = axes(fig, 'Position', [col*spc+(col-1)*w, row*spc+(row-1)*h, w, h]);
            end
        end

        function unifyAxesLims(ax)
            xlims = vertcat(ax.XLim);
            ylims = vertcat(ax.YLim);
            xrange = [min(xlims(:, 1)), max(xlims(:, 2))];
            yrange = [min(ylims(:, 1)), max(ylims(:, 2))];
            set(ax, 'XLim', xrange)
            set(ax, 'YLim', yrange)
            set(ax, 'XLimMode', 'manual')
            set(ax, 'YLimMode', 'manual')
        end

        function drawLines(ax, drawXY, drawDiag)
            if nargin < 2
                drawXY = true;
            end
            if nargin < 3
                drawDiag = false;
            end
            for i = 1:length(ax)
                hold(ax(i), 'on')
                xrange = [min(ax(i).XLim), max(ax(i).XLim)];
                yrange = [min(ax(i).YLim), max(ax(i).YLim)];
                if drawXY
                    plot(ax(i), xrange, [0, 0], 'k:')
                    plot(ax(i), [0, 0], yrange, 'k:')
                end
                if drawDiag
                    plot(ax(i), xrange, xrange, 'k:')
                end
                hold(ax(i), 'off')
            end
        end
    end

    methods (Static, Access = {})
        function x = lerp(a, b, t)
            if isnan(t)
                t = 0;
            end
            t = max(0, min(1, t));
            x = a + (b - a).*t;
        end

        function t = inverseLerp(a, b, x)
            t = (x - a) / (b - a);
            t = max(0, min(1, t));
        end

        function [peaks, I] = findpeaks(x, varargin)
            % Find local maxima and minima (maginitue must be greater than
            % threshold (default 0). If no peak found, use max(abs).
            p = inputParser();
            p.addRequired('X', @isnumeric)
            p.addOptional('Threshold', 0, @isnumeric)
            p.parse(x, varargin{:})
            x = p.Results.X;
            threshold = p.Results.Threshold;
            
            x = [0, x(:)'];
            
            df = [0, diff(x)];
            df1 = df > 0;
            df2 = df <= 0;
            df3 = df < 0;
            df4 = df >= 0;
            I = find(abs(x) > threshold & ((df1 & circshift(df2, -1)) | (df3 & circshift(df4, -1))));
            if ~isempty(I)
                peaks = x(I);
                I = I - 1;
            else
                x = x(2:end);
                [peaks, I] = max(abs(x));
            end
        end

        function label = makeGroupLabel(light, duration, varargin)
            p = inputParser();
            p.addRequired('light', @isnumeric);
            p.addRequired('duration', @isnumeric);
            p.addOptional('mlRank', [], @isnumeric);
            p.addOptional('dvRank', [], @isnumeric);
            p.parse(light, duration, varargin{:})
            light = p.Results.light;
            duration = p.Results.duration;
            mlRank = p.Results.mlRank;
            dvRank = p.Results.dvRank;

            function txt = rangetxt(x, fmt)
                if nargin < 2
                    fmt = '%g';
                end
                if isempty(x)
                    txt = '';
                elseif min(x) == max(x)
                    txt = sprintf(fmt, min(x));
                else
                    txt = sprintf([fmt, '-', fmt], min(x), max(x));
                end
            end

            label = sprintf('%smW %sms', rangetxt(light, '%.1f'), rangetxt(duration*1000, '%g'));

            if length(mlRank) == 1
                switch mlRank
                    case 1
                        mlText = 'mStr';
                    case 2
                        mlText = 'lStr';
                end
            else
                mlText = '';
            end

            if length(dvRank) == 1
                switch dvRank
                    case 1
                        dvText = '-4.15';
                    case 2
                        dvText = '-3.48';
                    case 3
                        dvText = '-2.81';
                    case 4
                        dvText = '-2.15';
                end
            else
                dvText = '';
            end

            if isempty(mlText) && isempty(dvText)
                return
            elseif isempty(mlText)
                label = sprintf('%s (%s)', label, dvText);
            elseif isempty(dvText)
                label = sprintf('%s (%s)', label, mlText);
            else
                label = sprintf('%s (%s %s)', label, mlText, dvText);
            end
        end
    end
end