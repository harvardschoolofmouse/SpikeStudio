classdef SpikeStudio < TetrodeRecording
    % 
    %   Creates a SpikeStudio object for spikesorting. 
    %       Datatypes equipped: Intan (rhd) -- ideally split into 1 min chunks
    % 
    %   "SS" -- refers to SpikeSorter output
    %   "LFH" -- refers to TetrodeRecording by Lingfeng Hou (LFH)
    %   
    %   Created     ahamilos    4/11/2023
    %   Modified    ahamilos    7/28/2023       versionCode = 'v0.2.1'
    %   Dependencies:   TetrodeRecording (by Lingfeng Hou)
    %                   cprintf Toolbox
    %                   SpikeSorter output csv files:
    %     For use with csv files produced from Spike Sorter v5.0 from Swindale
    %           lab, British Columbia 
    %               https://swindale.ecc.ubc.ca/home-page/software/
    % 
    properties
        iv
        % System = ''
        % Files = []
        % Path = []
        % Part = [1, 1]
        % Notes
        % FrequencyParameters
        % ChannelMap
        % SelectedChannels
        % Spikes
        % DigitalEvents
        % AnalogIn
        % StartTime
        % SpikeSorterData
    end

    properties (Transient)
        % Amplifier
        % BoardDigIn
        % BoardADC
        % NEV
        % NSx
        % UserData
    end

    %----------------------------------------------------
    %       Methods
    %----------------------------------------------------
    methods
        function obj = SpikeStudio(tr)
            %
            %   Can either take an existing tr obj and make a SpikeStudio object, or it can create from scratch
            %
            obj.iv.versionCode = 'v0.2.1';
            obj.spikeStudioAlerts;
            cprintf(['*' mat2str(obj.iv.SpikeStudioAlerts.info)], '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n')
            cprintf(['*' mat2str(obj.iv.SpikeStudioAlerts.info)], ['             Spike Studio, ' obj.iv.versionCode ' \n'])
            obj.alert('info', '            "We''ve got the spikes" ')
            disp(' ')
            obj.alert('info', '       (c) Harvard School of Mouse, 2023 ')
            obj.alert(['*' mat2str(obj.iv.SpikeStudioAlerts.info)], '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
            if nargin >= 1
                obj.System = tr.System;
                obj.Files = tr.Files;
                obj.Path = tr.Path;
                obj.Part = tr.Part;
                obj.Notes = tr.Notes;
                obj.FrequencyParameters = tr.FrequencyParameters;
                obj.ChannelMap = tr.ChannelMap;
                obj.SelectedChannels = tr.SelectedChannels;
                obj.Spikes = tr.Spikes;
                obj.DigitalEvents = tr.DigitalEvents;
                obj.AnalogIn = tr.AnalogIn;
                obj.StartTime = tr.StartTime;
                obj.SpikeSorterData = tr.SpikeSorterData;
                obj.Amplifier = tr.Amplifier;
                obj.BoardDigIn = tr.BoardDigIn;
                obj.BoardADC = tr.BoardADC;
                obj.NEV = tr.NEV;
                obj.NSx = tr.NSx;
                obj.UserData = tr.UserData;
            else % initialize a new SpikeStudio session...
               
                %% read in spikesorter data. you need to specify the files before this
                if ~ispc, cprintf(obj.iv.SpikeStudioAlerts.info, '--> Select raw ephys files (*.rhd). These should be 1 min chunks of files from Intan. \n'), end
                q = obj.SelectFiles();
                if q
                    cprintf(obj.iv.SpikeStudioAlerts.achtung, 'User did not select any .rhd files! Sad face for you :( -- Quitting. \n')
                    return
                end
                if ~ispc, cprintf(obj.iv.SpikeStudioAlerts.info, '--> Select SpikeSorter output (*.csv). This should be the csv output of SpikeSorter after post-processing. \n'), end
                units = obj.import_spikes();
                if isempty(units)
                    cprintf(obj.iv.SpikeStudioAlerts.achtung, 'User did not select any .csv files! Sad face for you :( -- Quitting. \n')
                    return
                end

                obj.iv.QC.n_units = numel(cell2mat([{units.times}']));
                obj.UserData.tol = 0.0000007;
                %

                obj.ReadFiles('ChunkSize',3,... % this function is in TetrodeRecording
                    'SpikeSorterAlign',true,...
                    'SpikeSorterCSV',units,...
                    'WaveformWindow', [-2, 2],...
                    'AlertText', obj.iv.SpikeStudioAlerts);
                disp(' ')
                obj.alert('info','SpikeStudio data imported!')
                % then do a quality check...there should be as many units in our bank as exist in the file
                obj.iv.QC.n_units_read_in = sum(cell2mat(cellfun(@(x) numel(cell2mat({x.SampleIndex})), {obj.SpikeSorterData.Unit}, 'uniformoutput', 0)));
                if obj.iv.QC.n_units_read_in ~= obj.iv.QC.n_units
                    obj.alert('achtung','       Did not find same # of units in the selected files as existed in the SpikeSorter csv. \n        This can happen if you didn''t load in all the rhd files. \n        If you did, you better check!')
                    obj.alert('achtung', ['     Imported only ' num2str(obj.iv.QC.n_units_read_in) ' of ' num2str(obj.iv.QC.n_units) ' in SpikeSorter'])
                else
                    obj.alert('info', ['    Successfully imported all ' num2str(obj.iv.QC.n_units) ' spike waveforms from SpikeSorter and Ephys Data!'])
                end
                disp(' ')

            end
            % get the animal's name and recording site from the filename...
            obj.getSessionInfo();
            % save the obj
            obj.alert('achtung','SpikeStudio obj initialized but NOT saved yet.')
            disp(' ')
            obj.alert('info', ['    (' datestr(now,'mm/dd/yyyy HH:MM AM') ') SpikeStudio Session Initialized.']);
            obj.alert('info', '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
            % obj.save();
        end
        function save(ss)
            timestamp_now = datestr(now,'yyyymmdd__HHMM');
            savefilename = ['SpikeStudio_' ss.iv.mousename_ '_' ss.iv.signalname_ '_' ss.iv.daynum_ '_' timestamp_now];
            save([savefilename, '.mat'], 'ss', '-v7.3');
            disp(' ')
            ss.alert('info', ['(' datestr(now,'mm/dd/yyyy HH:MM AM') ') Saved SpikeStudio Session to ' strjoin(strsplit(pwd, '\'), '/') savefilename '.mat']);
            disp(' ')
            disp(' ')
        end
        function spikeStudioAlerts(obj)
            % 
            %   Sets color palette for SpikeStudio alerts! (cprintf)
            % 
            obj.iv.SpikeStudioAlerts.info = [0,0.6,0.6];
            obj.iv.SpikeStudioAlerts.achtung = '*[1,0.6,0]';
            obj.iv.SpikeStudioAlerts.thinking = [0.3,0.5,0.8];
        end
        function alert(obj, Style, txt)
            Alerts = obj.iv.SpikeStudioAlerts;
            switch Style
                case 'info'
                    cprintf(Alerts.info, [txt, '\n'])
                case 'achtung'
                    cprintf(Alerts.achtung, [txt, '\n'])
                case 'thinking'
                    cprintf(Alerts.thinking, [txt, '\n'])
                otherwise
                    cprintf(Style, [txt, '\n'])
            end
        end
        function getSessionInfo(obj)
            if isempty(obj.Path)
                if ~ispc, obj.alert('info', '--> Select the directory where ephys files saved.'), end
                PathName = uigetdir('Select the directory where ephys files saved.');
                obj.Path = PathName;
            else PathName = obj.Path;
            end
            % get the animal's name and session deets
            PathComps = strsplit(PathName,{'\', '/'});
            PathComps = PathComps(cellfun(@(x) ~isempty(x), PathComps));
            PathComps = PathComps{end};
            SeshInfo = strsplit(PathComps,'_');
            obj.iv.mousename_ = SeshInfo{1};
            obj.iv.signalname_ = SeshInfo{2};
            obj.iv.daynum_ = SeshInfo{3};
        end
        function units = import_spikes(obj, Recycle)
            %
            %  For use with csv files produced from Spike Sorter v5.0 from Swindale
            %  lab, British Columbia 
            %       https://swindale.ecc.ubc.ca/home-page/software/
            %       Saved to Assad Lab / Spike Sorting folder on server
            %
            %   Start by sorting your spikes in Spike Sorter. Export the csv file.
            %   Read it in here
            % 
            obj.alert('thinking', ['(' datestr(now,'mm/dd/yyyy HH:MM AM') ') Loading SpikeSorter units...'])
            if nargin <2 || ~ Recycle
                [FileName,PathName,FilterIndex]= uigetfile('./*.csv', 'Select SpikeSorter CSV file (*.csv)');
                obj.iv.SpikeSorterCSVfile = [PathName, FileName];
                if ~ischar(PathName)
                    units = [];
                    return
                end
                cd(PathName)
            end            
            % pull in the spike data: Col1=times, Col2=unit#, Col3=electrode channel#
            A = readmatrix(obj.iv.SpikeSorterCSVfile);
            % allocate spike times to each unit
            unit_nos = unique(A(:,2));
            units.times = {};
            units.channels = {};
            for u = 1:numel(unit_nos)
                units(u).times = A(A(:,2)==u,1);
                units(u).channels = A(A(:,2)==u,3);
                if sum(units(u).times ~= sort(units(u).times)) >0
                    numoff = sum(units(u).times ~= sort(units(u).times));
                    obj.alert('achtung', ['     Found ' num2str(numoff) ' timestamp(s) out of order for unit ', num2str(u) ]) %: ' mat2str(units(u).times(units(u).times ~= sort(units(u).times)))])
                end
            end 
            obj.UserData.units = units;
        end
        function not_same = QC_check_timestamps(obj, units)
            if nargin < 2, units = obj.import_spikes(true); end
            timestamps_read_in = sort(cell2mat(cellfun(@(x) cell2mat({x.Timestamps}), {obj.SpikeSorterData.Unit}, 'uniformoutput', 0)))';
            assert(numel(timestamps_read_in), obj.iv.QC.n_units)
            % compare the timestamps read in to those from SpikeSorter...
            times_SS = sort(cell2mat({units.times}'));
            % check length...
            if length(timestamps_read_in) ~= length(times_SS), warning(['The length of timestamps read in by SpikeStudio from Intan was only ' num2str(timestamps_read_in), ', but SpikeSorter found ' num2str(times_SS)]); end
            % if lengths not equal, may be because not using same number of files from Intan. So truncate times_SS and then compare
            not_same = find(~ismembertol(times_SS, timestamps_read_in, 10^-5));%find(times_SS(1:length(timestamps_read_in)) ~= timestamps_read_in);
            if ~isempty(not_same), obj.alert('achtung', 'There were missing timestamps! not_same will tell which SS timestamps missing from our read-in of Intan waveforms...'), end
        end
        function not_same = QC_check_samples(obj, units)
            if nargin < 2, units = obj.import_spikes(true); end
            timestamps_read_in = sort(cell2mat(cellfun(@(x) cell2mat({x.Timestamps}), {obj.SpikeSorterData.Unit}, 'uniformoutput', 0)))';
            assert(numel(timestamps_read_in), obj.iv.QC.n_units)
            % compare the timestamps read in to those from SpikeSorter...
            times_SS = sort(cell2mat({units.times}'));
            % check length...
            if length(timestamps_read_in) ~= length(times_SS), warning(['The length of timestamps read in by SpikeStudio from Intan was only ' num2str(timestamps_read_in), ', but SpikeSorter found ' num2str(times_SS)]); end
            % if lengths not equal, may be because not using same number of files from Intan. So truncate times_SS and then compare
            not_same = find(~ismembertol(times_SS, timestamps_read_in, 10^-5));%find(times_SS(1:length(timestamps_read_in)) ~= timestamps_read_in);
            if ~isempty(not_same), obj.alert('achtung', 'There were missing timestamps! not_same will tell which SS timestamps missing from our read-in of Intan waveforms...'), end
        end
        function compareUnitsOnChannel(obj, varargin)
            % 
            %   Here, we will examine all waveforms in each SS cluster on the same channel to see if we should merge
            % 
            %   compareUnitsOnChannel(tr,...
                    % 'ch',4,...
                    % 'refevents', [],...% tr.DigitalEvents.JuiceOn
                    % 'refName', '',...% 'Reward'
                    % 'compareAll', false,...
                    % 'compareMeans', true,...
                    % 'comparePeakTrough', true,...
                    % 'PeakTroughTimecourse', true ...
                    % ,...
                    % 'Raster', false,...
                    % 'PETH', false,...
                    % 'Xcorr_ISI', false);
            % 
            % 
            p = inputParser;
            addParameter(p, 'ch', 1, @isnumeric); 
            addParameter(p, 'refevents', [], @isnumeric);
            addParameter(p, 'refName', '', @ischar);
            addParameter(p, 'compareAll', false, @islogical);
            addParameter(p, 'compareMeans', false, @islogical);
            addParameter(p, 'comparePeakTrough', false, @islogical);
            addParameter(p, 'PeakTroughTimecourse', false, @islogical);
            addParameter(p, 'Raster', false, @islogical);
            addParameter(p, 'PETH', false, @islogical);
            addParameter(p, 'Xcorr_ISI', false, @islogical);
            parse(p, varargin{:});
            ch              = p.Results.ch;
            refevents       = p.Results.refevents;
            refName         = p.Results.refName;
            compareAll      = p.Results.compareAll;
            compareMeans    = p.Results.compareMeans;
            comparePeakTrough  = p.Results.comparePeakTrough;
            PeakTroughTimecourse = p.Results.PeakTroughTimecourse;
            Raster          = p.Results.Raster;
            PETH            = p.Results.PETH;
            compareAll      = p.Results.compareAll;
            Xcorr_ISI       = p.Results.Xcorr_ISI;
            

            if ~isfield(obj.UserData, 'SpikeSorterMap') || numel(obj.UserData.SpikeSorterMap) < ch || isempty(obj.UserData.SpikeSorterMap(ch).units_onch), obj.getUnitsOnChannel(ch, [], obj.iv.SpikeStudioAlerts);end
            units = obj.UserData.SpikeSorterMap(ch).units_onch;
            C = linspecer(numel(units));

            % get number of spikes in each unit and the total time...
            s_b4 = 10;
            s_post = 10;
            maxtime = 0;
            for ii = 1:numel(units)
                if numel([obj.SpikeSorterData(units(ii)).Unit.Channels]) > 1
                    ch_idx(ii) = find([obj.SpikeSorterData(units(ii)).Unit.Channels] == ch);
                    % let's use all the data for this unit on this channel...
                    uts = [obj.SpikeSorterData(units(ii)).Unit(ch_idx).Timestamps];
                    obj.alert('achtung', ['Although unit ' num2str(units(ii)) ' was on channels ' mat2str([obj.SpikeSorterData(8).Unit.Channels]), ', we ONLY are including this channel''s data in this analysis...'])
                else
                    ch_idx(ii) = 1;
                    uts = obj.SpikeSorterData(units(ii)).Unit.Timestamps;
                end
                n(ii) = numel(uts);
                maxtime = max(maxtime, max(uts));
            end
            [~,II] = sort(n);
            II = fliplr(II);
            if isempty(refName)
                refName = 'pseudocue (q5s)';
                refevents = 5:5:maxtime;
            end
            
            if compareAll, [f,ax] = makeStandardFigure(numel(units), [1, numel(units)]);f.Units = 'Normalized';
                f.Position = [0.7,0, 0.3, 0.3];suptitle(['channel ', num2str(ch)])
            end
            if compareMeans,[f2,ax2] = makeStandardFigure;f2.Units = 'Normalized';
                f2.Position = [0.7,0.3, 0.3, 0.3];suptitle(['channel ', num2str(ch)])
            end
            if comparePeakTrough, [f3,ax3] = makeStandardFigure;f3.Units = 'Normalized';
                f3.Position = [0.7,0.65, 0.3, 0.3];suptitle('Minimum and Maximum Excursions')
            end
            if PeakTroughTimecourse, [f4,ax4] = makeStandardFigure;f4.Units = 'Normalized';
                f4.Position = [0.4,0, 0.3, 0.3];suptitle(['channel ', num2str(ch)])
            end
            if Raster, [f6,ax6] = makeStandardFigure;f6.Units = 'Normalized';
                f6.Position = [0.4,0.3, 0.3, 0.3];suptitle(['channel ', num2str(ch)])
            end
            if PETH, [f7,ax7] = makeStandardFigure;f7.Units = 'Normalized';
                f7.Position = [0.1,0.65, 0.3, 0.3];suptitle(['channel ', num2str(ch)]),xlabel(ax7, ['time (s) wrt ' refName])
            end
            yy = [0,0];
            
            
            for ii = 1:numel(units)
                u = units(ii);
                % xx = obj.SpikeSorterData(u).Unit.WaveformTimestamps;
                % V = obj.SpikeSorterData(u).Unit.Waveforms;
                st = obj.SpikeSorterData(u).Unit.Timestamps;
                Spikes{ii} = st;

                % plot 200 waveforms from each unit on the channel
                yy = [0,0];
                if compareAll
                    obj.plotWaveforms(ax(ii), u, ch_idx(ii), 200);
                    yi = ylim(ax(ii));
                    yy = [(yi(1)<=yy(1))*yi(1) + (yy(1)<=yi(1))*yy(1), (yi(2)>=yy(2))*yi(2) + (yy(2)>=yi(2))*yy(2)];
                    ylim(ax(ii), yy)
                end

                % plot ave waveforms from all units on the channel
                if compareMeans,  obj.plotMeanWaveform(ax2, u, ch_idx(ii), C(ii,:)); end

                % plot the histogram of spike amplitudes
                if comparePeakTrough, peak_peak = obj.negativeExcursionHistogram(ax3, xx, V, C(ii,:), u);end
                    
                % plot the timecourse of spikes
                if PeakTroughTimecourse, obj.plotSpikeTimecourse(ax4, peak_peak, st, C(ii,:), u); end

                % append raster
                if Raster
                    [~, spikes_wrt_event, firstspike_wrt_event] = obj.binupspikes(st,refevents,s_b4, s_post);
                    obj.plotraster(spikes_wrt_event, firstspike_wrt_event, 'referenceEventName', refName, 'Color', C(ii,:), 'dispName', ['unit #' num2str(u)], 'markerSize', 200-50*ii, 'ax', ax6, 'plotFirst', true, 'append', ii ~=1);
                    xlim(ax6,[-0.01,5])
                end

                % get PETH
                if PETH, obj.plotPETH(spikes_wrt_event, ax7, C(ii,:), ['unit #', num2str(u)], -2, 5,0.25);end
            end
            if compareAll, linkaxes(ax, 'y'); end

            
            
            
            % compare the ISI's and xcorrelation
            if Xcorr_ISI
                [~,ax5] = obj.compareISI(Spikes, C, units);
                if II(1) > 1,reversePlotOrder(ax5, 'reverse'); end
            end
            
            % optimize plot order
            if compareMeans,reversePlotOrder(ax2, II);end
            if comparePeakTrough, reversePlotOrder(ax3, II);end
            if PeakTroughTimecourse, reversePlotOrder(ax4, II);end
            
        end
        function [xl, xr] = checkIntanPlotCache(obj, Channel)
            %
            %   We'll check the UserData.IntanPlotCache field to see what
            %   timepoints we have loaded so far
            %
            if ~isfield(obj.UserData, 'IntanPlotCache') || numel({obj.UserData.IntanPlotCache.Timestamps}) < Channel || isempty(obj.UserData.IntanPlotCache(Channel).Timestamps)
                xl = 0;xr = 0;
            else
                xl = min(obj.UserData.IntanPlotCache(Channel).Timestamps);
                xr = max(obj.UserData.IntanPlotCache(Channel).Timestamps);
            end
        end
        function appendIntanPlotCache(obj, fileNos, Channel, Hz, sizeEscape)
            AlertText = obj.iv.SpikeStudioAlerts;
            %             
            % Figure out what times we have cached so far. Then figure out
            % what times we need to add. Then figure out what files those
            % times live on. If the plot cache will be too big, warn the
            % user and escape. If proceeding, load in those intan files and
            % downsample
            % 
            if nargin < 5
                sizeEscape = 32*3;
            end
            if ~isfield(obj.UserData, 'IntanPlotCache') || length({obj.UserData.IntanPlotCache.Hz}) < Channel
                obj.UserData.IntanPlotCache(Channel).Hz = Hz;
                obj.UserData.IntanPlotCache(Channel).Timestamps = [];
                obj.UserData.IntanPlotCache(Channel).Waveform = [];
                obj.UserData.IntanPlotCache(Channel).FilesLoaded = [];
            else
                if Hz ~= obj.UserData.IntanPlotCache(Channel).Hz
                    error('The requested sampling rate (Hz) did not match what was already loaded and stored. Clear the obj.UserData.IntanPlotCache or fix the sampling rate.')
                end
            end
            downsample_x = obj.FrequencyParameters.AmplifierSampleRate / Hz;
            % get the total files in the cache:
            totalloadedFiles = unique([obj.UserData.IntanPlotCache.FilesLoaded]);
            total_n_loadedFiles = numel(totalloadedFiles);
            loadedFiles_thisChannel = obj.UserData.IntanPlotCache(Channel).FilesLoaded;
%             n_loadedFiles_thisChannel = numel(loadedFiles_thisChannel);

            % check if required files have not been loaded in
            if sum(~ismember(fileNos,loadedFiles_thisChannel))>=1 % we need to load more data
                filesToAppend = fileNos(~ismember(fileNos,loadedFiles_thisChannel));
                files_to_get = sort(unique(filesToAppend));
                % check how long our filecount is getting...
                new_total_n_loadedFiles = total_n_loadedFiles + numel(files_to_get);
                if new_total_n_loadedFiles >= sizeEscape
                    obj.alert('*[1,0,0]', ['Too many files! The # of files requested is ', num2str(new_total_n_loadedFiles) '. Aborting.'])
                    return
                else
                    obj.alert('info', ['Total files requested is ', num2str(new_total_n_loadedFiles)])
                end
                Timestamps_Intan = [];
                Waveforms_Intan = [];
                for ifile = 1:numel(files_to_get)
                    fileNo = files_to_get(ifile);
                    % load the missing data...
                    obj.ReadIntan(obj.Files(fileNo), AlertText);
                    Timestamps_Intan = [Timestamps_Intan, obj.Amplifier.Timestamps(1:downsample_x:end)];
                    Waveforms_Intan = [Waveforms_Intan, obj.Amplifier.Data(Channel, 1:downsample_x:end)];
                end
                % get everything in proper order...
                [Timestamps_sorted, is] = sort([obj.UserData.IntanPlotCache(Channel).Timestamps,Timestamps_Intan]);
                Waveforms = [obj.UserData.IntanPlotCache(Channel).Waveform,Waveforms_Intan];
                Waveforms_sorted = Waveforms(is);
                % add the new data to the cache
                obj.UserData.IntanPlotCache(Channel).Timestamps = Timestamps_sorted;
                obj.UserData.IntanPlotCache(Channel).Waveform = Waveforms_sorted;
                obj.UserData.IntanPlotCache(Channel).FilesLoaded = [obj.UserData.IntanPlotCache(Channel).FilesLoaded,files_to_get];
            end


        end
        function [f, ax, g] = initializeContextPlotGUI(obj)
            [f, ax, g] = makeStandardUIFigure();
            set(f, 'units', 'normalized', 'Position', [0.05, 0.2, 0.9,0.2])
            legend(ax,'show')
            xlabel(ax, 'time (s)')
            ylabel(ax, 'µV')
            colNum = 1;
            b0 = uibutton(g, ...
                "Text","< Event", ...
                "Position",[0.0 0.05 0.025 0.05],...
                "ButtonPushedFcn", @(src,event) obj.prevEventPushedFcn(ax));
            b0.Layout.Row = 2;
            b0.Layout.Column = colNum;
            b = uibutton(g, ...
                "Text","Event >", ...
                "Position",[0.0 0.05 0.025 0.05],...
                "ButtonPushedFcn", @(src,event) obj.nextEventPushedFcn(ax));
            b.Layout.Row = 2;
            b.Layout.Column = b0.Layout.Column+1;
            b2 = uibutton(g, ...
                "Text","Toggle Unit", ...
                "Position",[0.0 0.05 0.025 0.05],...
                "ButtonPushedFcn", @(src,event) obj.toggleUnitFcn(ax));
            b2.Layout.Row = 2;
            b2.Layout.Column = b.Layout.Column+1;
            b3 = uibutton(g, ...
                "Text","<<", ...
                "Position",[0.0 0.05 0.025 0.05],...
                "ButtonPushedFcn", @(src,event) obj.xStep(ax, -5*0.075));
            b3.Layout.Row = 2;
            b3.Layout.Column = b2.Layout.Column+1;
            b4 = uibutton(g, ...
                "Text","<", ...
                "Position",[0.0 0.05 0.025 0.05],...
                "ButtonPushedFcn", @(src,event) obj.xStep(ax, -0.05));
            b4.Layout.Row = 2;
            b4.Layout.Column = b3.Layout.Column+1;
            b5 = uibutton(g, ...
                "Text",">", ...
                "Position",[0.0 0.05 0.025 0.05],...
                "ButtonPushedFcn", @(src,event) obj.xStep(ax, 0.05));
            b5.Layout.Row = 2;
            b5.Layout.Column = b4.Layout.Column+1;
            b6 = uibutton(g, ...
                "Text",">>", ...
                "Position",[0.0 0.05 0.05 0.05],...
                "ButtonPushedFcn", @(src,event) obj.xStep(ax, 5*0.075));
            b6.Layout.Row = 2;
            b6.Layout.Column = b5.Layout.Column+1;


            lbl = uilabel(g,...
                  "Position",[130 100 100 15]);
%             lbl.Layout.Row = 2;
%             lbl.Layout.Column = b6.Layout.Column + 1;
            
            txt = uieditfield(g,...
                  "Numeric",...
                  "Position",[100 175 100 22],...
                  "ValueChangedFcn",@(txt,event) obj.eventToggleIncrement(ax,txt,lbl));
            txt.Layout.Row = 2;
            txt.Layout.Column = b6.Layout.Column + 1;

            lbl2 = uilabel(g,...
                  "Position",[130 100 100 15] ...
                  );            
            txt2 = uieditfield(g,...
                  "numeric",...
                  "RoundFractionalValues","on",...
                  "Limits", [1,inf],...
                  "Position",[100 175 100 22],...
                  "ValueChangedFcn",@(txt2,event) obj.eventToggleEvent(ax,txt2,lbl2));
            txt2.Layout.Row = 2;
            txt2.Layout.Column = txt.Layout.Column + 1;

            b7 = uibutton(g, ...
                "Text","save", ...
                "Position",[0.0 0.05 0.05 0.05],...
                "ButtonPushedFcn", @(src,event) obj.saveContextPlot(f,ax));
            b7.Layout.Row = 2;
            b7.Layout.Column = txt2.Layout.Column+1;

        end
        function saveContextPlot(obj,f,ax)
            timestamp_now = datestr(now,'yyyymmdd__HHMM');
            ch = strsplit(ax.Title.String, ' ');
            savefilename = ['contextPlot_' strjoin({ch{1}, ch{2}}, '_'), '_' obj.iv.mousename_ '_' obj.iv.signalname_ '_' obj.iv.daynum_ '_' timestamp_now];
            savefig(f, savefilename);
            disp(' ')
            obj.alert('info', ['(' datestr(now,'mm/dd/yyyy HH:MM AM') ') Saved ContextPlot to ' strjoin(strsplit(pwd, '\'), '/') savefilename '.mat']);
            disp(' ')
            disp(' ')
        end
        function eventToggleIncrement(obj,ax,txt,lbl)
            lbl.Text = num2str(txt.Value);
            obj.goToNextEvent(ax,str2double(lbl.Text))
        end
        function eventToggleEvent(obj,ax,txt,lbl)
            lbl.Text = num2str(txt.Value);
            obj.goToEvent(ax,str2double(lbl.Text))
        end
        function [f,ax,g] = contextPlot(obj, timeRange, ch, f,ax)
            %
            %   We will now define a timeRange to observe and then plot the
            %   units on that channel in that range
            %
            % check for units on that channel with times in range
            if ~isfield(obj.UserData, 'SpikeSorterMap') || numel(obj.UserData.SpikeSorterMap) < ch || isempty(obj.UserData.SpikeSorterMap(ch).units_onch)
                obj.getUnitsOnChannel(ch, [], obj.iv.SpikeStudioAlerts);
            end
            units_onch = obj.UserData.SpikeSorterMap(ch).units_onch;
            % if there are other channels on any of these units, let's plot
            % those, too
            chToGet = unique(cell2mat(cellfun(@(x) [x.Channels], {obj.SpikeSorterData(units_onch).Unit}, 'uniformoutput',0)));
            %
            %   let's find the times from each channel to get...
            %
            for i_ch = 1:numel(chToGet) % for each channel in play
                % get the channel's data
                this_ch = chToGet(i_ch);
                if numel(obj.UserData.SpikeSorterMap) < this_ch || isempty(obj.UserData.SpikeSorterMap(this_ch).units_onch)
                    obj.getUnitsOnChannel(this_ch, [], obj.iv.SpikeStudioAlerts);
                end
                % now get all the units on those channels that are of interest
                units_on_thisch = obj.UserData.SpikeSorterMap(this_ch).units_onch;
                first_unit = true;
                for i_unit = 1:numel(units_on_thisch)
                    this_unit_no = units_on_thisch(i_unit);
                    this_ch_idx = find([obj.SpikeSorterData(this_unit_no).Unit.Channels] == this_ch);
                    % find the unit idxs we care about
                    ts = obj.SpikeSorterData(this_unit_no).Unit(this_ch_idx).Timestamps;
                    eventNos = find(ts > timeRange(1) & ts < timeRange(2));
                    if isempty(eventNos), obj.alert('achtung', ['>>SpikeStudio: No spikes within ' mat2str(timeRange), 's on channel ' num2str(this_ch) ' unit #' num2str(this_unit_no)]), end%continue, end
                    if first_unit
                        [f,ax] = obj.plotInContext(this_unit_no,this_ch,eventNos,3);
                    else
                        [f,ax] = obj.plotInContext(this_unit_no,this_ch,eventNos,3, f, ax);
                    end
                    first_unit = false;
                end
                if i_ch == 1
                    f.Position(2) = f.Position(2)-0.2;
                elseif i_ch == 3
                    f.Position(2) = f.Position(2)+0.2;
                elseif i_ch == 4
                    f.Position(2) = f.Position(2)+0.4;
                elseif i_ch == 5
                    f.Position(2) = f.Position(2)+0.6;
                elseif i_ch >= 6
                    f.Position(1) = f.Position(1)+i_ch/6/10;
                end
                f = [];
            end
        end
        function [f,ax,g] = plotInContext(obj,unitNo,channelNo,eventNos,s_buffer, f, ax)
            % 
            %   The idea is we want to show the timeseries surrounding some events
            %   We will find the files the event is on and re-open them
            %   We will collect a down-sampled version of the timeseries (stored in UserData.ContextPlot)
            %   We will hilight the event with a box!
            % 
            downsample_x = 2;
            Hz = obj.FrequencyParameters.AmplifierSampleRate / downsample_x;
            AlertText = obj.iv.SpikeStudioAlerts;
            if nargin < 3
                unitNo = 11;
                channelNo = 4;
                eventNos = 1:6;
                s_buffer = 5;
            end
            if nargin >= 6 % recycling plot mode
                recyclingMode = true;
            else
                recyclingMode = false;
                [f,ax,g] = obj.initializeContextPlotGUI;
            end
            %
            %   Determine what files the events are on and their timestamps
            %
            unitData = obj.SpikeSorterData(unitNo).Unit;
            channelsOnUnit = [unitData.Channels];
            channel_index = channelsOnUnit == channelNo;
            if isempty(channel_index)
                obj.alert('achtung', '>>SpikeStudio: The named channel was not on the unit!'), 
                return;
            end
            if ~isempty(eventNos)
                eventTimes = unitData(channel_index).Timestamps(eventNos);
            else
                eventTimes = nan;
            end
            %
            %   Let's now find the relevant window...
            %
            eventTimes_l = eventTimes - 0.001;
            eventWindow_l = min(eventTimes)-s_buffer;
            eventWindow_r = max(eventTimes)+s_buffer;
            %
            %   Look at our obj.UserData and decide if we have all
            %   the Intan waveforms in the cache that we need to make this
            %   plot
            %
            [xl, xr] = obj.checkIntanPlotCache(channelNo);
            if min(eventWindow_l) < xl || max(eventWindow_r) > xr
                % we have to load more data...
                fileNos = unitData(channel_index).FileNo(eventNos);
                files_to_get = unique(fileNos);
                obj.appendIntanPlotCache(files_to_get, channelNo, Hz)
            end
            

           

            %
            %   We now should check to see if the timeseries already plotted 
            %   includes all the timeseries needed for the new unit. If not, 
            %   we will need to append the plot
            %
            

            if recyclingMode
                plotData = ax.UserData;
                ts_h = plotData.ts_h;
                xl_plotted = min(ts_h.XData);
                xr_plotted = max(ts_h.XData);
                if isempty(xl_plotted), xl_plotted = nan;xr_plotted=nan;end
                
                if eventWindow_l < xl_plotted || eventWindow_r > xr_plotted || isnan(xl_plotted(1))
                    new_xl = nanmin(xl_plotted, eventWindow_l);
                    new_xr = nanmax(xr_plotted, eventWindow_r);
                    
                    Timestamps_Intan = obj.UserData.IntanPlotCache(channelNo).Timestamps;
                    Waveforms_Intan = obj.UserData.IntanPlotCache(channelNo).Waveform;
                    ii = Timestamps_Intan >= new_xl & Timestamps_Intan <= new_xr;
                    xx = Timestamps_Intan(ii);
                    yy = Waveforms_Intan(ii);
                    plotData.ts_h.XData = xx;
                    plotData.ts_h.YData = yy;
                    ax.UserData  = plotData;
                end
            else
                fileNos = unitData(channel_index).FileNo(eventNos);
                files_to_get = unique(fileNos);
                obj.alert('info', ['>>SpikeStudio: The specified spikes live on ', num2str(numel(files_to_get)) ' files.'])
                %             
                %   Find the timestamps of interest to plot
                % 
                Timestamps_Intan = obj.UserData.IntanPlotCache(channelNo).Timestamps;
                Waveforms_Intan = obj.UserData.IntanPlotCache(channelNo).Waveform;
                ii = Timestamps_Intan >= eventWindow_l & Timestamps_Intan <= eventWindow_r;
                xx = Timestamps_Intan(ii);
                yy = Waveforms_Intan(ii);
                if isempty(xx), xx=nan;yy=nan;end
                ts_h = plot(ax, xx, yy, 'k-', 'displayname', ['channel ' num2str(channelNo)]);
                ax.UserData = ts_h;
                title(ax, ['channel ', num2str(channelNo)])
            end
            if ~isempty(eventNos)
                xlim(ax, [eventTimes(1)-0.020, eventTimes(1)+0.020])
            end
            
            reversePlotOrder(ax);
            if ~isfield(obj.UserData, 'SpikeSorterMap') || numel(obj.UserData.SpikeSorterMap) < channelNo || isempty(obj.UserData.SpikeSorterMap(channelNo).units_onch)
                obj.getUnitsOnChannel(channelNo, [], obj.iv.SpikeStudioAlerts);
            end
            C = linspecer(numel(obj.UserData.SpikeSorterMap(channelNo).units_onch));
            thisunit = [obj.UserData.SpikeSorterMap(channelNo).units_onch] == unitNo;
            Color = [C(thisunit, :), 0.4];
            if ~recyclingMode
                activeUnit = 1;
                activeEvent = 1;
%                 set(ax, 'UserData', {{eventTimes}, eventNos, activeEvent, activeUnit, unitNo, ts_h})
                plotData = {};
                plotData.eventTimes = {eventTimes};
                plotData.eventNos = {eventNos};
                plotData.activeEvent = activeEvent;
                plotData.activeUnit = activeUnit;
                plotData.unitNos = unitNo;
                plotData.ts_h = ts_h;
                ax.UserData = plotData;
                unique_unit = true;
                unit_ix = 1;
                unique_eventNos = eventNos;
            else
                % we need to check if the unit was already plotted before.
                % if so we need to update its stuff
                plotData = ax.UserData;

                % check for existing unit
                if ismember(unitNo, plotData.unitNos)
                    redoNums = true;
                    % this unit is already plotted so just want to revise
                    % existing data in the plot
                    unit_ix = find(ismember(unitNo, plotData.unitNos));
                    % for plotting
                    all_eventTimes = sort(unique([eventTimes,plotData.eventTimes{unit_ix}]));
                    ix = ~ismember(eventTimes,plotData.eventTimes{unit_ix});
                    unique_eventTimes = eventTimes(ix);
                    
                    all_eventNos = 1:numel(all_eventTimes);%sort([eventNos(ix),plotData.eventNos{unit_ix}]);
                    unique_eventNos = find(ismember(all_eventTimes, unique_eventTimes));
                    % update
                    plotData.eventTimes{unit_ix} = all_eventTimes;%unique([plotData.eventTimes{unit_ix}, eventTimes]);
                    plotData.eventNos{unit_ix} = all_eventNos;
                    unique_unit = false;
                    if isempty(unique_eventTimes) % we already plotted everything...
                        plotData.activeUnit = unit_ix;    
                        first_replotted_event = find(min(eventTimes) == all_eventTimes);
                        plotData.activeEvent = first_replotted_event;
                        ax.UserData = plotData;
                        return
                    end
                    eventTimes_l = eventTimes_l(ix);
                    plotData.activeEvent = unique_eventNos(1);
                else
                    redoNums = false;
                    unit_ix = numel(plotData.eventTimes) + 1;
                    plotData.eventTimes{unit_ix} = eventTimes;
                    plotData.eventNos{unit_ix} = eventNos;
                    unique_unit = true;
                    unique_eventNos = eventNos;
                    plotData.activeEvent = 1;
                end
                plotData.activeUnit = unit_ix;                
                plotData.unitNos = unique([plotData.unitNos, unitNo]);
                ax.UserData = plotData;
            end
            plot(ax, eventTimes, zeros(size(eventTimes)), 'o', 'color', Color, 'handlevisibility', 'off')
            if unique_unit
                plot(ax, eventTimes(1), 0, 'o', 'color', Color, 'displayname', ['unit #' num2str(unitNo)])
            end
            if recyclingMode && redoNums
                delete(plotData.h_unittext{unit_ix});
            end
            for ievent = 1:numel(eventNos)  
                if ismember(eventNos(ievent), unique_eventNos)
                    if ievent == 1
                        rectangle(ax,'position', [eventTimes_l(eventNos(ievent) == unique_eventNos), -100, 0.002,200], 'facecolor', Color)
                    else
                        rectangle(ax,'position', [eventTimes_l(eventNos(ievent) == unique_eventNos), -100, 0.002,200], 'facecolor', Color)%, 'Color', 'y', 'FaceAlpha', 0.7)
                    end
                end                    
%                 if unique_unit
                plotData.h_unittext{unit_ix}(ievent) = text(ax, eventTimes(ievent) - 0.001, 85, num2str(eventNos(ievent)), 'color', 'k', 'fontsize', 15, 'linestyle', 'none');
%                 else
%                     plotData.h_unittext{unit_ix}(ievent).Text = num2str(eventNos(ievent));
%                 end
            end
            reversePlotOrder(ax);
            ax.UserData = plotData;
        end
        function prevEventPushedFcn(obj,ax)
            % get the current event and increment
            %              {alleventTimes, eventNos, activeevent, activeunit}
            uid = ax.UserData;
            activeUnit = uid.activeUnit;
            nexteventix = uid.activeEvent - 1;
            if nexteventix == 0, nexteventix = numel(uid.eventNos{activeUnit});end
            nexteventtime = uid.eventTimes{activeUnit}(nexteventix);
            uid.activeEvent = nexteventix;
            xlim(ax, [nexteventtime-0.020, nexteventtime+0.020])
            ax.UserData = uid;
        end
        function nextEventPushedFcn(obj, ax)
            % get the current event and increment
            %              {alleventTimes, eventNos, activeevent, activeunit}
            uid = ax.UserData;
            activeUnit = uid.activeUnit;
            nexteventix = uid.activeEvent + 1;
            if nexteventix > numel(uid.eventTimes{activeUnit}), nexteventix = 1;end
            nexteventtime = uid.eventTimes{activeUnit}(nexteventix);
            uid.activeEvent = nexteventix;
            xlim(ax, [nexteventtime-0.020, nexteventtime+0.020])
            ax.UserData = uid;
        end
        function toggleUnitFcn(obj, ax)
            % get the current event and increment
            %              {alleventTimes, eventNos, activeevent, activeunit}
            uid = ax.UserData;
            activeUnit = uid.activeUnit;%uid{4};
            activeEvent = uid.activeEvent;
            % find next unit with any events...
            ii = activeUnit+1;
            if ii > numel(uid.unitNos)
                ii = 1;
            end
            timeout = 10;
            while isempty(uid.eventNos{ii}) || timeout == 0
                if ii+1 > numel(uid.unitNos)
                    ii = 1;
                else
                    ii = ii+1;
                end
                timeout = timeout - 1;
            end
            if isempty(uid.eventNos{activeUnit})
                curr_t = 0;
            else
                curr_t = uid.eventTimes{activeUnit}(activeEvent);
            end
            % new unit
            activeUnit = ii;
            uid.activeUnit = activeUnit;
            uid.activeEvent = find(uid.eventTimes{activeUnit}<=curr_t,1,'last')-1;
            if isempty(uid.activeEvent)
                uid.activeEvent = numel(uid.eventTimes{activeUnit})-1;
            end
            tl = strsplit(ax.Title.String, ' | active unit: #');
            ax.Title.String = strjoin([tl(1), '| active unit: #', num2str(uid.unitNos(activeUnit))]);
            ax.UserData = uid;
            obj.nextEventPushedFcn(ax)
        end
        function goToNextEvent(obj, ax, Increment)
            % get the current event go to the next one, regardless of what
            % unit it's in...
            %
            uid = ax.UserData;
            activeUnit = uid.activeUnit;%uid{4};
            activeEvent = uid.activeEvent;
            % find the current timepoint center and find nearest event in
            % this new unit
            curr_t = uid.eventTimes{activeUnit}(activeEvent);
            % we now need to see where the next event is...
            allTimes = [uid.eventTimes{:}];
            next_ix = find(allTimes == curr_t, 1, 'first')+Increment;
            if next_ix > numel(allTimes), next_ix = 1;elseif next_ix <= 0, next_ix = numel(allTimes);end
            % which unit does it belong to?
            eventUnitIdx = cell2mat(cellfun(@(x,ii) ii.*ones(size(x)), uid.eventTimes, num2cell(1:numel(uid.eventTimes)), 'UniformOutput',false));
            uid.activeUnit = eventUnitIdx(next_ix);
            uid.activeEvent = find(uid.eventTimes{uid.activeUnit} == allTimes(next_ix));
            xlim(ax, [allTimes(next_ix)-0.020, allTimes(next_ix)+0.020])
            ax.UserData = uid;
        end
        function goToEvent(obj, ax, EventNo)
            % get the current event go to the next one, regardless of what
            % unit it's in...
            %
            uid = ax.UserData;
            if EventNo > numel(uid.eventTimes{uid.activeUnit}) || EventNo < 1
                obj.alert('*[1,0,0]', '>>SpikeStudio: Noooope. This unit doesn''t have that many events!')
                return
            end
            uid.activeEvent = EventNo;
            xlim(ax, [uid.eventTimes{uid.activeUnit}(uid.activeEvent)-0.020, uid.eventTimes{uid.activeUnit}(uid.activeEvent)+0.020])
            ax.UserData = uid;
        end
        function xStep(obj, ax, stepSize)
            % move the plot xaxes by fixed amount
            %   negative is left, positive is right
            xx = ax.XLim;
            xlim(ax, [xx(1)+stepSize, xx(2)+stepSize])
        end
        function plotWaveforms(obj,ax, unitNo, ch_idx,n_waves2plot) %xx, V, unitNo, n_waves2plot)
            if isempty(ax), [~, ax] = makeStandardFigure();end
            if nargin< 4 || isempty(ch_idx), ch_idx = 1; end
            try
                xx = obj.SpikeSorterData(unitNo).Unit(ch_idx).WaveformTimestamps;
            catch
                try
                    if ~isfield(obj.iv, 'waveformspath_')
                        obj.alert('info', '>> SpikeStudio: select path with waveforms .mat files from SpikeInterface')
                        obj.iv.waveformspath_ = uigetdir(pwd, 'Select waveforms folder');
                    end
                    % open the file with the waveform data
                    retdir = pwd;
                    cd(obj.iv.waveformspath_)
                    wavefile = load(['Unit_' num2str(unitNo) '_scipy.mat']);
                    wavestructname = fieldnames(wavefile);
                    wavefile = eval(['wavefile.' wavestructname{1}]);
                    obj.SpikeSorterData(unitNo).Unit(ch_idx).Channel = wavefile.Channel;
                    obj.SpikeSorterData(unitNo).Unit(ch_idx).Unit = wavefile.Unit;
                    obj.SpikeSorterData(unitNo).Unit(ch_idx).Sample = wavefile.Sample;
                    noisewaveidx = isnan(obj.SpikeSorterData(unitNo).Unit.Unit);
                    if noisewaveidx(end), noisewaveidx(end) = false;end
                    spikewaveidx = ~isnan(obj.SpikeSorterData(unitNo).Unit.Unit);
                    obj.SpikeSorterData(unitNo).Unit(ch_idx).Waveforms = wavefile.Waveform(spikewaveidx, :);
                    obj.SpikeSorterData(unitNo).Unit(ch_idx).NoiseWaveforms = wavefile.Waveform(noisewaveidx, :);
                    if size(wavefile.timestamps, 1) > 1 || size(wavefile.timestamps, 2) ~= size(obj.SpikeSorterData(unitNo).Unit(ch_idx).Waveforms, 2)
                        obj.alert('achtung', '>> SpikeStudio: WARNING: @OMKAR we need to get the actual waveform times from Spike interface')
                        obj.SpikeSorterData(unitNo).Unit(ch_idx).WaveformTimestamps = linspace(-1000*size(obj.SpikeSorterData(unitNo).Unit(ch_idx).Waveforms, 2)/2/30000, 1000*size(obj.SpikeSorterData(unitNo).Unit(ch_idx).Waveforms, 2)/2/30000, size(obj.SpikeSorterData(unitNo).Unit(ch_idx).Waveforms, 2));
                    else
                        obj.SpikeSorterData(unitNo).Unit(ch_idx).WaveformTimestamps = wavefile.timestamps;
                    end
                    xx = obj.SpikeSorterData(unitNo).Unit(ch_idx).WaveformTimestamps;
                    cd(retdir)
                catch
                    obj.alert('achtung', ['>> SpikeStudio: Uh oh--unit #' num2str(unitNo) ' ch idx#' num2str(ch_idx) ' didn''t plot correctly...'])
                end
            end
            V = obj.SpikeSorterData(unitNo).Unit(ch_idx).Waveforms;
            try N = obj.SpikeSorterData(unitNo).Unit(ch_idx).NoiseWaveforms; catch obj.alert('achtung', ['>> SpikeStudio: Unable to plot noise...']),end
            if isempty(V)
                title(ax, ['unit ', num2str(unitNo), ' n=0'])
                return
            end
            if nargin < 4
                n_waves2plot = 200*(size(V,1)>=200) + size(V,1)*(size(V,1)<=200);
            end
            if n_waves2plot > size(V,1)
                n_waves2plot = 200*(size(V,1)>=200) + size(V,1)*(size(V,1)<=200);
            end
            obj.alert('info', ['>> SpikeStudio: @ unit ' num2str(unitNo) ' | plotting ' num2str(n_waves2plot) ' randomly selected waveforms'])
            shuff_idx = randperm(size(V, 1));
            waves2plot = shuff_idx(1:n_waves2plot);%floor(1:shuff_idx*0.005:size(V));else,waves2plot=1:size(V,1);
            
            try plot(ax, xx, N(:,:), 'k'),end
            plot(ax, xx, V(waves2plot,:), 'r')
            ll = obj.SpikeSorterData(unitNo).Unit(1).WaveformTimestamps >= -0.5 & obj.SpikeSorterData(unitNo).Unit(1).WaveformTimestamps <= 0.5;
            ylim(ax, [min(min(V(waves2plot,ll))), max(max(V(waves2plot,ll)))])
            title(ax, ['unit ', num2str(unitNo), ' n=' num2str(size(V,1))])
            ylabel(ax, 'uV')
            xlabel(ax, 'time (ms)')
        end
        function plotMeanWaveform(obj,ax, unitNo, ch_idx,C,Title)
            if nargin < 6, Title='';else, title(ax, Title);end
            if isempty(ax), [~, ax] = makeStandardFigure;title(ax, ['Unit #' num2str(unitNo)]);end
            try
                xx = obj.SpikeSorterData(unitNo).Unit(ch_idx).WaveformTimestamps;
            catch
                try
                    if ~isfield(obj.iv, 'waveformspath_')
                        obj.alert('info', '>> SpikeStudio: select path with waveforms .mat files from SpikeInterface')
                        obj.iv.waveformspath_ = uigetdir(pwd, 'Select waveforms folder');
                    end
                    % open the file with the waveform data
                    retdir = pwd;
                    cd(obj.iv.waveformspath_)
                    wavefile = load(['Unit_' num2str(unitNo) '_scipy.mat']);
                    wavestructname = fieldnames(wavefile);
                    wavefile = eval(['wavefile.' wavestructname{1}]);
                    obj.SpikeSorterData(unitNo).Unit(ch_idx).Channel = wavefile.Channel;
                    obj.SpikeSorterData(unitNo).Unit(ch_idx).Unit = wavefile.Unit;
                    obj.SpikeSorterData(unitNo).Unit(ch_idx).Sample = wavefile.Sample;
                    noisewaveidx = isnan(obj.SpikeSorterData(unitNo).Unit.Unit);
                    if noisewaveidx(end), noisewaveidx(end) = false;end
                    spikewaveidx = ~isnan(obj.SpikeSorterData(unitNo).Unit.Unit);
                    obj.SpikeSorterData(unitNo).Unit(ch_idx).Waveforms = wavefile.Waveform(spikewaveidx, :);
                    obj.SpikeSorterData(unitNo).Unit(ch_idx).NoiseWaveforms = wavefile.Waveform(noisewaveidx, :);
                    if size(wavefile.timestamps, 1) > 1 || size(wavefile.timestamps, 2) ~= size(obj.SpikeSorterData(unitNo).Unit(ch_idx).Waveforms, 2)
                        obj.alert('achtung', '>> SpikeStudio: WARNING: @OMKAR we need to get the actual waveform times from Spike interface')
                        obj.SpikeSorterData(unitNo).Unit(ch_idx).WaveformTimestamps = linspace(-1000*size(obj.SpikeSorterData(unitNo).Unit(ch_idx).Waveforms, 2)/2/30000, 1000*size(obj.SpikeSorterData(unitNo).Unit(ch_idx).Waveforms, 2)/2/30000, size(obj.SpikeSorterData(unitNo).Unit(ch_idx).Waveforms, 2));
                    else
                        obj.SpikeSorterData(unitNo).Unit(ch_idx).WaveformTimestamps = wavefile.timestamps;
                    end
                    xx = obj.SpikeSorterData(unitNo).Unit(ch_idx).WaveformTimestamps;
                    cd(retdir)
                catch
                    obj.alert('achtung', ['>> SpikeStudio: Uh oh--unit #' num2str(unitNo) ' ch idx#' num2str(ch_idx) ' didn''t plot correctly...'])
                    return
                end
            end
            try
                V = obj.SpikeSorterData(unitNo).Unit(ch_idx).NoiseWaveforms;
                if isempty(V), plot(ax,nan, nan, '-', 'Color',[0,0,0],'displayname', ['NO unit #', num2str(unitNo)]), return;end
                U = prctile(V, 95, 1);
                L = prctile(V, 5, 1);
                line(ax, xx, mean(V,1), 'Color', [0,0,0], 'displayname', ['unit #', num2str(unitNo)]);
                patch(ax, [xx, xx(end:-1:1)], [L, U(end:-1:1)], [0,0,0],...
                'FaceAlpha', 0.15, 'EdgeColor', 'none', 'handlevisibility', 'off');
            catch
                obj.alert('achtung', '>> SpikeStudio: Unable to plot noise!')
            end


            V = obj.SpikeSorterData(unitNo).Unit(ch_idx).Waveforms;
            if isempty(V), plot(ax,nan, nan, '-', 'Color',C,'displayname', ['NO unit #', num2str(unitNo)]), return;end
            U = prctile(V, 95, 1);
            L = prctile(V, 5, 1);
            line(ax, xx, mean(V,1), 'Color', C, 'displayname', ['unit #', num2str(unitNo)]);
            patch(ax, [xx, xx(end:-1:1)], [L, U(end:-1:1)], C,...
                'FaceAlpha', 0.15, 'EdgeColor', 'none', 'handlevisibility', 'off');
            legend(ax, 'hide')
            ylabel(ax, 'uV')
            xlabel(ax, 'time (ms)')
        end
    end

    methods (Static)
        function [f,ax, fx, ax_x, fa, ax_a] = compareISI(Spikes, C, unitNos)
            warning('the xcorr part of the fxn needs to be fixed and validated. is not working yet')
            %     
            %  This function gets ISI with different combos of units on same
            %  channel. it also gets the auto and cross-correlation plots
            % 
            spikes_ms = cellfun(@(x) 1000*sort(x), Spikes, 'UniformOutput',false);
            [f,ax] = makeStandardFigure;
            f.Units = 'Normalized';
            f.Position = [0.4,0.65, 0.3, 0.3];
            unitix = 1:numel(spikes_ms);
            Cmix = linspecer(10);

            [fa,ax_a] = makeStandardFigure(numel(spikes_ms), [1,numel(spikes_ms)]);
            fa.Units = 'Normalized';
            fa.Position = [0.1,0.3, 0.3, 0.15];

            unique_pairs = [nan,nan];
            autocorrelation = cell(numel(Spikes),2);
            crosscorrelation = {[], []};
            xcor_sample_size = [];
            xcor_CIl = {};
            xcor_CIu = {};
            for ii = 1:numel(spikes_ms)
                u = spikes_ms{ii};
                uname = unitNos(ii);
                other_unit_ix = find(~ismember(unitix, ii));
                ISI = u(2:end)-u(1:end-1);
                prettyHxg(ax, ISI, ['unit ' num2str(uname)], C(ii,:),[-1,0:0.1:20], [], 'count');
                % do autocorrelation
                [autocorrelation{ii,1},autocorrelation{ii,2}] = xcorr(u, 'biased'); %per chatgpt, biased option corrects for len of vector
                lags = autocorrelation{ii,2};
                correlation = autocorrelation{ii,1};
                stem(ax_a(ii), lags, correlation, 'color', C(ii,:));
                xlabel(ax_a(ii),'Lag');
                ylabel(ax_a(ii),'Auto-correlation');
                title(ax_a(ii),['unit #', num2str(uname)]);


                % add in the other units
                for oo = 1:numel(spikes_ms)-1
                    pair = [ii, other_unit_ix(oo)];
                    % Check if pair is unique
                    if ~any(all(sort(pair,2) == unique_pairs, 2))
                        unique_pairs = [unique_pairs; pair];
                        other_uname = unitNos(other_unit_ix(oo));
                        o_unit_spikes = spikes_ms{other_unit_ix(oo)};
                        spikes_combo = [u, o_unit_spikes];
                        ISI = spikes_combo(2:end)-spikes_combo(1:end-1);
                        prettyHxg(ax, ISI, ['units ' num2str(uname) ' & ' num2str(other_uname)], Cmix(ii+oo*2,:),[-1,0:0.1:20], [], 'count');

                        xcor_ix = size(unique_pairs,1)-1;
                        [crosscorrelation{xcor_ix,1},crosscorrelation{xcor_ix,2}] = xcorr(u, o_unit_spikes);
                        xcor_sample_size(xcor_ix) = min(length(u), length(o_unit_spikes));

                        % Compute the confidence interval using a t-test with alpha = 0.05
                        alpha = 0.05;
                        t_critical = tinv(1-alpha/2, xcor_sample_size(xcor_ix)-1);
                        conf_interval = t_critical/sqrt(xcor_sample_size(xcor_ix));

                        % Compute the upper and lower bounds of the confidence interval
                        xcor_CIu{xcor_ix} = crosscorrelation{xcor_ix,1} + conf_interval * ones(size(crosscorrelation{xcor_ix,1}));
                        xcor_CIl{xcor_ix} = crosscorrelation{xcor_ix,1} - conf_interval * ones(size(crosscorrelation{xcor_ix,1}));
                    end
                end
            end
            legend(ax, 'show')


            % now do the xcorr and autocorr...
            unique_pairs = unique_pairs(2:end, :);
            n = size(unique_pairs,1);
            [fx,ax_x] = makeStandardFigure(n, [1,n]);
            fx.Units = 'Normalized';
            fx.Position = [0.1,0.45, 0.3, 0.15];
            for ip = 1:size(unique_pairs,1)
                stem(ax_x(ip), lags, crosscorrelation{ip,1}, 'color', (C(unique_pairs(ip, 1),:) + C(unique_pairs(ip, 2),:))./max(max(C(unique_pairs(ip, 1),:) + C(unique_pairs(ip, 2),:))));
                plot(ax_x(ip), lags, xcor_CIu{ip},'k-')
                plot(ax_x(ip), lags, xcor_CIl{ip},'k-')
                xlabel(ax_x(ip),'Lag');
                ylabel(ax_x(ip),'Cross-correlation');
                title(ax_x(ip),['units ', mat2str(unique_pairs(ip,:))]);
                xlim(ax_x(ip), [-1, 1])
            end
        end

        function Hz = plotPETH(spikes_wrt_event, ax, C, dispName, s_b4, s_post,s_per_bin)
            % 
            % can also take firstspike_wrt_event to just plot the first event
            % this is gonna normalize to the timebase... that gives us the rate
            %     
            if nargin < 7, s_per_bin=0.1;end
            if s_b4 >0, s_b4=-1*s_b4;end
            bin_edges = s_b4:s_per_bin:s_post;
            if iscell(spikes_wrt_event), spikes_wrt_event = cell2mat(spikes_wrt_event');end
            [no_spikes_per_bin,~] = histcounts(spikes_wrt_event, bin_edges);
            Hz = no_spikes_per_bin ./ s_per_bin;
            plot(ax, bin_edges(1:end-1)+0.05, Hz,'linewidth', 2, 'Color', C, 'DisplayName',dispName)
            plot(ax, [0,0], [min(Hz),max(Hz)],'linewidth', 2, 'Color', 'k', 'HandleVisibility','off')
            legend(ax,'show')
            ylabel(ax, 'spikes/s')
            xlabel(ax, 'time (s)')
        end
        function peak_peak = negativeExcursionHistogram(ax, t, V, C, unitNo)
            %     
            %  We will grab the max negative and position excursion on either size
            %  of t = 0
            % 
            i_zero = find(t>=0,1,'first');
            i_l = find(t>=-0.5,1,'first');
            i_r = find(t>=0.8,1,'first');
            VV = V(:,i_l:i_r);
            maxes = max(VV,[],2);
            mins = min(VV,[],2);

            peak_peak = maxes-mins;

            prettyHxg(ax, mins, ['unit #' num2str(unitNo)], C-0.05, min(mins):5:max(maxes));
            legend(ax, 'show')

            yyaxis(ax,'right')
            ylabel(ax,'% of peaks')
            hold on
            
            CC = C + 0.05;
            CC(CC>1) = 1;

            h = prettyHxg(ax, maxes, 'peak', CC, min(mins):5:max(maxes));
            
            h.HandleVisibility = 'off';
            
            yyaxis(ax, 'left')
            ylabel(ax,'% of troughs')
            xlabel(ax,'uV')
        end
        function plotSpikeTimecourse(ax, peak_peak, st, C, u)
            scatter(ax, st, peak_peak, 50, C, 'filled', 'MarkerFaceAlpha', 0.5, 'DisplayName',['unit #' , num2str(u)])
            xlabel(ax,'time (s)')
            ylabel(ax,'peak-peak uV')
            legend(ax,'show')
        end

        function [ISI_ms,h] = getISI(spikes, Plot, ax, dispName, Color)
            if nargin <2, Plot = false; end
            spikes_ms = 1000*sort(spikes);
            if Plot && nargin < 3, [~,ax] = makeStandardFigure();end
            ISI_ms = spikes_ms(2:end) - spikes_ms(1:end-1);
            if Plot
                h = prettyHxg(ax, ISI_ms, [dispName, ' min=' num2str(min(ISI_ms)) 'ms'], Color, [-1,0:0.1:20], [], 'count');
                xlim(ax,[-1,20])
                legend(ax, 'show')
                yy = get(ax,'ylim');
                plot(ax,[0,0], yy, 'k-', 'HandleVisibility','off')
            end
        end
        function [binned_spikes, spikes_wrt_event, firstspike_wrt_event] = binupspikes(spikes, refevents,s_b4, s_post)
            binned_spikes = cell(numel(refevents),1);    
            spikes_wrt_event = cell(numel(refevents),1);
            firstspike_wrt_event = nan(numel(refevents),1);
            for i_ref = 1:numel(refevents)
                spikes_before_event = spikes < refevents(i_ref) + s_post;
                spikes_after_event = spikes > refevents(i_ref)-s_b4;
        	    binned_spikes{i_ref} = spikes(spikes_before_event & spikes_after_event);
                spikes_wrt_event{i_ref} = binned_spikes{i_ref} - refevents(i_ref);
                
                if ~isempty(spikes_wrt_event{i_ref})
                    % get the first spike wrt the event:
                    firstspike_idx = find(spikes_wrt_event{i_ref}>0,1,'first');
                    if ~isempty(firstspike_idx)
                        firstspike_wrt_event(i_ref) = spikes_wrt_event{i_ref}(firstspike_idx);
                    end

                    % assert conditions for binning
                    assert(binned_spikes{i_ref}(1) > refevents(i_ref)-s_b4 && binned_spikes{i_ref}(end) < refevents(i_ref)+s_post);
                    assert(spikes_wrt_event{i_ref}(1) > 0-s_b4 && spikes_wrt_event{i_ref}(end) < s_post);
                end
            end
        end
        %%
        function ax = plotraster(spikes_wrt_event, first_spike_wrt_event, varargin)
            p = inputParser;
            addParameter(p, 'ax', [], @isaxes); 
        	addParameter(p, 'markerSize', 10, @isnumeric); 
        	addParameter(p, 'dispName', 'data', @ischar);
        	addParameter(p, 'Color', [0,0,0], @isnumeric);
            addParameter(p, 'referenceEventName', 'Reference Event', @ischar);
            addParameter(p, 'append', false, @islogical);
            addParameter(p, 'plotFirst', true, @islogical);
        	parse(p, varargin{:});
            ax 		= p.Results.ax;
        	markerSize 		= p.Results.markerSize;
        	dispName 		= p.Results.dispName;
            Color 	        = p.Results.Color;
            ReferenceEventName  = p.Results.referenceEventName;
            append          = p.Results.append;
            plotFirst       = p.Results.plotFirst;
            if isempty(ax), [~, ax] = makeStandardFigure();end
            % 
        	% 	Plot raster of all licks with first licks overlaid
        	% 
            numRefEvents = numel(first_spike_wrt_event);
            if ~append
        	    plot(ax, [0,0], [1,numRefEvents],'r-', 'DisplayName', ReferenceEventName)
        	    set(ax,  'YDir','reverse')
                ylim(ax, [1, numRefEvents])
            end
            if plotFirst % plot the first event after the cue
                scatter(ax, first_spike_wrt_event, 1:numRefEvents, markerSize+150, Color, 'filled', 'DisplayName', dispName, 'MarkerFaceAlpha',0.3, 'markeredgecolor', 'k');
            end
        	
        % 	for iexc = obj.iv.exclusions_struct.Excluded_Trials
        % 	    spikes_wrt_event{iexc} = [];
        %     end
        	for itrial = 1:numRefEvents
        		plotpnts = spikes_wrt_event{itrial};
        		if ~isempty(plotpnts)
                    if ~plotFirst && itrial==1
                        scatter(ax, plotpnts, itrial.*ones(numel(plotpnts), 1), markerSize, Color, 'filled','DisplayName', dispName, 'MarkerFaceAlpha',0.7)				
                    else
            			scatter(ax, plotpnts, itrial.*ones(numel(plotpnts), 1), markerSize, Color, 'filled','handlevisibility', 'off', 'MarkerFaceAlpha',0.7)				
                    end
        		end
        	end	
        	yy = get(ax, 'ylim');
        	ylim(ax, yy);
            legend(ax,'show')
            ylabel(ax,[ReferenceEventName, ' #'])
            xlabel(ax,['Time (s) wrt ' ReferenceEventName])
        end
        function [overlap_1,overlap_2] = tolerancePlot(tol, Group1Struct, Group1Times, Group1Name, Group2Struct, Group2Times, Group2Name)
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
            Group1Times = sort(Group1Times);
            Group2Times = sort(Group2Times);
            overlap_1 = Group1Times(ismembertol(Group1Times,Group2Times, tol));
            overlap_2 = Group2Times(ismembertol(Group2Times,Group1Times, tol));
            if numel(overlap_1) ~= numel(overlap_2), warning([Group1Name ' #:' num2str(numel(overlap_1)) ' | ' Group2Name ' #:' num2str(numel(overlap_2))]); end
            numfound1 = numel(overlap_1);
            numfound2 = numel(overlap_2);

            [~,ax] = makeStandardFigure(5, [1,5]);
            if ~isempty(overlap_1)
                for iter = 1:(5*(numfound1>=5) + numfound1*(numfound1<5))
                    try
                        plot(ax(iter), Group1Struct.WaveformTimestamps, Group1Struct.Waveforms(ismember(Group1Struct.Timestamps,overlap_1(iter)),:), 'k', 'displayname', [Group1Name ': ' num2str(overlap_1(iter))])
                    catch
                    end
                    try
                        plot(ax(iter), Group2Struct.WaveformTimestamps, Group2Struct.Waveforms(ismember(Group2Struct.Timestamps,overlap_2(iter)),:), 'r', 'displayname', [Group2Name ': ' num2str(overlap_2(iter))])
                    catch
                    end
                    legend(ax(iter),'show')

                end
                suptitle(['tolerance = ' num2str(tol)])
            else
                suptitle(['No overlap b/t ' Group1Name ' & ' Group2Name ' for tolerance = ' num2str(tol)])
            end
            % disp the stats:    
            
            disp(['Tolerance: ' num2str(tol)])
            disp(['Total found by ' Group1Name ':' num2str(numel(Group1Times))])
            disp(['Total found by ' Group2Name ':' num2str(numel(Group2Times))])
            
            disp(['% ' Group1Name ' found by ' Group2Name ': ' num2str(numfound1) '/' num2str(numel(Group1Times)) ' = ' num2str(numfound1/numel(Group1Times))])
            disp(['% ' Group2Name ' found by ' Group1Name ': ' num2str(numfound2) '/' num2str(numel(Group2Times)) ' = ' num2str(numfound2/numel(Group2Times))])
        end
    end
end
