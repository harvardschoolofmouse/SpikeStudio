classdef CollisionTest < handle
    properties
        SampleRate = NaN
        Data = []
        Timestamps = []
        PulseOn = []
        PulseOff = []
        TrainOn = []
        TrainOff = []
        Window = [0, 0]
        Filename
        ExpName = ''
        Spikes
        IsSorted = false
        SysInitDelay = 0
    end

    properties (Transient, Access = {})
        TR
        PTR
    end

    %% Constructor/Read/Write
    % Public methods
    methods
        % Constructor
        function obj = CollisionTest(varargin)
        %CollisionTest - Class for analyzing antidromic stimulation/and runnung collision tests.
        %
        % Syntax: ct = CollisionTest()
        % 
        % Optional Parameters: 
        % 'Folder'          - Skips file selection prompt if a valid path is provided.
        % 'Read'            - (Default TRUE) Whether or not to read tr/ptr/ns5 files. 
        % 'Channels'        - Which channels to look at. This is channel ID as shown in TetrodeRecording.PlotChannel([]). Leave empty to use all channels.
        % 'MaxTrains'       - Limit how many stim trains will be read.
        % 'ExtendedWindow'  - (ms) Extended window for reading data.
        % 
        % 
            p = inputParser();
            p.addParameter('Folder', '', @ischar);
            p.addParameter('Read', true, @islogical);
            p.addParameter('TRSource', 'SortedOnly', @ischar); % 'SortedOnly', 'SortedOrRaw', 'RawOnly'
            p.addParameter('Channels', [], @isnumeric); % Which channels to look at. This is channel ID as shown in TetrodeRecording.PlotChannel([])
            p.addParameter('MaxTrains', [], @isnumeric); % Limit how many stim trains will be read.
            p.addParameter('ExtendedWindow', [0, 0], @(x) isnumeric(x) && length(x) == 2); % (ms) Extended window for reading data.
            p.parse(varargin{:});
            folder = p.Results.Folder;
            doRead = p.Results.Read;
            obj.Window = p.Results.ExtendedWindow;

            % File selection prompt if folder not specified during constructor call.
            if isempty(folder)
                folder = uipickfiles('Prompt', 'Select a folder containing an ns5 file.', 'NumFiles', 1);
                folder = folder{1};
            end

            % Validate folder
            [~, obj.Filename, obj.ExpName, allValid, obj.IsSorted] = CollisionTest.validateFolders(folder, 'SuppressWarnings', true, 'TRSource', p.Results.TRSource);
            if ~allValid
                error('Invalid folder %s', folder);
            end

            if (doRead)
                obj.read(p.Results.Channels, p.Results.MaxTrains, p.Results.ExtendedWindow ./ 1000);
            end
        end

        function save(obj, varargin)
        %save - Save the object to a .mat file.
        %
        % Syntax: save(obj, varargin)
        % - 'Filename': Designate specific save path.
        % 
            p = inputParser();
            p.addOptional('Filename', '', @ischar);
            p.addOptional('SeparateFiles', false, @islogical);
            p.parse(varargin{:});
            filename = p.Results.Filename;
            separateFiles = p.Results.SeparateFiles;

            % Only one object, or user chose to save all objects to one file.
            if (length(obj) == 1 || ~separateFiles)
                if (isempty(filename))
                    if (length(obj) == 1)
                        defaultName = sprintf('ct_%s.mat', obj.ExpName);
                    else
                        defaultName = 'ct.mat';
                    end
                    uisave('obj', defaultName);
                else
                    tTic = tic; fprintf('Writing to file "%s"...', filename)
                    save(filename, 'obj', '-v7.3');
                    fprintf('Done (%.1f s).\n', toc(tTic))
                end
            % More than one object, user chose to save them to separate files.
            else
                selPath = uigetdir();
                allObjs = obj;
                for iObj = 1:length(obj)
                    obj = allObjs(iObj);
                    filename = sprintf('%s\\ct_%s', selPath, obj.ExpName);
                    tTic = tic; fprintf('Writing to file "%s"...', filename)
                    save(filename, 'obj', '-v7.3');
                    fprintf('Done (%.1f s).\n', toc(tTic))
                end
                obj = allObjs;
            end

        end
    end

    % Public static methods
    methods (Static)
        function varargout = batch(varargin)
        %Batch - Batch generate and save CollisionTest objects from tr/ptr/ns5 files.
        %
        % Optional Parameters: 
        % 'ExtendedWindow'  - (ms) Extended window for reading data.
        % 
        % Syntax: Batch(varargin)
        %
            p = inputParser();
            p.addParameter('ExtendedWindow', [-20, 20], @(x) isnumeric(x) && length(x) == 2 && diff(x) > 0);
            p.addParameter('OnError', 'WarningLong', @ischar); % What to do when there is an error. Can be 'WarningShort', 'WarningLong', 'Error'
            p.addParameter('TRSource', 'SortedOnly', @ischar); % 'SortedOnly', 'SortedOrRaw', 'RawOnly'
            p.parse(varargin{:});
            onError = p.Results.OnError;

            folders = uipickfiles('Prompt', 'Select multiple folders each containing an ns5 file.');

            folders = CollisionTest.validateFolders(folders, 'SuppressWarnings', false, 'TRSource', p.Results.TRSource);

            for iFolder = 1:length(folders)
                try
                    folder = folders{iFolder};
                    fprintf('Processing folder %d of %d - %s:\n', iFolder, length(folders), folder);
    
                    ct = CollisionTest('Folder', folder, 'ExtendedWindow', p.Results.ExtendedWindow, 'TRSource', p.Results.TRSource);
    
                    % Make sure save path exists
                    saveFolder = sprintf('%s//..//CollisionTest', folder);
                    if ~isfolder(saveFolder)
                        mkdir(saveFolder);
                    end
                    if ct.IsSorted
                        ct.save(sprintf('%s//ct_sorted_%s.mat', saveFolder, ct.ExpName));
                    else
                        ct.save(sprintf('%s//ct_%s.mat', saveFolder, ct.ExpName));
                    end
                catch ME
                    if (strcmpi(onError, 'Error'))
                        error('Error when processing folder "%s".', folder);
                    end
                    warning('Error when processing folder "%s". This one will be skipped.', folder);
                    if (strcmpi(onError, 'WarningLong'))
                        warning('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message)
                    end
                end
            end

            varargout = {ct}; % Only the last ct is exported.
            TetrodeRecording.RandomWords();
        end

        function ct = load(files)
        %Load - Load multiple ct files.
        %
            if nargin < 1
                files = uipickfiles('Prompt', 'Select (multiple) .mat files containing an CollisionTest object named "obj"', 'FilterSpec', '*.mat');
            end

            for iFile = 1:length(files)
                S(iFile) = load(files{iFile}, 'obj');
            end

            ct = [S.obj];
            ct.removeEmptySpikes();
        end
    end

    % Private methods
    methods (Access = {})
        function read(obj, channels, maxTrains, extendedWindow)
        %read - Read data from tr/ptr/ns5 files.
        % Syntax: read(obj, varargin)
            obj.readTR();

            [obj.PulseOn, obj.PulseOff, obj.TrainOn, obj.TrainOff] = obj.readDigitalEvents();
            [obj.Data, obj.Timestamps, obj.SampleRate, obj.SysInitDelay] = readAnalogTrains(obj, channels, maxTrains, extendedWindow, obj.TrainOn, obj.TrainOff);

            obj.readSpikes();
            obj.removeEmptySpikes();
        end

        function varargout = readDigitalEvents(obj)
        %readDigitalEvents - Read digital events (stimulus onsets & offsets).
            % Read digital events
			cueOn = sort(obj.TR.DigitalEvents.CueOn);
			pulseOn = sort(obj.TR.DigitalEvents.StimOn);
			pulseOff = sort(obj.TR.DigitalEvents.StimOff);

			% Get the start and end timestamps of a stim train.
			[~, trainOn] = TetrodeRecording.FindFirstInTrial(cueOn, pulseOn);
            [~, trainOff] = TetrodeRecording.FindLastInTrial(cueOn, pulseOff);
            
            varargout = {pulseOn, pulseOff, trainOn, trainOff};
        end

        function sysInitDelay = getSysInitDelay(obj)
            NSx = openNSx(obj.Filename.NSx, 'read', 'channels', 1, 'duration', [0, 20], 'sec');
            sampleRate = obj.SampleRate;
            if iscell(NSx.Data)
                if length(NSx.Data) == 2
                    sysInitDelay = size(NSx.Data{1}, 2) / sampleRate;
                else
                    error("NSx.Data is a cell array of length %d. This is not supported. It should be 2.", length(NSx.Data))
                end
            else
                sysInitDelay = 0;
            end
        end

        function [data, timestamps, sampleRate, sysInitDelay] = readAnalogTrains(obj, channels, maxTrains, extendedWindow, trainOn, trainOff)
        %readAnalogTrains - Read analog data (only during stim trains).
            if ~isempty(maxTrains)
                trainOn = trainOn(1:maxTrains);
                trainOff = trainOff(1:maxTrains);
            end

            if isempty(channels)
                channels = [obj.TR.Spikes.Channel];
            end

            sampleRate = obj.TR.FrequencyParameters.AmplifierSampleRate;

            % Pre-allocate
            nsxChannels =  obj.mapChannels(channels, 'From', 'TR', 'To', 'NSx');
            maxTrainLength = max(trainOff - trainOn) + diff(extendedWindow);
            maxTrainLength = ceil(sampleRate * maxTrainLength);

            dataByTrain = NaN(length(trainOn), maxTrainLength, length(channels));
            timestampsByTrain = NaN(length(trainOn), maxTrainLength);

            % Read data from each train and put them in an array.

            % Get sysInitDelay to shift openNSx window to the correct value.
            
            % [Deprecated] read SysInitDelay from TetrodeRecording object - we can't trust sysInitDelay from TetrodeRecording for some reason. re-read the first 20 seconds of the .NSx file to get it.
            % sysInitDelay = obj.TR.FrequencyParameters.SysInitDelay.Duration; 
            % if isnan(sysInitDelay)
            %     sysInitDelay = 0;
            % end

            sysInitDelay = obj.getSysInitDelay();
            
            tTic = tic();
            fprintf('Reading %d trains, %d channels...', length(trainOn), length(channels));

            for iTrain = 1:length(trainOn)
                trainWindow = [trainOn(iTrain), trainOff(iTrain)] + extendedWindow;

                % Read window for NSx file. Must shift to the right by sysInitDelay to exclude discarded data when the other rig started.
                readWindow = trainWindow + sysInitDelay;

                NSx = openNSx(obj.Filename.NSx, 'read', 'channels', nsxChannels, 'duration', readWindow, 'sec');
                numSamples = size(NSx.Data, 2);

                dataByTrain(iTrain, 1:numSamples, :) = reshape(transpose(NSx.Data), 1, numSamples, []);
                % timestampsByTrain(iTrain, 1:numSamples) = (firstSampleIndex : firstSampleIndex + numSamples - 1) / sampleRate;
                % timestampsByTrain(iTrain, 1:numSamples) = readWindow(1):1/sampleRate:readWindow(2);
                timestampsByTrain(iTrain, 1:numSamples) = trainWindow(1) : (1 / sampleRate) : (trainWindow(1) + (numSamples - 1) * 1/sampleRate);
            end

            data = reshape(permute(dataByTrain, [2, 1, 3]), size(dataByTrain, 1) * size(dataByTrain, 2), []);
            timestamps = reshape(permute(timestampsByTrain, [2, 1]), [], 1);

            hasData = ~isnan(timestamps);
            data = data(hasData, :);
            timestamps = timestamps(hasData);

            if (~CollisionTest.validateTimestamps(timestamps))
                error('Timestamps are not monotonic increasing. Digital events data probably needs to be trimmed.')
            end

            fprintf('Done (%.2f) s.\n', toc(tTic));
        end

        function readTR(obj, varargin)
        %read - Load TR/PTR files.
        % Syntax: obj.readTR('Sorted', false)
            p = inputParser();
            p.addParameter('Raw', true, @islogical);
            p.parse(varargin{:});
            readRaw = p.Results.Raw;

            obj.PTR = TetrodeRecording.BatchLoad({obj.Filename.PTR});
            obj.TR = TetrodeRecording.BatchLoad(obj.Filename.TR);
        end

        function readSpikes(obj)
        %read - Load and process sorted spikeTimes/waveforms from TR.Spikes.
        % Syntax: obj.readSpikes()
            for iChn = [obj.TR.Spikes.Channel]
                obj.Spikes(iChn).Channel = iChn;
                obj.Spikes(iChn).RawChannel = obj.mapChannels(iChn);
                obj.Spikes(iChn).WaveformWindow = obj.TR.Spikes(iChn).WaveformWindow;
                obj.Spikes(iChn).WaveformTimestamps = obj.TR.Spikes(iChn).WaveformTimestamps;
                for iUnit = unique(obj.TR.Spikes(iChn).Cluster.Classes)
                    theseIndices = obj.TR.Spikes(iChn).Cluster.Classes == iUnit;
                    theseWaveforms = obj.TR.Spikes(iChn).Waveforms(theseIndices, :);
                    obj.Spikes(iChn).Units(iUnit).Timestamps = obj.TR.Spikes(iChn).Timestamps(theseIndices);
                    obj.Spikes(iChn).Units(iUnit).Waveform.Mean = mean(theseWaveforms, 1);
                    obj.Spikes(iChn).Units(iUnit).Waveform.STD = std(theseWaveforms, 0, 1);
                    obj.Spikes(iChn).Units(iUnit).Waveform.Percentile95 = prctile(theseWaveforms, 95, 1);
                    obj.Spikes(iChn).Units(iUnit).Waveform.Percentile05 = prctile(theseWaveforms, 5, 1);
                end
            end
        end

        function removeEmptySpikes(obj)
            for iObj = 1:length(obj)
                emptyIndices = cellfun(@isempty, {obj(iObj).Spikes.Channel});
                if nnz(emptyIndices) > 0
                    obj(iObj).Spikes(emptyIndices) = [];
                    fprintf(1, 'Removed %d empty channels.\n', nnz(emptyIndices));
                end
            end
        end

        function outChannels = mapChannels(obj, channels, varargin)
        %mapChannels - Convert TR channel labels (1:n continuous) to NSx file channels (1:N continuous). n: number of spike sorted channels. N: number of recorded channels including both rigs.
            p = inputParser();
            p.addRequired('Channels', @isnumeric);
            p.addParameter('From', 'TR', @ischar);
            p.addParameter("To", "NSx", @ischar);
            p.parse(channels, varargin{:});
            channels = p.Results.Channels;
            from = p.Results.From;
            to = p.Results.To;

            switch lower(from)
                case 'tr'

                otherwise
                    warning('%s is not an acceptable value for argument "From". Only "TR" is supported.', from);
            end

            switch lower(to)
                case 'nsx'
                    % Find out which rig we're using. Rig2 data is appended after rig1.
                    rig = TetrodeRecording.GetRig(obj.Filename.NSx);
                    if (rig == 1)
                        channelMap = obj.PTR.ChannelMap.Rig1;
                    else
                        channelMap = obj.PTR.ChannelMap.Rig2;
                    end
        
                    % Channel label conversion:
                    channelMap = channelMap(obj.PTR.SelectedChannels);
                    outChannels = channelMap(channels);
                    return

                case 'data'
                    [~, outChannels] = ismember(channels, [obj.Spikes.Channel]);
                    outChannels(isnan(outChannels)) = NaN;
                    return

                otherwise
                    warning('%s is not an acceptable value for argument "To". Only "NSx" or "Data" is supported.', to);
            end
        end
    end

    % Private static methods
    methods (Access = {}, Static)

        function isMonoIncrease = validateTimestamps(array)
            isIncrease = diff(array) > 0;
            isMonoIncrease = nnz(isIncrease) == length(array) - 1;
        end

        function varargout = validateFolders(folders, varargin)
            p = inputParser();
            p.addRequired('Folders', @(x) iscell(x) || ischar(x));
            p.addParameter('SuppressWarnings', false, @islogical);
            p.addParameter('Sorted', false, @islogical);
            p.addParameter('TRSource', 'SortedOnly', @ischar); % 'SortedOnly', 'SortedOrRaw', 'RawOnly'
            p.parse(folders, varargin{:});
            folders = p.Results.Folders;
            suppressWarnings = p.Results.SuppressWarnings;
            trSource = p.Results.TRSource;

            allValid = true;
            validFolders = {};

            % Convert single folder in string format to cell.
            if ischar(folders)
                folders = {folders};
            end

            % Make sure all folders are valid, filter out bad ones.
            for iFolder = 1:length(folders)
                folder = folders{iFolder};

                % Check folder for NSx files
                if (isfolder(folder))
                    nsx = dir(sprintf('%s\\*.ns5', folder));
                    if length(nsx) > 1
                        nsx = nsx(1);
                        if ~suppressWarnings
                            warning('More than one .ns5 file is detected in "%s" but only the first one is used. This may lead to unexpected results.', folder)
                        end
                    elseif length(nsx) < 1
                        if ~suppressWarnings
                            warning('No .ns5 file detected in "%s".', folder)
                        end
                        allValid = false;
                        continue
                    end
                else
                    if ~suppressWarnings
                        warning('Selected path "%s" is not a folder.', folder)
                    end
                end

                % Determine experiment name
                expName = strsplit(nsx.name, '.ns5');
                expName = expName{1};

                % Find corresponding TR/PTR files in SpikeSort folder.
                spikeSortFolder = sprintf('%s\\..\\SpikeSort', nsx.folder);
                switch lower(trSource)
                    case 'sortedonly'
                        tr = dir(sprintf('%s\\tr_sorted_%s*.mat', spikeSortFolder, expName));
                        isSorted = true;
                    case 'rawonly'
                        tr = dir(sprintf('%s\\tr_%s*.mat', spikeSortFolder, expName));
                        isSorted = false;
                    case 'sortedorraw'
                        tr = dir(sprintf('%s\\tr_sorted_%s*.mat', spikeSortFolder, expName));
                        isSorted = true;
                        if isempty(tr)
                            tr = dir(sprintf('%s\\tr_%s*.mat', spikeSortFolder, expName));
                            isSorted = false;
                        end
                end
                ptr = dir(sprintf('%s\\ptr_%s.mat', spikeSortFolder, expName));

                % Make sure TR/PTR files exist
                if isempty(tr) || isempty(ptr)
                    if ~suppressWarnings
                        if isSorted
                            trFilePattern = sprintf('tr_sorted_%s*.mat', expName);
                        else
                            trFilePattern = sprintf('tr_%s*.mat', expName);
                        end
                        warning('Some of the following files could not be found: \n\t%s; \n\t"ptr_%s.mat".', trFilePattern, expName)
                    end
                    allValid = false;
                    continue
                end

                if (length(ptr) > 1) 
                    ptr = ptr(1);
                    if ~suppressWarnings
                        warning('More than one (%d) ptr file was found but only the first one is used. This may lead to unexpected results.', length(ptr));
                    end
                end

                validFolders = [validFolders, folder];

                % Store file names
                Filename(iFolder).NSx = sprintf('%s\\%s', nsx.folder, nsx.name);
                Filename(iFolder).NEV = sprintf('%s\\%s.nev', nsx.folder, expName);
                Filename(iFolder).PTR = sprintf('%s\\%s', ptr.folder, ptr.name);
                for iTr = 1:length(tr)
                    Filename(iFolder).TR{iTr} = sprintf('%s\\%s', tr(iTr).folder, tr(iTr).name);
                end
            end

            varargout = {validFolders, Filename, expName, allValid, isSorted};
        end
    end

    %% Plotting
    methods
        function plot(obj, channel, varargin)
        %plot - Plot electrode data aligned on stimulation onset events.
        % Syntax: plot(obj, channel, varargin)
        %   Press Down arrow key/Mouse wheel down to go to next page.
        %   Press Up arrow key/Mouse wheel up to go to previous page.
        %   Shift/Alt + Up/Down arrow keys to speed up.
            p = inputParser();
            p.addRequired('Channel', @(x) isnumeric(x) || ischar(x));
            p.addParameter('Start', 1, @isnumeric);
            p.addParameter('TracesPerPage', 25, @isnumeric);
            p.addParameter('YLim', [-500, 500], @(x) isnumeric(x) && length(x) == 2 && diff(x) > 0);
            p.addParameter('XLim', obj.Window, @(x) isnumeric(x) && length(x) == 2 && diff(x) > 0);
            p.addParameter('YSpacing', 1, @(x) isnumeric(x) && length(x) == 1);
            p.addParameter('Units', [], @isnumeric);
            p.addParameter('OverlayUnitTraces', false, @islogical);
            p.addParameter('SortPulsesByUnit', NaN, @(x) isnumeric(x) && length(x) == 1);
            p.addParameter('SortPulsesByUnitTimeCutoff', 5e-4, @isnumeric);
            p.addParameter('CollisionCutoff', 1e-3, @isnumeric);
            p.addParameter('LimitPulseDuration', [0, Inf], @(x) isnumeric(x) && length(x) >= 2 && x(end) >= x(1))
            p.addParameter('LimitPulseDurationTolerance', 1e-4, @(x) isnumeric(x) && length(x) == 1)
            p.parse(channel, varargin{:})
            xRange = p.Results.XLim;

            if ischar(channel) && strcmpi(channel, 'all')
                for iChn = [obj.Spikes.Channel]
                    obj.plot(iChn, 'Start', p.Results.Start, 'TracesPerPage', p.Results.TracesPerPage, 'YLim', p.Results.YLim, 'XLim', p.Results.XLim,...
                        'YSpacing', p.Results.YSpacing, 'Units', p.Results.Units, 'OverlayUnitTraces', p.Results.OverlayUnitTraces,...
                        'SortPulsesByUnit', p.Results.SortPulsesByUnit, 'SortPulsesByUnitTimeCutoff', p.Results.SortPulsesByUnitTimeCutoff,...
                        'CollisionCutoff', p.Results.CollisionCutoff, 'LimitPulseDuration', p.Results.LimitPulseDuration, 'LimitPulseDurationTolerance', p.Results.LimitPulseDurationTolerance);
                end
                return
            end

            if isempty(channel)
                channel = obj.Spikes(1).Channel;
            end

            % Sort pulses by last spikeTime before pulse on
            sortPulsesByUnit = p.Results.SortPulsesByUnit;
            sortPulsesByUnitTimeCutoff = p.Results.SortPulsesByUnitTimeCutoff;
            if ~isnan(sortPulsesByUnit)
                [~, pulseOrder, spikeToPulseLatency] = obj.sortPulses(channel, sortPulsesByUnit, sortPulsesByUnitTimeCutoff);
            else
                pulseOrder = 1:length(obj.PulseOn);
            end

            % Selected Pulses by duration
            [pulseOrder, ~] = obj.selectPulsesByDuration(p.Results.LimitPulseDuration(1), p.Results.LimitPulseDuration(end), 'Tolerance', p.Results.LimitPulseDurationTolerance, 'PulseOrder', pulseOrder);

            % Figure layout
            xSpacing = 0.05;
            ySpacing = 0.075;

            % Create figure
            fig = figure('Units', 'normalized', 'OuterPosition', [0, 0.05, 1, 0.95]);
            ax = axes(fig, 'Units', 'normalized', 'Position', [xSpacing, ySpacing, 0.5 - 2 * xSpacing, 1 - 2 * ySpacing], 'Tag', 'Raster');
            ax2 = axes(fig, 'Units', 'normalized', 'Position', [0.5 + xSpacing, 0.67 + ySpacing, 0.25 - 2 * xSpacing, 0.33 - 2 * ySpacing]);
            ax3 = axes(fig, 'Units', 'normalized', 'Position', [0.5 + xSpacing, 0.33 + ySpacing, 0.5 -  2 * xSpacing, 0.33 - 2 * ySpacing]);

            ax.YDir = 'reverse';
            grid(ax, 'on');
            hold(ax, 'on');
            xlim(ax, xRange);

            xlabel(ax, 'Time from stim on (ms)')
            ylabel(ax, 'Trial number + Normalized voltage (a.u.)')


            % Plot the first page
            obj.updatePlot(ax, p, p.Results.Start, pulseOrder);

            % Keypress listeners for updating the plot.
            fig.WindowKeyPressFcn       = {@obj.onWindowKeyPress, p, pulseOrder};
            fig.WindowScrollWheelFcn    = {@obj.onWindowKeyPress, p, pulseOrder};

            % Plot unit mean waveforms
            obj.plotWaveforms(ax2, channel);

            % Plot mean traces by collision windows
            if ~isnan(sortPulsesByUnit)
                obj.plotMeanByCollision(ax3, p, spikeToPulseLatency, pulseOrder);
            end
        end
    end

    % Plotting, private
    methods (Access = {})
        function onWindowKeyPress(obj, fig, event, p, pulseOrder)
            if isa(event, 'matlab.ui.eventdata.ScrollWheelData')
                if (event.VerticalScrollCount < 0)
                    direction = 'up';
                else
                    direction = 'down';
                end
                turbo = 1;
            elseif isa(event, 'matlab.ui.eventdata.KeyData')
                if strcmp(event.Key, 'uparrow')
                    direction = 'up';
                elseif strcmp(event.Key, 'downarrow')
                    direction = 'down';
                else
                    return
                end
                shift = ismember('shift', event.Modifier);
                alt = ismember('alt', event.Modifier);

                if shift && alt
                    turbo = Inf;
                elseif alt
                    turbo = 10;
                elseif shift
                    turbo = 5;
                else
                    turbo = 1;
                end
            else
                return
            end

            ax = fig.findobj('Type', 'axes', 'Tag', 'Raster');

            if strcmp(direction, 'down')
                startTrace = min(ax.UserData.StartTrace + turbo * p.Results.TracesPerPage, length(pulseOrder));
            elseif strcmpi(direction, 'up')
                startTrace = max(ax.UserData.StartTrace - turbo * p.Results.TracesPerPage, 1);
            else
                return
            end

            obj.updatePlot(ax, p, startTrace, pulseOrder);
        end

        function updatePlot(obj, ax, p, startTrace, pulseOrder)
            trChannel = p.Results.Channel;
            pulseOn = obj.PulseOn(pulseOrder);
            pulseOff = obj.PulseOff(pulseOrder);
            channel = obj.mapChannels(trChannel, 'From', 'TR', 'To', 'Data');

            tracesPerPage = p.Results.TracesPerPage;
            yRange = p.Results.YLim;
            ySpacing = p.Results.YSpacing;

            % Store startTrace
            ax.UserData.StartTrace = startTrace;

            cla(ax);

            plotWindow = 0.001 * obj.Window;

            % Normalize voltage data and align to stimOnsetTime;
            for iPulse = startTrace:startTrace + tracesPerPage - 1

                iPulseInPage = iPulse - startTrace + 1;

                isInPlotWindow = obj.Timestamps > pulseOn(iPulse) + plotWindow(1) & obj.Timestamps <= pulseOn(iPulse) + plotWindow(2);
                pulseData = obj.Data(isInPlotWindow, channel);
                pulseTimestamps = obj.Timestamps(isInPlotWindow);

                % Normalize voltage to yRange.
                y = -(pulseData - yRange(1)) ./ diff(yRange) + iPulse * ySpacing + 0.5;
                
                % Align time to stimOn
                t = 1000 * (pulseTimestamps - pulseOn(iPulse));

                % Plot trace
                plot(ax, t, y, 'k');

                % Plot stim window
                stimOnVertices(2 * iPulseInPage - 1: 2 * iPulseInPage, 1) = 0;
                stimOnVertices(2 * iPulseInPage - 1: 2 * iPulseInPage, 2) = [iPulse * ySpacing, iPulse * ySpacing + 1] - 0.5;
                stimOffVertices(2 * iPulseInPage - 1: 2 * iPulseInPage, 1) = 1000 * (pulseOff(iPulse) - pulseOn(iPulse));
                stimOffVertices(2 * iPulseInPage - 1: 2 * iPulseInPage, 2) = [iPulse * ySpacing, iPulse * ySpacing + 1] - 0.5;

                colors = 'rgbcmyk';

                % Plot sorted spike timestamps
                units = p.Results.Units;
                if isempty(units)
                    units = 1:max(1, length(obj.Spikes(channel).Units) - 1);
                end
                for iUnit = units
                    unitTimestamps = obj.Spikes(channel).Units(iUnit).Timestamps;
                    isInPlotWindow = unitTimestamps > pulseOn(iPulse) + plotWindow(1) & unitTimestamps <= pulseOn(iPulse) + plotWindow(2);
                    t = 1000 * (unitTimestamps(isInPlotWindow) - pulseOn(iPulse));
                    y = repmat(iPulse * ySpacing, [nnz(isInPlotWindow), 1]);
                    plot(ax, t, y, sprintf('%so', colors(iUnit)), 'MarkerSize', 20);

                    if p.Results.OverlayUnitTraces
                        if isempty(obj.TR)
                            obj.readTR();
                        end

                        trTimestamps = obj.TR.Spikes(trChannel).Timestamps;
                        isInPlotWindow = trTimestamps > pulseOn(iPulse) + plotWindow(1) & trTimestamps <= pulseOn(iPulse) + plotWindow(2);

                        iSelWaveforms = find(isInPlotWindow);

                        for iWave = iSelWaveforms
                            t = 1000 * (trTimestamps(iWave) - pulseOn(iPulse)) + obj.TR.Spikes(trChannel).WaveformTimestamps;
                            y = obj.TR.Spikes(trChannel).Waveforms(iWave, :);
                            y = -(y - yRange(1)) ./ diff(yRange) + iPulse * ySpacing + 0.5;
                            iCluster = obj.TR.Spikes(trChannel).Cluster.Classes(iWave);
                            if ismember(iCluster, units)
                                thisColor = colors(iCluster);
                                plot(ax, t, y, 'Color', thisColor, 'LineWidth', 1.5);
                            end
                        end

                        obj.TR.Spikes(trChannel);

                    end
                end

                if iPulse >= length(pulseOrder)
                    break
                end
            end

            % Page done
            stimPatchVertices = vertcat(stimOnVertices, stimOffVertices(end:-1:1, :));
            patch(ax, 'XData', stimPatchVertices(:, 1), 'YData', stimPatchVertices(:, 2), 'FaceColor', [77, 190, 238] / 255, 'FaceAlpha', 0.33, 'EdgeAlpha', 0);
            ylim(ax, [(iPulse - iPulseInPage + 1) * ySpacing - .5, iPulse * ySpacing + .5])
            yticks(ax, startTrace:5:startTrace + tracesPerPage - 1) 
            title(ax, sprintf('%s Chn%d (Pulses %d - %d)', obj.ExpName, trChannel, iPulse - iPulseInPage + 1, iPulse), 'Interpreter', 'none')
        end

        function plotMeanByCollision(obj, ax, p, spikeToPulseLatency, pulseOrder)
            trChannel = p.Results.Channel;
            channel = obj.mapChannels(trChannel, 'From', 'TR', 'To', 'Data');

            plotWindow = 0.001 * obj.Window(2);
            numSamples = ceil(plotWindow * obj.SampleRate);

            % Sorted/duration-selected versions of things
            spikeToPulseLatency = spikeToPulseLatency(pulseOrder);
            pulseOn = obj.PulseOn(pulseOrder);
            
            % Group pulses by latency
            latencyEdges = unique([min(spikeToPulseLatency), sort(p.Results.CollisionCutoff), max(spikeToPulseLatency)]);
            [numTracesPerBin, ~, bin] = histcounts(spikeToPulseLatency, latencyEdges);
            
            % Pre-allocate bins
            uniqueBins = reshape(unique(bin), 1, []);
            for iBin = uniqueBins % This skips empty bins
                Bin(iBin).Traces = NaN(numTracesPerBin(iBin), numSamples); % Preallocate
                Bin(iBin).NumTraces = 0;
            end

            % Group pulses by bin
            for iTrace = 1:length(pulseOn)
                iBin = bin(iTrace);

                iSampleStart = find(obj.Timestamps >= pulseOn(iTrace), 1, 'first');
                selSamples = iSampleStart : iSampleStart + numSamples - 1;

                Bin(iBin).Traces(Bin(iBin).NumTraces + 1, :) = obj.Data(selSamples, channel);
                Bin(iBin).NumTraces = Bin(iBin).NumTraces + 1;
            end

            % For each bin, calculate mean trace, std, prctile(5, 95)
            for iBin = uniqueBins
                Bin(iBin).Mean = nanmean(Bin(iBin).Traces, 1);
                Bin(iBin).Std = nanstd(Bin(iBin).Traces, 0, 1);
                Bin(iBin).Percentiles = prctile(Bin(iBin).Traces, [5, 95], 1);
            end

            % Common timestamps for all traces
            t = 0:numSamples - 1;
            t = 1000 * t / obj.SampleRate;

            % Plot mean traces of potential collision trials vs. regular trials.
            hold(ax, 'on')
            xlabel(ax, 'Time from stim on (ms)')
            ylabel(ax, 'Mean voltage (mV)')
            title(ax, sprintf('%s Chn %i, Unit %i', obj.ExpName, trChannel, p.Results.SortPulsesByUnit), 'Interpreter', 'none')
            colors = 'rgbcmyk';

            for i = 1:length(uniqueBins)
                iBin = uniqueBins(i);
                h(i) = plot(ax, t, Bin(iBin).Mean, colors(i), 'LineWidth', 2, 'DisplayName', sprintf('StimLatency \\in [%.1f, %.1f) ms (n = %d)', 1000 * latencyEdges(iBin), 1000 * latencyEdges(iBin + 1), numTracesPerBin(iBin)));
                patch(ax, [t, flip(t)], [Bin(iBin).Mean - Bin(iBin).Std, flip(Bin(iBin).Mean + Bin(iBin).Std)], colors(i),...
                    'FaceAlpha', .1, 'EdgeColor', colors(i), 'LineStyle', 'none');
                % patch(ax, [t, flip(t)], [Bin(iBin).Percentiles(1, :), flip(Bin(iBin).Percentiles(2, :))], colors(i),...
                %     'FaceAlpha', .1, 'EdgeColor', colors(i), 'LineStyle', ':');
            end

            hold(ax, 'off')

            legend(h)
        end

        function plotWaveforms(obj, ax, channel)
            trChannel = channel;
            channel = obj.mapChannels(channel, 'From', 'TR', 'To', 'Data');

            xlabel(ax, 'Time (ms)')
            ylabel(ax, 'Voltage (mV)')
            title(ax, sprintf('%s Chn %i', obj.ExpName, trChannel), 'Interpreter', 'none')
            hold(ax, 'on')

            t = obj.Spikes(channel).WaveformTimestamps;

            colors = 'rgbcmyk';

            for iUnit = 1:length(obj.Spikes(channel).Units)
                thisColor = colors(iUnit);
                Waveform = obj.Spikes(channel).Units(iUnit).Waveform;
                spikeRate = obj.getSpikeRate(trChannel, iUnit);
                h(iUnit) = line(ax, t, Waveform.Mean, 'LineStyle', '-', 'Color', thisColor, 'DisplayName', sprintf('%.0f sp/s', spikeRate));
                patch(ax, [t, flip(t)], [Waveform.Percentile05, flip(Waveform.Percentile95)], thisColor,...
                    'FaceAlpha', 0.15, 'EdgeColor', 'none');
                patch(ax, [t, flip(t)], [Waveform.Mean - Waveform.STD, flip(Waveform.Mean + Waveform.STD)], thisColor,...
                    'FaceAlpha', 0.4, 'EdgeColor', 'none');
                line(ax, t, [Waveform.Mean - Waveform.STD; Waveform.Mean + Waveform.STD], 'LineStyle', '--', 'Color', thisColor);
                line(ax, t, [Waveform.Percentile05; Waveform.Percentile95], 'LineStyle', ':', 'Color', thisColor);
            end

            legend(h, 'Location', 'southwest')

            hold(ax, 'off')
        end
    end

    % Sorting/selecting pulses
    methods
        function varargout = sortPulses(obj, channel, unit, timeCutoff)
        %sortPulses - Sort pulses by last spontaneous spike time before stim on.
        % Syntax: output = sortPulses(obj)
            p = inputParser();
            p.addRequired('Channel', @(x) isnumeric(x) && length(x) == 1);
            p.addOptional('Unit', 1, @(x) isnumeric(x) && length(x) == 1);
            p.addOptional('TimeCutoff', 5e-4, @(x) isnumeric(x) && length(x) == 1);
            p.parse(channel, unit, timeCutoff);
            channel = p.Results.Channel;
            unit = p.Results.Unit;
            timeCutoff = p.Results.TimeCutoff;

            % Map channel labels to data
            trChannel = channel;
            channel = obj.mapChannels(trChannel, 'From', 'TR', 'To', 'Data');

            % Read unit spike timestamps relative to pulse on
            allSpikeTimes = obj.Spikes(channel).Units(unit).Timestamps;

            spikeToPulseLatency = zeros(length(obj.PulseOn), 1);

            for iPulse = 1:length(obj.PulseOn)
                iLastSpike = find(allSpikeTimes <= obj.PulseOn(iPulse) + timeCutoff, 1, 'last');
                if isempty(iLastSpike)
                    spikeToPulseLatency(iPulse) = Inf;
                else
                    spikeToPulseLatency(iPulse) = obj.PulseOn(iPulse) - allSpikeTimes(iLastSpike);
                end
            end

            [sortedSpikeToPulseLatency, sortedPulseOrder] = sort(spikeToPulseLatency, 'ascend');

            varargout = {sortedSpikeToPulseLatency, sortedPulseOrder, spikeToPulseLatency}; 
        end

        function varargout = selectPulsesByDuration(obj, minDuration, maxDuration, varargin)
            %selectPulses - Select a subset of stim pulses by stim duration in seconds.
            % Syntax: [selectedPulseIndices, selectedPulseDurations] = selectPulsesByDuration(obj, minDuration = 0, maxDuration = Inf, 'Tolerance', 1e-4, 'PulseOrder', pulseOrder)
            p = inputParser();
            p.addRequired('MinDuration', @(x) isnumeric(x) && length(x) == 1);
            p.addRequired('MaxDuration', @(x) isnumeric(x) && length(x) == 1);
            p.addParameter('Tolerance', 1e-4, @(x) isnumeric(x) && length(x) == 1);
            p.addParameter('PulseOrder', 1:length(obj.PulseOn), @(x) isnumeric(x) && length(x) == length(obj.PulseOn)); % Use to add a custom sort order, in which case return indices and durations are also sorted the same way.
            p.parse(minDuration, maxDuration, varargin{:});
            minDuration = p.Results.MinDuration;
            maxDuration = p.Results.MaxDuration;
            tolerance = p.Results.Tolerance;
            pulseOrder = p.Results.PulseOrder;

            pulseDuration = obj.PulseOff(pulseOrder) - obj.PulseOn(pulseOrder);
            
            selectedPulseIndices = (pulseDuration >= minDuration - tolerance) & (pulseDuration <= maxDuration + tolerance);
            selectedPulseIndices = find(selectedPulseIndices);
            selectedPulseDurations = pulseDuration(selectedPulseIndices);
            selectedPulseIndices = pulseOrder(selectedPulseIndices);

            varargout = {selectedPulseIndices, selectedPulseDurations};
        end
    end

    %% Correction
    % Deprecated. Not necessary.
    methods (Static, Access = {})
        function tr = fixMisaligned(tr, sysInitDelay)
            if tr.FrequencyParameters.SysInitDelay.DataTrimmed
                disp('Does not need trimming. Already did.')
                return
            end

            if sysInitDelay > 0
                for iChn = 1:length(tr.Spikes)
                    if ~isempty(tr.Spikes(iChn).Channel)
                        tr.Spikes(iChn).Timestamps = tr.Spikes(iChn).Timestamps - sysInitDelay;
                    end
                end
                tr.FrequencyParameters.SysInitDelay.Duration = sysInitDelay;
                tr.FrequencyParameters.SysInitDelay.DataTrimmed = true;
                disp(['Removed data in the first ', num2str(sysInitDelay), ' seconds'])
            else
                disp('Does not need fixing.');
                return
            end
        end
    end

    methods
        % Use to undo deprecated tr = fixMisaligned(tr) call
        function undoFixMisaligned(obj, direction, varargin)
            p = inputParser();
            p.addOptional('Direction', 'Add', @ischar);
            p.parse(direction, varargin{:});
            direction = p.Results.Direction;

            switch lower(direction)
                case 'add'
                    direction = 1;
                case 'substract'
                    direction = -1;
            end
                    

            for iObj = 1:length(obj)
                sysInitDelay = obj(iObj).getSysInitDelay();

                if sysInitDelay > 0
                    for iChn = 1:length(obj(iObj).Spikes)
                        for iUnit = 1:length(obj(iObj).Spikes(iChn).Units)
                            obj(iObj).Spikes(iChn).Units(iUnit).Timestamps = obj(iObj).Spikes(iChn).Units(iUnit).Timestamps + direction * sysInitDelay;
                        end
                    end
                end
            end

            fprintf(1, 'Spike timestamps shifted by %f seconds.', direction * sysInitDelay)
        end
    end

    %% Misc
    methods
        function unloadTR(obj)
            obj.TR = [];
        end

        function spikeRate = getSpikeRate(obj, channel, unit)
            channel = obj.mapChannels(channel, 'From', 'TR', 'To', 'Data');
            t = obj.Spikes(channel).Units(unit).Timestamps;
            spikeRate = length(t) / (t(end) - t(1));
        end
    end
end