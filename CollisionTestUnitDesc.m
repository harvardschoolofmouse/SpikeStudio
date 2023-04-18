classdef CollisionTestUnitDesc < handle
    properties
        Animal = ''
        Date = ''
        ExpName = ''
        File = ''
        Channel = NaN
        Unit = NaN
        HasCollision = false
        HasTrueResponse = false
        HasAnyResponse = false
        Notes = ''
        SpikeRate = NaN
    end

    properties
        CollisionTest
    end

    methods
        function obj = CollisionTestUnitDesc(data)
            if nargin < 1
                return
            end

            if iscell(data)
                obj(1, size(data, 1)) = CollisionTestUnitDesc;
                for i = 1:size(data, 1)
                    obj(i).Animal = data{i, 1};
                    obj(i).Date = data{i, 2};
                    obj(i).ExpName = sprintf('%s_%s', data{i, 1}, data{i, 2});
                    obj(i).Channel = data{i, 3};
                    obj(i).Unit = data{i, 4};
                    obj(i).HasCollision = data{i, 5};
                    obj(i).HasTrueResponse = data{i, 6};
                    obj(i).HasAnyResponse = data{i, 7};
                    obj(i).Notes = data{i, 8};
                    obj(i).File = sprintf('C:\\SERVER\\%s\\CollisionTest\\ct_sorted_%s.mat', obj(i).Animal, obj(i).ExpName);
                end
            elseif isstruct(data)
                obj(1, length(data)) = CollisionTestUnitDesc;
                for i = 1:length(data)
                    obj(i).Animal = data(i).Animal;
                    obj(i).Date = data(i).Date;
                    obj(i).ExpName = sprintf('%s_%s', data(i).Animal, data(i).Date);
                    obj(i).Channel = data(i).Channel;
                    obj(i).Unit = data(i).Unit;
                    obj(i).HasCollision = data(i).HasCollision;
                    obj(i).HasTrueResponse = data(i).HasTrueResponse;
                    obj(i).HasAnyResponse = data(i).HasAnyResponse;
                    obj(i).Notes = data(i).Notes;
                    obj(i).File = sprintf('C:\\SERVER\\%s\\CollisionTest\\ct_sorted_%s.mat', obj(i).Animal, obj(i).ExpName);
                end
            end
        end

        function numFiles = countUnique(obj)
            numFiles = length(unique({obj.File}));
        end

        function read(obj)
        %read - Read ct files.
        %
        % Syntax: getCtFiles(obj)
            [uniqueFiles, ~, iUniqueFiles] = unique({obj.File});
            ct = CollisionTest.load(uniqueFiles);

            for i = 1:length(obj)
                obj(i).CollisionTest = ct(iUniqueFiles(i));
            end

            obj.getSpikeRate();

            TetrodeRecording.RandomWords();
        end

        function plot(obj, latencyCuttoff)
            if nargin < 2
                latencyCuttoff = 1e-3;
            end

            if length(obj) == 1
                obj.CollisionTest.plot(obj.Channel, 'Units', obj.Unit, 'SortPulsesByUnit', obj.Unit, 'CollisionCutoff', latencyCuttoff, 'LimitPulseDuration', [1e-3, 1e-3]);
                return
            end

            for i = 1:length(obj)
                try
                    obj(i).CollisionTest.plot(obj(i).Channel, 'Units', obj(i).Unit, 'SortPulsesByUnit', obj(i).Unit, 'CollisionCutoff', latencyCuttoff, 'LimitPulseDuration', [1e-3, 1e-3]);
                    suptitle(sprintf('%s Chn%d Unit%d (%d/%d)', obj(i).ExpName, obj(i).Channel, obj(i).Unit, i, length(obj)))                
                catch ME
                    warning('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', mfilename, getcallstack(ME), ME.message)
                end
            end
        end

        function getSpikeRate(obj)
            for i = 1:length(obj)
                obj(i).SpikeRate = obj(i).CollisionTest.getSpikeRate(obj(i).Channel, obj(i).Unit);
            end
        end
    end
end