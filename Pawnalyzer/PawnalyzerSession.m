classdef PawnalyzerSession < handle
    properties
        expName
        img
        roi
        tags = {}
    end

    properties (Hidden)
        pawMask % 1, 2, 3 for (left, right, both), 0 for None
    end

    properties (Dependent)
        roiImg
        animalName
        paw
        frameCount
    end

    properties (Hidden, Transient)
        frameIndex = 0
        edited = false
    end

    methods
        function obj = PawnalyzerSession(expName, img)
            obj.expName = expName;
            obj.img = img;
            obj.pawMask = zeros(size(img, 4), 1, 'uint8');
        end
        
        function save(obj, varargin)
            p = inputParser();
            p.addOptional('path', 'C:\SERVER\PawAnalysis\Data\', @ischar)
            p.parse(varargin{:})
            path = p.Results.path;

            if ~isfolder(path)
                assert(mkdir(path) == 1)
            end

            if length(obj) == 1
                save(sprintf('%s\\%s.mat', path, obj.expName), 'obj', '-v7.3');
                obj.edited = false;
            else
                for i = 1:length(obj)
                    obj(i).save(path);
                end
            end
        end

        function export(obj, varargin)
            p = inputParser();
            p.addOptional('path', 'C:\SERVER\PawAnalysis\Data\Export\', @ischar)
            p.addOptional('imsize', [150 200], @isnumeric)
            p.parse(varargin{:})
            path = p.Results.path;
            imsize = p.Results.imsize;

            if ~isfolder(path)
                assert(mkdir(path) == 1)
            end

            if length(obj) == 1
                X = imresize(obj.roiImg, imsize);
                y = obj.pawMask;
                save(sprintf('%s\\%s.mat', path, obj.expName), 'X', 'y', '-v7.3');
            else
                for i = 1:length(obj)
                    obj(i).export(path, imsize);
                end
            end
        end

        function importPawMask(obj, varargin)
            p = inputParser();
            p.addOptional('path', 'C:\SERVER\PawAnalysis\Data\Predicted\', @ischar)
            p.parse(varargin{:})
            path = p.Results.path;

            if length(obj) > 1
                for i = 1:length(obj)
                    obj(i).importPawMask(path);
                end
            else
                filepath = sprintf('%s\\%s.bin', path, obj.expName);
                if isfile(filepath)
                    fid = fopen(filepath, 'r');
                    data = fread(fid, 'uint8');
                    data = reshape(data, length(data), 1);
                    obj.pawMask = data;
                else
                    warning('File not found: %s', filepath)
                end
            end
        end

        function animalName = get.animalName(obj)
            animalName = strsplit(obj.expName, '_');
            animalName = strjoin(animalName(1:end-1), '_');
        end

        function n = get.frameCount(obj)
            n = size(obj.img, 4);
        end

        %% Paw mask getter (as char array, 'N/L/R/B' for neither/left/right/both)
        function pawName = get.paw(obj)
            pawName = repmat('N', size(obj.pawMask));
            pawName(obj.pawMask==1) = 'L';
            pawName(obj.pawMask==2) = 'R';
            pawName(obj.pawMask==3) = 'B';
        end

        %% Ephysunits
        function eu = loadEphysUnits(obj)
            f = dir(sprintf('C:\\SERVER\\Units\\Lite_NonDuplicate\\%s*.mat', obj.expName));
            f = cellfun(@(x) sprintf('C:\\SERVER\\Units\\Lite_NonDuplicate\\%s', x), {f.name}', UniformOutput=false);
            
            eu = EphysUnit.load(f);
        end

        %% Paw mask Read/Write
        function state = getPaw(obj, frameIndex, side)
            side = PawnalyzerSession.pawNameToInt(side);
            state = logical(bitand(obj.pawMask(frameIndex), side, 'uint8'));
        end

        function setPaw(obj, frameIndex, side)
            obj.pawMask(frameIndex) = PawnalyzerSession.pawNameToInt(side);
            obj.edited = true;
        end

        function addPaw(obj, frameIndex, side)
            side = PawnalyzerSession.pawNameToInt(side);
            obj.pawMask(frameIndex) = bitor(obj.pawMask(frameIndex), side, 'uint8');
            obj.edited = true;
        end

        function removePaw(obj, frameIndex, side)
            side = PawnalyzerSession.pawNameToInt(side);
            obj.pawMask(frameIndex) = bitor(obj.pawMask(frameIndex), side, 'uint8') - side;
            obj.edited = true;
        end

        function s = summarizePaw(obj)
            s = sprintf('Total=%d, Left=%d, Right=%d, Both=%d, Neither=%d', ...
                obj.frameCount, nnz(obj.paw=='L'), nnz(obj.paw=='R'), nnz(obj.paw=='B'), nnz(obj.paw=='N'));
        end

        %% ROI
        function b = hasROI(obj)
            b = ~isempty(obj.roi);
        end

        function img = get.roiImg(obj)
            if obj.hasROI
                img = obj.img(obj.roi(2):obj.roi(2)+obj.roi(4), obj.roi(1):obj.roi(1)+obj.roi(3), :, :);
            else
                img = obj.img;
            end
        end

        function set.roi(obj, value)
            obj.edited = true;
            obj.roi = floor(value);
        end

        %% Tags
        function addTag(obj, tag)
            obj.tags = unique([obj.tags, lower(tag)]);
        end
    end

    methods (Static)
        function obj = load(varargin)
            p = inputParser();
            p.addOptional('folderOrFiles', '', @(x) ischar(x) || iscell(x))
            p.parse(varargin{:})

            if isempty(p.Results.folderOrFiles)
                [files, path] = uigetfile({'*.mat'}, 'Select files', 'C:\SERVER\Pawnalysis\Data', MultiSelect='on');
                if ~iscell(files)
                    files = {files};
                end
                files = cellfun(@(x) sprintf('%s\\%s', path, x), files, UniformOutput=false);
            elseif ischar(p.Results.folderOrFiles)
                folder = p.Results.folderOrFiles;
                if p.Results.folderOrFiles(end) == '\'
                    p.Results.folderOrFiles(end) = [];
                end
                files = dir(sprintf('%s\\*.mat', p.Results.folderOrFiles));
                files = cellfun(@(x) sprintf('%s\\%s', folder, x), {files.name}, UniformOutput=false);
            else
                files = p.Results.folderOrFiles;
            end
            
            S(length(files)) = struct('obj', []);
            for iFile = 1:length(files)
                S(iFile) = load(files{iFile}, 'obj');
                S(iFile).obj.img = S(iFile).obj.img(:, :, 1, :);
            end
            obj = [S.obj];
        end
    end

    methods (Access=private, Static)
        function side = pawNameToInt(side)
            switch lower(side)
                case 'l'
                    side = bitshift(uint8(1), 0, 'uint8');
                case 'r'
                    side = bitshift(uint8(1), 1, 'uint8');
                case 'b'
                    side = bitand(bitshift(uint8(1), 0, 'uint8'), bitshift(uint8(1), 1, 'uint8'), 'uint8');
                case 'n'
                    side = uint8(0);
                otherwise
                    error('Unrecognized side %s, must be "l", "r", "b", or "n"', side)
            end
        end
    end
end