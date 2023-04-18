% Has camera frame timing and EphysUnits.
classdef VideoSession < handle
    properties
        animalName
        expName
        path
        ac
        eventTimes
        videoFrameTimes
    end

    properties (Transient)
        eu
    end

    methods
        function obj = VideoSession(expName)
            assert(~isempty(expName), 'Experiment name cannot be empty.')

            animalName = strsplit(expName, '_');
            animalName = animalName{1};
            
            obj.path.arduino = sprintf('C:\\SERVER\\%s\\%s\\%s.mat', animalName, expName, expName);
            ac = load(obj.path.arduino);
            obj.ac = ac.obj;
            obj.animalName = animalName;
            obj.expName = expName;
            
            eu = obj.loadEphysUnits();
            obj.eventTimes = eu.EventTimes;

            % Use cue_on at everytrial to align camera and ephys
            % VideoDateTime <-> ArduinoCueDateTime <-> EphysCueTime           
            refEphysTime = obj.eventTimes.Cue;
            refEventId = find(strcmp(obj.ac.EventMarkerNames, 'CUE_ON'));
            refDateTime = datetime(obj.ac.EventMarkersUntrimmed(obj.ac.EventMarkersUntrimmed(:, 1) == refEventId, 3)', ConvertFrom='datenum', TimeZone='America/New_York');
            % Check data integrity
            if length(refEphysTime) ~= length(refDateTime)
                warning('Arduino has %g cue events, but ephys has %g cue events.', length(refDateTime), length(refEphysTime))
                n = min(length(refEphysTime), length(refDateTime));
                refEphysTime = refEphysTime(1:n);
                refDateTime = refDateTime(1:n);
            end
            if all(abs(diff(refEphysTime) - seconds(diff(refDateTime))) >= 0.1)
                warning('Adruino trial lengths differe significantly from ephys, max different: %g.', max(abs(diff(refEphysTime) - seconds(diff(refDateTime)))))
            end

            % Video
            obj.path.video = cell(obj.ncams, 1);
            cam = cell(obj.ncams, 1);
            obj.videoFrameTimes = cell(obj.ncams, 1);
            for icam = 1:obj.ncams
                obj.path.video{icam} = sprintf('C:\\SERVER\\%s\\%s\\%s_%d.mp4', animalName, expName, expName, icam);
                cam{icam} = obj.ac.Cameras(icam).Camera;
                
                videoDateTime = datetime([cam{icam}.EventLog.Timestamp], ConvertFrom='datenum', TimeZone='America/New_York');
                videoFrameNum = [cam{icam}.EventLog.FrameNumber];
    
                % Clean up restarting framenums
                if nnz(videoFrameNum == 0) > 1
                    iStart = find(videoFrameNum == 0, 1, 'last');
                    videoFrameNum = videoFrameNum(iStart:end);
                    videoDateTime = videoDateTime(iStart:end);
                    warning('%s camera %d had a restart. Only the last batch of framenumbers and timestamps are kept. %.2f seconds of data are useless.', obj.expName, icam, (iStart-1)*10/30)
                end
                assert(all(diff(videoFrameNum) == 10))
    
                videoEphysTime = interp1(refDateTime, refEphysTime, videoDateTime, 'linear', 'extrap');
                obj.videoFrameTimes{icam} = table(videoFrameNum' + 1, videoEphysTime', VariableNames={'frame', 'time'});                
            end
        end

        function t = trials(obj, type)
            switch lower(type)
                case 'press'
                    t = obj.eu(1).Trials.Press;
                case 'lick'
                    t = obj.eu(1).Trials.Lick;
            end
        end

        % Video stuff
        function n = ncams(obj)
            n = length(obj.ac.Cameras);
        end

        function n = getVideoFrame(obj, icam, t)
            n = round(interp1(obj.videoFrameTimes{icam}.time, obj.videoFrameTimes{icam}.frame, t, 'linear', 'extrap'));
        end

        function t = getEphysTime(obj, icam, n)
            t = interp1(obj.videoFrameTimes{icam}.frame, obj.videoFrameTimes{icam}.time, n, 'linear', 'extrap');
        end

        function frames = extractFrames(obj, t)
            frames = cell(obj.ncams, 1);
            for icam = 1:obj.ncams
                vid = VideoReader(obj.path.video{icam});
                n = obj.getVideoFrame(icam, t);
                theseFrames = zeros(vid.Height, vid.Width, 3, length(n), 'uint8');
                for i = 1:length(n)
                    % fprintf(1, 'Extracting frame %d of %d...\n', i, length(n))
                    theseFrames(:, :, :, i) = vid.read(n(i));
                end
                frames{icam} = theseFrames;
                clear vid
            end
            frames = cat(2, frames{:});
        end

        function eu = loadEphysUnits(obj, varargin)
            p = inputParser();
            p.addOptional('n', [], @isnumeric)
            p.parse(varargin{:})
            n = p.Results.n;

            f = dir(sprintf('C:\\SERVER\\Units\\Lite_NonDuplicate\\%s*.mat', obj.expName));
            f = cellfun(@(x) sprintf('C:\\SERVER\\Units\\Lite_NonDuplicate\\%s', x), {f.name}', UniformOutput=false);
            if ~isempty(n)
                f = f(1:n);
            end
            
            eu = EphysUnit.load(f);
            obj.eu = eu;
        end
    end

    methods (Static)
    end

    methods (Access={})
    end

    methods (Static, Access={})
    end
end