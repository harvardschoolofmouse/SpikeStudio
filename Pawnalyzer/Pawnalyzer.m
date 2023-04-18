classdef Pawnalyzer < handle
    properties
        sessions
        currentSessionIndex = 1
        currentFrameIndex = 1
    end

    properties (Dependent)
        frameCount
        currentSession
        sessionCount
    end

    properties (Hidden, Transient)
        h = struct('fig', [], 'ax', [], 'img', [], 'annoL', [], 'annoR', [], 'annoFrame', [], 'annoExpName', [], 'roi', [], 'roiListener', [])
    end

    methods
        function obj = Pawnalyzer(sessions)
            if nargin < 1 || isempty(sessions)
                sessions = PawnalyzerSession.load();
            end

            obj.sessions = sessions;
            obj.importLabels();
            obj.show();
        end

        function save(obj)
            edited = [obj.sessions.edited];
            if nnz(edited) > 0
                answer = questdlg(sprintf('Save %i edited sessions?', nnz(edited)), 'Save', 'Yes', 'No', 'Yes');
                if strcmp(answer, 'Yes')
                    obj.sessions(edited).save();
                end
            end
        end

        function importLabels(obj)
            answer = questdlg('Load model generated labels?', 'Labels', 'Yes', 'No', 'Yes');
            if strcmp(answer, 'Yes')
                path = uigetdir('C:\SERVER\PawAnalysis\Data\Predicted\');
                if isfolder(path)
                    obj.sessions.importPawMask(path);
                end
            end

        end

        function export(obj)
            answer = questdlg(sprintf('Export %i sessions?', obj.sessionCount), 'Export', 'Yes', 'No', 'Yes');
            if strcmp(answer, 'Yes')
                obj.sessions.export();
            end
        end

        function [X, y] = exportLabelledFrames(obj, imsize)
            if nargin < 2
                imsize = [150 200];
            end
            answer = questdlg(sprintf('Export labelled frames from up to %i sessions?', obj.sessionCount), 'Export', 'Yes', 'No', 'Yes');
            nSessions = 0;
            if strcmp(answer, 'Yes')
                X = cell(obj.sessionCount, 1);
                y = cell(obj.sessionCount, 1);
                for i = 1:obj.sessionCount
                    s = obj.sessions(i);
                    sel = s.pawMask > 0 & s.pawMask < 3;
                    if nnz(sel) > 0
                        fprintf('%i %i\n', i, nnz(sel))
                        X{i} = imresize(s.roiImg(:, :, 1, sel), imsize);
                        y{i} = s.pawMask(sel);
                        nSessions = nSessions + 1;
                    else
                        X{i} = [];
                        y{i} = [];
                    end
                end
                X = cat(4, X{:});
                y = cat(1, y{:});
            end
            answer = questdlg(sprintf('Save %i labelled frames from %i sessions to file?', length(y), nSessions), 'Export', 'Yes', 'No', 'Yes');
            
            if strcmp(answer, 'Yes')
                save(sprintf('%s\\training_set.mat', 'C:\SERVER\PawAnalysis\Data\Export\'), 'X', 'y', '-v7.3');
            end
            fprintf(1, 'Done.\n')
        end

        function s = get.currentSession(obj)
            if obj.currentSessionIndex <= 0 || obj.currentSessionIndex > length(obj.sessions)
                s = [];
            else
                s = obj.sessions(obj.currentSessionIndex);
            end
        end

        function n = get.frameCount(obj)
            s = obj.currentSession;
            if isempty(s)
                n = 0;
            else
                n = s.frameCount;
            end
        end

        function n = get.sessionCount(obj)
            if isempty(obj.sessions)
                n = 0;
            else
                n = length(obj.sessions);
            end
        end

        function show(obj, varargin)
            p = inputParser();
            p.addOptional('sessionIndex', 0, @isnumeric);
            p.addOptional('frameIndex', 0, @isnumeric);
            p.parse(varargin{:})
            frameIndex = p.Results.frameIndex;
            sessionIndex = p.Results.sessionIndex;

            if sessionIndex < 1 || sessionIndex > length(obj.sessions)
                sessionIndex = obj.currentSessionIndex;
            else
                obj.currentSessionIndex = sessionIndex;
            end

            s = obj.currentSession;

            obj.currentFrameIndex = max(min(frameIndex, obj.frameCount), 1);

            if isempty(obj.h.fig) || ~obj.h.fig.isvalid
                obj.h.fig = figure(Units='normalized', Position=[0.25 0.25 0.5 0.5]);
                obj.h.ax = axes(obj.h.fig, Units='normalized', Position=[0 0 1 1]);
                obj.h.annoL = annotation(obj.h.fig, 'textbox', [0.8, 0, 0.1, 0.1], String='L', ...
                    Color='white', BackgroundColor='black', FontName='Arial Black', FontWeight='normal', FontSize=16, VerticalAlignment='middle', HorizontalAlignment='center');
                obj.h.annoR = annotation(obj.h.fig, 'textbox', [0.9, 0, 0.1, 0.1], String='R', ...
                    Color='white', BackgroundColor='black', FontName='Arial Black', FontWeight='normal', FontSize=16, VerticalAlignment='middle', HorizontalAlignment='center');
                obj.h.annoFrame = annotation(obj.h.fig, 'textbox', [0.9, 0.9, 0.1, 0.1], String='', ...
                    Color='white', BackgroundColor='black', FontName='Arial', FontWeight='bold', FontSize=14, VerticalAlignment='middle', HorizontalAlignment='right');
                obj.h.annoExpName = annotation(obj.h.fig, 'textbox', [0, 0.9, 0.333, 0.1], String='', Interpreter='none', ...
                    Color='white', BackgroundColor='black', FontName='Arial', FontWeight='bold', FontSize=14, VerticalAlignment='middle', HorizontalAlignment='left');

                obj.h.fig.CloseRequestFcn = @obj.onClose;
                obj.h.fig.KeyPressFcn = @obj.onKeyPressed;
            end
            obj.h.img = imshow(s.img(:, :, :,  obj.currentFrameIndex), Parent=obj.h.ax);
            obj.updateAnnotation();
            obj.showROI();
        end

    end

    methods (Access=private)
        %% GUI
        function updateAnnotation(obj)
            s = obj.currentSession;

            % Update frame index
            set(obj.h.annoFrame, String=sprintf('%i / %i', obj.currentFrameIndex, obj.frameCount));

            % Update expName
            if s.edited
                set(obj.h.annoExpName, String=sprintf('%s*\n%i / %i', s.expName, obj.currentSessionIndex, obj.sessionCount));
            else
                set(obj.h.annoExpName, String=sprintf('%s\n%i / %i', s.expName, obj.currentSessionIndex, obj.sessionCount));
            end

            % Update left paw
            if s.getPaw(obj.currentFrameIndex, 'L')
                set(obj.h.annoL, Color='white', BackgroundColor=hsl2rgb([0.4, 0.7, 0.5]))
            else
                set(obj.h.annoL, Color='white', BackgroundColor='black')
            end
            
            % Update right paw
            if s.getPaw(obj.currentFrameIndex, 'R')
                set(obj.h.annoR, Color='white', BackgroundColor=hsl2rgb([0.4, 0.7, 0.5]))
            else
                set(obj.h.annoR, Color='white', BackgroundColor='black')
            end
        end

        function nextFrame(obj)
            if obj.currentFrameIndex < obj.frameCount
                obj.show(obj.currentSessionIndex, obj.currentFrameIndex + 1);
            end
        end

        function prevFrame(obj)
            if obj.currentFrameIndex > 1
                obj.show(obj.currentSessionIndex, obj.currentFrameIndex - 1);
            end
        end

        function nextLabelledFrame(obj)
            if obj.currentFrameIndex < obj.currentSession.frameCount
                index = find(obj.currentSession.pawMask > 0 & transpose(1:length(obj.currentSession.pawMask) > obj.currentFrameIndex), 1, 'first');
                if ~isempty(index)
                    obj.show(obj.currentSessionIndex, index);
                end
            end
        end

        function prevLabelledFrame(obj)
            if obj.currentFrameIndex > 1
                index = find(obj.currentSession.pawMask > 0 & transpose(1:length(obj.currentSession.pawMask) < obj.currentFrameIndex), 1, 'last');
                if ~isempty(index)
                    obj.show(obj.currentSessionIndex, index);
                end
            end
        end

        function nextSession(obj)
            if obj.currentSessionIndex < obj.sessionCount
                obj.show(obj.currentSessionIndex + 1, 1);
            end
        end

        function prevSession(obj)
            if obj.currentSessionIndex > 1
                obj.show(obj.currentSessionIndex - 1, 1);
            end
        end

        function showROI(obj)
            s = obj.currentSession;
            if s.hasROI() && ~obj.isShowingROI()
                obj.createROI(s.roi);
            end
        end

        function b = isShowingROI(obj)
            b = ~isempty(obj.h.roi) && isvalid(obj.h.roi);
        end

        function createROI(obj, position)
            if nargin < 2
                position = [];
            end

            if ~obj.isShowingROI
                if isempty(position)
                    if obj.currentSessionIndex > 1 && ~isempty(obj.sessions(obj.currentSessionIndex - 1).roi)
                        obj.h.roi = drawrectangle(obj.h.ax, Position=obj.sessions(obj.currentSessionIndex - 1).roi, AspectRatio=3/4, FixedAspectRatio=true, Deletable=false);
                    else
                        obj.h.roi = drawrectangle(obj.h.ax, AspectRatio=3/4, FixedAspectRatio=true, Deletable=false);
                    end
                else
                    obj.h.roi = drawrectangle(obj.h.ax, Position=position, AspectRatio=3/4, FixedAspectRatio=true, Deletable=false);
                end
                cm = uicontextmenu();
                uimenu(cm, Text='Delete', MenuSelectedFcn=@obj.deleteROI);

                obj.h.roi.ContextMenu = cm;
                obj.currentSession.roi = obj.h.roi.Position;
                delete(obj.h.roiListener)
                obj.h.roiListener = obj.h.roi.addlistener('ROIMoved', @obj.onROIMoved);
            end
        end

        function deleteROI(obj, varargin)
            obj.currentSession.roi = [];
            delete(obj.h.roi);
            delete(obj.h.roiListener)
        end

        function onROIMoved(obj, src, e)
            obj.currentSession.roi = e.CurrentPosition;
        end

        function onClose(obj, src, e)
            delete(src)
            obj.h.fig = [];
        end

        function onKeyPressed(obj, src, e)
            if any(strcmpi(e.Modifier, 'control')) && any(strcmpi(e.Modifier, 'alt')) && any(strcmpi(e.Modifier, 'shift')) && strcmpi(e.Key, 's')
                obj.export()
                return
            end

            if any(strcmpi(e.Modifier, 'shift')) && strcmpi(e.Key, 'x')
                obj.createROI()
                return
            end

            if any(strcmpi(e.Modifier, 'control')) && strcmpi(e.Key, 's')
                obj.save();
                obj.updateAnnotation();
                return
            end

            if any(strcmpi(e.Modifier, 'control')) && strcmpi(e.Key, 'g')
                answer = inputdlg({'Session', 'Frame'}, 'Jump to...', [1, 15; 1, 15], ...
                    {num2str(obj.currentSessionIndex), num2str(obj.currentFrameIndex)});
                if ~isempty(answer)
                    try
                        sessionIndex = str2double(answer{1});
                        frameIndex = str2double(answer{2});
                        assert(round(sessionIndex) == sessionIndex && round(frameIndex) == frameIndex);
                        obj.show(sessionIndex, frameIndex);
                    catch
                        msgbox('Invalid input, try again.', 'Error')
                    end
                end
                return
            end

            if any(strcmpi(e.Modifier, 'shift'))
                switch e.Key
                    case {'leftarrow'}
                        obj.prevLabelledFrame();
                        return
                    case {'rightarrow'}
                        obj.nextLabelledFrame();
                        return
                end
            end

            if any(strcmpi(e.Modifier, 'shift')) && any(strcmpi(e.Modifier, 'control'))
                switch e.Key
                    case {'a', 'q', 'l'}
                        if obj.currentSession.getPaw(obj.currentFrameIndex, 'L')
                            answer = questdlg('Remove L for all frames?', 'Set All', 'Yes', 'No', 'Yes');
                            if strcmpi(answer, 'yes')
                                obj.currentSession.removePaw(1:obj.frameCount, 'L')
                            end
                        else
                            answer = questdlg('Add L for all frames?', 'Set All', 'Yes', 'No', 'Yes');
                            if strcmpi(answer, 'yes')
                                obj.currentSession.addPaw(1:obj.frameCount, 'L')
                            end
                        end
                        obj.updateAnnotation();
                    case {'d', 'e', 'r'}
                        if obj.currentSession.getPaw(obj.currentFrameIndex, 'R')
                            answer = questdlg('Remove R for all frames?', 'Set All', 'Yes', 'No', 'Yes');
                            if strcmpi(answer, 'yes')
                                obj.currentSession.removePaw(1:obj.frameCount, 'R')
                            end
                        else
                            answer = questdlg('Add R for all frames?', 'Set All', 'Yes', 'No', 'Yes');
                            if strcmpi(answer, 'yes')
                                obj.currentSession.addPaw(1:obj.frameCount, 'R')
                            end
                        end
                        obj.updateAnnotation();
                end
            else
                switch e.Key
                    case {'leftarrow'}
                        obj.prevFrame();
                    case {'rightarrow', 'space'}
                        obj.nextFrame();
                    case 'uparrow'
                        obj.show(obj.currentSessionIndex, obj.currentFrameIndex - 10)
                    case 'downarrow'
                        obj.show(obj.currentSessionIndex, obj.currentFrameIndex + 10)
                    case 'pageup'
                        obj.prevSession();
                    case 'pagedown'
                        obj.nextSession();
                    case {'a', 'q', 'l'}
                        s = obj.currentSession;
                        if s.getPaw(obj.currentFrameIndex, 'L')
                            s.removePaw(obj.currentFrameIndex, 'L')
                        else
                            s.addPaw(obj.currentFrameIndex, 'L')
                        end
                        obj.updateAnnotation();
                    case {'d', 'e', 'r'}
                        s = obj.currentSession;
                        if s.getPaw(obj.currentFrameIndex, 'R')
                            s.removePaw(obj.currentFrameIndex, 'R')
                        else
                            s.addPaw(obj.currentFrameIndex, 'R')
                        end
                        obj.updateAnnotation();
                end
            end
        end
    end
end