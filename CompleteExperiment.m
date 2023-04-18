classdef CompleteExperiment < handle
    properties
        name = ''
        eu = []
        vtdL = [] % camera 2, animal's left
        vtdR = [] % camera 1, animal's right
        ac = []
    end

    methods
        function obj = CompleteExperiment(varargin)
            if nargin == 0
                return
            end
            p = inputParser();
            p.addRequired('eu', @(x) isa(x, 'EphysUnit'))
            p.parse(varargin{:});
            eu = p.Results.eu;

            [uniqueExpNames, ~, expIndices] = unique({eu.ExpName});
            nExp = length(uniqueExpNames);
            obj(nExp) = CompleteExperiment();
            for i = 1:nExp
                obj(i).name = uniqueExpNames{i};
                obj(i).eu = eu(expIndices==i);
                obj(i).vtdL = CompleteExperiment.readVideoTrackingData(obj(i).name, 'l');
                obj(i).vtdR = CompleteExperiment.readVideoTrackingData(obj(i).name, 'r');
                obj(i).ac = CompleteExperiment.readArduino(obj(i).name);
            end
        end

        function name = animalName(obj)
            if length(obj) == 1
                name = obj.eu(1).getAnimalName();
            else
                name = arrayfun(@(obj) obj.animalName(), obj, UniformOutput=false);
            end
        end

        function t = getEventTimestamps(obj, eventName)
            p = inputParser();
            p.addRequired('eventName', @(x) ismember(x, {'Cue', 'Press', 'Lick', 'StimOn', 'StimOff', 'LightOn', 'LightOff', 'RewardTimes'}))
            p.parse(eventName);
            eventName = p.Results.eventName;

            if length(obj) == 1
                t = obj.eu(1).EventTimes.(eventName);
            else
                t = arrayfun(@(obj) obj.getEventTimestamps(eventName), obj, UniformOutput=false);
            end
        end

        % Sync arduino and video to ephys time.
        function alignTimestamps(obj)
            % Use CUE_ON events because this is recorded in arduino and ephys
            if length(obj) == 1
                eventId = find(strcmp(obj.ac.EventMarkerNames, 'CUE_ON'));
                eventDateNum = obj.ac.EventMarkersUntrimmed(obj.ac.EventMarkersUntrimmed(:, 1) == eventId, 3)';
                eventDateTime = datetime(eventDateNum, ConvertFrom='datenum', TimeZone='America/New_York');
                rcamDateTime = datetime([obj.ac.Cameras(1).Camera.EventLog.Timestamp], ConvertFrom='datenum', TimeZone='America/New_York');
                rcamFrameNum = [obj.ac.Cameras(1).Camera.EventLog.FrameNumber];
                lcamDateTime = datetime([obj.ac.Cameras(2).Camera.EventLog.Timestamp], ConvertFrom='datenum', TimeZone='America/New_York');
                lcamFrameNum = [obj.ac.Cameras(2).Camera.EventLog.FrameNumber];

                % Find event in ephystime
                eventEhpysTime = obj.eu(1).EventTimes.Cue;
                
                % Some assertions: 
                assert(length(eventEhpysTime) == length(eventDateTime), 'Arduino has %g cue events, but ephys has %g cue events.', length(eventDateTime), length(eventEhpysTime))
                assert(all(abs(diff(eventEhpysTime) - seconds(diff(eventDateTime))) < 0.1), 'Adruino trial lengths differe significantly from ephys, max different: %g.', max(abs(diff(eventEhpysTime) - seconds(diff(eventDateTime)))))

                % Clean up restarting framenums
                if nnz(lcamFrameNum == 0) > 1
                    iStart = find(lcamFrameNum == 0, 1, 'last');
                    lcamFrameNum = lcamFrameNum(iStart:end);
                    lcamDateTime = lcamDateTime(iStart:end);
                    warning('%s left camera had a restart. Only the last batch of framenumbers and timestamps are kept. %.2f seconds of data are useless.', obj.name, (iStart-1)*10/30)
                end
                if nnz(rcamFrameNum == 0) > 1
                    iStart = find(rcamFrameNum == 0, 1, 'last');
                    rcamFrameNum = rcamFrameNum(iStart:end);
                    rcamDateTime = rcamDateTime(iStart:end);
                    warning('%s right camera had a restart. Only the last batch of framenumbers and timestamps are kept. %.2f seconds of data are useless.', obj.name, (iStart-1)*10/30)
                end
                assert(all(diff(lcamFrameNum) == 10))
                assert(all(diff(rcamFrameNum) == 10))

                lcamEphysTime = interp1(eventDateTime, eventEhpysTime, lcamDateTime, 'linear', 'extrap');
                rcamEphysTime = interp1(eventDateTime, eventEhpysTime, rcamDateTime, 'linear', 'extrap');

                lvtdEphysTime = interp1(lcamFrameNum, lcamEphysTime, obj.vtdL.FrameNumber, 'linear', 'extrap');
                rvtdEphysTime = interp1(rcamFrameNum, rcamEphysTime, obj.vtdR.FrameNumber, 'linear', 'extrap');

                obj.vtdL.Timestamp = lvtdEphysTime;
                obj.vtdR.Timestamp = rvtdEphysTime;

                fprintf(1, 'Frame 0 in ephys time: %.3f s, %.3f s\n', lcamEphysTime(1), rcamEphysTime(1))
                
            else
                for i = 1:length(obj)
                    try
                        obj(i).alignTimestamps();
                    catch ME
                        fprintf(1, '%g: %s has error. %g EphysUnits involved.\n', i, obj(i).name, length(obj(i).eu))
                        warning('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message)
                    end
                end
            end
        end

		function clip = getVideoClip(obj, ephysTime, varargin)
			p = inputParser;
			addRequired(p, 'ephysTime', @isnumeric);
            addOptional(p, 'side', 'l', @(x) ismember(x, {'l', 'r'}))
			addParameter(p, 'numFramesBefore', 30, @isnumeric);
			addParameter(p, 'numFramesAfter', 30, @isnumeric);
			parse(p, ephysTime, varargin{:});
			ephysTime			= p.Results.ephysTime;
            side                = p.Results.side;
			numFramesBefore		= p.Results.numFramesBefore;
			numFramesAfter		= p.Results.numFramesAfter;

            assert(length(obj) == 1)

            switch side
                case 'r'
                    vtd = obj.vtdR;
                    file = sprintf('C:\\SERVER\\%s\\%s\\%s_1.mp4', obj.animalName, obj.name, obj.name);
                case 'l'
                    vtd = obj.vtdL;
                    file = sprintf('C:\\SERVER\\%s\\%s\\%s_2.mp4', obj.animalName, obj.name, obj.name);
            end

            % Collect bodypart trajectories
            bodyparts = {'handIpsi', 'footIpsi', 'nose', 'spine', 'tail', 'tongue'};
            xPos = cellfun(@(bp) vtd.(sprintf('%s_X', bp)), bodyparts, UniformOutput=false);
            yPos = cellfun(@(bp) vtd.(sprintf('%s_Y', bp)), bodyparts, UniformOutput=false);
            prob = cellfun(@(bp) vtd.(sprintf('%s_Likelihood', bp)), bodyparts, UniformOutput=false);

            labelColors = [transpose(0:(0.8 - 0)/(length(bodyparts) - 1):0.8), repmat([1, 0.5], length(bodyparts), 1)];
            labelColors = hsl2rgb(labelColors)*255;

			v = VideoReader(file);
			vidStartTime = v.CurrentTime;

			clip = cell(length(ephysTime), 1);

			for iClip = 1:length(ephysTime)
				fprintf('Extracting clip %d of %d...', iClip, length(ephysTime))

				[~, iFrame] = min(abs(vtd.Timestamp - ephysTime(iClip)));
				v.CurrentTime = (iFrame - 1 - numFramesBefore)/v.FrameRate + vidStartTime;

				clip{iClip} = uint8(zeros(v.Height, v.Width, 3, numFramesBefore + numFramesAfter + 1));
				for iClipFrame = 1:size(clip{iClip}, 4)
					thisFrame = readFrame(v);
					iFrameAbs = iFrame + iClipFrame - numFramesBefore - 1;
					thisProb = transpose(cellfun(@(x) x(iFrameAbs), prob));
                    sel = thisProb > 0.95;
                    thisProb = thisProb(sel);
					thisPos = transpose([cellfun(@(x) x(iFrameAbs), xPos); cellfun(@(x) x(iFrameAbs), yPos)]);
                    thisPos = thisPos(sel, :);
                    thisColor = labelColors(sel, :);
                    thisLabels = bodyparts(sel);
					thisFrame = insertText(thisFrame, thisPos, thisLabels, TextColor=thisColor, BoxOpacity=0, AnchorPoint='RightTop');
					thisFrame = insertText(thisFrame, thisPos, round(100*thisProb)/100, TextColor=thisColor, BoxOpacity=0, AnchorPoint='RightBottom');
					thisFrame = insertMarker(thisFrame, thisPos, Color=thisColor, Size=10);
					if iClipFrame == numFramesBefore + 1
						thisFrame = insertShape(thisFrame, 'FilledRectangle', [0, 0, v.Width, v.Height], Color='red', Opacity=0.7);
					end
					clip{iClip}(:, :, :, iClipFrame) = thisFrame;
				end
				fprintf('Done!\n')
            end

            if length(ephysTime) == 1
                clip = clip{1};
            end
		end

        function F = getFeatures(obj, varargin)
            if length(obj) > 1
                F = cellfun(@(obj) obj.getFeatures(varargin{:}), obj, UniformOutput=false);
                return
            end

            p = inputParser();
            p.addParameter('timestamps', [], @isnumeric); % [tStart, tEnd]. Request data at these ephys timestamps. If emtpy use 0:1/sampleRate:lastSpikeInAllUnits
            p.addParameter('sampleRate', 30, @isnumeric); % Only used if tquery is empty
            p.addParameter('features', {'handL', 'handR', 'footL', 'footR'}, ...
                @(x) all(ismember(x, {'handL', 'handR', 'footL', 'footR', 'nose', 'spine', 'tail', 'tongue', ...
                'trialStart', 'reward', 'anyPress', 'anyLick', 'firstPress', 'firstLick', ...
                'firstPressRamp', 'firstLickRamp', 'pressTrialRamp', 'lickTrialRamp'})))
            p.addParameter('stats', {'xPos', 'yPos', 'xVel', 'yVel', 'spd'})
            p.addParameter('likelihoodThreshold', 0.95, @isnumeric); % Observations with lieklihood below this threshold will be discarded (NaN)
            p.addParameter('rampDurations', 0.1:0.2:2, @isnumeric);
            p.addParameter('trialType', {'press', 'lick'})
            p.addParameter('useGlobalNormalization', true, @islogical)
            p.addParameter('baselineTimestamps', [], @isnumeric);
            p.parse(varargin{:});
            timestamps = p.Results.timestamps;
            features = p.Results.features;
            stats = p.Results.stats;
            likelihoodThreshold = p.Results.likelihoodThreshold;
            useGlobalNormalization = p.Results.useGlobalNormalization;
            baselineTimestamps = p.Results.baselineTimestamps;

            if isempty(timestamps)
                lastSpikeTimestamp = max(arrayfun(@(eu) eu.SpikeTimes(end), obj.eu));
                timestamps = 0:1/p.Results.sampleRate:lastSpikeTimestamp;
            end
            timestamps = timestamps(:);
            inTrial = obj.eu(1).getTrials(p.Results.trialType).inTrial(timestamps);

            F = table(timestamps, inTrial, VariableNames={'t', 'inTrial'});
            for iFeature = 1:length(features)
                featureName = features{iFeature};

                if ismember(featureName, {'handL', 'handR', 'footL', 'footR'})
                    switch featureName
                        case 'handL'
                            vtd = obj.vtdL;
                            bodypartName = 'handIpsi';
                        case 'handR'
                            vtd = obj.vtdR;
                            bodypartName = 'handIpsi';
                        case 'footL'
                            vtd = obj.vtdL;
                            bodypartName = 'footIpsi';
                        case 'footR'
                            vtd = obj.vtdR;
                            bodypartName = 'footIpsi';
                    end
    
                    xPosGlobal = vtd.(sprintf('%s_X', bodypartName));
                    yPosGlobal = vtd.(sprintf('%s_Y', bodypartName));

                    % Remove uncertain estimates (NaN)
                    isUncertain = vtd.(sprintf('%s_Likelihood', bodypartName)) < likelihoodThreshold;
                    xPosGlobal(isUncertain) = NaN;
                    yPosGlobal(isUncertain) = NaN;

                    % Calculate velocity
                    t = vtd.Timestamp;
                    xVelGlobal = [0; diff(xPosGlobal)] ./ [1; diff(t)];
                    yVelGlobal = [0; diff(yPosGlobal)] ./ [1; diff(t)];

                    % Resample data at tquery
                    xPos = interp1(t, xPosGlobal, timestamps, 'linear', NaN);
                    yPos = interp1(t, yPosGlobal, timestamps, 'linear', NaN);
                    xVel = interp1(t, xVelGlobal, timestamps, 'linear', NaN);
                    yVel = interp1(t, yVelGlobal, timestamps, 'linear', NaN);


                    % Normalize data
                    if ~isempty(baselineTimestamps)
                        xPosBaseline = interp1(t, xPosGlobal, baselineTimestamps, 'linear', NaN);
                        yPosBaseline = interp1(t, yPosGlobal, baselineTimestamps, 'linear', NaN);
                        xVelBaseline = interp1(t, xVelGlobal, baselineTimestamps, 'linear', NaN);
                        yVelBaseline = interp1(t, yVelGlobal, baselineTimestamps, 'linear', NaN);
                        xPos = (xPos - mean(xPosBaseline, 'omitnan')) ./ std(xPosBaseline, 0, 'omitnan');
                        yPos = (yPos - mean(yPosBaseline, 'omitnan')) ./ std(yPosBaseline, 0, 'omitnan');
                        xVel = (xVel - mean(xVelBaseline, 'omitnan')) ./ std(xVelBaseline, 0, 'omitnan');
                        yVel = (yVel - mean(yVelBaseline, 'omitnan')) ./ std(yVelBaseline, 0, 'omitnan');
                    elseif useGlobalNormalization
                        xPos = (xPos - mean(xPosGlobal, 'omitnan')) ./ std(xPosGlobal, 0, 'omitnan');
                        yPos = (yPos - mean(yPosGlobal, 'omitnan')) ./ std(yPosGlobal, 0, 'omitnan');
                        xVel = (xVel - mean(xVelGlobal, 'omitnan')) ./ std(xVelGlobal, 0, 'omitnan');
                        yVel = (yVel - mean(yVelGlobal, 'omitnan')) ./ std(yVelGlobal, 0, 'omitnan');
                    else
                        xPos = normalize(xPos, 'zscore');
                        yPos = normalize(yPos, 'zscore');
                        xVel = normalize(xVel, 'zscore');
                        yVel = normalize(yVel, 'zscore');
                    end

                    % Inverse sign of x data for left camera (so that front of mouse is x positive, up is y positive)
                    if ismember(featureName, {'handL', 'footL'})
                        xPos = -xPos;
                        xVel = -xVel;
                    end

                    if ismember('xPos', stats)
                        F.(sprintf('%s_xPos', featureName)) = xPos;
                    end
                    if ismember('yPos', stats)
                        F.(sprintf('%s_yPos', featureName)) = yPos;
                    end
                    if ismember('xVel', stats)
                        F.(sprintf('%s_xVel', featureName)) = xVel;
                    end
                    if ismember('yVel', stats)
                        F.(sprintf('%s_yVel', featureName)) = yVel;
                    end
                    if ismember('spd', stats)
                        F.(sprintf('%s_spd', featureName)) = sqrt(xVel.^2 + yVel.^2);
                    end
                elseif ismember(featureName, {'nose', 'spine', 'tail'})
                    vtd = {obj.vtdR, obj.vtdL};
                    bodypartName = featureName;

                    xPosBothSides = NaN(length(timestamps), 2);
                    yPosBothSides = NaN(length(timestamps), 2);
                    xVelBothSides = NaN(length(timestamps), 2);
                    yVelBothSides = NaN(length(timestamps), 2);

                    xPosMU = NaN(1, 2);
                    yPosMU = NaN(1, 2);
                    xVelMU = NaN(1, 2);
                    yVelMU = NaN(1, 2);
                    xPosSD = NaN(1, 2);
                    yPosSD = NaN(1, 2);
                    xVelSD = NaN(1, 2);
                    yVelSD = NaN(1, 2);

                    for iSide = 1:2
                        xPos = vtd{iSide}.(sprintf('%s_X', bodypartName));
                        yPos = vtd{iSide}.(sprintf('%s_Y', bodypartName));
                        isUncertain = vtd{iSide}.(sprintf('%s_Likelihood', bodypartName)) < likelihoodThreshold;
                        xPos(isUncertain) = NaN;
                        yPos(isUncertain) = NaN;

                        % Calculate velocity
                        t = vtd{iSide}.Timestamp;
                        xVel = [0; diff(xPos)] ./ [1; diff(t)];
                        yVel = [0; diff(yPos)] ./ [1; diff(t)];

                        xPosMU(:, iSide) = mean(xPos, 'omitnan');
                        yPosMU(:, iSide) = mean(yPos, 'omitnan');
                        xVelMU(:, iSide) = mean(xVel, 'omitnan');
                        yVelMU(:, iSide) = mean(yVel, 'omitnan');
                        xPosSD(:, iSide) = std(xPos, 0, 'omitnan');
                        yPosSD(:, iSide) = std(yPos, 0, 'omitnan');
                        xVelSD(:, iSide) = std(xVel, 0, 'omitnan');
                        yVelSD(:, iSide) = std(yVel, 0, 'omitnan');

                        % Resample data at tquery
                        xPosBothSides(:, iSide) = interp1(t, xPos, timestamps, 'linear', NaN);
                        yPosBothSides(:, iSide) = interp1(t, yPos, timestamps, 'linear', NaN);
                        xVelBothSides(:, iSide) = interp1(t, xVel, timestamps, 'linear', NaN);
                        yVelBothSides(:, iSide) = interp1(t, yVel, timestamps, 'linear', NaN);
                    end

                    % Normalize data
                    if ~isempty(baselineTimestamps)
                        xPosBaseline = interp1(t, xPosGlobal, baselineTimestamps, 'linear', NaN);
                        yPosBaseline = interp1(t, yPosGlobal, baselineTimestamps, 'linear', NaN);
                        xVelBaseline = interp1(t, xVelGlobal, baselineTimestamps, 'linear', NaN);
                        yVelBaseline = interp1(t, yVelGlobal, baselineTimestamps, 'linear', NaN);
                        xPosBothSides = (xPos - mean(xPosBaseline, 'omitnan')) ./ std(xPosBaseline, 0, 'omitnan');
                        yPosBothSides = (yPos - mean(yPosBaseline, 'omitnan')) ./ std(yPosBaseline, 0, 'omitnan');
                        xVelBothSides = (xVel - mean(xVelBaseline, 'omitnan')) ./ std(xVelBaseline, 0, 'omitnan');
                        yVelBothSides = (yVel - mean(yVelBaseline, 'omitnan')) ./ std(yVelBaseline, 0, 'omitnan');
                    elseif useGlobalNormalization
                        xPosBothSides = (xPosBothSides - xPosMU) ./ xPosSD;
                        yPosBothSides = (yPosBothSides - yPosMU) ./ yPosSD;
                        xVelBothSides = (xVelBothSides - xVelMU) ./ xVelSD;
                        yVelBothSides = (yVelBothSides - yVelMU) ./ yVelSD;
                    else
                        xPosBothSides = normalize(xPosBothSides, 1, 'zscore');
                        yPosBothSides = normalize(yPosBothSides, 1, 'zscore');
                        xVelBothSides = normalize(xVelBothSides, 1, 'zscore');
                        yVelBothSides = normalize(yVelBothSides, 1, 'zscore');
                    end

                    % Inverse sign of x data for left camera (so that front of mouse is x positive, up is y positive)
                    xPosBothSides(:, 2) = -xPosBothSides(:, 2);
                    xVelBothSides(:, 2) = -xVelBothSides(:, 2);
    
                    % Take the mean between two cameras
                    xPos = mean(xPosBothSides, 2, 'omitnan');
                    yPos = mean(yPosBothSides, 2, 'omitnan');
                    xVel = mean(xVelBothSides, 2, 'omitnan');
                    yVel = mean(yVelBothSides, 2, 'omitnan');

                    if ismember('xPos', stats)
                        F.(sprintf('%s_xPos', featureName)) = xPos;
                    end
                    if ismember('yPos', stats)
                        F.(sprintf('%s_yPos', featureName)) = yPos;
                    end
                    if ismember('xVel', stats)
                        F.(sprintf('%s_xVel', featureName)) = xVel;
                    end
                    if ismember('yVel', stats)
                        F.(sprintf('%s_yVel', featureName)) = yVel;
                    end
                    if ismember('spd', stats)
                        F.(sprintf('%s_spd', featureName)) = sqrt(xVel.^2 + yVel.^2);
                    end
                elseif strcmp(featureName, 'tongue')
                    % Tongue is special because it usually is only visible
                    % for one or two frames. So we use simple event-like
                    % thresholding (when either camera detects tongue, a lick event is registered)
                    vtd = {obj.vtdR, obj.vtdL};
                    bodypartName = 'tongue';

                    lickBothSides = NaN(length(timestamps), 2);
                    for iSide = 1:2
                        lick = vtd{iSide}.(sprintf('%s_Likelihood', bodypartName)) >= likelihoodThreshold;
                        lick = double(lick);

                        % Resample data at tquery
                        t = vtd{iSide}.Timestamp;
                        lickBothSides(:, iSide) = interp1(t, lick, timestamps, 'linear', NaN);
                    end

                    % If either camera sees a lick, we accept it. Eww.
                    lick = sum(lickBothSides, 2, 'omitnan');
                    lick = lick > 0;
                    
                    F = addvars(F, lick, NewVariableNames={'tongue'});
                elseif ismember(featureName, {'trialStart', 'reward', 'anyPress', 'anyLick', 'firstPress', 'firstLick'})
                    switch featureName
                        case 'trialStart'
                            eventTimes = obj.eu(1).EventTimes.Cue;
                        case 'reward'
                            eventTimes = obj.eu(1).EventTimes.RewardTimes;
                        case 'anyPress'
                            eventTimes = obj.eu(1).EventTimes.Press;
                        case 'anyLick'
                            eventTimes = obj.eu(1).EventTimes.Lick;
                        case 'firstPress'
                            eventTimes = [obj.eu(1).getTrials('press').Stop];
                        case 'firstLick'
                            eventTimes = [obj.eu(1).getTrials('lick').Stop];
                    end
                    x = [0, histcounts(eventTimes, timestamps)]';
                    F = addvars(F, x, NewVariableNames={featureName});
                elseif ismember(featureName, {'pressTrialRamp', 'lickTrialRamp', 'firstPressRamp', 'firstLickRamp'})
                    switch featureName
                        case 'pressTrialRamp'
                            trials = obj.eu(1).getTrials('press');
                            startTimes = [trials.Start];
                            stopTimes = [trials.Stop];
                        case 'lickTrialRamp'
                            trials = obj.eu(1).getTrials('lick');
                            startTimes = [trials.Start];
                            stopTimes = [trials.Stop];
                        case 'firstPressRamp'
                            rampDurations = p.Results.rampDurations;
                            trials = obj.eu(1).getTrials('press');
                            stopTimes = [trials.Stop];
                            startTimes = cell(length(rampDurations), 1);
                            for iRamp = 1:length(rampDurations)
                                startTimes{iRamp} = stopTimes - rampDurations(iRamp);
                            end
                        case 'firstLickRamp'
                            rampDurations = p.Results.rampDurations;
                            trials = obj.eu(1).getTrials('lick');
                            stopTimes = [trials.Stop];
                            startTimes = cell(length(rampDurations), 1);
                            for iRamp = 1:length(rampDurations)
                                startTimes{iRamp} = stopTimes - rampDurations(iRamp);
                            end
                    end
                    if isnumeric(startTimes)
                        t = [startTimes - 0.001, startTimes, stopTimes, stopTimes + 0.001];
                        n = length(trials);
                        x = [zeros(1, n), zeros(1, n), ones(1, n), zeros(1, n)];
                        x = interp1(t, x, timestamps, 'linear', 0);
                        F = addvars(F, x, NewVariableNames={featureName});
                    elseif iscell(startTimes)
                        for iRamp = 1:length(startTimes)
                            t = [startTimes{iRamp} - 0.001, startTimes{iRamp}, stopTimes, stopTimes + 0.001];
                            n = length(trials);
                            x = [zeros(1, n), zeros(1, n), ones(1, n), zeros(1, n)];
                            x = interp1(t, x, timestamps, 'linear', 0);
                            d = round(rampDurations(iRamp) * 1000);
                            F = addvars(F, x, NewVariableNames={sprintf('%s%g', featureName, d)});
                        end
                    end
                end
            end
        end


        function [F, mask] = maskFeaturesByTrial(obj, F, maskValue, trialType, window, varargin)
            p = inputParser();
            p.addRequired('F', @istable)
            p.addRequired('maskValue')
            p.addRequired('trialType', @(x) ismember(x, {'press', 'lick'}))
            p.addRequired('window', @isnumeric) % [-0.5, 2]
            p.addParameter('features', {}, @iscell)
            p.addParameter('stats', {'xVel', 'yVel'}, @iscell)
            p.addParameter('reference', 'stop', @(x) ismember(x, {'stop', 'start'}))
            p.addParameter('replace', false, @islogical)
            p.parse(F, maskValue, trialType, window, varargin{:});
            r = p.Results;
            F = r.F;
            trialType = r.trialType;
            window = r.window;
            features = r.features;
            stats = r.stats;

            if strcmpi(r.reference, 'start')
                error('NOT IMPLEMENTED: REFUSAL BY THE GRAD STUDENT.')
            end

            trials = obj.eu(1).getTrials(trialType);
            start = [trials.Start];
            stop = [trials.Stop];

            mask = false(size(F.t));
            for iTrial = 1:length(trials)
                mask = mask | (F.t >= stop(iTrial) + window(1) & F.t <= stop(iTrial) + window(2));
            end
            for iFeat = 1:length(features)
                featureName = features{iFeat};
                for iStat = 1:length(stats)
                    statName = sprintf('%s_%s', featureName, stats{iStat});
                    x = F.(statName);
                    x(mask) = r.maskValue;
                    if r.replace
                        F.(statName) = x;
                    else
                        F.(sprintf('%s_masked', statName)) = x;
                    end
                end
            end
        end
    end

    methods (Static)
        function Fn = normalizeFeatures(F, varargin)
            p = inputParser();
            p.addRequired('F', @istable);
            p.addOptional('method', 'zscore', @(x) ismember(x, {'zscore', 'robust zscore'}))
            p.addParameter('nameContains', {})
            p.parse(F, varargin{:});
            F = p.Results.F;
            method = p.Results.method;
            nameContains = p.Results.NameContains;

            data = F.Variables;
            switch method
                case 'zscore'
                    data = (data - mean(data, 1, 'omitnan')) ./ std(data, 0, 1, 'omitnan');
                case 'robust zscore'
                    data = (data - median(data, 1, 'omitnan')) ./ (1.4826 * mad(data, 1, 1));
            end
            Fn = array2table(data, VariableNames=F.Properties.VariableNames);
        end

        function F = convolveFeatures(F, K, varargin)
            p = inputParser();
            p.addRequired('F', @istable); % Feature table
            p.addRequired('K', @isnumeric); % convolution kernels
            p.addParameter('kernelNames', {}, @(x) iscell(x) || isnumeric(x));
            p.addParameter('features', {'handL', 'handR', 'footL', 'footR'}, ...
                @(x) all(ismember(x, {'handL', 'handR', 'footL', 'footR', 'nose', 'spine', 'tail', 'tongue', 'trialStart', 'reward', 'anyPress', 'anyLick', 'firstPress', 'firstLick'})))
            p.addParameter('stats', {'xVel', 'yVel'});
            p.addParameter('mode', 'add', @(x) ismember(x, {'replace', 'add', 'new'}));
            p.addParameter('normalize', 'none', @(x) ismember(x, {'none', 'zscore', 'modified zscore', 'maxabs'})); % True to normalize after convolving
            p.parse(F, K, varargin{:});
            F = p.Results.F;
            K = p.Results.K;
            kernelNames = p.Results.kernelNames;
            stats = p.Results.stats;
            features = p.Results.features;
            mode = p.Results.mode;

            if isempty(kernelNames)
                kernelNames = arrayfun(@(x) num2str(x), 1:size(K, 1), UniformOutput=false);
            elseif isnumeric(kernelNames)
                signs = {'-', '+', '+'};
                kernelNames = arrayfun(@(x) sprintf('%s%g', signs{sign(x) + 2}, abs(x)), kernelNames, UniformOutput=false);
            end

            oldF = F;
            if strcmp(mode, 'new')
                F = table(oldF.t, VariableNames={'t'});
            end

            for iFeat = 1:length(features)
                featureName = features{iFeat};
                % Bodyparts
                if ismember(featureName, {'handL', 'handR', 'footL', 'footR', 'nose', 'spine', 'tail'})
                    for iStat = 1:length(stats)
                        statName = sprintf('%s_%s', featureName, stats{iStat});
                        x = oldF.(statName);
                        for iKernel = 1:size(K, 1)
                            y = conv(x, K(iKernel, :), 'same');
                            y = LOCAL_NORMALIZE(y);
                            F.(sprintf('%s%s', statName, kernelNames{iKernel})) = y;
                        end
                        if strcmp(mode, 'replace')
                            F.(statName) = [];
                        end
                    end
                else
                    x = oldF.(featureName);
                    for iKernel = 1:size(K, 1)
                        y = conv(x, K(iKernel, :), 'same');
                        y = LOCAL_NORMALIZE(y);
                        F.(sprintf('%s%s', featureName, kernelNames{iKernel})) = y;
                    end
                    if strcmp(mode, 'replace')
                        F.(featureName) = [];
                    end
                end
            end

            function y = LOCAL_NORMALIZE(y)
                switch p.Results.normalize
                    case 'zscore'
                        y = (y - mean(y, 1, 'omitnan')) ./ std(y, 0, 1, 'omitnan');
                    case 'modified zscore'
                        y = (y - median(y, 1, 'omitnan')) ./ (1.4826 * mad(y, 1, 1));
                    case 'maxabs'
                        y = y ./ max(abs(y));
                end
            end
        end

        function [K, t, delay] = makeConsineKernels(n, varargin)
            p = inputParser();
            p.addRequired('n', @isnumeric);
            p.addParameter('width', 0.2, @isnumeric);
            p.addParameter('overlap', 0.5, @isnumeric);
            p.addParameter('direction', 'both', @(x) ismember(x, {'left', 'right', 'both'}));
            p.addParameter('sampleRate', 30, @isnumeric);
            p.parse(n, varargin{:});
            n = p.Results.n;
            width = p.Results.width;
            overlap = p.Results.overlap;
            direction = p.Results.direction;
            sampleRate = p.Results.sampleRate;

            offset = (1 - overlap) * width;

            t0 = -width/2:1/sampleRate:width/2;
            c0 = cos(linspace(-pi/2, pi/2, length(t0)));

            if n == 0
                K = c0;
                t = t0;
                delay = 0;
                return
            end

            switch direction
                case 'left'
                    delay = zeros(n, 1);
                    for i = 1:n
                        delay(i) = -offset*(n+1-i);
                        TRaw(i, :) = t0 + delay(i);
                        CRaw(i, :) = c0;
                    end
                    delay = [delay; 0];
                    TRaw = [TRaw; t0];
                    CRaw = [CRaw; c0];                        
                case 'right'
                    delay = zeros(n, 1);
                    for i = 1:n
                        delay(i) = offset*i;
                        TRaw(i, :) = t0 + delay(i);
                        CRaw(i, :) = c0;
                    end
                    delay = [0; delay];
                    TRaw = [t0; TRaw];
                    CRaw = [c0; CRaw];
                case 'both'
                    delayL= zeros(n, 1);
                    delayR= zeros(n, 1);
                    for i = 1:n
                        delayL(i) = -offset*(n+1-i);
                        Tl(i, :) = t0 + delayL(i);
                        Cl(i, :) = c0;
                    end
                    for i = 1:n
                        delayR(i) = offset*i;
                        Tr(i, :) = t0 + delayR(i);
                        Cr(i, :) = c0;
                    end
                    delay = [delayL; 0; delayR];
                    TRaw = [Tl; t0; Tr];
                    CRaw = [Cl; c0; Cr];
            end

            halfRange = max(abs(TRaw(:)));
            t = -halfRange:1/sampleRate:halfRange;
            N = size(CRaw, 1);
            for i = 1:N
                K(i, :) = interp1(TRaw(i, :), CRaw(i, :), t, 'linear', 0);
            end
        end
    end

    methods (Access={}, Static)
        function ac = readArduino(expName)
            animalName = strsplit(expName, '_');
            animalName = animalName{1};
            S = load(sprintf('C:\\SERVER\\%s\\%s\\%s.mat', animalName, expName, expName));
            ac = S.obj;
        end
        
        function vtd = readVideoTrackingData(expName, side)
            if nargin < 2
                side = 'both';
            end
        
            smoothingWindow_jointVel = 10;
        
            switch lower(side)
                case {'l', 'left'}
                    sidenum = 2;
                case {'r', 'right'}
                    sidenum = 1;
                otherwise
                    vtd.l = readVideoTrackingData(expName, 'l');
                    vtd.r = readVideoTrackingData(expName, 'r');
                    return
            end
        
            files_vtd = sortrows(struct2table(dir(sprintf('C:\\SERVER\\VideoTracking\\videos\\%s_%g*.csv', expName, sidenum))), 'datenum', 'descend');
            % Use the newest csv file generated by DeepLabCut if multiple matches
            % are found
            if height(files_vtd) > 1
                fname_vtd = sprintf('%s\\%s', files_vtd.folder{1}, files_vtd.name{1});
            else
                fname_vtd = sprintf('%s\\%s', files_vtd.folder, files_vtd.name);
            end
            opts = detectImportOptions(fname_vtd, 'NumHeaderLines', 3);
            opts.VariableNamesLine = 2;
            
            
            t_read = tic();
            fprintf(1, 'Reading video tracking data from file %s...', fname_vtd);
            vtd = readtable(fname_vtd, opts);
            fprintf(1, '\nDone (%s).\n', seconds(toc(t_read)));
            
            % Set colnames
            vtd.Properties.VariableNames{1} = 'FrameNumber';
            w = length(vtd.Properties.VariableNames);
            for i = 2:w
                splitName = strsplit(vtd.Properties.VariableNames{i}, '_');
                if length(splitName) == 1
                    vtd.Properties.VariableNames{i} = [splitName{1}, '_X'];
%                     spos = table2array(smoothdata(vtd(:, i:i+1), 'gaussian', smoothingWindow_jointVel));
%                     vel = [0, 0; diff(spos, 1)];
%                     spd = sqrt(sum(vel.^2, 2));
%                     vtd = addvars(vtd, vel(:, 1), vel(:, 2), spd, 'NewVariableNames', {[splitName{1}, '_VelX'], [splitName{1}, '_VelY'], [splitName{1}, '_Speed']});
                elseif splitName{2} == '1'
                    vtd.Properties.VariableNames{i} = [splitName{1}, '_Y'];
                elseif splitName{2} == '2'
                    vtd.Properties.VariableNames{i} = [splitName{1}, '_Likelihood'];
                end
            end
            clear files_vtd i opts splitName w spos vel spd t_read
        end

    end
end