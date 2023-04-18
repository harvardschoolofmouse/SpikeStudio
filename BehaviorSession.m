classdef BehaviorSession < handle
    properties
        animalName = ''
        expName = ''
        date = []
        file = ''
        paramNames = {}
        eventNames = {}
        resultNames = {}
        eventData = []
        paramData = []
        resultData = []
        numTrials = NaN
    end

    methods
        function obj = BehaviorSession(path)
            if nargin < 1
                return
            end
            if iscell(path)
                N = length(path);
                obj(N, 1) = BehaviorSession();
                tTic0 = tic();
                fprintf(1, 'Batch reading behavior files...\n')
                for i = 1:N
                    tTic = tic();
                    fprintf(1, '\t%g of %g: %s...', i, N, path{i});
                    try
                        obj(i) = BehaviorSession(path{i});
                    catch ME
                        warning(sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message))
                        delete(obj(i))
                    end
                    fprintf(1, 'Done (%.2fs)\n', toc(tTic));
                end
                fprintf(1, '%g files read in %.2fs.\n', N, toc(tTic0))
                return
            end
            assert(ischar(path) && isfile(path), 'File %s does not exist.', path);
            obj.file = path;
            fname = strsplit(path, '\');
            fname = strsplit(fname{end}, '.mat');
            obj.expName = fname{1};
            expName = strsplit(obj.expName, '_');
            obj.animalName = expName{1};
            obj.date = str2double(expName{end});
            S = load(path);
            obj.paramNames = S.obj.ParamNames;
            obj.eventNames = S.obj.EventMarkerNames;
            obj.resultNames = S.obj.ResultCodeNames;
            obj.eventData = S.obj.EventMarkers;
            obj.paramData = vertcat(S.obj.Trials.Parameters);
            obj.resultData = vertcat(S.obj.Trials.Code);
            assert(length(S.obj.Trials) == S.obj.TrialsCompleted);
            obj.numTrials = S.obj.TrialsCompleted;
        end

        function p = getParams(obj, paramName)
            assert(length(obj) == 1)
            p = obj.paramData(:, strcmpi(obj.paramNames, paramName));
        end

        function N = countTrials(obj, type, result)
            if nargin < 2
                type = '';
            end
            if nargin < 3
                result = '';
            end
            if length(obj) > 1
                N = NaN(length(obj), 1);
                for i = 1:length(obj)
                    N(i) = obj(i).countTrials(type, result);
                end
                return
            end
            if isempty(result) && isempty(type)
                N = obj.numTrials;
                return;
            end

            switch lower(result)
                case ''
                    selResult = true(length(obj.numTrials), 1);
                case 'correct'
                    selResult = obj.resultData == find(strcmpi(obj.resultNames, 'CORRECT'));
                case 'early'
                    selResult = obj.resultData == find(strcmpi(obj.resultNames, 'EARLY_MOVE'));
                case 'nomove'
                    selResult = obj.resultData == find(strcmpi(obj.resultNames, 'NO_MOVE'));
            end
            switch type
                case ''
                    selType = true(length(obj.numTrials), 1);
                case 'lick'
                    selType = obj.getParams('USE_LEVER') == 0;
                case 'press'
                    selType = obj.getParams('USE_LEVER') == 1;
            end

            N = nnz(selResult & selType);
        end

        function t = getEventTimes(obj, eventName)
            % Query eventTimestamps by eventName. Returns timestamps
            % relative to first event of any kind.
            assert(length(obj) == 1)
            sel = obj.eventData(:, 1) == find(strcmpi(obj.eventNames, eventName));
            t = obj.eventData(sel, 2) - obj.eventData(1, 2);
            t = t./1000;
        end

        function t = getEventTimesRelative(obj, eventName, varargin)
            p = inputParser();
            p.addRequired('EventName', @ischar);
            p.addParameter('RefEventName', 'CUE_ON', @ischar);
            p.addParameter('TrialStartEventName', 'TRIAL_START', @ischar);
            p.addParameter('TrialEndEventName', 'ITI', @ischar);
            p.addParameter('FirstInTrial', true, @islogical);
            p.addParameter('RequireTrialType', '', @(x) ismember(x, {'', 'lever', 'lick'}))
            p.parse(eventName, varargin{:});
            eventName = p.Results.EventName;
            refEventName = p.Results.RefEventName;
            trialStartEventName = p.Results.TrialStartEventName;
            trialEndEventName = p.Results.TrialEndEventName;
            firstInTrial = p.Results.FirstInTrial;
            requireTrialType = p.Results.RequireTrialType;

            assert(length(obj) == 1)
            tEvent = obj.getEventTimes(eventName);
            tRef = obj.getEventTimes(refEventName);
            tTrialStart = obj.getEventTimes(trialStartEventName);
            tTrialEnd = obj.getEventTimes(trialEndEventName);
            assert(length(tTrialStart) == length(tTrialEnd));

            if ~isempty(requireTrialType)
                switch lower(requireTrialType)
                    case 'lever'
                        sel = obj.getParams('USE_LEVER') == 1;
                    case 'lick'
                        sel = obj.getParams('USE_LEVER') == 0 & obj.getParams('PAVLOVIAN') == 0;
                end
                tTrialStart = tTrialStart(sel);
                tTrialEnd = tTrialEnd(sel);
                fprintf(1, '%s: %g/%g\n', obj.expName, nnz(sel), length(sel));
            end

            % First find first reference events in each trial.
            trialEdges = [tTrialStart, tTrialEnd]';
            trialEdges = trialEdges(:);
            if any(diff(trialEdges) <= 0)
                warning('Non-incremental event timestamps.')
            end
            [~, ~, binsRef] = histcounts(tRef, trialEdges);
            [uniqueBinsRef, iaRef, ~] = unique(binsRef);
            tRef = tRef(iaRef(uniqueBinsRef > 0));

            % Then bin events into refEdges.
            refEdges = [tRef; Inf];
            [~, ~, binsEvent] = histcounts(tEvent, refEdges);
            if firstInTrial
                [uniqueBinsEvent, iaEvent, ~] = unique(binsEvent);
                tEvent = tEvent(iaEvent(uniqueBinsEvent > 0));
                tRef = refEdges(uniqueBinsEvent(uniqueBinsEvent > 0));
                t = tEvent - tRef;
            else
                tEvent = tEvent(binsEvent > 0);
                binsEvent = binsEvent(binsEvent > 0);
                t = tEvent - refEdges(binsEvent);
            end
        end
    end
end