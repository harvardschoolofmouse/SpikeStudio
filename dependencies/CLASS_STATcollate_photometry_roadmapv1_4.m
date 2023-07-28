classdef CLASS_STATcollate_photometry_roadmapv1_4 < handle
	% 
	% 	Made for CLASS_photometry_roadmapv1_4.m to combine stat analyses across sessions into a plottable thing.
	% 
	% 	Created 	11/6/19	ahamilos
	% 	Modified 	11/6/19	VERSION CODE: ['CLASS_STATcollate_photometry_roadmapv1_4 v1.0 Modified 11-6-19 13:05 | obj created: ' datestr(now)];
	% 
	% 	VERSION CODE HISTORY
	% 
	properties
		iv
		collatedResults
		analysis
	end

	%-------------------------------------------------------
	%		Methods: Initialization
	%-------------------------------------------------------
	methods
		function obj = CLASS_STATcollate_photometry_roadmapv1_4(collateKey,n)
			% 
			% 	collateKey:			specifies the kind of analysis to capture in each object
			% 						ht 		-- computes the threshold crossing regression for all files in HOST folder
			% 						-cdf 	-- computes the cdf for all files in HOST
			% 						vt		-- computes the threshold crossing regression for all files in HOST folder
			% 						rim		-- runs RimSummary on a Mary-type statObj -- caution using on AH machines! Only works on Mary Machines
			% 									NB: renaming CLASS_MARY_STATcollate_photometry_roadmapv1_4 for MARY use until ready to combine the files.
			% 									Get version updates from here. Last update on this 12/19/19 17:05
			% 						-PCAdecoding 	-- runs the pca methods AND the decoding models
			% 						-htStiff -- ht with stiff threshold and decoding model on ht (gfit only, no tdt channel)
			% 						-ht_1_Stiff -- ht with stiff threshold and decoding model on ht (one threshold and tdt channel)
			% 						-DecodingPaperFinal -- has all the final versions of the decoding model -- 10s baseline, stiff threshs on tdt, PC methods... but too hard to run
			% 						-	1ht_stiff_ea
			% 						-	multiht_stiff_ea
			% 						-	PC1_3_1httdtstiff
			% 						=	1htPCAstiff_1tdtstiff
			% 						=	multihtPCAstiff_multitdtstiff
			% 						-	multihtPCAstiff_multiPCAtdtstiff
			% 						-PCAcollateSummary --  runs obj.plotPCA, then stores the PCs and the summary
			% 
			% 						baselineANOVAidx -- gets items for selectivity index plots
			% 						baselineANOVAwithLick -- does the 3 way ANOVA datasets
			% 						divergenceIndex -- uses new dF/F baseline bootstrap method
			% 						-singleTrialFigures 	-- bins gfit signal by single trials and then saves the figure with 200ms smoothing to check for outliers
			% 						-singleTrialOutliers -- redoes exclusions on all the datasets, then it generates a composite binned stat obj of your choosing.
			% 						-movectrlcustom -- does the special binning for the LTA2l figure and plots and saves all the figures
			% 						-movectrltimes -- does the times binning for the LTA2l figure and plots 7 bins and saves all the figures, both 0ms and 30ms EMG smooth
			% 						-movectrlall -- does the all trials binning! NOW 0ms (old:30ms smooth EMG)
			% 						-movectrltrials -- 10 trials per bin to look at more evenly NOW 0ms (old: 30 ms smooth EMG)
			% 						-tof -- calculates the vigor metrics and saves plots (in dev now)
			% 
			% 						-plotPartition -- partitions session by nTrials and then plots Hxg and CLTA for 7 bins
			% 							n = #partitions
			% 						-nTrialsWithFLick -- simply pulls out the # of trials with a flick and all flick times
			% 							this will help us do partitioning on the fly
			%  
			%						-CLTAconditionNm1notRew -- for use with dlight and grabda data
			% 							finds all trials preceded by reward, then does binning based on no rew or rew condition
			% 							then, saves the baselines of each bin in the rew and not rew conditions
			% 							then plots and saves the CLTA plot
			% 
			% 						-prepXconditioning -- use this to get trialIDs where the ongoing movement during the trial is reduced, conditioned in some way (e.g., excessMoveRatio or meanExcessMoveAmplitude)
			% 							developed 11/5/2020 for dlight sessions based on s1f_DLS/X_24 and s3f_DLS/X_20
			% 
			% 						%%%%DEPRECATED: not implemented-rawF -- does paired and triplet conditioning, plots CTAs and collates across sessions because why not? 11/18/2020
			% 
			% 						-extract_trial_CSV -- we will automagically export out single trial interval, baseline interval, and LOI interval across sessionss to a compiled folder
			%						-stepvramp_julia -- allows us to import results from Julia CSV saving. 
			%								n is the model package function, e.g, hierarchy_v1
			%						-loivsflick -- regress the first lick time vs loi
			%						-getOperantTrials -- excludes all trials not in operant range; n=pavlovian time s
			%						-PCAbehavior -- runs PCA on behavioral trials
			%
			%		2023
			%						-sloshingModels -- n will be a cell with {divs, 'LTA' or 'LOTA', 'del' or 'abs', 'mean' or 'median' or 'rails'}	
			% 							REDO: 6/2/23:
			% 								obj = CLASS_STATcollate_photometry_roadmapv1_4('sloshingModels',{20, 'LTA', 'del', 'mean'})
			% 								obj = CLASS_STATcollate_photometry_roadmapv1_4('sloshingModels',{10, 'LOTA', 'abs', 'mean'})
			% 						-sloshingModels_timeslice -- runs the appropriate timeeslice model, e.g., [~,~,~,~,mdls, ModelDeets, Name] = obj.runNestedModel('LOTA-&-EMG-&-tdt',10,'del','mean', true);
			% 							you have to specify the predictors...
			% 							
			%							obj = CLASS_STATcollate_photometry_roadmapv1_4('sloshingModels_timeslice',{10, 'LOTA-&-EMG-&-X-&-tdt', 'abs', 'mean'})
			%							obj = CLASS_STATcollate_photometry_roadmapv1_4('sloshingModels_timeslice',{10, 'LOTA-&-EMG-&-X-&-tdt', 'del', 'mean'})
			%							obj = CLASS_STATcollate_photometry_roadmapv1_4('sloshingModels_timeslice',{20, 'LTA-&-EMG-&-X-&-tdt', 'abs', 'mean'})
			%							obj = CLASS_STATcollate_photometry_roadmapv1_4('sloshingModels_timeslice',{20, 'LTA-&-EMG-&-X-&-tdt', 'del', 'mean'})
			% 							
			%							if n has a 5th argument, then we can condition trials, e.g., early or rew:
			% 								if LTA, early means the current trial was early
			% 								if LOTA, early means the NEXT trial will be early
			% 
			%						-sloshingModels-sysclub - the same as above, but you specify which version of the model you want
			%							obj = CLASS_STATcollate_photometry_roadmapv1_4('sloshingModels',{20, 'LTA-&-tdt', 'del', 'mean'})
			%							obj = CLASS_STATcollate_photometry_roadmapv1_4('sloshingModels',{20, 'LTA-&-tdt', 'abs', 'mean'})
			%							obj = CLASS_STATcollate_photometry_roadmapv1_4('sloshingModels',{10, 'LOTA-&-tdt', 'abs', 'mean'})
			%						-sloshingLOI -- will make the model with the LOI predictors, uses LTA and del or abs, mean or median
			% 								{'del' or 'abs' or 'logabs', 'mean' or 'median'}	
			%							obj = CLASS_STATcollate_photometry_roadmapv1_4('sloshingLOI',{'del', 'mean'})	

			%
			%
			% 						-grabMoveControls, n={gfitcell, binningMode, nbins, pad}
			% 								% obj = CLASS_STATcollate_photometry_roadmapv1_4('grabMoveControls', {{'multibaseline', 10}, 'times-lampoff', 68, 30000})
			% 								- NB requires that a statobj already be in the folder.
			% 								- the idea here is that I want to grab the associated move controls for an obj in the folder.
			% 									I then want to do the binning and save an obj that has the binned data. This is a little tricky
			% 								ex: obj = CLASS_photometry_roadmapv1_4('v3x','times-lampoff',68,{'multibaseline',10},30000,[],[],'off')
			%
			%						-sloshingStimulation
			%							% extracrs all the flick times on stim and unstim trials as well as subsequent 2 trials to be able to compare composite distributions
			% 
			obj.iv.runID = randi(10000);
			obj.iv.versionCode = ['CLASS_STATcollate_photometry_roadmapv1_4 v1.0 Modified 11-5-20 15:45 | obj created: ' datestr(now)];

			if nargin < 1 || isempty(collateKey)
				obj.iv.collateKey = 'cdf';
			else
				obj.iv.collateKey = collateKey;
			end
			if nargin < 2
				n = 2;
			end
			obj.iv.n = n;

			obj.getDataset;
			obj.setAnimalID;
			obj.getMouseNames;
	    	% 
	    	% 	Save the collated results
	    	% 
	    	obj.save;
	    	disp('Collation of analyses is complete! The shell object is saved to Host Folder.')
			alert = ['Photometry Collation Analysis Obj Complete: ' num2str(obj.iv.runID)]; 
			reportErrors(obj);
		    mailAlert(alert);
		    if strcmpi(obj.iv.collateKey,'PCAdecoding')
		    	cd('..');
	    	elseif strcmpi(obj.iv.collateKey,'singleTrialOutliers')
	    		alert = ['ACTION NEEDED--@singleTrialOutliers Need to select folders now. Photometry Collation Analysis Obj In Prog...: ' num2str(obj.iv.runID)]; 
	    		mailAlert(alert);
	    		disp('	** We are in the process of reExcluding based on outliers, now creating the binned statObj... Select the host folder!')
	    		obj = CLASS_photometry_roadmapv1_4('v3x', 'times', 34, {'box', 200000}, 30000, [], [], 'off');
    		end
		end
		function getDataset(obj, correctionsMode, addDataMode)
			% 
			% 	To correct an existing dataset:
			% 		correctionsMode = true
			% 		Use the original host folder so it can read the original folder names that are missing data
			% 	
			% 	To add data to an existing dataset:
			% 		addDataMode = true (will overide correctionsMode)
			% 		Use a new host with folders for only the data you want to add.
			% 		Remember to move over the new saved file
			% 
			if nargin <3
				addDataMode = false;
			end
			if nargin <2
				correctionsMode = false;
			end
			if ~correctionsMode && ~addDataMode
				if strcmpi(obj.iv.collateKey, 'rim')
					instructions = sprintf('Collate RIM Analyses across Session Object Initialization -- For use with MARY stat objs only as of 12/15/19 \n\n 1. Set Up HOSTObj folder > rimSummary > then folders within this for each day named MOUSENAME_DAY_STYLE (e.g., M1R_1_hyb500 or M1R_7_2_op0). Process Photometry StatObjs as usual and have ready in folders for collation. IS OKAY TO PUT FOLDERS FROM DIFFERENT MICE \n 2. Select the Host Folder For Collation \n 3. Each folder will be processed and CollatedAnalysisObj saved to the HOST folder for the Collation.')
				else
		    		instructions = sprintf('Collate Analyses across Session Object Initialization \n\n 1. Set Up HOSTObj folder > Signal > then folders within this for each day. Each folder is named MouseID_Signal_Day#. Process Photometry StatObjs as usual and have ready in folders for collation. IS OKAY TO PUT FOLDERS FROM DIFFERENT MICE AND SIGNALS DEPENDING ON ANALYSIS \n 2. Select the Host Folder For Collation \n 3. Each folder will be processed and CollatedAnalysisObj saved to the HOST folder for the Collation.')
	    		end
    		elseif correctionsMode
    			instructions = sprintf('FIXING ERRORS \n\n 1. After fixing problems with files, Go to the original HOSTObj folder > Signal  \n 2. Select the original Host Folder For Collation \n 3. Each folder will be processed and appended to CollatedAnalysisObj saved to the HOST folder for the Collation.')
			elseif addDataMode
				instructions = sprintf('ADDING DATA \n\n 1. Put HOSTObj day folders in a new addHOST folder. Only put new files to append here.  \n 2. Select the new addHost Folder For Addition \n 3. Each folder will be processed and appended to CollatedAnalysisObj saved to the addHOST folder for the Collation. \n\n -- ** REMEMBER TO MOVE ADDED AND APPENDED FILES TO MAIN HOST FOR STORAGE!')
    		end
    		hhh = msgbox(instructions);
	    	
	    	disp('Select the HOST Folder for Collation')
	    	disp('	NB: for PCA, outer HOST contains sessionHOST, PCAfigureHOST, and decodeFigureHOST**')
            hostFolder = uigetdir('', 'Select the HOST Folder for Collation');
            obj.iv.hostFolder = hostFolder;
            if ~strcmpi(obj.iv.collateKey,'baselineANOVAidx') || ~strcmpi(obj.iv.collateKey,'ht') || ~strcmpi(obj.iv.collateKey,'vt') || ~strcmpi(obj.iv.collateKey,'rim')
                cd(hostFolder)
            	filesax = dir;
            	dirFlagsax = [filesax.isdir];
            	Foldersax = filesax(dirFlagsax);
            	name = {Foldersax(3:end).name};
				folder = {Foldersax(3:end).folder};
            	
            	if strcmpi(obj.iv.collateKey, 'grabMoveControls') || strcmpi(obj.iv.collateKey, 'cdf') || strcmpi(obj.iv.collateKey, 'loivsflick') || strcmpi(obj.iv.collateKey, 'PCAbehavior')
            		obj.iv.suppressNsave.cdf = hostFolder;
        		elseif strcmpi(obj.iv.collateKey, 'extract_trial_CSV')
        			disp('	Select the folder to save collated CSVs for all sessions')
        			obj.iv.CSV_folder = uigetdir('', 'Select the folder to save collated CSVs');
        			% disp('	Select the folder to save BASELINE CSVs')
        			% obj.iv.baseline_folder = uigetdir('', 'Select the folder to save BASELINE CSVs');
        			% disp('	Select the folder to save LOI CSVs')
        			% obj.iv.loi_folder = uigetdir('', 'Select the folder to save LOI CSVs');
        			disp('	Select the figureHOST folder for Collation')
        			obj.iv.suppressNsave.figuresHOST = uigetdir('', 'Select the figureHOST Folder for Collation');
    			elseif strcmpi(obj.iv.collateKey, 'stepvramp_julia')
        			disp('	Select the folder where the collated CSVs are for all sessions')
        			obj.iv.CSV_folder = uigetdir('', 'Select the folder to save collated CSVs');
        			disp('	Select the figureHOST folder for Collation')
        			obj.iv.suppressNsave.figuresHOST = uigetdir('', 'Select the figureHOST Folder for Collation');
        			
        		elseif strcmpi(obj.iv.collateKey, 'prepXconditioning')
        			disp('	Select the companion Xhost folder for Collation')
        			obj.iv.hostXfolder = uigetdir('', 'Select the companion Xhost Folder for Collation');
        			disp('	Select the figureHOST folder for Collation')
        			obj.iv.suppressNsave.figuresHOST = uigetdir('', 'Select the figureHOST Folder for Collation');
        			disp('	Select the explore_X_EMG_conditioning folder for Collation (if saved files exist, will prioritize these)')
        			obj.iv.savedNewObjFolder = uigetdir('', 'Select the location for Explore X/DLS object (can reuse)');
        		elseif strcmpi(obj.iv.collateKey, 'sloshingStimulation') || strcmpi(obj.iv.collateKey, 'sloshingModels') || strcmpi(obj.iv.collateKey, 'sloshingModels_timeslice') || strcmpi(obj.iv.collateKey, 'sloshingModels-sysclub')||strcmpi(obj.iv.collateKey, 'sloshingLOI')|| strcmpi(obj.iv.collateKey,'rawF')|| strcmpi(obj.iv.collateKey,'CLTAconditionNm1notRew') || strcmpi(obj.iv.collateKey,'divergenceIndex') || strcmpi(obj.iv.collateKey, 'plotPartition') || strcmpi(obj.iv.collateKey, 'singleTrialFigures') || strcmpi(obj.iv.collateKey,'singleTrialOutliers') || strcmpi(obj.iv.collateKey,'movectrlcustom') || strcmpi(obj.iv.collateKey,'movectrltimes') || strcmpi(obj.iv.collateKey,'movectrlall') || strcmpi(obj.iv.collateKey,'movectrltrials') || strcmpi(obj.iv.collateKey,'tof') || strcmpi(obj.iv.collateKey, 'PCAcollateSummary')
        			cd ..
					disp(	'Select the figureHOST Folder for Collation')
					obj.iv.suppressNsave.singleTrialFigures = uigetdir('', 'Select the figureHOST Folder for Collation');
					obj.iv.suppressNsave.figuresHOST = obj.iv.suppressNsave.singleTrialFigures;
        		else
	            	if isempty(find(contains(name,'sessionHOST'),1))
						disp(	'Select the sessionHOST Folder for Collation')
						sessionHostFolder = uigetdir('', 'Select the HOST Folder for Collation');
	        		else
	        			sessionHostFolder = obj.correctPathOS([hostFolder '/' name{find(contains(name,'sessionHOST'))}]);
	        		end
	        		obj.iv.outerHostFolder = hostFolder;
	                outerHostFolder = obj.iv.outerHostFolder;
	        		obj.iv.hostFolder = sessionHostFolder;
	        		hostFolder = sessionHostFolder;
	        		obj.iv.sessionHostFolder = sessionHostFolder;
	        		
	        		if strcmpi(obj.iv.collateKey,'PCAdecoding')
						if isempty(find(contains(name,'PCAfigureHOST')))
							mkdir('PCAfigureHOST');
							PCAfigureHOSTfolder = obj.correctPathOS([outerHostFolder '/PCAfigureHOST']);
						else					
							PCAfigureHOSTfolder = obj.correctPathOS([outerHostFolder '/' name{find(contains(name,'PCAfigureHOST'))}]);
						end
						obj.iv.PCAfigureHOSTfolder = PCAfigureHOSTfolder;
						cd(PCAfigureHOSTfolder)
		            	filesax = dir;
		            	if size(filesax,1) < 8+2
			            	mkdir('PCAsummary')
			            	mkdir('PCAtestfit')
			            	mkdir('PCAwtVsLickTime')
			            	mkdir('PCAXfitAll')
			            	mkdir('PCAXfitSelected')
			            	mkdir('Xfitbinned')
			            	mkdir('PCAmeanSlope')
			            	mkdir('HOSTdecode')
			            	filesax = dir;   
		            	end         
		            	dirFlagsax = [filesax.isdir];
		            	Foldersax = filesax(dirFlagsax);
		            	name = {Foldersax(3:end).name};
						folder = {Foldersax(3:end).folder};
		            	obj.iv.suppressNsave.PCAsummary = [folder{find(contains(name,'PCAsummary'))} '/' name{find(contains(name,'PCAsummary'))}];
		            	obj.iv.suppressNsave.PCAtestfit = [folder{find(contains(name,'PCAtestfit'))} '/' name{find(contains(name,'PCAtestfit'))}];
		            	obj.iv.suppressNsave.PCAwtVsLickTime = [folder{find(contains(name,'PCAwtVsLickTime'))} '/' name{find(contains(name,'PCAwtVsLickTime'))}];
		            	obj.iv.suppressNsave.PCAXfitAll = [folder{find(contains(name,'PCAXfitAll'))} '/' name{find(contains(name,'PCAXfitAll'))}];
		            	obj.iv.suppressNsave.PCAXfitSelected = [folder{find(contains(name,'PCAXfitSelected'))} '/' name{find(contains(name,'PCAXfitSelected'))}];
		            	obj.iv.suppressNsave.Xfitbinned = [folder{find(contains(name,'Xfitbinned'))} '/' name{find(contains(name,'Xfitbinned'))}];
		            	obj.iv.suppressNsave.PCAmeanSlope = [folder{find(contains(name,'PCAmeanSlope'))} '/' name{find(contains(name,'PCAmeanSlope'))}];	

		                cd(outerHostFolder)
	                end

	            	filesax = dir;
	            	dirFlagsax = [filesax.isdir];
	            	Foldersax = filesax(dirFlagsax);
	            	name = {Foldersax(3:end).name};
					folder = {Foldersax(3:end).folder};
					if isempty(find(contains(name,'decodeFigureHOST')))
						mkdir('decodeFigureHOST');
						decodeFigureHOSTfolder = obj.correctPathOS([outerHostFolder '/decodeFigureHOST']);
					else					
						decodeFigureHOSTfolder = obj.correctPathOS([outerHostFolder '/' name{find(contains(name,'decodeFigureHOST'))}]);
					end
					obj.iv.decodeFigureHOSTfolder = decodeFigureHOSTfolder;
%                     obj.iv.suppressNsave.decodeFigureHOSTfolder = decodeFigureHOSTfolder;
					cd(decodeFigureHOSTfolder)
	            	filesax = dir;
	            	if strcmpi(obj.iv.collateKey,'PCAdecoding')
		            	if size(filesax,1) < 5+4
			            	mkdir('ht')
			            	mkdir('htPCA')
			            	mkdir('PC1_3')
			            	mkdir('PC1_3htPCA')
			            	mkdir('mislope')
			            	mkdir('htPCA-stiff')
			            	mkdir('PCA_ht_1_Stiff')
			            	filesax = dir;   
		            	end
	            	elseif strcmpi(obj.iv.collateKey,'DecodingPaperFinal') || strcmpi(obj.iv.collateKey,'1ht_stiff_ea') || strcmpi(obj.iv.collateKey,'multiht_stiff_ea') || strcmpi(obj.iv.collateKey,'PC1_3_1httdtstiff') || strcmpi(obj.iv.collateKey,'1htPCAstiff_1tdtstiff') || strcmpi(obj.iv.collateKey,'multihtPCAstiff_multitdtstiff') || strcmpi(obj.iv.collateKey,'multihtPCAstiff_multiPCAtdtstiff') 
	            		if size(filesax,1) < 6+2
			            	mkdir('1ht_stiff_ea')
			            	mkdir('multiht_stiff_ea')
			            	mkdir('PC1_3_1httdtstiff')
			            	mkdir('1htPCAstiff_1tdtstiff')
			            	mkdir('multihtPCAstiff_multitdtstiff')
			            	mkdir('multihtPCAstiff_multiPCAtdtstiff')
			            	filesax = dir;   
		            	end
	            	elseif strcmpi(obj.iv.collateKey,'htStiff') || strcmpi(obj.iv.collateKey,'ht_1_Stiff')
	            		dirFlagsax = [filesax.isdir];
		            	Foldersax = filesax(dirFlagsax);
		            	name = {Foldersax(3:end).name};
	            		if ~contains(name, 'ht-stiff')
			            	mkdir('ht-stiff')
			            	filesax = dir;   
			            	dirFlagsax = [filesax.isdir];
			            	Foldersax = filesax(dirFlagsax);
			            	name = {Foldersax(3:end).name};
		            	end
		            	folder = {Foldersax(3:end).folder};
	            	end
	            	
					% idx = strcmpi(name, 'ht');
                    
					if strcmpi(obj.iv.collateKey,'PCAdecoding')
                        filesax = dir;
                        dirFlagsax = [filesax.isdir];
                        Foldersax = filesax(dirFlagsax);
                        name = {Foldersax(3:end).name};
                        folder = {Foldersax(3:end).folder};
		            	obj.iv.suppressNsave.ht = [folder{strcmpi(name,'ht')} '/' name{strcmpi(name,'ht')}];
		            	obj.iv.suppressNsave.htPCA = [folder{strcmpi(name,'htPCA')} '/' name{strcmpi(name,'htPCA')}];
		            	obj.iv.suppressNsave.PC1_3 = [folder{strcmpi(name,'PC1_3')} '/' name{strcmpi(name,'PC1_3')}];
		            	obj.iv.suppressNsave.PC1_3htPCA = [folder{strcmpi(name,'PC1_3htPCA')} '/' name{strcmpi(name,'PC1_3htPCA')}];
		            	obj.iv.suppressNsave.mislope = [folder{strcmpi(name,'mislope')} '/' name{strcmpi(name,'mislope')}];
		            	obj.iv.suppressNsave.htPCA_stiff = [folder{strcmpi(name,'htPCA-stiff')} '/' name{strcmpi(name,'htPCA-stiff')}];
		            	obj.iv.suppressNsave.PCA_ht_1_Stiff  = [folder{strcmpi(name,'PCA_ht_1_Stiff')} '/' name{strcmpi(name,'PCA_ht_1_Stiff')}];
	            	elseif strcmpi(obj.iv.collateKey,'DecodingPaperFinal') || strcmpi(obj.iv.collateKey,'1ht_stiff_ea') || strcmpi(obj.iv.collateKey,'multiht_stiff_ea') || strcmpi(obj.iv.collateKey,'PC1_3_1httdtstiff') || strcmpi(obj.iv.collateKey,'1htPCAstiff_1tdtstiff') || strcmpi(obj.iv.collateKey,'multihtPCAstiff_multitdtstiff') || strcmpi(obj.iv.collateKey,'multihtPCAstiff_multiPCAtdtstiff') 
	            		filesax = dir;
                        dirFlagsax = [filesax.isdir];
                        Foldersax = filesax(dirFlagsax);
                        name = {Foldersax(3:end).name};
                        folder = {Foldersax(3:end).folder};
		            	obj.iv.suppressNsave.ht_stiff_ea = [folder{strcmpi(name,'1ht_stiff_ea')} '/' name{strcmpi(name,'1ht_stiff_ea')}];
		            	obj.iv.suppressNsave.multiht_stiff_ea = [folder{strcmpi(name,'multiht_stiff_ea')} '/' name{strcmpi(name,'multiht_stiff_ea')}];
		            	obj.iv.suppressNsave.PC1_3_1httdtstiff = [folder{strcmpi(name,'PC1_3_1httdtstiff')} '/' name{strcmpi(name,'PC1_3_1httdtstiff')}];
		            	obj.iv.suppressNsave.htPCAstiff_1tdtstiff = [folder{strcmpi(name,'1htPCAstiff_1tdtstiff')} '/' name{strcmpi(name,'1htPCAstiff_1tdtstiff')}];
		            	obj.iv.suppressNsave.multihtPCAstiff_multitdtstiff = [folder{strcmpi(name,'multihtPCAstiff_multitdtstiff')} '/' name{strcmpi(name,'multihtPCAstiff_multitdtstiff')}];
		            	obj.iv.suppressNsave.multihtPCAstiff_multiPCAtdtstiff = [folder{strcmpi(name,'multihtPCAstiff_multiPCAtdtstiff')} '/' name{strcmpi(name,'multihtPCAstiff_multiPCAtdtstiff')}];
	            	elseif strcmpi(obj.iv.collateKey,'htStiff') || strcmpi(obj.iv.collateKey,'ht_1_Stiff')
	            		obj.iv.suppressNsave.ht_stiff = [folder{strcmpi(name,'ht-stiff')} '/' name{strcmpi(name,'ht-stiff')}];
	        		end
        		end
        	end
        	cd(hostFolder)

            if exist('hhh', 'var')
                close(hhh);
            end
        	disp('====================================================')
		    disp('			Collated Photometry Analysis Processing 	 	  ')
		    disp('====================================================')
		    disp(' ')
		    disp(['Started: ' datestr(now)])
		    disp(' ')
            hostFiles = dir(hostFolder);
			dirFlags = [hostFiles.isdir];
			subFolders = hostFiles(dirFlags);
			folderNames = {subFolders(3:end).name};
			% folderPaths = {subFolders(3:end).folder};
			if correctionsMode
				% 
				% 	Only load new folders and folders with error
				% 
				EEidxs = obj.reportErrors(false);
                EEidxsliteral = find(EEidxs);
				folderNames = {obj.collatedResults(EEidxs).sessionID};
			elseif addDataMode
				obj.iv.files(end+1:end+numel(folderNames)) = folderNames;
			else 
				obj.iv.files = folderNames;
			end

			disp(char(['Loading the following files...' folderNames]))
			disp(' ')
	    	disp('-----------------------------------------------------------------')
	
            
			for ipos = 1:numel(folderNames)
				if correctionsMode
					iset = EEidxsliteral(ipos);
				elseif addDataMode
					iset = numel({obj.collatedResults.sessionID})+1;
				else 
					iset = ipos;
				end
				result = [];
				fprintf(['Working on file #' num2str(ipos) ': ' folderNames{ipos} '(' num2str(ipos) '/' num2str(numel(folderNames)) ' ' datestr(now,'HH:MM AM') ') \n'])
        		cd(folderNames{ipos})
        		% 
				% 	Check what info is available to us in the subfolder. If we want a box200 gfit, we need to load the gfit. If exclusions are present we will add them
				% 
				dirFiles = dir;
				% 
				% 	First, ensure statObj is already present:
				% 
				sObjpos = find(contains({dirFiles.name},'REVISED'));
				if isempty(sObjpos)
					sObjpos = find(contains({dirFiles.name},'sObj'));
					if isempty(sObjpos)
						sObjpos = find(contains({dirFiles.name},'snpObj'));
						if isempty(sObjpos)
							sObjpos = find(contains({dirFiles.name},'statObj'));
						end
					end
				end
				try
					if ~isempty(sObjpos)
						% 
						% 	Find the newest version of the obj
						% 
						idxdates = [dirFiles(sObjpos).datenum];
						newestObj = find(idxdates == max([dirFiles(sObjpos).datenum]));
						sObjpos = sObjpos(newestObj);

						pathstr = obj.correctPathOS([dirFiles(sObjpos).folder, '\' dirFiles(sObjpos).name]);
						sObj = load(pathstr);
	                    sObjfield = fieldnames(sObj);
	                    eval(['sObj = sObj.' sObjfield{1} ';']);
	                    if strcmpi(obj.iv.collateKey, 'rim')
	                    	istyle = strsplit(folderNames{ipos}, '_');
	                    	sObj.iv.Style = istyle{end};
                    	end

	                    result = obj.analyze(sObj, obj.iv.collateKey);
	                    obj.collatedResults(iset).analysisType = obj.iv.collateKey;
	                    obj.collatedResults(iset).sessionID = folderNames{ipos};
	                    if strcmpi(obj.iv.collateKey, 'PCAbehavior')
	                    	obj.collatedResults(iset).rxnwindows = unique(result.rxnwin_s);
	                    	obj.collatedResults(iset).modes = unique(result.behaviorparams.ishybrid);
	                    	obj.iv.modenote = 'modes in collated results indicates 1 for hybrid, 2 for pav, 0 for everything else (operant)';
                            
	                    	obj.collatedResults(iset).ntrials = result.ntrials;
							
							nrewards = sum(result.flick_s_wrtc >=3.333);							
							obj.collatedResults(iset).nrewards = nrewards;
                            obj.collatedResults(iset).binningflag = result.binningflag;
							obj.collatedResults(iset).behaviorparams = result.behaviorparams;
							obj.collatedResults(iset).behaviorparams.rxnwin_s = result.rxnwin_s; 

	                    	obj.collatedResults(iset).flick_s_wrtc = result.flick_s_wrtc;
							obj.collatedResults(iset).cue = result.cue;
							obj.collatedResults(iset).lick = result.lick;
							obj.collatedResults(iset).lampOff = result.lampOff;
							
							obj.collatedResults(iset).alllick_s_wrtc = result.lick_s_wrtc;
							obj.collatedResults(iset).alllick_s_wrtc_newboutonly = result.lick_s_wrtc_newboutonly;
                            obj.collatedResults(iset).Excluded_Trials = result.Excluded_Trials;
                        elseif strcmpi(obj.iv.collateKey, 'sloshingStimulation')
                        	obj.collatedResults(iset).flick_s_wrtc = result.flick_s_wrtc;
                        	obj.collatedResults(iset).stimTrials = result.stimTrials;
                        	obj.collatedResults(iset).noStimTrials = result.noStimTrials;
                        	obj.collatedResults(iset).stim_flicks = result.stim_flicks;
                        	obj.collatedResults(iset).unstim_flicks = result.unstim_flicks;
                        	obj.collatedResults(iset).stim_nexttrial_flicks = result.stim_nexttrial_flicks;
                        	obj.collatedResults(iset).unstim_nexttrial_flicks = result.unstim_nexttrial_flicks;
                        	obj.collatedResults(iset).stim_nexttrial_flicks2 = result.stim_nexttrial_flicks2;
                        	obj.collatedResults(iset).unstim_nexttrial_flicks2 = result.unstim_nexttrial_flicks2;

                        elseif strcmpi(obj.iv.collateKey, 'sloshingModels') || strcmpi(obj.iv.collateKey, 'sloshingModels-sysclub')
                        	obj.collatedResults(iset).divs = obj.iv.n{1}; % number of timebins, eg 10 -- 1s bins (10s ITI)
                        	obj.collatedResults(iset).Mode = obj.iv.n{2}; %'LTA' or 'LOTA' 
                        	obj.collatedResults(iset).Model = obj.iv.n{3}; % 'del' or 'abs'
                        	obj.collatedResults(iset).Signal = obj.iv.n{4}; % 'mean' or 'median' or 'rails'
                        	
                        	obj.collatedResults(iset).rsq = result.rsq;
                        	obj.collatedResults(iset).criterion = result.criterion;
                        	obj.collatedResults(iset).ModelNames = result.ModelNames;
                        	obj.collatedResults(iset).Theta_Names = result.Theta_Names;
                        	obj.collatedResults(iset).mdls = result.mdls; % this should have everything we need to do stuff
%                         	obj.collatedResults(iset).LOI = result.LOI;
						elseif strcmpi(obj.iv.collateKey, 'sloshingModels_timeslice')
							obj.collatedResults(iset).divs = obj.iv.n{1}; % number of timebins, eg 10 -- 1s bins (10s ITI)
                        	obj.collatedResults(iset).Mode = obj.iv.n{2}; %'LTA' or 'LOTA' || for timeslice, will be LTA-&-EMG-&-X-&-tdt
                        	obj.collatedResults(iset).Model = obj.iv.n{3}; % 'del' or 'abs'
                        	obj.collatedResults(iset).Signal = obj.iv.n{4}; % 'mean' or 'median' or 'rails'
                        	if numel(obj.iv.n) > 4
                        		obj.collatedResults(iset).Early_or_Rew_conditioning = obj.iv.n{5};
                    		end
                        	
                        	obj.collatedResults(iset).Name = result.Name;
                        	obj.collatedResults(iset).mdls = result.mdls; % this should have everything we need to do stuff
                    		obj.collatedResults(iset).ModelDeets = result.ModelDeets;
						elseif strcmpi(obj.iv.collateKey, 'grabMoveControls')
							% n={gfitcell, binningMode, nbins, pad}
							% runningavetimeseries_movement
                        	% we need to do the running average
                        	obj.collatedResults(iset).hasPhot = result.hasPhot;
                        	obj.collatedResults(iset).hasX = result.hasX;
                        	obj.collatedResults(iset).hastdt = result.hastdt;
                        	obj.collatedResults(iset).hasEMG = result.hasEMG;
                        	obj.collatedResults(iset).gfitStyle = obj.iv.n{1}; % the gfit mode for red channel
                        	obj.collatedResults(iset).Mode = obj.iv.n{2}; %'the binning mode for getbinnedtimeseries
                        	obj.collatedResults(iset).nbins = obj.iv.n{3}; % the nbins for getbinnedtimeseries
                        	obj.collatedResults(iset).timePad = obj.iv.n{4}; % the timepad (ms) for getbinnedtimeseries



                    	elseif strcmpi(obj.iv.collateKey, 'sloshingLOI')
                        	obj.collatedResults(iset).Model = obj.iv.n{1}; % 'del' or 'abs'
                        	obj.collatedResults(iset).Signal = obj.iv.n{2}; % 'mean' or 'median' or 'rails'
                        	
                        	obj.collatedResults(iset).models = result.models;
                        	obj.collatedResults(iset).LOI = result.LOI;
                        				
	                    elseif strcmpi(obj.iv.collateKey, 'loivsflick')
	                    	obj.collatedResults(iset).stats = result.stats;
	                    	obj.collatedResults(iset).b = result.b;
	                    	obj.collatedResults(iset).rsq = result.rsq2;
	                    	obj.collatedResults(iset).yfit = result.yfit;
	                    	obj.collatedResults(iset).x = result.x;
	                    	obj.collatedResults(iset).y = result.y;
                    	elseif strcmpi(obj.iv.collateKey, 'getOperantTrials')
	                    	obj.collatedResults(iset).operantTrials = result.operantTrials;
	                    	obj.collatedResults(iset).pavlovianTrials = result.pavlovianTrials;
                        elseif strcmpi(obj.iv.collateKey, 'cdf')
	                    	obj.collatedResults(iset).ecdf_f = result.ecdf_f;
	                    	obj.collatedResults(iset).ecdf_x = result.ecdf_x;
	                    	obj.collatedResults(iset).f_lick_ex_s_ecdf = result.result.f_lick_ex_s_wrtref_cdf;
	                    	obj.collatedResults(iset).lick_s = result.result.lick_s;
	                    	obj.collatedResults(iset).f_lick_ex_s_wrtref = result.result.f_lick_ex_s_wrtref;
	                    	obj.collatedResults(iset).rb_s = result.result.rb_ms/1000;
                    	elseif strcmpi(obj.iv.collateKey, 'PCAdecoding')
                    		obj.collatedResults(iset).PCA = result.PCA;
                    		obj.collatedResults(iset).decoding.ht = result.decoding.ht;
                    		obj.collatedResults(iset).decoding.htPCA = result.decoding.htPCA;
                    		obj.collatedResults(iset).decoding.PC1_3 = result.decoding.PC1_3;
                    		obj.collatedResults(iset).decoding.PC1_3htPCA = result.decoding.PC1_3htPCA;
                    		obj.collatedResults(iset).decoding.mislope = result.decoding.mislope;
                    		obj.collatedResults(iset).decoding.htPCA_stiff = result.decoding.htPCA_stiff;
                    		obj.collatedResults(iset).decoding.PCA_ht_1_Stiff = result.decoding.PCA_ht_1_Stiff;
                    		
                    		obj.collatedResults(iset).ht_raw = result.decoding.ht_raw;
							obj.collatedResults(iset).ht_PCA = result.decoding.ht_PCA;
                    		obj.collatedResults(iset).flick_s_wrtc = result.flick_s_wrtc;
                		elseif strcmpi(obj.iv.collateKey, 'DecodingPaperFinal')
                			obj.collatedResults(iset).decoding.ht_stiff_ea = result.decoding.ht_stiff_ea;
                    		obj.collatedResults(iset).decoding.multiht_stiff_ea = result.decoding.multiht_stiff_ea;
                    		obj.collatedResults(iset).decoding.PC1_3_1httdtstiff = result.decoding.PC1_3_1httdtstiff;
                    		obj.collatedResults(iset).decoding.htPCAstiff_1tdtstiff = result.decoding.htPCAstiff_1tdtstiff;
                    		obj.collatedResults(iset).decoding.multihtPCAstiff_multitdtstiff = result.decoding.multihtPCAstiff_multitdtstiff;
                    		obj.collatedResults(iset).decoding.multihtPCAstiff_multiPCAtdtstiff = result.decoding.multihtPCAstiff_multiPCAtdtstiff;
                    		obj.collatedResults(iset).flick_s_wrtc = result.flick_s_wrtc;
                    		obj.collatedResults(iset).flagNoRed = result.flagNoRed;
                		elseif strcmpi(obj.iv.collateKey,'1ht_stiff_ea')
                    		obj.collatedResults(iset).decoding.ht_stiff_ea = result.decoding.ht_stiff_ea;
                    		obj.collatedResults(iset).flick_s_wrtc = result.flick_s_wrtc;
                    		obj.collatedResults(iset).flagNoRed = result.flagNoRed;
                		elseif strcmpi(obj.iv.collateKey,'multiht_stiff_ea')
                			obj.collatedResults(iset).decoding.multiht_stiff_ea = result.decoding.multiht_stiff_ea;
                    		obj.collatedResults(iset).flick_s_wrtc = result.flick_s_wrtc;
                    		obj.collatedResults(iset).flagNoRed = result.flagNoRed;
                		elseif strcmpi(obj.iv.collateKey,'PC1_3_1httdtstiff')
                			obj.collatedResults(iset).decoding.PC1_3_1httdtstiff = result.decoding.PC1_3_1httdtstiff;
                    		obj.collatedResults(iset).flick_s_wrtc = result.flick_s_wrtc;
                    		obj.collatedResults(iset).flagNoRed = result.flagNoRed;
                		elseif strcmpi(obj.iv.collateKey,'1htPCAstiff_1tdtstiff')
                			obj.collatedResults(iset).decoding.htPCAstiff_1tdtstiff = result.decoding.htPCAstiff_1tdtstiff;
                    		obj.collatedResults(iset).flick_s_wrtc = result.flick_s_wrtc;
                    		obj.collatedResults(iset).flagNoRed = result.flagNoRed;
                		elseif strcmpi(obj.iv.collateKey,'multihtPCAstiff_multitdtstiff')
                			obj.collatedResults(iset).decoding.multihtPCAstiff_multitdtstiff = result.decoding.multihtPCAstiff_multitdtstiff;
                    		obj.collatedResults(iset).flick_s_wrtc = result.flick_s_wrtc;
                    		obj.collatedResults(iset).flagNoRed = result.flagNoRed;
                		elseif strcmpi(obj.iv.collateKey,'multihtPCAstiff_multiPCAtdtstiff') 
                			obj.collatedResults(iset).decoding.multihtPCAstiff_multiPCAtdtstiff = result.decoding.multihtPCAstiff_multiPCAtdtstiff;
                    		obj.collatedResults(iset).flick_s_wrtc = result.flick_s_wrtc;
                    		obj.collatedResults(iset).flagNoRed = result.flagNoRed;
                		elseif strcmpi(obj.iv.collateKey, 'htStiff') || strcmpi(obj.iv.collateKey, 'ht_1_Stiff')
                			obj.collatedResults(iset).decoding.ht_stiff = result.decoding.ht_stiff;
                			obj.collatedResults(iset).flick_s_wrtc = result.flick_s_wrtc;

                    	elseif strcmpi(obj.iv.collateKey, 'ht')
                    		obj.collatedResults(iset).note = result.note;
                    		obj.collatedResults(iset).nthresh = result.nthresh;
                    		obj.collatedResults(iset).nTrials_InRange = result.nTrialsTotal;
                    		obj.collatedResults(iset).nbins_inRange = result.nbins_inRange;

                    		obj.collatedResults(iset).binned_ntrialsperbin = result.binned_ntrialsperbin;
                    		obj.collatedResults(iset).delay_ms = result.delay_ms;
                    		obj.collatedResults(iset).smoothing_samples = result.smoothing_samples;

                    		obj.collatedResults(iset).singletrial_b = result.singletrial_b;
                    		obj.collatedResults(iset).singletrial_dev = result.singletrial_dev;
                    		obj.collatedResults(iset).singletrial_stats = result.singletrial_stats;
                    		obj.collatedResults(iset).singletrial_rsq = result.singletrial_rsq;
                    		obj.collatedResults(iset).singletrial_nbinsXing = result.singletrial_nbinsXing;
                    		obj.collatedResults(iset).singletrial_pcTrialsXing = result.singletrial_pcTrialsXing;
                    		obj.collatedResults(iset).singletrial_time2lickFromThreshXing = result.singletrial_time2lickFromThreshXing;
                    		obj.collatedResults(iset).binned_b = result.binned_b;
                    		obj.collatedResults(iset).binned_dev = result.binned_dev;
                    		obj.collatedResults(iset).binned_stats = result.binned_stats;
                    		obj.collatedResults(iset).binned_rsq = result.binned_rsq;
                    		obj.collatedResults(iset).binned_nbinsXing = result.binned_nbinsXing;
                    		obj.collatedResults(iset).binned_pcBinsXing = result.binned_pcBinsXing;
                    		obj.collatedResults(iset).binned_time2lickFromThreshXing = result.binned_time2lickFromThreshXing;
                		elseif strcmpi(obj.iv.collateKey, 'vt')
                    		obj.collatedResults(iset).note = result.note;
                    		obj.collatedResults(iset).nthresh = result.nthresh;
                    		obj.collatedResults(iset).nTrialsTotal = result.nTrialsTotal;
                    		obj.collatedResults(iset).nBinsTotal = result.nBinsTotal;
                    		obj.collatedResults(iset).thresholds = result.thresholds;

                    		obj.collatedResults(iset).binned_ntrialsperbin = result.binned_ntrialsperbin;
                    		obj.collatedResults(iset).delay_ms = result.delay_ms;
                    		obj.collatedResults(iset).smoothing_samples = result.smoothing_samples;

                    		obj.collatedResults(iset).singletrial_b = result.singletrial_b;
                    		obj.collatedResults(iset).singletrial_dev = result.singletrial_dev;
                    		obj.collatedResults(iset).singletrial_stats = result.singletrial_stats;
                    		obj.collatedResults(iset).singletrial_rsq = result.singletrial_rsq;
                    		obj.collatedResults(iset).singletrial_r = result.singletrial_r;
                    		
                    		
                    		obj.collatedResults(iset).binned_b = result.binned_b;
                    		obj.collatedResults(iset).binned_dev = result.binned_dev;
                    		obj.collatedResults(iset).binned_stats = result.binned_stats;
                    		obj.collatedResults(iset).binned_rsq = result.binned_rsq;
                    		obj.collatedResults(iset).binned_r = result.binned_r;
                		elseif strcmpi(obj.iv.collateKey,'baselineANOVAidx') || strcmpi(obj.iv.collateKey,'baselineANOVAwithLick')
                			obj.collatedResults(iset).results = result.results;
                			obj.collatedResults(iset).F_nm1 = result.F_nm1;
                			obj.collatedResults(iset).F_n = result.F_n;
                			obj.collatedResults(iset).nm1Score = result.nm1Score;
                			obj.collatedResults(iset).nScore = result.nScore;
                			obj.collatedResults(iset).sig_nm1 = result.sig_nm1;
                			obj.collatedResults(iset).sig_n = result.sig_n;
                			obj.collatedResults(iset).centers = result.centers;
                			obj.collatedResults(iset).baselineWindow = result.baselineWindow;
            			elseif strcmpi(obj.iv.collateKey, 'PCAcollateSummary')
            				obj.collatedResults(iset).PCA = result.PCA;
            				obj.collatedResults(iset).flick_s_wrtc = result.flick_s_wrtc;
        				elseif strcmpi(obj.iv.collateKey, 'divergenceIndex')
        					result.Stat.convergenceIndex.XE = [];
        					result.Stat.convergenceIndex.XR = [];
        					result.Stat.divergenceIndex.EX = [];
							result.Stat.divergenceIndex.RX = [];
            				obj.collatedResults(iset).Stat = result.Stat;
            				obj.collatedResults(iset).flick_s_wrtc = result.flick_s_wrtc;
        				elseif strcmpi(obj.iv.collateKey,'CLTAconditionNm1notRew')
        					obj.collatedResults(iset).flick_s_wrtc = result.flick_s_wrtc;
        					obj.collatedResults(iset).nm1rew = result.nm1rew;
        					obj.collatedResults(iset).nm1norew = result.nm1norew;
        				elseif strcmpi(obj.iv.collateKey, 'tof')
        					obj.collatedResults(iset).riseT_linear_rsq = result.riseT.linear.rsq;
            				obj.collatedResults(iset).riseT_linear_pbeta = result.riseT.linear.p(2);
            				obj.collatedResults(iset).riseT_linear_b0 = result.riseT.linear.b0;
            				obj.collatedResults(iset).riseT_linear_b1 = result.riseT.linear.b1;
            				obj.collatedResults(iset).riseT_sqrty_rsq = result.riseT.sqrt_y.rsq;
            				obj.collatedResults(iset).riseT_sqrty_pbeta = result.riseT.sqrt_y.p(2);
            				obj.collatedResults(iset).riseT_sqrty_b0 = result.riseT.sqrt_y.b0;
            				obj.collatedResults(iset).riseT_sqrty_b1 = result.riseT.sqrt_y.b1;

            				obj.collatedResults(iset).peakT_linear_rsq = result.peakT.linear.rsq;
            				obj.collatedResults(iset).peakT_linear_pbeta = result.peakT.linear.p(2);
            				obj.collatedResults(iset).peakT_linear_b0 = result.peakT.linear.b0;
            				obj.collatedResults(iset).peakT_linear_b1 = result.peakT.linear.b1;
            				obj.collatedResults(iset).peakT_sqrty_rsq = result.peakT.sqrt_y.rsq;
            				obj.collatedResults(iset).peakT_sqrty_pbeta = result.peakT.sqrt_y.p(2);
            				obj.collatedResults(iset).peakT_sqrty_b0 = result.peakT.sqrt_y.b0;
            				obj.collatedResults(iset).peakT_sqrty_b1 = result.peakT.sqrt_y.b1;

            				obj.collatedResults(iset).peakAmp_linear_rsq = result.peakAmp.linear.rsq;
            				obj.collatedResults(iset).peakAmp_linear_pbeta = result.peakAmp.linear.p(2);
            				obj.collatedResults(iset).peakAmp_linear_b0 = result.peakAmp.linear.b0;
            				obj.collatedResults(iset).peakAmp_linear_b1 = result.peakAmp.linear.b1;
            				obj.collatedResults(iset).peakAmp_sqrty_rsq = result.peakAmp.sqrt_y.rsq;
            				obj.collatedResults(iset).peakAmp_sqrty_pbeta = result.peakAmp.sqrt_y.p(2);
            				obj.collatedResults(iset).peakAmp_sqrty_b0 = result.peakAmp.sqrt_y.b0;
            				obj.collatedResults(iset).peakAmp_sqrty_b1 = result.peakAmp.sqrt_y.b1;

            				obj.collatedResults(iset).integral_linear_rsq = result.integral.linear.rsq;
            				obj.collatedResults(iset).integral_linear_pbeta = result.integral.linear.p(2);
            				obj.collatedResults(iset).integral_linear_b0 = result.integral.linear.b0;
            				obj.collatedResults(iset).integral_linear_b1 = result.integral.linear.b1;
            				obj.collatedResults(iset).integral_sqrty_rsq = result.integral.sqrt_y.rsq;
            				obj.collatedResults(iset).integral_sqrty_pbeta = result.integral.sqrt_y.p(2);  
            				obj.collatedResults(iset).integral_sqrty_b0 = result.integral.sqrt_y.b0;
            				obj.collatedResults(iset).integral_sqrty_b1 = result.integral.sqrt_y.b1;      

        				elseif strcmpi(obj.iv.collateKey, 'nTrialsWithFLick')
        					obj.collatedResults(iset).nFLicks = result.nFLicks;
        					obj.collatedResults(iset).flick_s_wrtc = result.flick_s_wrtc;   
    					elseif strcmpi(obj.iv.collateKey, 'prepXconditioning')
    						obj.collatedResults(iset).sObj = result.sObj; 
    						obj.collatedResults(iset).mObj = result.mObj;
    						obj.collatedResults(iset).exploreObj = result.exploreObj;
    						obj.collatedResults(iset).analysis.flick_s_wrtc = result.analysis.flick_s_wrtc;
    						obj.collatedResults(iset).analysis.smX = result.analysis.smX;
    						obj.collatedResults(iset).analysis.note = result.analysis.note;
    						obj.collatedResults(iset).analysis.st_ID = result.analysis.st_ID;
    						obj.collatedResults(iset).analysis.trialID = result.analysis.trialID;
    						obj.collatedResults(iset).Ratio = result.Ratio;
    						obj.collatedResults(iset).Amplitude = result.Amplitude;
						elseif strcmpi(obj.iv.collateKey, 'extract_trial_CSV')
							%  No data saved to result... a shell
						elseif strcmpi(obj.iv.collateKey, 'stepvramp_julia')
							obj.collatedResults(iset).amount_of_computation = result.amount_of_computation;
							obj.collatedResults(iset).flags = result.flags;
							obj.collatedResults(iset).intercepts = result.intercepts;
							obj.collatedResults(iset).left_segment = result.left_segment;
							obj.collatedResults(iset).lick_time = result.lick_time;
							obj.collatedResults(iset).modelID = result.modelID;
							obj.collatedResults(iset).ntraces_per_trial = result.ntraces_per_trial;
							obj.collatedResults(iset).p = result.p;
							obj.collatedResults(iset).right_segment = result.right_segment;
							obj.collatedResults(iset).sessionCode = result.sessionCode;
							obj.collatedResults(iset).slopes = result.slopes;
							obj.collatedResults(iset).step_time = result.step_time;
							obj.collatedResults(iset).tNo = result.tNo;
							obj.collatedResults(iset).trim_cue_s = result.trim_cue_s;
							obj.collatedResults(iset).trim_lick_s = result.trim_lick_s;

			 				obj.collatedResults(iset).flick_s_wrtc = result.flick_s_wrtc;
						    obj.collatedResults(iset).step_time_s_wrtc = result.step_time_s_wrtc;
						    obj.collatedResults(iset).pc_interval_step = result.pc_interval_step;
						    obj.collatedResults(iset).nbins = result.nbins;
						    obj.collatedResults(iset).binedges = result.binedges;
						    obj.collatedResults(iset).trials_per_bin = result.trials_per_bin;

						    obj.collatedResults(iset).gfit_xl = result.gfit_xl;
						    obj.collatedResults(iset).gfit_xr = result.gfit_xr;
						    obj.collatedResults(iset).gfit_LHS = result.gfit_LHS;
						    obj.collatedResults(iset).gfit_RHS = result.gfit_RHS;
						    obj.collatedResults(iset).gfit_count_l = result.gfit_count_l;
						    obj.collatedResults(iset).gfit_count_r = result.gfit_count_r;

						    obj.collatedResults(iset).tdt_xl = result.tdt_xl;
						    obj.collatedResults(iset).tdt_xr = result.tdt_xr;
						    obj.collatedResults(iset).tdt_LHS = result.tdt_LHS;
						    obj.collatedResults(iset).tdt_RHS = result.tdt_RHS;
						    obj.collatedResults(iset).tdt_count_l = result.tdt_count_l;
						    obj.collatedResults(iset).tdt_count_r = result.tdt_count_r;

						    obj.collatedResults(iset).emg_xl = result.emg_xl;
						    obj.collatedResults(iset).emg_xr = result.emg_xr;
						    obj.collatedResults(iset).emg_LHS = result.emg_LHS;
						    obj.collatedResults(iset).emg_RHS = result.emg_RHS;
						    obj.collatedResults(iset).emg_count_l = result.emg_count_l;
						    obj.collatedResults(iset).emg_count_r = result.emg_count_r;

					    	obj.collatedResults(iset).Xflag = result.Xflag;
	                	end
	                    
	                    
					else
						error('No statObj in the folder!')
                    end	

                    % collect some useful data...
                    strs = obj.collatedResults(iset).sessionID;
                    ids = regexp(strs, '_', 'split');
                    sessionNos = str2double(ids{3});
                    obj.collatedResults(iset).sessionNo = sessionNos;
                    mouseName = ids{1};
                    obj.collatedResults(iset).mouseName = mouseName;
                    
                   
                    if correctionsMode
						disp('error fixed! moving on...')
						obj.collatedResults(iset).error = [];
					end
					disp(' ')
					disp('	File analyzed and added to Collated Obj.')
				catch ex
					EE = getReport(ex);
					disp(EE)
					warning(['Error while processing this file. The message was:' EE])
					disp('	Skipping this file. Add it to the collated analysis obj later')

                    obj.collatedResults(iset).analysisType = obj.iv.collateKey;
                    obj.collatedResults(iset).sessionID = folderNames{ipos};
                    obj.collatedResults(iset).error = ['Error Encountered:' EE];

                end
                
	    		disp('-----------------------------------------------------------------')
                cd(hostFolder)
            end
            % try 
            %     [~,~,mouseIdx] = unique({obj.collatedResults.mouseName});
            %     mouseIdx = num2cell(mouseIdx);
            %     [obj.collatedResults.mouseIdx] = mouseIdx{:};
            % catch
            %     warning('unable to index animals...')
            % end
			if correctionsMode || addDataMode
				obj.save;
			end
		end
		function fixErrors(obj)
			% 
			% 	Go to the original host folder after stuff fixed in folders or code and run again
			% 
			obj.getDataset(true, false);
		end
		function addData(obj)
			% 
			% 	Go to a distinct host folder with the new data host days to add and run this
			% 
			obj.getDataset(false,true);
		end


		function [idxs,ok] = reportErrors(obj, verbose)
			if nargin < 2
				verbose = true;
			end
			if verbose
				disp('----------------	Error Report -----------------')
				disp('There were errors processing the following datasets:')
				disp(' ')
			end
			if ~isfield(obj.collatedResults, 'error')
				idxs = zeros(length({obj.collatedResults.sessionID}),1);
				ok = ones(length({obj.collatedResults.sessionID}),1);
				return
			end
			if strcmpi(obj.iv.collateKey, 'cdf')
				if verbose, disp(char({obj.collatedResults(cellfun(@(x) isempty(x), {obj.collatedResults.rb_s})).sessionID}')), end
				idxs = cellfun(@(x) isempty(x), {obj.collatedResults.rb_s});
				ok = cellfun(@(x) ~isempty(x), {obj.collatedResults.rb_s});
			elseif strcmpi(obj.iv.collateKey, 'ht')
				if verbose, disp(char({obj.collatedResults(cellfun(@(x) isempty(x), {obj.collatedResults.binned_time2lickFromThreshXing})).sessionID}')), end
				idxs = cellfun(@(x) isempty(x), {obj.collatedResults.binned_time2lickFromThreshXing});
				ok = cellfun(@(x) ~isempty(x), {obj.collatedResults.binned_time2lickFromThreshXing});
			else %if strcmpi(obj.iv.collateKey, 'PCAdecoding') || strcmpi(obj.iv.collateKey, 'htStiff') || strcmpi(obj.iv.collateKey, 'ht_1_Stiff') || strcmpi(obj.iv.collateKey, 'baselineANOVAidx') || strcmpi(obj.iv.collateKey, 'baselineANOVAwithLick')
                if verbose, disp(char({obj.collatedResults(cellfun(@(x) ~isempty(x), {obj.collatedResults.error})).sessionID}')), end
				idxs = cellfun(@(x) ~isempty(x), {obj.collatedResults.error});
				ok = cellfun(@(x) isempty(x), {obj.collatedResults.error});
			end
		end

		function replaceErrors(obj)

		end

		

		function result = analyze(obj, sObj, collateKey)
			% 
			% 	collateKey: 	A keyword indicating the analysis to complete
			% 				cdf
			% 				ht
			%
			% ----------
            if isfield(sObj.Log, 'f_log')
                try
                    close(sObj.Log.f_log)
                catch
%                     warning('here')
                end
            end
			if nargin < 2
				collateKey = 'cdf';
				disp('-------------default analysis: cdf of first licks with exclusions, excluding trials in first 700ms -- saving ALL first lick times (including rxns) and cdfs---------------')
			end

			if strcmpi(collateKey, 'cdf')
				% 
				% 	Will work for an object with any kind of signal
				% 
				[result.ecdf_f, result.ecdf_x, result.result] = sObj.getCDFAnalysis(0, obj.iv.runID, obj.iv.suppressNsave.cdf);
			elseif strcmpi(collateKey, 'PCAbehavior')
				% 
				% 	Will work for an object with any kind of signal, just gets the first licks wrtc
				% 
				sObj.getflickswrtc;
				result.flick_s_wrtc = sObj.GLM.flick_s_wrtc;
				result.ntrials = numel(sObj.GLM.flick_s_wrtc);
                result.cue = sObj.GLM.cue_s;
				result.lick = sObj.GLM.lick_s;
				result.lampOff = sObj.GLM.lampOff_s;

                result.Excluded_Trials = sObj.iv.exclusions_struct.Excluded_Trials;

				% we need to open the arduino connection file to find the reaction window...
				dirFiles = dir;
				pos = find(contains({dirFiles.name},'behavior'));
				result.binningflag = '';
				if isempty(pos)
					warning('There''s no Arduino Connection file detected in this folder. Make sure it says ''behavior'' in the filename!')
					result.rxnwin_s = 0;
					result.behaviorparams.ishybrid = nan;
					result.behaviorparams.rb_ms = nan;
					result.behaviorparams.eot = nan;
					result.behaviorparams.target = nan;
					result.behaviorparams.total_time_ = nan;
					result.binningflag = 'there is no Arduino behavior file...';
				else

					pathstr = obj.correctPathOS([dirFiles(pos).folder, '\' dirFiles(pos).name]);
					objAC = load(pathstr);
	                objACfield = fieldnames(objAC);
	                eval(['objAC = objAC.' objACfield{1} ';']);
	                % look for rxn window...
	                iii = find(contains(objAC.ParamNames, 'ABORT_MIN'));
	                if ~isfield(objAC.Trials, 'Parameters')
	                	warning('Yikes! The behavioral file is a problem, there are no Trials or Parameters recorded. We will go with the values at last save...')
	                	result.binningflag = 'there was no data in the behavior file so we are assuming the params logged at last save were true for every trial';
	                	iii = find(contains(objAC.ParamNames, 'ABORT_MIN'));
	                	result.rxnwin_s = objAC.ParamValues(iii)./1000.*ones(1,result.ntrials);
	                	iii = find(contains(objAC.ParamNames, 'HYBRID')); % 1 for hybrid, 0 for operant or pav...but will add +1 for pav (should never happen)
						result.behaviorparams.ishybrid = objAC.ParamValues(iii).*ones(1,result.ntrials);
						iii = find(contains(objAC.ParamNames, 'PAVLOVIAN')); % 2 for pav
		                iii = iii(1);
						result.behaviorparams.ishybrid = result.behaviorparams.ishybrid + objAC.ParamValues(iii).*ones(1,result.ntrials);
						if sum(ismember(result.behaviorparams.ishybrid, 2))
							warning('this session seems to have had PAVLOVIAN mode trials...eeek. Use caution.')
						end
						iii = find(contains(objAC.ParamNames, 'ABORT_MAX'));
		                result.behaviorparams.rb_ms = objAC.ParamValues(iii).*ones(1,result.ntrials);
		                iii = find(contains(objAC.ParamNames, 'TRIAL_DURATION'));
		                result.behaviorparams.eot = objAC.ParamValues(iii).*ones(1,result.ntrials);
		                iii = find(contains(objAC.ParamNames, 'TARGET'));
		                result.behaviorparams.target = objAC.ParamValues(iii).*ones(1,result.ntrials);
		                iii = find(contains(objAC.ParamNames, 'INTERVAL_MAX'));
		                jjj = find(contains(objAC.ParamNames, 'ITI'));
		                jjj = jjj(1);
		                result.behaviorparams.total_time_ = objAC.ParamValues(iii).*ones(1,result.ntrials); + objAC.ParamValues(jjj).*ones(1,result.ntrials);;
                	else
		                rxnwin_s = cell2mat(cellfun(@(x) x(iii), {objAC.Trials.Parameters}, 'uniformoutput', 0))./1000;
		                result.rxnwin_s = rxnwin_s;
						iii = find(contains(objAC.ParamNames, 'HYBRID')); % 1 for hybrid, 0 for operant or pav...but will add +1 for pav (should never happen)
						result.behaviorparams.ishybrid = cell2mat(cellfun(@(x) x(iii), {objAC.Trials.Parameters}, 'uniformoutput', 0));
						iii = find(contains(objAC.ParamNames, 'PAVLOVIAN')); % 2 for pav
		                iii = iii(1);
						result.behaviorparams.ishybrid = result.behaviorparams.ishybrid + cell2mat(cellfun(@(x) 2.*x(iii), {objAC.Trials.Parameters}, 'uniformoutput', 0));
						if sum(ismember(result.behaviorparams.ishybrid, 2))
							warning('this session seems to have had PAVLOVIAN ONLY trials...eeek. Use caution.')
						end
						iii = find(contains(objAC.ParamNames, 'ABORT_MAX'));
		                result.behaviorparams.rb_ms = cell2mat(cellfun(@(x) x(iii), {objAC.Trials.Parameters}, 'uniformoutput', 0));
		                iii = find(contains(objAC.ParamNames, 'TRIAL_DURATION'));
		                result.behaviorparams.eot = cell2mat(cellfun(@(x) x(iii), {objAC.Trials.Parameters}, 'uniformoutput', 0));
		                iii = find(contains(objAC.ParamNames, 'TARGET'));
		                result.behaviorparams.target = cell2mat(cellfun(@(x) x(iii), {objAC.Trials.Parameters}, 'uniformoutput', 0));
		                iii = find(contains(objAC.ParamNames, 'INTERVAL_MAX'));
		                jjj = find(contains(objAC.ParamNames, 'ITI'));
		                jjj = jjj(1);
		                result.behaviorparams.total_time_ = cell2mat(cellfun(@(x) x(iii), {objAC.Trials.Parameters}, 'uniformoutput', 0)) + cell2mat(cellfun(@(x) x(jjj), {objAC.Trials.Parameters}, 'uniformoutput', 0));
	                end
                end

                % get cue-aligned ALL licks and cue-aligned NEW lick bouts
                rxnwin_s = unique(result.rxnwin_s);
                lick = result.lick;
                if numel(rxnwin_s) >1
                    warning('there are multiple rxn windows here...we will exclude any that are 500 for purposes of binning')
                    result.binningflag = 'excluded rxn >0ms from binning, but not in collatedResults.lick field';
                    iii = find(result.rxnwin_s>0);
                    lick(iii) = NaN;
                
                end
                % rxn win shouldnt matter for this...
                [result.lick_s_wrtc,~,~,~] = getBinnedLicksMARY_standalonefxn(result.cue, result.lick, result.lampOff, 'cue', 30000, 30000, 0, 'all');
                [result.lick_s_wrtc_newboutonly,~,~,~] = getBinnedLicksMARY_standalonefxn(result.cue, result.lick, result.lampOff, 'cue', 30000, 30000, 0, 'new');				
            elseif strcmpi(collateKey, 'sloshingStimulation')
            	espObj = EphysStimPhot(sObj);
            	espObj.getflickswrtc
            	result.flick_s_wrtc = espObj.GLM.flick_s_wrtc;
            	result.stimTrials = espObj.GLM.stimTrials;
            	result.noStimTrials = espObj.GLM.noStimTrials;
            	[result.stim_flicks,result.unstim_flicks,result.stim_nexttrial_flicks,result.unstim_nexttrial_flicks,result.stim_nexttrial_flicks2,result.unstim_nexttrial_flicks2,f] = espObj.plotStimulation;
            	figureName = ['plotStimulation_' espObj.iv.sessionCode];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, f);
				close(f);
			elseif strcmpi(collateKey, 'sloshingModels')
				div = obj.iv.n{1};
				Mode = obj.iv.n{2};
				Model = obj.iv.n{3};
				Signal = obj.iv.n{4};
				%
				% check for signals and add them if missing. this fxn autoresaved
				sObj.addMoveControls;
				
				% create a sloshing obj from the session file
				sloshObj = CLASS_sloshing_model_obj(sObj);
% 				sloshObj.Extract_LOI_predictors(sObj);
% 				result.LOI = obj.analysis.LOI;
				% run the nested model to get all permutations of the model
				[result.rsq, result.criterion, result.ModelNames, result.Theta_Names, result.mdls, fs] = sloshObj.runSelectModelByDivs(Mode,div,Model,Signal);
				for ii = 1:numel(fs)
					figureName = ['criteriondata_' get(fs(ii), 'name')];
					set(fs(ii), 'name', '')
					sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, fs(ii));
					close(fs(ii))
				end
				% get the big figures
				[~,~, f1, f2] = sloshObj.runNestedModel(cell2mat(result.ModelNames{end}),div,Model,Signal);
				% save the scatter
				figureName = ['scatterbydiv_' cell2mat(sloshObj.iv.sessionCode)];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, f1);
				close(f1);
				figureName = ['coeffbydiv_' cell2mat(sloshObj.iv.sessionCode)];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, f2);
				close(f2);
			elseif strcmpi(collateKey, 'sloshingModels_timeslice')
				div = obj.iv.n{1};
				Mode = obj.iv.n{2};
				Model = obj.iv.n{3};
				Signal = obj.iv.n{4};

				% check for signals and add them if missing. this fxn autoresaved
				warning('uncomment this')
                % sObj.addMoveControls;
				% 
				% if conditioning, we need to mask unwanted trials
				%  THIS IS NOT THE RIGHT WAY TO DO THIS...we can't predict on dels if we just delete the other category...
				% if numel(obj.iv.n) > 4
				% 	Early_or_Rew_conditionedMode = true;
                %     sObj.getflickswrtc();
				% 	if strcmpi(obj.iv.n{5}, 'early')
				% 		mask = sObj.GLM.flick_s_wrtc >= 3.333;
				% 		Title_append = 'Early-Only_';
				% 	elseif strcmpi(obj.iv.n{5}, 'reward')
				% 		mask = sObj.GLM.flick_s_wrtc < 3.333 || sObj.GLM.flick_s_wrtc > 7.0;
				% 		Title_append = 'Rewarded-Only_';
				% 	else
				% 		error('conditioning (n{5}) must be ''early'' or ''reward''')
                %     end
                %     sObj.GLM.flick_s_wrtc(mask) = nan;
				% else
				% 	Title_append = '';
				% 	Early_or_Rew_conditionedMode = false;
				% end
				if numel(obj.iv.n) > 4
					Early_or_Rew_conditioning = obj.iv.n{5};
					Title_append = 'Early-Only_';
				else
					Early_or_Rew_conditioning = 'none';
					Title_append = 'Rewarded-Only_';
				end
				%
				% create a sloshing obj from the session file
				sloshObj = CLASS_sloshing_model_obj(sObj, [], false);

				[~,~,f1,f2,result.mdls, result.ModelDeets, result.Name] = sloshObj.runNestedModel(Mode,div,Model,Signal, true, Early_or_Rew_conditioning);
				figureName = [Title_append, 'scatterbydiv_' cell2mat(sloshObj.iv.sessionCode)];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, f1);
				close(f1);
				figureName = [Title_append, 'coeffbydiv_' cell2mat(sloshObj.iv.sessionCode)];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, f2);
				close(f2);

			elseif strcmpi(collateKey, 'sloshingModels-sysclub')
				div = obj.iv.n{1};
				Mode = obj.iv.n{2};
				Model = obj.iv.n{3};
				Signal = obj.iv.n{4};
				%
				% check for signals and add them if missing. this fxn autoresaved
				sObj.addMoveControls;
				
				% create a sloshing obj from the session file
				sloshObj = CLASS_sloshing_model_obj(sObj);

				% get the big figures
				[~,~, f1, f2] = sloshObj.runNestedModel(Mode,div,Model,Signal);
				% save the scatter
				figureName = ['scatterbydiv_' cell2mat(sloshObj.iv.sessionCode)];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, f1);
				close(f1);
				figureName = ['coeffbydiv_' cell2mat(sloshObj.iv.sessionCode)];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, f2);
				close(f2);
			elseif strcmpi(collateKey, 'grabMoveControls')
				% go to the runner script. this will get all the move ctrl signals and then do running ave
				% we will store the binned data in the obj.analysis.gfit and etc fields...

				runningavetimeseries_movement

				result.hasPhot = hasPhot;
				result.hasX = hasX;
				result.hastdt = hastdt;
				result.hasEMG = hasEMG;
				
			elseif strcmpi(collateKey, 'sloshingLOI')
				Model = obj.iv.n{1};
				Signal = obj.iv.n{2};
                Window = 400;
				xshifts = {0,50,100,150,200,250,300,400,500,5000};
				nmodels = numel(xshifts);
				%
				% check for signals and add them if missing. this fxn autoresaved
				sObj.addMoveControls;
				
				% create a sloshing obj from the session file
				sloshObj = CLASS_sloshing_model_obj(sObj);
				sloshObj.Extract_LOI_predictors(sObj);
				result.LOI = sloshObj.analysis.LOI;
				% run the nested model to get all permutations of the model
				[result.models(1:nmodels).Window] = deal(Window);
				[result.models.xshift] = deal(xshifts{:});
				tstamp = datestr(now, 'yyyy_mm_dd_HHMM');
				
				for ii = 1:nmodels
					[result.models(ii).rsq, result.models(ii).criterion, result.models(ii).ModelNames, result.models(ii).Theta_Names, result.models(ii).mdls, fs] = sloshObj.retrospectiveRPE_vs_prospectiveLOI(Model, Signal, xshifts{ii}, Window);

					for jj = 1:numel(fs)
						FigureName = ['LOISloshModel_' get(fs(jj), 'name')];
						set(fs(jj), 'name', '')
                        set(fs(jj), 'units', 'normalized', 'Position', [0 0 0.5 1])
						Folder = obj.iv.suppressNsave.figuresHOST;
			    		filename = [FigureName, '_' tstamp '.fig'];
			    		f.Name = filename;
						retdir = pwd;
			            cd(Folder)
						filename = regexprep(filename, ':', '-');
						sObj.printFigure(filename, fs(jj))
			            cd(retdir);
						close(fs(jj))
					end
				end
			elseif strcmpi(collateKey, 'loivsflick')
				close all hidden
				[result.stats, result.b, ~, result.rsq2, result.yfit, result.x,result.y] = sObj.fast_lickTimeVSLampOffInterval;
			elseif strcmpi(collateKey, 'getOperantTrials')
				target_s = obj.iv.n;
				disp(['pavlovian thresh=', num2str(target_s), 's'])

				result.operantTrials = find(sObj.GLM.flick_s_wrtc<target_s);
	            result.pavlovianTrials = [find(sObj.GLM.flick_s_wrtc>=target_s); find(isnan(sObj.GLM.flick_s_wrtc))];
				sObj.iv.exclusions_struct.Excluded_Trials = [sObj.iv.exclusions_struct.Excluded_Trials, result.pavlovianTrials];
                sObj.iv.excludedtrials_ = 'took pavlovian exclusions using obj = CLASS_STATcollate_photometry_roadmapv1_4(''getOperantTrials'',5)';
	            
                [f,ax]=makeStandardFigure(2,[2,1]);
                gca = ax(1);
                sObj.getBinnedTimeseries(sObj.GLM.gfit, 'custom', [0,700,1500,3000,5000,17000], 30000);
                sObj.plot('CLTA', [2:4], true, 100, 'last-to-first', 1)
                xlim([-1,5])
                title([sObj.iv.mousename_, ' ' sObj.iv.signalname, ' ' sObj.iv.daynum_, ' before'])
                
                sObj.redoExclusions();
                sObj.getflickswrtc(true);
                
                sObj.getBinnedTimeseries(sObj.GLM.gfit, 'custom', [0,700,1500,3000,5000,17000], 30000);
                gca = ax(2);
                sObj.plot('CLTA', [2:4], true, 100, 'last-to-first', 1)
                xlim([-1,5])
                title([sObj.iv.mousename_, ' ' sObj.iv.signalname, ' ' sObj.iv.daynum_, ' after'])
                
                try 
                    fileID = fopen('null_exclusions.txt','w');
                    fprintf(fileID,'pavlovian: %s',mat2str(result.pavlovianTrials))
                    fclose(fileID);
                    sObj.iv.PAVLOVIANSEXCLUDED=true;
                    sObj.save;
                catch ex
                    warning('failed to open exclusions file...make sure is named null_exclusions.txt')
                end
			elseif strcmpi(collateKey, 'stepvramp_julia')
				close all hidden
				%
				% 	The task is to first find the julia file and import this to our workspace...
				%
				% find the corresponding CSV folder for this animal:
				retdir = pwd;
				result.path = retdir;
				folderName = [sObj.iv.mousename_, '_', sObj.iv.signalname{1, 1}, '_', sObj.iv.daynum_];
				cd(obj.iv.CSV_folder)
				cd(folderName)
				% identify the most recent run of hierarchy program. n will be our runID
				if isempty(obj.iv.n)
					warning('No runID specified. Looking for most recent hierarchy_v1 folder...')
					obj.iv.n = 'hierarchy_v1';
				end
				dirs = dir;
				dirs = dirs(3:end);				
				ii = find(contains({dirs.name}, obj.iv.n));
				if numel(ii) > 1
					disp(['******Found multiple ', obj.iv.n, ' folders.'])
					candidatedirs = dirs(ii);
					datezzz = {candidatedirs.date};
					[s,ix]=sort(datezzz);
                    cns = {candidatedirs.name};
					model_dir = cns{ix(end)};
					disp(['selected: ', model_dir])
					disp(['options were: ', cell2mat(cns)])
					disp(cell2mat({candidatedirs.date}))
                else
                    cns = {dirs.name};
					model_dir = cns{ii};
				end
				cd(model_dir)
				% now find the most recent matlab file
				matfiles = dir('*.mat');
				if numel(matfiles) > 1
					disp('******Found multiple *.mat files here.')
					datezzz = {matfiles.date};
					[s,ix]=sort(datezzz);
                    mfn = {matfiles.name};
					matfile = mfn{ix(end)};
					disp(['selected: ', matfile])
					disp(['options were: ', cell2mat({matfiles.name})])
					disp(cell2mat({matfiles.date}))
				else
					matfile = matfiles.name;
				end
				load(matfile);
				% we have enough space to load all the models into the compilation object, so let's do that...
				result.amount_of_computation = amount_of_computation;
				result.flags = flags;
				result.intercepts = intercepts;
				result.left_segment = left_segment;
				result.lick_time = lick_time;
				result.modelID = modelID;
				result.ntraces_per_trial = ntraces_per_trial;
				result.p = p;
				result.right_segment = right_segment;
				result.sessionCode = sessionCode;
				result.slopes = slopes;
				if exist('step_time')
					result.step_time = step_time;
				else
					result.step_time = st;
				end
				result.tNo = tNo;
				result.trim_cue_s = trim_cue_s;
				result.trim_lick_s = trim_lick_s;

				% Process the data for the sObj...
				sObj.iv.suppressNsave.figuresHOST = obj.iv.suppressNsave.figuresHOST;
				result = fxn_pull_step_model_data(result, sObj);
				
 				% result.flick_s_wrtc = obj.GLM.flick_s_wrtc;
			  %   result.step_time_s_wrtc = step_time_s_wrtc;
			  %   result.pc_interval_step = pc_interval_step;
			  %   result.nbins = nbins;
			  %   result.binedges = binedges;
			  %   result.trials_per_bin = trials_per_bin;

			    % result.gfit_xl = xl;
			    % result.gfit_xr = xr;
			    % result.gfit_LHS = LHS;
			    % result.gfit_RHS = RHS;
			    % result.gfit_count_l = count_l;
			    % result.gfit_count_r = count_r;

			    % result.tdt_xl = []; 
			    % result.tdt_xr = [];
			    % result.tdt_LHS = [];
			    % result.tdt_RHS = [];
			    % result.tdt_count_l = [];
			    % result.tdt_count_r = [];

			    % result.emg_xl = [];
			    % result.emg_xr = [];
			    % result.emg_LHS = [];
			    % result.emg_RHS = [];
			    % result.emg_count_l = [];
			    % result.emg_count_r = [];
                cd(retdir)

			elseif strcmpi(collateKey, 'extract_trial_CSV')
				%
				% 	We will create a directory for the current file
				%
				mid = [sObj.iv.mousename_, '_', sObj.iv.signalname{1, 1}, '_', sObj.iv.daynum_];
				st_fname = correctPathOS(sObj,[obj.iv.CSV_folder, '/', mid, '/singletrial']);
				bl_fname = correctPathOS(sObj,[obj.iv.CSV_folder, '/', mid, '/baseline']);
				loi_fname = correctPathOS(sObj,[obj.iv.CSV_folder, '/', mid, '/LOI']);
				mkdir(st_fname)
				mkdir(bl_fname)
				mkdir(loi_fname)
				FXN_extract_CLTA_data_from_figure(sObj, 'singletrial', st_fname, 0)
				warning('Be sure to rewrite if you want timepoints BEYOND lick time. Right now only goes up to lick.')
				figureName = ['singletrial_example'];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, gcf());

				FXN_extract_CLTA_data_from_figure(sObj, 'baseline', bl_fname, 0)
				figureName = ['baseline_example'];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, gcf());

				FXN_extract_CLTA_data_from_figure(sObj, 'LOI', loi_fname, 0)
				figureName = ['LOI_example'];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, gcf());
				result = []

			elseif strcmpi(collateKey, 'prepXconditioning')
				% 
				% 	We have a lot of work to do... this will take up a lot of space, so writing out in a script
				% 
				analyzeHelper_prepXconditioning


			elseif strcmpi(collateKey, 'CLTAconditionNm1notRew')
				if strcmpi(sObj.iv.signaltype_, 'camera')
					smoothing = 3;
					spms = 0.03;
				elseif strcmpi(sObj.iv.signaltype_, 'EMG')
					smoothing = 30;
					spms = 2;
				elseif strcmpi(sObj.iv.signaltype_, 'Photometry')
					smoothing = 100;
					spms = 1;
				else
					smoothing = 30;
					spms = 2;
				end
				sObj.getflickswrtc;
				result.flick_s_wrtc = sObj.GLM.flick_s_wrtc;
				% 
				% 	Get trial indicies for all trials preceded by reward
				% 
				result.nm1rew.subsequentTrials = 1+find(result.flick_s_wrtc>=3.333);
				result.nm1norew.subsequentTrials = 1+find(result.flick_s_wrtc<3.333);
				if max(result.nm1rew.subsequentTrials) > numel(result.flick_s_wrtc), result.nm1rew.subsequentTrials(max(result.nm1rew.subsequentTrials)) = []; end
				if max(result.nm1norew.subsequentTrials) > numel(result.flick_s_wrtc), result.nm1norew.subsequentTrials(max(result.nm1norew.subsequentTrials)) = []; end
				% getBinnedTimeseries(obj, ts, Mode, nbins, timePad, trialsIncluded,
				% 
				% 	Handle condition | n-1 = no reward
				% 
				sObj.getBinnedTimeseries(sObj.GLM.gfit, 'singletrial', [], 30000, result.nm1norew.subsequentTrials);
				z = find(sObj.ts.Plot.CTA.xticks.s >=0, 1, 'first');
				idx = [round(z-spms*5000):1:z];
				result.nm1norew.licktimes = [sObj.ts.BinParams.s.CLTA_Min]';
				result.nm1norew.baselines = cell2mat(cellfun(@(x) nanmean(x(idx)), sObj.ts.BinnedData.CTA, 'uniformoutput',0))';
				% 
				% 	Handle condition | n-1 = reward
				% 
				sObj.getBinnedTimeseries(sObj.GLM.gfit, 'singletrial', [], 30000, result.nm1rew.subsequentTrials);
				z = find(sObj.ts.Plot.CTA.xticks.s >=0, 1, 'first');
				idx = [round(z-spms*5000):1:z];
				result.nm1rew.licktimes = [sObj.ts.BinParams.s.CLTA_Min]';
				result.nm1rew.baselines = cell2mat(cellfun(@(x) nanmean(x(idx)), sObj.ts.BinnedData.CTA, 'uniformoutput',0))';

				[result.nm1norew.b, ~, result.nm1norew.stat] = glmfit(result.nm1norew.licktimes, result.nm1norew.baselines);
				result.nm1norew.yfit = glmval(result.nm1norew.b,result.nm1norew.licktimes, 'identity');
				[result.nm1rew.b, ~, result.nm1rew.stat] = glmfit(result.nm1rew.licktimes, result.nm1rew.baselines);
				result.nm1rew.yfit = glmval(result.nm1rew.b,result.nm1rew.licktimes, 'identity');
				% 
				% 	plot baseline
				% 
				yy = [min(min(result.nm1norew.baselines),min(result.nm1rew.baselines)), max(max(result.nm1norew.baselines), max(result.nm1rew.baselines))];
				m = mean([result.nm1norew.baselines;result.nm1rew.baselines]);
				s = std([result.nm1norew.baselines;result.nm1rew.baselines]);
				xx = [min(min(result.nm1norew.licktimes),min(result.nm1rew.licktimes)), max(max(result.nm1norew.licktimes), max(result.nm1rew.licktimes))];
				[f,ax] = makeStandardFigure(2, [1,2]);
				plot(ax(1), xx, [m,m], 'k-')
				plot(ax(1), xx, [m,m]+s, 'r--')
				plot(ax(1), xx, [m,m]-s, 'r--')
				plot(ax(1), xx, [m,m]+2*s, 'r--')
				plot(ax(1), xx, [m,m]-2*s, 'r--')
				plot(ax(1), xx, [m,m]+3*s, 'r--')
				plot(ax(1), xx, [m,m]-3*s, 'r--')
				plot(ax(1),result.nm1norew.licktimes, result.nm1norew.baselines, '.', 'markersize', 20)
				plot(ax(1), result.nm1norew.licktimes,result.nm1norew.yfit, 'r-', 'linewidth', 3)
				title(ax(1), '| n-1 early')
				xlabel(ax(1), 'flick time (s)')
				ylabel(ax(1), 'mean 5s baseline')
				ylim(ax(1), yy)
				plot(ax(2),result.nm1rew.licktimes, result.nm1rew.baselines, '.', 'markersize', 20)
				plot(ax(2), result.nm1rew.licktimes,result.nm1rew.yfit, 'r-', 'linewidth', 3)
				title(ax(2), '| n-1 rewarded')
				xlabel(ax(2), 'flick time (s)')
				plot(ax(2), xx, [m,m], 'k-')
				plot(ax(2), xx, [m,m]+s, 'r--')
				plot(ax(2), xx, [m,m]-s, 'r--')
				plot(ax(2), xx, [m,m]+2*s, 'r--')
				plot(ax(2), xx, [m,m]-2*s, 'r--')
				plot(ax(2), xx, [m,m]+3*s, 'r--')
				plot(ax(2), xx, [m,m]-3*s, 'r--')
				ylim(ax(2), yy)
				figureName = ['conditionedBASELINE'];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, f);
				% 
				% 	Plot CLTA | n-1 rew
				% 
				sObj.getBinnedTimeseries(sObj.GLM.gfit, 'custom', [0,700,1000,1500,2000,2500,3333,3334,4500,7000,17000], 30000, result.nm1rew.subsequentTrials);
				f2 = sObj.plot('CLTA','all', false, smoothing, 'last-to-first', 1)
				xticks([-5:1:5])
				title([sObj.iv.mousename_ ' ' sObj.iv.daynum_ ' | n-1th rewarded, ' num2str(smoothing) 'smsamp'])
				xlim([-5,5])
				figureName = ['conditionNm1REWARDED'];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, f2);
				% 
				% 	Plot CLTA | n-1 no rew
				% 
				sObj.getBinnedTimeseries(sObj.GLM.gfit, 'custom', [0,700,1000,1500,2000,2500,3333,3334,4500,7000,17000], 30000, result.nm1norew.subsequentTrials);
				f2 = sObj.plot('CLTA', 'all', false, smoothing, 'last-to-first', 1)
				xticks([-5:1:5])
				title([sObj.iv.mousename_ ' ' sObj.iv.daynum_ ' |n-1th NOT rewarded, ' num2str(smoothing) 'smsamp'])
				xlim([-5,5])
				figureName = ['conditionNm1NOreward'];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, f2);
				result.nm1rew;
				result.nm1norew;
			elseif strcmpi(collateKey, 'nTrialsWithFLick')
				sObj.getflickswrtc;
				result.nFLicks = numel(sObj.GLM.fLick_trial_num);
				result.flick_s_wrtc = sObj.GLM.flick_s_wrtc;
			elseif strcmpi(collateKey, 'singleTrialFigures')	
				sObj.singleTrialFigures([2,7],200, obj.iv.suppressNsave.singleTrialFigures);
				result = [];
			elseif strcmpi(collateKey, 'plotPartition')	
				close all hidden
				sObj.plotHistogram(obj.iv.n,'flick-partition');
				result = [];
				%  get all figures and suppress and save each
				obj_h = findobj();
				t = get(obj_h,'Type');
				ff = obj_h(contains(t, 'figure'));
				figureName = ['Hxg_partitioned'];
				set(ff(1), 'userdata', ['obj = CLASS_STATcollate_photometry_roadmapv1_4(''plotPartition'', ' num2str(obj.iv.n) ')'])
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, ff(1));
				pidxs = fliplr(1:obj.iv.n);
				for ii = 2:numel(ff)
					pnum = pidxs(ii-1);
					sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, gcf);
					figureName = ['Partition' num2str(pnum) '_CLTA'];
					set(ff(ii), 'userdata', ['obj = CLASS_STATcollate_photometry_roadmapv1_4(''plotPartition'', ' num2str(obj.iv.n) ')'])
                    sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, ff(ii));					
				end
			elseif strcmpi(collateKey, 'rawF')	
				error('Not implemented. Please use the Xconditioning collated file with the createCompositeBinnedDataObj functions')
				close all hidden
				result = [];
				rawFhelper
				
			elseif strcmpi(collateKey, 'movectrlcustom')
				sObj.getBinnedTimeseries(sObj.GLM.gfit, 'custom', [0,2000,3333,3334,7000,17000], 30000);
				if strcmpi(sObj.iv.signaltype_, 'camera')
					smoothing = 3;
				elseif strcmpi(sObj.iv.signaltype_, 'EMG')
					smoothing = 30;
				elseif strcmpi(sObj.iv.signaltype_, 'Photometry')
					smoothing = 100;
				else
					smoothing = 30;
				end
				sObj.plot('LTA2l', [2,4], false, smoothing, 'last-to-first', 1)
				result = [];
				xticks([-5:1:5])
				title([sObj.iv.mousename_ ' ' sObj.iv.daynum_ ' ' num2str(smoothing) 'smsamp'])
				xlim([-5,5])
				figureName = ['MoveCtrl_LTA2l'];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, gcf);
			elseif strcmpi(collateKey, 'movectrltimes')
				sObj.getBinnedTimeseries(sObj.GLM.gfit, 'times', 34, 30000);
				if strcmpi(sObj.iv.signaltype_, 'camera')
					smoothing = 3;
				elseif strcmpi(sObj.iv.signaltype_, 'EMG')
					smoothing = 30;
				elseif strcmpi(sObj.iv.signaltype_, 'Photometry')
					smoothing = 100;
				else
					smoothing = 30;
				end
				sObj.plot('LTA2l', [1:14], false, smoothing, 'last-to-first', 1)
				result = [];
				xticks([-5:1:5])
				title([sObj.iv.mousename_ ' ' sObj.iv.daynum_ ' ' num2str(smoothing) 'smsamp'])
				xlim([-1,1])
				figureName = ['MoveCtrl_LTA2l_sm', num2str(smoothing)];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, gcf);
				sObj.plot('LTA2l', [1:14], false, 0, 'last-to-first', 1)
				result = [];
				xticks([-5:1:5])
				title([sObj.iv.mousename_ ' ' sObj.iv.daynum_ ' ' num2str(0) 'smsamp'])
				xlim([-1,1])
				figureName = ['MoveCtrl_LTA2l_sm', num2str(0)];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, gcf);
			elseif strcmpi(collateKey, 'movectrltrials')
				sObj.getBinnedTimeseries(sObj.GLM.gfit, 'trials', 30, 30000);
				if strcmpi(sObj.iv.signaltype_, 'camera')
					smoothing = 3;
				elseif strcmpi(sObj.iv.signaltype_, 'EMG')
					smoothing = 30;
				elseif strcmpi(sObj.iv.signaltype_, 'Photometry')
					smoothing = 100;
				else
					smoothing = 30;
				end
				sObj.plot('LTA2l', 1:numel(sObj.ts.BinnedData.LTA)-1, false, smoothing, 'first-to-last', 1)
				set(gca, 'fontsize', 10)
				result = [];
				xticks([-5:.1:5])
				title([sObj.iv.mousename_ ' ' sObj.iv.daynum_ ' ' num2str(smoothing) 'smsamp'])
				xlim([-0.5,0])
				figureName = ['MoveCtrl_LTA2l_sm', num2str(smoothing)];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, gcf);
				sObj.plot('LTA2l', 1:numel(sObj.ts.BinnedData.LTA)-1, false, 0, 'first-to-last', 1)
				set(gca, 'fontsize', 10)
				result = [];
				xticks([-5:.1:5])
				title([sObj.iv.mousename_ ' ' sObj.iv.daynum_ ' ' num2str(0) 'smsamp'])
				xlim([-0.5,0])
				figureName = ['MoveCtrl_LTA2l_sm', num2str(0)];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, gcf);
			elseif strcmpi(collateKey, 'movectrlall')
				sObj.getBinnedTimeseries(sObj.GLM.gfit, 'singletrial', [], 30000);
				if strcmpi(sObj.iv.signaltype_, 'camera')
					smoothing = 3;
				elseif strcmpi(sObj.iv.signaltype_, 'EMG')
					smoothing = 0;
				elseif strcmpi(sObj.iv.signaltype_, 'Photometry')
					smoothing = 100;
				else
					smoothing = 30;
				end
				sObj.plot('LTA2l', 'all', false, smoothing, 'last-to-first', 1)
				result = [];
				xticks([-5:1:5])
				title([sObj.iv.mousename_ ' ' sObj.iv.daynum_ ' ' num2str(smoothing) 'smsamp'])
				xlim([-1,1])
				figureName = ['MoveCtrl_LTA2l_sm', num2str(smoothing)];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, gcf);
				sObj.plot('LTA2l', [1:14], false, 0, 'last-to-first', 1)
			elseif strcmpi(collateKey, 'tof')
				sObj.TOF_LTApeakAmp(false);
				figureName = ['tof_' sObj.iv.mousename_ '_' sObj.iv.daynum_ '_' sObj.iv.signalname{1, 1}];
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, figureName, gcf);
				result = sObj.ts.LTA_TOF.GLM;
			elseif strcmpi(obj.iv.collateKey,'singleTrialOutliers') 
				lickTimeRange = [0,7];
				redoExclusions = true;
				stdmultiplier = 2;
				outlierTimeRange = [-1.5,7];
				sObj.singleTrialOutliers(lickTimeRange, redoExclusions,stdmultiplier,outlierTimeRange,obj.iv.decodeFigureHOSTfolder)
				save('sObj_Corrected.mat', 'sObj', '-v7.3');
				result = [];
			elseif strcmpi(collateKey, 'divergenceIndex')
				sObj.bootOutcomeDivergenceIndex(1000000, 100, 'all')
				sObj.plotDivergenceIndicies(obj.iv.suppressNsave.figuresHOST)
				if ~isfield(sObj.GLM,'flick_s_wrtc')
		            sObj.GLM.flick_s_wrtc = nan(size(sObj.GLM.cue_s));
					sObj.GLM.flick_s_wrtc(sObj.GLM.fLick_trial_num) = sObj.GLM.firstLick_s - sObj.GLM.cue_s(sObj.GLM.fLick_trial_num);
				end
				result.flick_s_wrtc = sObj.GLM.flick_s_wrtc;
				result.Stat = sObj.Stat;
			elseif strcmpi(collateKey, 'PCAcollateSummary')
				sObj.interpolateForPCA;
				sObj.modelDatasetWithPCA(1:3);
				sObj.plotPCA('summary',[],[],[],obj.iv.suppressNsave.figuresHOST)
				if ~isfield(sObj.GLM,'flick_s_wrtc')
		            sObj.GLM.flick_s_wrtc = nan(size(sObj.GLM.cue_s));
					sObj.GLM.flick_s_wrtc(sObj.GLM.fLick_trial_num) = sObj.GLM.firstLick_s - sObj.GLM.cue_s(sObj.GLM.fLick_trial_num);
				end
				result.flick_s_wrtc = sObj.GLM.flick_s_wrtc;
				result.PCA = sObj.GLM.PCA;
				
			elseif strcmpi(collateKey, 'PCAdecoding')
				warning('off','stats:glmfit:IllConditioned');
				% 
				% 	Run PCA analysis
				% 
				sObj.interpolateForPCA;
				sObj.modelDatasetWithPCA(1:3);
				sObj.plotPCA('summary',[],[],[],obj.iv.suppressNsave.PCAsummary)
				if ~isempty(sObj.GLM.PCA.trialidx)
					sObj.plotPCA('testfit', sObj.GLM.PCA.trialidx(1),[],[],obj.iv.suppressNsave.PCAtestfit)
					if numel(sObj.GLM.PCA.trialidx) >= 10
						sObj.plotPCA('testfit', sObj.GLM.PCA.trialidx(10),[],[],obj.iv.suppressNsave.PCAtestfit)
					else
						warning('Found fewer than 10 trials passing PCA critera...')
						nmax = numel(sObj.GLM.PCA.trialidx);
						sObj.plotPCA('testfit', sObj.GLM.PCA.trialidx(nmax),[],[],obj.iv.suppressNsave.PCAtestfit)
					end
					if numel(sObj.GLM.PCA.trialidx) >= 100
						sObj.plotPCA('testfit', sObj.GLM.PCA.trialidx(100),[],[],obj.iv.suppressNsave.PCAtestfit)
					else
						warning('Found fewer than 100 trials passing PCA critera...')
						nmax = numel(sObj.GLM.PCA.trialidx);
						sObj.plotPCA('testfit', sObj.GLM.PCA.trialidx(nmax),[],[],obj.iv.suppressNsave.PCAtestfit)
					end
				else
					warning('Found NO trials passing criteria for PCA analysis. sObj.GLM.PCA.trialidx is empty')
				end
				sObj.plotPCA('wtVsLickTime',[],[],[],obj.iv.suppressNsave.PCAwtVsLickTime)
				sObj.plotPCA('Xfit', 'all',[],[],obj.iv.suppressNsave.PCAXfitAll)
				sObj.plotPCA('Xfit', [1:10:numel(sObj.GLM.cue_s)],[],[],obj.iv.suppressNsave.PCAXfitSelected)
				sObj.binPCAfit('times', 7)
                sObj.plotPCA('Xfitbinned',[1:7],[1:3],[],obj.iv.suppressNsave.Xfitbinned)
% 				sObj.plotPCA('Xfitbinned',[1:7],[],[],obj.iv.suppressNsave.Xfitbinned)
				sObj.PCAmeanSlope(1:3, true, obj.iv.suppressNsave.PCAmeanSlope);
				result.PCA = sObj.GLM.PCA;
				% 
				% 	Run decoding models
				% 
				sObj.Nested_GLM_predictLickTime(1:8, 'ht', false)
				result.decoding.ht = sObj.GLM.decoding;
				result.decoding.ht_raw = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:8, obj.iv.suppressNsave.ht);
				sObj.plotDecodingModelResults('fit',1:8, obj.iv.suppressNsave.ht);

				sObj.Nested_GLM_predictLickTime(1:8, 'htPCA', false)
				result.decoding.htPCA = sObj.GLM.decoding;
				result.decoding.ht_PCA = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:8, obj.iv.suppressNsave.htPCA);
				sObj.plotDecodingModelResults('fit',1:8, obj.iv.suppressNsave.htPCA);

				sObj.Nested_GLM_predictLickTime(1:8, 'PC1-3', false)
				result.decoding.PC1_3 = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:8, obj.iv.suppressNsave.PC1_3);
				sObj.plotDecodingModelResults('fit',1:8, obj.iv.suppressNsave.PC1_3);

				sObj.Nested_GLM_predictLickTime(1:11, 'PC1-3htPCA', false)
				result.decoding.PC1_3htPCA = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:11, obj.iv.suppressNsave.PC1_3htPCA);
				sObj.plotDecodingModelResults('fit',1:11, obj.iv.suppressNsave.PC1_3htPCA);

				sObj.Nested_GLM_predictLickTime(1:6, 'mislope', false)
				result.decoding.mislope = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:6, obj.iv.suppressNsave.mislope);
				sObj.plotDecodingModelResults('fit',1:6, obj.iv.suppressNsave.mislope);

				sObj.Nested_GLM_predictLickTime(1:8, 'htPCA-stiff', false)
				result.decoding.htPCA_stiff = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:8, obj.iv.suppressNsave.htPCA_stiff);
				sObj.plotDecodingModelResults('fit',1:8, obj.iv.suppressNsave.htPCA_stiff);

				sObj.Nested_GLM_predictLickTime(1:10, 'pretrial_tdtht_1htstiff_PCAversion', false)
				result.decoding.PCA_ht_1_Stiff = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:10, obj.iv.suppressNsave.PCA_ht_1_Stiff);
				sObj.plotDecodingModelResults('fit',1:10, obj.iv.suppressNsave.PCA_ht_1_Stiff);

				

				if ~isfield(sObj.GLM,'flick_s_wrtc')
		            sObj.GLM.flick_s_wrtc = nan(size(sObj.GLM.cue_s));
					sObj.GLM.flick_s_wrtc(sObj.GLM.fLick_trial_num) = sObj.GLM.firstLick_s - sObj.GLM.cue_s(sObj.GLM.fLick_trial_num);
				end
				result.flick_s_wrtc = sObj.GLM.flick_s_wrtc;

				warning('on','stats:glmfit:IllConditioned');	

			elseif strcmpi(collateKey, 'DecodingPaperFinal')
				warning('off','stats:glmfit:IllConditioned');
				disp('-----pretrial_tdtht_1htstiff')
				% 1 stiff tdt, 1 stiff gcamp
				n = 10;
				sObj.Nested_GLM_predictLickTime(1:n, 'pretrial_tdtht_1htstiff', false)
				result.decoding.ht_stiff_ea = sObj.GLM.decoding;
				if isfield(sObj.GLM.decoding,'flagNoRed')
					result.flagNoRed = sObj.GLM.decoding.flagNoRed;
				else
					result.flagNoRed = false;
				end
				sObj.plotDecodingModelResults('summary',1:n, obj.iv.suppressNsave.ht_stiff_ea);
				sObj.plotDecodingModelResults('fit',1:n, obj.iv.suppressNsave.ht_stiff_ea);
				disp('-----pretrial_tdtht_multiHTstiff')
				% 3 stiff tdt, 3 stiff gcamp
				n = 14;
				sObj.Nested_GLM_predictLickTime(1:n, 'pretrial_tdtht_multiHTstiff', false)
				result.decoding.multiht_stiff_ea = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:n, obj.iv.suppressNsave.multiht_stiff_ea);
				sObj.plotDecodingModelResults('fit',1:n, obj.iv.suppressNsave.multiht_stiff_ea);
				disp('-----pretrial_tdtht_PC1-3')
				% 1 stiff tdt, 3PC |weights|
				n = 12;
				sObj.Nested_GLM_predictLickTime(1:n, 'pretrial_tdtht_PC1-3', false)
				result.decoding.PC1_3_1httdtstiff = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:n, obj.iv.suppressNsave.PC1_3_1httdtstiff);
				sObj.plotDecodingModelResults('fit',1:n, obj.iv.suppressNsave.PC1_3_1httdtstiff);
				disp('-----pretrial_tdtht_1htstiff_PCAversion')
				% 1 stiff tdt(not pca), 1stiffPCgcamp
				n = 10;
				sObj.Nested_GLM_predictLickTime(1:n, 'pretrial_tdtht_1htstiff_PCAversion', false)
				result.decoding.htPCAstiff_1tdtstiff = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:n, obj.iv.suppressNsave.htPCAstiff_1tdtstiff);
				sObj.plotDecodingModelResults('fit',1:n, obj.iv.suppressNsave.htPCAstiff_1tdtstiff);
				disp('-----pretrial_tdtht_multiHTstiffPCA')
				% 3 stiff tdt(not pca), 3stiffPCgcamp
				n = 14;
				sObj.Nested_GLM_predictLickTime(1:n, 'pretrial_tdtht_multiHTstiffPCA', false)
				result.decoding.multihtPCAstiff_multitdtstiff = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:n, obj.iv.suppressNsave.multihtPCAstiff_multitdtstiff);
				sObj.plotDecodingModelResults('fit',1:n, obj.iv.suppressNsave.multihtPCAstiff_multitdtstiff);

				if ~isfield(sObj.GLM,'flick_s_wrtc')
		            sObj.GLM.flick_s_wrtc = nan(size(sObj.GLM.cue_s));
					sObj.GLM.flick_s_wrtc(sObj.GLM.fLick_trial_num) = sObj.GLM.firstLick_s - sObj.GLM.cue_s(sObj.GLM.fLick_trial_num);
				end
				result.flick_s_wrtc = sObj.GLM.flick_s_wrtc;
				disp('-----pretrial_PCAtdtht_multiHTstiffPCA')
				% 3 stiff tdt-PCA, 3stiffPCgcamp
				if ~result.flagNoRed
					n = 14;
					sObj.Nested_GLM_predictLickTime(1:14, 'pretrial_PCAtdtht_multiHTstiffPCA', false)
					result.decoding.multihtPCAstiff_multiPCAtdtstiff = sObj.GLM.decoding;
					sObj.plotDecodingModelResults('summary',1:n, obj.iv.suppressNsave.multihtPCAstiff_multiPCAtdtstiff);
					sObj.plotDecodingModelResults('fit',1:n, obj.iv.suppressNsave.multihtPCAstiff_multiPCAtdtstiff);
					disp('-----Done.')
				else
					result.decoding.multihtPCAstiff_multiPCAtdtstiff = [];
				end

			elseif strcmpi(obj.iv.collateKey,'1ht_stiff_ea')
				warning('off','stats:glmfit:IllConditioned');
				disp('-----pretrial_tdtht_1htstiff')
				% 1 stiff tdt, 1 stiff gcamp
				n = 10;
				sObj.Nested_GLM_predictLickTime(1:n, 'pretrial_tdtht_1htstiff', false)
				result.decoding.ht_stiff_ea = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:n, obj.iv.suppressNsave.ht_stiff_ea);
				sObj.plotDecodingModelResults('fit',1:n, obj.iv.suppressNsave.ht_stiff_ea);
				if ~isfield(sObj.GLM,'flick_s_wrtc')
		            sObj.GLM.flick_s_wrtc = nan(size(sObj.GLM.cue_s));
					sObj.GLM.flick_s_wrtc(sObj.GLM.fLick_trial_num) = sObj.GLM.firstLick_s - sObj.GLM.cue_s(sObj.GLM.fLick_trial_num);
				end
				result.flick_s_wrtc = sObj.GLM.flick_s_wrtc;
				if isfield(sObj.GLM.decoding,'flagNoRed')
					result.flagNoRed = sObj.GLM.decoding.flagNoRed;
				else
					result.flagNoRed = false;
				end
			elseif strcmpi(obj.iv.collateKey,'multiht_stiff_ea')
				warning('off','stats:glmfit:IllConditioned');
				disp('-----pretrial_tdtht_multiHTstiff')
				% 3 stiff tdt, 3 stiff gcamp
				n = 14;
				sObj.Nested_GLM_predictLickTime(1:n, 'pretrial_tdtht_multiHTstiff', false)
				result.decoding.multiht_stiff_ea = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:n, obj.iv.suppressNsave.multiht_stiff_ea);
				sObj.plotDecodingModelResults('fit',1:n, obj.iv.suppressNsave.multiht_stiff_ea);
				if ~isfield(sObj.GLM,'flick_s_wrtc')
		            sObj.GLM.flick_s_wrtc = nan(size(sObj.GLM.cue_s));
					sObj.GLM.flick_s_wrtc(sObj.GLM.fLick_trial_num) = sObj.GLM.firstLick_s - sObj.GLM.cue_s(sObj.GLM.fLick_trial_num);
				end
				result.flick_s_wrtc = sObj.GLM.flick_s_wrtc;
				if isfield(sObj.GLM.decoding,'flagNoRed')
					result.flagNoRed = sObj.GLM.decoding.flagNoRed;
				else
					result.flagNoRed = false;
				end
			elseif strcmpi(obj.iv.collateKey,'PC1_3_1httdtstiff')
				warning('off','stats:glmfit:IllConditioned');
				disp('-----pretrial_tdtht_PC1-3')
				% 1 stiff tdt, 3PC |weights|
				n = 12;
				sObj.Nested_GLM_predictLickTime(1:n, 'pretrial_tdtht_PC1-3', false)
				result.decoding.PC1_3_1httdtstiff = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:n, obj.iv.suppressNsave.PC1_3_1httdtstiff);
				sObj.plotDecodingModelResults('fit',1:n, obj.iv.suppressNsave.PC1_3_1httdtstiff);
				if ~isfield(sObj.GLM,'flick_s_wrtc')
		            sObj.GLM.flick_s_wrtc = nan(size(sObj.GLM.cue_s));
					sObj.GLM.flick_s_wrtc(sObj.GLM.fLick_trial_num) = sObj.GLM.firstLick_s - sObj.GLM.cue_s(sObj.GLM.fLick_trial_num);
				end
				result.flick_s_wrtc = sObj.GLM.flick_s_wrtc;
				if isfield(sObj.GLM.decoding,'flagNoRed')
					result.flagNoRed = sObj.GLM.decoding.flagNoRed;
				else
					result.flagNoRed = false;
				end
			elseif strcmpi(obj.iv.collateKey,'1htPCAstiff_1tdtstiff')
				warning('off','stats:glmfit:IllConditioned');
				disp('-----pretrial_tdtht_1htstiff_PCAversion')
				% 1 stiff tdt(not pca), 1stiffPCgcamp
				n = 10;
				sObj.Nested_GLM_predictLickTime(1:n, 'pretrial_tdtht_1htstiff_PCAversion', false)
				result.decoding.htPCAstiff_1tdtstiff = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:n, obj.iv.suppressNsave.htPCAstiff_1tdtstiff);
				sObj.plotDecodingModelResults('fit',1:n, obj.iv.suppressNsave.htPCAstiff_1tdtstiff);
				if ~isfield(sObj.GLM,'flick_s_wrtc')
		            sObj.GLM.flick_s_wrtc = nan(size(sObj.GLM.cue_s));
					sObj.GLM.flick_s_wrtc(sObj.GLM.fLick_trial_num) = sObj.GLM.firstLick_s - sObj.GLM.cue_s(sObj.GLM.fLick_trial_num);
				end
				result.flick_s_wrtc = sObj.GLM.flick_s_wrtc;
				if isfield(sObj.GLM.decoding,'flagNoRed')
					result.flagNoRed = sObj.GLM.decoding.flagNoRed;
				else
					result.flagNoRed = false;
				end
			elseif strcmpi(obj.iv.collateKey,'multihtPCAstiff_multitdtstiff')
				warning('off','stats:glmfit:IllConditioned');
				disp('-----pretrial_tdtht_multiHTstiffPCA')
				% 3 stiff tdt(not pca), 3stiffPCgcamp
				n = 14;
				sObj.Nested_GLM_predictLickTime(1:n, 'pretrial_tdtht_multiHTstiffPCA', false)
				result.decoding.multihtPCAstiff_multitdtstiff = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:n, obj.iv.suppressNsave.multihtPCAstiff_multitdtstiff);
				sObj.plotDecodingModelResults('fit',1:n, obj.iv.suppressNsave.multihtPCAstiff_multitdtstiff);
				if ~isfield(sObj.GLM,'flick_s_wrtc')
		            sObj.GLM.flick_s_wrtc = nan(size(sObj.GLM.cue_s));
					sObj.GLM.flick_s_wrtc(sObj.GLM.fLick_trial_num) = sObj.GLM.firstLick_s - sObj.GLM.cue_s(sObj.GLM.fLick_trial_num);
				end
				result.flick_s_wrtc = sObj.GLM.flick_s_wrtc;
				if isfield(sObj.GLM.decoding,'flagNoRed')
					result.flagNoRed = sObj.GLM.decoding.flagNoRed;
				else
					result.flagNoRed = false;
				end
			elseif strcmpi(obj.iv.collateKey,'multihtPCAstiff_multiPCAtdtstiff') 
				warning('off','stats:glmfit:IllConditioned');
				if ~isfield(sObj.GLM, 'tdt')
					errorflag = sObj.addtdt(false);
                    if ~errorflag
                        sObj.GLM.decoding.flagNoRed = false;
                        result.flagNoRed = false;
                    else
                        sObj.GLM.decoding.flagNoRed = true;
                        result.flagNoRed = true;
                    end
                else
                	result.flagNoRed = false;
                end
				disp('-----pretrial_PCAtdtht_multiHTstiffPCA')
				% 3 stiff tdt-PCA, 3stiffPCgcamp
				if ~result.flagNoRed
					n = 14;
					sObj.Nested_GLM_predictLickTime(1:14, 'pretrial_PCAtdtht_multiHTstiffPCA', false)
					result.decoding.multihtPCAstiff_multiPCAtdtstiff = sObj.GLM.decoding;
					sObj.plotDecodingModelResults('summary',1:n, obj.iv.suppressNsave.multihtPCAstiff_multiPCAtdtstiff);
					sObj.plotDecodingModelResults('fit',1:n, obj.iv.suppressNsave.multihtPCAstiff_multiPCAtdtstiff);
					disp('-----Done.')
				else
					result.decoding.multihtPCAstiff_multiPCAtdtstiff = [];
				end
				if ~isfield(sObj.GLM,'flick_s_wrtc')
		            sObj.GLM.flick_s_wrtc = nan(size(sObj.GLM.cue_s));
					sObj.GLM.flick_s_wrtc(sObj.GLM.fLick_trial_num) = sObj.GLM.firstLick_s - sObj.GLM.cue_s(sObj.GLM.fLick_trial_num);
				end
				result.flick_s_wrtc = sObj.GLM.flick_s_wrtc;
				

			elseif strcmpi(collateKey, 'htStiff')
				warning('off','stats:glmfit:IllConditioned');
				sObj.Nested_GLM_predictLickTime(1:8, 'ht-stiff', false)
				result.decoding.ht_stiff = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:8, obj.iv.suppressNsave.ht_stiff);
				sObj.plotDecodingModelResults('fit',1:8, obj.iv.suppressNsave.ht_stiff);

				if ~isfield(sObj.GLM,'flick_s_wrtc')
		            sObj.GLM.flick_s_wrtc = nan(size(sObj.GLM.cue_s));
					sObj.GLM.flick_s_wrtc(sObj.GLM.fLick_trial_num) = sObj.GLM.firstLick_s - sObj.GLM.cue_s(sObj.GLM.fLick_trial_num);
				end
				result.flick_s_wrtc = sObj.GLM.flick_s_wrtc;
				warning('on','stats:glmfit:IllConditioned');	
			elseif strcmpi(collateKey, 'ht_1_Stiff')
				warning('off','stats:glmfit:IllConditioned');
				sObj.Nested_GLM_predictLickTime(1:10, 'pretrial_tdtht_1htstiff', false)
				result.decoding.ht_stiff = sObj.GLM.decoding;
				sObj.plotDecodingModelResults('summary',1:10, obj.iv.suppressNsave.ht_stiff);
				sObj.plotDecodingModelResults('fit',1:10, obj.iv.suppressNsave.ht_stiff);

				if ~isfield(sObj.GLM,'flick_s_wrtc')
		            sObj.GLM.flick_s_wrtc = nan(size(sObj.GLM.cue_s));
					sObj.GLM.flick_s_wrtc(sObj.GLM.fLick_trial_num) = sObj.GLM.firstLick_s - sObj.GLM.cue_s(sObj.GLM.fLick_trial_num);
				end
				result.flick_s_wrtc = sObj.GLM.flick_s_wrtc;
				warning('on','stats:glmfit:IllConditioned');

			elseif strcmpi(collateKey, 'ht')
				warning('off','stats:glmfit:IllConditioned');
				% 
				%	 obj.horizontalThreshold(Mode = LTA2l or CTA2l, bins = ‘all’, nthresh, delay, direction = ‘+’ (upward crossing), Plot)
				% 
				result = sObj.runHorizontalThresholdCollate(20, obj.iv.runID);
				warning('on','stats:glmfit:IllConditioned');
			elseif strcmpi(collateKey, 'vt')
				warning('off','stats:glmfit:IllConditioned');
				% 
				%	 
				% 
				result = sObj.runVerticalThresholdCollate(70, [-10000:100:7000], obj.iv.runID);
				result.thresholds =[-10000:100:7000];
				warning('on','stats:glmfit:IllConditioned');
			elseif strcmpi(collateKey, 'baselineANOVAidx')
				if ~isfield(sObj.gFitLP, 'nMultibDFF')
					if ~isfield(sObj.GLM, 'rawF')
						sObj.loadRawF;
					end
					sObj.normalizedMultiBaselineDFF(5000, 10, sObj.GLM.rawF);
					save('sObj_Corrected.mat', 'sObj', '-v7.3');
				end
				[result.results, result.F_nm1, result.F_n, result.nm1Score, result.nScore, result.sig_nm1, result.sig_n, result.centers,result.baselineWindow] = sObj.slidingBaselineANOVA('off',false);
			elseif strcmpi(collateKey, 'baselineANOVAwithLick')
				if ~isfield(sObj.gFitLP, 'nMultibDFF')
					if ~isfield(sObj.GLM, 'rawF')
						sObj.loadRawF;
					end
					sObj.normalizedMultiBaselineDFF(5000, 10, sObj.GLM.rawF);
					save('sObj_Corrected.mat', 'sObj', '-v7.3');
				end
				[result.results, result.F_nm1, result.F_n, result.nm1Score, result.nScore, result.sig_nm1, result.sig_n, result.centers,result.baselineWindow] = sObj.slidingBaselineANOVA('include',false);
			elseif strcmpi(collateKey, 'rim')
				result.f = sObj.RIMSummary(sObj.iv.mousename_, sObj.iv.daynum_, sObj.iv.Style);
			else
				error('undefined canned analysis')
			end
			warning('on','stats:glmfit:IllConditioned');
		end



		function ax = plot(obj, Mode, MouseID)
			% 
			% 	Mode options:
			%		Collate Key: cdf
			% 			cdf (3,5 distinguishment)
			% 			cdf-NHl
			% 			hxg (3,5 distinguishment)
			% 			hxg-xsesh (3,5 distinguishment)
            % 			hxg-xsesh-NHL (3,5 distinguishment)
			% 			cdf-xsesh
			% 			hxg-NHL 
			% 
			if nargin < 2
				if strcmpi(obj.iv.collateKey, 'cdf')
					Mode = 'cdf';
				else
					Mode = [];
				end
			end
			if nargin < 3
				MouseID =[];
			end
			if ~isempty(MouseID)
				idxs = contains({obj.collatedResults.sessionID}, MouseID);
			else
				idxs = 1:numel({obj.collatedResults.sessionID});
			end
					
			f = figure;
			if strcmpi(obj.iv.collateKey, 'cdf')
				if strcmpi(Mode, 'cdf') || strcmpi(Mode, 'cdf-NHL')
					rb_s = nan(numel({obj.collatedResults.sessionID}),1);
					rb_s(cellfun(@(x) ~isempty(x), {obj.collatedResults.rb_s})) = [obj.collatedResults.rb_s];
					if strcmpi(Mode, 'cdf-NHL')
						nhlidx = contains({obj.collatedResults.sessionID}, 'NHL');
						rb_s(nhlidx) = -3;
					end
					% 
					% 	Plot cdfs overlaid
					% 
					ax = subplot(1,1,1, 'parent', f);
					hold(ax, 'on');
					xlim(ax, [0, 17]);
					plot(ax, [7, 7], [0, 1],'r-', 'DisplayName', 'ITI Start-3.33 s task')
					title(ax, ['eCDF of First Licks wrt cue ' MouseID])
					for iSet = 1:numel({obj.collatedResults.sessionID})
						if idxs(iSet) == 0
							continue
						end
						if round(rb_s(iSet)) == 3
							pc = 'r-';
						elseif round(rb_s(iSet)) == -3
							pc = 'k-';
							xlim(ax, [0, 17]);
							title(ax, ['eCDF fLicks red=normal, black=NHL ' MouseID])
						elseif round(rb_s(iSet)) == 5
							pc = 'b-';
							xlim(ax, [0, 20]);
							plot(ax, [10, 10], [0, 1],'b-', 'DisplayName', 'ITI Start-5 s task')
						else
							pc = 'm-';
							warning(['undefined reward bound at ' obj.collatedResults(iSet).sessionID])
						end
						plot(ax, obj.collatedResults(iSet).ecdf_x, obj.collatedResults(iSet).ecdf_f, pc, 'displayname', obj.collatedResults(iSet).sessionID)
					end
					
					ylim(ax, [0,1])
					ax.XLabel.String = 'First Lick Time (s wrt cue)';
					ax.YLabel.String = '% of responses in session';
				elseif strcmpi(Mode, 'hxg') || strcmpi(Mode, 'hxg-NHL') || strcmpi(Mode, 'hxg-xsesh') || strcmpi(Mode, 'cdf-xsesh') || strcmpi(Mode, 'hxg-xsesh-NHL')|| strcmpi(Mode, 'cdf-xsesh-NHL') 
					rb_s = nan(numel({obj.collatedResults.sessionID}),1);
					rb_s(cellfun(@(x) ~isempty(x), {obj.collatedResults.rb_s})) = [obj.collatedResults.rb_s];
					if strcmpi(Mode, 'hxg-NHL') || strcmpi(Mode, 'hxg-xsesh-NHL')|| strcmpi(Mode, 'cdf-xsesh-NHL')
						nhlidx = contains({obj.collatedResults.sessionID}, 'NHL');
						rb_s(nhlidx) = -3;
					end
					% 
					% 	Plot hxgs overlaid
					% 
					yy = [0,0];
					ax = subplot(1,1,1, 'parent', f);
					hold(ax, 'on');
					xlim(ax, [0, 7.01]);
					title(ax, ['Normalized First Licks, omitting exclusions' MouseID])
					allTimes_33 = {};
					allTimes_5 = {};
					for iSet = 1:numel({obj.collatedResults.sessionID})
						if idxs(iSet) == 0
							continue
						end
						if round(rb_s(iSet)) == 3
							pc = 'r';
						elseif round(rb_s(iSet)) == -3
							pc = 'k';
							title(ax, ['Normalized First Licks, omitting exclusions, red=normal, black=NHL' MouseID])
						elseif round(rb_s(iSet)) == 5
							pc = 'b';
							xlim(ax, [0, 10.01]);
						else
							pc = 'm';
							warning(['undefined reward bound at ' obj.collatedResults(iSet).sessionID])
						end
						if ~strcmpi(Mode, 'hxg-xsesh') && ~strcmpi(Mode, 'cdf-xsesh') && ~strcmpi(Mode, 'hxg-xsesh-NHL')&& ~strcmpi(Mode, 'cdf-xsesh-NHL') 
							histogram(ax, obj.collatedResults(iSet).f_lick_ex_s_ecdf(obj.collatedResults(iSet).f_lick_ex_s_ecdf>0), [0:0.25:20], 'displaystyle', 'stairs', 'edgecolor', pc, 'displayname', obj.collatedResults(iSet).sessionID, 'normalization', 'probability')
							y = get(ax, 'ylim');
							yy(2) = max(yy(2), y(2));
						else
							if round(rb_s(iSet)) == 3
								allTimes_33{iSet} = obj.collatedResults(iSet).f_lick_ex_s_ecdf(obj.collatedResults(iSet).f_lick_ex_s_ecdf>0);
                            elseif round(rb_s(iSet)) == -3
								allTimes_NHL{iSet} = obj.collatedResults(iSet).f_lick_ex_s_ecdf(obj.collatedResults(iSet).f_lick_ex_s_ecdf>0);
							else
								allTimes_5{iSet} = obj.collatedResults(iSet).f_lick_ex_s_ecdf(obj.collatedResults(iSet).f_lick_ex_s_ecdf>0);
							end
						end
					end
					if strcmpi(Mode, 'cdf-xsesh')
						allTimes_33 = cell2mat(allTimes_33');
						[ecdf_f33,ecdf_x33] = ecdf(allTimes_33);
						allTimes_5 = cell2mat(allTimes_5');
						[ecdf_f5,ecdf_x5] = ecdf(allTimes_5);
						plot(ax, ecdf_x33,ecdf_f33, 'r-', 'displayname', '3.3s total', 'linewidth', 5)
						plot(ax, ecdf_x5,ecdf_f5, 'b-', 'displayname', '5s total', 'linewidth', 5)
						y = get(ax, 'ylim');
						yy(2) = max(yy(2), y(2));
					elseif strcmpi(Mode, 'hxg-xsesh')
						allTimes_33 = cell2mat(allTimes_33');
						allTimes_5 = cell2mat(allTimes_5');
						histogram(ax, allTimes_33, [0:0.25:20], 'displaystyle', 'stairs', 'edgecolor', 'r', 'displayname', '3.3s total', 'normalization', 'probability', 'linewidth', 5)
						histogram(ax, allTimes_5, [0:0.25:20], 'displaystyle', 'stairs', 'edgecolor', 'b', 'displayname', '5s total', 'normalization', 'probability', 'linewidth', 5)
						y = get(ax, 'ylim');
						yy(2) = max(yy(2), y(2));
                    elseif strcmpi(Mode, 'hxg-xsesh-NHL')
                        allTimes_33 = cell2mat(allTimes_33');
						allTimes_NHL = cell2mat(allTimes_NHL');
						histogram(ax, allTimes_33, [0:0.25:20], 'displaystyle', 'stairs', 'edgecolor', 'r', 'displayname', '3.3s total', 'normalization', 'probability', 'linewidth', 5)
						histogram(ax, allTimes_NHL, [0:0.25:20], 'displaystyle', 'stairs', 'edgecolor', 'k', 'displayname', '5s total', 'normalization', 'probability', 'linewidth', 5)
						y = get(ax, 'ylim');
						yy(2) = max(yy(2), y(2));
                    elseif strcmpi(Mode, 'cdf-xsesh-NHL')
						allTimes_33 = cell2mat(allTimes_33');
						allTimes_NHL = cell2mat(allTimes_NHL');
						[ecdf_f33,ecdf_x33] = ecdf(allTimes_33);
						[ecdf_f5,ecdf_x5] = ecdf(allTimes_NHL);
						plot(ax, ecdf_x33,ecdf_f33, 'r-', 'displayname', '3.3s total', 'linewidth', 5)
						plot(ax, ecdf_x5,ecdf_f5, 'k-', 'displayname', '5s total', 'linewidth', 5)
						y = get(ax, 'ylim');
						yy(2) = max(yy(2), y(2));
                    else
                        plot(ax, [7, 7], [yy],'r-', 'DisplayName', 'ITI Start-3.33 s task')
                        plot(ax, [10, 10], [yy],'b-', 'DisplayName', 'ITI Start-5 s task')
					end
					
					
					ax.XLabel.String = 'first lick time (s relative to cue)';
					ax.YLabel.String = 'fraction of responses in session';
				end
				set(ax, 'fontsize', 20)
			else
				error('not Implemented')	
			end
		end

		function inValidIdx = probeBestHT(obj, idx, plotInvalid)
			if nargin < 3
				plotInvalid = false;
			end
			if nargin < 2
				idx = 'all';
			end
			if strcmpi(idx, 'all')
				idx = 1:numel({obj.collatedResults.sessionID});
			end
			collatedResults = obj.collatedResults(idx);
			
			disp('----------------------------------------------------------')
			disp('	Threshold Crossing Analysis Results')
			disp('		')

			f = figure;
			ax_bin = subplot(3,2,1, 'parent', f);
			ax_st = subplot(3,2,2, 'parent', f);
			ax_bin_rsq = subplot(3,2,3, 'parent', f);
			ax_st_rsq = subplot(3,2,4, 'parent', f);
			ax_bin_th = subplot(3,2,5, 'parent', f);
			ax_st_th = subplot(3,2,6, 'parent', f);
			hold(ax_bin, 'on');
			hold(ax_st, 'on');
			hold(ax_bin_rsq, 'on');
			hold(ax_st_rsq, 'on');
			hold(ax_bin_th, 'on');
			hold(ax_st_th, 'on');
			set(ax_bin, 'fontsize', 20);
			set(ax_st, 'fontsize', 20);
			set(ax_bin_rsq, 'fontsize', 20);
			set(ax_st_rsq, 'fontsize', 20);
			set(ax_bin_th, 'fontsize', 20);
			set(ax_st_th, 'fontsize', 20);

			f2 = figure;
			ax_bin_xt2l = subplot(1,2,1, 'parent', f2);
			ax_st_xt2l = subplot(1,2,2, 'parent', f2);
			hold(ax_bin_xt2l, 'on');
			hold(ax_st_xt2l, 'on');
			set(ax_bin_xt2l, 'fontsize', 20);
			set(ax_st_xt2l, 'fontsize', 20);
			
			% legend(ax_bin_rsq,'show', 'interpreter', 'none');
			% legend(ax_st_rsq,'show', 'interpreter', 'none');
			% legend(ax_bin_th,'show', 'interpreter', 'none');
			% legend(ax_st_th,'show', 'interpreter', 'none');

			title(ax_bin, 'Binned hThreshold Crossing-% bins')
			title(ax_st, 'Single-Trial hThreshold Crossing-%trials')
			title(ax_bin_rsq, 'Binned R^2')
			title(ax_st_rsq, 'Single-Trial R^2')
			title(ax_bin_th, 'Binned Slope: xtime vs flick')
			title(ax_st_th, 'Single-Trial Slope: xtime vs flick')
			ax_bin.YLabel.String = '% of bins crossing';
			ax_st.YLabel.String = '% of trials crossing';
			ax_bin_rsq.YLabel.String = 'Rsq';
			ax_st_rsq.YLabel.String = 'Rsq';
			ax_bin_th.YLabel.String = 'Slope';
			ax_st_th.YLabel.String = 'Slope';
			% ax_bin.XLabel.String = 'threshold #';
			% ax_st.XLabel.String = 'threshold #';
			ax_bin_th.XLabel.String = 'threshold #';
			ax_st_th.XLabel.String = 'threshold #';

			title(ax_bin_xt2l, 'Binned xtime - lick time')
			title(ax_st_xt2l, 'Single-Trial xtime - lick time')
			
			ax_bin_xt2l.YLabel.String = 'time (s)';
			ax_bin_xt2l.XLabel.String = 'threshold #';
			ax_st_xt2l.XLabel.String = 'threshold #';

			binColors = 0.1:(.9-0.1)/numel({collatedResults.sessionID}):0.9;
			bin_nValidSesh = 0;
			st_nValidSesh = 0;
			bin_invalidSessions = {};
			st_invalidSessions = {};
			inValidIdx.bin = [];
			inValidIdx.st = [];
			for iSession = 1:numel({collatedResults.sessionID})
				% try
					nthresh = collatedResults(iSession).nthresh;
					if isempty(nthresh)
						warning(['It appears this dataset is missing: ' collatedResults(iSession).sessionID])
						bin_invalidSessions{end+1,1} = collatedResults(iSession).sessionID;
						st_invalidSessions{end+1,1} = collatedResults(iSession).sessionID;
						continue
					end
					% 
					% 	Find trials meeting some critera - let's say at least 100 trials crossing or 10 bins crossing AND median time2xing > 250ms
					% 
					bin_median_xt2l = cellfun(@(x) median(x), collatedResults(iSession).binned_time2lickFromThreshXing);
					st_median_xt2l = cellfun(@(x) median(x), collatedResults(iSession).singletrial_time2lickFromThreshXing);

					if ~plotInvalid
						bin_thresh_not_in_range = unique([find(collatedResults(iSession).binned_pcBinsXing.*collatedResults(iSession).nbins_inRange < 10), find(bin_median_xt2l > -0.25)]); %& bin_median_xt2l < 0.25
						% bin_thresh_not_in_range = bin_thresh_not_in_range(ismember(bin_thresh_not_in_range, find(bin_median_xt2l < 0.25)));
						st_thresh_not_in_range = unique([find(collatedResults(iSession).singletrial_pcTrialsXing.*collatedResults(iSession).nTrials_InRange < 100), find(st_median_xt2l > -0.25)]); % & st_median_xt2l < 0.25
					else
						bin_thresh_not_in_range = [];
						st_thresh_not_in_range = [];
					end
					% st_thresh_not_in_range = st_thresh_not_in_range(ismember(st_thresh_not_in_range, find(st_median_xt2l < 0.25))); % & st_median_xt2l < 0.25

					plot(ax_bin_xt2l, 1:nthresh, bin_median_xt2l, '-', 'color', [0,0,binColors(iSession)], 'DisplayName', ['median xtime - lick time: ' collatedResults(iSession).sessionID, ' nbins: ' num2str(collatedResults(iSession).nbins_inRange)], 'linewidth', 2);
					plot(ax_st_xt2l, 1:nthresh, st_median_xt2l, '-', 'color', [binColors(iSession),0,0], 'DisplayName', ['median xtime - lick time: ' collatedResults(iSession).sessionID, ' nbins: ' num2str(collatedResults(iSession).nTrials_InRange)], 'linewidth', 2);

					
					bin_maxthreshXtimeLimit250 = find(bin_median_xt2l > -0.025, 1, 'first');
					st_maxthreshXtimeLimit250 = find(st_median_xt2l > -0.025, 1, 'first');
					if isempty(bin_maxthreshXtimeLimit250), bin_maxthreshXtimeLimit250 = nan;, end
					if isempty(st_maxthreshXtimeLimit250), st_maxthreshXtimeLimit250 = nan;, end

					plot(ax_bin, 1:nthresh, collatedResults(iSession).binned_pcBinsXing, '-', 'color', [0,0,binColors(iSession)], 'DisplayName', ['%bins: ' collatedResults(iSession).sessionID, ' nbins: ' num2str(collatedResults(iSession).nbins_inRange)], 'linewidth', 2);
					plot(ax_bin, [bin_maxthreshXtimeLimit250,bin_maxthreshXtimeLimit250], [0,1], '-', 'color', [0,0,binColors(iSession)], 'DisplayName', ['250ms latency bound'], 'linewidth', 2);
					plot(ax_st, 1:nthresh, collatedResults(iSession).singletrial_pcTrialsXing, '-', 'color', [binColors(iSession),0,0], 'DisplayName', ['%bins: ' collatedResults(iSession).sessionID, ' nbins: ' num2str(collatedResults(iSession).nTrials_InRange)], 'linewidth', 2);
					plot(ax_st, [st_maxthreshXtimeLimit250,st_maxthreshXtimeLimit250], [0,1], '-', 'color', [binColors(iSession),0,0], 'DisplayName', ['250ms latency bound'], 'linewidth', 2);
					

					bin_rsq_in_range = collatedResults(iSession).binned_rsq;
					if ~isempty(bin_thresh_not_in_range)
						bin_rsq_in_range(bin_thresh_not_in_range) = nan;
					end
					st_rsq_in_range = collatedResults(iSession).singletrial_rsq;
					if ~isempty(st_thresh_not_in_range)
						st_rsq_in_range(st_thresh_not_in_range) = nan;
					end
					plot(ax_bin_rsq, 1:nthresh, bin_rsq_in_range, '-', 'color', [0,0,binColors(iSession)], 'DisplayName', ['Rsq: ' collatedResults(iSession).sessionID, ' nbins: ' num2str(collatedResults(iSession).nbins_inRange)], 'linewidth', 2);
					plot(ax_st_rsq, 1:nthresh, st_rsq_in_range, '-', 'color', [binColors(iSession),0,0], 'DisplayName', ['Rsq: ' collatedResults(iSession).sessionID, ' nbins: ' num2str(collatedResults(iSession).nTrials_InRange)], 'linewidth', 2);
					% plot(ax_bin_rsq, [bin_maxthreshXtimeLimit250,bin_maxthreshXtimeLimit250], [0,1], '-', 'color', [0,0,binColors(iSession)], 'DisplayName', ['250ms latency bound'], 'linewidth', 2);
					% plot(ax_st_rsq, [st_maxthreshXtimeLimit250,st_maxthreshXtimeLimit250], [0,1], '-', 'color', [binColors(iSession),0,0], 'DisplayName', ['250ms latency bound'], 'linewidth', 2);

					
					th_bin = cell2mat(collatedResults(iSession).binned_b)';
					th_bin = th_bin(:,2);
					th_bin(bin_thresh_not_in_range) = nan;
					th_st = cell2mat(collatedResults(iSession).singletrial_b)';
					th_st = th_st(:,2);
					th_st(st_thresh_not_in_range) = nan;
					plot(ax_bin_th, 1:nthresh, th_bin, '-', 'color', [0,0,binColors(iSession)], 'DisplayName', ['r: ' collatedResults(iSession).sessionID, ' nbins: ' num2str(collatedResults(iSession).nbins_inRange)], 'linewidth', 2);
					plot(ax_st_th, 1:nthresh, th_st, '-', 'color', [binColors(iSession),0,0], 'DisplayName', ['r: ' collatedResults(iSession).sessionID, ' nbins: ' num2str(collatedResults(iSession).nTrials_InRange)], 'linewidth', 2);
					% plot(ax_bin_th, [bin_maxthreshXtimeLimit250,bin_maxthreshXtimeLimit250], [0,1], '-', 'color', [0,0,binColors(iSession)], 'DisplayName', ['250ms latency bound'], 'linewidth', 2);
					% plot(ax_st_th, [st_maxthreshXtimeLimit250,st_maxthreshXtimeLimit250], [0,1], '-', 'color', [binColors(iSession),0,0], 'DisplayName', ['250ms latency bound'], 'linewidth', 2);

				% catch
					
				% end
				if numel(bin_thresh_not_in_range) ~= nthresh
					bin_nValidSesh = bin_nValidSesh + 1;
				else
					bin_invalidSessions{end+1,1} = collatedResults(iSession).sessionID;
					inValidIdx.bin(end+1) = iSession;
				end
				if numel(st_thresh_not_in_range) ~= nthresh
					st_nValidSesh = st_nValidSesh + 1;
				else
					st_invalidSessions{end+1,1} = collatedResults(iSession).sessionID;
					inValidIdx.st(end+1) = iSession;
				end
			end
			ylim(ax_bin, [0,1]);
			ylim(ax_st, [0,1]);
			ylim(ax_bin_rsq, [0,1]);
			ylim(ax_st_rsq, [0,1]);
			ylim(ax_bin_th, [0,1]);
			ylim(ax_st_th, [0,1]);
			xlim(ax_bin, [0,nthresh])
			xlim(ax_st, [0,nthresh])
			xlim(ax_bin_rsq, [0,nthresh])
			xlim(ax_st_rsq, [0,nthresh])
			xlim(ax_bin_th, [0,nthresh])
			xlim(ax_st_th, [0,nthresh])
			% legend(ax_bin,'show', 'interpreter', 'none');
			% legend(ax_st,'show', 'interpreter', 'none');
			
			disp(['	Total Sessions: ' num2str(numel({collatedResults.sessionID}))])
			disp(' ');
			disp(['	Binned Data:'])
			disp(['		# Valid Sessions: ' num2str(bin_nValidSesh)])
			disp(['		Invalid Sessions: '])
            disp(char(bin_invalidSessions))
			disp(' ');
			disp(['	Single Trial Data:'])
			disp(['		# Valid Sessions: ' num2str(st_nValidSesh)])
			disp(['		Invalid Sessions: ' ])
            disp(char(st_invalidSessions))

		end

		function inValidIdx = probeBestVT(obj, idx, plotInvalid)
			if nargin < 3
				plotInvalid = false;
			end
			if nargin < 2
				idx = 'all';
			end
			if strcmpi(idx, 'all')
				idx = 1:numel({obj.collatedResults.sessionID});
			end
			collatedResults = obj.collatedResults(idx);
			
			disp('----------------------------------------------------------')
			disp('	Threshold Crossing Analysis Results')
			disp('		')

			f = figure;
			ax_bin = subplot(3,2,1, 'parent', f);
			ax_st = subplot(3,2,2, 'parent', f);
			ax_bin_rsq = subplot(3,2,3, 'parent', f);
			ax_st_rsq = subplot(3,2,4, 'parent', f);
			ax_bin_r = subplot(3,2,5, 'parent', f);
			ax_st_r = subplot(3,2,6, 'parent', f);
			hold(ax_bin, 'on');
			hold(ax_st, 'on');
			hold(ax_bin_rsq, 'on');
			hold(ax_st_rsq, 'on');
			hold(ax_bin_r, 'on');
			hold(ax_st_r, 'on');
			set(ax_bin, 'fontsize', 20);
			set(ax_st, 'fontsize', 20);
			set(ax_bin_rsq, 'fontsize', 20);
			set(ax_st_rsq, 'fontsize', 20);
			set(ax_bin_r, 'fontsize', 20);
			set(ax_st_r, 'fontsize', 20);

			
			title(ax_bin, 'Binned vThreshold Crossing-% bins')
			title(ax_st, 'Single-Trial vThreshold Crossing-%trials')
			title(ax_bin_rsq, 'Binned R^2')
			title(ax_st_rsq, 'Single-Trial R^2')
			title(ax_bin_r, 'Binned Correlation: xpos vs flick')
			title(ax_st_r, 'Single-Trial Correlation: xpos vs flick')
			ax_bin.YLabel.String = '% of bins crossing';
			ax_st.YLabel.String = '% of trials crossing';
			ax_bin_rsq.YLabel.String = 'Rsq';
			ax_st_rsq.YLabel.String = 'Rsq';
			ax_bin_r.YLabel.String = 'r';
			ax_st_r.YLabel.String = 'r';
			ax_bin_r.XLabel.String = 'threshold #';
			ax_st_r.XLabel.String = 'threshold #';


			binColors = 0.1:(.9-0.1)/numel({collatedResults.sessionID}):0.9;
			bin_nValidSesh = 0;
			st_nValidSesh = 0;
			bin_invalidSessions = {};
			st_invalidSessions = {};
			inValidIdx.bin = [];
			inValidIdx.st = [];
			for iSession = 1:numel({collatedResults.sessionID})
				% try
					nthresh = collatedResults(iSession).nthresh;
					if isempty(nthresh)
						warning(['It appears this dataset is missing: ' collatedResults(iSession).sessionID])
						bin_invalidSessions{end+1,1} = collatedResults(iSession).sessionID;
						st_invalidSessions{end+1,1} = collatedResults(iSession).sessionID;
						continue
					end
					

					

					

					bar(ax_bin, iSession, collatedResults(iSession).nBinsTotal, 'facecolor', [0,0,binColors(iSession)], 'linewidth', 2);
					bar(ax_st, iSession, collatedResults(iSession).nTrialsTotal, 'facecolor', [binColors(iSession),0,0], 'linewidth', 2);
					
					

					bin_rsq_in_range = collatedResults(iSession).binned_rsq;
% 					if ~isempty(bin_thresh_not_in_range)
% 						bin_rsq_in_range(bin_thresh_not_in_range) = nan;
% 					end
					st_rsq_in_range = collatedResults(iSession).singletrial_rsq;
% 					if ~isempty(st_thresh_not_in_range)
% 						st_rsq_in_range(st_thresh_not_in_range) = nan;
% 					end
					plot(ax_bin_rsq, collatedResults(iSession).thresholds, bin_rsq_in_range, '-', 'color', [0,0,binColors(iSession)], 'DisplayName', ['Rsq: ' collatedResults(iSession).sessionID, ' nbins: ' num2str(collatedResults(iSession).nBinsTotal)], 'linewidth', 2);
					plot(ax_st_rsq, collatedResults(iSession).thresholds, st_rsq_in_range, '-', 'color', [binColors(iSession),0,0], 'DisplayName', ['Rsq: ' collatedResults(iSession).sessionID, ' nbins: ' num2str(collatedResults(iSession).nTrialsTotal)], 'linewidth', 2);
					
					
					plot(ax_bin_r, collatedResults(iSession).thresholds, collatedResults(iSession).binned_r, '-', 'color', [0,0,binColors(iSession)], 'DisplayName', ['r: ' collatedResults(iSession).sessionID, ' nbins: ' num2str(collatedResults(iSession).nBinsTotal)], 'linewidth', 2);
					plot(ax_st_r, collatedResults(iSession).thresholds, collatedResults(iSession).singletrial_r, '-', 'color', [binColors(iSession),0,0], 'DisplayName', ['r: ' collatedResults(iSession).sessionID, ' nbins: ' num2str(collatedResults(iSession).nTrialsTotal)], 'linewidth', 2);
					
				% if numel(bin_thresh_not_in_range) ~= nthresh
				% 	bin_nValidSesh = bin_nValidSesh + 1;
				% else
				% 	bin_invalidSessions{end+1,1} = collatedResults(iSession).sessionID;
				% 	inValidIdx.bin(end+1) = iSession;
				% end
				% if numel(st_thresh_not_in_range) ~= nthresh
				% 	st_nValidSesh = st_nValidSesh + 1;
				% else
				% 	st_invalidSessions{end+1,1} = collatedResults(iSession).sessionID;
				% 	inValidIdx.st(end+1) = iSession;
				% end
			end
			% ylim(ax_bin, [0,1]);
			% ylim(ax_st, [0,1]);
			ylim(ax_bin_rsq, [0,1]);
			ylim(ax_st_rsq, [0,1]);
			ylim(ax_bin_r, [-1,1]);
			ylim(ax_st_r, [-1,1]);
			
			xlim(ax_bin_rsq, [collatedResults(1).thresholds(1),collatedResults(1).thresholds(end)])
			xlim(ax_st_rsq, [collatedResults(1).thresholds(1),collatedResults(1).thresholds(end)])
			xlim(ax_bin_r, [collatedResults(1).thresholds(1),collatedResults(1).thresholds(end)])
			xlim(ax_st_r, [collatedResults(1).thresholds(1),collatedResults(1).thresholds(end)])
			% legend(ax_bin,'show', 'interpreter', 'none');
			% legend(ax_st,'show', 'interpreter', 'none');
			
			disp(['	Total Sessions: ' num2str(numel({collatedResults.sessionID}))])
			disp(' ');
			disp(['	Binned Data:'])
			disp(['		# Valid Sessions: ' num2str(bin_nValidSesh)])
			disp(['		Invalid Sessions: '])
            disp(char(bin_invalidSessions))
			disp(' ');
			disp(['	Single Trial Data:'])
			disp(['		# Valid Sessions: ' num2str(st_nValidSesh)])
			disp(['		Invalid Sessions: ' ])
            disp(char(st_invalidSessions))
		end


% ------------------------------------------------------------------------------------------------------------------------------------
% 	PCA Collated Results
% ------------------------------------------------------------------------------------------------------------------------------------

		function PCAvarianceExplainedOverlay(obj, d, pcs)
			% 
			% 	d: the index of the datasets to include
			% 	pcs: default is 1:10 for top 10 pcs
			% 
			if nargin < 2 || isempty(d)
				d = find(~obj.reportErrors(false));
			end
			if nargin < 3 || isempty(pcs)
				pcs = 1:10;
			end
			disp('-------------------------------------------------------')
			disp('	Plotting PCA Variance Explained Overlay for the following Sets:')
			disp(char({obj.collatedResults(d).sessionID}'))
			disp(['	pcs: ' num2str(pcs)])

			for id = d

			end
		end







		function plotDecodingModelResults(obj,idx,Mode,n,suppressNsave,Modelnum)
			% 
			% 	Mode: 	'summary'
			% 			'fit'
			% 			'fit-stem'
			% 			'fit-final'
			% 			'fit-final-compressed'
			% 	Same idea, but use refit- to use on refit datasets
			% 			'refit-summary'
			% 			'refit-final-compressed'
			% 
			% 	n: nests to plot
			% 	suppressNsave: a folder to save the plot to. will close the plot and not show (for collation)
			% 
			if nargin < 6
				Modelnum = 1;
            end
            if nargin < 3  || isempty(Mode)
				Mode = 'refit-final-compressed';
			end
			% 
			% 	Extract data
			% 
			if ~contains(Mode, 'refit')
				Dset = obj.collatedResults(idx).decoding;
				names = fieldnames(Dset);
				eval(['decoding = Dset.' names{Modelnum} ';'])
			else
				decoding = obj.collatedResults(idx).refit;
			end
			
			if nargin < 5
				suppressNsave = [];
			end
			if nargin < 4
				n = decoding.n;
			end
			
			colors = ['k','r','g','c','b','m','k','r','g','c','b','m','k','r','g'];
			y = decoding.y;
			yfit = decoding.yfit;

			if contains(Mode, 'summary')
				predictorNames = decoding.predictorNames;
				b = decoding.b;
				CImin = decoding.CImin;
				CImax = decoding.CImax;
				stats = decoding.stats;
				LossImprovement = decoding.LossImprovement;
				BIC = decoding.BIC;
				Rsq = decoding.Rsq;
				ESS = decoding.ESS;
				RSS = decoding.RSS;
				f = figure;
				ax = subplot(1,4,1, 'parent',f);
	            hold(ax, 'on');
	            title(ax,'Log-Coefficients with 95% CI')
	            plot(ax, [0,numel(predictorNames)], [0,0], 'k-')
				ax3 = subplot(1,4,3, 'parent',f);
				title(ax3,'BIC')
				hold(ax3, 'on')
	            ax4 = subplot(1,4,4, 'parent',f);
	            hold(ax4, 'on');
	            title(ax4,'Rsq')
	            for in=n
					plot(ax, [1:in] + (in-1)/(10*max(n)), b{in}, 'o', 'MarkerFaceColor', colors(in),'MarkerEdgeColor', colors(in))
					for inn = 1:in
						plot(ax, [inn + (in-1)/(10*max(n)),inn + (in-1)/(10*max(n))], [CImin{in}(inn),b{in}(inn)], [colors(in) '-'])	%ci min
						plot(ax, [inn + (in-1)/(10*max(n)),inn + (in-1)/(10*max(n))], [b{in}(inn),CImax{in}(inn)], [colors(in) '-'])	%ci max
					end
					plot(ax3, in + (in-1)/(10*max(n)), BIC(in), 'o', 'MarkerFaceColor', colors(in),'MarkerEdgeColor', colors(in))
					plot(ax4, in + (in-1)/(10*max(n)), Rsq(in), 'o', 'MarkerFaceColor', colors(in),'MarkerEdgeColor', colors(in))
				end
	            xticks(ax, 1:max(n))
	            xticklabels(ax, predictorNames(1:max(n)))
	            xticks(ax4, n)
	            xticklabels(ax4, predictorNames(n))
				% ylabel(ax4, 'Log-y fit weights')
				ax2 = subplot(1,4,2, 'parent',f);
				plot(ax2,LossImprovement(1:max(n)), 'ko-')
	            title(ax2,'Loss Improvement')
				xlabel(ax2,'Nest #')
				ylabel(ax2,'Training MSE Loss / Null Loss')
				ylabel(ax, 'Log-y fit weights')
				xticks(ax2, n)
	            xticklabels(ax2, predictorNames(n))
				
				xticks(ax3, n)
	            xticklabels(ax3, predictorNames(n))
	            xtickangle(ax,45)
	            xtickangle(ax2,45)
	            xtickangle(ax3,45)
	            xtickangle(ax4,45)

	            if isempty(suppressNsave)
					disp('		-------------------------------------------')
		 			disp(['		GLM Fit Nested Results for ' decoding.Conditioning ' | ' decoding.Link])
		 			disp(' ')
		 			disp(['		nests shown: ' mat2str(n)])
% 		 			disp(['		ntrials: ' num2str(numel(decoding.y{1})), '/' num2str(numel(obj.GLM.cue_s)) ' (' num2str(100*numel(decoding.y{1})/numel(obj.GLM.cue_s)) '%)'])

		 			disp('	')
		 			disp(cell2table({decoding.predictorNames{1:max(n)};decoding.predictorSet{1:max(n)}}))
	 			end
	 			if ~isempty(suppressNsave), figureName = ['DecodingFitResults_' decoding.predictorKey];, obj.suppressNsaveFigure(suppressNsave, figureName, f), close(f), end
			elseif strcmpi(Mode, 'fit')
	 			for in = n
                    trials_in_range_first = decoding.trials_in_range_first;
	 				f = figure;
		 			subplot(1,2,1);
		 			title(['log-all x,y | Nest ' num2str(in)])
		 			hold on
                    
		 			%  Handle case of PCA where the yfit is not same length across all nests...
		 			if numel(trials_in_range_first) ~= numel(y{in})
		 				trials_in_range_first = decoding.firstnest.trials_in_range_first;
	 				end

                    plot(trials_in_range_first+1,y{in}, 'o-', 'displayname', 'logy')
                    plot(trials_in_range_first+1,yfit{in}, 'o-', 'displayname', 'logyfit')                    
		 			xlabel('trial n')
		 			ylabel('log lick time trial n, (log-s)')
		 			subplot(1,2,2)
		 			hold on
		 			title(['original scale | Nest ' Mode])
                    plot(trials_in_range_first+1,exp(y{in}), 'o-', 'displayname', 'y')
                    plot(trials_in_range_first+1,exp(yfit{in}), 'o-', 'displayname', 'yfit')
		 			xlabel('trial n')
		 			ylabel('lick time trial n, (s)')
		 			legend('show')
		 			if ~isempty(suppressNsave), figureName = ['DecodingFit' decoding.predictorKey '_nest' num2str(in)];, obj.suppressNsaveFigure(suppressNsave, figureName, f), close(f), end
	 			end
 			elseif contains(Mode, 'fit-stem') || contains(Mode, 'fit-final')  || contains(Mode, 'fit-final-compressed')
                for in = n
                    trials_in_range_first = decoding.trials_in_range_first;
                    f = figure;
                    ax = subplot(1,1,1);
                    hold(ax, 'on');
                    title(ax,['original scale | Nest ' Mode])

                    %  Handle case of PCA where the yfit is not same length across all nests...
                    if numel(trials_in_range_first) ~= numel(y{in})
                        trials_in_range_first = decoding.firstnest.trials_in_range_first;
                    end

                    if contains(Mode, 'fit-stem')
	                    stem(trials_in_range_first+1,exp(y{in}), 'displayname', 'y')
	                    stem(trials_in_range_first+1,exp(yfit{in}), 'displayname', 'yfit')
%                     elseif contains(Mode, 'fit-final')
%                     	plot(trials_in_range_first+1,exp(y{in}), 'o-', 'displayname', 'y')
% 	                    plot(trials_in_range_first+1,exp(yfit{in}), 'o-', 'displayname', 'yfit')
                    else
                    	plot(exp(y{in}), 'o-', 'displayname', 'y')
	                    plot(exp(yfit{in}), 'o-', 'displayname', 'yfit')
	                end
                    xlabel('trial n')
                    ylabel('lick time trial n, (s)')
                    legend('show')
                    if ~isempty(suppressNsave), figureName = ['DecodingFit' decoding.predictorKey '_nest' num2str(in)];, obj.suppressNsaveFigure(suppressNsave, figureName, f), close(f), end
		
                end
            end
		end
		function flagCustom(obj)
			% 
			% 	This will specifically exclude datasets where QC was not met in the v3x QC pptx
			% 
			obj.analysis.note{2,1} = 'custom exclusions by QC taken'; 
			exclusions = {'H5_SNc_11',...
			'B5_SNc_17',...
			'B5_SNc_19',...
			'B6_SNc_13',...
			'H3_SNc_17',...
			'H3_SNc_18',...
			'H3_SNc_19',...
			'H3_SNc_20',...
			'H7_SNc_13',...
			'H7_SNc_12',...
			};
			for ii = 1:numel(obj.collatedResults), obj.collatedResults(ii).flagCustom = false; end
			for ii = 1:numel(exclusions)
				obj.collatedResults(find(strcmpi({obj.collatedResults.sessionID}, exclusions{ii}))).flagCustom = true;
			end
		end
		function extractThetas(obj, modelNum, Mode)
			% 
			% 	Pulls out all the theta info for the largest nest from all datasets
			% 
			% 	obj.analysis.thetas = [dataset# x nest]
			% 	obj.analysis.se_th = [dataset# x nest]
			% 	
			% 	Mode = 'fit' or 'refit'
			% 
			obj.flagCustom;	
			if nargin < 3
				Mode = 'fit';
			end
			if nargin < 2
				modelNum = 1; % since most datasets now have one model per dataset...
			end
			fields = fieldnames(obj.collatedResults(1).decoding);
			name = fields{modelNum};
			if strcmpi(Mode, 'fit')
				disp('** Extracting thetas on original fit')
			elseif strcmpi(Mode, 'refit')
                if ~strcmpi(name, 'multihtPCAstiff_multiPCAtdtstiff')
    				disp(['** Extracting thetas on ' num2str(obj.collatedResults(1).refit.k(1)) '-fold xval refit'])
                else
                    disp(['** Extracting thetas on ' num2str(obj.collatedResults(find(~[obj.collatedResults.flagNoRed],1,'first')).refit.k(1)) '-fold xval refit'])
                end
			else
				error('undefined mode')
			end
			try
    			eval(['nMax = numel(obj.collatedResults(1).decoding.' name '.predictorNames);'])
                eval(['numel(obj.collatedResults(1).decoding.' name '.predictorSet);'])
                hasRedFix = false;
            catch
                warning('running for hasred only')
                nMax = 14;
                hasRedFix = true;
                eval(['obj.collatedResults(1).decoding.' name '.predictorNames = obj.collatedResults(find(~[obj.collatedResults.flagNoRed], 1, ''first'')).decoding.' name '.predictorNames;'])
            end
			obj.analysis.note{1,1} = 'sets with < 20 df flagged for poor fit'; 
			obj.analysis.note{3,1} = ['Mode: ' Mode]; 
			obj.analysis.thMode = Mode;
			obj.analysis.setID = cell(numel(obj.collatedResults), 1);
			obj.analysis.thetas = nan(numel(obj.collatedResults), nMax);
			obj.analysis.se_ths = nan(numel(obj.collatedResults), nMax);
			obj.analysis.dfs = nan(numel(obj.collatedResults),1);
			for ii = 1:numel(obj.collatedResults)
				obj.analysis.setID{ii, 1} = obj.collatedResults(ii).sessionID;
                if ~hasRedFix || ~obj.collatedResults(ii).flagNoRed
                    if strcmpi(Mode, 'fit')
                        eval(['obj.analysis.thetas(ii, :) = obj.collatedResults(ii).decoding.' name '.stats{1, nMax}.beta;']) 
                        eval(['obj.analysis.se_ths(ii, :) = obj.collatedResults(ii).decoding.' name '.stats{1, nMax}.se;'])
                        eval(['obj.analysis.dfs(ii,1) = obj.collatedResults(ii).decoding.' name  '.stats{1, nMax}.dfe;'])
                    elseif strcmpi(Mode, 'refit')
                        obj.analysis.thetas(ii, :) = obj.collatedResults(ii).refit.stats{nMax,1}.beta;
                        obj.analysis.se_ths(ii, :) = obj.collatedResults(ii).refit.stats{nMax,1}.se;
                        % if obj.collatedResults(ii).flagNoRed
                        % 	% 
                        % 	% 	Because the tdts are set to be 1's across the board, we need to combine with the offset term to deal with them splitting everything
                        % 	% 
                        % 	tdtIdxs = find(cell2mat(cellfun(@(x) contains(x{1},'tdt'), obj.collatedResults(ii).refit.predictorSet, 'uniformoutput',false)));
                        % 	obj.analysis.thetas(ii, 1) = sum(obj.analysis.thetas(ii, [1, tdtIdxs]));
                        % 	obj.analysis.se_ths(ii, 1) = sum(obj.analysis.se_ths(ii, [1, tdtIdxs]));
                        % 	obj.analysis.thetas(ii, tdtIdxs) = 0;
                        % 	obj.analysis.se_ths(ii, tdtIdxs) = 0;
                        % end
                        % if sum(~isreal(obj.analysis.se_ths(ii, :))) > 0
                        % 	iiii = find(~isreal(obj.analysis.se_ths(ii, :)));
                        % 	disp(['	#' num2str(ii) ' has imaginary error on ths, setting to nan: ' mat2str(iiii)])
                        % 	obj.analysis.se_ths(ii, iiii) = nan;
                        % 	obj.analysis.ths(ii, iiii) = nan;
         %                    obj.analysis.thetas(ii, iiii) = nan;
                        % end
                        obj.analysis.dfs(ii,1) = obj.collatedResults(ii).refit.stats{nMax,1}.dfe;
                    else
                        obj.analysis.thetas(ii, :)
                        obj.analysis.se_ths(ii, :) = nan;
                        obj.analysis.dfs(ii,1) = nan;
                    end
				end
					
				if obj.analysis.dfs(ii,1) < 20
					obj.collatedResults(ii).flagPoorFit = true;
				else
					obj.collatedResults(ii).flagPoorFit = false;
				end
			end		
			if ~hasRedFix
    			eval(['obj.analysis.thNames = obj.collatedResults(1).decoding.' name '.predictorNames;'])
            else
                eval(['obj.analysis.thNames = obj.collatedResults(find(~[obj.collatedResults.flagNoRed], 1, ''first'')).decoding.' name '.predictorNames;'])
            end
		end
		function [meanTh, propagated_se_th, mdf] = getCompositeTheta(obj,idxs, Mode)
			% 
			% 	Called by decodingFigures
			% 
			% 	idxs = the datasets to use
			% 
			if nargin < 3
				Mode = 'fit';
            end
            if numel(fieldnames(obj.collatedResults(1).decoding)) > 1, warning('IS THIS THE RIGHT MODEL VERSION? USING THE FIRST ONE!'), end
			obj.extractThetas(1, Mode)
			if strcmpi(obj.analysis.thMode, 'fit')
				warning('composite theta on ORIGINAL FIT, NOT xval!!!!')
			end
			if nargin < 2
				idxs = 1:numel(obj.collatedResults);
			end
			
			
			
			ths = obj.analysis.thetas(idxs, :);
			se_ths = obj.analysis.se_ths(idxs, :);
			N = numel(idxs);
			NN = N.*ones(1, size(ths, 2));
			
			meanTh = 1/N .* nansum(ths, 1);
			propagated_se_th = 1/N .* sqrt(nansum(se_ths.^2, 1));
			mdf = sum(obj.analysis.dfs(idxs)).*ones(1, size(meanTh,2));
			% 
			% 	Now, handle the thetas with tdt separately
			% 
			thsWithtdt = find(contains(obj.analysis.thNames, 'tdt'));

			tdtIdxs = find(~[obj.collatedResults.flagNoRed]);
			tdtIdxs = tdtIdxs(ismember(tdtIdxs, idxs));
			disp(['tdt betas using only sets with tdt+. Found ' num2str(numel(tdtIdxs)), ' tdt+ sets in range.'])
 			ths = obj.analysis.thetas(tdtIdxs, thsWithtdt);
			se_ths = obj.analysis.se_ths(tdtIdxs, thsWithtdt);
			N = numel(tdtIdxs);
			NN(thsWithtdt) = N;
			meanTh(thsWithtdt) = 1/N .* nansum(ths, 1);
			propagated_se_th(thsWithtdt) = 1/N .* sqrt(nansum(se_ths.^2, 1));
			mdf(thsWithtdt) = sum(obj.analysis.dfs(tdtIdxs)).*ones(1, size(thsWithtdt,2));
			% 
			% 	Now, calculate the CI = b +/- t(0.025, n(m-1))*se
			% 
			for nn = 1:size(meanTh, 2)
				CImin(nn) = meanTh(nn) - abs(tinv(.025,numel(NN(nn))*(mdf(nn) - 1))).*propagated_se_th(nn);
				CImax(nn) = meanTh(nn) + abs(tinv(.025,numel(NN(nn))*(mdf(nn) - 1))).*propagated_se_th(nn);
%                 Tried below, too, but yields same result. Not different
%                 and I think above is correct version
%                 CIminA(nn) = meanTh(nn) - abs(tinv(.025,numel(mdf(nn))*(NN(nn) - 1))).*propagated_se_th(nn);
% 				CImaxA(nn) = meanTh(nn) + abs(tinv(.025,numel(mdf(nn))*(NN(nn) - 1))).*propagated_se_th(nn);
			end

			obj.analysis.flush.meanTh = meanTh;
			obj.analysis.flush.propagated_se_th = propagated_se_th;
			obj.analysis.flush.mdf = mdf;
			obj.analysis.flush.N = NN;
			obj.analysis.flush.CImin = CImin;
			obj.analysis.flush.CImax = CImax;
		end
		function getThresholdCrossingSlopes(obj)
			obj.analysis = [];
			% 
			% 	For all the collated data, we will calculate the slope on the multi-threshold predictors
			% 
			tdtPredictors = [9:11];
			gcampPredictors = [12:14];
			[x{1},y{1}] = obj.compileSlopeData('tdt_min_xtimes');
			[x{2},y{2}] = obj.compileSlopeData('tdt_most_xtimes');
			[x{3},y{3}] = obj.compileSlopeData('tdt_max_xtimes');
			[x{4},y{4}] = obj.compileSlopeData('min_xtimes');
			[x{5},y{5}] = obj.compileSlopeData('most_xtimes');
			[x{6},y{6}] = obj.compileSlopeData('max_xtimes');
			minXing{1} = obj.collatedResults(1).decoding.multiht_stiff_ea.tdtmin_minTrialsXing;
			minXing{2} = obj.collatedResults(1).decoding.multiht_stiff_ea.tdtmost_minTrialsXing;
			minXing{3} = obj.collatedResults(1).decoding.multiht_stiff_ea.tdtmax_minTrialsXing;
			minXing{4} = obj.collatedResults(1).decoding.multiht_stiff_ea.min_minTrialsXing;
			minXing{5} = obj.collatedResults(1).decoding.multiht_stiff_ea.most_minTrialsXing;
			minXing{6} = obj.collatedResults(1).decoding.multiht_stiff_ea.max_minTrialsXing;

			for is = 1:6
                % if ~isempty(y{is}{1})
                    [b{is},Rsq{is},yfit{is},stats{is},x{is},y{is}] = obj.fitSlope(x{is},y{is});
                    obj.analysis.slopes{is} = cell2mat(cellfun(@(bs) bs(2), b{is}, 'uniformoutput',0));
                % else
                %     b{is} = [nan; nan];
                %     Rsq{is} = nan;
                %     yfit{is} = x{is};
                %     stats{is} =[];
                %     obj.analysis.slopes{is} = [nan;
                % end
			end
			obj.analysis.dataIDs = {'tdt-low';'tdt-mid'; 'tdt-hi';'gcamp-lo';'gcamp-mid';'gcamp-hi'};
			obj.analysis.tdtPredictors = tdtPredictors;
			obj.analysis.gcampPredictors = gcampPredictors;
			obj.analysis.x = x;
			obj.analysis.y = y;
			obj.analysis.b = b;
			obj.analysis.stats = stats;
			obj.analysis.yfit = yfit;
            obj.analysis.Rsq = Rsq;
            obj.analysis.minXing = minXing;
		end
		function [x,y] = compileSlopeData(obj, thresholdData)
			x = {};
			y = {};
			for dd = 1:numel(obj.collatedResults)
				if strcmp(thresholdData,'tdt_min_xtimes') && ~isempty(obj.collatedResults(dd).decoding.multiht_stiff_ea.tdt_min_xtimes)
					if obj.collatedResults(dd).decoding.multiht_stiff_ea.tdtminthreshIdx == obj.collatedResults(dd).decoding.multiht_stiff_ea.tdtmostthreshIdx
						skip = true;
					end
				elseif strcmp(thresholdData,'tdt_max_xtimes') && ~isempty(obj.collatedResults(dd).decoding.multiht_stiff_ea.tdt_max_xtimes)
					if obj.collatedResults(dd).decoding.multiht_stiff_ea.tdtmaxthreshIdx == obj.collatedResults(dd).decoding.multiht_stiff_ea.tdtmostthreshIdx
						skip = true;
					end
				elseif strcmp(thresholdData,'min_xtimes') && ~isempty(obj.collatedResults(dd).decoding.multiht_stiff_ea.min_xtimes)
					if obj.collatedResults(dd).decoding.multiht_stiff_ea.minthreshIdx == obj.collatedResults(dd).decoding.multiht_stiff_ea.mostthreshIdx
						skip = true;
					end
				elseif strcmp(thresholdData,'max_xtimes') && ~isempty(obj.collatedResults(dd).decoding.multiht_stiff_ea.max_xtimes)
					if obj.collatedResults(dd).decoding.multiht_stiff_ea.maxthreshIdx == obj.collatedResults(dd).decoding.multiht_stiff_ea.mostthreshIdx
						skip = true;
					end
				else 
					skip = false;
				end
				if ~skip
					eval(['y{dd} = zero2nan(obj.collatedResults(dd).decoding.multiht_stiff_ea.' thresholdData ');'])
				else
					y{dd} = [];
				end
				x{dd} = obj.collatedResults(dd).flick_s_wrtc;
			end
		end
		function [b,Rsq,yfit,stats,xx,yy] = fitSlope(obj,xx,yy)
			warning('off','stats:glmfit:IllConditioned');
			b = cell(numel(xx),1);
			Rsq = nan(numel(xx),1);
			stats = cell(numel(xx),1);
			yfit = cell(numel(xx),1);
			for dd = 1:numel(xx)
				if ~isempty(yy{dd})
					x = xx{dd}(~isnan(xx{dd}));
					y = yy{dd}(~isnan(xx{dd}));
	                if size(x,1) ~= size(y,1)
	                    x = x';
	                end
	                x = x(~isnan(y));
	                y = y(~isnan(y));
					[b{dd},~,stats{dd}] = glmfit(x,y, 'normal', 'constant', 'on');
					yfit{dd} = b{dd}'*[ones(size(x));x];
					ESS = sum((yfit{dd} - mean(y)).^2);
	 				RSS = sum((yfit{dd} - y).^2);
	 				Rsq(dd) = ESS/(RSS+ESS);
	 				xx{dd} = x;
	 				yy{dd} = y;
 				else
					b{dd} = [nan;nan];
					stats{dd} = [];
					yfit{dd} = [];
	 				Rsq(dd) = nan;
 				end
			end 			
			warning('on','stats:glmfit:IllConditioned');
		end
		function plotThreshSlope(obj, sessionIdx, threshID)
			[f, ax] = makeStandardFigure(1, [1,1]);
            if ~isempty(obj.analysis.y{threshID}{sessionIdx})
    			plot(ax, obj.analysis.x{threshID}{sessionIdx}, obj.analysis.y{threshID}{sessionIdx}, 'k.', 'markersize', 20)
    			plot(ax, obj.analysis.x{threshID}{sessionIdx}, obj.analysis.yfit{threshID}{sessionIdx}, 'r-', 'linewidth', 3)
            end
			title(ax,[obj.collatedResults(sessionIdx).sessionID ' ' obj.analysis.dataIDs{threshID} ' slope:' num2str(round(obj.analysis.slopes{threshID}(sessionIdx),3)) ' Rsq:' num2str(round(obj.analysis.Rsq{threshID}(sessionIdx),2))], 'interpreter', 'none')
			xlabel(ax, 'xing time (s)')
			ylabel(ax, 'first-lick time (s)')
            set(f, 'userdata', ['obj.plotThreshSlope(' num2str(sessionIdx) ',' num2str(threshID)])
		end
		function plotSlopeSummary(obj)
			[f, ax] = makeStandardFigure(6, [2,3]);
			[f2, ax2] = makeStandardFigure(6, [2,3]);
			slopeMeans = nan(6,1);
			slopeStds = nan(6,1);
			slopeMins = nan(6,1);
			slopeMaxs = nan(6,1);
			rsqMeans = nan(6,1);
			rsqStds = nan(6,1);
			rsqMins = nan(6,1);
			rsqMaxs = nan(6,1);
            for iax = 1:6
	            title(ax(iax), obj.analysis.dataIDs{iax})
	            h = prettyHxg(ax(iax), obj.analysis.slopes{iax}(~isnan(obj.analysis.slopes{iax})), ['slope, n=' num2str(sum(~isnan(obj.analysis.slopes{iax})))], 'k');
                set(h, 'BinWidth', 0.1);
	            slopeMeans(iax) = nanmean(obj.analysis.slopes{iax});
	            slopeStds(iax) = nanstd(obj.analysis.slopes{iax});
				slopeMins(iax) = nanmin(obj.analysis.slopes{iax});
				slopeMaxs(iax) = nanmax(obj.analysis.slopes{iax});
	            addVerticalEvent(ax(iax), slopeMeans(iax), 'g', ['mean: ' num2str(round(slopeMeans(iax),2))], '-');
	            addVerticalEvent(ax(iax), slopeMins(iax), 'k', ['min: ' num2str(round(slopeMins(iax),2))], '--');
	            addVerticalEvent(ax(iax), slopeMaxs(iax), 'k', ['max: ' num2str(round(slopeMaxs(iax),2))], '--');
	            addVerticalEvent(ax(iax), slopeMeans(iax)-slopeStds(iax), 'r', ['-1std: ' num2str(round(slopeMeans(iax)-slopeStds(iax),2))], '--');
	            addVerticalEvent(ax(iax), slopeMeans(iax)+slopeStds(iax), 'r', ['+1std: ' num2str(round(slopeMeans(iax)+slopeStds(iax),2))], '--');
	            xlabel(ax(iax), 'slope')
	            ylabel(ax(iax), 'p')
                xlim(ax(iax),[0,1])
                ylim(ax(iax),[0,1])
                legend(ax(iax), 'show')

                title(ax2(iax), obj.analysis.dataIDs{iax})
	            h2 = prettyHxg(ax2(iax), obj.analysis.Rsq{iax}(~isnan(obj.analysis.Rsq{iax})), ['Rsq, n=' num2str(sum(~isnan(obj.analysis.Rsq{iax})))], 'k');
                set(h2, 'BinWidth', 0.1);
	            rsqMeans(iax) = nanmean(obj.analysis.Rsq{iax});
	            rsqStds(iax) = nanstd(obj.analysis.Rsq{iax});
				rsqMins(iax) = nanmin(obj.analysis.Rsq{iax});
				rsqMaxs(iax) = nanmax(obj.analysis.Rsq{iax});
	            addVerticalEvent(ax2(iax), rsqMeans(iax), 'g', ['mean: ' num2str(round(rsqMeans(iax),2))], '-');
	            addVerticalEvent(ax2(iax), rsqMins(iax), 'k', ['min: ' num2str(round(rsqMins(iax),2))], '--');
	            addVerticalEvent(ax2(iax), rsqMaxs(iax), 'k', ['max: ' num2str(round(rsqMaxs(iax),2))], '--');
	            addVerticalEvent(ax2(iax), rsqMeans(iax)-rsqStds(iax), 'r', ['-1std: ' num2str(round(rsqMeans(iax)-rsqStds(iax),2))], '--');
	            addVerticalEvent(ax2(iax), rsqMeans(iax)+rsqStds(iax), 'r', ['+1std: ' num2str(round(rsqMeans(iax)+rsqStds(iax),2))], '--');
	            xlabel(ax2(iax), 'Rsq')
	            ylabel(ax2(iax), 'p')
                xlim(ax2(iax),[0,1])
                ylim(ax2(iax),[0,1])
                legend(ax2(iax), 'show')
            end
            set(f, 'userdata', ['obj.plotSlopeSummary'])
            set(f, 'name', ['SLOPE'])
			set(f2, 'userdata', ['obj.plotSlopeSummary'])
			set(f2, 'name', ['Rsq'])

			obj.analysis.rsqMeans = rsqMeans
			obj.analysis.rsqStds = rsqStds
			obj.analysis.rsqMins = rsqMins
			obj.analysis.rsqMaxs = rsqMaxs
            obj.analysis.slopeMeans = slopeMeans;
            obj.analysis.slopeStds = slopeStds;
            obj.analysis.slopeMins = slopeMins;
            obj.analysis.slopeMaxs = slopeMaxs;
		end

		function decodingFigures(obj, Mode, Flag,Datasets, ModelNum)
			% 
			% 	Plots composite decoding model figures of all types
			% 
			% 	Mode: 	loss -- plots overlay of all loss plots
			% 			Rsq
			% 			BIC
			% 			b
			% 
			% 			loss-CI -- plots just the 2*STD bars on the loss
			% 			loss-noCI
			% 			Rsq-CI
			% 			Rsq-noCI
			% 			BIC-CI
			% 			b-CI
			% 			loss-condensed (combines the outcome stuff into one feature)
			% 			b-condensed
			% 			b-nob0
			% 			Rsq-overlay
			% 			BIC-overlay
			% 			BIC-unnormalized
			% 
			% 	Add refit- tag to any model to use the REFIT data instead
			% 
			% 	Flag: 	'hasRed' -- gets all sets with red data from ~obj.collatedResults.flagNoRed
			% 
			markers = 20;
			linewidths = 5;
			if nargin < 5 || isempty(ModelNum)
				ModelNum  = 1;
			end
			if nargin < 4 || isempty(Datasets)
				error_idxs = obj.reportErrors(false);
				goodidxs = find(~error_idxs);
			else
				goodidxs = Datasets;
			end
			if nargin < 3 || isempty(Flag)
				Flag = 'none';
			end
			if nargin < 2
				Mode = 'loss-condensed';
			end
			if contains(Mode, 'refit')
				fitMode = 'refit';
				warning('using refit xval''d data')
% 				Mode = erase(Mode, 'refit');
			else
				fitMode = 'fit';
                warning('on')
				warning('USING ORIGINAL FIT, NOT XVAL!')
			end

			if strcmpi(Flag, 'none')
				goodidxs = goodidxs;
			elseif strcmpi(Flag, 'hasRed')
				disp('		* Only using Red+ datasets')
				hasRed = find(~[obj.collatedResults.flagNoRed]);
				goodidxs = goodidxs(ismember(goodidxs, hasRed));
			elseif strcmpi(Flag, 'noRed')
				disp('		* Only using NO Red datasets')
				noRed = find([obj.collatedResults.flagNoRed]);
				goodidxs = goodidxs(ismember(goodidxs, noRed));
			else
				error('Unrecognized Dataset Flag. Options: noRed, hasRed, none');
			end

			% Deal with poor fits
			obj.extractThetas(1,fitMode)
			goodFits = find(~[obj.collatedResults.flagPoorFit]);
			goodidxs = goodidxs(ismember(goodidxs, goodFits));
			goodFits = find(~[obj.collatedResults.flagCustom]);
			goodidxs = goodidxs(ismember(goodidxs, goodFits));
            % 
			% 	Select model
			% 
			ModelType = fieldnames(obj.collatedResults(goodidxs(1)).decoding);
			ModelType = ModelType{ModelNum};
			disp(['Plotting for ' ModelType '.......'])
            if strcmpi(ModelType, 'multihtPCAstiff_multiPCAtdtstiff')
                goodidxs(ismember(goodidxs, find([obj.collatedResults.flagNoRed]))) = [];
            end
			disp(['--------- Plotting ' num2str(numel(goodidxs)) ' Successful Fits --------'])
			[meanTh, propagated_se_th] = obj.getCompositeTheta(goodidxs,fitMode);
			
			eval(['predictorNames = obj.collatedResults(goodidxs(1)).decoding.' ModelType '.predictorNames;'])
			% 
			% 	Decide whether we are refitting or no.
			% 
			if ~contains(Mode, 'refit')
				warning('Using original fit, NOT xval.')
				decoding1 = [obj.collatedResults(goodidxs).decoding];
                for ii = 1:numel(goodidxs)
                   eval(['decoding{ii,1} = decoding1(ii).' ModelType ';'])
                end
            else
				warning('Using XVALIDATED refit.')
				Mode = erase(Mode, 'refit');
				decoding = {obj.collatedResults(goodidxs).refit};
			end
				

			condensedPredictors = find(contains(predictorNames, 'n-1') & ~contains(predictorNames, 'lick time'));
            if strcmpi(Mode, 'b-condensed')
				li = nan(1,numel(predictorNames)-numel(condensedPredictors)+1);
                bi = nan(1,numel(predictorNames)-numel(condensedPredictors)+1);
                predictorNames = predictorNames(2:end);
                condensedPredictors = find(contains(predictorNames, 'n-1') & ~contains(predictorNames, 'lick time'));
            else
               li = nan(1,numel(predictorNames)-numel(condensedPredictors)+1); 
			end
			tdtPredictors = find(contains(predictorNames, 'tdt')); % don't want to include the non-tdt datasets in the averages for the loss or rsq on that term, they should be unchanged
			
			figure
			ax = subplot(1,1,1);
			hold(ax, 'on');
			for idx = 1:numel(goodidxs)
				if strcmpi(Mode, 'loss') || strcmpi(Mode, 'loss-CI') || strcmpi(Mode, 'loss-noCI')
					plot(ax, [0,numel(predictorNames)+1],[1,1], 'k-', 'linewidth', linewidths)
					% eval(['li(idx, 1:numel(predictorNames)) = obj.collatedResults(' num2str(goodidxs(idx)) ').decoding.' ModelType '.LossImprovement;'])
					li(idx, 1:numel(predictorNames)) = decoding{idx}.LossImprovement;
					% 
					% 	Check for no red and adjust
					% 
					if obj.collatedResults(idx).flagNoRed
						li(idx, tdtPredictors) = li(idx, tdtPredictors(1)-1);
					end
					ylabel(['Loss ' ModelType],'interpreter', 'none')
					if strcmpi(Mode, 'loss')
						plot(ax, li(idx, 1:numel(predictorNames)), '-', 'color', [0.2,0.2,0.2],'linewidth', 1, 'displayname', obj.collatedResults(goodidxs(idx)).sessionID)
					end
					ylim(ax, [0.5,1])
				elseif strcmpi(Mode, 'loss-condensed')
					% eval(['lipre(idx, 1:numel(predictorNames)) = obj.collatedResults(' num2str(goodidxs(idx)) ').decoding.' ModelType '.LossImprovement;'])
					warning('rbf')
					lipre(idx, 1:numel(predictorNames)) = decoding{idx}.LossImprovement;
					if obj.collatedResults(idx).flagNoRed
						lipre(idx, tdtPredictors) = lipre(idx, tdtPredictors(1)-1);
					end
					li(idx, condensedPredictors(1)) = lipre(idx, condensedPredictors(end));
					li(idx, 1:condensedPredictors(1)-1) = lipre(idx, 1:condensedPredictors(1)-1);
					li(idx, condensedPredictors(1)+1:end) = lipre(idx, condensedPredictors(end)+1:end);
					ylabel(['Loss ' ModelType],'interpreter', 'none')
                    plot(ax, li(idx, 1:numel(li(1,:))), '-', 'color', [0.2,0.2,0.2],'linewidth', 1, 'displayname', obj.collatedResults(goodidxs(idx)).sessionID)
                elseif strcmpi(Mode, 'b-condensed')
                	warning('rbf')
					% eval(['li1pre(idx, 1:numel(predictorNames)) = obj.collatedResults(' num2str(goodidxs(idx)) ').decoding.' ModelType '.b(numel(predictorNames)+1);'])
					li1pre(idx, 1:numel(predictorNames)) = decoding{idx}.b(numel(predictorNames)+1);
					if obj.collatedResults(idx).flagNoRed
						lipre(idx, tdtPredictors) = lipre(idx, tdtPredictors(1)-1);
					end
                    li(idx, 1:length(li1pre{end})) = li1pre{end};
					% eval(['CImin_i(idx, 1:numel(predictorNames)) = cell2mat(obj.collatedResults(' num2str(goodidxs(idx)) ').decoding.' ModelType '.CImin(2:end);'])
     %                eval(['CImax_i(idx, 1:numel(predictorNames)) = cell2mat(obj.collatedResults(' num2str(goodidxs(idx)) ').decoding.' ModelType '.CImax(2:end);'])
					bi(idx, condensedPredictors(1)) = nanmean(li(idx, condensedPredictors(end)));
					bi(idx, 1:condensedPredictors(1)-1) = li(idx, 1:condensedPredictors(1)-1);
					bi(idx, condensedPredictors(1)+1:end) = li(idx, condensedPredictors(end)+1:end);
					ylabel(['wt ' ModelType],'interpreter', 'none')
                    plot(ax, bi(idx, 1:numel(bi(1,:))), '-', 'color', [0.2,0.2,0.2],'linewidth', 1, 'displayname', obj.collatedResults(goodidxs(idx)).sessionID)
				elseif strcmpi(Mode, 'Rsq') || strcmpi(Mode, 'Rsq-CI') || strcmpi(Mode, 'Rsq-noCI')
					% eval(['li(idx, 1:numel(predictorNames)) = obj.collatedResults(' num2str(goodidxs(idx)) ').decoding.' ModelType '.Rsq;'])
					li(idx, 1:numel(predictorNames)) = decoding{idx}.Rsq;
					if obj.collatedResults(idx).flagNoRed
						li(idx, tdtPredictors) = li(idx, tdtPredictors(1)-1);
					end
					title(['Rsq ' ModelType],'interpreter', 'none')
					if strcmpi(Mode, 'Rsq')
						plot(ax, li(idx, 1:numel(predictorNames)), '-', 'color', [0.2,0.2,0.2],'linewidth', 1,'displayname', obj.collatedResults(goodidxs(idx)).sessionID)
					end
					ylim(ax, [0,0.5])
				elseif strcmpi(Mode, 'Rsq-overlay')
					error('depricated method, use Rsq for this')
					% eval(['lipre(idx, 1:numel(predictorNames)) = obj.collatedResults(' num2str(goodidxs(idx)) ').decoding.' ModelType '.Rsq;'])
					lipre(idx, 1:numel(predictorNames)) = decoding{idx}.Rsq;
					if obj.collatedResults(idx).flagNoRed
						lipre(idx, tdtPredictors) = lipre(idx, tdtPredictors(1)-1);
					end
					title(['Rsq ' ModelType],'interpreter', 'none')
					li(idx, condensedPredictors(1)) = lipre(idx, condensedPredictors(end));
					li(idx, 1:condensedPredictors(1)-1) = lipre(idx, 1:condensedPredictors(1)-1);
					li(idx, condensedPredictors(1)+1:end) = lipre(idx, condensedPredictors(end)+1:end);
					plot(ax, li(idx, 1:numel(li(1,:))), '-', 'color', [0.2,0.2,0.2],'linewidth', 1, 'displayname', obj.collatedResults(goodidxs(idx)).sessionID)
					ylim(ax, [0,0.5])
				elseif strcmpi(Mode, 'BIC') || strcmpi(Mode, 'BIC-CI') || strcmpi(Mode, 'BIC-overlay') || strcmpi(Mode, 'BIC-unnormalized')
					% eval(['li(idx, 1:numel(predictorNames)) = obj.collatedResults(' num2str(goodidxs(idx)) ').decoding.' ModelType '.BIC;'])
					li(idx, 1:numel(predictorNames)) = decoding{idx}.BIC;
					warning('no noredflag taken into account, showing fit BIC')
				elseif strcmpi(Mode,'b') || strcmpi(Mode, 'b-CI') || strcmpi(Mode, 'b-nob0')
					jitter = (rand*2-1)*0.2;					
					% eval(['bi(idx, 1:numel(predictorNames)) = cell2mat(obj.collatedResults(' num2str(goodidxs(idx)) ').decoding.' ModelType '.b(numel(predictorNames)));'])
					% eval(['CImin_i(idx, 1:numel(predictorNames)) = cell2mat(obj.collatedResults(' num2str(goodidxs(idx)) ').decoding.' ModelType '.CImin(numel(predictorNames)));'])
     %                eval(['CImax_i(idx, 1:numel(predictorNames)) = cell2mat(obj.collatedResults(' num2str(goodidxs(idx)) ').decoding.' ModelType '.CImax(numel(predictorNames)));'])
     				bi(idx, 1:numel(predictorNames)) = cell2mat(decoding{idx}.b(numel(predictorNames)));
					CImin_i(idx, 1:numel(predictorNames)) = cell2mat(decoding{idx}.CImin(numel(predictorNames)));
                    CImax_i(idx, 1:numel(predictorNames)) = cell2mat(decoding{idx}.CImax(numel(predictorNames)));
					if strcmpi(Mode, 'b')
						for b = 1:numel(predictorNames)
							plot(ax, b+jitter, bi(idx,b), 'k.', 'markersize', markers)
							plot(ax, [b+jitter,b+jitter], [CImin_i(idx,b),CImax_i(idx,b)], 'k-', 'linewidth', linewidths)
						end
					end
				end
			end
			% 
			%	Normalize BIC 
			% 
			if strcmpi(Mode,'BIC') || strcmpi(Mode,'BIC-CI') || strcmpi(Mode,'BIC-overlay')
				for idx = 1:numel(goodidxs)
					row = li(idx, :);
					row = row./max(row);
					% plot(ax, row, 'k-o', 'linewidth', 1)
					li(idx, :) = row;
					plot(ax, li(idx, :),'-', 'color', [0.2,0.2,0.2],'linewidth', 1,'displayname', obj.collatedResults(goodidxs(idx)).sessionID)
				end
				if strcmpi(Mode,'BIC')
					boxplot(ax,li,'extrememode','compress');
				elseif strcmpi(Mode,'BIC-overlay')
					plot(ax, mean(li,1), 'r-o', 'linewidth',linewidths, 'markersize', markers)
				else
					CI = 2*std(li,1);
					plot(ax, mean(li,1), 'r-o', 'linewidth',linewidths, 'markersize', markers)
					for ii = 1:numel(li(1,:))
						obj.plotCIbar(ax,ii,mean(li(:,ii)),CI(ii));
						obj.plotCIbar(ax,ii,mean(li(:,ii)),-CI(ii));
					end
				end
				title(['normalized BIC ' ModelType ' | ' obj.analysis.thMode],'interpreter', 'none')
			elseif strcmpi(Mode,'BIC-unnormalized')
				warning('rbf')
				for idx = 1:numel(goodidxs)
					plot(ax, li(idx, :),'-', 'color', [0.2,0.2,0.2],'linewidth', 1,'displayname', obj.collatedResults(goodidxs(idx)).sessionID)
				end
				plot(ax, mean(li,1), 'r-o', 'linewidth',linewidths, 'markersize', markers)
				title(['unnormalized BIC ' ModelType ' | ' obj.analysis.thMode],'interpreter', 'none')
			elseif strcmpi(Mode,'b') || strcmpi(Mode,'b-CI') || strcmpi(Mode,'b-nob0')
				% 
				% 	Extract all thetas and all SEMs on each theta
				% 


				if strcmpi(Mode,'b-nob0')
                	plot(ax, [0,numel(predictorNames)],[0,0], 'k-', 'linewidth', linewidths)
            	else
            		plot(ax, [0,numel(predictorNames)+1],[0,0], 'k-', 'linewidth', linewidths)
        		end
        		% 	Old version -- incorrect error propagation
				% meanb = nanmean(bi, 1);
				% meanCIn = nanmean(CImin_i, 1);
				% meanCIx = nanmean(CImax_i, 1);
				% 	Below: correct error propagation: ( I propagated sem, then applied correct dof to get the 95% t-test CI)
				meanb = obj.analysis.flush.meanTh;
				meanCIn = obj.analysis.flush.CImin;
				meanCIx = obj.analysis.flush.CImax;
				for b = 1:numel(predictorNames)
					if strcmpi(Mode,'b-nob0')
						if b == 1
							continue
						end
						obj.plotCIbar(ax,b-1,meanb(b),meanCIx(b), true, false,obj.collatedResults(goodidxs(idx)).sessionID);
						obj.plotCIbar(ax,b-1,meanb(b),meanCIn(b), true, false);
						obj.plotCIbar(ax,b-1,meanb(b),[meanCIn(b),meanCIx(b)], true, true);
					else
						obj.plotCIbar(ax,b,meanb(b),meanCIx(b), true, false,obj.collatedResults(goodidxs(idx)).sessionID);
						obj.plotCIbar(ax,b,meanb(b),meanCIn(b), true, false);
						obj.plotCIbar(ax,b,meanb(b),[meanCIn(b),meanCIx(b)], true, true);
					end
					% plot(ax, b, meanb(b), 'r.', 'markersize', 30)
					% plot(ax, [b,b], [meanCIn(b),meanCIx(b)], 'r-', 'linewidth', 3)
				end
				if strcmpi(Mode,'b-CI')
					plot(ax, nanmean(meanb,1), 'r-o', 'linewidth',linewidths, 'markersize', markers,'markerfacecolor','r')
				elseif strcmpi(Mode,'b-nob0')
					plot(ax, nanmean(meanb(:,2:end),1), 'r-o', 'linewidth',linewidths, 'markersize', markers,'markerfacecolor','r')
				end
				ylabel('predictor weight log(s)')
			elseif strcmpi(Mode,'loss-CI') || strcmpi(Mode,'Rsq-CI')
				CI = 2*std(li,1);
				for idx = 1:numel(obj.collatedResults)
					if obj.collatedResults(idx).flagNoRed
						li(idx, tdtPredictors) = nan;
					end
				end
				plot(ax, nanmean(li,1), 'r-o', 'linewidth',linewidths)
				for ii = 1:numel(li(1,:))
					obj.plotCIbar(ax,ii,mean(li(:,ii)),CI(ii));
					obj.plotCIbar(ax,ii,mean(li(:,ii)),-CI(ii));
				end
            elseif contains(Mode,'condensed')
                warning('has errors')
                xxx = nan(1, size(li,2) - numel(condensedPredictors)+1); 
                xxx([1:condensedPredictors(1)-1,condensedPredictors(1)+1:end]) = mean(li(:,[1:condensedPredictors(1)-1,condensedPredictors(end)+1:end]),1);
                xxx(condensedPredictors) = mean(mean(li(condensedPredictors),1));
                plot(ax, xxx, 'r-o', 'linewidth',linewidths, 'markersize', markers, 'markerfacecolor','r')
            else
				plot(ax, mean(li,1), 'r-o', 'linewidth',linewidths, 'markersize', markers, 'markerfacecolor','r')
			end
				
			if strcmpi(Mode,'loss-condensed') || strcmpi(Mode,'b-condensed')
				error('has errors')
                if contains(Mpde, 'loss')
    				plot(ax, [0,numel(predictorNames)+1],[1,1], 'k-', 'linewidth', linewidths)
                else
                    plot(ax, [0,numel(predictorNames)+1],[0,0], 'k-', 'linewidth', linewidths)
                end
                predictorNamesCondensed = cell(1, numel(predictorNames) - numel(condensedPredictors)+1);
				predictorNamesCondensed(1:condensedPredictors(1)-1) = predictorNames(1:condensedPredictors(1)-1);
				predictorNamesCondensed{condensedPredictors(1)} = 'outcome';
				predictorNamesCondensed(condensedPredictors(1)+1:end) = predictorNames(condensedPredictors(end)+1:end);
				xticks(1:numel(predictorNamesCondensed));
	            xticklabels(predictorNamesCondensed); 
				xlim([0,numel(predictorNamesCondensed)+1])
			elseif strcmpi(Mode,'b-nob0')
				xticks(1:numel(predictorNames)-1);
	            xticklabels(predictorNames(2:end)); 
				xlim([0,numel(predictorNames)])
            else
                xticks(1:numel(predictorNames));
	            xticklabels(predictorNames); 
				xlim([0,numel(predictorNames)+1])
			end
			xtickangle(ax,45)
            set(ax, 'fontsize', 50)
            title([Mode, ' ' Flag ' | ' obj.analysis.thMode])
        end
		function plotCIbar(obj,ax, x,y,CIspan, absMode, printstar,handlename)
			% 
			% 	CIspan is the position of the bar end relative to mean. put in absolute mode to go to the position of CI
			% 	printstar takes the full CI span. If it doesn't cross zero, it plots a star 0.1 units above the top bar
			% 		** must use in absMode
			% 
			% 	Plots one side of CI
			% 
			if nargin < 6
				absMode = false;
			end
			if nargin < 7
				printStar = false;
            end
            if nargin < 8
                handlename = [];
            end
            if ~isreal(CIspan)
                warning([handlename ' has imaginary error! This happens because tdt and b0 are identical in the model. Matlab''s glmfit accounts for this, but my xval doesn''t'])
            end
            if absMode && printstar
				if CIspan(1)>0 && CIspan(2)>0 || CIspan(1)<0 && CIspan(2)<0
					plot(ax, x, max(CIspan)+0.2, 'k*', 'markersize',20)
                end
                return
			end
			if absMode && ~printstar
				if ~isempty(handlename)
					plot(ax, [x,x], [y,CIspan], 'k-', 'linewidth',8, 'displayname', handlename)
				else
					plot(ax, [x,x], [y,CIspan], 'k-', 'linewidth',8, 'HandleVisibility', 'off')
				end
				plot(ax, [x-0.15,x+0.15], [CIspan,CIspan], 'k-', 'linewidth',8)
			else
				if ~isempty(handlename)
					plot(ax, [x,x], [y,y + CIspan], 'k-', 'linewidth',8, 'displayname', handlename)
				else
					plot(ax, [x,x], [y,y + CIspan], 'k-', 'linewidth',8, 'HandleVisibility', 'off')
				end
				plot(ax, [x-0.15,x+0.15], [y + CIspan,y + CIspan], 'k-', 'linewidth',8)
            end
		end

		function plotBaselineANOVAidx(obj,sessionIdx,Mode)
			obj.flagPoorANOVA
			if nargin < 3
				Mode = 'mean';
			end
			if nargin < 2 || isempty(sessionIdx)
				% [~,sessionIdx] = obj.reportErrors(false);
    %             sessionIdx = find(sessionIdx);
    			sessionIdx = find(~[obj.collatedResults.FlagQC]);
			elseif strcmpi(sessionIdx, 'mdt')
				sessionIdx = find([obj.collatedResults.MDT]);
                sessionIdx(ismember(find([obj.collatedResults.MDT]),find([obj.collatedResults.FlagQC]))') = [];
			end
			figure
			ax = subplot(1,1,1);
			hold(ax, 'on');
			centers = obj.collatedResults(sessionIdx(1)).centers;
			jitter = rand/10;
			if strcmpi(Mode, 'overlay')
				for ii = 1:numel(sessionIdx)
					
					plot((centers+0.5*0)./1000, obj.collatedResults(sessionIdx(ii)).nm1Score, 'k-')
					plot((centers+0.5*0)./1000, obj.collatedResults(sessionIdx(ii)).sig_nm1+jitter, 'k-', 'linewidth',5)
					plot((centers+0.5*0)./1000, obj.collatedResults(sessionIdx(ii)).nScore, 'r-')
					plot((centers+0.5*0)./1000, obj.collatedResults(sessionIdx(ii)).sig_n-2+jitter, 'r-','linewidth',5)
				end
			elseif strcmpi(Mode, 'mean')
				obj.analysis.seshIdx = [];
				obj.analysis.nm1Scores = {};
				obj.analysis.nScores = {};
				for ii = 1:numel(sessionIdx)
					obj.analysis.nm1Scores{end+1} = obj.collatedResults(sessionIdx(ii)).nm1Score;
					obj.analysis.nScores{end+1} = obj.collatedResults(sessionIdx(ii)).nScore;
					obj.analysis.seshIdx(end+1) = sessionIdx(ii);
                end
                nm1Scoresmean = nanmean(cell2mat(obj.analysis.nm1Scores'));
                nScoresmean = nanmean(cell2mat(obj.analysis.nScores'));
				plot((centers+0.5*0)./1000, nm1Scoresmean, 'k-')
				plot((centers+0.5*0)./1000, nScoresmean, 'r-')
			end
			legend('show')
			xlabel('time (s relative to lamp-off)')
			ylabel('Selectivity Index')
			set(gca, 'fontsize',30)
			xlim([(centers(1)+0.5*0)./1000, (centers(end)+0.5*0)./1000])
			set(gcf,'color','w');
		end
		function [p,tbl,stats,terms] = xMouseBaselineANOVA(obj, sessionIdx, showtable)
			if nargin < 3
				showtable = 'on'
			end
			if showtable == 1
				showtable = 'on';
			elseif showtable == 0
				showtable = 'off';
			end

			% level is 1xn list of labels
			% data is a nx1 list of medians
			A_level = obj.collatedResults(sessionIdx).results{1, 1}.cellData.A_level;
			B_level = obj.collatedResults(sessionIdx).results{1, 1}.cellData.B_level;
			data = obj.collatedResults(sessionIdx).results{1, 1}.cellData.data;
			[p,tbl,stats,terms] = anovan(data, {A_level, B_level}, 'model','interaction', 'display',showtable);
		end
		function flagPoorANOVA(obj, overwrite)
            if nargin < 2
                overwrite = false;
            end
			% 
			% 	Flags sessions based on there being no information in the ANOVA
			% 
			if ~isfield(obj.collatedResults, 'MDT') || overwrite
				obj.collatedResults(1).MDT = [];
				obj.collatedResults(1).FlagQC = [];
				obj.collatedResults(1).Nm1sig = [];
				obj.collatedResults(1).Nsig = [];
				obj.collatedResults(1).NxMsig = [];
				for ii = 1:numel(obj.collatedResults)
					if isempty(obj.collatedResults(ii).results)
						obj.collatedResults(ii).Nm1sig = false;
						obj.collatedResults(ii).Nsig = false;
						obj.collatedResults(ii).NxMsig = false;
						obj.collatedResults(ii).MDT = false;
						obj.collatedResults(ii).FlagQC = true;
					else
						[p,~,~,~] = obj.xMouseBaselineANOVA(ii, false);
						if p(1) < 0.05
							obj.collatedResults(ii).Nm1sig = true;
						else
							obj.collatedResults(ii).Nm1sig = false;
						end
						if p(2) < 0.05
							obj.collatedResults(ii).Nsig = true;
						else
							obj.collatedResults(ii).Nsig = false;
						end
						if p(3) < 0.05
							obj.collatedResults(ii).NxMsig = true;
						else
							obj.collatedResults(ii).NxMsig = false;
						end
						if contains(obj.collatedResults(ii).sessionID, {'H6','H7','B5','B6'})
							obj.collatedResults(ii).MDT = true;
						else
							obj.collatedResults(ii).MDT = false;
						end
						if ~sum([obj.collatedResults(ii).Nm1sig,obj.collatedResults(ii).Nsig,obj.collatedResults(ii).NxMsig])
							obj.collatedResults(ii).FlagQC = true;
						else
							obj.collatedResults(ii).FlagQC = false;
						end
					end
				end
			end
		end
		function flagMDT(obj)
			if ~isfield(obj.collatedResults, 'MDT')
				for ii = 1:numel(obj.collatedResults)
					if contains(obj.collatedResults(ii).sessionID, {'H6','H7','B5','B6'})
						obj.collatedResults(ii).MDT = true;
					else
						obj.collatedResults(ii).MDT = false;
					end
				end
			end
		end
		






















		%%% DECODING XVAL
		function kCheck(obj, d, n, k, modelName)
			if ~isfield(obj.collatedResults, 'kfoldSets')
				obj.collatedResults(1).kfoldSets = [];
			end
			if isempty(obj.collatedResults(d).kfoldSets) || ~isfield(obj.collatedResults(d).kfoldSets, 'k') || obj.collatedResults(d).kfoldSets.k ~= k
				obj.getKfoldSet(d, k, modelName);
			end
		end
		function getKfoldSet(obj, d, k, modelName, startOver)
			disp('Fetching k-fold set...')
			if nargin < 5
				startOver = false;
				% 
				% 	This means that we will recycle an old k-fold set with same k from the obj
				% 
			end
			if startOver || ~isfield(obj.collatedResults(d).kfoldSets, 'k') || obj.collatedResults(d).kfoldSets.k ~= k
				% 
				% 	Clear the previous results
				% 
				obj.collatedResults(d).XvalResults = [];
				if startOver
					disp(['	' num2str(k) '-fold Set is being started again from scratch.'])
				else
					disp(['	' num2str(k) '-fold Set NOT stored in obj. Fetching now.'])
				end
				fetchID = randi(1000000);
				%					
				% 	Randomly divide the set into sets with about equal numbers of trials
				% 
				eval(['nTrials = numel(obj.collatedResults(d).decoding.' modelName '.y{end});'])
				trials_per_set = floor(nTrials/k);
				shuffleSet = randperm(nTrials);
				for iSet = 1:k
					if iSet ~= k
						trialSets{iSet} = shuffleSet((iSet-1)*trials_per_set + 1:iSet*trials_per_set);
					else
						trialSets{iSet} = shuffleSet((iSet-1)*trials_per_set + 1:end);
					end
				end
				obj.collatedResults(d).kfoldSets.ID = fetchID;
				obj.collatedResults(d).kfoldSets.k = k;
				obj.collatedResults(d).kfoldSets.trialSets = trialSets;
				obj.collatedResults(d).kfoldSets.nTrials = nTrials;
			else
				disp(['	' num2str(k) '-fold Set already stored in obj. Recycling.'])
			end
		end
		function selectBestLam(obj, d, n)
			% 
			% 	We will get the best lamda for each cross-validation type (k-fold, code)
			% 		It will get updated for every iteration of xvalidate
			%
		 	%	obj.XvalResults(d).nest(n)
		 	% 
		 	% 		. kfoldID
		 	% 		. k
		 	% 		meanTestLoss
		 	% 		testLoss (as fx of lamda) -- so a matrix of k x #lam
		 	% 		bestLam
		 	% 		lamRange
		 	% ----------------------------
		 	% 
		 	% 	Get optimal lam
		 	%	obj.collatedResults(d).XvalResults(n).
		 	% 
		 	[lams, sortIdx] = sort([obj.collatedResults(d).XvalResults(n).models.lam]);
		 	nullLossTraining = obj.collatedResults(d).XvalResults(n).models(sortIdx).nullLossTraining;
			nullLossTest = obj.collatedResults(d).XvalResults(n).models(sortIdx).nullLossTest;
			trainingLoss = [obj.collatedResults(d).XvalResults(n).models(sortIdx).trainingLoss];
			testLoss = [obj.collatedResults(d).XvalResults(n).models(sortIdx).testLoss];
			% 
			% 	Deal with ill-specified models, ie if matrix was singular, we should exclude it from consideration
			% 	by making loss effectively infinite
			% 
			trainingLoss(isnan(trainingLoss)) = 10^10;
			testLoss(isnan(testLoss)) = 10^10;
			
			meanTrainingLoss = mean(trainingLoss, 1);
			meanTestLoss = mean(testLoss, 1);


		 	bestLamIdx = find(meanTestLoss == min(meanTestLoss));
		 	bestLam = lams(bestLamIdx);
            bestTestLoss = meanTestLoss(bestLamIdx);
            bestTrainingLoss = meanTrainingLoss(bestLamIdx);

			k = obj.collatedResults(d).kfoldSets.k;
	 		obj.collatedResults(d).XvalResults(n).kfoldID = obj.collatedResults(d).XvalResults(n).models(1).kfoldID;
            obj.collatedResults(d).XvalResults(n).bestLam = bestLam;
            obj.collatedResults(d).XvalResults(n).bestTestLoss = bestTestLoss;
		 	obj.collatedResults(d).XvalResults(n).k = k;
		 	obj.collatedResults(d).XvalResults(n).meanTestLoss = meanTestLoss;
		 	obj.collatedResults(d).XvalResults(n).testLoss = testLoss;
		 	obj.collatedResults(d).XvalResults(n).meanTrainingLoss = meanTrainingLoss;
		 	obj.collatedResults(d).XvalResults(n).trainingLoss = trainingLoss;
		 	obj.collatedResults(d).XvalResults(n).bestTrainingLoss = bestTrainingLoss;
		 	obj.collatedResults(d).XvalResults(n).lamRange = lams;
		 	obj.collatedResults(d).XvalResults(n).nullLossTraining = nullLossTraining;
		 	obj.collatedResults(d).XvalResults(n).nullLossTest = nullLossTest;
		 	obj.collatedResults(d).XvalResults(n).bestLamIdx = bestLamIdx;
		end
		function xValLossPlotVsLam(obj, d, n)
			figure
			ax2 = axes;
			hold(ax2, 'on');
			lamLabel = cell(1, length(obj.collatedResults(d).XvalResults(n).models));
			for ilam = 1:length(obj.collatedResults(d).XvalResults(n).models)
				lamLabel{ilam} = num2str(obj.collatedResults(d).XvalResults(n).models(ilam).lam);
				nullLossTraining(ilam) =  mean([obj.collatedResults(d).XvalResults(n).models(ilam).nullLossTraining]);
				nullLossTest(ilam) =  mean([obj.collatedResults(d).XvalResults(n).models(ilam).nullLossTest]);
			end


			% Have to sort the lams before plotting it all
			[lams, sortIdx] = sort([obj.collatedResults(d).XvalResults(n).models.lam]);
			lamLabel = lamLabel(sortIdx);
			nullLossTraining = nullLossTraining(sortIdx);
			nullLossTest = nullLossTest(sortIdx);
			trainingLoss = [obj.collatedResults(d).XvalResults(n).models(sortIdx).trainingLoss];
			testLoss = [obj.collatedResults(d).XvalResults(n).models(sortIdx).testLoss];
			meanTrainingLoss = mean(trainingLoss, 1);
			meanTestLoss = mean(testLoss, 1);
			plot(ax2, 1:numel(lams), nullLossTraining, 'b--', 'DisplayName', 'Mean Null Loss - Training')
			plot(ax2, 1:numel(lams), nullLossTest, 'r--', 'DisplayName', 'Mean Null Loss - Test')
			for ilam = 1:numel(lams)
				l = scatter(ax2, ilam.*ones(size(trainingLoss(:, ilam))), trainingLoss(:, ilam), 'b', 'filled', 'HandleVisibility', 'off');
				alpha(l, 0.2)
				l = scatter(ax2, ilam.*ones(size(testLoss(:, ilam))), testLoss(:, ilam), 'r', 'filled', 'HandleVisibility', 'off');
				alpha(l, 0.2)
			end

			plot(ax2, 1:numel(lams), meanTrainingLoss, 'b-o', 'DisplayName', 'Training Loss')
			plot(ax2, 1:numel(lams), meanTestLoss, 'r-o', 'DisplayName', 'Test Loss')
			xticks(ax2, 1:length(obj.collatedResults(d).XvalResults(n).models));
			xticklabels(ax2, lamLabel);
			title(ax2, 'Loss vs Regularization')
			xlabel(ax2, 'lambda')
			ylabel(ax2, 'loss')
			legend(ax2, 'show')
			xtickangle(ax2,90);
		end
		function plotXval(obj, d, n)
			models = obj.collatedResults(d).XvalResults(n).models;
			figure,
			ax_trainingLoss = subplot(2,2,1);
			ax_testLoss = subplot(2,2,2);
			ax_EnImprovement = subplot(2,2,3);
			ax_EImprovement = subplot(2,2,4);
			% ax_se_model = subplot(2,2,3);
			% ax_R2 = subplot(2,2,4);
			hold(ax_trainingLoss, 'on')
			hold(ax_testLoss, 'on')
			hold(ax_EnImprovement, 'on')
			hold(ax_EImprovement, 'on')
			% hold(ax_se_model, 'on')
			% hold(ax_R2, 'on')

			nXv = numel(models(1).se_model);
			jitter = 0.5*rand(nXv,1) -.25;

			lamLabel = cell(1, length(models));

			for ilam = 1:length(models)
				lamLabel{ilam} = num2str(models(ilam).lam);
				nullLossTraining(ilam) =  mean([models(ilam).nullLossTraining]);
				nullLossTest(ilam) =  mean([models(ilam).nullLossTest]);

				scatter(ax_trainingLoss, jitter + ilam*ones(nXv, 1), models(ilam).trainingLoss)
				alpha(.1);
				scatter(ax_trainingLoss, ilam, models(ilam).meanTrainingLoss, 'filled')

				scatter(ax_testLoss, jitter + ilam*ones(nXv, 1), models(ilam).testLoss)
				alpha(.1);
				scatter(ax_testLoss, ilam, models(ilam).meanTestLoss, 'filled')

				EnImprovement{ilam} = 100*(nullLossTraining(ilam) - models(ilam).trainingLoss)./nullLossTraining(ilam);
				meanEnImprovement(ilam) = mean(EnImprovement{ilam});
				EImprovement{ilam} = 100*(nullLossTest(ilam) - models(ilam).testLoss)./nullLossTest(ilam);
				meanEImprovement(ilam) = mean(EImprovement{ilam});

				scatter(ax_EnImprovement, jitter + ilam*ones(nXv, 1), EnImprovement{ilam})
				alpha(.1);

				scatter(ax_EImprovement, jitter + ilam*ones(nXv, 1), EImprovement{ilam})
				alpha(.1);

				% scatter(ax_se_model, jitter + ilam*ones(nXv, 1), models(ilam).se_model)
				% alpha(.3);

				% scatter(ax_R2, jitter + ilam*ones(nXv, 1), models(ilam).R2)
				% alpha(.3);
			end
			plot(ax_trainingLoss, nullLossTraining, 'k-o')
			plot(ax_testLoss, nullLossTest, 'k-o')
			plot(ax_EnImprovement, meanEnImprovement, 'k-o')
			plot(ax_EImprovement, meanEImprovement, 'k-o')


			xticks(ax_trainingLoss, 1:length(models));
			xticklabels(ax_trainingLoss, lamLabel);
			title(ax_trainingLoss, 'Training Loss')
			xlabel(ax_trainingLoss,'lamda')
			ylabel(ax_trainingLoss,'Training Set MSELoss')

			
			xticks(ax_testLoss, 1:length(models));
			xticklabels(ax_testLoss, lamLabel);
			title(ax_testLoss, 'Test Loss')
			xlabel(ax_testLoss,'lamda')
			ylabel(ax_testLoss,'Test Set MSELoss')

			xticks(ax_EnImprovement, 1:length(models));
			xticklabels(ax_EnImprovement, lamLabel);
			title(ax_EnImprovement, 'Training Loss % Improvement vs Sn Null')
			xlabel(ax_EnImprovement,'lamda')
			ylabel(ax_EnImprovement,'% Improvement (+ is better)')

			xticks(ax_EImprovement, 1:length(models));
			xticklabels(ax_EImprovement, lamLabel);
			title(ax_EImprovement, 'Test Loss % Improvement vs Sn Null')
			xlabel(ax_EImprovement,'lamda')
			ylabel(ax_EImprovement,'% Improvement (+ is better)')

			% xticks(ax_se_model, [models.lam]);
			% xticklabels(ax_se_model, lamLabel);
			% title(ax_se_model, 'se of model')

			% xticks(ax_R2, [models.lam]);
			% xticklabels(ax_R2, lamLabel);
			% title(ax_R2, 'R^2')
			models = models;
			figure
			ax2 = axes;
			hold(ax2, 'on');
			plot(ax2, nullLossTraining, 'b--', 'DisplayName', 'Mean Null Loss - Training')
			plot(ax2, nullLossTest, 'r--', 'DisplayName', 'Mean Null Loss - Test')

			plot(ax2, [models.meanTrainingLoss], 'b-o', 'DisplayName', 'Training Loss')
			plot(ax2, [models.meanTestLoss], 'r-o', 'DisplayName', 'Test Loss')
			xticks(ax2, 1:length(models));
			xticklabels(ax2, lamLabel);
			title(ax2, 'Loss vs Regularization')
			xlabel(ax2, 'lambda')
			ylabel(ax2, 'loss')
			legend(ax2, 'show')
			xtickangle(ax2,90);

		end
		function ax = plotBestLoss(obj, d, kfoldID, ax)
			% 
			% 	Will make training and test loss plots for the dataset in question
			% 
			if nargin < 2
				error('Must specify dataset #')
			end
			if nargin < 4
				figure, 
				ax{1} = subplot(2,2,1);
				title(ax{1}, 'Training Loss by Nest')
				xlabel(ax{1}, 'Nest #')
				ylabel(ax{1}, 'MSE Loss')
				hold(ax{1}, 'on');
				ax{2} = subplot(2,2,2);
				title(ax{2}, 'Test Loss by Nest')
				xlabel(ax{2}, 'Nest #')
				ylabel(ax{2}, 'MSE Loss')
				hold(ax{2}, 'on');
				ax{3} = subplot(2,2,3);
				title(ax{3}, 'Training Loss Improvement')
				xlabel(ax{3}, 'Nest #')
				ylabel(ax{3}, '% Improvement vs Training Null')
				hold(ax{3}, 'on');
				ax{4} = subplot(2,2,4);
				title(ax{4}, 'Test Loss Improvement')
				xlabel(ax{4}, 'Nest #')
				ylabel(ax{4}, '% Improvement vs Test Null')
				hold(ax{4}, 'on');
			end

			
			
			XvalResults = obj.collatedResults(d).XvalResults;
			nests = 1:numel(XvalResults(end).nests);
			nNests = numel(XvalResults);
			bestTestLoss = nan(nNests, 1);
			bestTrainingLoss = nan(nNests, 1);
			testLoss = cell(nNests, 1);
			trainingLoss = cell(nNests, 1);
			meanPercImprovementTrain = nan(nNests, 1);
			meanPercImprovementTest = nan(nNests, 1);
			percImprovementTrain = cell(nNests, 1);
			percImprovementTest = cell(nNests, 1);

			for n = 1:nNests
				k = XvalResults(n).k;
				bestLamIdx = XvalResults(n).bestLamIdx;
				bestTestLoss(n) = XvalResults(n).bestTestLoss;
				bestTrainingLoss(n) = XvalResults(n).bestTrainingLoss;
				trainingLoss{n} = XvalResults(n).trainingLoss(:,bestLamIdx);
				testLoss{n} = XvalResults(n).testLoss(:,bestLamIdx);
				meanPercImprovementTrain(n) = 100*(mean(XvalResults(n).nullLossTraining) - bestTrainingLoss(n))/mean(XvalResults(n).nullLossTraining);
				meanPercImprovementTest(n) = 100*(mean(XvalResults(n).nullLossTest) - bestTestLoss(n))/mean(XvalResults(n).nullLossTest);
				for il = 1:numel(trainingLoss{n})
					percImprovementTrain{n}(end+1) = 100*(XvalResults(n).nullLossTraining(il) - trainingLoss{n}(il))/XvalResults(n).nullLossTraining(il);
					percImprovementTest{n}(end+1) = 100*(XvalResults(n).nullLossTest(il) - testLoss{n}(il))/XvalResults(n).nullLossTest(il);
				end

				l = scatter(ax{1}, nests(n).*ones(size(trainingLoss{n})), trainingLoss{n}, 'b', 'filled', 'HandleVisibility', 'off');
				alpha(l, 0.1);
				l = scatter(ax{2}, nests(n).*ones(size(testLoss{n})), testLoss{n}, 'r', 'filled', 'HandleVisibility', 'off');
				alpha(l, 0.1);
				l = scatter(ax{3}, nests(n).*ones(size(percImprovementTrain{n})), percImprovementTrain{n}, 'b', 'filled', 'HandleVisibility', 'off');
				alpha(l, 0.1);
				l = scatter(ax{4}, nests(n).*ones(size(percImprovementTest{n})), percImprovementTest{n}, 'r', 'filled', 'HandleVisibility', 'off');
				alpha(l, 0.1);
			end
			plot(ax{1}, nests, mean(XvalResults(n).nullLossTraining).*ones(size(nests)), 'b--', 'DisplayName', 'Null Training Loss')
			plot(ax{1}, nests, bestTrainingLoss, 'b-o', 'DisplayName', 'Best Training Loss')
			legend(ax{1}, 'show')

			plot(ax{2}, nests, mean(XvalResults(n).nullLossTest).*ones(size(nests)), 'r--', 'DisplayName', 'Null Test Loss')
			plot(ax{2}, nests, bestTestLoss, 'r-o', 'DisplayName', 'Best Test Loss')
			legend(ax{2}, 'show')

			plot(ax{3}, nests, meanPercImprovementTrain, 'b-o')
			plot(ax{4}, nests, meanPercImprovementTest, 'r-o')

			xticks(ax{1}, 1:max(nests));
			xticks(ax{2}, 1:max(nests));
			xticks(ax{3}, 1:max(nests));
			xticks(ax{4}, 1:max(nests));

		end
		function autoXval(obj, d, n, modelName, k, nLamsPerRound, useSingle)
            nRounds = 1;
			% 
			% 	If you set nRounds to 0, this will just return the plot summary! nice
			% 
			% 	d = the collatedResults index for the dataset
			% 	n = the nest of the model to xval
			% 	
			suppressPlot = true;
			if nargin < 7
				useSingle = false;
			end
			if nargin<6
				nLamsPerRound = 20;
			end
			if nargin < 5;
				k = 5;
			end
			
			disp('~~~~~~~~~~~~~~~~~~')
			disp('~	Auto Xvalidate ~')
			disp('~~~~~~~~~~~~~~~~~~')
			% 
			% 	The function will work to choose a lam that is best 
			% 
			% 	while min is 0 or the largest lam
			% 	1. Test new range of lam and find best lam
			% 	for nRounds after finding a middle-lam that is minimum test loss,
			% 	2. Test range of lams between min lam and surrounding lams
			% 
			bestLamIdx = 1;
			% 
			% 	Check for existing k-set for this dataset
			% 	
			obj.kCheck(d,n,k,modelName);
			kfoldID = obj.collatedResults(d).kfoldSets.ID;
			% 
			% 	Recycle any lams already in our saved results for this kID
			% 
			if ~isfield(obj.collatedResults, 'XvalResults')
				obj.collatedResults.XvalResults = [];
			end
			if ~isempty(obj.collatedResults(d).XvalResults) && isfield(obj.collatedResults(d).XvalResults, 'n') && numel(obj.collatedResults(d).XvalResults.n) >= n && isfield(obj.collatedResults(d).XvalResults.n, 'kfoldID') && ~isempty(obj.collatedResults(d).XvalResults(n).kfoldID) && obj.collatedResults(d).XvalResults(n).kfoldID == kfoldID
				lams = obj.collatedResults(d).XvalResults(n).lamRange;
				obj.selectBestLam(d, n);
				bestLamIdx = obj.collatedResults(d).XvalResults(n).bestLamIdx;
			else
				lams = [0,0.001, 0.1,1,10,100,1000,10000];
				obj.xValidate(d, n, lams, 'k-fold', k, false, modelName, suppressPlot, useSingle);
				obj.selectBestLam(d, n);
				bestLamIdx = obj.collatedResults(d).XvalResults(n).bestLamIdx;
            end
            if numel(bestLamIdx)>1
                bestLamIdx = bestLamIdx(2);
            end
            iter = 1;
			while bestLamIdx==1 || bestLamIdx==2 || bestLamIdx==numel(lams) && iter <= 10								
				if bestLamIdx==1
					disp('lam=0 is still best.')
                    sortLams = sort(lams);
					lams = [lams, sortLams(2)/10];
				elseif bestLamIdx==2
					disp('lam=0 is still flanking on left.')
                    sortLams = sort(lams);
					lams = [lams, sortLams(2)/10];
				elseif bestLamIdx==numel(lams)
					disp(['lam=' num2str(lams(end)) ' is best.'])
					lams = [lams, lams(end)*10];
				end
				disp(['	Attempting with lam=' num2str(lams(end)) '... ' datestr(now)])
				obj.xValidate(d, n, lams, 'k-fold', k, false, modelName, suppressPlot, useSingle);
				obj.selectBestLam(d, n);
				lams = obj.collatedResults(d).XvalResults(n).lamRange;
				bestLamIdx = obj.collatedResults(d).XvalResults(n).bestLamIdx;
                iter = iter + 1;
                if numel(bestLamIdx)>1
                    bestLamIdx = bestLamIdx(2);
                end
				if iter > 10
					warning('Timeout - ran 10 iterations of lams and found nothing...')
                    
                    if bestLamIdx==1 || bestLamIdx==2
                        disp('lam=0 or effectively 0 is still best. Finish this round')
                        nRounds = 0;
                        break
                    else
                        disp('lam is exploding, clearly the fit is not good. proceed with largest lam')
                        nRounds = 0;
                        break
                    end
				end
			end
			disp(['----- Found a minimum lam=' num2str(lams(bestLamIdx)) ' | ' datestr(now)])
			disp([' '])
			% 
			% 	Now zoom in and find even better lam
			% 
			for l = 1:nRounds
				disp(['----- Testing subdiv lams, round ' num2str(l) '/' num2str(nRounds) ' | ' datestr(now)])
				[lamsSorted, idxs] = sort(lams);
				bestLam = lams(bestLamIdx);
				bestLamIdxSorted = find(lamsSorted == bestLam);
				if bestLamIdxSorted == 2
					% 
					% 	The range is between [0, bestlam, nextbest]
					% 
					lams = unique([lams, lamsSorted(bestLamIdxSorted)/10:lamsSorted(bestLamIdxSorted)/(nLamsPerRound/2):lamsSorted(bestLamIdxSorted), lamsSorted(bestLamIdxSorted):lamsSorted(bestLamIdxSorted+1)/(nLamsPerRound/2):lamsSorted(bestLamIdxSorted+1)]);
					obj.xValidate(d, n, lams, 'k-fold', k, false, modelName, suppressPlot, useSingle);
					obj.selectBestLam(d, n);
					bestLamIdx = obj.collatedResults(d).XvalResults(n).bestLamIdx;
					lams = obj.collatedResults(d).XvalResults(n).lamRange;
                else
					lams = unique([lams, lamsSorted(bestLamIdxSorted-1):(lamsSorted(bestLamIdxSorted)-lamsSorted(bestLamIdxSorted-1))/(nLamsPerRound/2):lamsSorted(bestLamIdxSorted), lamsSorted(bestLamIdxSorted):(lamsSorted(bestLamIdxSorted+1)-lamsSorted(bestLamIdxSorted))/(nLamsPerRound/2):lamsSorted(bestLamIdxSorted+1)]);
					obj.xValidate(d, n, lams, 'k-fold', k, false, modelName, suppressPlot, useSingle);
					obj.selectBestLam(d, n);
					bestLamIdx = obj.collatedResults(d).XvalResults(n).bestLamIdx;
					lams = obj.collatedResults(d).XvalResults(n).lamRange;
				end
			end
			% 
			% The results struct is always sorted by lam, so we can access it without fear here;
			% 
			[lamsSorted, idxs] = sort(lams);
            nullLossTest = obj.collatedResults(d).XvalResults(n).nullLossTest;
			bestLam = obj.collatedResults(d).XvalResults(n).bestLam;
            if numel(bestLam) > 1
            	obj.collatedResults(d).XvalResults(n).flag = {'more than one bestLam, removed extras', bestLam};
                bestLam = bestLam(1);
                obj.collatedResults(d).XvalResults(n).bestLam = obj.collatedResults(d).XvalResults(n).bestLam(1);
                obj.collatedResults(d).XvalResults(n).bestLamIdx = obj.collatedResults(d).XvalResults(n).bestLamIdx(1);
                obj.collatedResults(d).XvalResults(n).bestTestLoss = obj.collatedResults(d).XvalResults(n).bestTestLoss(1);
                obj.collatedResults(d).XvalResults(n).bestTrainingLoss = obj.collatedResults(d).XvalResults(n).bestTrainingLoss(1);
            end
			bestLamIdxSorted = find(lamsSorted == bestLam);
            assert(obj.collatedResults(d).XvalResults(n).bestLamIdx == bestLamIdxSorted);
			bestTestLoss = obj.collatedResults(d).XvalResults(n).bestTestLoss;
			testLoss = [obj.collatedResults(d).XvalResults(n).testLoss(:,bestLamIdxSorted)];
			meanPercImprovementTest = 100*(mean(nullLossTest) - bestTestLoss)/mean(nullLossTest);
			percImprovementTest = nan(1, k);
			for il = 1:k
				percImprovementTest(il) = 100*(nullLossTest(il) - testLoss(il))/nullLossTest(il);
			end
			% 
			% 	Report the results
			% 
			disp('Complete. --------------')
			disp('')
			disp('Report: ')
			disp(['Lams tested: ' mat2str(sort(obj.collatedResults(d).XvalResults(n).lamRange))])
			disp(['Best lam: ' mat2str(bestLam)])
			disp(['Test Loss Improvement over Null: ' mat2str(round(meanPercImprovementTest,8)) ' % Improvement'])
			disp(['Range Test Loss Improvement over Null Range: ' mat2str(round(sort(percImprovementTest),8)) ' % Improvement'])
			disp('')
			
            if bestLamIdxSorted ~= 1
                llIdx = idxs(bestLamIdxSorted - 1);
            else
                llIdx = idxs(bestLamIdxSorted);
            end
            if bestLamIdxSorted ~= numel(lamsSorted)
    			ulIdx = idxs(bestLamIdxSorted + 1);
            else
                ulIdx = idxs(bestLamIdxSorted);
            end
			
			bestLam_ll = lams(llIdx);
		 	testLoss_ll = [obj.collatedResults(d).XvalResults(n).testLoss(:,llIdx)];
		 	meanTestLoss_ll = mean(testLoss_ll, 1);
		 	meanPercImprovementTest_ll = 100*(mean(nullLossTest) - meanTestLoss_ll)/mean(nullLossTest);
			percImprovementTest_ll = nan(1, k);

			bestLam_ul = lams(ulIdx);
		 	testLoss_ul = [obj.collatedResults(d).XvalResults(n).testLoss(:,ulIdx)];
		 	meanTestLoss_ul = mean(testLoss_ul, 1);
		 	meanPercImprovementTest_ul = 100*(mean(nullLossTest) - meanTestLoss_ul)/mean(nullLossTest);			
			percImprovementTest_ul = nan(1, k);
			
			for il = 1:k
				percImprovementTest_ll(il) = 100*(nullLossTest(il) - testLoss_ll(il))/nullLossTest(il);
				percImprovementTest_ul(il) = 100*(nullLossTest(il) - testLoss_ul(il))/nullLossTest(il);
			end

			disp(['Next best lams=' mat2str([bestLam_ll, bestLam_ul])])
			disp(['Test Loss Improvement over Null: ' mat2str([round(meanPercImprovementTest_ll,8), round(meanPercImprovementTest_ul,8)]) ' % Improvement'])
			disp(['Lower Level Range Test Loss Improvement over Null Range: ' mat2str(round(sort(percImprovementTest_ll),8)) ' % Improvement'])
			disp(['Upper Level Range Test Loss Improvement over Null Range: ' mat2str(round(sort(percImprovementTest_ul),8)) ' % Improvement'])
		end
		function yFit = calcYfit(obj, th, X)
			yFit = th.'*X;
		end 
		function [se_model, se_th, CVmat, signifCoeff] = standardErrorOfModelAndTh(obj, XtX, th, yActual, yFit, lambda)
			% 
			% 	Updated 3/2/23 for missing data
			% 
			warning('check this for missing data....')
			incl = find(~isnan(yActual));
			se_model = sqrt(sum((yActual(incl)-yFit(incl)).^2./numel(yFit(incl))));
			CVmat = (XtX+lambda*eye(size(XtX)))^-1*XtX*(XtX+lambda*eye(size(XtX)))^-1;
			se_th = se_model.*diag(CVmat).^.5; 
			distFromZero = abs(th) - 2*abs(se_th);
			signifCoeff = distFromZero > 0;
		end
		function E = MSELoss(obj,a,yFit)
			E = 1/numel(a)*sum((a - yFit).^2);
		end
		function [Resid, std_Resid, Rsq] = getModelResidualsAndR2(obj, yActual, yFit, th)
			error('need to check the error is fixed here...needs to be a nanmean etc')
			Resid = yActual - yFit;
			std_Resid = sqrt(sum(Resid.^2)./(numel(yActual) - numel(th)));
			std_yActual = std(yActual);
% 			explainedVarianceR2 = 1 - std_Resid^2/std_yActual^2;

			% 
			%  Check consistent
			% 	
			ESS = sum((yFit - mean(yActual)).^2);
 			RSS = sum((yFit - yActual).^2);
 			Rsq = ESS/(RSS+ESS);
%  			assert(explainedVarianceR2 == Rsq)
		end

		function xValidate(obj, d, n, lam, Mode, k, recycle_k, modelName, suppressPlot, useSingle)
			disp('=========================================')
			disp('=			 crossvalidation	 		  =')
			disp('=========================================')
			disp(' ')
			% 
			% 	We will reuse the saved X and a vectors to run Xvalidations with an array of lambdas to try
			% 
			% 	The default will be to do leave-1-out Xvalidation, since we have the ability to do this!
			% 
			% obj.xValidate(d, n, lams, 'k-fold', k, false, true, true, useSingle);
			% 
			%---------------------------------
			if nargin < 9
				suppressPlot = false;
			end
			if nargin < 4
				lam = [];
			end
			if nargin < 2
				d = 1;
			end
			if nargin < 3
				n = 1;
			end
			if nargin < 7
				recycle_k = false;
			end
			
			
			if nargin < 5
				Mode = 'leave-1-out';
				nX = obj.collatedResults(d).kfoldSets.nTrials;
			elseif strcmpi(Mode, 'leave-1-out')
				nX = obj.collatedResults(d).kfoldSets.nTrials;
			elseif strcmpi(Mode, 'k-fold')
				% 
				% 	Once a k-fold set is drawn, use it for ALL nests. Stored in obj.kfoldSets
				% 
				if ~recycle_k
					if nargin < 6
						k = 5;
					end
					nX = k;
					obj.getKfoldSet(d, k)
					
					trialSets = obj.collatedResults(d).kfoldSets.trialSets;

					obj.collatedResults(d).XvalResults(n).k = k;
					obj.collatedResults(d).XvalResults(n).trialSets = trialSets;
				else
					nX = obj.collatedResults(d).kfoldSets.k;
					trialSets = obj.collatedResults(d).kfoldSets.trialSets;
				end
			elseif strcmpi(Mode, 'check-lam')
				warning('We are checking out lam effect before running the cross-validation.')
				nX = 1;
				trial_check = randi(obj.collatedResults(d).kfoldSets.nTrials);
			else
				warning('Running in debug mode - will stop after 5x leave-1-out cross validations')
			end
			disp(['Dataset: ' obj.collatedResults(d).sessionID ' Nest #' num2str(n)])
			disp(['Calculating ' num2str(nX) 'x XVs for lamda=' mat2str(lam)])
			disp([' '])
			% 
			% 	We will have a set of models for each lamda
			%
			if strcmpi(Mode, 'k-fold')
				% 
				% 	Check in lam already in our set - if so, ignore it
				% 
				if ~isempty(obj.collatedResults(d).XvalResults) && isfield(obj.collatedResults(d).XvalResults, 'n') && numel(obj.collatedResults(d).XvalResults) >= n && isfield(obj.collatedResults(d).XvalResults, 'models') && ~isempty(obj.collatedResults(d).XvalResults(n).models)
					disp(['	Detected existing models for ' obj.collatedResults(d).sessionID ' nest#' num2str(n)])
					igLamIdxs = [];
					for ilam = 1:numel(lam)
						if sum(ismember([obj.collatedResults(d).XvalResults(n).models.lam], lam(ilam)))
							igLamIdxs(end+1) = ilam;
						end
					end
					lam(igLamIdxs) = [];
                end
            end
            if isempty(lam)
                disp('All input lams were already tested and in the results set')
            else
				for l = 1:numel(lam)
					models(l).lam = lam(l);
					if strcmpi(Mode, 'k-fold')
						models(l).kfoldID = obj.collatedResults(d).kfoldSets.ID;
						models(l).k = obj.collatedResults(d).kfoldSets.k;
					end
				end
				% 
				% 	models have stats as XV x lam
				% 			lam1	lam2	lam3...
				% 	XV 1
				% 	XV 2
				% 	...
				
				[models.nullLossTraining] = deal(nan(nX, 1));
				[models.meanTrainingLoss] = deal(nan(nX, 1));
				[models.nullLossTest] = deal(nan(nX, 1));
				[models.meanTestLoss] = deal(nan);
				[models.trainingLoss] = deal(nan(nX, 1));
				[models.testLoss] = deal(nan(nX, 1));
				[models.th] = deal(cell(nX, 1));
				[models.se_model] = deal(nan(nX, 1));
				[models.se_th] = deal(cell(nX, 1));
				[models.R2] = deal(nan(nX, 1));
				%
				%	Extract the relevant X and a for Xvalidation 
				% 	
				eval(['X = obj.collatedResults(d).decoding.' modelName '.X(1:n,:);'])
				eval(['nests = obj.collatedResults(d).decoding.' modelName '.predictorSet(1:n);'])
				eval(['a = obj.collatedResults(d).decoding.' modelName '.y{end};']) % using the final nest because this is fairest -- the dataset shrinks when we add the final predictors, so fair is fair here...
				
				dd = size(X, 1);
				% 
				% 	Now, for each XV, let's get the Xxv and aXV and calculate
				% 	the loss for each lam
				% 
				if strcmpi(Mode, 'check-lam') || ~suppressPlot
					figure,
					ax = subplot(1,2,1);
					ax2 = subplot(1,2,2);
					hold(ax, 'on');
					hold(ax2, 'on');
					C = linspecer(numel(lam));
				end
				disp(['Initiating cross-validation fitting ' datestr(now)])
				for xv = 1:nX
					% if ~rem(xv, 25)
					% 	disp(['On cross-validation ' num2str(xv) ' of ' num2str(nX) ' ' datestr(now)])
					% end
					obj.progressBar(xv, nX, false, 5)
					% 
					% 	Get the X and a
					% 
					if strcmpi(Mode, 'leave-1-out')
						trial = xv;
						a_xv = a;
						X_xv = X;
						a_test = a;
						X_test = X;	
					elseif strcmpi(Mode, 'check-lam')
						trial = trial_check;
						a_xv = a;
						X_xv = X;
						a_test = a;
						X_test = X;
					elseif strcmpi(Mode, 'k-fold')
						trials_test = trialSets{xv};	
						trials_training = trialSets;
						trials_training{xv} = [];
						trials_training = cell2mat(trials_training);
						
	                    Sn_killpos = trials_test;
	                    a_xv = a;
						X_xv = X;
	                    a_xv(Sn_killpos) = [];
	                    X_xv(:,Sn_killpos) = [];
	                    S_killpos = trials_training;
						a_test = a;
						X_test = X;
	                    a_test(S_killpos) = [];
	                    X_test(:, S_killpos) = [];
					end
					
					
					if strcmpi(Mode, 'check-lam') && ~suppressPlot
						xv = 1;
						plot(ax, a_test, 'DisplayName', 'dF/F')
						title('Lambda Check')
						xlabel('samples')
						ylabel('model dF/F')
					end


					for ilam = 1:numel(lam)
						XtX = X_xv*X_xv.';
						th = (XtX+lam(ilam).*eye(dd))\X_xv*a_xv.';
						models(ilam).th = th;
						% 
						% 	Return the yFit
						% 
						yFit = obj.calcYfit(th, X_xv);
						[models(ilam).se_model(xv, 1), models(ilam).se_th{xv, 1}, ~, ~] = obj.standardErrorOfModelAndTh(XtX, th, a_xv, yFit, lam(ilam));
						[~, ~, models(ilam).R2(xv, 1)] = obj.getModelResidualsAndR2(a_xv, yFit, th);
						models(ilam).trainingLoss(xv, 1) = obj.MSELoss(a_xv,yFit);
						models(ilam).nullLossTraining(xv, 1) = obj.MSELoss(a_xv,mean(a_xv).*ones(size(a_xv)));
						models(ilam).nullLossTest(xv, 1) = obj.MSELoss(a_test,mean(a_test).*ones(size(a_test)));
						models(ilam).testLoss(xv, 1) = obj.MSELoss(a_test,obj.calcYfit(th, X_test));

						
						if strcmpi(Mode, 'check-lam') && ~suppressPlot
							disp(['	lam: ' num2str(lam(ilam)) ' | TestLoss: ' num2str(models(ilam).testLoss(xv, 1))])
							if lam(ilam) == 0
								plot(ax, obj.calcYfit(th, X_test), 'k-', 'linewidth',3, 'DisplayName', num2str(lam(ilam)))
							else							
								plot(ax, obj.calcYfit(th, X_test), 'color', C(ilam, :), 'DisplayName', num2str(lam(ilam)))
							end
						end
					end
				end
				for ilam = 1:numel(lam)
					models(ilam).meanTestLoss = mean([models(ilam).testLoss(:, 1)]);
					models(ilam).meanTrainingLoss = mean([models(ilam).trainingLoss(:, 1)]);
				end

				% 
				% save everything to the xval structure. If we have a matching set of k-codes, then we should append, else we will replace
				% 
                obj.collatedResults(d).XvalResults(n).models = models;
                obj.collatedResults(d).XvalResults(n).nests = nests;
% 				if strcmpi(Mode, 'k-fold')
% 					for iModel = 1:numel(lam)
% 						if ~sum(ismember([obj.collatedResults(d).XvalResults(n).models.lam], lam(iModel)))
% 							obj.collatedResults(d).XvalResults(n).models = [obj.collatedResults(d).XvalResults(n).models, models(iModel)];
% 						end
% 					end
% 				else
% 					error('rbf, not tested')
% 					obj.collatedResults(d).XvalResults(n).models = models;
% 				end
				obj.analysis.flush.n = n;
	            obj.analysis.flush.d = d;
	            obj.analysis.flush.X = X;
				obj.analysis.flush.a = a;
			end
			
			if strcmpi(Mode, 'check-lam') && ~suppressPlot
				legend(ax, 'show');
				plot(ax2, [models.nullLossTraining], 'b--', 'DisplayName', 'Null Loss - Training')
				plot(ax2, [models.nullLossTest], 'r--', 'DisplayName', 'Null Loss - Test')

				plot(ax2, [models.meanTrainingLoss], 'b-o', 'DisplayName', 'Training Loss')
				plot(ax2, [models.meanTestLoss], 'r-o', 'DisplayName', 'Test Loss')
				xticks(ax2, 1:length(obj.collatedResults(d).XvalResults(n).models));
				xticklabels(ax2, lamLabel);
				title(ax2, 'Loss vs Regularization')
				xlabel(ax2, 'lambda')
				ylabel(ax2, 'loss')
				legend(ax2, 'show')
				xtickangle(ax2,90);
			elseif ~suppressPlot
				obj.xValLossPlotVsLam(d, n);
			end

			% 
			% 	Update selectBestLam(obj, d, n)
			% 
			obj.selectBestLam(d, n)
            disp('Complete. ~~')
		end
		

		function mouseLevelXval(obj, d, n, modelNum, k, nLamsPerRound, useSingle)
            try
                disp('==================================================================================')
                disp('==		Running AutoXval for multiple datasets...							  ==') 
                disp('==================================================================================') 
                jobID = randi(10000000);
                % 
                % 	Autoruns autoXval(obj, d, n, nRounds, k, nLamsPerRound) for all datasets, d
                % 
                % 	d = vector of dataset idx
                % 	n = vector of nest idx or 'all'
                % 	If only one type of model saved in the set, then just leave modelNum empty, or set to 1
                % 
                if nargin < 7
                	useSingle = false;
            	elseif useSingle
            		warning('Using single point precision.')
            	end
                if nargin < 2 || isempty(d)
                    d = 1:numel(obj.collatedResults);
                end
                if nargin < 3 || isempty(n)
                    n = 'all';
                end
                if nargin < 4 || isempty(modelNum)
                    modelNum = 1;
                end
                modelName = fieldnames(obj.collatedResults(1).decoding);
                modelName = modelName{modelNum};
                if nargin < 5 || isempty(k)
                    k = 20;
                end
                if nargin < 6 || isempty(nLamsPerRound)
                    nLamsPerRound = 20;
                end
                for id = d
	                seshCode = obj.collatedResults(id).sessionID;
                	roundID = ['JobID: ' num2str(jobID), ' | Current Signal ' seshCode ' | d=' num2str(id)];
                	obj.collatedResults(id).kfoldSets.modelName = modelName;
                    disp('==================================================================================') 
                    disp(['	Initiating for dataset ' num2str(find(d == id)) ' of ' num2str(numel(d))])
                    disp('    ')
                    obj.progressBar(find(d == id), numel(d), false, 1)
                    if strcmpi(n, 'all')
                        eval(['n_d = 1:numel(obj.collatedResults(id).decoding.' modelName '.predictorSet);'])
                    else
                        n_d = n;
                    end
                    obj.collatedResults(id).jobID = jobID;
                    for in_d = n_d
                        disp(['	Working on dataset ' num2str(find(d == id)) ' of ' num2str(numel(d)) ' | Nest #'])
                        obj.progressBar(find(n_d == in_d), numel(n_d), true, 1)
                        obj.autoXval(id, in_d, modelName, k, nLamsPerRound, useSingle);
                        
                        obj.analysis.flush = []; % free up memory immediately before saving
                        % obj.save;
                        % mailAlert(['mouseLevelXval Decoding Job' num2str(jobID) ' in Progress. Now complete: ' seshCode ' n=' num2str(in_d) '/' num2str(numel(n_d)) ' d=' num2str(find(d == id)) '/' num2str(numel(d))], roundID);
                    end
                    % 
                    % 	Remove spent Stats fields to save space
                    % 
                end
            catch EX
                msg = ['Exception Thrown: ' EX.identifier ' | ' EX.message '\n\n' roundID];
                alert = ['ERROR in mouseLevelXval Decoding Job in Progress.']; 
                mailAlert(alert, msg);
                rethrow(EX)
            end
			disp('==================================================================================') 
			disp('Complete.')
			mailAlert(['mouseLevelXval Decoding Job' num2str(jobID) ' COMPLETE without errors!']);
		end
		function refitXval(obj, dd, nn, lam)
            
			if nargin < 2
				dd = 1:numel(obj.collatedResults);
			end
			if isfield(obj.collatedResults(1).kfoldSets,'modelName')
				modelName = obj.collatedResults(1).kfoldSets.modelName;
			else
				modelName = fieldnames(obj.collatedResults(1).decoding);
				modelName = modelName{1};
			end
			if nargin < 3
				eval(['nn = 1:numel(obj.collatedResults(dd(1)).decoding.' modelName '.n);'])
			end
			disp('==================================================================================')
            disp('==		Refitting Xval fits...												  ==') 
            disp('==================================================================================') 
			try
				for d = dd		
					disp(['Dataset:' obj.collatedResults(d).sessionID])
                    obj.collatedResults(d).refit = [];
					obj.progressBar(find(dd==d), numel(dd), false, 1)			
                    

					for n = nn
% 						obj.progressBar(find(nn==n), numel(nn), true, 1)
						if nargin < 4 || isempty(kfoldID)
							kfoldID = obj.collatedResults(d).kfoldSets.ID;
							k = obj.collatedResults(d).kfoldSets.k;
						end
						if nargin < 5
							lam = obj.collatedResults(d).XvalResults(n).bestLam;
% 							disp([num2str(n) '		Using best lam=' num2str(lam)])
						end						
						% 
						% 	Collect X and a from file
						% 
						
						eval(['X = obj.collatedResults(d).decoding.' modelName '.X(1:n,:);'])
						eval(['a = obj.collatedResults(d).decoding.' modelName '.y{end};'])
						eval(['dfe = obj.collatedResults(d).decoding.' modelName '.stats{1, n}.dfe;'])
						meanAloss = []; 
						modelSquaredLoss = [];
						th = []; 
						se_model = []; 
						se_th = [];
						signifCoeff= [];
						Resid = [];
						std_Resid = [];
						explainedVarianceR2 = [];
						AIC = [];
						AICc = [];
						nAIC = [];
						BIC = [];
						% 
						% 	Now refit the model with lam
						% 
						% disp(['XX.T is pseudo-invertible! Using analytical RIDGE solution, lambda = ', num2str(lam)])
						% 
						% if matrix is invertible, we will use analytical solution
						% 
						% 
						% 	Combine singular variables!
						% 
						singularIndicies = [];
						for ir = 2:size(X,1)
							if sum(X(ir,:)) == size(X,2)
								singularIndicies(end+1) = ir;
							end
                        end
                        Xfix = X;
                        if ~isempty(singularIndicies)
                            Xfix(singularIndicies,:) = []; 
                        end
						% 
						% 
						% 
						XtX = Xfix*Xfix.';
						th = (XtX+lam.*eye(size(XtX, 1)))\Xfix*a.';
						% 
						% 	Return the yFit
						% 
						yFit = th.'*Xfix;
						[se_model, se_th, CVmat, signifCoeff] = obj.standardErrorOfModelAndTh(XtX, th, a, yFit, lam);
						[Resid, std_Resid, explainedVarianceR2] = obj.getModelResidualsAndR2(a, yFit, th);	
                        [AIC, AICc, nAIC, BIC] = testAIC(a, th, yFit);
                        meanAloss = 1/numel(a)*sum((a - mean(a)).^2);
						modelSquaredLoss = 1/numel(a)*sum((a - yFit).^2);	
						% 
						% 	Add back the singular components
						% 
                        if ~isempty(singularIndicies)
                            if n == max(nn)
                                disp(['   Singular correction on nest: ' mat2str(singularIndicies)])
                            end
                            th = [th(1:singularIndicies(1)-1); nan(numel(singularIndicies),1); th(singularIndicies(1):end)];
                            se_th = [se_th(1:singularIndicies(1)-1); nan(numel(singularIndicies),1); se_th(singularIndicies(1):end)];
                        end
                            

						CImin = th - abs(tinv(.025,dfe)).*se_th;
						CImax = th + abs(tinv(.025,dfe)).*se_th;
						close


						% 
						% 	Compile results
						%
						eval(['obj.collatedResults(d).refit.predictorKey = obj.collatedResults(d).decoding.' modelName '.predictorKey;'])
						eval(['obj.collatedResults(d).refit.trials_in_range_first = obj.collatedResults(d).decoding.' modelName '.trials_in_range_first;'])
						eval(['obj.collatedResults(d).refit.Conditioning = obj.collatedResults(d).decoding.' modelName '.Conditioning;'])
						eval(['obj.collatedResults(d).refit.Link = obj.collatedResults(d).decoding.' modelName '.Link;'])
						eval(['obj.collatedResults(d).refit.predictorNames = obj.collatedResults(d).decoding.' modelName '.predictorNames;'])
						eval(['obj.collatedResults(d).refit.n = obj.collatedResults(d).decoding.' modelName '.n;'])
						obj.collatedResults(d).refit.b{n,1} = th;
						obj.collatedResults(d).refit.CImin{n,1} = CImin;
						obj.collatedResults(d).refit.CImax{n,1} = CImax;
						obj.collatedResults(d).refit.stats{n,1}.dfe = dfe;
						obj.collatedResults(d).refit.stats{n,1}.lam = lam;
						obj.collatedResults(d).refit.stats{n,1}.beta = th;
						obj.collatedResults(d).refit.stats{n,1}.s = se_model;
						obj.collatedResults(d).refit.stats{n,1}.se = se_th;
						obj.collatedResults(d).refit.stats{n,1}.covb = CVmat;
						obj.collatedResults(d).refit.y{n,1} = a;
						obj.collatedResults(d).refit.yfit{n,1} = yFit;
						obj.collatedResults(d).refit.LossImprovement(n,1) = modelSquaredLoss/meanAloss;
						obj.collatedResults(d).refit.BIC(n,1) = BIC;
						obj.collatedResults(d).refit.AIC(n,1) = AIC;
						obj.collatedResults(d).refit.AICc(n,1) = AICc;
						obj.collatedResults(d).refit.nAIC(n,1) = nAIC;
						obj.collatedResults(d).refit.Rsq(n,1) = explainedVarianceR2;
						eval(['obj.collatedResults(d).refit.ESS(n,1) = obj.collatedResults(d).decoding.' modelName '.ESS(n);'])
						eval(['obj.collatedResults(d).refit.RSS(n,1) = obj.collatedResults(d).decoding.' modelName '.ESS(n);'])
						eval(['obj.collatedResults(d).refit.predictorSet = obj.collatedResults(d).decoding.' modelName '.predictorSet;'])
						obj.collatedResults(d).refit.X = X;
						obj.collatedResults(d).refit.Xn{n,1} = X;
                        obj.collatedResults(d).refit.singularIndicies{n,1} = singularIndicies;
						obj.collatedResults(d).refit.kfoldID(n,1) = kfoldID;
						obj.collatedResults(d).refit.k(n,1) = k;						 
					end
				end
				% 
				%	Create obj with all the results together	 
				% 
				alert = ['ALL DONE: Decoding Refit XvalResults COMPLETE. d=' num2str(max(d)) ' n=' mat2str(max(nn))]; 
			    mailAlert(alert);
		    catch EX
                alert = ['ERROR in refitXval']; 
                msg = ['Exception Thrown: ' EX.identifier ' | ' EX.message ];
                mailAlert(alert, msg);
                rethrow(EX)
            end
			disp('==================================================================================') 
			disp('Complete. Ready to get stats on refit data')
		end





		function conditionPCA(obj, minPCs, killSessions)
			% 
			% 	Assign good indicies based on these criteria (default)
			% 
			% 	minPCs = 30
			% 
			if nargin < 3
				killSessions = false;
			end
			if nargin < 2
				minPCs = 30;
			end
			sessionsToKill = {'DLSred',...
			'H6_SNc_d23_1',...
			'H6_SNc_d23_2',...
			'H6_SNc_d23_3',...
			'H6_SNc_d22_1',...
			'H6_SNc_d22_2',...
			'H6_SNc_d22_3',...
			'H6_SNc_d22_4',...
			'H6_SNc_d22_5',...
			'H6_SNc_d21',...
			'H6_SNc_d20',...
			'B6_SNc_12',...
			'B6_SNc_13',...
			'B6_SNc_14_1',...
			'B6_SNc_15_1',...
			'B6_SNc_15_2',...
			'B3_SNc_21',...
			'B3_SNc_20',...
			'B5_SNc_19',...
			'B5_SNc_20_1',...
			'B5_SNc_20_2',...
			'B5_SNc_20_3',...
			'B5_SNc_20_4',...
			'B5_SNc_21_1',...
			'B5_SNc_21_2',...
			'B5_SNc_17',...
			'B5_SNc_19',...
			'B6_SNc_13',...
			'H3_SNc_17',...
			'H3_SNc_18',...
			'H3_SNc_19',...
			'H3_SNc_20',...
			'H5_SNc_11',...
			'H5_SNc_17',...
			'H5_SNc_18',...
			'H5_SNc_19',...
			'H7_SNc_12',...
			'H7_SNc_13',...
			'H7_SNc_14_2',...
			'H7_SNc_15_1',...
			'H7_SNc_15_2',...
			'H7_SNc_15_3',...
			'H7_SNc_15_4',...
			'H7_SNc_15_5',...
			'H7_SNc_16_1',...
			'H7_SNc_16_2',...
			'H7_SNc_16_3',...
			};
			for d = 1:numel(obj.collatedResults)
				if numel(obj.collatedResults(d).PCA.mu) < minPCs
					obj.collatedResults(d).QCflag = true;
				elseif killSessions && sum(contains(obj.collatedResults(d).sessionID,sessionsToKill))>0
					obj.collatedResults(d).QCflag = true;
				else
					obj.collatedResults(d).QCflag = false;
				end
			end
		end
		function plotPCA(obj,killSessions,Mode,idxs)
			obj.conditionPCA(30, killSessions);
        	% 
        	% 	Mode: 'summary': plots a summary of explained variance of PCs and top 3 PCs
        	% 		  
    		excludetime = obj.collatedResults(1).PCA.excludetime;
    		maxWindow_trimRHS = obj.collatedResults(1).PCA.maxWindow_trimRHS;
            enforcedlatency = obj.collatedResults(1).PCA.enforcedlatency;

            if nargin < 4
            	idxs = find(~[obj.collatedResults.QCflag]);
        	end
    		if nargin < 3
    			Mode = 'summary';
			end

			f = figure;
			if strcmpi(Mode, 'summary')
				ax_rsq = subplot(1,2,1);
				hold(ax_rsq, 'on')
				ylim(ax_rsq, [0, 100])
				ylabel(ax_rsq, '% Variance Explained')
				title(ax_rsq, ['n = ' num2str(numel(idxs)) '/' num2str(numel(obj.collatedResults))])
				xlabel(ax_rsq, 'PC#')
				xlim(ax_rsq, [1,10])
				ax_pc1 = subplot(3,2,2);
				ax_pc2 = subplot(3,2,4);
				ax_pc3 = subplot(3,2,6);
				title(ax_pc1,'PC #1')
				title(ax_pc2,'PC #2')
				title(ax_pc3,'PC #3')
				xlim(ax_pc1, [0,maxWindow_trimRHS/1000])
				xlim(ax_pc2, [0,maxWindow_trimRHS/1000])
				xlim(ax_pc3, [0,maxWindow_trimRHS/1000])
				hold(ax_pc1, 'on')
				hold(ax_pc2, 'on')
				hold(ax_pc3, 'on')

				plot(ax_pc1, [0,7], [0,0], 'k-', 'HandleVisibility', 'off', 'linewidth',3)
				plot(ax_pc2, [0,7], [0,0], 'k-','HandleVisibility', 'off', 'linewidth',3)
				plot(ax_pc3, [0,7], [0,0], 'k-','HandleVisibility', 'off', 'linewidth',3)
				
				for dd = 1:numel(idxs)
                    d = idxs(dd);
					rsq{dd,1} = obj.collatedResults(d).PCA.explained;
					plot(ax_rsq, rsq{dd}, '-', 'color', [0.2,0.2,0.2], 'DisplayName', obj.collatedResults(d).sessionID)
					s1{dd,1} = obj.collatedResults(d).PCA.score(:,1);
					s2{dd,1} = obj.collatedResults(d).PCA.score(:,2);
					s3{dd,1} = obj.collatedResults(d).PCA.score(:,3);
					if mean(s1{dd}) < 0
						s1{dd} = -1.*s1{dd};
					end
					if mean(s2{dd}(end-100:end)) < 0
						s2{dd} = -1.*s2{dd};
					end
					if mean(s3{dd}(end-100:end)) < 0
						s3{dd} = -1.*s3{dd};
					end
					plot(ax_pc1, linspace(excludetime,maxWindow_trimRHS/1000,maxWindow_trimRHS-excludetime*1000), s1{dd}, '-', 'color', [0.2,0.2,0.2],'HandleVisibility', 'off')
					plot(ax_pc2, linspace(excludetime,maxWindow_trimRHS/1000,maxWindow_trimRHS-excludetime*1000), s2{dd}, '-', 'color', [0.2,0.2,0.2],'HandleVisibility', 'off')
					plot(ax_pc3, linspace(excludetime,maxWindow_trimRHS/1000,maxWindow_trimRHS-excludetime*1000), s3{dd}, '-', 'color', [0.2,0.2,0.2],'HandleVisibility', 'off')
				end
				rsq10 = cellfun(@(x) x(1:10), rsq,'uniformoutput', false);
				mrsq = mean(cell2mat(rsq10'), 2);
				ms1 = mean(cell2mat(s1'),2);
				ms2 = mean(cell2mat(s2'),2);
				ms3 = mean(cell2mat(s3'),2);

				plot(ax_rsq, mrsq, 'r-o', 'linewidth', 4)
				plot(ax_pc1, linspace(excludetime,maxWindow_trimRHS/1000,maxWindow_trimRHS-excludetime*1000), ms1, 'r-', 'linewidth', 4)
				plot(ax_pc2, linspace(excludetime,maxWindow_trimRHS/1000,maxWindow_trimRHS-excludetime*1000), ms2, 'r-', 'linewidth', 4)
				plot(ax_pc3, linspace(excludetime,maxWindow_trimRHS/1000,maxWindow_trimRHS-excludetime*1000), ms3, 'r-', 'linewidth', 4)
				x1 = get(ax_pc1, 'ylim');
				x2 = get(ax_pc2, 'ylim');
				x3 = get(ax_pc3, 'ylim');
				xl = min([x1(1), x2(1), x3(1)]);
				xu = max([x1(2), x2(2), x3(2)]);
				ylim(ax_pc1,[xl, xu])
				ylim(ax_pc2,[xl, xu])
				ylim(ax_pc3,[xl, xu])
				linkaxes([ax_pc1,ax_pc2,ax_pc3],'xy')
			end
		end





		function gatherDivergenceIndicies(obj)
			nEE = 0;
			nER = 0;
			nRE = 0;
			nRR = 0;
			% obj.analysis.divergenceIndex.meanEX = {};
			% obj.analysis.divergenceIndex.EX_CIlow = {};
			% obj.analysis.divergenceIndex.EX_CIhi = {};

			% obj.analysis.divergenceIndex.meanRX = {};
			% obj.analysis.divergenceIndex.RX_CIlow = {};
			% obj.analysis.divergenceIndex.RX_CIhi = {};

			% obj.analysis.convergenceIndex.meanXE = {};
			% obj.analysis.convergenceIndex.XE_CIlow = {};
			% obj.analysis.convergenceIndex.XE_CIhi = {};

			% obj.analysis.convergenceIndex.meanXR = {};
			% obj.analysis.convergenceIndex.XR_CIlow = {};
			% obj.analysis.convergenceIndex.XR_CIhi = {};

			for d = 1:numel(obj.collatedResults)
				nEE = nEE + obj.collatedResults(d).Stat.n.nEE;
				nER = nER + obj.collatedResults(d).Stat.n.nER;
				nRE = nRE + obj.collatedResults(d).Stat.n.nRE;
				nRR = nRR + obj.collatedResults(d).Stat.n.nRR;
				if d == 1
					obj.analysis.composite.meanEX = obj.collatedResults(d).Stat.divergenceIndex.meanEX;
					obj.analysis.composite.meanRX = obj.collatedResults(d).Stat.divergenceIndex.meanRX;
					obj.analysis.composite.meanXE = obj.collatedResults(d).Stat.convergenceIndex.meanXE;
					obj.analysis.composite.meanXR = obj.collatedResults(d).Stat.convergenceIndex.meanXR;
				else
					obj.analysis.composite.meanEX = nansum([obj.analysis.composite.meanEX .* ((d-1)./d); obj.collatedResults(d).Stat.divergenceIndex.meanEX]);
					obj.analysis.composite.meanRX = nansum([obj.analysis.composite.meanRX .* ((d-1)./d); obj.collatedResults(d).Stat.divergenceIndex.meanRX]);
					obj.analysis.composite.meanXE = nansum([obj.analysis.composite.meanXE .* ((d-1)./d); obj.collatedResults(d).Stat.convergenceIndex.meanXE]);
					obj.analysis.composite.meanXR = nansum([obj.analysis.composite.meanXR .* ((d-1)./d); obj.collatedResults(d).Stat.convergenceIndex.meanXR]);
				end
				% obj.analysis.divergenceIndex(d).meanEX = obj.collatedResults(d).Stat.divergenceIndex.meanEX;
				% obj.analysis.divergenceIndex(d).meanRX = obj.collatedResults(d).Stat.divergenceIndex.meanRX;
				% obj.analysis.convergenceIndex(d).meanXE = obj.collatedResults(d).Stat.divergenceIndex.meanXE;
				% obj.analysis.convergenceIndex(d).meanXR = obj.collatedResults(d).Stat.divergenceIndex.meanXR;
				obj.analysis.n.nEE = nEE;
				obj.analysis.n.nER = nER;
				obj.analysis.n.nRE = nRE;
				obj.analysis.n.nRR = nRR;
			end


		end
		function plotDivergenceIndicies(obj, Mode, suppressNsave)
			% 
			% 	Mode: 'composite', 'overlay'
			% 
			obj.gatherDivergenceIndicies
			if nargin < 2
				Mode = 'composite';
			end
			if nargin < 3
				suppressNsave = [];
			end
			
			c = obj.collatedResults(1).Stat.centers/1000;

			[f, ax] = makeStandardFigure(4,[2,2]);
			hold(ax(1), 'on');
            hold(ax(2), 'on');
            hold(ax(3), 'on');
            hold(ax(4), 'on');
            plot(ax(1), [c(1), c(end)], [0,0], 'k-', 'LineWidth',1)
            plot(ax(2), [c(1), c(end)], [0,0], 'k-', 'LineWidth',1)
            plot(ax(3), [c(1), c(end)], [0,0], 'k-', 'LineWidth',1)
            plot(ax(4), [c(1), c(end)], [0,0], 'k-', 'LineWidth',1)
            title(ax(1), ['diverg: EE(' num2str(obj.analysis.n.nEE) ')-ER(' num2str(obj.analysis.n.nER) ')'])
            title(ax(3), ['convergence: RE-EE'])
            
            ylabel(ax(1),'nth trial selectivity')
            title(ax(2), ['divergence: RE(' num2str(obj.analysis.n.nRE) ')-RR(' num2str(obj.analysis.n.nRR) ')'])
            ylabel(ax(3),'n-1th trial selectivity')
            title(ax(4), ['convergence: RR-ER'])
            xlim(ax(1), [-10,3])
            xlim(ax(2), [-10,3])
            xlim(ax(3), [-10,3])
            xlim(ax(4), [-10,3])

            if strcmpi(Mode, 'composite')
            	plot(ax(1), c, obj.analysis.composite.meanEX, 'r-', 'LineWidth',3)				
				plot(ax(2), c, obj.analysis.composite.meanRX, 'r-', 'LineWidth',3)
				plot(ax(3), c, -1.*obj.analysis.composite.meanXE, 'r-', 'LineWidth',3)
				plot(ax(4), c, -1.*obj.analysis.composite.meanXR, 'r-', 'LineWidth',3)
        	elseif strcmpi(Mode, 'overlay')
        		for d = 1:numel(obj.collatedResults)
	        		plot(ax(1), c, obj.collatedResults(d).Stat.divergenceIndex.meanEX, 'r-', 'LineWidth',3)
					% plot(ax(1), c, obj.Stat.divergenceIndex.EX_CIlow, 'k-', 'LineWidth',2)
					% plot(ax(1), c, obj.Stat.divergenceIndex.EX_CIhi, 'k-', 'LineWidth',2)
					plot(ax(2), c, obj.collatedResults(d).Stat.divergenceIndex.meanRX, 'r-', 'LineWidth',3)
					% plot(ax(2), c, obj.Stat.divergenceIndex.RX_CIlow, 'k-', 'LineWidth',2)
					% plot(ax(2), c, obj.Stat.divergenceIndex.RX_CIhi, 'k-', 'LineWidth',2)					
					plot(ax(3), c, -1.*obj.collatedResults(d).Stat.convergenceIndex.meanXE, 'r-', 'LineWidth',3)
					% plot(ax(3), c, -1.*obj.Stat.convergenceIndex.XE_CIlow, 'k-', 'LineWidth',2)
					% plot(ax(3), c, -1.*obj.Stat.convergenceIndex.XE_CIhi, 'k-', 'LineWidth',2)
					plot(ax(4), c, -1.*obj.collatedResults(d).Stat.convergenceIndex.meanXR, 'r-', 'LineWidth',3)
					% plot(ax(4), c, -1.*obj.Stat.convergenceIndex.XR_CIlow, 'k-', 'LineWidth',2)
					% plot(ax(4), c, -1.*obj.Stat.convergenceIndex.XR_CIhi, 'k-', 'LineWidth',2)
				end
    		else 
    			error('undefined Mode')
    		end        		
			if ~isempty(suppressNsave), figureName = ['DivergenceIndex_' obj.Stat.outcomeMode.Mode];, obj.suppressNsaveFigure(suppressNsave, figureName, f), close(f), end
		end
		function compositeANOVAdataset(obj, idx)
			% 
			% 	for baselineANOVAwithLick or baselineANOVAidx objects, called by A2ElevelANOVA(obj,nLevels,idx, overwrite)
			% 	NB: switch C and D levels for 3-way on baselineANOVAidx objs with no lick stuff
			% 
			% A_level = n-1th outcome 
			% B_level = nth outcome
			% C_level = # of licks in baseline
			% D_level = session ID
			% E_level = mouse ID (redundant with session so not really used)
			% 	
			% 
			if nargin < 2
				idx = 1:numel(obj.collatedResults);
			end
			% 
			% 	Gather 1 result slot by collating all the A_level, B_level and data across the sessionIdxs
			%
			if ~isfield(obj.analysis,'mouseName')
				for ii = 1:numel(obj.collatedResults) 
					obj.analysis.mouseName{ii} = strsplit(obj.collatedResults(ii).sessionID,'_');
					obj.analysis.mouseName{ii} = obj.analysis.mouseName{ii}{1};
				end
			end
			mice = unique(obj.analysis.mouseName);
			% 
			% 	Start by gathering the datasets
			% 
			% for each position in baseline gather across sessions and also track which animal and session
			data = cell(1,numel(obj.collatedResults(1).results));
			A_level = cell(1,numel(obj.collatedResults(1).results));
			B_level = cell(1,numel(obj.collatedResults(1).results));
			C_level = cell(1,numel(obj.collatedResults(1).results));
			D_level = cell(1,numel(obj.collatedResults(1).results));
			E_level = cell(1,numel(obj.collatedResults(1).results));
			for M = 1:numel(mice) 
				midx = find(contains(obj.analysis.mouseName,mice{M}));
				for dd = 1:numel(midx)
					d = midx(dd);
					if ismember(d, idx)
						for pos = 1:numel(obj.collatedResults(d).results)
							data{1,pos} = [data{1,pos};obj.collatedResults(d).results{1, pos}.cellData.data];  	% df/f
							A_level{1,pos} = [A_level{1,pos};obj.collatedResults(d).results{1, pos}.cellData.A_level'];   % n-1 category
							B_level{1,pos} = [B_level{1,pos};obj.collatedResults(d).results{1, pos}.cellData.B_level'];  % nth category
							% C_level{1,pos} = [C_level{1,pos};obj.collatedResults(d).results{1, pos}.cellData.C_level']; % not imp yet but could be EMG spikes
							% D_level{1,pos} = [D_level{1,pos};obj.collatedResults(d).results{1, pos}.cellData.D_level']; % session number, to be assigned
							E_level{1,pos} = [E_level{1,pos};obj.collatedResults(d).results{1, pos}.cellData.lickLevel']; % mouse, to be assigned
							MM = cell(size(obj.collatedResults(d).results{1, pos}.cellData.data));
							MM(:) = mice(M);
							D_level{1,pos} = [D_level{1,pos}; MM];
							SS = cell(size(obj.collatedResults(d).results{1, pos}.cellData.data));
							SS(:) = {obj.collatedResults(d).sessionID};
							C_level{1,pos} = [C_level{1,pos}; SS];
						end
					end
				end
			end
			obj.analysis.A_level = A_level;
			obj.analysis.B_level = B_level;
			obj.analysis.C_level = C_level;
			obj.analysis.D_level = D_level;
			obj.analysis.E_level = E_level;
			obj.analysis.data = data;
			obj.analysis.nMice = numel(unique(D_level{1}));
			obj.analysis.nSesh = numel(unique(C_level{1}));
		end
		function A2ElevelANOVA(obj,nLevels,idx, overwrite)
			% 
			% 	for baselineANOVAwithLick or baselineANOVAidx objects
			% 
			% 	To just run 17 MDT seshs, use: A2ElevelANOVA(obj,4, [27:29,38,39,40,47,48,97:101,117,118,131,132],true) 
			% 
            if nargin < 4
                overwrite = false;
            end
			if nargin < 3 || isempty(idx)
				idx = 1:numel(obj.collatedResults);
			elseif strcmpi(idx, 'MDT')
				obj.flagMDT;
				idx = find([obj.collatedResults.MDT]);
				overwrite = true;
			end
			if nargin < 2
				nLevels = 4;
			end
			if ~isfield(obj.analysis, 'A_level') || overwrite
				compositeANOVAdataset(obj, idx);
			end
			A_level = obj.analysis.A_level;
			B_level = obj.analysis.B_level;
			C_level = obj.analysis.C_level;
			D_level = obj.analysis.D_level;
			E_level = obj.analysis.E_level;
			data = obj.analysis.data;
			for pos = 1:numel(obj.collatedResults(1).results)
				if nLevels == 2
					levels = {A_level{pos},B_level{pos}};
				elseif nLevels == 3
					levels = {A_level{pos},B_level{pos},E_level{pos}};%C_level{pos}};
				elseif nLevels == 4
					levels = {A_level{pos},B_level{pos},C_level{pos},E_level{pos}};
				elseif nLevels == 5
					levels = {A_level{pos},B_level{pos},C_level{pos},E_level{pos},D_level{pos}};
				end
				[p{pos},tbl{pos},stats{pos}] = anovan(data{pos},levels);
			end
			obj.analysis.p = p;
			obj.analysis.tbl = tbl;
			obj.analysis.stats = stats;

			obj.compositeANOVAFindex
		end
		function compositeANOVAFindex(obj)
			% 
			% 	Use after A2ElevelANOVA(obj,nLevels,idx, overwrite) to plot composite F-index
			% 
			c = obj.collatedResults(1).centers/1000;

			for ic = 1:numel(c)
				F_nm1(ic) = obj.analysis.tbl{1, ic}{2,6};
				F_n(ic) = obj.analysis.tbl{1, ic}{3,6};
				F_l(ic) = obj.analysis.tbl{1, ic}{4,6};
				F_s(ic) = obj.analysis.tbl{1, ic}{5,6};
				nm1Score(ic) = (F_nm1(ic) - F_n(ic))/(F_nm1(ic) + F_n(ic));
				sig_nm1(ic) = 1*(obj.analysis.tbl{1, ic}{2,7} < 0.05);
				nScore(ic) = (F_n(ic) - F_nm1(ic))/(F_n(ic) + F_nm1(ic));
				sig_n(ic) = 1*(obj.analysis.tbl{1, ic}{3,7} < 0.05);
				sig_l(ic) = 1*(obj.analysis.tbl{1, ic}{4,7} < 0.05);
				sig_s(ic) = 1*(obj.analysis.tbl{1, ic}{5,7} < 0.05);

				nInfluence(ic) = (F_n(ic))/(F_n(ic) + F_nm1(ic));
				nm1Influence(ic) = (F_nm1(ic))/(F_n(ic) + F_nm1(ic));

				n3Influence(ic) = (F_n(ic))/(F_n(ic) + F_nm1(ic) + F_l(ic));
				nm13Influence(ic) = (F_nm1(ic))/(F_n(ic) + F_nm1(ic) + F_l(ic));
				l3Influence(ic) = (F_l(ic))/(F_n(ic) + F_nm1(ic) + F_l(ic));


				n4Influence(ic) = (F_n(ic))/(F_n(ic) + F_nm1(ic) + F_l(ic) + F_s(ic));
				nm14Influence(ic) = (F_nm1(ic))/(F_n(ic) + F_nm1(ic) + F_l(ic) + F_s(ic));
				l4Influence(ic) = (F_l(ic))/(F_n(ic) + F_nm1(ic) + F_l(ic) + F_s(ic));
				s4Influence(ic) = (F_s(ic))/(F_n(ic) + F_nm1(ic) + F_l(ic) + F_s(ic));
			end
			sig_nm1(find(~sig_nm1))=nan;
			sig_n(~sig_n)=nan;
			% [f,ax] = makeStandardFigure(1,[1,1]);
			% plot(ax,(c+0.5*0), nm1Score, 'k-', 'displayname', 'n-1th selectivity')
			% hold(ax, 'on')
			% plot(ax,(c+0.5*0), sig_nm1, 'k-', 'displayname', 'n-1th p<0.05', 'linewidth',5)
			% plot(ax,(c+0.5*0), nScore, 'r-', 'displayname', 'nth selectivity')
			% plot(ax,(c+0.5*0), sig_n-2, 'r-', 'displayname', 'nth p<0.05', 'linewidth',5)
			% legend(ax,'show')
			% xlabel(ax,'time (s relative to lamp-off)')
			% ylabel(ax,'Selectivity Index')
			% xlim(ax,[(c(1)+0.5*0), (c(end)+0.5*0)])

			[f,ax] = makeStandardFigure(1,[1,1]);
			hold(ax, 'on')
			plot(ax,(c+0.5*0), nm1Influence, 'k-', 'displayname', 'n-1th selectivity')
			plot(ax,(c+0.5*0), sig_nm1, 'k-', 'displayname', 'n-1th p<0.05', 'linewidth',5)
			plot(ax,(c+0.5*0), nInfluence, 'r-', 'displayname', 'nth selectivity')
			plot(ax,(c+0.5*0), sig_n+0.1, 'r-', 'displayname', 'nth p<0.05', 'linewidth',5)
			xlabel(ax,'Time (s relative to lamp-off)')
			ylabel(ax,'Relative Influence')
			xlim(ax,[(c(1)+0.5*0), (c(end)+0.5*0)])

			[f,ax] = makeStandardFigure(1,[1,1]);
			hold(ax, 'on')
			plot(ax,(c+0.5*0), nm13Influence, 'k-', 'displayname', 'n-1th selectivity')
			plot(ax,(c+0.5*0), sig_nm1, 'k-', 'displayname', 'n-1th p<0.05', 'linewidth',5)
			plot(ax,(c+0.5*0), n3Influence, 'r-', 'displayname', 'nth selectivity')
			plot(ax,(c+0.5*0), sig_n+0.01, 'r-', 'displayname', 'nth p<0.05', 'linewidth',5)
			plot(ax,(c+0.5*0), l3Influence, 'b-', 'displayname', 'nth selectivity')
			plot(ax,(c+0.5*0), sig_l+0.02, 'b-', 'displayname', 'nth p<0.05', 'linewidth',5)
			xlabel(ax,'Time (s relative to lamp-off)')
			ylabel(ax,'Relative Influence')
			xlim(ax,[(c(1)+0.5*0), (c(end)+0.5*0)])

			[f,ax] = makeStandardFigure(1,[1,1]);
			hold(ax, 'on')
			plot(ax,(c+0.5*0), nm14Influence, 'k-', 'displayname', 'n-1th selectivity')
			plot(ax,(c+0.5*0), sig_nm1, 'k-', 'displayname', 'n-1th p<0.05', 'linewidth',5)
			plot(ax,(c+0.5*0), n4Influence, 'r-', 'displayname', 'nth selectivity')
			plot(ax,(c+0.5*0), sig_n+0.01, 'r-', 'displayname', 'nth p<0.05', 'linewidth',5)
			plot(ax,(c+0.5*0), l4Influence, 'b-', 'displayname', 'nth selectivity')
			plot(ax,(c+0.5*0), sig_l+0.02, 'b-', 'displayname', 'nth p<0.05', 'linewidth',5)
			plot(ax,(c+0.5*0), s4Influence, 'g-', 'displayname', 'nth selectivity')
			plot(ax,(c+0.5*0), sig_s+0.03, 'g-', 'displayname', 'nth p<0.05', 'linewidth',5)
			xlabel(ax,'Time (s relative to lamp-off)')
			ylabel(ax,'Relative Influence')
			xlim(ax,[(c(1)+0.5*0), (c(end)+0.5*0)])
		end
		function [results, F_nm1, F_n, nm1Score, nScore, sig_nm1, sig_n, centers,baselineWindow, dataScore] = slidingBaselineANOVA(obj,baselineLickMode,verbose)
			error('not Implemented')
			% 
			% 	For use with divergenceIndex obj!
			% 
			% 	baselineLickMode: 'off' (don't worry about lick, 2-way ANOVA)
			% 	baselineLickMode: 'exclude' (ignore trials with lick in baseline window, 2-way ANOVA)
			% 	baselineLickMode: 'include' (3-way anova including lick presence as predictor)
			% 
			% 	set datanotFstat to true if you want to use the data itself in the selectivity index. If want to use the Fstat, leave this false (default and original version)
			% 		this was added 2/23/2020, see Lab Notebook ppt on baseline analysis figure s4 finalization
			% 		(actually we get it for free, so just updating the methods. We want the dataScore output)
			% 
			if nargin < 2
				baselineLickMode = 'off';
			end
			if nargin < 3
				verbose = true;
			end
			centers = obj.collatedResults(1).Stat.centers;
			for ic = 1:numel(centers)
				results{ic} = obj.buildStaticBaselineANOVADataset(baselineWindow, obj.gFitLP.nMultibDFF.dFF, baselineLickMode, 'lampOff', centers(ic), false);
				% results{ic} = obj.buildStaticBaselineANOVADataset(baselineWindow, obj.gFitLP.nMultibDFF.dFF, 'exclude', 'lampOff', centers(ic), false);
				F_nm1(ic) = results{ic}.results.tbl{2,6};
				F_n(ic) = results{ic}.results.tbl{3,6};
				nm1Score(ic) = (F_nm1(ic) - F_n(ic))/(F_nm1(ic) + F_n(ic));
				sig_nm1(ic) = 1*(results{ic}.results.tbl{2,7} < 0.025);
				nScore(ic) = (F_n(ic) - F_nm1(ic))/(F_n(ic) + F_nm1(ic));
				sig_n(ic) = 1*(results{ic}.results.tbl{3,7} < 0.025);
				% 
				% 	Have to think here about good selectivity index from the data itself... 
				% 
			end
			sig_nm1(find(~sig_nm1))=nan;
			sig_n(~sig_n)=nan;
			if verbose
				figure
				plot((centers+0.5*0)./1000, nm1Score, 'ko-', 'displayname', 'n-1th selectivity')
				hold on
				plot((centers+0.5*0)./1000, sig_nm1, 'k-', 'displayname', 'n-1th p<0.025', 'linewidth',5)
				plot((centers+0.5*0)./1000, nScore, 'ro-', 'displayname', 'nth selectivity')
				plot((centers+0.5*0)./1000, sig_n-2, 'r-', 'displayname', 'nth p<0.025', 'linewidth',5)
				legend('show')
				xlabel('time (s relative to lamp-off)')
				ylabel('Selectivity Index')
				set(gca, 'fontsize',30)
				xlim([(centers(1)+0.5*0)./1000, (centers(end)+0.5*0)./1000])
				set(gcf,'color','w');
			end
		end
		function ANOVAparams = buildStaticBaselineANOVADataset(obj, baselineWindow, ts, baselineLickMode, refEvent, centerOffsetFromRefEvent,verbose)
			error('not Implemented')
			% 
			% 	Baseline window is relative to Lamp-Off here, unless specified
			% 		refEvent = 'lampOff' or 'cue'
			% 
			%  OLD VERSION:
			% 	Baseline window - : consider BEFORE event as baseline
			% 	Baseline window + : consider AFTER event as baseline
			%  NOW BASELINE WINDOW IS ALWAYS +, it's the center offset from ref that decides if we are before or after
			% 
			%  NEW VERSION:
			% 	centerOffsetFromRefEvent: This number of samples gets subtracted from the reference event to determine the centering of the sliding window
			% 		- : before ref event
			% 		+ : after ref event
			% 
			if nargin < 7
				verbose = true;
			end
			if nargin < 6
				centerOffsetFromRefEvent = -2500;
			end
			if nargin < 5
				refEvent = 'lampOff';
			end
			if nargin < 4
				baselineLickMode = 'exclude'; %'off', 'include'
			end
			if nargin < 3
				ts = obj.GLM.gfit;
				warning('Using 200-boxcar gfit from GLM struct')
			end
			baselineWindow = abs(baselineWindow);
			% 
			% 	We will find all trials in each 'cell' and record the mean of the baseline to the set
			% 
			% 	Factor A = (n-1 trial outcome)
			% 		level 1 = early
			% 		level 2 = rewarded
			% 
			% 	Factor B = (n trial outcome)
			% 		level 1 = early
			% 		level 2	= rewarded
			% -------------------------------------------------
        	% 
        	% 	Early vs Rew ranges in ms
        	% 
        	earlyRange = [700, 3330];
        	rewRange = [3334, 7000];
        	% earlyRange = [700, 2000];
        	% rewRange = [4000, 7000];
        	% 
            all_fl_wrtc_ms = zeros(numel(obj.GLM.lampOff_s), 1);
			all_fl_wrtc_ms(obj.GLM.fLick_trial_num) = obj.GLM.firstLick_s - obj.GLM.cue_s(obj.GLM.fLick_trial_num);
			all_fl_wrtc_ms = all_fl_wrtc_ms*1000/obj.Plot.samples_per_ms; % convert to ms
			allTrialIdx = 1:numel(all_fl_wrtc_ms);
        	% 
        	% 	We will find all trials fitting each Factor-level, then find intersections. 
        	% 	Then we will take the appropriate data from each set to make the cell-dataset
        	% 
        	ll = allTrialIdx(all_fl_wrtc_ms(1:end-1) >= earlyRange(1));
			ul = allTrialIdx(all_fl_wrtc_ms(1:end-1) <= earlyRange(2));
			A1 = ll(ismember(ll, ul));

        	ll = allTrialIdx(all_fl_wrtc_ms(1:end-1) >= rewRange(1));
			ul = allTrialIdx(all_fl_wrtc_ms(1:end-1) <= rewRange(2));
			A2 = ll(ismember(ll, ul));

        	ll = allTrialIdx(all_fl_wrtc_ms(2:end) >= earlyRange(1));
			ul = allTrialIdx(all_fl_wrtc_ms(2:end) <= earlyRange(2));
			B1 = ll(ismember(ll, ul));

        	ll = allTrialIdx(all_fl_wrtc_ms(2:end) >= rewRange(1));
			ul = allTrialIdx(all_fl_wrtc_ms(2:end) <= rewRange(2));
			B2 = ll(ismember(ll, ul));
			% NB! This is indexed as (trial n) - 1. Just for the intersections. Need to add 1 to get final trial n!
			% 
			% 	Find trial indicies for each cell.
			% 
			A1B1_idx = intersect(A1, B1) + 1;
			A2B1_idx = intersect(A2, B1) + 1;
			A1B2_idx = intersect(A1, B2) + 1;
			A2B2_idx = intersect(A2, B2) + 1;
			if isempty(A1B1_idx), error('(n-1) early (n) early factor doesn''t exist in data'),
			elseif isempty(A2B1_idx), error('(n-1) rew (n) early factor doesn''t exist in data'),
			elseif isempty(A1B2_idx), error('(n-1) early (n) rew factor doesn''t exist in data'),
			elseif isempty(A2B2_idx), error('(n-1) rew (n) rew factor doesn''t exist in data'), end
			% 
			% 	Get data for each cell:
			% 
			A_level = cell(1, numel(A1B1_idx)+numel(A2B1_idx));
			B_level = cell(1, numel(A1B1_idx)+numel(A1B2_idx));

			if strcmpi(refEvent, 'lampOff')
				if baselineWindow < 0
					error('this is obsolete. use for old version without the sliding window')
					A1B1 = nan(numel(A1B1_idx), 1);
					for iTrial = 1:numel(A1B1_idx)
						A1B1(iTrial) = mean(ts(obj.GLM.pos.lampOff(A1B1_idx(iTrial)) - abs(baselineWindow):obj.GLM.pos.lampOff(A1B1_idx(iTrial))));
						A_level{iTrial} = 'early n-1';
						B_level{iTrial} = 'early n';
					end
					A2B1 = nan(numel(A2B1_idx), 1);
					for iTrial = 1:numel(A2B1_idx)
						A2B1(iTrial) = mean(ts(obj.GLM.pos.lampOff(A2B1_idx(iTrial)) - abs(baselineWindow):obj.GLM.pos.lampOff(A2B1_idx(iTrial))));
						A_level{numel(A1B1_idx)+iTrial} = 'rewarded n-1';
						B_level{numel(A1B1_idx)+iTrial} = 'early n';
					end
					A1B2 = nan(numel(A1B2_idx), 1);
					for iTrial = 1:numel(A1B2_idx)
						A1B2(iTrial) = mean(ts(obj.GLM.pos.lampOff(A1B2_idx(iTrial)) - abs(baselineWindow):obj.GLM.pos.lampOff(A1B2_idx(iTrial))));
						A_level{numel(A1B1_idx)+numel(A2B1_idx)+iTrial} = 'early n-1';
						B_level{numel(A1B1_idx)+numel(A2B1_idx)+iTrial} = 'rewarded n';
					end
					A2B2 = nan(numel(A2B2_idx), 1);
					for iTrial = 1:numel(A2B2_idx)
						A2B2(iTrial) = mean(ts(obj.GLM.pos.lampOff(A2B2_idx(iTrial)) - abs(baselineWindow):obj.GLM.pos.lampOff(A2B2_idx(iTrial))));
						A_level{numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+iTrial} = 'rewarded n-1';
						B_level{numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+iTrial} = 'rewarded n';	
					end
				else
					A1B1 = nan(numel(A1B1_idx), 1);
					for iTrial = 1:numel(A1B1_idx)
						idxs = round(obj.GLM.pos.lampOff(A1B1_idx(iTrial))+centerOffsetFromRefEvent - abs(baselineWindow)/2 +1):round(obj.GLM.pos.lampOff(A1B1_idx(iTrial))+centerOffsetFromRefEvent + abs(baselineWindow)/2);
						A1B1(iTrial) = mean(ts(idxs));
						A_level{iTrial} = 'early n-1';
						B_level{iTrial} = 'early n';
					end
					A2B1 = nan(numel(A2B1_idx), 1);
					for iTrial = 1:numel(A2B1_idx)
						idxs = round(obj.GLM.pos.lampOff(A2B1_idx(iTrial))+centerOffsetFromRefEvent - abs(baselineWindow)/2 +1):round(obj.GLM.pos.lampOff(A2B1_idx(iTrial))+centerOffsetFromRefEvent + abs(baselineWindow)/2);
						A2B1(iTrial) = mean(ts(idxs));
						A_level{numel(A1B1_idx)+iTrial} = 'rewarded n-1';
						B_level{numel(A1B1_idx)+iTrial} = 'early n';
					end
					A1B2 = nan(numel(A1B2_idx), 1);
					for iTrial = 1:numel(A1B2_idx)
						idxs = round(obj.GLM.pos.lampOff(A1B2_idx(iTrial))+centerOffsetFromRefEvent - abs(baselineWindow)/2 +1):round(obj.GLM.pos.lampOff(A1B2_idx(iTrial))+centerOffsetFromRefEvent + abs(baselineWindow)/2);
						A1B2(iTrial) = mean(ts(idxs));
						A_level{numel(A1B1_idx)+numel(A2B1_idx)+iTrial} = 'early n-1';
						B_level{numel(A1B1_idx)+numel(A2B1_idx)+iTrial} = 'rewarded n';
					end
					A2B2 = nan(numel(A2B2_idx), 1);
					for iTrial = 1:numel(A2B2_idx)
						idxs = round(obj.GLM.pos.lampOff(A2B2_idx(iTrial))+centerOffsetFromRefEvent - abs(baselineWindow)/2 +1):round(obj.GLM.pos.lampOff(A2B2_idx(iTrial))+centerOffsetFromRefEvent + abs(baselineWindow)/2);
						A2B2(iTrial) = mean(ts(idxs));
						A_level{numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+iTrial} = 'rewarded n-1';
						B_level{numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+iTrial} = 'rewarded n';	
					end
				end
			elseif strcmpi(refEvent, 'cue')
				error('Not Implemented')
			else
				error('Not Implemented')
			end

			if strcmpi(baselineLickMode, 'include')
				% 
				% 	If using nLicks in baseline...
				% 
				if ~isfield(obj.GLM, 'pos') || ~isfield(obj.GLM.pos, 'lick'), obj.GLM.pos.lick = obj.getXPositionsWRTgfit(obj.GLM.lick_s);, end
				% 
				% 	Determine the indicies of the beginnings of each baseline Period...
				% 
				if strcmpi(refEvent, 'lampOff')
					if baselineWindow < 0
						error('obsolete')
						obj.GLM.pos.baselineStart = obj.GLM.pos.lampOff - abs(baselineWindow) + 1;
					else
% 						obj.GLM.pos.baselineStart = obj.GLM.pos.lampOff; 
                        obj.GLM.pos.baselineStart = round(obj.GLM.pos.lampOff + centerOffsetFromRefEvent - abs(baselineWindow)/2 + 1);
					end
				elseif strcmpi(refEvent, 'cue')
					error('Not Implemented')
				else
					error('Not Implemented')
				end
				obj.GLM.pos.baselineStart(end+1) = numel(obj.GLM.rawF); % tack on the full length so that we can correct the entire signal...
				
				nBaselineLicks = zeros(size(obj.GLM.pos.cue));

				if strcmpi(refEvent, 'lampOff')
					if baselineWindow < 0
						for iTrial = 1:numel(obj.GLM.pos.cue)
							nBaselineLicks(iTrial) = sum(ismember(find(obj.GLM.pos.lick > obj.GLM.pos.baselineStart(iTrial)), find(obj.GLM.pos.lick < obj.GLM.pos.baselineStart(iTrial)+abs(baselineWindow))));
	            		end
					else
						for iTrial = 1:numel(obj.GLM.pos.cue)
							nBaselineLicks(iTrial) = sum(ismember(find(obj.GLM.pos.lick > obj.GLM.pos.baselineStart(iTrial)), find(obj.GLM.pos.lick < obj.GLM.pos.baselineStart(iTrial)+baselineWindow)));
	            		end
					end
				elseif strcmpi(refEvent, 'cue')
					error('Not Implemented')
				else
					error('Not Implemented')
				end
				if verbose
		            figure 
		            bar(nBaselineLicks)
		            xlabel('Trial #')
		            ylabel('# licks in baseline')
	            end

	            trialOrder = [A1B1_idx,A2B1_idx,A1B2_idx,A2B2_idx];
	            lickLevel = zeros(size(trialOrder));
	            lickLevel(find(nBaselineLicks(trialOrder) ~= 0)) = 1;
                
	            if verbose
		            figure;
					hold on
	% 				C = linspecer(max(nBaselineLicks)*2);
	                C = colormap('hsv');
	                C = C(1:32, :);
	                colormap(C)
	                maxNLicks = max(nBaselineLicks(all_fl_wrtc_ms > 700 & all_fl_wrtc_ms < 7000));
	                caxis([1,maxNLicks])
	%                 st = max(nBaselineLicks);
	                allIdx = 1:numel(A1B1_idx);
					for iTrial = 1:numel(A1B1_idx)
						if lickLevel(allIdx(iTrial)) == ~(nBaselineLicks(A1B1_idx(iTrial)))
							error('Lick level is not correct!')
						end
						if nBaselineLicks(A1B1_idx(iTrial)) > 0
							plot(1+rand(1)/3, A1B1(iTrial), 'o', 'MarkerFaceColor', C(round(nBaselineLicks(A1B1_idx(iTrial))/maxNLicks*32), :) -0, 'MarkerEdgeColor', C(round(nBaselineLicks(A1B1_idx(iTrial))/maxNLicks*32), :), 'Markersize', 10);
						else
							plot(1+rand(1)/3, A1B1(iTrial), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
						end
					end
					plot(1, mean(A1B1), 'ko', 'MarkerSize', 30);
	                allIdx = numel(A1B1_idx)+1:numel(A1B1_idx)+numel(A2B1_idx);
					for iTrial = 1:numel(A2B1_idx)
						if lickLevel(allIdx(iTrial)) ~= true(nBaselineLicks(A2B1_idx(iTrial)))
							error('Lick level is not correct!')
						end
						if nBaselineLicks(A2B1_idx(iTrial)) > 0
							plot(2+rand(1)/3, A2B1(iTrial), 'o', 'MarkerFaceColor', C(round(nBaselineLicks(A2B1_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A2B1_idx(iTrial))/maxNLicks*32),:), 'Markersize', 10);
						else
							plot(2+rand(1)/3, A2B1(iTrial), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
						end
					end	
					plot(2, mean(A2B1), 'ko', 'MarkerSize', 30);
	                allIdx = numel(A1B1_idx)+numel(A2B1_idx)+1:numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx);
					for iTrial = 1:numel(A1B2_idx)
						if lickLevel(allIdx(iTrial)) ~= true(nBaselineLicks(A1B2_idx(iTrial)))
							error('Lick level is not correct!')
						end
						if nBaselineLicks(A1B2_idx(iTrial)) > 0
							plot(3+rand(1)/3, A1B2(iTrial), 'o', 'MarkerFaceColor', C(round(nBaselineLicks(A1B2_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A1B2_idx(iTrial))/maxNLicks*32),:), 'Markersize', 10);
						else
							plot(3+rand(1)/3, A1B2(iTrial), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
						end
					end
					plot(3, mean(A1B2), 'ko', 'MarkerSize', 30);
					allIdx = numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+1:numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+numel(A2B2_idx);
					for iTrial = 1:numel(A2B2_idx)
						if lickLevel(allIdx(iTrial)) ~= true(nBaselineLicks(A2B2_idx(iTrial)))
							error('Lick level is not correct!')
						end
						if nBaselineLicks(A2B2_idx(iTrial)) > 0
							plot(4+rand(1)/3, A2B2(iTrial), 'o', 'MarkerFaceColor', C(round(nBaselineLicks(A2B2_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A2B2_idx(iTrial))/maxNLicks*32),:), 'Markersize', 10);
						else
							plot(4+rand(1)/3, A2B2(iTrial), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
						end
					end						
					plot(4, mean(A2B2), 'ko', 'MarkerSize', 30);
					ax = gca;
					set(ax, 'fontsize', 20);
					ax.XAxis.TickValues = [1,2,3,4];
					ax.XAxis.TickLabels = {'(n-1) early|n early','(n-1) rew|n early','(n-1) early|n rew','(n-1) rew|n rew'};
				end
				% 
				% 	Run ANOVA
				% 
				ANOVAparams.earlyRange = earlyRange;
				ANOVAparams.rewRange = rewRange;
				ANOVAparams.A1 = '(n-1) early';
				ANOVAparams.A2 = '(n-1) rewarded';
				ANOVAparams.B1 = '(n) early';
				ANOVAparams.B2 = '(n) rewarded';
				ANOVAparams.L1 = 'No Baseline Licks';
				ANOVAparams.L2 = '+ Baseline Licks';
				ANOVAparams.factorIdx.A1 = A1;
				ANOVAparams.factorIdx.A2 = A2;
				ANOVAparams.factorIdx.B1 = B1;
				ANOVAparams.factorIdx.B2 = B2;
				ANOVAparams.factorIdx.nBaselineLicks = nBaselineLicks;
				ANOVAparams.cellIdx.A1B1 = A1B1_idx;
				ANOVAparams.cellIdx.A2B1 = A2B1_idx;
				ANOVAparams.cellIdx.A1B2 = A1B2_idx;
				ANOVAparams.cellIdx.A2B2 = A2B2_idx;
				ANOVAparams.cellData.A1B1 = A1B1;
				ANOVAparams.cellData.A2B1 = A2B1;
				ANOVAparams.cellData.A1B2 = A1B2;
				ANOVAparams.cellData.A2B2 = A2B2;
				ANOVAparams.cellData.A_level = A_level;
				ANOVAparams.cellData.B_level = B_level;
				ANOVAparams.cellData.lickLevel = lickLevel;
				ANOVAparams.cellData.data = [A1B1;A2B1;A1B2;A2B2];
				if verbose
					[ANOVAparams.results.p,ANOVAparams.results.tbl,ANOVAparams.results.stats,ANOVAparams.results.terms] = anovan(ANOVAparams.cellData.data, {A_level, B_level, lickLevel}, 'model','interaction');
				else
					[ANOVAparams.results.p,ANOVAparams.results.tbl,ANOVAparams.results.stats,ANOVAparams.results.terms] = anovan(ANOVAparams.cellData.data, {A_level, B_level, lickLevel}, 'model','interaction', 'display', 'off');
				end
			elseif strcmpi(baselineLickMode, 'exclude')
				% 
				% 	If using nLicks in baseline...
				% 
				if ~isfield(obj.GLM, 'pos') || ~isfield(obj.GLM.pos, 'lick'), obj.GLM.pos.lick = obj.getXPositionsWRTgfit(obj.GLM.lick_s);, end
				% 
				% 	Determine the indicies of the beginnings of each baseline Period...
				% 
				if strcmpi(refEvent, 'lampOff')
					if baselineWindow < 0
                        error('obsolete')
						obj.GLM.pos.baselineStart = obj.GLM.pos.lampOff - abs(baselineWindow) + 1;
					else
% 						obj.GLM.pos.baselineStart = obj.GLM.pos.lampOff;
                        obj.GLM.pos.baselineStart = round(obj.GLM.pos.lampOff + centerOffsetFromRefEvent - abs(baselineWindow)/2 + 1);
					end
				elseif strcmpi(refEvent, 'cue')
					error('Not Implemented')
				else
					error('Not Implemented')
				end
				
				obj.GLM.pos.baselineStart(end+1) = numel(obj.GLM.rawF); % tack on the full length so that we can correct the entire signal...
				
				nBaselineLicks = zeros(size(obj.GLM.pos.cue));
				for iTrial = 1:numel(obj.GLM.pos.cue)
					nBaselineLicks(iTrial) = sum(ismember(find(obj.GLM.pos.lick > obj.GLM.pos.baselineStart(iTrial)), find(obj.GLM.pos.lick < obj.GLM.pos.baselineStart(iTrial)+abs(baselineWindow))));
	            end
	            if verbose            	
		            figure 
		            bar(nBaselineLicks)
		            xlabel('Trial #')
		            ylabel('# licks in baseline')
	            end
	            % 
	            %	Look at all trials
	            %
	            trialOrder = [A1B1_idx,A2B1_idx,A1B2_idx,A2B2_idx];
	            lickLevel = zeros(size(trialOrder));
	            lickLevel(find(nBaselineLicks(trialOrder) ~= 0)) = 1;
                if verbose
		            figure;
		            ax1 = subplot(1,2,1);
		            ax2 = subplot(1,2,2);
					hold(ax1, 'on');
					hold(ax2, 'on');
	% 				C = linspecer(max(nBaselineLicks)*2);
	                C = colormap('hsv');
	                C = C(1:32, :);
	                colormap(C)
	                maxNLicks = max(nBaselineLicks(all_fl_wrtc_ms > 700 & all_fl_wrtc_ms < 7000));
	                caxis(ax1, [1,maxNLicks])
	%                 st = max(nBaselineLicks);
	                allIdx = 1:numel(A1B1_idx);
	                % rng(1);
					for iTrial = 1:numel(A1B1_idx)
						if lickLevel(allIdx(iTrial)) == ~(nBaselineLicks(A1B1_idx(iTrial)))
							error('Lick level is not correct!')
						end
						if nBaselineLicks(A1B1_idx(iTrial)) > 0
							scatter3(ax1, 1+rand(1)/3, A1B1(iTrial), A1B1_idx(iTrial), 30, 'o', 'filled', 'MarkerFaceColor', C(round(nBaselineLicks(A1B1_idx(iTrial))/maxNLicks*32), :) -0, 'MarkerEdgeColor', C(round(nBaselineLicks(A1B1_idx(iTrial))/maxNLicks*32), :));
						else
							scatter3(ax1, 1+rand(1)/3, A1B1(iTrial), A1B1_idx(iTrial), 15, 'o', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
						end
					end
					scatter3(ax1,1, mean(A1B1), 1, 1000, 'ko', 'LineWidth', 3);
	                allIdx = numel(A1B1_idx)+1:numel(A1B1_idx)+numel(A2B1_idx);
					for iTrial = 1:numel(A2B1_idx)
						if lickLevel(allIdx(iTrial)) ~= true(nBaselineLicks(A2B1_idx(iTrial)))
							error('Lick level is not correct!')
						end
						if nBaselineLicks(A2B1_idx(iTrial)) > 0
							scatter3(ax1, 2+rand(1)/3, A2B1(iTrial), A2B1_idx(iTrial), 30, 'o', 'filled', 'MarkerFaceColor', C(round(nBaselineLicks(A2B1_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A2B1_idx(iTrial))/maxNLicks*32),:));
						else
							scatter3(ax1, 2+rand(1)/3, A2B1(iTrial), A2B1_idx(iTrial), 15, 'o', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
						end
					end	
					scatter3(ax1,2, mean(A2B1), 1, 1000, 'ko', 'LineWidth', 3);
	                allIdx = numel(A1B1_idx)+numel(A2B1_idx)+1:numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx);
					for iTrial = 1:numel(A1B2_idx)
						if lickLevel(allIdx(iTrial)) ~= true(nBaselineLicks(A1B2_idx(iTrial)))
							error('Lick level is not correct!')
						end
						if nBaselineLicks(A1B2_idx(iTrial)) > 0
							scatter3(ax1, 3+rand(1)/3, A1B2(iTrial), A1B2_idx(iTrial), 30, 'o', 'MarkerFaceColor', C(round(nBaselineLicks(A1B2_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A1B2_idx(iTrial))/maxNLicks*32),:));
						else
							scatter3(ax1, 3+rand(1)/3, A1B2(iTrial), A1B2_idx(iTrial), 15, 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
						end
					end
					scatter3(ax1,3, mean(A1B2), 1, 1000, 'ko', 'LineWidth', 3);
					allIdx = numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+1:numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+numel(A2B2_idx);
					for iTrial = 1:numel(A2B2_idx)
						if lickLevel(allIdx(iTrial)) ~= true(nBaselineLicks(A2B2_idx(iTrial)))
							error('Lick level is not correct!')
						end
						if nBaselineLicks(A2B2_idx(iTrial)) > 0
							scatter3(ax1, 4+rand(1)/3, A2B2(iTrial), A2B2_idx(iTrial), 30, 'o', 'MarkerFaceColor', C(round(nBaselineLicks(A2B2_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A2B2_idx(iTrial))/maxNLicks*32),:));
						else
							scatter3(ax1, 4+rand(1)/3, A2B2(iTrial), A2B2_idx(iTrial), 15, 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
						end
					end						
					scatter3(ax1,4, mean(A2B2), 1, 1000, 'ko', 'LineWidth', 3);
					set(ax1, 'fontsize', 16);
					ax1.XAxis.TickValues = [1,2,3,4];
					ax1.XAxis.TickLabels = {'(n-1) early|n early','(n-1) rew|n early','(n-1) early|n rew','(n-1) rew|n rew'};
				end
				% 
				% 	Remove trials with licks in ITI
				% 
	            A1B1(nBaselineLicks(A1B1_idx) > 0) = [];
				A2B1(nBaselineLicks(A2B1_idx) > 0) = [];
				A1B2(nBaselineLicks(A1B2_idx) > 0) = [];
				A2B2(nBaselineLicks(A2B2_idx) > 0) = [];
				A1B1_idx(nBaselineLicks(A1B1_idx) > 0) = [];
				A2B1_idx(nBaselineLicks(A2B1_idx) > 0) = [];
				A1B2_idx(nBaselineLicks(A1B2_idx) > 0) = [];
				A2B2_idx(nBaselineLicks(A2B2_idx) > 0) = [];
				A_level(nBaselineLicks(trialOrder) > 0) = [];
				B_level(nBaselineLicks(trialOrder) > 0) = [];
				trialOrder = [A1B1_idx,A2B1_idx,A1B2_idx,A2B2_idx];
				% 
				allIdx = 1:numel(A1B1_idx);
                % rng(1);
                if verbose
					for iTrial = 1:numel(A1B1_idx)
						if nBaselineLicks(A1B1_idx(iTrial)) > 0
							scatter3(ax2, 1+rand(1)/3, A1B1(iTrial), A1B1_idx(iTrial), 30, 'o', 'filled', 'MarkerFaceColor', C(round(nBaselineLicks(A1B1_idx(iTrial))/maxNLicks*32), :) -0, 'MarkerEdgeColor', C(round(nBaselineLicks(A1B1_idx(iTrial))/maxNLicks*32), :));
						else
							scatter3(ax2, 1+rand(1)/3, A1B1(iTrial), A1B1_idx(iTrial), 15, 'o', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
						end
					end
					scatter3(ax2,1, mean(A1B1), 1, 1000, 'ko', 'LineWidth', 3);
	                allIdx = numel(A1B1_idx)+1:numel(A1B1_idx)+numel(A2B1_idx);
					for iTrial = 1:numel(A2B1_idx)
						if nBaselineLicks(A2B1_idx(iTrial)) > 0
							scatter3(ax2, 2+rand(1)/3, A2B1(iTrial), A2B1_idx(iTrial), 30, 'o', 'filled', 'MarkerFaceColor', C(round(nBaselineLicks(A2B1_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A2B1_idx(iTrial))/maxNLicks*32),:));
						else
							scatter3(ax2, 2+rand(1)/3, A2B1(iTrial), A2B1_idx(iTrial), 15, 'o', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
						end
					end	
					scatter3(ax2,2, mean(A2B1), 1, 1000, 'ko', 'LineWidth', 3);
	                allIdx = numel(A1B1_idx)+numel(A2B1_idx)+1:numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx);
					for iTrial = 1:numel(A1B2_idx)
						if nBaselineLicks(A1B2_idx(iTrial)) > 0
							scatter3(ax2, 3+rand(1)/3, A1B2(iTrial), A1B2_idx(iTrial), 30, 'o', 'MarkerFaceColor', C(round(nBaselineLicks(A1B2_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A1B2_idx(iTrial))/maxNLicks*32),:));
						else
							scatter3(ax2, 3+rand(1)/3, A1B2(iTrial), A1B2_idx(iTrial), 15, 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
						end
					end
					scatter3(ax2,3, mean(A1B2), 1, 1000, 'ko', 'LineWidth', 3);
					allIdx = numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+1:numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+numel(A2B2_idx);
					for iTrial = 1:numel(A2B2_idx)
						if nBaselineLicks(A2B2_idx(iTrial)) > 0
							scatter3(ax2, 4+rand(1)/3, A2B2(iTrial), A2B2_idx(iTrial), 30, 'o', 'MarkerFaceColor', C(round(nBaselineLicks(A2B2_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A2B2_idx(iTrial))/maxNLicks*32),:));
						else
							scatter3(ax2, 4+rand(1)/3, A2B2(iTrial), A2B2_idx(iTrial), 15, 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
						end
					end						
					scatter3(ax2,4, mean(A2B2), 1, 1000, 'ko', 'LineWidth', 3);
					set(ax2, 'fontsize', 16);
					ax2.XAxis.TickValues = [1,2,3,4];
					ax2.XAxis.TickLabels = {'(n-1) early|n early','(n-1) rew|n early','(n-1) early|n rew','(n-1) rew|n rew'};
				end
				% 
				% 	Run ANOVA
				% 
				ANOVAparams.earlyRange = earlyRange;
				ANOVAparams.rewRange = rewRange;
				ANOVAparams.A1 = '(n-1) early';
				ANOVAparams.A2 = '(n-1) rewarded';
				ANOVAparams.B1 = '(n) early';
				ANOVAparams.B2 = '(n) rewarded';
				ANOVAparams.L1 = 'No Baseline Licks';
				ANOVAparams.L2 = '+ Baseline Licks';
				ANOVAparams.factorIdx.A1 = A1;
				ANOVAparams.factorIdx.A2 = A2;
				ANOVAparams.factorIdx.B1 = B1;
				ANOVAparams.factorIdx.B2 = B2;
				ANOVAparams.factorIdx.nBaselineLicks = nBaselineLicks;
				ANOVAparams.cellIdx.A1B1 = A1B1_idx;
				ANOVAparams.cellIdx.A2B1 = A2B1_idx;
				ANOVAparams.cellIdx.A1B2 = A1B2_idx;
				ANOVAparams.cellIdx.A2B2 = A2B2_idx;
				ANOVAparams.cellData.A1B1 = A1B1;
				ANOVAparams.cellData.A2B1 = A2B1;
				ANOVAparams.cellData.A1B2 = A1B2;
				ANOVAparams.cellData.A2B2 = A2B2;
				ANOVAparams.cellData.A_level = A_level;
				ANOVAparams.cellData.B_level = B_level;
				ANOVAparams.cellData.data = [A1B1;A2B1;A1B2;A2B2];
				if verbose
					[ANOVAparams.results.p,ANOVAparams.results.tbl,ANOVAparams.results.stats,ANOVAparams.results.terms] = anovan(ANOVAparams.cellData.data, {A_level, B_level}, 'model','interaction');
				else
					[ANOVAparams.results.p,ANOVAparams.results.tbl,ANOVAparams.results.stats,ANOVAparams.results.terms] = anovan(ANOVAparams.cellData.data, {A_level, B_level}, 'model','interaction','display','off');
				end
					
				% rng('default');
            else
				% 
				% 	Plot the means for each cell
				% 
				if verbose
					figure;
					hold on
					plot(ones(numel(A1B1_idx)), A1B1, 'o');
					plot(1, mean(A1B1), 'ko', 'MarkerSize', 30);
					plot(2*ones(numel(A2B1_idx)), A2B1, 'o');
					plot(2, mean(A2B1), 'ko', 'MarkerSize', 30);
					plot(3*ones(numel(A1B2_idx)), A1B2, 'o');
					plot(3, mean(A1B2), 'ko', 'MarkerSize', 30);
					plot(4*ones(numel(A2B2)), A2B2, 'o');
					plot(4, mean(A2B2), 'ko', 'MarkerSize', 30);
					ax = gca;
					set(ax, 'fontsize', 20);
					ax.XAxis.TickValues = [1,2,3,4];
					ax.XAxis.TickLabels = {'(n-1) early|n early','(n-1) rew|n early','(n-1) early|n rew','(n-1) rew|n rew'};
				end
				% 
				% 	Run ANOVA
				% 
				ANOVAparams.earlyRange = earlyRange;
				ANOVAparams.rewRange = rewRange;
				ANOVAparams.A1 = '(n-1) early';
				ANOVAparams.A2 = '(n-1) rewarded';
				ANOVAparams.B1 = '(n) early';
				ANOVAparams.B2 = '(n) rewarded';
				ANOVAparams.factorIdx.A1 = A1;
				ANOVAparams.factorIdx.A2 = A2;
				ANOVAparams.factorIdx.B1 = B1;
				ANOVAparams.factorIdx.B2 = B2;
				ANOVAparams.cellIdx.A1B1 = A1B1_idx;
				ANOVAparams.cellIdx.A2B1 = A2B1_idx;
				ANOVAparams.cellIdx.A1B2 = A1B2_idx;
				ANOVAparams.cellIdx.A2B2 = A2B2_idx;
				ANOVAparams.cellData.A1B1 = A1B1;
				ANOVAparams.cellData.A2B1 = A2B1;
				ANOVAparams.cellData.A1B2 = A1B2;
				ANOVAparams.cellData.A2B2 = A2B2;
				ANOVAparams.cellData.A_level = A_level;
				ANOVAparams.cellData.B_level = B_level;
				ANOVAparams.cellData.data = [A1B1;A2B1;A1B2;A2B2];
				if verbose
					[ANOVAparams.results.p,ANOVAparams.results.tbl,ANOVAparams.results.stats,ANOVAparams.results.terms] = anovan(ANOVAparams.cellData.data, {A_level, B_level}, 'model','interaction');
				else
					[ANOVAparams.results.p,ANOVAparams.results.tbl,ANOVAparams.results.stats,ANOVAparams.results.terms] = anovan(ANOVAparams.cellData.data, {A_level, B_level}, 'model','interaction', 'display', 'off');
				end
			end
			% 
			% 	Calculate expected power of test for dataset
			% 
			% k_prime = 2; % number of levels of each factor
			% n_primeA = numel(A1B1_idx) + numel(A2B1_idx);
			% ssA = 
			% phiA = sqrt()
		end





		function tofSummary(obj)
			% 
			% 	Make a boxplot of all the coefficients, pvalues and rsqs
			% 
			labels = {'rampT', 'rampT^2', 'peakT', 'peakT^2', 'amp', 'amp^2', 'int', 'int^2'};
			Xrsq = [[obj.collatedResults.riseT_linear_rsq]',[obj.collatedResults.riseT_sqrty_rsq]',[obj.collatedResults.peakT_linear_rsq]',[obj.collatedResults.peakT_sqrty_rsq]',[obj.collatedResults.peakAmp_linear_rsq]',[obj.collatedResults.peakAmp_sqrty_rsq]',[obj.collatedResults.integral_linear_rsq]',[obj.collatedResults.integral_sqrty_rsq]'];
			Xp = [[obj.collatedResults.riseT_linear_pbeta]',[obj.collatedResults.riseT_sqrty_pbeta]',[obj.collatedResults.peakT_linear_pbeta]',[obj.collatedResults.peakT_sqrty_pbeta]',[obj.collatedResults.peakAmp_linear_pbeta]',[obj.collatedResults.peakAmp_sqrty_pbeta]',[obj.collatedResults.integral_linear_pbeta]',[obj.collatedResults.integral_sqrty_pbeta]'];
			Xb1 = [[obj.collatedResults.riseT_linear_b1]',[obj.collatedResults.riseT_sqrty_b1]',[obj.collatedResults.peakT_linear_b1]',[obj.collatedResults.peakT_sqrty_b1]',[obj.collatedResults.peakAmp_linear_b1]',[obj.collatedResults.peakAmp_sqrty_b1]',[obj.collatedResults.integral_linear_b1]',[obj.collatedResults.integral_sqrty_b1]'];

			sz = [numel([obj.collatedResults.riseT_linear_rsq]),1];
			j = (rand(sz)-0.5)/2;

			[f, ax] = makeStandardFigure(3, [1,3]);
			boxplot(ax(1), Xrsq, labels);
			hold(ax(1), 'on'), plot(ax(1), ones(sz)+j, [obj.collatedResults.riseT_linear_rsq], 'k.', 'markersize', 30) 
			boxplot(ax(2), Xb1, labels);
			boxplot(ax(3), Xp, labels);

			ylabel(ax(1), 'rsq')
			ylabel(ax(3), 'p(b1)')
			ylabel(ax(2), 'b1')

			xtickangle(ax(1), 90)
			xtickangle(ax(2), 90)
			xtickangle(ax(3), 90)

			
		end

		function flagNFlick(obj, nMin)
			% 
			% 	For use with nTrialsWithFLick objs, used to deal with partitioning sessions for eLife rebuttal #1 (10/11/2020)
			% 		We will flag sessions with more than the nMin # of trials and then use these in our analysis
			% 
            cc = num2cell([obj.collatedResults.nFLicks]>nMin);
% 			obj.collatedResults = rmfield(obj.collatedResults,'hasMinNo');
            [obj.collatedResults.hasMinNo] = cc{:};
		end
		function hxgPartitioned(obj, nPartitions, nFlicksMin)
			if nargin < 3
				nFlicksMin = 400;
			end
			if nargin < 2
				nPartitions = 4;
            end
            obj.flagNFlick(nFlicksMin);
			goodSeshs = find([obj.collatedResults.hasMinNo]);
			obj.analysis.nPartitions = nPartitions;
			obj.analysis.nFlicksMin = nFlicksMin;
			obj.analysis.goodSeshs = goodSeshs;
			obj.analysis.flicks_by_partitions = cell(nPartitions,1);
			obj.analysis.flicks_by_partitions = cellfun(@(x) [], obj.analysis.flicks_by_partitions, 'uniformOutput', 0);
			for ii = 1:numel(goodSeshs)
                s = goodSeshs(ii);
				goodtrials = obj.collatedResults(s).flick_s_wrtc(~isnan(obj.collatedResults(s).flick_s_wrtc));
				for ip = 1:nPartitions
					i1 = 1+floor(obj.collatedResults(s).nFLicks/nPartitions)*(ip-1);
					i2 = floor(obj.collatedResults(s).nFLicks/nPartitions)*(ip);
					disp(['idx: ' num2str(i1) ':' num2str(i2)])
                    if ip ~= nPartitions
    					obj.analysis.flicks_by_partitions{ip} = [obj.analysis.flicks_by_partitions{ip};goodtrials(i1:i2)];
                    else
                        obj.analysis.flicks_by_partitions{ip} = [obj.analysis.flicks_by_partitions{ip};goodtrials(i1:end)];
                    end
				end
			end
		end
		function plotHxgPartitioned(obj)
			[f,ax] = makeStandardFigure(1,[1,1]);
			hold(ax, 'on');
			for ii = 1:obj.analysis.nPartitions
				histogram(ax, obj.analysis.flicks_by_partitions{ii}, 'binwidth', 0.25,'linewidth', 3, 'displayname', ['Partition ' num2str(ii), ' | nt=' num2str(numel(obj.analysis.flicks_by_partitions{ii}))], 'displaystyle', 'stairs', 'normalization', 'probability')
			end
			set(f, 'userdata', ['plotHxgPartitioned(obj),obj.hxgPartitioned(' num2str(obj.analysis.nPartitions) ',' num2str(obj.analysis.nFlicksMin) ')'])
			title(sprintf(['First Licks Partitioned by Trials in Session \n nSesh: ' num2str(numel(obj.analysis.goodSeshs)), ' | min # flicks: ' num2str(obj.analysis.nFlicksMin)]))
            legend(ax, 'show')
            ylabel('% first-licks in session')
            xlabel('time (s)')
		end
		function getModePartition(obj, distribution, rxnWin, closeWindow, verbose)
			% 
			% 	The idea is we want to fit a peak to the distribution for each partition so that we can plot it.
			% 		In general, inv gauss and gauss each have some shortcomings. inv gauss too conservative on peak time, gauss a little too centered.
			% 	Anywho, use 'normal' or 'inversegaussian for the
			% 	distribution OR 'none' to not fit anything
			% 
			% 	Verbose will also plot the fits
			% 	rxnWin is where we set the cutoff for rxn (in s)
			% 
            if nargin < 5
                verbose = true;
            end
            if nargin < 4
            	closeWindow = 7;
        	end
			if nargin < 3
				rxnWin = 0.7;
            end
            xx = [rxnWin:0.1:10];
			if nargin < 2
				distribution = 'normal';
				warning('using normal distribution')
			end
			if verbose
				[f,ax] = makeStandardFigure(1,[1,1]);
			    hold(ax(1), 'on');
				title(ax(1), sprintf([distribution ' fit \n First Licks Partitioned by Trials in Session \n nSesh: ' num2str(numel(obj.analysis.goodSeshs)), ' | min # flicks: ' num2str(obj.analysis.nFlicksMin)]))
			    ylabel(ax(1), '% first-licks in session')
    			xlabel(ax(1), 'time (s)')
    			set(f, 'userdata', ['obj.getModePartition(' distribution ',' num2str(rxnWin) ', true) | plotHxgPartitioned(obj),obj.hxgPartitioned(' num2str(obj.analysis.nPartitions) ',' num2str(obj.analysis.nFlicksMin) ')'])
    			C = linspecer(obj.analysis.nPartitions);
	            C(2:end-1) = C(2:end-1)-0.1;
                C(C<0) = 0;
                C = flipud(C);
                C = reshape(C, [1, numel(C)]);
                if strcmpi(distribution, 'none')
                    C = [C;C];
                    C = reshape(C, [2*obj.analysis.nPartitions,3]);
                else
                    C = [C;C;C];
                    C = reshape(C, [3*obj.analysis.nPartitions,3]);
                end
	            set(ax,'NextPlot','replacechildren', 'ColorOrder',C);
                hold(ax(1), 'on');
	            xlim(ax(1), [0,10])
	            xticks(ax(1), [0,3.3,7])
	            legend(ax(1), 'show')
	    	end
			for ii = 1:obj.analysis.nPartitions
				x = obj.analysis.flicks_by_partitions{ii};
				x = x(x>rxnWin);
				mm = median(x(x<closeWindow));
				obj.analysis.rxn_window_for_median = rxnWin;
				obj.analysis.medians_by_partitions{ii} = mm;
				if verbose
				    h = histogram(ax(1), obj.analysis.flicks_by_partitions{ii}, 'binwidth', 0.25, 'linewidth',3, 'displaystyle', 'stairs', 'normalization', 'probability','displayname', ['Partition #' num2str(ii) ' | Peak: ' num2str(round(mm,2)) ')']);
                    be1 = h.BinEdges(h.BinEdges(2:end)>mm & h.BinEdges(2:end)<=closeWindow+0.5)+0.5*h.BinWidth;
					be2 = h.Values(h.BinEdges(2:end)>mm & h.BinEdges(2:end)<=closeWindow+0.5);
            		a = area(ax(1), be1, be2, 'displayname', ['Median: ' num2str(round(mm),2) ')']);
                    alpha(a,0.1);
	    			maxh = max(h.Values);
                end
                if strcmpi(distribution, 'none')
                    continue
                end
                pd = fitdist(x,distribution);
			    pdfx = pdf(pd, xx)./max(pdf(pd, xx)).*maxh;
			    [h,rejectDist] = chi2gof(x, 'CDF', pd);
			    if strcmpi(distribution, 'normal')
					modex = pd.mu;
		    	elseif strcmpi(distribution, 'inversegaussian')
		    		modeInvGauss = @(mu, lam) mu*(sqrt(1+(9*mu^2)/(4*lam^2)) - 3*mu/(2*lam));
					mu = pd.mu;
					lam = pd.lambda;
					modex = modeInvGauss(mu, lam);
                end   
                if verbose
                    plot(ax(1), xx, pdfx, 'linewidth', 2, 'displayname', ['mode: ' num2str(modex), ' p' distribution ': ' num2str(rejectDist)])
                end
            end
            if verbose
            	yy = get(ax(1), 'ylim');
            	plot(ax(1), [rxnWin, rxnWin], yy, 'k-', 'displayname', 'Reaction Window (not considered in Median)')
        	end
		end
		function sAboveMedian_lastPartition = getMedianAllPartitionsAllSessions(obj, nPartitions, nFlicksMin, rxnWin, closeWindow)
			%		
			%	This pulls out all the medians in the timing distribution for each session so we can compare how the nonstationarity goes by session
			%		It will rerun all the initialization codes		
			% 
			setAnimalID(obj);
			if nargin < 2
				nPartitions = 4;
			end
			if nargin < 3
				nFlicksMin = 100;
			end
			if nargin < 4
				rxnWin = 0.7;
			end
			if nargin < 5
				closeWindow = 7;
			end
			obj.analysis.allSessions.nPartitions = nPartitions;
			obj.analysis.allSessions.nFlicksMin = nFlicksMin;
			obj.analysis.allSessions.rxnWin = rxnWin;
			obj.flagNFlick(nFlicksMin);
			goodSeshs = find([obj.collatedResults.hasMinNo]);
			obj.analysis.allSessions.goodSeshs = goodSeshs;
			obj.analysis.allSessions.medians_by_partitions = nan(numel(obj.collatedResults), nPartitions);
			for ii = 1:numel(goodSeshs)
				obj.analysis.allSessions.s(ii).flicks_by_partitions = cell(nPartitions,1);
				obj.analysis.allSessions.s(ii).flicks_by_partitions = cellfun(@(x) [], obj.analysis.allSessions.s(ii).flicks_by_partitions, 'uniformOutput', 0);
                s = goodSeshs(ii);
				goodtrials = obj.collatedResults(s).flick_s_wrtc(~isnan(obj.collatedResults(s).flick_s_wrtc));
				for ip = 1:nPartitions
					i1 = 1+floor(obj.collatedResults(s).nFLicks/nPartitions)*(ip-1);
					i2 = floor(obj.collatedResults(s).nFLicks/nPartitions)*(ip);
					disp(['idx: ' num2str(i1) ':' num2str(i2)])
                    if ip ~= nPartitions
    					obj.analysis.allSessions.s(ii).flicks_by_partitions{ip} = goodtrials(i1:i2);
                    else
                        obj.analysis.allSessions.s(ii).flicks_by_partitions{ip} = goodtrials(i1:end);
                    end
                    x = obj.analysis.allSessions.s(ii).flicks_by_partitions{ip};
					x = x(x>rxnWin & x < closeWindow);
                    obj.analysis.allSessions.medians_by_partitions(s, ip) = median(x);
				end
			end
			% [f, ax] = makeStandardFigure(1, [1,1]);
			% hold(ax, 'on');
			% for is = goodSeshs
			% 	plot(ax, obj.analysis.allSessions.medians_by_partitions(is,:), 1:4, '-', 'markersize', 20, 'displayname', ['ID: ' num2str(is) ' | ' obj.collatedResults(is).sessionID])
			% end
			% xlabel(ax, 'median time (s)')
			% ylabel(ax, 'partition #')
			% set(ax, 'Ydir', 'reverse');
			% set(f, 'userdata', ['obj.getMedianAllPartitionsAllSessions(' num2str(nPartitions) ',' num2str(nFlicksMin) ',' num2str(rxnWin) ')'])
			[f, ax2] = makeStandardFigure(3, [1,3]);
			set(f, 'userdata', ['obj.getMedianAllPartitionsAllSessions(' num2str(nPartitions) ',' num2str(nFlicksMin) ',' num2str(rxnWin) ')'])
			boxplot(ax2(1),obj.analysis.allSessions.medians_by_partitions)
			hold(ax2(1), 'on')
			hold(ax2(2), 'on')
			hold(ax2(3), 'on')
			plot(ax2(1), [0,5], [3.333, 3.333], 'k-')
			allMiceMedians = cell(numel(obj.iv.animalIDs), 1);
			allMiceMedians = cellfun(@(x) nan(1,nPartitions), allMiceMedians, 'uniformoutput', 0);
            for is = goodSeshs 
                j = (rand-0.5)/2;
                plot(ax2(1), [1:nPartitions]+j,obj.analysis.allSessions.medians_by_partitions(is, :), '.', 'markersize', 20, 'displayname', ['ID: ' num2str(is) ' | ' obj.collatedResults(is).sessionID])
                allMiceMedians{obj.collatedResults(is).animalIdx} = [allMiceMedians{obj.collatedResults(is).animalIdx};obj.analysis.allSessions.medians_by_partitions(is, :)];
            end
            xlabel(ax2(1), 'partition #')
            ylabel(ax2(1), 'median time (s)')

            allMiceMedians_n = cellfun(@(x) size(x, 1), allMiceMedians, 'uniformoutput', 0);
            allMiceMedians_mean = cellfun(@(x) nanmean(x, 1), allMiceMedians, 'uniformoutput', 0);
			cellfun(@(x,ii,n) plot(ax2(2), 1:nPartitions, x, '.-', 'color', [0.2,.2,.2], 'LineWidth', 2, 'displayname', [obj.iv.animalIDs{ii} ' | n=' num2str(n)]), allMiceMedians_mean, num2cell(1:numel(obj.iv.animalIDs))', allMiceMedians_n, 'uniformoutput', 0)
            plot(ax2(2), [0,nPartitions+1], [3.333,3.333], 'k-', 'displayname', 'criterion time')
            boxplot(ax2(2),obj.analysis.allSessions.medians_by_partitions)
			legend(ax2(2), 'show')
            xlabel(ax2(2), 'partition #')

            delete(ax2(3))

            for ip = 1:nPartitions
            	axx = subplot(nPartitions, 3, 3*ip);
            	hold(axx, 'on');
            	y = obj.analysis.allSessions.medians_by_partitions(~isnan(obj.analysis.allSessions.medians_by_partitions(:, ip)), ip);
	            histogram(axx, y, 'BinWidth', 0.25, 'displaystyle', 'stairs', 'normalization', 'probability', 'linewidth',3,'displayname', ['ID: ' num2str(is) ' | ' obj.collatedResults(is).sessionID])
	            yy = get(axx, 'ylim');
            	plot(axx, [3.333,3.333], yy, 'k-')
	            ylabel(axx, '% first-licks in session')
	            xlim(axx,[0,7])
            end
            xlabel(axx, 'time (s)')
            
            
           
            % ylim([0,7])
			
			title(ax2(2),['median of timing range (' num2str(rxnWin) '-' num2str(closeWindow) ')'])
			sAboveMedian_lastPartition = find(obj.analysis.allSessions.medians_by_partitions(:, end)>median(obj.analysis.allSessions.medians_by_partitions(:, end)));
			sAboveMedian_lastPartition = {obj.collatedResults(sAboveMedian_lastPartition).sessionID}';
			sAboveMedian_lastPartition(:,2) = num2cell(find(obj.analysis.allSessions.medians_by_partitions(:, end)>median(obj.analysis.allSessions.medians_by_partitions(:, end))));
		end
		function hxgSingleSession(obj, sessionIDno, nPartitions, binwidth, rxnWin, closeWindow)
			if nargin < 3
				nPartitions = 1;
			end
			if nargin <4
				binwidth = 0.25;
			end
			if nargin < 5
				rxnWin = 0.7;
			end
			if nargin < 6
				closeWindow = 7;
			end
			% 
			% 	Use this to look at any session
			% 
			x = obj.collatedResults(sessionIDno).flick_s_wrtc;
			[f, ax] = makeStandardFigure(1, [1,1]);
			hold(ax, 'on');
			for ip = 1:nPartitions
				i1 = 1+floor(numel(x)/nPartitions)*(ip-1);
				i2 = floor(numel(x)/nPartitions)*(ip);
				disp(['idx: ' num2str(i1) ':' num2str(i2)])
                if ip ~= nPartitions
					fbp = x(i1:i2);
                else
                    fbp = x(i1:end);
                end
				h = histogram(ax(1), fbp, 'binwidth', binwidth, 'linewidth',3, 'displaystyle', 'stairs', 'normalization', 'probability','displayname', ['Partition# ' num2str(ip) ' | ID: ' num2str(sessionIDno) ' | ' obj.collatedResults(sessionIDno).sessionID]);
				mm = median(x(x>rxnWin & x < closeWindow))
				be1 = h.BinEdges(h.BinEdges(2:end)>mm & h.BinEdges(2:end)<=closeWindow+0.5)+0.5*h.BinWidth;
				be2 = h.Values(h.BinEdges(2:end)>mm & h.BinEdges(2:end)<=closeWindow+0.5);
				yy = get(ax(1), 'ylim');
            	plot(ax(1), [3.333,3.333], yy, 'k-')
	            a = area(ax(1), be1, be2, 'displayname', ['Median: ' num2str(round(median(x(x>rxnWin& x<closeWindow)),2)) ')']);
	            alpha(a,0.1);
            end
            xlim(ax, [0,7])
            legend(ax, 'show');
		end
		function [IRTbyOP, edges] = IRTbyOpportunity(obj, fl, edges)
			if nargin < 3
				edges = [0:0.25:17];
			end
			[N, edges] = histcounts(fl(~isnan(fl)), edges);
			IRTbyOP = nan(numel(N),1);
			for nn = 1:numel(IRTbyOP)
				IRTbyOP(nn) = N(nn)/(sum(N(nn:end)));
			end
		end
		function mockDistributionIRTbyOpportunity(obj, binWidth)
			%             
            % Make some mock data for 2 cases -- inv gauss and exp
            % 
            if nargin < 2
            	binWidth = 0.25;
        	end
        	edges = [0:binWidth:17];
            pdExp = makedist('Exponential', 0.7);
%             pdfExp = pdf(pdExp, [0:0.01:17]);
            pdIG = makedist('inversegaussian', 3.4,8.16);
%             pdfIG = pdf(pdIG, [0:0.01:17]);
            r_exp = random(pdExp, [100000,1]);
            r_exp = r_exp(r_exp <= 17);
            r_IG = random(pdIG, [100000,1]);
            r_IG = r_IG(r_IG <= 17);
            [IRTbyOPexp, edges_exp] = obj.IRTbyOpportunity(r_exp, edges);
            [IRTbyOPIG, edges_IG] = obj.IRTbyOpportunity(r_IG, edges);
            [f, ax] = makeStandardFigure(4, [2, 2]);
            histogram(ax(1), r_exp, 'binwidth', binWidth, 'displaystyle', 'stairs')
            plot(ax(2), edges_exp(edges_exp(1:end-1) <= 17) + binWidth/2, IRTbyOPexp, 'k-', 'linewidth', 2)
            histogram(ax(3), r_IG, 'binwidth', binWidth, 'displaystyle', 'stairs')
            plot(ax(4), edges_IG(edges_IG(1:end-1) <= 17) + binWidth/2, IRTbyOPIG, 'k-', 'linewidth', 2)
            for ii = 1:4
            	hold(ax(ii), 'on')
            	yy = [0, max(IRTbyOPIG(1:find(edges_IG >= 7, 1, 'first')))];
            	plot(ax(ii), [3.333, 3.333], yy, 'r-')
                xlim(ax(ii), [0,10])
                xticks(ax(ii), 0:10)
        	end
        	set(f, 'userdata', ['obj.mockDistributionIRTbyOpportunity(' num2str(binWidth) ')'])
		end
		function [yy,med, nextneighbors] = numericalCDF(obj, x,y)
            yy = nan(size(y));
            for ii = 1:numel(y)    
                yy(ii) = nansum(y(1:ii))./nansum(y); 
            end
            medidx = find(yy >= 0.5, 1, 'first'); 
            med = x(medidx);
            nextneighbors = [x(medidx-1), x(medidx+1)];
		end
		function yy = inverseSample(obj,y,n, x)
			% 
			% 	y should be made by numericalCDF. n is the number of samples
			% 
			r = rand(n,1);
			yy = nan(n,1);
			for ii = 1:n
				yy(ii) = find(y>=r(ii), 1, 'first');
				if nargin > 3
					yy(ii) = x(yy(ii));
				end
			end
		end
		function plotMedianIRTbyOpportunity(obj, x, IRTbyOp, med)
			[f, ax] = makeStandardFigure(1,[1,1]);
			hold(ax, 'on');
			plot(ax, x,IRTbyOp, 'k-','linewidth', 3)
			area(ax, x(x>=med & x<=7),IRTbyOp(x>=med & x<=7))
            xlim(ax,[0,7])
            yy = [0,max(IRTbyOp(x<=7))];
            ylim(ax,yy)
            plot(ax, [3.333,3.333],yy,'r-')
		end
		function [CIl, CIu, bootpeak,bootmedian] = bootIRTbyOpportunity(obj, fl, edges, nboot, Alpha)
			% 
			% 	Will bootstrap to get the full range of IRTs (to get 95% CI) and also the peak
			% 
			closeWindow = 7;
			rxnWin = 0.7;
			if nargin < 3, edges = [0:0.25:17], end
			if nargin < 4, nboot = numel(fl), end
			if nargin < 5, Alpha = 0.05, end
			b = nan(nboot, numel(edges(1:end-1)));
			bootpeak = nan(nboot,1);
			for ib = 1:nboot
				ff = fl;
				ff=fl(randi(numel(fl),numel(fl),1));
				[b(ib,:), ~] = obj.IRTbyOpportunity(ff, edges);
				bootpeak(ib) = find(b(ib,:) == max(b(ib,edges>0.7&edges<7)), 1, 'first');
				[CDF,med, nextneighbors] = obj.numericalCDF(edges(edges>rxnWin & edges < closeWindow)+(edges(2)-edges(1))/2,b(ib,edges>rxnWin&edges<closeWindow));
				bootmedian(ib) = med;
			end
			bsort = sort(b,1);
			lidx = round((Alpha/2*nboot));
			uidx = (1-(Alpha/2))*nboot;
			CIl = bsort(lidx, :);
			CIu = bsort(uidx, :);
            bootpeaksort = sort(bootpeak);
			bootpeak = [bootpeaksort(lidx), mean(bootpeaksort), bootpeaksort(uidx)];
			bootmediansort = sort(bootmedian);
			bootmedian = [bootmediansort(lidx), mean(bootmediansort), bootmediansort(uidx)];
		end
		function sAboveMedian_lastPartition = plotIRTbyOpportunity(obj, nPartitions, nFlicksMin,binWidth, rxnWin, closeWindow)
            obj.analysis = [];
			% 
			% 	From Jaldow and Oakley 1990 -- "Interresponse time distribution. A low number of
			%	reinforcements obtained per session does not necessarily indicate that an animal has 
			%	not learned anything about the temporal requirements of the schedule. 
			%
			%	By looking at changes, if any, in the length and frequency of IRTs as a function of training, 
			%	a clearer pieture of an animal's temporal sensitivities may be obtained. Accordingly, the fre-
			%	quency of IRT durations, split into successive 2-sec bins, was calculated as apercentage of 
			%	the total number of IRTs for each animal and then for the group. All IRTs over 24 sec long were 
			%	placed into the last bin (see Figure 3)"
			% 	
			% 
			% 	NB: This is much too noisy for single session!!! So we should really do this across sessions within an animal, I think...
			% 
			setAnimalID(obj);
			if nargin < 2
				nPartitions = 4;
			end
			if nargin < 3
				nFlicksMin = 100;
			end
			if nargin < 4
				binWidth = 0.25;
			end
			if nargin < 5
				rxnWin = 0.7;
			end
			if nargin < 6
				closeWindow = 7;
            end
            edges = [0:binWidth:17];
            obj.mockDistributionIRTbyOpportunity(binWidth);
			
			obj.analysis.allSessions.nPartitions = nPartitions;
			obj.analysis.allSessions.nFlicksMin = nFlicksMin;
			obj.analysis.allSessions.rxnWin = rxnWin;
			obj.flagNFlick(nFlicksMin);
			goodSeshs = find([obj.collatedResults.hasMinNo]);
			obj.analysis.allSessions.goodSeshs = goodSeshs;
			obj.analysis.allSessions.IRTbyopportunity = cell(numel(obj.collatedResults), nPartitions);
			obj.analysis.allSessions.medians_IRTbyopportunity = nan(numel(obj.collatedResults), nPartitions);
			obj.analysis.allSessions.edges_IRTbyopportunity = cell(numel(obj.collatedResults), nPartitions);
			for ii = 1:numel(goodSeshs)
				obj.analysis.allSessions.s(ii).flicks_by_partitions = cell(nPartitions,1);
				obj.analysis.allSessions.s(ii).flicks_by_partitions = cellfun(@(x) [], obj.analysis.allSessions.s(ii).flicks_by_partitions, 'uniformOutput', 0);
                s = goodSeshs(ii);
				goodtrials = obj.collatedResults(s).flick_s_wrtc(~isnan(obj.collatedResults(s).flick_s_wrtc));
				for ip = 1:nPartitions
					i1 = 1+floor(obj.collatedResults(s).nFLicks/nPartitions)*(ip-1);
					i2 = floor(obj.collatedResults(s).nFLicks/nPartitions)*(ip);
					disp(['idx: ' num2str(i1) ':' num2str(i2)])
                    if ip ~= nPartitions
    					obj.analysis.allSessions.s(ii).flicks_by_partitions{ip} = goodtrials(i1:i2);
                    else
                        obj.analysis.allSessions.s(ii).flicks_by_partitions{ip} = goodtrials(i1:end);
                    end
					fl = obj.analysis.allSessions.s(ii).flicks_by_partitions{ip};
					obj.analysis.allSessions.fl{s, ip} = obj.analysis.allSessions.s(ii).flicks_by_partitions{ip};
                    [IRTbyop, Edges] = obj.IRTbyOpportunity(fl, edges);
                    if numel(IRTbyop) ~= numel(edges)-1
                       IRTbyop(end+ numel(edges)-1-numel(IRTbyop)) = nan;
                    end
					obj.analysis.allSessions.IRTbyopportunity{s, ip} = IRTbyop;
					x = IRTbyop;
					x = x(Edges(1:end-1)>rxnWin & Edges(1:end-1) < closeWindow);
					[CDF,med, nextneighbors] = obj.numericalCDF(edges(edges>rxnWin & edges < closeWindow)+binWidth/2,x);
					% disp(['median: ' num2str(med) ', range:' mat2str(nextneighbors)])
					% if rem(ii, 10) == 0
					% 	obj.plotMedianIRTbyOpportunity(edges(1:end-1) + binWidth/2, IRTbyop, med)
					% end
%                     figure, plot(edges(1:end-1) + binWidth/2,IRTbyop)
                    obj.analysis.allSessions.medians_IRTbyopportunity(s, ip) = med;
                    obj.analysis.allSessions.edges_IRTbyopportunity{s, ip} = Edges;
				end
			end
			[f, ax2] = makeStandardFigure(3, [1,3]);
			set(f, 'userdata', ['obj.plotIRTbyOpportunity(' num2str(nPartitions) ',' num2str(nFlicksMin) ',' num2str(rxnWin) ',' num2str(closeWindow) ')'])
			boxplot(ax2(1),obj.analysis.allSessions.medians_IRTbyopportunity)
			hold(ax2(1), 'on')
			hold(ax2(2), 'on')
			hold(ax2(3), 'on')
			plot(ax2(1), [0,5], [3.333, 3.333], 'k-')
			allMiceFL = cell(numel(obj.iv.animalIDs), 1);
			allMiceFL = cellfun(@(x) nan(1,nPartitions), allMiceFL, 'uniformoutput', 0);
			allFL  = cell(1, nPartitions);
			allFL = cellfun(@(x) [], allFL, 'uniformoutput', 0);
			allMiceMedians_n = cell(numel(obj.iv.animalIDs),1);
			allMiceMedians_n = cellfun(@(x) 0, allMiceMedians_n, 'uniformoutput', 0);
            for is = goodSeshs 
                j = (rand-0.5)/2;
                plot(ax2(1), [1:nPartitions]+j,obj.analysis.allSessions.medians_IRTbyopportunity(is, :), '.', 'markersize', 20, 'displayname', ['ID: ' num2str(is) ' | ' obj.collatedResults(is).sessionID])
                % 
                % 	Gather all the flicks for a given animal so we can run IRT on that animal
                % obj.analysis.allSessions.fl{s, ip}
                for ip = 1:nPartitions
	                allMiceFL{obj.collatedResults(is).animalIdx, ip} = [allMiceFL{obj.collatedResults(is).animalIdx, ip};obj.analysis.allSessions.fl{is, ip}];
	                allFL{ip} = [allFL{ip};obj.analysis.allSessions.fl{is, ip}];
                end
                allMiceMedians_n{obj.collatedResults(is).animalIdx,1} = allMiceMedians_n{obj.collatedResults(is).animalIdx,1}+1;
            end
            obj.analysis.allFL = allFL;
            % 
            % 	Now get across animal IRT
            % 
            allMiceIRTbyOp = cell(numel(obj.iv.animalIDs), 1);
			allMiceIRTbyOp = cellfun(@(x) nan(1,nPartitions), allMiceIRTbyOp, 'uniformoutput', 0);
			[f2, ax] = makeStandardFigure(1,[1,1]);
			set(f2, 'userdata', ['obj.plotIRTbyOpportunity(' num2str(nPartitions) ',' num2str(nFlicksMin) ',' num2str(rxnWin) ',' num2str(closeWindow) ')'])
			hold(ax, 'on');
            xlim(ax,[0,7])


            for im = 1:numel(allMiceFL)
            	for ip = 1:nPartitions
	                fl = allMiceFL{im, ip};
	                % 
	                % 	Gather all the flicks for a given animal so we can run IRT on that animal
	                % 
	                [IRTbyop, ~] = obj.IRTbyOpportunity(fl, edges);
	                allMiceIRTbyOp{im, ip} = IRTbyop;
					obj.analysis.allSessions.allMiceIRTbyOp{im, ip} = IRTbyop;
					x = IRTbyop;
					x = x(edges(1:end-1)>rxnWin & edges(1:end-1) < closeWindow);
					[CDF,med, nextneighbors] = obj.numericalCDF(edges(edges>rxnWin & edges < closeWindow)+binWidth/2,x);
					% disp(['median: ' num2str(med) ', range:' mat2str(nextneighbors)])
					% obj.plotMedianIRTbyOpportunity(edges(1:end-1) + binWidth/2, IRTbyop, med)
					plot(ax, edges(1:end-1),IRTbyop, 'k-','linewidth', 3, 'displayname', ['mouseidx: ' num2str(im), ' partition: ' num2str(ip)])
					% a = area(ax, edges(edges>=med & edges<=7),IRTbyop(edges>=med & edges<=7));
     %                alpha(a, 0.1);
					% 
					% 	Now, rather than taking the median, let's estimate the peak with a bootstrap procedure. We will recalc the IRTbyop n times to get a CI, then we will take the mean peak
					% 
					[CIl, CIu, bootpeak, bootmedian] = obj.bootIRTbyOpportunity(fl, edges, 10000, 0.05);
					% patch(ax, [edges(1:end-1) fliplr(edges(1:end-1))], [CIu fliplr(CIl)], 'g')
					% plot(ax, edges(1:end-1),CIl, 'k-','linewidth', 1, 'displayname', ['95% CI-lower'])
					% plot(ax, edges(1:end-1),CIu, 'k-','linewidth', 1, 'displayname', ['95% CI-upper'])
					% plot(ax, [edges(bootpeak(1)),edges(bootpeak(3))], max(IRTbyop(edges(1:end-1)>rxnWin & edges(1:end-1) < closeWindow)).*[1,1], 'r*-', 'displayname', 'peak')
					a = area(ax, edges(edges>=bootmedian(2) & edges <=closeWindow),IRTbyop(edges>=bootmedian(2) & edges <=closeWindow));
					alpha(a, 0.1);
					d = rem(bootpeak(2),1);
                    obj.analysis.IRTbyop_allmice_bootPeak{im,ip} = edges(floor(bootpeak(2)))+d*binWidth;
                    obj.analysis.IRTbyop_allmice_minbootPeak{im,ip} = edges(floor(bootpeak(1)));
					obj.analysis.allSessions.allMiceIRTbyOp{im, ip} = IRTbyop;
					obj.analysis.IRTbyop_allmice_bootMedian(im,ip) = bootmedian(2);
					disp(['boot median: ' num2str(bootmedian(2)) ', range:' mat2str([bootmedian(1), bootmedian(3)])])
                end
                plot(ax2(2), 1:nPartitions, obj.analysis.IRTbyop_allmice_bootMedian(im,:), '.-', 'color', [0.2,.2,.2], 'LineWidth', 2, 'displayname', [obj.iv.animalIDs{im} ' | n=' num2str(allMiceMedians_n{im})], 'markersize', 20)
            end
            for ip = 1:nPartitions
            	fl = allFL{ip};
            	[IRTbyop, ~] = obj.IRTbyOpportunity(fl, edges);
                compositeIRTbyOp{ip} = IRTbyop;
				obj.analysis.allSessions.compositeIRTbyOp{ip} = IRTbyop;
				x = IRTbyop;
				x = x(edges(1:end-1)>rxnWin & edges(1:end-1) < closeWindow);
            	plot(ax, edges(1:end-1),IRTbyop, 'r-','linewidth', 3, 'displayname', ['All data, all mice, all sessions'])
            	[CIl, CIu, bootpeak, bootmedian] = obj.bootIRTbyOpportunity(fl, edges, 100000, 0.05);
	            a = area(ax, edges(edges>=bootmedian(2) & edges <=closeWindow),IRTbyop(edges>=bootmedian(2) & edges <=closeWindow));
				alpha(a, 0.1);
				d = rem(bootpeak(2),1);
                obj.analysis.IRTbyop_composite_bootPeak{ip} = edges(floor(bootpeak(2)))+d*binWidth;
                obj.analysis.IRTbyop_composite_minbootPeak{ip} = edges(floor(bootpeak(1)));
				obj.analysis.IRTbyop_composite_bootMedian(ip) = bootmedian(2);
				plot(ax, edges(1:end-1),CIl, 'r--','linewidth', 1, 'displayname', ['95% CI-lower'])
				plot(ax, edges(1:end-1),CIu, 'r--','linewidth', 1, 'displayname', ['95% CI-upper'])
				disp(['grand average boot median: ' num2str(bootmedian(2)) ', range:' mat2str([bootmedian(1), bootmedian(3)])])
            end
            ylim(ax,[0,0.24])
			xlabel(ax,'time relative to cue (s)')
			ylabel(ax,'Proportion of First-licks by Opportunity')
			title(ax,['Hazard analysis (min flicks = 100), trim 0.7-7s for median analysis, n=' num2str(numel(obj.iv.animalIDs)) ' mice'])


            yy = [0,max(IRTbyop(x<=7))];
            ylim(ax,yy)
            plot(ax, [3.333,3.333],yy,'r-')
            xlabel(ax2(1), 'partition #')
            ylabel(ax2(1), 'median IRT/Op time (s)')

            
			% cellfun(@(x,ii,n) plot(ax2(2), 1:nPartitions, x, '.-', 'color', [0.2,.2,.2], 'LineWidth', 2, 'displayname', [obj.iv.animalIDs{ii} ' | n=' num2str(n)]), obj.analysis.IRTbyop_allmice_bootMedian, num2cell(1:numel(obj.iv.animalIDs))', allMiceMedians_n, 'uniformoutput', 0)
            plot(ax2(2), [0,nPartitions+1], [3.333,3.333], 'k-', 'displayname', 'criterion time')
            boxplot(ax2(2),obj.analysis.IRTbyop_allmice_bootMedian)
			legend(ax2(2), 'show')
            xlabel(ax2(2), 'partition #')

            delete(ax2(3))
            for ip = 1:nPartitions
            	axx = subplot(nPartitions, 3, 3*ip, 'parent', f);
            	hold(axx, 'on');
            	y = obj.analysis.allSessions.medians_IRTbyopportunity(~isnan(obj.analysis.allSessions.medians_IRTbyopportunity(:, ip)), ip);
	            histogram(axx, y, 'BinWidth', 0.25, 'displaystyle', 'stairs', 'normalization', 'probability', 'linewidth',3,'displayname', ['ID: ' num2str(is) ' | ' obj.collatedResults(is).sessionID])
	            yy = get(axx, 'ylim');
            	plot(axx, [3.333,3.333], yy, 'k-')
	            ylabel(axx, 'median IRT/op in session')
	            xlim(axx,[0,7])
            end
            xlabel(axx, 'time (s)')
			title(ax2(2),['IRT/Opportunity median for timing range (' num2str(rxnWin) '-' num2str(closeWindow) ')'])
			sAboveMedian_lastPartition = find(obj.analysis.allSessions.medians_IRTbyopportunity(:, end)>median(obj.analysis.allSessions.medians_IRTbyopportunity(:, end)));
			sAboveMedian_lastPartition = {obj.collatedResults(sAboveMedian_lastPartition).sessionID}';
			sAboveMedian_lastPartition(:,2) = num2cell(find(obj.analysis.allSessions.medians_IRTbyopportunity(:, end)>median(obj.analysis.allSessions.medians_IRTbyopportunity(:, end))));
			% makeStandardFigure(1,[1,1])
			% histogram(obj.analysis.allFL{1}, 'binwidth', 0.25, 'displaystyle', 'stairs', 'linewidth',2, 'normalization', 'probability')
			% xlim([0,10])
			% set(gca, 'fontsize', 12)
			% hold on
			% plot([3.333,3.333],[0,0.15], 'k--')
			% xlabel('time relative to cue (s)')
			% ylabel('proportion of first-licks')
			% printFigure('Hxg for all photom sessions with 100+ flicks, 102 sesh total')
		end
		function createCompositeBinnedDataObj(obj, sessionIdxs, movebins, conditioningMode, tsID, Mode, nbins, timePad, conditionNm1RewOrEarly)
			% 
			% 	NB: we divide by number of trials per bin
			% 
			% 	for use with prepXconditioning objects. 
			% 
			% 		tsID: 'gfit' or 'nmb' or 'rawF' or 'X'
			% 
			% 		conditioningMode: 'ratio', 'amp' or 'amplitude' or 'none' (uses all trials)
			% 
			% 	We have binned trials based on how much ongoing movement was happening during the timing interval
			% 		Goal now is to make a photometry object with binned data 
			% 
			if nargin < 2 || isempty(sessionIdxs)
				sessionIdxs = 1:numel(obj.collatedResults);
			end
			if nargin < 3
				movebins = 1:obj.iv.n/2; 
			elseif strcmpi(movebins, 'all')
				movebins = 1:obj.iv.n; 
			end
			if nargin < 4
				conditioningMode = 'amplitude';
			end
			if nargin < 5
				tsID = 'gfit';
			end
			if nargin < 6
				Mode = 'custom';
			end
			if nargin < 7
				nbins = [0,700,1000,1500,2000,2500,3333,3334,4500,7000,17000];
			end
			if nargin < 8
				timePad = 30000;
			end
			if nargin < 9
				conditionNm1RewOrEarly = 'off';
			end

			nMice = numel(unique([obj.collatedResults(sessionIdxs).animalIdx]));
			disp('------------------------------------------------------------------')
			disp(' Executing binned timeseries conditioned on movement')
			disp([' Conditioning Mode: ' conditioningMode])
			disp([' movebins: ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n)])
			disp([' Sessions included: ' num2str(numel(sessionIdxs)) '/' num2str(numel(obj.collatedResults))])
			disp([' nMice included: ' num2str(nMice) '/' num2str(numel(unique(unique([obj.collatedResults(:).animalIdx]))))])
			disp([' Runs at ~15 s/file, total est time: ' num2str(round(15/60*numel(sessionIdxs),2)) ' min'])
			

			obj.analysis.ts = []; % we will store the composite binned data here. since everything is binned the same way, we need only cook up the first obj, then append
			obj.analysis.ts.sessionIdxs = sessionIdxs;
            obj.analysis.ts.sessionIDs = {obj.collatedResults(sessionIdxs).sessionID}';
			obj.analysis.ts.movebins = movebins;
			obj.analysis.ts.conditioningMode = conditioningMode;
			obj.analysis.ts.tsID = tsID;
			obj.analysis.ts.Mode = Mode;
			obj.analysis.ts.nbins = nbins;
			obj.analysis.ts.timePad = timePad;
			obj.analysis.ts.conditionNm1RewOrEarly = conditionNm1RewOrEarly;
			obj.analysis.ts.nMice = nMice;
			for dd = 1:numel(sessionIdxs)
				d = sessionIdxs(dd);
				[sObj, ts, trialsIncluded] = loadUpPrepXConditioningDatasets(obj,d, dd, tsID,sessionIdxs,conditioningMode, movebins); % I recently replaced the commented region below with this fx. if error, check here
				% disp('----------------------------')
				% disp(['   Cooking: ' obj.collatedResults(dd).sessionID ' ' num2str(dd) '/' num2str(numel(sessionIdxs)) '...(' datestr(now) ')'])
				% if strcmpi(tsID, 'X')
				% 	[folder, filename] = obj.findFile(dd, 'mObj', false);
				% else
				% 	[folder, filename] = obj.findFile(dd, 'sObj', false);
				% end
				% sObj = loadFile(obj, folder, filename);
    %             if isfield(sObj.Log, 'f_log')
    %                 try
    %                     close(sObj.Log.f_log)
    %                 catch
    %                 end
    %             end
				% if strcmpi(tsID, 'gfit') && contains(sObj.GLM.gfitMode, 'box200') || strcmpi(tsID, 'X')
				% 	ts = sObj.GLM.gfit;
				% elseif strcmpi(tsID, 'nmb') && contains(sObj.GLM.gfitMode, 'box200')
    %                 disp(['      Calculating nmultibaseline dF/F'])
				% 	sObj.normalizedMultiBaselineDFF(5000, 10, sObj.GLM.rawF);
				% 	ts = sObj.gFitLP.nMultibDFF.dFF;
				% elseif strcmpi(tsID, 'rawF')
				% 	ts = sObj.GLM.rawF;
				% else
				% 	error('either dF/F isn''t gfit box200000 or something else is wrong... possible tsIDs: ''gfit'' or ''nmb''')
				% end
				% if strcmpi(conditioningMode, 'ratio')
				% 	trialsIncluded = cell2mat(obj.collatedResults(d).Ratio.binnedData.trialIds(movebins,1));
				% elseif strcmpi(conditioningMode, 'amp') || strcmpi(conditioningMode, 'amplitude')
				% 	trialsIncluded = cell2mat(obj.collatedResults(d).Amplitude.binnedData.trialIds(movebins,1));
				% elseif strcmpi(conditioningMode, 'none')
				% 	trialsIncluded = sort(cell2mat(obj.collatedResults(d).analysis.trialID));
				% end
				% sObj.getBinnedTimeseries(ts, Mode, nbins, timePad, trialsIncluded, [], false, [], conditionNm1RewOrEarly);

				if strcmpi(Mode, 'paired') && obj.analysis.SessionPlotOn	
					td = pwd;
					cd(obj.iv.suppressNsave.figuresHOST)
					set(gcf,'name',[sObj.iv.mousename_ '_' sObj.iv.signalname{1} '_' sObj.iv.daynum_ ])
                    timestamp_now = datestr(now,'mm_dd_yy__HH_MM');
        			set(gcf, 'userdata', [sObj.iv.filename_ '__' timestamp_now '.mat'])
                    if nbins{3}(1) > nbins{2}(1)
						title(['early->late: {2,' mat2str(nbins{2}) ',' mat2str(nbins{3}) '}'])
                        savefig(gcf, ['early-late trialPositions ' sObj.iv.mousename_ '_' sObj.iv.signalname{1} '_' sObj.iv.daynum_  ' Xconditioning' conditioningMode '(lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(nbins)) '_' tsID '_' conditionNm1RewOrEarly])
                    else
						title(['late->early: {2,' mat2str(nbins{2}) ',' mat2str(nbins{3}) '}'])
						savefig(gcf, ['late-early trialPositions ' sObj.iv.mousename_ '_' sObj.iv.signalname{1} '_' sObj.iv.daynum_  ' Xconditioning' conditioningMode '(lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(nbins)) '_' tsID '_' conditionNm1RewOrEarly])
					end
        			
        			
        			sObj.plot('CTA', 'all', false, 100, 'first-to-last', true)
        			set(gcf,'name', [sObj.iv.mousename_ '_' sObj.iv.signalname{1} '_' sObj.iv.daynum_ ])
        			set(gcf, 'userdata', [obj.collatedResults(d).sObj ', plotted' timestamp_now '.mat'])
					xlim([-10,5])
        			if nbins{3}(1) > nbins{2}(1)
						title(['early->late: {2,' mat2str(nbins{2}) ',' mat2str(nbins{3}) '}'])
						savefig(gcf, ['early-late CTA ' sObj.iv.mousename_ '_' sObj.iv.signalname{1} '_' sObj.iv.daynum_  ' Xconditioning' conditioningMode '(lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(nbins)) '100msm_' tsID '_' conditionNm1RewOrEarly])
					else
						title(['late->early: {2,' mat2str(nbins{2}) ',' mat2str(nbins{3}) '}'])
						savefig(gcf, ['late-early CTA' sObj.iv.mousename_ '_' sObj.iv.signalname{1} '_' sObj.iv.daynum_  ' Xconditioning' conditioningMode '(lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(nbins)) '100msm_' tsID '_' conditionNm1RewOrEarly])
					end
					cd(td)	
				elseif strcmpi(Mode, 'triplet') && obj.analysis.SessionPlotOn	
					td = pwd;
					cd(obj.iv.suppressNsave.figuresHOST)
					set(gcf,'name',[sObj.iv.mousename_ '_' sObj.iv.signalname{1} '_' sObj.iv.daynum_ ])
                    timestamp_now = datestr(now,'mm_dd_yy__HH_MM');
        			set(gcf, 'userdata', [sObj.iv.filename_ '__' timestamp_now '.mat'])
                    if nbins{3}(1) > nbins{2}(1)
						title(['triplet (early)->early->late: {2,' mat2str(nbins{2}) ',' mat2str(nbins{3}) '}'])
                        savefig(gcf, ['triplet (early)-early-late trialPositions ' sObj.iv.mousename_ '_' sObj.iv.signalname{1} '_' sObj.iv.daynum_  ' Xconditioning' conditioningMode '(lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(nbins)) '_' tsID '_' conditionNm1RewOrEarly])
                    elseif nbins{3}(1) == nbins{2}(1) && nbins{3}(1) == 700
        				title(['triplet (early)->early->early: {2,' mat2str(nbins{2}) ',' mat2str(nbins{3}) '}'])
                        savefig(gcf, ['triplet (early)-early-early trialPositions ' sObj.iv.mousename_ '_' sObj.iv.signalname{1} '_' sObj.iv.daynum_  ' Xconditioning' conditioningMode '(lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(nbins)) '_' tsID '_' conditionNm1RewOrEarly])
    				elseif nbins{3}(1) == nbins{2}(1) && nbins{3}(1) == 3334
						title(['triplet (late)->late->late: {2,' mat2str(nbins{2}) ',' mat2str(nbins{3}) '}'])
                        savefig(gcf, ['triplet (late)-late-late trialPositions ' sObj.iv.mousename_ '_' sObj.iv.signalname{1} '_' sObj.iv.daynum_  ' Xconditioning' conditioningMode '(lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(nbins)) '_' tsID '_' conditionNm1RewOrEarly])
                    else
						title(['triplet (late)->late->early: {2,' mat2str(nbins{2}) ',' mat2str(nbins{3}) '}'])
						savefig(gcf, ['triplet (late)-late-early trialPositions ' sObj.iv.mousename_ '_' sObj.iv.signalname{1} '_' sObj.iv.daynum_  ' Xconditioning' conditioningMode '(lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(nbins)) '_' tsID '_' conditionNm1RewOrEarly])
					end
        			
        			
        			sObj.plot('CTA', 'all', false, 100, 'first-to-last', true)
        			set(gcf,'name', [sObj.iv.mousename_ '_' sObj.iv.signalname{1} '_' sObj.iv.daynum_ ])
        			set(gcf, 'userdata', [obj.collatedResults(d).sObj ', plotted' timestamp_now '.mat'])
					xlim([-10,5])
        			if nbins{3}(1) > nbins{2}(1)
						title(['triplet (early)->early->late: {2,' mat2str(nbins{2}) ',' mat2str(nbins{3}) '}'])
						savefig(gcf, ['triplet (early)-early-late CTA ' sObj.iv.mousename_ '_' sObj.iv.signalname{1} '_' sObj.iv.daynum_  ' Xconditioning' conditioningMode '(lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(nbins)) '100msm_' tsID '_' conditionNm1RewOrEarly])
					elseif nbins{3}(1) == nbins{2}(1) && nbins{3}(1) == 700
        				title(['triplet (early)->early->early: {2,' mat2str(nbins{2}) ',' mat2str(nbins{3}) '}'])
						savefig(gcf, ['triplet (early)-early-early CTA ' sObj.iv.mousename_ '_' sObj.iv.signalname{1} '_' sObj.iv.daynum_  ' Xconditioning' conditioningMode '(lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(nbins)) '100msm_' tsID '_' conditionNm1RewOrEarly])
    				elseif nbins{3}(1) == nbins{2}(1) && nbins{3}(1) == 3334
						title(['triplet (late)->late->late: {2,' mat2str(nbins{2}) ',' mat2str(nbins{3}) '}'])
						savefig(gcf, ['triplet (late)-late-late CTA ' sObj.iv.mousename_ '_' sObj.iv.signalname{1} '_' sObj.iv.daynum_  ' Xconditioning' conditioningMode '(lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(nbins)) '100msm_' tsID '_' conditionNm1RewOrEarly])
					else
						title(['triplet (late)->late->early: {2,' mat2str(nbins{2}) ',' mat2str(nbins{3}) '}'])
						savefig(gcf, ['triplet (late)-late-early CTA' sObj.iv.mousename_ '_' sObj.iv.signalname{1} '_' sObj.iv.daynum_  ' Xconditioning' conditioningMode '(lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(nbins)) '100msm_' tsID '_' conditionNm1RewOrEarly])
					end
					cd(td)					
				else
					close
				end

				if dd == 1
					obj.analysis.ts.BinnedData = sObj.ts.BinnedData;
                    obj.analysis.ts.BinParams = sObj.ts.BinParams;
                    obj.analysis.ts.BinParams.trialsIDs{dd,1} = sObj.ts.BinParams.trials_in_each_bin;
                    obj.analysis.ts.Plot = sObj.ts.Plot;
					obj.analysis.ts.NperBin = cell2mat(cellfun(@(x) numel(x), sObj.ts.BinParams.trials_in_each_bin, 'uniformoutput', 0));
					cc = [];
					for ib = 1:numel(obj.analysis.ts.BinnedData.CTA)
						if ~isempty(obj.analysis.ts.BinnedData.CTA{ib})
							cc = numel(obj.analysis.ts.BinnedData.CTA{ib});
							ll = numel(obj.analysis.ts.BinnedData.LTA{ib});
							break
						end
					end
					% 
					% 	set blanks for running ave
					% 
                    obj.analysis.ts.BinnedData.CTA(cellfun(@isempty, obj.analysis.ts.BinnedData.CTA)) = {nan(1,cc)};
                    obj.analysis.ts.BinnedData.LTA(cellfun(@isempty, obj.analysis.ts.BinnedData.LTA)) = {nan(1,ll)};
				else
					% 
					% 	Running average and update
					% 
					obj.analysis.ts.BinParams.trialsIDs{dd,1} = sObj.ts.BinParams.trials_in_each_bin;
					binningHelper;
				end
            end
            disp('----------------------------')
            %
            %   Fix legend
            %
            for ibin = 1:numel(obj.analysis.ts.BinParams.Legend_s.CLTA)
                npos = strsplit(obj.analysis.ts.BinParams.Legend_s.CLTA{ibin}, 'n='); 
                obj.analysis.ts.BinParams.Legend_s.CLTA{ibin} = [npos{1}, 'n=', num2str(obj.analysis.ts.NperBin(ibin))];
            end
			% 
			% 	Now, hoping all went well, we initialize a new sObj with our ts data...
			% 
			collatedObj = CLASS_photometry_roadmapv1_4('empty');
			collatedObj.ts = obj.analysis.ts;
			collatedObj.iv.CLASS = 'CLASS_photometry_roadmapv1_4';
			collatedObj.iv.initType = 'Created from STATcollate_photometry, obj.createCompositeBinnedDataObj.';
			collatedObj.iv.COLLATEDiv = obj.iv;
			collatedObj.iv.sessionIdxs = sessionIdxs;
			collatedObj.iv.movebins = movebins;
			collatedObj.iv.conditioningMode = conditioningMode;
			collatedObj.iv.tsID = tsID;
			collatedObj.iv.Mode = Mode;
			collatedObj.iv.nbins = nbins;
			collatedObj.iv.timePad = timePad;
			collatedObj.iv.conditionNm1RewOrEarly = conditionNm1RewOrEarly;

			collatedObj.iv.BingoMODE = false;
			collatedObj.iv.setStyle = 'v3x Combined Datasets';
			collatedObj.iv.date = datestr(now);
			collatedObj.iv.exptype_ = 'op';
			collatedObj.iv.rxnwin_ = 0;
            if isfield(sObj.iv, 'total_time_')            
    			collatedObj.iv.total_time_ = sObj.iv.total_time_;
            else
                collatedObj.iv.total_time_ = 17000;
            end
			collatedObj.iv.num_trials = sum(obj.analysis.ts.NperBin);
			collatedObj.iv.signalname = sObj.iv.signalname;
			collatedObj.iv.signaltype_ = sObj.iv.signaltype_;
			collatedObj.iv.ctrl_signalname = 'X';
			collatedObj.iv.ctrl_signaltype_ = sObj.iv.ctrl_signaltype_;
            
            collatedObj.Plot = sObj.Plot;

            if numel(nbins) > 1
                ognbins = nbins;
                nbins = numel(nbins);
            end
			collatedObj.iv.filename_ = ['sObjComposite_v3x10_' sObj.iv.signalname{1} '_conditionedOnMovement_' conditioningMode '_mbins_' num2str(movebins(1)) '-' num2str(movebins(end)) 'of' num2str(obj.iv.n) '_Mode_' Mode '_nbins' num2str(nbins), '_' num2str(obj.analysis.ts.nMice) 'mice_' num2str(numel(sessionIdxs)) 'sesh_' tsID];
			

            if strcmpi(tsID, 'gfit')
    			collatedObj.GLM.gfitMode = sObj.GLM.gfitMode;
            elseif strcmpi(tsID, 'nmb')
                collatedObj.GLM.gfitMode = sObj.gFitLP.nMultibDFF.style;
            end
			collatedObj.GLM.tsID = tsID;
            collatedObj.iv.n = obj.iv.n;

			timestamp_now = datestr(now,'mm_dd_yy__HH_MM');
            fn = [collatedObj.iv.filename_ '__' timestamp_now '.mat'];
            
            save(fn, 'collatedObj', '-v7.3')
            disp('~~~~~~ Composite object saved! ~~~~~~~')
            disp(fn)
            
            
            if strcmpi(Mode, 'paired') || strcmpi(Mode, 'triplet')
	            collatedObj.plot('CLTA', 'all', false, 100, 'first-to-last', true); xlim([-2, 6])
	            set(gcf, 'userdata', [collatedObj.iv.filename_ '__' timestamp_now '.mat'])
             	if strcmpi(Mode, 'paired')
	            	if ognbins{3}(1) > ognbins{2}(1)
	            		title(sprintf(['early->late: {2,' mat2str(ognbins{2}) ',' mat2str(ognbins{3}) '} \n Composite ' sObj.iv.signalname{1} ' | excess move ' conditioningMode ' (lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', 100msm ' tsID]))
	            		savefig(gcf, ['Composite early-late rawFpaired' collatedObj.iv.signalname{1} ' excessMove' collatedObj.iv.conditioningMode '(lo-hi), mbins ' num2str(collatedObj.iv.movebins(1)) '-' num2str(collatedObj.iv.movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(collatedObj.iv.nbins)) '100msm_' collatedObj.GLM.tsID '_' collatedObj.iv.conditionNm1RewOrEarly])
	        		else
	        			title(sprintf(['late->early: {2,' mat2str(ognbins{2}) ',' mat2str(ognbins{3}) '} \n Composite ' sObj.iv.signalname{1} ' | excess move ' conditioningMode ' (lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', 100msm ' tsID]))
	        			savefig(gcf, ['Composite late-early rawFpaired' collatedObj.iv.signalname{1} ' excessMove' collatedObj.iv.conditioningMode '(lo-hi), mbins ' num2str(collatedObj.iv.movebins(1)) '-' num2str(collatedObj.iv.movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(collatedObj.iv.nbins)) '100msm_' collatedObj.GLM.tsID '_' collatedObj.iv.conditionNm1RewOrEarly])
	    			end
				elseif strcmpi(Mode, 'triplet')
					xlim([-10,7])
					if ognbins{3}(1) > ognbins{2}(1)
	            		title(sprintf(['triplet (early)->early->late: {2,' mat2str(ognbins{2}) ',' mat2str(ognbins{3}) '} \n Composite ' sObj.iv.signalname{1} ' | excess move ' conditioningMode ' (lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', 100msm ' tsID]))
	            		savefig(gcf, ['Composite triplet (early)-early-late rawFpaired' collatedObj.iv.signalname{1} ' excessMove' collatedObj.iv.conditioningMode '(lo-hi), mbins ' num2str(collatedObj.iv.movebins(1)) '-' num2str(collatedObj.iv.movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(collatedObj.iv.nbins)) '100msm_' collatedObj.GLM.tsID '_' collatedObj.iv.conditionNm1RewOrEarly])
	            	elseif ognbins{3}(1) == ognbins{2}(1) && ognbins{3}(1) == 700
	            		title(sprintf(['triplet (early)->early->early: {2,' mat2str(ognbins{2}) ',' mat2str(ognbins{3}) '} \n Composite ' sObj.iv.signalname{1} ' | excess move ' conditioningMode ' (lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', 100msm ' tsID]))
	            		savefig(gcf, ['Composite triplet (early)-early-early rawFpaired' collatedObj.iv.signalname{1} ' excessMove' collatedObj.iv.conditioningMode '(lo-hi), mbins ' num2str(collatedObj.iv.movebins(1)) '-' num2str(collatedObj.iv.movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(collatedObj.iv.nbins)) '100msm_' collatedObj.GLM.tsID '_' collatedObj.iv.conditionNm1RewOrEarly])
	        		elseif ognbins{3}(1) == ognbins{2}(1) && ognbins{3}(1) == 3334
	            		title(sprintf(['triplet (late)->late->late: {2,' mat2str(ognbins{2}) ',' mat2str(ognbins{3}) '} \n Composite ' sObj.iv.signalname{1} ' | excess move ' conditioningMode ' (lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', 100msm ' tsID]))
	            		savefig(gcf, ['Composite triplet (late)-late-late rawFpaired' collatedObj.iv.signalname{1} ' excessMove' collatedObj.iv.conditioningMode '(lo-hi), mbins ' num2str(collatedObj.iv.movebins(1)) '-' num2str(collatedObj.iv.movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(collatedObj.iv.nbins)) '100msm_' collatedObj.GLM.tsID '_' collatedObj.iv.conditionNm1RewOrEarly])
	        		else
	        			title(sprintf(['triplet (late)->late->early: {2,' mat2str(ognbins{2}) ',' mat2str(ognbins{3}) '} \n Composite ' sObj.iv.signalname{1} ' | excess move ' conditioningMode ' (lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', 100msm ' tsID]))
	        			savefig(gcf, ['Composite triplet (late)-late-early rawFpaired' collatedObj.iv.signalname{1} ' excessMove' collatedObj.iv.conditioningMode '(lo-hi), mbins ' num2str(collatedObj.iv.movebins(1)) '-' num2str(collatedObj.iv.movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(collatedObj.iv.nbins)) '100msm_' collatedObj.GLM.tsID '_' collatedObj.iv.conditionNm1RewOrEarly])
	    			end
    			end
	        else   
	        	collatedObj.plot('CLTA', 'all', false, 100, 'last-to-first', true); xlim([-2, 6])
            	set(gcf, 'userdata', [collatedObj.iv.filename_ '__' timestamp_now '.mat'])
	            title(['Composite ' sObj.iv.signalname{1} ' | excess move ' conditioningMode ' (lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', 100msm ' tsID])
	            savefig(gcf, ['Composite ' collatedObj.iv.signalname{1} ' excessMove' collatedObj.iv.conditioningMode '(lo-hi), mbins ' num2str(collatedObj.iv.movebins(1)) '-' num2str(collatedObj.iv.movebins(end)) ' of ' num2str(obj.iv.n) ', _nbins' num2str(numel(collatedObj.iv.nbins)) '100msm_' collatedObj.GLM.tsID '_' collatedObj.iv.conditionNm1RewOrEarly])
            end             
    	end
    	function rawFcomparisons(obj, Mode, tsID,SessionPlotOn)
    		% 
    		% 	For use with prepXconditioning collated objs -- creates a composite obj and also saves individual session plots
    		% 
    		% 	Mode: 'paired' or 'triplet'
    		% 
    		% 	tsID: 'gfit', 'X', 'nmb', 'rawF'
    		% 
            if nargin < 4
                SessionPlotOn = true;
            end
            if nargin < 3
            	tsID = 'rawF';
        	end
            if nargin < 2
                Mode = 'paired';
            end
    		obj.analysis.SessionPlotOn = SessionPlotOn;
    		if strcmpi(Mode, 'paired')
    			obj.createCompositeBinnedDataObj([], 'all', 'none', tsID, 'paired', {2, [700, 3333], [3334, 7000]}, 30000, 'off');
	    		obj.createCompositeBinnedDataObj([], 'all', 'none', tsID, 'paired', {2, [3334, 7000], [700, 3333]}, 30000, 'off');
    		else strcmpi(Mode, 'triplet')
    			obj.createCompositeBinnedDataObj([], 'all', 'none', tsID, 'triplet', {2, [700,3333], [3334,7000]}, 30000, 'off');
    			obj.createCompositeBinnedDataObj([], 'all', 'none', tsID, 'triplet', {2, [700,3333], [700,3333]}, 30000, 'off');
    			obj.createCompositeBinnedDataObj([], 'all', 'none', tsID, 'triplet', {2, [3334,7000], [700,3333]}, 30000, 'off');
    			obj.createCompositeBinnedDataObj([], 'all', 'none', tsID, 'triplet', {2, [3334,7000], [3334,7000]}, 30000, 'off');
			end
		end
		function plotBinnedsObjCLTA(obj,collatedObj)
			% 
			% 	A convenient shortcut to plotting binned objects CLTA. make sure to have a STAT_collate obj open in addition to the photometry object
			% 
			timestamp_now = datestr(now,'mm_dd_yy__HH_MM');
            Mode = collatedObj.iv.Mode;
            ognbins = collatedObj.iv.nbins;
            conditioningMode = collatedObj.iv.conditioningMode;
            movebins = collatedObj.iv.movebins;
            tsID = collatedObj.iv.tsID;
			if strcmpi(Mode, 'paired') || strcmpi(Mode, 'triplet')
	            collatedObj.plot('CLTA', 'all', false, 100, 'first-to-last', true); xlim([-2, 6])
	            set(gcf, 'userdata', [collatedObj.iv.filename_ '__' timestamp_now '.mat'])
             	if strcmpi(Mode, 'paired')
	            	if ognbins{3}(1) > ognbins{2}(1)
	            		title(sprintf(['early->late: {2,' mat2str(ognbins{2}) ',' mat2str(ognbins{3}) '} \n Composite ' collatedObj.iv.signalname{1} ' | excess move ' conditioningMode ' (lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', 100msm ' tsID]))
	            		savefig(gcf, ['Composite early-late rawFpaired' collatedObj.iv.signalname{1} ' excessMove' collatedObj.iv.conditioningMode '(lo-hi), mbins ' num2str(collatedObj.iv.movebins(1)) '-' num2str(collatedObj.iv.movebins(end)) ' of ' num2str(collatedObj.iv.n) ', _nbins' num2str(numel(collatedObj.iv.nbins)) '100msm_' collatedObj.GLM.tsID '_' collatedObj.iv.conditionNm1RewOrEarly])
	        		else
	        			title(sprintf(['late->early: {2,' mat2str(ognbins{2}) ',' mat2str(ognbins{3}) '} \n Composite ' collatedObj.iv.signalname{1} ' | excess move ' conditioningMode ' (lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', 100msm ' tsID]))
	        			savefig(gcf, ['Composite late-early rawFpaired' collatedObj.iv.signalname{1} ' excessMove' collatedObj.iv.conditioningMode '(lo-hi), mbins ' num2str(collatedObj.iv.movebins(1)) '-' num2str(collatedObj.iv.movebins(end)) ' of ' num2str(collatedObj.iv.n) ', _nbins' num2str(numel(collatedObj.iv.nbins)) '100msm_' collatedObj.GLM.tsID '_' collatedObj.iv.conditionNm1RewOrEarly])
	    			end
				elseif strcmpi(Mode, 'triplet')
					xlim([-10,7])
					if ognbins{3}(1) > ognbins{2}(1)
	            		title(sprintf(['triplet (early)->early->late: {2,' mat2str(ognbins{2}) ',' mat2str(ognbins{3}) '} \n Composite ' collatedObj.iv.signalname{1} ' | excess move ' conditioningMode ' (lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', 100msm ' tsID]))
	            		savefig(gcf, ['Composite triplet (early)-early-late rawFpaired' collatedObj.iv.signalname{1} ' excessMove' collatedObj.iv.conditioningMode '(lo-hi), mbins ' num2str(collatedObj.iv.movebins(1)) '-' num2str(collatedObj.iv.movebins(end)) ' of ' num2str(collatedObj.iv.n) ', _nbins' num2str(numel(collatedObj.iv.nbins)) '100msm_' collatedObj.GLM.tsID '_' collatedObj.iv.conditionNm1RewOrEarly])
	            	elseif ognbins{3}(1) == ognbins{2}(1) && ognbins{3}(1) == 700
	            		title(sprintf(['triplet (early)->early->early: {2,' mat2str(ognbins{2}) ',' mat2str(ognbins{3}) '} \n Composite ' collatedObj.iv.signalname{1} ' | excess move ' conditioningMode ' (lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', 100msm ' tsID]))
	            		savefig(gcf, ['Composite triplet (early)-early-early rawFpaired' collatedObj.iv.signalname{1} ' excessMove' collatedObj.iv.conditioningMode '(lo-hi), mbins ' num2str(collatedObj.iv.movebins(1)) '-' num2str(collatedObj.iv.movebins(end)) ' of ' num2str(collatedObj.iv.n) ', _nbins' num2str(numel(collatedObj.iv.nbins)) '100msm_' collatedObj.GLM.tsID '_' collatedObj.iv.conditionNm1RewOrEarly])
	        		elseif ognbins{3}(1) == ognbins{2}(1) && ognbins{3}(1) == 3334
	            		title(sprintf(['triplet (late)->late->late: {2,' mat2str(ognbins{2}) ',' mat2str(ognbins{3}) '} \n Composite ' collatedObj.iv.signalname{1} ' | excess move ' conditioningMode ' (lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', 100msm ' tsID]))
	            		savefig(gcf, ['Composite triplet (late)-late-late rawFpaired' collatedObj.iv.signalname{1} ' excessMove' collatedObj.iv.conditioningMode '(lo-hi), mbins ' num2str(collatedObj.iv.movebins(1)) '-' num2str(collatedObj.iv.movebins(end)) ' of ' num2str(collatedObj.iv.n) ', _nbins' num2str(numel(collatedObj.iv.nbins)) '100msm_' collatedObj.GLM.tsID '_' collatedObj.iv.conditionNm1RewOrEarly])
	        		else
	        			title(sprintf(['triplet (late)->late->early: {2,' mat2str(ognbins{2}) ',' mat2str(ognbins{3}) '} \n Composite ' collatedObj.iv.signalname{1} ' | excess move ' conditioningMode ' (lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', 100msm ' tsID]))
	        			savefig(gcf, ['Composite triplet (late)-late-early rawFpaired' collatedObj.iv.signalname{1} ' excessMove' collatedObj.iv.conditioningMode '(lo-hi), mbins ' num2str(collatedObj.iv.movebins(1)) '-' num2str(collatedObj.iv.movebins(end)) ' of ' num2str(collatedObj.iv.n) ', _nbins' num2str(numel(collatedObj.iv.nbins)) '100msm_' collatedObj.GLM.tsID '_' collatedObj.iv.conditionNm1RewOrEarly])
	    			end
    			end
	        else   
	        	collatedObj.plot('CLTA', 'all', false, 100, 'last-to-first', true); xlim([-2, 6])
            	set(gcf, 'userdata', [collatedObj.iv.filename_ '__' timestamp_now '.mat'])
	            title(['Composite ' collatedObj.iv.signalname{1} ' | excess move ' conditioningMode ' (lo-hi), mbins ' num2str(movebins(1)) '-' num2str(movebins(end)) ' of ' num2str(obj.iv.n) ', 100msm ' tsID])
	            savefig(gcf, ['Composite ' collatedObj.iv.signalname{1} ' excessMove' collatedObj.iv.conditioningMode '(lo-hi), mbins ' num2str(collatedObj.iv.movebins(1)) '-' num2str(collatedObj.iv.movebins(end)) ' of ' num2str(collatedObj.iv.n) ', _nbins' num2str(numel(collatedObj.iv.nbins)) '100msm_' collatedObj.GLM.tsID '_' collatedObj.iv.conditionNm1RewOrEarly])
            end         
		end
		function compileBaselines(obj, tsID,rewrite)
			% 
			% 	For use with prepXconditioning objects, where we have a corresponding X file for every photometry file.
			% 
			% 	tsID = 'gfit', 'nmb', 'rawF', 'X'
			% 		if X, will go to the X directory to pull out correct baseline period
			% 
			% 	Goal is to extract baseline of the signal type for each session so that we can quickly manipulate it. We will take the entire ITI from end of trial to LAMPoff event
			% 

			% use a common file parsing machinery
			sessionIdxs = 1:numel(obj.collatedResults);
			if nargin < 2
				tsID = 'gfit';
			end
			if nargin < 3
				rewrite = false;
			end
			nMice = numel(unique([obj.collatedResults(sessionIdxs).animalIdx]));

			if ~isfield(obj.analysis, 'baseline')
				
				obj.analysis.baseline.gfit.signals = cell(numel(sessionIdxs),1);
				obj.analysis.baseline.nmb.signals = cell(numel(sessionIdxs),1);
				obj.analysis.baseline.X.signals = cell(numel(sessionIdxs),1);
				obj.analysis.baseline.rawF.signals = cell(numel(sessionIdxs),1);
				
			end
			if eval(['~isempty(obj.analysis.baseline.' tsID '.signals)']) 
				if rewrite
					warning('Overwriting existing baseline dataset...')
					eval(['obj.analysis.baseline.' tsID  '.signals = cell(numel(sessionIdxs),1);'])
				else
					warning(['There''s already a baseline dataset matching ' tsID '. Specify rewrite=true to overwrite.'])
					return
				end
			end
			params.nMice = nMice;
			params.sessionIdxs = sessionIdxs;
            params.sessionIDs = {obj.collatedResults(sessionIdxs).sessionID}';

			
			disp('------------------------------------------------------------------')
			disp(' Executing baseline grabbing for all sessions')
			disp([' tsID: ' tsID])
			disp([' Sessions included: ' num2str(numel(sessionIdxs)) '/' num2str(numel(obj.collatedResults))])
			disp([' nMice included: ' num2str(nMice) '/' num2str(numel(unique(unique([obj.collatedResults(:).animalIdx]))))])
			disp([' Runs at ~15 s/file, total est time: ' num2str(round(15/60*numel(sessionIdxs),2)) ' min'])
			baselines = cell(numel(sessionIdxs),1);
			for dd = 1:numel(sessionIdxs)
				d = sessionIdxs(dd);
				[sObj, ts, ~] = obj.loadUpPrepXConditioningDatasets(d, dd, tsID,sessionIdxs);
				baselines{d} = obj.extractBaseline(ts,sObj);
			end
			eval(['obj.analysis.baseline.' tsID  '.params = params;'])
			eval(['obj.analysis.baseline.' tsID  '.signals = baselines;'])
		end
		function baselines = extractBaseline(obj, ts, sObj)
			% 
			% 	Determine the indicies of the beginnings of each baseline Period...
			% 
			ITIsamples = round(10000 * sObj.Plot.samples_per_ms);
			sObj.GLM.pos.baselineStart = sObj.GLM.pos.lampOff - ITIsamples + 1;
			sObj.GLM.pos.baselineStart(end+1) = numel(sObj.GLM.rawF); % tack on the full length so that we can correct the entire signal...
            sObj.GLM.pos.NBbaselineStartRel2LAMPOFF = [];
			baselines = cell(numel(sObj.GLM.pos.cue), 1);
            assert(numel(sObj.GLM.gfit) == numel(ts));
			for iTrial = 1:numel(sObj.GLM.pos.cue)
				baselines{iTrial} = ts(sObj.GLM.pos.baselineStart(iTrial):sObj.GLM.pos.lampOff(iTrial));
			end
			% 
			% 	recoup the baselines for good trials as
			% ccc = cell2mat(cellfun(@(x) x',obj.analysis.baseline.nmb.signals{d}(~isnan(obj.collatedResults(d).flick_s_wrtc)), 'uniformoutput',0))
			% 
		end
		function [sObj, ts, trialsIncluded] = loadUpPrepXConditioningDatasets(obj,d, dd, tsID, sessionIdxs, conditioningMode, movebins)
			if nargin < 6
				conditioningMode = 'none';
			end
			disp('----------------------------')
			disp(['   Cooking: ' obj.collatedResults(dd).sessionID ' ' num2str(dd) '/' num2str(numel(sessionIdxs)) '...(' datestr(now) ')'])
			if strcmpi(tsID, 'X')
				[folder, filename] = obj.findFile(dd, 'mObj', false);
			else
				[folder, filename] = obj.findFile(dd, 'sObj', false);
			end
			sObj = loadFile(obj, folder, filename);
            if isfield(sObj.Log, 'f_log')
                try
                    close(sObj.Log.f_log)
                catch
                end
            end
			if strcmpi(tsID, 'gfit') && contains(sObj.GLM.gfitMode, 'box200') || strcmpi(tsID, 'X')
				ts = sObj.GLM.gfit;
			elseif strcmpi(tsID, 'nmb') && contains(sObj.GLM.gfitMode, 'box200')
                disp(['      Calculating nmultibaseline dF/F'])
				sObj.normalizedMultiBaselineDFF(5000, 10, sObj.GLM.rawF);
				ts = sObj.gFitLP.nMultibDFF.dFF;
			elseif strcmpi(tsID, 'rawF')
				ts = sObj.GLM.rawF;
			else
				error('either dF/F isn''t gfit box200000 or something else is wrong... possible tsIDs: ''gfit,'' ''nmb,'' ''rawF,'' ''X''')
			end
			if strcmpi(conditioningMode, 'ratio')
				trialsIncluded = cell2mat(obj.collatedResults(d).Ratio.binnedData.trialIds(movebins,1));
			elseif strcmpi(conditioningMode, 'amp') || strcmpi(conditioningMode, 'amplitude')
				trialsIncluded = cell2mat(obj.collatedResults(d).Amplitude.binnedData.trialIds(movebins,1));
			elseif strcmpi(conditioningMode, 'none')
				trialsIncluded = sort(cell2mat(obj.collatedResults(d).analysis.trialID));
			end
		end
		function pullProperflickwrtcs(obj, rewrite)
			if nargin < 2
				rewrite = false;
			end
			if ~isfield(obj.collatedResults(1), 'flick_s_wrtc') || rewrite
				for d = 1:numel(obj.collatedResults)
					[sObj,~,~] = obj.loadUpPrepXConditioningDatasets(d, d, 'rawF', 1:numel(obj.collatedResults), 'none', 'n/a');
					sObj.getflickswrtc;
					obj.collatedResults(d).flick_s_wrtc = sObj.GLM.flick_s_wrtc;
				end
			end
		end
		function predictBaselineDA_GLM(obj, modelID, window_ms,Style,  tsID, sessionIdxs)
			% 
			% 	NB: ignores 1st trials for which n-trials back is incomplete
			% 
			% 	Style: median or mean
			%	window: part of the 10s ITI to take 
			% 
			% 	modelID is a code I assign to different encapsulations
			% 		versions:
			% 			'5 trials back, 5 categories'
			% 			'5 trials back, 5 categories-shuffle';
			% 			'10 trials back, rew no reward'
			% 			'10 trials back, rew no reward-shuffle'
			% 
			if nargin < 2 || isempty(modelID)
				modelID = '5 trials back, 5 categories';
				% modelID = '10 trials back, rew no reward';
			end
			if nargin < 3
				window_ms = 'all';
			end
			if nargin < 4
				Style = 'mean';
			end
			if strcmpi(modelID,'5 trials back, 5 categories-shuffle') || strcmpi(modelID,'10 trials back, rew no reward-shuffle')
				Style = [Style '-shuffle'];
			end
			if nargin < 5
				tsID = 'nmb';
			end
			if nargin < 6
				sessionIdxs = 'all';
			end
			if strcmpi(sessionIdxs, 'all')
				sessionIdxs = 1:numel(obj.collatedResults);
			end
			if strcmpi(window_ms, 'all')
				window_ms = 1:10000;
			end
			obj.compileBaselines(tsID,false);
			eval(['baselines = obj.analysis.baseline.' tsID '.signals;'])

			baseline_GLM_DA
		end
		function outcomeCodes = getTrialOutcome(obj, d)
			% 
			% 	Fetches trial outcome: 'rxn', 'early', 'reward', 'ITI', 'excluded'
			% 		NB: excluded includes noLick trials...
			%
			%%%%%%% WRITTEN FOR 3.3s task!!!!!!
			rxnMax = 0.7;
			earlyMax = 3.333;
			rewMax =7;


			flicks = obj.collatedResults(d).flick_s_wrtc;
			outcomeCodes = cell(numel(flicks),1);
			outcomeCodes(flicks<=rxnMax) = {'rxn'};
			outcomeCodes(flicks>rxnMax & flicks<=earlyMax) = {'early'};
			outcomeCodes(flicks>earlyMax & flicks<=rewMax) = {'rew'};
			outcomeCodes(flicks>rewMax & ~isnan(flicks)) = {'ITI'};
			outcomeCodes(isnan(flicks)) = {'excluded'};
		end
		function y = buildY_predictBaseline_GLM(obj, Style, window_ms,baselines, d)
			pre_y = cellfun(@(x) x(window_ms),baselines{d},'uniformoutput',0);
			if strcmpi(Style, 'median') || strcmpi(Style, 'median-shuffle')
				y = obj.normalize01(cell2mat(cellfun(@(x) nanmedian(x),pre_y,'uniformoutput',0)));
				if strcmpi(Style, 'median-shuffle')
					y = y(randperm(numel(y)));
				end
			elseif strcmpi(Style, 'mean') || strcmpi(Style, 'mean-shuffle')
				y = obj.normalize01(cell2mat(cellfun(@(x) nanmean(x),pre_y,'uniformoutput',0)));
				if strcmpi(Style, 'mean-shuffle')
					y = y(randperm(numel(y)));
				end
			else
				error('undefined Style. Choices: ''mean'' or ''median'' or ''mean-shuffle'' or ''median-shuffle''')
			end
		end
		function normX = normalize01(obj,x)
			% 
			% 	Set the min to be zero and the max to be 1
			% 
			flat = (x - min(x));
            normX = flat./max(flat);
		end
		function Xi = buildX_predictBaseline_GLM(obj, predictorCode, outcomeCodes,startTrial)
			if numel(predictorCode) == 2
				checks = [startTrial:numel(outcomeCodes)] - predictorCode{1};
				Xi = contains({outcomeCodes{checks}}, predictorCode{2});
			else
				if strcmp(predictorCode, 'b0')
					Xi = ones(1,numel(startTrial:numel(outcomeCodes)));
				end
			end
		end
		function [stats,Rsq,b,Rsqnull,bnull,yfit,NullLoss,TrainingLoss,SnLossImprovement] = GLMfit(obj,y,X, verbose)
			if nargin < 4
				verbose = true;
			end
			warning('off','stats:glmfit:IllConditioned');
        	[bnull,~,~] = glmfit(ones(size(y)),y, 'normal', 'constant', 'off');
	        [b,dev,stats] = glmfit(X',y, 'normal', 'constant', 'off');
            yfit = (b'*X)';
            ynull = bnull'*ones(size(y));
 			
 			Rsqnull = obj.Rsq(y,ynull);
 			Rsq = obj.Rsq(y,yfit);

 			NullLoss = 1/numel(y)*sum((y - ynull).^2);
 			TrainingLoss = 1/numel(y)*sum((y - yfit).^2);
 			SnLossImprovement = 1-TrainingLoss/NullLoss;
 			if verbose
	            disp(['	RsqNull: ' num2str(Rsqnull)])
	            disp(['	Rsq: ' num2str(Rsq)])
	            disp(['	NullLoss: ' num2str(NullLoss)])
	            disp(['	TrainingLoss: ' num2str(TrainingLoss)])
	            disp(['	Training Loss Improvement: ' num2str(SnLossImprovement)])
            end
		end
		function Rsq = Rsq(obj, y, yfit)
			% 
			% 	Updated 3/2/23 to avoid missing data
			% 
			incl = find(~isnan(y));
			ESS = sum((yfit(incl) - mean(y(incl))).^2);
 			RSS = sum((yfit(incl) - y(incl)).^2);
 			Rsq = ESS/(RSS+ESS); 
		end



    
    
   		function setAnimalID(obj)
   			% 
   			% 
   			% 
   			a = cellfun(@(x) strsplit(x, '_'), {obj.collatedResults.sessionID}, 'uniformoutput', 0);
			obj.iv.animalIDs = unique(cellfun(@(x) x{1}, a, 'uniformoutput', 0))';
			% obj.iv.animalIDs = cellfun(@(x) strcat(x, '_'), obj.iv.animalIDs, 'uniformoutput', 0);
			aa = cellfun(@(x) strsplit(x, '_'), {obj.collatedResults.sessionID}, 'uniformoutput', 0);
			a = cellfun(@(x) find(contains(obj.iv.animalIDs, x{1})), aa, 'uniformoutput', 0);
			[obj.collatedResults(:).animalIdx] = a{:};
		end
		function progressBar(obj, iter, total, nested, cutter)
			if nargin < 5
				cutter = 1000;
			end
			if nargin < 4
				nested = false;
			end
			if nested
				prefix = '		';
			else
				prefix = '';
			end
			if rem(iter,total*.1) == 0 || rem(iter, cutter) == 0
				done = {'=', '=', '=', '=', '=', '=', '=', '=', '=', '='};
				incomplete = {'-', '-', '-', '-', '-', '-', '-', '-', '-', '-'};
				ndone = round(iter/total * 10);
				nincomp = round((1 - iter/total) * 10);
				disp([prefix '	*' horzcat(done{1:ndone}) horzcat(incomplete{1:nincomp}) '	(' num2str(iter) '/' num2str(total) ') ' datestr(now)]);
			end
		end
		function pathstr = correctPathOS(obj,pathstr)
			if ispc
    			pathstr = strjoin(strsplit(pathstr, '/'), '\');
			else
				pathstr = [strjoin(strsplit(pathstr, '\'), '/')];
			end
		end

		function save(obj)
			ID = obj.iv.runID;
			if strcmpi(obj.iv.collateKey, 'sloshingModels') || strcmpi(obj.iv.collateKey, 'sloshingModels-sysclub')
				savefilename = ['CollatedStatAnalysisObj_' obj.iv.collateKey, '_' num2str(obj.iv.n{1}), '_', num2str(obj.iv.n{2}), '_', num2str(obj.iv.n{3}), '_', num2str(obj.iv.n{4}), '_', datestr(now, 'YYYYmmDD_HH_MM') '_runIDno' num2str(ID)];
			else
				savefilename = ['CollatedStatAnalysisObj_' obj.iv.collateKey, '_' datestr(now, 'YYYYmmDD_HH_MM') '_runIDno' num2str(ID)];
			end
			obj.iv.savedFileName = obj.correctPathOS([pwd, '\' , savefilename, '.mat']);
			save([savefilename, '.mat'], 'obj', '-v7.3');
		end
		function [folder, filename] = findFile(obj, sessionIdx, field, verbose)
			% 
			% 	The saved sObj file address is different for each computer. We instead need to find it based on the current folder.
			% 
			% 	sessionIdx can be a number or the sessionID
			% 
			% 	field is the fieldname of collated results where the filename is specified
			% 	
			if nargin < 3
				field = 'sObj';
			end
			if nargin < 4
				verbose = true;
			end
			if ~isnumeric(sessionIdx)
				warning('rbf')
				sessionIdxs = contains({obj.collatedResults.sessionID}, sessionIdx);
			end
			if verbose, warning('Be sure to move to the original host folder for the collation so that search works properly.'), end
			eval(['fileLoc = obj.correctPathOS(obj.collatedResults(sessionIdx).' field ');']);
			% 
			% 	Split off the fileLoc to the directories we can recognize
			% 
			fileLoc = strsplit(fileLoc, {'/','\'});
			folder = fileLoc{end-1};
			filename = fileLoc{end};
		end
		function sObj = loadFile(obj, folder, filename)
			dd = pwd;
			cd(folder)
			sObj = load(filename);
            fn = fieldnames(sObj);
            eval(['sObj = sObj.' fn{1} ';']);
			cd(dd)
		end


		%
		%
		%.   STEP VS RAMP........................
		%
		%
		function composite_prob_ramp_not_step(obj,excluded_idx)
			d = find(~ismember(1:numel(obj.collatedResults), excluded_idx));
			names = cellfun(@(x) x(1:3), {obj.collatedResults.sessionID}, 'uniformoutput', 0);
			names = names(d);
			ps = {obj.collatedResults.p};
            ps = cell2mat(ps(d)');
			[f,ax]=makeStandardFigure;
			prettyHxg(ax, ps, '', 'r', [],10)
			xlabel(ax,['p(ramp not step)'])
			ylabel(ax,'% of trials')
			nsesh=num2str(numel(d));
			nmice = num2str(numel(unique(names)));
			title(['nsesh=', nsesh, ' nmice=', nmice])
			retdir=pwd;
			disp('')
			if contains(obj.iv.suppressNsave.figuresHOST, '\\research.files.med.harvard.edu') && ~ispc
				aa = strsplit(obj.iv.suppressNsave.figuresHOST, '\\research.files.med.harvard.edu');
				aa = aa{2};
				obj.iv.suppressNsave.figuresHOST = ['/Volumes', aa];
            end
            obj.iv.suppressNsave.figuresHOST = correctPathOS(obj.iv.suppressNsave.figuresHOST);
			cd(obj.iv.suppressNsave.figuresHOST)
			printFigure(['comp_p_rns_nsesh', nsesh, '_nmice', nmice], f)
			cd(retdir)
		end

		function composite_signal_by_animal(obj, animalIdxs)
			% 
			%  animalIdxs = cell with arrays of indicies for each animal that will get included. Want to include all on equal footing...
			%   i.e., rather than by trial.
			% 
			nmice = numel(animalIdxs);
			nsesh = numel(cell2mat(animalIdxs));
			% 
			%  get the composite signal for each mouse
			% 
			results = cell(nmice,1);
			for imouse = 1:nmice
				results{imouse} = obj.composite_signal_aligned_to_step(animalIdxs{imouse});
			end
			% 
			%  now get the average across the results struct...
			% 
			gfit_LHS = results{1}.gfit_LHS;
			gfit_RHS = results{1}.gfit_RHS;
			gfit_count_l = results{1}.gfit_count_l;
			gfit_count_r = results{1}.gfit_count_r;
			tdt_LHS = results{1}.tdt_LHS;
			tdt_RHS = results{1}.tdt_RHS;
			tdt_count_l = results{1}.tdt_count_l;
			tdt_count_r = results{1}.tdt_count_r;
			emg_LHS = results{1}.emg_LHS;
			emg_RHS = results{1}.emg_RHS;
			emg_count_l = results{1}.emg_count_l;
			emg_count_r = results{1}.emg_count_r;
			ntdtmice = 0;
			nemgmice = 0;
			if sum(isnan(results{1}.tdt_RHS)) ~= numel(results{1}.tdt_RHS)
				ntdtmice = ntdtmice + 1;
			end
			if sum(isnan(results{1}.emg_RHS)) ~= numel(results{1}.emg_RHS)
				nemgmice = nemgmice + 1;
			end

			
			if nmice>1
				for imouse = 2:nmice
					% gfit
					[gfit_LHS, gfit_RHS, gfit_count_l, gfit_count_r] = obj.run_signal_aligned_to_step(gfit_LHS,...
					 gfit_RHS, gfit_count_l>0, gfit_count_r>0,...
					 results{imouse}.gfit_LHS, results{imouse}.gfit_RHS,...
					 results{imouse}.gfit_count_l>0, results{imouse}.gfit_count_r>0);

					if sum(isnan(results{imouse}.tdt_RHS)) ~= numel(results{imouse}.tdt_RHS)
						ntdtmice = ntdtmice + 1;
					end
					if sum(isnan(results{imouse}.emg_RHS)) ~= numel(results{imouse}.emg_RHS)
						nemgmice = nemgmice + 1;
					end
					% tdt
					[tdt_LHS, tdt_RHS, tdt_count_l, tdt_count_r] = obj.run_signal_aligned_to_step(...
					 tdt_LHS,...
					 tdt_RHS, tdt_count_l>0, tdt_count_r>0,...
					 results{imouse}.tdt_LHS, results{imouse}.tdt_RHS,...
					 results{imouse}.tdt_count_l>0, results{imouse}.tdt_count_r>0);% gfit


					% emg
					[emg_LHS, emg_RHS, emg_count_l, emg_count_r] = obj.run_signal_aligned_to_step(emg_LHS,...
					 emg_RHS, emg_count_l>0, emg_count_r>0,...
					 results{imouse}.emg_LHS, results{imouse}.emg_RHS,...
					 results{imouse}.emg_count_l>0, results{imouse}.emg_count_r>0);
				end
			end
			xl = linspace(-numel(gfit_LHS),-1,numel(gfit_LHS)) ./ 1000;
	        xr = linspace(0,numel(gfit_RHS)-1, numel(gfit_RHS)) ./ 1000;
			
			Title = ['gfit sm100, nsesh=', num2str(nsesh), ' nmice=', num2str(nmice)];
			[f, ax] = obj.aligned_to_step_plot_helper(Title);
			plot(ax(1),xl, gfit_LHS)
			plot(ax(1),xr, gfit_RHS)
			plot(ax(2),xl, gfit_count_l)
			plot(ax(2),xr, gfit_count_r)
			yyy=get(ax(1),'ylim');

            tdtchk = {obj.collatedResults.tdt_xl};
			ntdtsesh = sum(cellfun(@(x) ~isempty(x), tdtchk(cell2mat(animalIdxs))));
			% ntdtmice = num2str(numel(unique(names(find(~isempty([obj.collatedResults.tdt_xl]))))));
			
            xl = linspace(-numel(tdt_LHS),-1,numel(tdt_LHS)) ./ 1000;
	        xr = linspace(0,numel(tdt_RHS)-1, numel(tdt_RHS)) ./ 1000;
			Title = ['tdt sm100, ntdtsesh=', num2str(ntdtsesh), ' ntdtmice=', num2str(ntdtmice)];
			[f, ax] = obj.aligned_to_step_plot_helper(Title);
			plot(ax(1),xl, tdt_LHS)
			plot(ax(1),xr, tdt_RHS)
			plot(ax(2),xl, tdt_count_l)
			plot(ax(2),xr, tdt_count_r)
			ylim(ax(1),yyy);

            xl = linspace(-numel(emg_LHS),-1,numel(emg_LHS)) ./ 1000;
	        xr = linspace(0,numel(emg_RHS)-1, numel(emg_RHS)) ./ 1000;
			emgchk = {obj.collatedResults.emg_xl};
			nemgsesh = sum(cellfun(@(x) ~isempty(x), emgchk(cell2mat(animalIdxs))));
			% nemgmice = num2str(numel(unique(names(find(~isempty([obj.collatedResults.emg_xl]))))));
			Title = ['emg sm100, nemgsesh=', num2str(nemgsesh), ' nemgmice=', num2str(nemgmice)];
			[f, ax] = obj.aligned_to_step_plot_helper(Title);
			plot(ax(1),xl, emg_LHS)
			plot(ax(1),xr, emg_RHS)
			plot(ax(2),xl, emg_count_l)
			plot(ax(2),xr, emg_count_r)

			result = {};
			result.gfit_LHS = gfit_LHS;
			result.gfit_RHS = gfit_RHS;
			result.gfit_count_l = gfit_count_l;
			result.gfit_count_r = gfit_count_r;
			result.tdt_LHS = tdt_LHS;
			result.tdt_RHS = tdt_RHS;
			result.tdt_count_l = tdt_count_l;
			result.tdt_count_r = tdt_count_r;
			result.emg_LHS = emg_LHS;
			result.emg_RHS = emg_RHS;
			result.emg_count_l = emg_count_l;
			result.emg_count_r = emg_count_r;

		end

		function result = composite_signal_aligned_to_step(obj, included_idx, Debug)
			if nargin < 3
				Debug = false;
			end
			if nargin < 2
				included_idx = 1:numel(obj.collatedResults);
			end
			nsesh = numel(included_idx);
			names = cellfun(@(x) x(1:3), {obj.collatedResults.sessionID}, 'uniformoutput', 0);
			nmice = num2str(numel(unique(names(included_idx))));

			gfit_LHS = nan(1,1);
			gfit_RHS = nan(1,1);
			gfit_count_l = zeros(size(gfit_LHS));
			gfit_count_r = zeros(size(gfit_RHS));

			tdt_LHS = nan(1,1);
			tdt_RHS = nan(1,1);
			tdt_count_l = zeros(size(tdt_LHS));
			tdt_count_r = zeros(size(tdt_RHS));

			emg_LHS = nan(1,1);
			emg_RHS = nan(1,1);
			emg_count_l = zeros(size(emg_LHS));
			emg_count_r = zeros(size(emg_RHS));

			for s = included_idx
				gfit_sig_l = obj.collatedResults(s).gfit_LHS;
				gfit_sig_r = obj.collatedResults(s).gfit_RHS;  
				gfit_n_sig_lhs = obj.collatedResults(s).gfit_count_l;
				gfit_n_sig_rhs = obj.collatedResults(s).gfit_count_r;  
			    [gfit_LHS, gfit_RHS, gfit_count_l, gfit_count_r] = obj.run_signal_aligned_to_step(...
			    	gfit_LHS, ...
			    	gfit_RHS, ...
			    	gfit_count_l, ...
			    	gfit_count_r, ...
			    	gfit_sig_l, ...
			    	gfit_sig_r, ...
			    	gfit_n_sig_lhs, ...
			    	gfit_n_sig_rhs);


			    tdt_sig_l = obj.collatedResults(s).tdt_LHS;
				tdt_sig_r = obj.collatedResults(s).tdt_RHS;  
				tdt_n_sig_lhs = obj.collatedResults(s).tdt_count_l;
				tdt_n_sig_rhs = obj.collatedResults(s).tdt_count_r;  
			    [tdt_LHS, tdt_RHS, tdt_count_l, tdt_count_r] = obj.run_signal_aligned_to_step(...
			    	tdt_LHS, ...
			    	tdt_RHS, ...
			    	tdt_count_l, ...
			    	tdt_count_r, ...
			    	tdt_sig_l, ...
			    	tdt_sig_r, ...
			    	tdt_n_sig_lhs, ...
			    	tdt_n_sig_rhs);


			    emg_sig_l = obj.collatedResults(s).emg_LHS;
				emg_sig_r = obj.collatedResults(s).emg_RHS;  
				emg_n_sig_lhs = obj.collatedResults(s).emg_count_l;
				emg_n_sig_rhs = obj.collatedResults(s).emg_count_r;  
			    [emg_LHS, emg_RHS, emg_count_l, emg_count_r] = obj.run_signal_aligned_to_step(...
			    	emg_LHS, ...
			    	emg_RHS, ...
			    	emg_count_l, ...
			    	emg_count_r, ...
			    	emg_sig_l, ...
			    	emg_sig_r, ...
			    	emg_n_sig_lhs, ...
			    	emg_n_sig_rhs);

			    if Debug
			    	Title = ['session=', num2str(s)];
			    	xl = linspace(-numel(gfit_LHS),-1,numel(gfit_LHS)) ./ 1000;
	        		xr = linspace(0,numel(gfit_RHS)-1, numel(gfit_RHS)) ./ 1000;
					[f, ax] = obj.aligned_to_step_plot_helper(Title);
					plot(ax(1),xl, gfit_LHS)
					plot(ax(1),xr, gfit_RHS)
					plot(ax(2),xl, gfit_count_l)
					plot(ax(2),xr, gfit_count_r)
					yyy=get(ax(1),'ylim');

				end
			end
			xl = linspace(-numel(gfit_LHS),-1,numel(gfit_LHS)) ./ 1000;
	        xr = linspace(0,numel(gfit_RHS)-1, numel(gfit_RHS)) ./ 1000;
			
			Title = ['gfit sm100, nsesh=', num2str(nsesh), ' nmice=', nmice];
			[f, ax] = obj.aligned_to_step_plot_helper(Title);
			plot(ax(1),xl, gfit_LHS)
			plot(ax(1),xr, gfit_RHS)
			plot(ax(2),xl, gfit_count_l)
			plot(ax(2),xr, gfit_count_r)
			yyy=get(ax(1),'ylim');

            tdtchk = {obj.collatedResults.tdt_xl};
			ntdtsesh = sum(cellfun(@(x) ~isempty(x), tdtchk(included_idx)));
			ntdtmice = num2str(numel(unique(names(find(~isempty([obj.collatedResults.tdt_xl]))))));
			
            xl = linspace(-numel(tdt_LHS),-1,numel(tdt_LHS)) ./ 1000;
	        xr = linspace(0,numel(tdt_RHS)-1, numel(tdt_RHS)) ./ 1000;
			Title = ['tdt sm100, ntdtsesh=', num2str(ntdtsesh), ' ntdtmice=', ntdtmice];
			[f, ax] = obj.aligned_to_step_plot_helper(Title);
			plot(ax(1),xl, tdt_LHS)
			plot(ax(1),xr, tdt_RHS)
			plot(ax(2),xl, tdt_count_l)
			plot(ax(2),xr, tdt_count_r)
			ylim(ax(1),yyy);

            xl = linspace(-numel(emg_LHS),-1,numel(emg_LHS)) ./ 1000;
	        xr = linspace(0,numel(emg_RHS)-1, numel(emg_RHS)) ./ 1000;
			emgchk = {obj.collatedResults.emg_xl};
			nemgsesh = sum(cellfun(@(x) ~isempty(x), emgchk(included_idx)));
			nemgmice = num2str(numel(unique(names(find(~isempty([obj.collatedResults.emg_xl]))))));
			Title = ['emg sm100, nemgsesh=', num2str(nemgsesh), ' nemgmice=', nemgmice];
			[f, ax] = obj.aligned_to_step_plot_helper(Title);
			plot(ax(1),xl, emg_LHS)
			plot(ax(1),xr, emg_RHS)
			plot(ax(2),xl, emg_count_l)
			plot(ax(2),xr, emg_count_r)

			result = {};
			result.gfit_LHS = gfit_LHS;
			result.gfit_RHS = gfit_RHS;
			result.gfit_count_l = gfit_count_l;
			result.gfit_count_r = gfit_count_r;
			result.tdt_LHS = tdt_LHS;
			result.tdt_RHS = tdt_RHS;
			result.tdt_count_l = tdt_count_l;
			result.tdt_count_r = tdt_count_r;
			result.emg_LHS = emg_LHS;
			result.emg_RHS = emg_RHS;
			result.emg_count_l = emg_count_l;
			result.emg_count_r = emg_count_r;

		end
		function [f, ax] = aligned_to_step_plot_helper(obj, Title)
			[f,ax]=makeStandardFigure(2, [2,1]);
			hold(ax(1), 'on')
			hold(ax(2), 'on')
            xlim(ax(1),[-5,5])
			ylabel(ax(1),'dF/F')
			xlabel(ax(2),'time from step position (s)')
			ylabel(ax(2),'ntrials')
			linkaxes(ax, 'x')
			title(ax(1), Title)
		end
		function [LHS, RHS, count_l, count_r] = run_signal_aligned_to_step(obj, LHS, RHS, count_l, count_r, sig_l, sig_r, n_sig_lhs, n_sig_rhs)
	        % handle left side
	        if numel(sig_l) ~= numel(n_sig_lhs) || numel(sig_r) ~= numel(n_sig_rhs)
        		error()
    		end

	        if numel(sig_l) < numel(LHS) % if we have longer left side than LHS
	            nanpad = nan(1,numel(LHS)-numel(n_sig_lhs));
	            zeropad = zeros(1,numel(LHS)-numel(n_sig_lhs));
	            sig_l = [nanpad,sig_l];
	            n_sig_lhs = [zeropad,n_sig_lhs];
	        elseif numel(sig_l) > numel(LHS)
	            nanpad = nan(1,numel(n_sig_lhs)-numel(LHS));
	            zeropad = zeros(1,numel(n_sig_lhs)-numel(LHS));
	            sig_l = sig_l;
	            LHS = [nanpad, LHS];
	            count_l = [zeropad, count_l];
	        else
	            sig_l = sig_l;
	        end
	        % handle right side
	        if numel(sig_r) < numel(RHS) % if we have longer left side than LHS
	            nanpad = nan(1,numel(RHS)-numel(n_sig_rhs));
	            zeropad = nan(1,numel(RHS)-numel(n_sig_rhs));
	            sig_r = [sig_r, nanpad];
	            n_sig_rhs = [n_sig_rhs, zeropad];
	        elseif numel(sig_r) > numel(RHS)
	            nanpad = nan(1,numel(n_sig_rhs)-numel(RHS));
	            zeropad = zeros(1,numel(n_sig_rhs)-numel(RHS));
	            sig_r = sig_r;
	            RHS = [RHS, nanpad];
	            count_r = [count_r,zeropad];
	        else
	            sig_r = sig_r;
	        end
	        
	        % Now do the running average
			% 	   The trouble is each of these is a running average, so 
			%.      if we do the running ave as usual, we will over crush the original...
			% 	So we just want to do a weighted mean...
			% 	        
	        count_l_total = nansum([count_l; n_sig_lhs]);
	        count_r_total = nansum([count_r; n_sig_rhs]);
			updateidx_left = find(~isnan(sig_l));
        	updateidx_right = find(~isnan(sig_r));
	        % LHS(updateidx_left) = nansum([LHS(updateidx_left) .* ((count_l(updateidx_left)-1)./count_l(updateidx_left)); sig_l(updateidx_left) .* (n_sig_lhs(updateidx_left) -1) ./count_l(updateidx_left)]);
	        % RHS(updateidx_right) = nansum([RHS(updateidx_right) .* ((count_r(updateidx_right)-1)./count_r(updateidx_right)); sig_r(updateidx_right) .* (n_sig_rhs(updateidx_right)-1) ./count_r(updateidx_right)]);  
	        LHS(updateidx_left) = nansum([LHS(updateidx_left) .* count_l(updateidx_left); sig_l(updateidx_left) .* n_sig_lhs(updateidx_left)])./count_l_total(updateidx_left);
	        RHS(updateidx_right) = nansum([RHS(updateidx_right) .* count_r(updateidx_right); sig_r(updateidx_right) .* n_sig_rhs(updateidx_right)])./count_r_total(updateidx_right);


	        count_l = count_l_total;
			count_r = count_r_total;
		end
		function import_sObj_for_stepvramp(obj, sessionIdx)
			seshCode = obj.collatedResults(sessionIdx).sessionID;
			retdir = pwd();
			cd(obj.iv.hostFolder)
			d = dir;
			d = d(3:end);
			idx = find(contains({d.name},seshCode));
			cd(d(idx).name);
			d = dir('*.mat');
			idx = find(contains({d.name},'Obj'));
			d = d(idx);
			if numel(d)>1
                dates = datetime({d.date});
                [s,ix] = sort(dates);
				idx = ix(end);
				disp('******found multiple sObjs: ')
				disp(cellstr({d.name}))
				disp(cellstr({d.date}))
				disp(['using: ' d(idx).name])
				obj.analysis.obj = load(d(idx).name);
			else
				obj.analysis.obj = load(d(1).name);
            end
            try
                obj.analysis.obj = obj.analysis.obj.obj;
            catch ex
                obj.analysis.obj = obj.analysis.obj.sObj;
            end
			obj.analysis.seshID = sessionIdx;
			cd(retdir)
		end


		function composite_step_pcinterval(obj, seshIdx)
			if nargin < 2
				seshIdx = 1:numel(obj.collatedResults);
			end
			nsesh = numel(seshIdx);
			names = cellfun(@(x) x(1:3), {obj.collatedResults.sessionID}, 'uniformoutput', 0);
			nmice = num2str(numel(unique(names(seshIdx))));

			obj.analysis.step_pc_int={};
			obj.analysis.step_pc_int.seshIdx = seshIdx;
			obj.analysis.step_pc_int.nsesh = nsesh;
			obj.analysis.step_pc_int.nmice = nmice;
			obj.analysis.step_pc_int.composite_pc_interval = cell2mat({obj.collatedResults.pc_interval_step}');

        end
        function plot_composite_step_pcinterval(obj)
        	pc_intervals = obj.analysis.step_pc_int.composite_pc_interval;
        	pc_intervals = pc_intervals(~isnan(pc_intervals));
        	[f,ax] = makeStandardFigure();
        	prettyHxg(ax, pc_intervals, '% interval', 'b', [], 20);
	        title(ax,['% interval elapsed at step, all trials, nmice=', num2str(obj.analysis.step_pc_int.nmice), ' nsesh=', num2str(obj.analysis.step_pc_int.nsesh)])
	        xlabel(ax,'% of interval elapsed at step')
	        xlim(ax, [0,1])
        	xticks(ax, 0:0.1:1)

    	end
    	function get_timeslice_variance(obj, seshID, timeslice_ms, num_pcts, verbose)
    		if nargin < 2 || isempty(seshID) || seshID == obj.analysis.seshID
    			sObj = obj.analysis.obj;
			else 
				obj.import_sObj_for_stepvramp(seshID);
				sObj = obj.analysis.obj;
			end
			if nargin < 3 || isempty(timeslice_ms)
				timeslice_ms = 100; % this is the window over which we will look at variance
			end
			if nargin < 4 || isempty(num_pcts)
				num_pcts = 10;
			end
			if nargin < 5
				verbose = true;
			end
    		signal = sObj.GLM.gfit;
    		nbins = 17;
			time_increment_per_bin_ms = 17000/nbins;

			sObj.getBinnedTimeseries(signal, 'singletrial',[], 30000,[],[],false);
			[s,idx] = sort(cell2mat(sObj.ts.BinParams.trials_in_each_bin));
			smoothed = cellfun(@(x) sObj.smooth(x, 100), sObj.ts.BinnedData.CTA, 'uniformoutput', 0);
			sorted_binned = cell(sObj.iv.num_trials,1);
			sorted_binned([sObj.ts.BinParams.trials_in_each_bin{idx}]) = smoothed(idx);

			binned_variances = cell(17,1);
			edges = linspace(0,17,18);
			n_trials_by_bin = nan(17,1);
			for ii = 1:nbins
			    n_slices_this_bin = round(time_increment_per_bin_ms*(ii-1)/timeslice_ms);
			    binned_variances{ii} = nan(1,n_slices_this_bin);
			    trials_in_this_bin = find(sObj.GLM.flick_s_wrtc >=edges(ii) & sObj.GLM.flick_s_wrtc < edges(ii+1));
			    n_trials_by_bin(ii) = numel(trials_in_this_bin);
			    for jj = 1:n_slices_this_bin
			        this_slice = cell2mat(cellfun(@(x) x(1+(jj-1)*timeslice_ms:jj*timeslice_ms),sorted_binned(trials_in_this_bin), 'uniformoutput', 0));
			        binned_variances{ii}(jj) = var(nanmean(this_slice,2));%,'omitnan');
			    end
			end

			%% now look at timeslices by % interval elapsed
			timeslice_pc = num_pcts;

			binned_variances = cell(17,1);
			edges = linspace(0,17,18);
			n_trials_by_bin = nan(17,1);
			for ii = 1:nbins
			    n_slices_this_bin = timeslice_pc;
			    timeslice_ms = edges(ii)*1000/timeslice_pc;
			    binned_variances{ii} = nan(1,n_slices_this_bin);
			    trials_in_this_bin = find(sObj.GLM.flick_s_wrtc >=edges(ii) & sObj.GLM.flick_s_wrtc < edges(ii+1));
			    n_trials_by_bin(ii) = numel(trials_in_this_bin);
			    for jj = 1:n_slices_this_bin
			        this_slice = cell2mat(cellfun(@(x) x(1+(jj-1)*timeslice_ms:jj*timeslice_ms),sorted_binned(trials_in_this_bin), 'uniformoutput', 0));
			        binned_variances{ii}(jj) = var(nanmean(this_slice,2),'omitnan');
			    end
			end

			mean_var = nanmean(cell2mat(binned_variances(1:7)), 1);

			

			% Let's simulate the steps...
			st = obj.collatedResults(seshID).step_time;
			tNo = obj.collatedResults(seshID).tNo;
			l = obj.collatedResults(seshID).left_segment;
			r = obj.collatedResults(seshID).right_segment;
			cue_cut_s = obj.collatedResults(seshID).trim_cue_s;
			lick_cut_s = abs(obj.collatedResults(seshID).trim_lick_s);
			cl_pos = find(sObj.ts.Plot.CTA.xticks.s>=cue_cut_s, 1,'first') .* ones(sObj.iv.num_trials,1);
			sObj.getflickswrtc;
			lp = sObj.GLM.flick_pos_wrtc - lick_cut_s*1000;
			zero_p = find(sObj.ts.Plot.CTA.xticks.s>=0, 1,'first');

			relevant_window = cell(sObj.iv.num_trials,1);
			relevant_window_red = cell(sObj.iv.num_trials,1);
			for ii = 1:sObj.iv.num_trials
			    if ~isnan(lp(ii))
			        relevant_window{ii} = sorted_binned{ii}(cl_pos(ii):lp(ii)+zero_p);
			    end
			end

			step_positions = cellfun(@(x) x*10 + cue_cut_s*1000, st, 'uniformoutput',false);

			sp_julia_frame = nan(sObj.iv.num_trials,1);
			ixx = find(cellfun(@(x) ~isempty(x), st));
			lefts = nan(sObj.iv.num_trials,1);
			rights = nan(sObj.iv.num_trials,1);
			sorted_by_trial_step_fits = cell(sObj.iv.num_trials,1);

			for ii = 1:numel(ixx)
			    itrial = ixx(ii);
			    if ~isempty(st{itrial})
			        % get the mode
			        if numel(unique(st{itrial}))==numel(st{itrial})
			            xxx = sort(st{itrial});
			            sp_julia_frame(tNo(itrial)) = 10*xxx(round(numel(xxx)/2));
			        elseif numel(mode(st{itrial})) > 1
			            xxx = mode(st{itrial});
			            sp_julia_frame(tNo(itrial)) = 10*xxx(randperm(numel(xxx),1));
			        else
			            sp_julia_frame(tNo(itrial)) = 10*mode(st{itrial});
			        end		        
			        
			        % get the mode LEFT SEGMENT
			        if numel(unique(l{itrial}))==numel(l{itrial})
			            xxx = sort(l{itrial});
			            lefts(tNo(itrial)) = xxx(round(numel(xxx)/2));
			        elseif numel(mode(l{itrial})) > 1
			            xxx = mode(l{itrial});
			            lefts(tNo(itrial)) = xxx(randperm(numel(xxx),1));
			        else
			            lefts(tNo(itrial)) = mode(l{itrial});
			        end
			        % get the mode RIGHT SEGMENT
			        if numel(unique(r{itrial}))==numel(r{itrial})
			            xxx = sort(r{itrial});
			            rights(tNo(itrial)) = xxx(round(numel(xxx)/2));
			        elseif numel(mode(r{itrial})) > 1
			            xxx = mode(r{itrial});
			            rights(tNo(itrial)) = xxx(randperm(numel(xxx),1));
			        else
			            rights(tNo(itrial)) = mode(r{itrial});
			        end
			        
			        % CREATE THE STEP FIT...
			        sorted_by_trial_step_fits{tNo(itrial)} = [lefts(tNo(itrial)).*ones(1,0.5*1000+sp_julia_frame(tNo(itrial))), rights(tNo(itrial)).*ones(1,sObj.GLM.flick_pos_wrtc(tNo(itrial))-sp_julia_frame(tNo(itrial))-0.5*1000)];%-lick_cut_s*1000
			    end
			end
			sp_matlab_frame = sp_julia_frame+cl_pos;



			binned_variances_sim = cell(17,1);
			n_trials_by_bin_sim = nan(17,1);
			for ii = 1:nbins
			    n_slices_this_bin_sim = timeslice_pc;
			    timeslice_ms = floor(edges(ii)*sObj.Plot.samples_per_ms*1000/timeslice_pc);
			    binned_variances_sim{ii} = nan(1,n_slices_this_bin_sim);
			    trials_in_this_bin_sim = find(sObj.GLM.flick_s_wrtc >=edges(ii) & sObj.GLM.flick_s_wrtc < edges(ii+1));
			    n_trials_by_bin_sim(ii) = numel(trials_in_this_bin_sim);
			    for jj = 1:n_slices_this_bin_sim
                    
			        this_slice = cell2mat(cellfun(@(x) x(1+(jj-1)*timeslice_ms:jj*timeslice_ms),sorted_by_trial_step_fits(trials_in_this_bin_sim), 'uniformoutput', 0));
			        binned_variances_sim{ii}(jj) = var(nanmean(this_slice,2),'omitnan');
			    end
			end

			mean_var_sim = nanmean(cell2mat(binned_variances_sim(1:7)), 1);

			

			if ~isfield(obj.analysis, 'timeslice_pc')
				obj.analysis.timeslice_pc.num_pcts = num_pcts;
				obj.analysis.timeslice_pc.timeslice_ms = timeslice_ms;
			end
			if obj.analysis.timeslice_pc.num_pcts ~= num_pcts
				warning('This is not the same set up as the other stored data. Check this line and erase the timeslice_pc field if you want to overwrite. For now, returning the result in analysis.flush if you want it.')
				obj.analysis.flush.seshID = seshID;
				obj.analysis.flush.num_pcts = num_pcts;
				obj.analysis.flush.timeslice_ms = timeslice_ms;
				obj.analysis.flush.binned_variances = binned_variances;
				obj.analysis.flush.mean_var = mean_var;
				obj.analysis.flush.n_trials_by_bin = n_trials_by_bin;

				obj.analysis.flush.binned_variances_sim = binned_variances_sim;
				obj.analysis.flush.mean_var_sim = mean_var_sim;
				obj.analysis.flush.n_trials_by_bin_sim = n_trials_by_bin_sim;
			else
				obj.analysis.timeslice_pc.seshID = seshID;
				obj.analysis.timeslice_pc.edges = edges;
				obj.analysis.timeslice_pc.data(seshID).binned_variances = binned_variances;
				obj.analysis.timeslice_pc.data(seshID).mean_var = mean_var;
				obj.analysis.timeslice_pc.data(seshID).n_trials_by_bin = n_trials_by_bin;
				
				obj.analysis.timeslice_pc.data(seshID).binned_variances_sim = binned_variances_sim;
				obj.analysis.timeslice_pc.data(seshID).mean_var_sim = mean_var_sim;
				obj.analysis.timeslice_pc.data(seshID).n_trials_by_bin_sim = n_trials_by_bin_sim;
				disp('Data stored in obj.analysis.timeslice_pc.data')
			end


			if verbose
				[f,ax] = obj.plot_variance_and_sim_timeslice(seshID);
				set(f, 'userdata', ['obj = CLASS_STATcollate_photometry_roadmapv1_4(''stepvramp_julia'', ' obj.iv.n '), using obj.get_timeslice_variance(' num2str(seshID) ',' num2str(timeslice_ms) ',' num2str(num_pcts) ',' num2str(verbose) ')'])
				sObj.suppressNsaveFigure(obj.iv.suppressNsave.figuresHOST, 'var_timeslice_steps', f);
			end
		end
		function [f,ax] = plot_variance_and_sim_timeslice(obj, seshID, normalize)
			%
			%. Henceforth, normalize can be 'true', 'false', 'align50'
			%
			if nargin < 3
				normalize = 'align50';	
			end
			if ~isfield(obj.analysis.step_pc_int, 'pc50')
				obj.analysis.step_pc_int.pc50 = nan(numel(obj.collatedResults),1);
			end
			nsesh = numel(seshID);
			names = cellfun(@(x) x(1:3), {obj.collatedResults.sessionID}, 'uniformoutput', 0);
			nmice = num2str(numel(unique(names(seshID))));	
			edges = obj.analysis.timeslice_pc.edges;

			binned_variances = cell(6,1);
			n_trials_by_bin = zeros(6,1);
			mean_var = nan(nsesh, obj.analysis.timeslice_pc.num_pcts);
			binned_variances_sim = cell(6,1);
			n_trials_by_bin_sim = zeros(6,1);
			mean_var_sim = nan(nsesh, obj.analysis.timeslice_pc.num_pcts);

			% get all sessions and CI
			for ii = 1:nsesh
				ntrials_this_sesh = obj.analysis.timeslice_pc.data(seshID(ii)).n_trials_by_bin(2:7);
				for ibin = 2:7
					if strcmpi(normalize, 'false') 
						wt = 1;
					else
						if ntrials_this_sesh(ibin-1) == 1
							wt = nan;
						else
							wt = ntrials_this_sesh(ibin-1)./sum(ntrials_this_sesh);
						end
					end
					binned_variances{ibin-1, 1}(ii,:) = obj.analysis.timeslice_pc.data(seshID(ii)).binned_variances{ibin} .* wt;
					binned_variances_sim{ibin-1, 1}(ii,:) = obj.analysis.timeslice_pc.data(seshID(ii)).binned_variances_sim{ibin} .* wt;
				end
				n_trials_by_bin = n_trials_by_bin + obj.analysis.timeslice_pc.data(seshID(ii)).n_trials_by_bin(2:7);
				n_trials_by_bin_sim = n_trials_by_bin_sim + obj.analysis.timeslice_pc.data(seshID(ii)).n_trials_by_bin_sim(2:7);
				
				% mean_var(ii,:) = obj.analysis.timeslice_pc.data(seshID(ii)).mean_var;
				% mean_var_sim(ii,:) = obj.analysis.timeslice_pc.data(seshID(ii)).mean_var_sim;
				% we want a weighted ave
				all_wtd_vars_this_sesh = cell2mat(cellfun(@(x) x(ii,:), binned_variances, 'uniformoutput',0));
				all_wtd_vars_this_sesh_sim = cell2mat(cellfun(@(x) x(ii,:), binned_variances_sim, 'uniformoutput',0));
				% if strcmpi(normalize, 'true')
                    mean_var(ii,:) = nanmean(all_wtd_vars_this_sesh,1);
                    mean_var_sim(ii,:) = nanmean(all_wtd_vars_this_sesh_sim,1);
                % else
                %     mean_var(ii,:) = nanmean(all_wtd_vars_this_sesh,1);
                %     mean_var_sim(ii,:) = nanmean(all_wtd_vars_this_sesh_sim,1);
                % end
			end			

			mean_binned_variances = cellfun(@(x) nanmean(x,1), binned_variances, 'uniformoutput',0);
			mean_mean_var = nanmean(mean_var,1);
			mean_binned_variances_sim = cellfun(@(x) nanmean(x,1), binned_variances_sim, 'uniformoutput',0);
			mean_mean_var_sim = nanmean(mean_var_sim,1);

			[CIl_mean_var, CIu_mean_var] = obj.bootCI(mean_var, 1, 1000, 0.05);
			[CIl_mean_var_sim, CIu_mean_var_sim] = obj.bootCI(mean_var_sim, 1, 1000, 0.05);


			CIl_binned_variances = cell(6,1);
			CIu_binned_variances = cell(6,1);
			CIl_binned_variances_sim = cell(6,1);
			CIu_binned_variances_sim = cell(6,1);
			for ibin = 1:6
				[CIl_binned_variances{ibin}, CIu_binned_variances{ibin}] = obj.bootCI(binned_variances{ibin}, 1, 1000, 0.05);
				[CIl_binned_variances_sim{ibin}, CIu_binned_variances_sim{ibin}] = obj.bootCI(binned_variances_sim{ibin}, 1, 1000, 0.05);
			end



			[f,ax]=makeStandardFigure(2,[1,2]);
			C = linspecer(nsesh);
			hold(ax(1), 'on');
			hold(ax(2), 'on');
			if strcmpi(normalize, 'align50mean') || strcmpi(normalize, 'align50-0')
				lefts = nan(nsesh, 11);
				rights = nan(nsesh, 10);
			end
			for ii = 1:nsesh
				if strcmpi(normalize, 'align50') || strcmpi(normalize, 'align50mean') || strcmpi(normalize, 'align50-0')
					% we DON'T want to norm 0,1 here this time.
					% we need to grab the timebin with the 50% of cdf
					% this info is stored here: obj.collatedResults.pc_interval_step
					% Then let's put it in the analysis field so we don't have to keep calculating...
					if isnan(obj.analysis.step_pc_int.pc50(seshID(ii)))
						[fff,xxx] = ecdf(obj.collatedResults(seshID(ii)).pc_interval_step);
						pc50_idx = find(fff >= 0.5, 1, 'first');
						pc50_x = xxx(pc50_idx);
						obj.analysis.step_pc_int.pc50(seshID(ii)) = pc50_x;
					end
					pc50_x = obj.analysis.step_pc_int.pc50(seshID(ii));
					xs = linspace(10-5, 100-5,numel(mean_var(ii,:)));
					xbin = find((xs-5)./100 <= pc50_x, 1, 'last');
					if strcmpi(normalize, 'align50mean')
						yplot_left = mean_var(ii,1:xbin) - nanmean(mean_var(ii,:));
						yplot_right = mean_var(ii,xbin+1:end) - nanmean(mean_var(ii,:));
						% yplot_sim = mean_var_sim(ii,:) - nanmean(mean_var_sim(ii,:));
						xs_left = linspace(-10*(numel(yplot_left)-1),0, numel(yplot_left));
						xs_right = linspace(10,10*numel(yplot_right), numel(yplot_right));
						plot(ax(1),[xs_left,xs_right],[yplot_left, yplot_right],'-', 'color', C(ii,:), 'linewidth', 1,'displayname', obj.collatedResults(seshID(ii)).sessionID)
						% plot(ax(1),xs_right,yplot_right,'-', 'color', C(ii,:), 'linewidth', 1,'displayname', obj.collatedResults(seshID(ii)).sessionID)
						lefts(ii, end-numel(yplot_left)+1:end) = yplot_left;
						rights(ii, 1:numel(yplot_right)) = yplot_right;
					elseif strcmpi(normalize, 'align50-0')
						yyy = mean_var(ii,xbin);
						yplot_left = mean_var(ii,1:xbin) - yyy;
						yplot_right = mean_var(ii,xbin+1:end) - yyy;
						% yplot_sim = mean_var_sim(ii,:) - nanmean(mean_var_sim(ii,:));
						xs_left = linspace(-10*(numel(yplot_left)-1),0, numel(yplot_left));
						xs_right = linspace(10,10*numel(yplot_right), numel(yplot_right));
						plot(ax(1),[xs_left,xs_right],[yplot_left, yplot_right],'-', 'color', C(ii,:), 'linewidth', 1,'displayname', obj.collatedResults(seshID(ii)).sessionID)
						% plot(ax(1),xs_right,yplot_right,'-', 'color', C(ii,:), 'linewidth', 1,'displayname', obj.collatedResults(seshID(ii)).sessionID)
						lefts(ii, end-numel(yplot_left)+1:end) = yplot_left;
						rights(ii, 1:numel(yplot_right)) = yplot_right;
					else
						yyy = mean_var(ii,xbin);
						yplot = mean_var(ii,:) - yyy;
						yyy_sim = mean_var_sim(ii,xbin);
						yplot_sim = mean_var_sim(ii,:) - yyy_sim;
						plot(ax(1),xs,yplot,'-', 'color', C(ii,:), 'linewidth', 1,'displayname', obj.collatedResults(seshID(ii)).sessionID)
						plot(ax(2),xs,yplot_sim, '-', 'color', C(ii,:), 'linewidth', 1,'displayname', obj.collatedResults(seshID(ii)).sessionID)
					end
					
					

				else
					plot(ax(1),linspace(10-5, 100-5,numel(mean_var(ii,:))),normalize_0_1(mean_var(ii,:)),'-', 'color', C(ii,:), 'linewidth', 1,'displayname', obj.collatedResults(seshID(ii)).sessionID)
					plot(ax(2),linspace(10-5, 100-5,numel(mean_var(ii,:))),normalize_0_1(mean_var_sim(ii,:)), '-', 'color', C(ii,:), 'linewidth', 1,'displayname', obj.collatedResults(seshID(ii)).sessionID)
				end
			end
			
			if strcmpi(normalize, 'align50') || strcmpi(normalize, 'align50mean') || strcmpi(normalize, 'align50-0')
				% now we need to put the zero point at the 50% cdf of composite.
				if ~isfield(obj.analysis.step_pc_int, 'composite_pc50')
					[fff,xxx] = ecdf(obj.analysis.step_pc_int.composite_pc_interval);
					pc50_idx = find(fff >= 0.5, 1, 'first');
					pc50_x = xxx(pc50_idx);
					obj.analysis.step_pc_int.composite_pc50 = pc50_x;
				end
				
				if strcmpi(normalize, 'align50mean')
					mean_mean_var = [nanmean(lefts, 1), nanmean(rights,1)];
					yplot = mean_mean_var - nanmean(mean_mean_var);
					xs = linspace(-100,100,21);
					% yplot_sim = mean_mean_var_sim(ii,:) - nanmean(mean_mean_var_sim(ii,:));
					plot(ax(1),xs,yplot, 'k.-',  'markersize', 50, 'linewidth', 4,'displayname', ['Mean'])
					plot(ax(1),[0,0],[nanmin(nanmin(rights)), nanmax(nanmax(lefts))], 'k-',  'linewidth', 1,'displayname', ['Mean'])
					% plot(ax(2),xs,yplot_sim, 'k.-',  'markersize', 50, 'linewidth', 4,'displayname', ['Mean'])
				elseif strcmpi(normalize, 'align50-0')
					mean_mean_var = [nanmean(lefts, 1), nanmean(rights,1)];
					Zero = nanmean(lefts, 1);
					yplot = mean_mean_var - Zero(end);
					xs = linspace(-100,100,21);
					% yplot_sim = mean_mean_var_sim(ii,:) - nanmean(mean_mean_var_sim(ii,:));
					plot(ax(1),xs,yplot, 'k.-',  'markersize', 50, 'linewidth', 4,'displayname', ['Mean'])
					plot(ax(1),[0,0],[nanmin(nanmin(rights)), nanmax(nanmax(lefts))], 'k-',  'linewidth', 1,'displayname', ['Mean'])
					% plot(ax(2),xs,yplot_sim, 'k.-',  'markersize', 50, 'linewidth', 4,'displayname', ['Mean'])
				else
					pc50_x = obj.analysis.step_pc_int.composite_pc50;
					xs = linspace(10-5, 100-5,numel(mean_mean_var));
					xbin = find((xs-5)./100 <= pc50_x, 1, 'last');
					yyy = mean_mean_var(xbin);
					yplot = mean_mean_var(:) - yyy;
					yyy_sim = mean_mean_var_sim(xbin);
					yplot_sim = mean_mean_var_sim(:) - yyy_sim;
					plot(ax(1),xs,yplot, 'k.-',  'markersize', 50, 'linewidth', 4,'displayname', ['Mean'])
					plot(ax(2),xs,yplot_sim, 'k.-',  'markersize', 50, 'linewidth', 4,'displayname', ['Mean'])
				end
				
			else				
				plot(ax(1),linspace(10-5, 100-5,numel(mean_mean_var)),normalize_0_1(mean_mean_var), 'k.-',  'markersize', 50, 'linewidth', 4,'displayname', ['Mean'])
				plot(ax(2),linspace(10-5, 100-5,numel(mean_mean_var)),normalize_0_1(mean_mean_var_sim), 'k.-',  'markersize', 50, 'linewidth', 4,'displayname', ['Mean'])
			end


			
			xlabel(ax(1),'% of interval elapsed')
			xlabel(ax(2),'% of interval elapsed')
			ylabel(ax(1),'variance across trials in bin')
			title(ax(1),['Variance by ' num2str(100/obj.analysis.timeslice_pc.num_pcts) '% timeslice: real data'])
			title(ax(2),['step-fit, nmice=' num2str(nmice) ' nsesh=', num2str(nsesh)])
			legend(ax(1),'show', 'interpreter', 'none')
			legend(ax(2),'show', 'interpreter', 'none')
			set(f, 'userdata', ['[f,ax] = obj.plot_variance_and_sim_timeslice(seshID=' num2str(seshID) ', normalize=' normalize ')'])





			if ~strcmpi(normalize, 'align50mean') && ~strcmpi(normalize, 'align50-0')
				[f2,ax]=makeStandardFigure(2,[1,2]);
				C = linspecer(10);%nbins);
				% C = flipud(C);
				hold(ax(1), 'on');
				hold(ax(2), 'on');
				for binNo = 1:6%nbins
				    % plot(ax(1),linspace(10-5, 100-5,numel(binned_variances{binNo})),binned_variances{binNo}, '.-', 'color', C(binNo, :), 'markersize', 30, 'displayname', ['Trials: ', num2str(edges(binNo)), '-', num2str(edges(binNo+1)), 's, nTrials=', num2str(n_trials_by_bin(binNo))])
				    % plot(ax(2),linspace(10-5, 100-5,numel(binned_variances_sim{binNo})),binned_variances_sim{binNo}, '.-', 'color', C(binNo, :), 'markersize', 30, 'displayname', ['Trials: ', num2str(edges(binNo)), '-', num2str(edges(binNo+1)), 's, nTrials=', num2str(n_trials_by_bin_sim(binNo))])
				    plot(ax(1),linspace(10-5, 100-5,numel(mean_binned_variances{binNo})),mean_binned_variances{binNo}, '.-', 'color', C(binNo, :), 'markersize', 30, 'displayname', ['Trials: ', num2str(edges(binNo+1)), '-', num2str(edges(binNo+2)), 's, nTrials=', num2str(n_trials_by_bin(binNo))])
				    h= plot(ax(1),linspace(10-5, 100-5,numel(CIl_binned_variances{binNo})),CIl_binned_variances{binNo}, '-', 'color', C(binNo, :), 'displayname', ['CIl']);
				    h.Annotation.LegendInformation.IconDisplayStyle = 'off';
				    h = plot(ax(1),linspace(10-5, 100-5,numel(CIu_binned_variances{binNo})),CIu_binned_variances{binNo}, '-', 'color', C(binNo, :), 'displayname', ['CIu']);
				    h.Annotation.LegendInformation.IconDisplayStyle = 'off';

				    plot(ax(2),linspace(10-5, 100-5,numel(mean_binned_variances_sim{binNo})),mean_binned_variances_sim{binNo}, '.-', 'color', C(binNo, :), 'markersize', 30, 'displayname', ['Trials: ', num2str(edges(binNo+1)), '-', num2str(edges(binNo+2)), 's, nTrials=', num2str(n_trials_by_bin_sim(binNo))])
				    h = plot(ax(2),linspace(10-5, 100-5,numel(CIl_binned_variances_sim{binNo})),CIl_binned_variances_sim{binNo}, '-', 'color', C(binNo, :), 'displayname', ['CIl']);
				    h.Annotation.LegendInformation.IconDisplayStyle = 'off';
				    h = plot(ax(2),linspace(10-5, 100-5,numel(CIu_binned_variances_sim{binNo})),CIu_binned_variances_sim{binNo}, '-', 'color', C(binNo, :), 'displayname', ['CIu']);
				    h.Annotation.LegendInformation.IconDisplayStyle = 'off';
				end
				% plot(ax(1),linspace(10-5, 100-5,numel(binned_variances{binNo})),mean_var, 'k.-',  'markersize', 50, 'linewidth', 4,'displayname', ['Mean'])
				% plot(ax(2),linspace(10-5, 100-5,numel(binned_variances_sim{binNo})),mean_var_sim, 'k.-',  'markersize', 50, 'linewidth', 4,'displayname', ['Mean'])
				plot(ax(1),linspace(10-5, 100-5,numel(mean_binned_variances{binNo})),mean_mean_var, 'k.-',  'markersize', 50, 'linewidth', 4,'displayname', ['Mean'])
				h = plot(ax(1),linspace(10-5, 100-5,numel(mean_binned_variances{binNo})),CIl_mean_var, 'k-', 'linewidth', 1,'displayname', ['CIl']);
				h.Annotation.LegendInformation.IconDisplayStyle = 'off';
				h = plot(ax(1),linspace(10-5, 100-5,numel(mean_binned_variances{binNo})),CIu_mean_var, 'k-', 'linewidth', 1,'displayname', ['CIu']);
				h.Annotation.LegendInformation.IconDisplayStyle = 'off';

				plot(ax(2),linspace(10-5, 100-5,numel(mean_binned_variances_sim{binNo})),mean_mean_var_sim, 'k.-',  'markersize', 50, 'linewidth', 4,'displayname', ['Mean'])
				h = plot(ax(2),linspace(10-5, 100-5,numel(mean_binned_variances_sim{binNo})),CIl_mean_var_sim, 'k-', 'linewidth', 1,'displayname', ['CIl']);
				h.Annotation.LegendInformation.IconDisplayStyle = 'off';
				h = plot(ax(2),linspace(10-5, 100-5,numel(mean_binned_variances_sim{binNo})),CIu_mean_var_sim, 'k-', 'linewidth', 1,'displayname', ['CIu']);
				h.Annotation.LegendInformation.IconDisplayStyle = 'off';

				
				xlabel(ax(1),'% of interval elapsed')
				xlabel(ax(2),'% of interval elapsed')
				ylabel(ax(1),'variance across trials in bin')
				title(ax(1),['Variance by ' num2str(100/obj.analysis.timeslice_pc.num_pcts) '% timeslice: real data'])
				title(ax(2),['step-fit, nmice=' num2str(nmice) ' nsesh=', num2str(nsesh)])
				legend(ax(1),'show')
				legend(ax(2),'show')
				set(f2, 'userdata', ['[f,ax] = obj.plot_variance_and_sim_timeslice(seshID=' num2str(seshID) ', normalize=' normalize ')'])
			end

			
		end
		function [CIl, CIu] = bootCI(obj, mat, dim, nboot, Alpha)
			% 
			% 	Will bootstrap to get the full range of IRTs (to get 95% CI) and also the peak
			% 
			closeWindow = 7;
			rxnWin = 0.7;
			if nargin < 3, dim = 1;, end
			if nargin < 4, nboot = 1000;, end
			if nargin < 5, Alpha = 0.05;, end
			if dim == 1
				n = size(mat, 2);
			elseif dim == 2 
				n = size(mat, 1);
			else
				error()
			end

			obj.analysis.bootparams = {};
			obj.analysis.bootparams.dim = dim;
			obj.analysis.bootparams.nboot = nboot;
			obj.analysis.bootparams.Alpha = Alpha;
			obj.analysis.bootparams.n = n;

			b = nan(nboot, n);
			ib = randi(size(mat,dim),[nboot,1]);
			% ib = randi(nboot,[1,nboot]);
			b(:,:) = mat(ib, :);

			bsort = sort(b,1);
			lidx = round((Alpha/2*nboot));
			uidx = (1-(Alpha/2))*nboot;
			CIl = bsort(lidx, :);
			CIu = bsort(uidx, :);
		end
		function PCAbehavior(obj, seshID)
			% 
			% 	For use with PCAbehavior mode object. We will gather a PCA matrix of licktimeswrtc_s x seshNo. 
			%	The goal is to be able to distinguish which sessions are in the learning phase of behavior and which are expert to see if 
			%	we can identify behavioral strategies as they evolve
			% 
			if nargin < 2
				seshIdx = 1:numel(obj.collatedResults);
			end
			nsesh = numel(seshIdx);
			names = cellfun(@(x) x(1:3), {obj.collatedResults.sessionID}, 'uniformoutput', 0);
			nmice = num2str(numel(unique(names(seshIdx))));

			X = nan(max([obj.collatedResults.ntrials]),nsesh);
            maxish = 0;
			for ii = 1:nsesh
                xx = obj.collatedResults(ii).flick_s_wrtc(~isnan(obj.collatedResults(ii).flick_s_wrtc));
                if numel(xx)>maxish
                    maxish=numel(xx);
                end
				X(1:numel(xx), ii) = xx;
            end
            X = X(1:200,:)';
			[obj.analysis.PCA.coeff,...
				obj.analysis.PCA.score,...
				obj.analysis.PCA.latent,...
				obj.analysis.PCA.tsquared,...
				obj.analysis.PCA.explained,obj.analysis.PCA.mu] = pca(X, 'Centered',false);

			obj.analysis.PCA.X = X;
			obj.analysis.PCA.nsesh = nsesh;
			obj.analysis.PCA.names = names;
			obj.analysis.PCA.nmice = nmice;
			
		end
		function plotPCAbehavior(obj)
			try
				obj.analysis.PCA.X;
			catch
				error('you must run obj.PCAbehavior first')
			end
			obj.setAnimalID;
			[f, ax] = makeStandardFigure();
% 			for im = 1:str2num(obj.analysis.PCA.nmice)
% 				idxs = find([obj.collatedResults.animalIdx] == im);
% 				plot(ax, obj.analysis.PCA.score(idxs,1), '.-', 'displayname', [obj.collatedResults(idxs).sessionID])
% 			end
            colors = {'rs','gs','bs','cs','ks','ms','ro','go','bo','co','ko','mo'};
            for im = 1:size(obj.analysis.PCA.X,1)
				idx = obj.collatedResults(im).animalIdx;
				plot(ax, obj.analysis.PCA.score(im,2),obj.analysis.PCA.score(im,3), colors{idx}, 'markersize',10, 'displayname', obj.collatedResults(im).sessionID)
            end
            xlabel('PC0')
            ylabel('PC1')
            legend('show')
		end
		function [ax,nrew] = RIMplotraster(obj, seshIdx, animalIdx, customLabeling, excludeCustom)
			% for use with PCAbehavior style object. this has all the behavioral events from arduino, so is more reliable.
			% we can thus plot things with more sublety. Also, this can be used on any session data, but need to run with PCAbehavior
			% to get the needed fields
			%
			% also note that with PCAbehavior obj, we can get the proper flick depending on rxn window... 
			% 	the methods to do this are below!
			%
			% We also may want to do custom exclusions and lebeling. Custom labeling will mark trials based on their labeling code
			% excludeCustom will decide whether to plot these trials or not...
			%
			% We can get the number of non-excluded rewards (ie rewards until satiation, for example...)
			% 
			% 	Plot raster of all licks with first licks overlaid
			% 
			if nargin < 4, customLabeling = false; end
			if nargin < 5, excludeCustom = false; end
			if nargin < 3
				animalIdx = [];
			end
			if isempty(seshIdx)
				seshIdx = find(ismember([obj.collatedResults.animalIdx], animalIdx));
				[~,I] = sort([obj.collatedResults(seshIdx).sessionNo]);
				seshIdx = seshIdx(I);
			end
			nsesh = numel(seshIdx);
			if nsesh > 5
				rr = ceil(nsesh/5);
				[f, ax] = makeStandardFigure(5*rr,[rr,5]);
			else
				[f, ax] = makeStandardFigure(nsesh,[1,nsesh]);
			end
			for ii = 1:numel(seshIdx)
				sesh = seshIdx(ii);
				if ~strcmp(obj.collatedResults(ii).analysisType,'PCAbehavior')
					error('only for use on PCAbehavior objects')
				end
				obj.fix_flicks_for_variable_rxnwin(sesh, true)
				ntrials = obj.collatedResults(sesh).ntrials;
				rb_ms = obj.collatedResults(sesh).behaviorparams.rb_ms;
				target = obj.collatedResults(sesh).behaviorparams.target;
				target(obj.collatedResults(sesh).behaviorparams.ishybrid ~= 1) = nan;
				eot = obj.collatedResults(sesh).behaviorparams.eot;
				rxnwin_s = obj.collatedResults(sesh).behaviorparams.rxnwin_s;
				total_time_ = obj.collatedResults(sesh).behaviorparams.total_time_;
				trialrewarded = obj.collatedResults(sesh).trialrewarded;
				% if numel(obj.collatedResults.rxnwindows) > 1
					
				% end
				flick_s_wrtc = obj.collatedResults(sesh).flick_s_wrtc;
				alllicktimes = obj.collatedResults(sesh).alllick_s_wrtc;

			    
			    %
			    % handle custom exclusions and labeling cases
			    %
			    if customLabeling
			    	if ~isfield(obj.collatedResults(sesh), 'labeling_complete') || ~obj.collatedResults(sesh).labeling_complete
	    				error('You must complete custom labeling of trials before using excludeCustom feature. Run label_trials_in_session and labeling_complete on the session')
    				end
    				[C,~,IC] = unique(obj.collatedResults(sesh).trial_labels(:,1));
    				[d, colors] = obj.trial_type_label_dictionary;
    				for iii = 1:numel(C)
	    				cc = find(strcmp(d,C(iii)));
    					label = C(iii);
    					Color = colors{cc};
                        Rows = find(IC == iii);
                        trials = cell2mat(obj.collatedResults(sesh).trial_labels(Rows,4)');
    					plot(ax(ii), [[-2,17].*ones(numel(trials),2)]', [trials',trials']','-', 'color', Color,'linewidth', 4, 'DisplayName', label{:})
					end
					Rows = 1:numel(obj.collatedResults(sesh).trial_labels(:,1));
                    trials = cell2mat(obj.collatedResults(sesh).trial_labels(Rows,4)');
                    all_exclusions = [obj.collatedResults(sesh).Excluded_Trials, trials];
                    for iexc = all_exclusions
                    	if iexc <= ntrials
					        trialrewarded(iexc) = nan;
				    	end
			        end
		    	end
		    	
		    	if excludeCustom
	    			% remove the trials in custom field...
	    			if ~isfield(obj.collatedResults(sesh), 'labeling_complete') || ~obj.collatedResults(sesh).labeling_complete
	    				error('You must complete custom labeling of trials before using excludeCustom feature. Run label_trials_in_session and labeling_complete on the session')
    				end
    				Rows = 1:numel(obj.collatedResults(sesh).trial_labels(:,1));
                    trials = cell2mat(obj.collatedResults(sesh).trial_labels(Rows,4)');
                    all_exclusions = [obj.collatedResults(sesh).Excluded_Trials, trials];
                    for iexc = all_exclusions
                    	if iexc <= ntrials
		    				alllicktimes{iexc} = [nan];
					        flick_s_wrtc(iexc) = nan;
					        trialrewarded(iexc) = nan;
				    	end
			        end
		        else
		        	for iexc = obj.collatedResults(sesh).Excluded_Trials
		        		if iexc <= ntrials
					        alllicktimes{iexc} = [nan];
					        flick_s_wrtc(iexc) = nan;
					        trialrewarded(iexc) = nan;
				    	end
			    	end
	    		end
			    
	    		nrew = nansum(trialrewarded);
			    plot(ax(ii), flick_s_wrtc, 1:ntrials, 'mo', 'DisplayName', 'First Lick', 'MarkerFaceColor', 'm');
			    plot(ax(ii), trialrewarded.*flick_s_wrtc, 1:ntrials, 'go', 'DisplayName', 'First Lick', 'MarkerFaceColor', 'g');

			    for itrial = 1:ntrials
			        plotpnts = alllicktimes{itrial};
			        if ~isempty(plotpnts)
			            plot(ax(ii), plotpnts, itrial.*ones(numel(plotpnts), 1),'k.')				
			        end
			    end	
			    plot(ax(ii), [0,0], [1,ntrials],'r-', 'DisplayName', 'Cue')
			    plot(ax(ii), rb_ms./1000, 1:numel(rb_ms),'k-', 'DisplayName', 'Reward Boundary')
			    plot(ax(ii), target./1000, 1:numel(target),'r-', 'DisplayName', 'Target')
			    plot(ax(ii), eot./1000, 1:numel(eot),'k-', 'DisplayName', 'ITI Start')
			    plot(ax(ii), total_time_./1000, 1:numel(total_time_),'k-', 'DisplayName', 'ITI End')
			    plot(ax(ii), rxnwin_s, 1:numel(rxnwin_s),'g--', 'DisplayName', 'Permitted Reaction Window')
			    set(ax(ii),  'YDir','reverse')

			    xlim(ax(ii), [-2, total_time_(1)/1000])
			    ylim(ax(ii), [1, ntrials])
			    

			    title(ax(ii), [obj.collatedResults(sesh).sessionID, ' ' num2str(nrew) 'x'], 'interpreter', 'none')
			    xlabel(ax(ii),'time (s)')
			    ylabel(ax(ii),'trial No')
            end
            yy = cell2mat(arrayfun(@(x) get(x, 'ylim'),ax,'uniformoutput', 0));
            ymax = max(yy);
            for ii = 1:nsesh
                ylim(ax(ii), [1,ymax]);
            end
            set(f, 'userdata', ['obj = CLASS_STATcollate_photometry_roadmapv1_4(''PCAbehavior''), using obj.RIMplotraster(' num2str(seshIdx) ',' num2str(animalIdx) '); file: ' obj.iv.savedFileName, ' rewards does not include excluded trials'])
		end
		function fix_flicks_for_variable_rxnwin(obj, seshIdx, Plot)
			%
			% For use with PCAbehavior objects. We will ignore the rxn licks now rather than forcing zero. 
			%
			if ~isfield(obj.collatedResults,'flicks_corrected_for_rxnwin')
				ooo = num2cell(zeros(1,numel(obj.collatedResults)));
				[obj.collatedResults.flicks_corrected_for_rxnwin] = ooo{:};
			end
			if nargin < 3
				Plot = true;
			end
			ii = seshIdx;
			if ~strcmp(obj.collatedResults(ii).analysisType,'PCAbehavior')
				error('only for use on PCAbehavior objects')
			elseif obj.collatedResults(ii).flicks_corrected_for_rxnwin
				return
			elseif numel(obj.collatedResults(ii).rxnwindows) == 1 && obj.collatedResults(ii).rxnwindows == 0
				if ~Plot
					warning(['There''s only one rxn window type in this session, and it''s ' num2str(obj.collatedResults(ii).rxnwindows) '. Nothing to correct. Exiting...'])
				end
				obj.collatedResults(ii).flicks_corrected_for_rxnwin = true;
				obj.collatedResults(ii).trialrewarded = nan(size(obj.collatedResults(ii).flick_s_wrtc));
				obj.collatedResults(ii).trialrewarded(obj.collatedResults(ii).flick_s_wrtc >= 3.3 & obj.collatedResults(ii).flick_s_wrtc < 7) = true;
				return
			elseif numel(obj.collatedResults(ii).rxnwindows) > 2
				error(['we didn''t design this to handle multiple rxn windows (only 2: 0, 500ms). The following were found: ' num2str(obj.collatedResults(ii).rxnwindows)])
			end
			disp(['The following rxn windows were found: ', num2str(obj.collatedResults(ii).rxnwindows)])
			if Plot
				[f,ax] = makeStandardFigure();
				plot(ax, [obj.collatedResults(ii).rxnwindows;obj.collatedResults(ii).rxnwindows], [1,numel(obj.collatedResults(ii).flick_s_wrtc);1,numel(obj.collatedResults(ii).flick_s_wrtc)]', 'k-', 'LineWidth',3, 'displayname', 'rxnwin')
				plot(ax, obj.collatedResults(ii).flick_s_wrtc,1:numel(obj.collatedResults(ii).flick_s_wrtc), 'k.', 'markersize', 20, 'displayname', 'original')
				legend('show');
				ylabel('trial number')
				set(ax,  'YDir','reverse')
				xlabel('rxn win')
			end
			% find the trials with rxn wins that are different...
			rxnwindows = sort(obj.collatedResults(ii).rxnwindows);
			lick = obj.collatedResults(ii).lick;
			cue = obj.collatedResults(ii).cue;
			lampOff = obj.collatedResults(ii).lampOff;

            
            if numel(obj.collatedResults(ii).behaviorparams.rxnwin_s) == numel(obj.collatedResults(ii).lampOff) + 1
                rxnwin_s = obj.collatedResults(ii).behaviorparams.rxnwin_s(1:end-1);
            else
                rxnwin_s = obj.collatedResults(ii).behaviorparams.rxnwin_s;
            end
            
			rxnzerotrials = find(rxnwin_s == 0);
			rxnnonzerotrials = find(rxnwin_s == 0.5);
			[~,lick_s_wrtc_zero,~,~] = getBinnedLicksMARY_standalonefxn(cue, lick, lampOff, 'cue', 30000, 30000, 0, 'all');
            lick_s_wrtc_zero = lick_s_wrtc_zero(rxnzerotrials);
			[~,lick_s_wrtc_500,~,~] = getBinnedLicksMARY_standalonefxn(cue, lick, lampOff, 'cue', 30000, 30000, 0.5, 'all');
            lick_s_wrtc_500 = lick_s_wrtc_500(rxnnonzerotrials);
			obj.collatedResults(ii).flick_s_wrtc = nan(size(obj.collatedResults(ii).flick_s_wrtc));
			obj.collatedResults(ii).flick_s_wrtc(rxnzerotrials) = lick_s_wrtc_zero;
			obj.collatedResults(ii).flick_s_wrtc(rxnnonzerotrials) = lick_s_wrtc_500;
			plot(ax, obj.collatedResults(ii).flick_s_wrtc,1:numel(obj.collatedResults(ii).flick_s_wrtc), 'r.', 'markersize', 20, 'displayname', 'updated')
			obj.collatedResults(ii).trialrewarded = nan(size(obj.collatedResults(ii).flick_s_wrtc));
			obj.collatedResults(ii).trialrewarded(obj.collatedResults(ii).flick_s_wrtc >= 3.3 & obj.collatedResults(ii).flick_s_wrtc < 7) = true;
			obj.collatedResults(ii).flicks_corrected_for_rxnwin = true;
		end
		function [h,fl] = RIMplot_flickhxg(obj, seshIdx, animalIdx, customLabeling, inset, minX)
			% for use with PCAbehavior style object. this has all the behavioral events from arduino, so is more reliable.
			% we can thus plot things with more sublety. Also, this can be used on any session data, but need to run with PCAbehavior
			% to get the needed fields
			%
			% 
			% 	To do averages, make seshIdx a cell -- minX currently only configured for use with averages
			%
			%	if you run customLabeling, you can either exclude all labeled trials or plot BASED on the label
			% 		customLabeling = false: plot all trials (except null exclusions)
			% 		customLabeling = 'sated': only plots the category of interest
			% 		customLabeling = 'clean': this only plots trials that are NOT labeled. This is probs most useful
			% 
			% 	Plot flick hxg of all first licks corrected for rxn window...
			% 
			if nargin < 6, minX = 0; end
			if nargin < 5, inset = []; end
			if nargin < 4, customLabeling = false; end
			if nargin < 3, animalIdx = []; end
			if isempty(seshIdx)
				seshIdx = find(ismember([obj.collatedResults.animalIdx], animalIdx));
				[~,I] = sort([obj.collatedResults(seshIdx).sessionNo]);
				seshIdx = seshIdx(I);
			end
			if iscell(seshIdx)
				averagemode = true;
			else
				averagemode = false;
			end
			nsesh = numel(seshIdx);
			if ~isempty(inset)
				f = gcf;
				ax = inset;
			else
				if ~iscell(seshIdx)
					if nsesh > 5
						rr = ceil(nsesh/5);
						[f, ax] = makeStandardFigure(5*rr,[rr,5]);
					else
						[f, ax] = makeStandardFigure(nsesh,[1,nsesh]);
					end
				else
					[f, ax] = makeStandardFigure();
				end
			end
			if averagemode
				% collect all the flicks
				all_flick_s_wrtc = [];
				sessions = {};
				for ii = 1:numel(seshIdx)
					sesh = seshIdx{ii};
					obj.fix_flicks_for_variable_rxnwin(sesh, true);
					if customLabeling
						[flick_s_wrtc, Color, ~] = obj.condition_flicks(sesh, customLabeling);
					end
					all_flick_s_wrtc = vertcat(all_flick_s_wrtc, flick_s_wrtc);
					sessions{end+1} = obj.collatedResults(sesh).sessionID;
				end
				ntrials = obj.collatedResults(sesh).ntrials;
				rb_ms = obj.collatedResults(sesh).behaviorparams.rb_ms;
				target = obj.collatedResults(sesh).behaviorparams.target;
				target(obj.collatedResults(sesh).behaviorparams.ishybrid ~= 1) = nan;
				eot = obj.collatedResults(sesh).behaviorparams.eot;
				rxnwin_s = obj.collatedResults(sesh).behaviorparams.rxnwin_s;
				total_time_ = obj.collatedResults(sesh).behaviorparams.total_time_;

				% condition on minX
				all_flick_s_wrtc(all_flick_s_wrtc<minX) = [];
				fl = all_flick_s_wrtc(~isnan(all_flick_s_wrtc));

				if customLabeling
			    	h = prettyHxg(ax, all_flick_s_wrtc(~isnan(all_flick_s_wrtc)), sprintf(['flick wrtc\n',customLabeling]), Color,0:0.5:17);
			    	title(ax, [cellstr(sessions), ' ', customLabeling, ' ' 'minX:' num2str(minX)], 'interpreter', 'none')
				else
					h = prettyHxg(ax, all_flick_s_wrtc(~isnan(all_flick_s_wrtc)), 'flick wrtc', 'k',0:0.5:17);
					title(ax, [cellstr(sessions), 'minX:' num2str(minX)], 'interpreter', 'none')
				end
				yy = get(ax, 'ylim');
                hold(ax, 'on')

			    plot(ax, [0,0], [0,1],'r-', 'DisplayName', 'Cue')
			    if numel(unique(rb_ms)) > 1
			    	[obj.collatedResults(sesh).rxnwindows;obj.collatedResults(sesh).rxnwindows], [1,numel(all_flick_s_wrtc);1,numel(all_flick_s_wrtc)]'
			    	plot(ax, [unique(rb_ms./1000);unique(rb_ms./1000)], [zeros(numel(unique(rb_ms))); ones(numel(unique(rb_ms)))],'k-.', 'DisplayName', 'Reward Boundary')
	    		else
	    			plot(ax, rb_ms(1)./1000.*[1,1], [0,1],'k-', 'DisplayName', 'Reward Boundary')
	    		end
	    		if numel(unique(unique(target(~isnan(target))))) > 1
	    			plot(ax, [unique(target./1000);unique(target./1000)], [zeros(numel(unique(target))); ones(numel(unique(target)))],'r-.', 'DisplayName', 'Target')
    			else
    				plot(ax, target(1)./1000.*[1,1], [0,1],'r-', 'DisplayName', 'Target')
    			end
			    plot(ax, eot(1)./1000.*[1,1], [0,1],'k-', 'DisplayName', 'ITI Start')
			    plot(ax, total_time_(1)./1000.*[1,1], [0,1],'k-', 'DisplayName', 'ITI End')
			    if numel(unique(rb_ms)) > 1
			    	plot(ax, [unique(rxnwin_s);unique(rxnwin_s)], [zeros(numel(unique(target))); ones(numel(unique(target)))],'g-.', 'DisplayName', 'Permitted Reaction Window')
	    		else
					plot(ax, rxnwin_s(1).*[1,1], [0,1],'g--', 'DisplayName', 'Permitted Reaction Window')
				end
			    
			    xlim(ax, [-2, total_time_(1)/1000])
			    ylim(ax, yy)	

			    
			    xlabel(ax,'time (s)')
			    ylabel(ax,'% first licks')
			    set(f, 'userdata', ['obj = CLASS_STATcollate_photometry_roadmapv1_4(''PCAbehavior''), using obj.RIMplot_flickhxg(' num2str(cell2mat(seshIdx)) ',' num2str(animalIdx) ',' num2str(customLabeling) ',' num2str(isempty(inset)) ',' num2str(minX) '); file: ' obj.iv.savedFileName])

			else
				for ii = 1:numel(seshIdx)
	                sesh = seshIdx(ii);
					if ~strcmp(obj.collatedResults(sesh).analysisType,'PCAbehavior')
						error('only for use on PCAbehavior objects')
					end
					obj.fix_flicks_for_variable_rxnwin(sesh, true);
					ntrials = obj.collatedResults(sesh).ntrials;
					rb_ms = obj.collatedResults(sesh).behaviorparams.rb_ms;
					target = obj.collatedResults(sesh).behaviorparams.target;
					target(obj.collatedResults(sesh).behaviorparams.ishybrid ~= 1) = nan;
					eot = obj.collatedResults(sesh).behaviorparams.eot;
					rxnwin_s = obj.collatedResults(sesh).behaviorparams.rxnwin_s;
					total_time_ = obj.collatedResults(sesh).behaviorparams.total_time_;
					trialrewarded = obj.collatedResults(sesh).trialrewarded;
					
					
				    
					flick_s_wrtc = obj.collatedResults(sesh).flick_s_wrtc;
					if customLabeling
						if ~isfield(obj.collatedResults(sesh), 'labeling_complete') || ~obj.collatedResults(sesh).labeling_complete
		    				error('You must complete custom labeling of trials before using excludeCustom feature. Run label_trials_in_session and labeling_complete on the session')
	    				end
						if strcmpi(customLabeling, 'clean')
			    			% remove the trials in custom field...
		    				Rows = 1:numel(obj.collatedResults(sesh).trial_labels(:,1));
		                    trials = cell2mat(obj.collatedResults(sesh).trial_labels(Rows,4)');
		                    for iexc = trials
		                    	if iexc <= ntrials
							        flick_s_wrtc(iexc) = nan;
							        trialrewarded(iexc) = nan;
						    	end
					        end
					        Color = 'b';
				        else
				        	%  Only plot the named category.
	    					% identify the desired customlabel from the dictionary along with its color
	    					[d, colors] = obj.trial_type_label_dictionary;
				        	cc = find(strcmp(d,customLabeling));
				        	label = customLabeling;
	    					Color = colors{cc};
	    					% figure out if that label is in the dataset
	    					[C,~,IC] = unique(obj.collatedResults(sesh).trial_labels(:,1));
				        	iii = find(strcmp(C,customLabeling));

	                        	
	                        flwrctemp = flick_s_wrtc;
	                    	flick_s_wrtc = nan(size(flick_s_wrtc));
	                    	trtemp = trialrewarded;
							trialrewarded = nan(size(trialrewarded));
	    					if ~isempty(iii)
		                        Rows = find(IC == iii);
		                        trials = cell2mat(obj.collatedResults(sesh).trial_labels(Rows,4)');
		                        % select only the labeled trials
	                            trials(trials > ntrials) = [];
		                        flick_s_wrtc = nan(size(flick_s_wrtc));
		                        flick_s_wrtc(trials) = flwrctemp(trials);
		                        trialrewarded = nan(size(trialrewarded));
								trialrewarded(trials) = trtemp(trials);
	                    	end
			        	end
			        end
					for iexc = obj.collatedResults(sesh).Excluded_Trials
	                    if iexc <= numel(flick_s_wrtc)
	    			        flick_s_wrtc(iexc) = [];
	                    end
				    end

				    nrew = nansum(trialrewarded);
				    
				    if customLabeling
				    	h = prettyHxg(ax(ii), flick_s_wrtc(~isnan(flick_s_wrtc)), sprintf(['flick wrtc\n',customLabeling]), Color,0:0.5:17);
				    	title(ax(ii), [obj.collatedResults(sesh).sessionID, ' ', customLabeling ' ' num2str(nrew) 'x'], 'interpreter', 'none')
					else
						h = prettyHxg(ax(ii), flick_s_wrtc(~isnan(flick_s_wrtc)), 'flick wrtc', 'k',0:0.5:17);
						title(ax(ii), [obj.collatedResults(sesh).sessionID, ' ' num2str(nrew) 'x'], 'interpreter', 'none')
					end
					yy = get(ax(ii), 'ylim');

				    plot(ax(ii), [0,0], [0,1],'r-', 'DisplayName', 'Cue')
				    if numel(unique(rb_ms)) > 1
				    	[obj.collatedResults(sesh).rxnwindows;obj.collatedResults(sesh).rxnwindows], [1,numel(obj.collatedResults(sesh).flick_s_wrtc);1,numel(obj.collatedResults(sesh).flick_s_wrtc)]'
				    	plot(ax(ii), [unique(rb_ms./1000);unique(rb_ms./1000)], [zeros(numel(unique(rb_ms))); ones(numel(unique(rb_ms)))],'k-.', 'DisplayName', 'Reward Boundary')
		    		else
		    			plot(ax(ii), rb_ms(1)./1000.*[1,1], [0,1],'k-', 'DisplayName', 'Reward Boundary')
		    		end
		    		if numel(unique(unique(target(~isnan(target))))) > 1
		    			plot(ax(ii), [unique(target./1000);unique(target./1000)], [zeros(numel(unique(target))); ones(numel(unique(target)))],'r-.', 'DisplayName', 'Target')
	    			else
	    				plot(ax(ii), target(1)./1000.*[1,1], [0,1],'r-', 'DisplayName', 'Target')
	    			end
				    plot(ax(ii), eot(1)./1000.*[1,1], [0,1],'k-', 'DisplayName', 'ITI Start')
				    plot(ax(ii), total_time_(1)./1000.*[1,1], [0,1],'k-', 'DisplayName', 'ITI End')
				    if numel(unique(rb_ms)) > 1
				    	plot(ax(ii), [unique(rxnwin_s);unique(rxnwin_s)], [zeros(numel(unique(target))); ones(numel(unique(target)))],'g-.', 'DisplayName', 'Permitted Reaction Window')
		    		else
						plot(ax(ii), rxnwin_s(1).*[1,1], [0,1],'g--', 'DisplayName', 'Permitted Reaction Window')
					end
				    
				    xlim(ax(ii), [-2, total_time_(1)/1000])
				    ylim(ax(ii), yy)	

				    
				    xlabel(ax(ii),'time (s)')
				    ylabel(ax(ii),'% first licks')
				    set(f, 'userdata', ['obj = CLASS_STATcollate_photometry_roadmapv1_4(''PCAbehavior''), using obj.RIMplot_flickhxg(' num2str(seshIdx) ',' num2str(animalIdx) ',' num2str(customLabeling) ',' num2str(isempty(inset)) ',' num2str(minX) '); file: ' obj.iv.savedFileName])
				    fl = [];
	            end
            end
            

		end
		function RIM_KS_flicks(obj,animalID, customLabeling)
			if nargin<3, customLabeling = false; end
			% collate the KS test data and plots across sessions
			%	if you run customLabeling, you can either exclude all labeled trials or plot BASED on the label
			% 		customLabeling = false: plot all trials (except null exclusions)
			% 		customLabeling = 'sated': only plots the category of interest
			% 		customLabeling = 'clean': this only plots trials that are NOT labeled. This is probs most useful

			rxnBoundary = 0.7; %excludes the reaction peak from the timing dist

			sessionIDs = find([obj.collatedResults.animalIdx] == animalID);
			[~,I] = sort([obj.collatedResults(sessionIDs).sessionNo]);
			sessionIDs = sessionIDs(I);

			nsessions = numel(sessionIDs);

			if nsessions == 10
			    [f,ax] = makeStandardFigure(10, [2,5]);
			else
			    [f,ax] = makeStandardFigure(25, [5,5]);
			end

			xbars = [];
			stds = [];
			Ds_ig = [];
			ps_ig = [];

			for ii = 1:nsessions
			    % ID the session and animal
			    seshID = sessionIDs(ii);
			    if ~strcmp(obj.collatedResults(seshID).analysisType,'PCAbehavior')
					error('only for use on PCAbehavior objects')
				end
			    str = obj.collatedResults(seshID).sessionID;
			    ids = regexp(str, '_', 'split');
			    Mouse = ids{1};
			    Day = ids{3};
			    
			    % define the behavioral vars
			    flick_s_wrtc = obj.collatedResults(seshID).flick_s_wrtc;
			    ntrials = obj.collatedResults(seshID).ntrials;
			    trialrewarded = obj.collatedResults(seshID).trialrewarded;

			    % handle exclusions
				if customLabeling
					if ~isfield(obj.collatedResults(seshID), 'labeling_complete') || ~obj.collatedResults(seshID).labeling_complete
	    				error('You must complete custom labeling of trials before using excludeCustom feature. Run label_trials_in_session and labeling_complete on the session')
    				end
					if strcmpi(customLabeling, 'clean')
		    			% remove the trials in custom field...
	    				Rows = 1:numel(obj.collatedResults(seshID).trial_labels(:,1));
	                    trials = cell2mat(obj.collatedResults(seshID).trial_labels(Rows,4)');
	                    for iexc = trials
	                    	if iexc <= ntrials
						        flick_s_wrtc(iexc) = nan;
						        trialrewarded(iexc) = nan;
					    	end
				        end
				        Color = 'b';
			        else
			        	%  Only plot the named category.
    					% identify the desired customlabel from the dictionary along with its color
    					[d, colors] = obj.trial_type_label_dictionary;
			        	cc = find(strcmp(d,customLabeling));
			        	label = customLabeling;
    					Color = colors{cc};
    					% figure out if that label is in the dataset
    					[C,~,IC] = unique(obj.collatedResults(seshID).trial_labels(:,1));
			        	iii = find(strcmp(C,customLabeling));

                        	
                        flwrctemp = flick_s_wrtc;
                    	flick_s_wrtc = nan(size(flick_s_wrtc));
                    	trtemp = trialrewarded;
						trialrewarded = nan(size(trialrewarded));
    					if ~isempty(iii)
	                        Rows = find(IC == iii);
	                        trials = cell2mat(obj.collatedResults(seshID).trial_labels(Rows,4)');
	                        % select only the labeled trials
                            trials(trials > ntrials) = [];
	                        flick_s_wrtc = nan(size(flick_s_wrtc));
	                        flick_s_wrtc(trials) = flwrctemp(trials);
	                        trialrewarded = nan(size(trialrewarded));
							trialrewarded(trials) = trtemp(trials);
                    	end
		        	end
		        end
				for iexc = obj.collatedResults(seshID).Excluded_Trials
                    if iexc <= numel(flick_s_wrtc)
    			        flick_s_wrtc(iexc) = [];
                    end
			    end

			    nrew = nansum(trialrewarded);
			    trialRange = 1:numel(flick_s_wrtc);




			    % params of behavior
			    X = flick_s_wrtc(trialRange);
			    X = X(X >rxnBoundary); 
			    X = X(X < 7);
			    N = length(X(X>0));
			    x_bar = mean(X); 
			    xbars(ii) = x_bar;
			    sigma = std(X,1); 
			    stds(ii) = sigma;
			    x_m = min(X);
			    
			    % stats
			    % Inverse Gaussian (maximum Likelihood)
			    try
				    mu_hat_ml_igaussian = x_bar; 
				    lambda_hat_inv_ml_igaussian = (1/N) * sum( 1./X - 1/mu_hat_ml_igaussian); 
				    inverse_gaussian_dist = makedist('InverseGaussian',mu_hat_ml_igaussian, 1/lambda_hat_inv_ml_igaussian); 
				    % exp dist
				    lambda_hat_ml_exponential = 1/x_bar;
				    exponential_dist = makedist('Exponential','mu', x_bar);
					 % KS test
				    disp(' ')
				    disp(' ')
				    disp(str)
				    [h1,p1,ks2stat1]=kstest(X,inverse_gaussian_dist);
				    Ds_ig(ii) = ks2stat1;
				    ps_ig(ii) = p1;
				    [h2,p2,ks2stat2]=kstest(X,exponential_dist);
			    catch
			    	h1 = nan;p1=nan;ks2stat1=nan;
				    Ds_ig(ii) = ks2stat1;
				    ps_ig(ii) = p1;
				    h2=nan;p2=nan;ks2stat2=nan;
			    end
			    

			    disp('KS test inverse-gaussian')
			    disp(num2str(h1))
			    disp(num2str(p1))
			    disp('KS test exp')
			    disp(num2str(h2))
			    disp(num2str(p2))
			    
			    % plotting
			    prettyHxg(ax(ii), X, 'behavior', 'k', 0:1:7);
			    yy = get(ax(ii), 'ylim');
			    try
				    plot(ax(ii), [0;sort(X);7], pdf(inverse_gaussian_dist, [0;sort(X);7]), 'b--', 'displayname', sprintf(['inv gauss\npnot=' num2str(p1)]), 'linewidth', 2)
				    plot(ax(ii), [0;sort(X);7], pdf(exponential_dist, [0;sort(X);7]), 'r--', 'displayname', sprintf(['exp\npnot=' num2str(p1)]), 'linewidth', 2)
			    end
			    ylim(ax(ii), yy);
			    xlim(ax(ii), [0,7]);
			    title(ax(ii), sprintf([str, '\np_ig=' num2str(round(p1,2))]), 'interpreter', 'none')

			end
			set(f, 'userdata', ['obj = CLASS_STATcollate_photometry_roadmapv1_4(''PCAbehavior''), using obj.RIM_KS_flicks(' num2str(animalID) ',' num2str(customLabeling) '); file: ' obj.iv.savedFileName])
			set(f, 'name', ['Trial labeling: ' num2str(customLabeling)])

			%%
			[f,ax] = makeStandardFigure(3, [1,3]);
			for ii = 1:nsessions
			    if ps_ig(ii) < 0.05
			        cc = 'r.';
			    else
			        cc = 'k.';
			    end
			    plot(ax(1), ii, xbars(ii), cc, 'markersize', 20, 'displayname', ['p_not IG=' num2str(ps_ig(ii))])
			    plot(ax(2), ii, stds(ii), cc, 'markersize', 20, 'displayname', ['p_not IG=' num2str(ps_ig(ii))])
			    plot(ax(3), ii, Ds_ig(ii), cc, 'markersize', 20, 'displayname', ['p_not IG=' num2str(ps_ig(ii))])
			    
			        
			    title(ax(1), 'mean flick (s)')
			    xlabel(ax(1), 'session #')
			    ylabel(ax(1), 'time (s)')
			    
			    title(ax(2), 'std flicks')
			    xlabel(ax(2), 'session #')
			    ylabel(ax(2), 'std')
			    
			    title(ax(3), 'KS Distance, inv g')
			    xlabel(ax(3), 'session #')
			    ylabel(ax(3), 'KS Distance')
			end
			


		end
		function [d, colors] = trial_type_label_dictionary(obj)
			% defines a standard set of trial labels
			%
			% Note that "clean" gets applied to anything unlabeled and not in the null_exclusions file when using label_trials_in_session(obj, seshIdx, labelstr, ax)
			% rewards will generally be calculated wrt clean trials unless you write to specify otherwise
			% 
			% 	g: groom; 
			% 	ro: run over from rxn or LOI licking or rew on previous trial
			% 	p: pavlovian
			% 	exp: experimental error (often defn in null exclusions not custom)
			% 	sated: stopped drinking to rewards, let's say inconsistent lick train or <= 4 licks in a bout or followed by several trials off till end
			%	stopped_p_to_o_with_less_than_5_operant_but_then_continued_when_p_again: there was active participation during pav but stopped within a 5 trials of op
			% 	stopped_after_more_than_5_operant_but_then_continued_when_p_again: did a number of operants but then stopped after a time, then resumed with pav
			%	stopped_after_p_to_o_and_didnt_resume: even when go back to p, not participating
			% 	tookbreak: took at least 3 trials off without any licks at all
			%	sated_but_continued_p: animal demonstrated many trials operant from begin of session, but after a long time engaged again in hybrid task (see M4R day 5)
			%
			d = {'g', 'ro', 'p', 'exp', 'sated', 'stopped_p_to_o_with_less_than_5_operant_but_then_continued_when_p_again',...
			 'stopped_after_more_than_5_operant_but_then_continued_when_p_again',...
			 'stopped_after_p_to_o_and_didnt_resume', 'tookbreak', 'sated_but_continued_p'}';
			colors = {[.8,.8,.8], [.5,.5,.5], [.5,.5,0], [1,1,1],[.1,.8,.4],...
				[.6,0,0],...
				[0,.6,0],...
				[0,0,.6],...
				[.8,0,0],...
				[.2,.2,0]};
		end

		function [label,ax] = label_trials_in_session(obj, seshIdx, labelstr, ax)
			%
			%  This and next 2 fxns allow us to label trials in session, which can then be used for exclusions
			% Best to define seshIdx as a variable (e.g., seshId = 1) and then plot the raster first so you can zoom, then run this fxn
			%
			disp('choose from:')
            disp(cellstr(obj.trial_type_label_dictionary))
			if nargin < 3 || isempty(labelstr), labelstr = 'g'; end
			if nargin < 4, ax = obj.RIMplotraster(seshIdx); end
			if ~strcmp(obj.collatedResults(seshIdx).analysisType,'PCAbehavior')
				error('only for use on PCAbehavior objects')
			end
			if ~isfield(obj.collatedResults, 'trial_labels')
				obj.collatedResults(1).trial_labels = {};
				aaa = num2cell(zeros(numel(obj.collatedResults),1));
                [obj.collatedResults.labeling_complete] = aaa{:};
			end
			label = label_trials(ax, labelstr);
			obj.collatedResults(seshIdx).trial_labels{end+1,1} = label{1};
			obj.collatedResults(seshIdx).trial_labels{end,2} = label{2};
			obj.collatedResults(seshIdx).trial_labels{end,3} = label{3};
			obj.collatedResults(seshIdx).trial_labels{end,4} = label{4};
		end
		function mostrecent = delete_label_trials_in_session(obj, seshIdx)
			%
			%	Use this fxn to delete the most recent label for this session
			%
			if ~strcmp(obj.collatedResults(seshIdx).analysisType,'PCAbehavior')
				error('only for use on PCAbehavior objects')
			end
			if ~isempty(obj.collatedResults(seshIdx).trial_labels)
				mostrecent = obj.collatedResults(seshIdx).trial_labels{end,1:4};
				obj.collatedResults(seshIdx).trial_labels = obj.collatedResults(seshIdx).trial_labels{1:end-1, 1:4};
				disp(['removed from ', obj.collatedResults(seshIdx).sessionID, ':' cellstr(mostrecent)])
			end
		end
		function labeling_complete(obj, seshIdx)
			if ~strcmp(obj.collatedResults(seshIdx).analysisType,'PCAbehavior')
				error('only for use on PCAbehavior objects')
			end
			obj.collatedResults(seshIdx).labeling_complete = true;
			disp(['Labeling marked complete for ', obj.collatedResults(seshIdx).sessionID])
		end
		function category_numbers = get_number_of_trials_in_labeled_category(obj, sesh, label)
			% 
			%  this will allow us to tally the number of trials in each labeled category.
			%  if label is not specified, we will return ALL labels and categories for the session
			% 
			% 	Remember you can see all labels in dictionary by running: obj.trial_type_label_dictionary
			% 
			ntrials = obj.collatedResults(sesh).ntrials;
			category_numbers = {};
			cleantrials = 1:ntrials;
			if nargin < 3
				% define all trial types:
				[C,~,IC] = unique(obj.collatedResults(sesh).trial_labels(:,1));
				[d, ~] = obj.trial_type_label_dictionary;
				for iii = 1:numel(C)
    				cc = find(strcmp(d,C(iii)));
					label = C(iii);
                    Rows = find(IC == iii);
                    trials = cell2mat(obj.collatedResults(sesh).trial_labels(Rows,4)');
					trials(trials>ntrials) = [];
					category_numbers{iii,1} = label{1};
					category_numbers{iii,2} = numel(unique(trials));
					category_numbers{iii,3} = unique(trials);

					% remove these from the full tally
					cleantrials(trials) = nan;
				end
				
				% tally the total number of trials:
				category_numbers{end+1,1} = 'null_exclusions';
				et = unique(obj.collatedResults(sesh).Excluded_Trials);
				et(et>ntrials) = [];
				category_numbers{end,2} = numel(et);
				category_numbers{end,3} = et;

				cleantrials(et) = nan;

				allothers = sum(cell2mat(category_numbers(:,2)));
				holder = obj.collatedResults(sesh).trialrewarded;
				holder(1:allothers) = [];
				cleans = numel(holder);
				assert(ntrials - allothers == sum(~isnan(cleantrials)))

				category_numbers{end+1,1} = 'clean';
				category_numbers{end,2} = cleans;
				category_numbers{end,3} = find(~isnan(cleantrials));
                
                category_numbers{end+1,1} = 'total';
				category_numbers{end,2} = ntrials;
				category_numbers{end,3} = 1:ntrials;

				category_numbers{end+1,1} = 'clean rewards';
				category_numbers{end,2} = nansum(obj.collatedResults(sesh).trialrewarded(~isnan(cleantrials)));
                notclean = 1:ntrials;
                notclean(~isnan(cleantrials)) = [];
                rews = obj.collatedResults(sesh).trialrewarded;
                rews(notclean) = false;
				category_numbers{end,3} = find(rews==1)';

			else
			end
		end
		function RIM_overlay_fullytrained_Hxg(obj, animalIdx, nsesh)
			% 
			% 	We will find all the most trained sessions and overlay the Hxgs
			%	nsesh is counting backwards from final day of training
			% 
			if nargin < 3, nsesh = 1; end 
			if nargin < 2, animalIdx = 1:numel(unique([obj.collatedResults.animalIdx])); end

			[f,ax] = makeStandardFigure();

			sessionNo = [obj.collatedResults.sessionNo];
			% start by finding the max sesh for each animal
			[Mice,~,I] = unique([obj.collatedResults.animalIdx]);
			C = linspecer(numel(animalIdx)*nsesh);
			for ii = 1:numel(animalIdx)
				jj = find(I == animalIdx(ii));
				seshs = sessionNo(jj);
				[seshs,II] = sort(seshs);
                
				for kk = 1:nsesh
					thissesh = jj(II(end));
					h = obj.RIMplot_flickhxg(thissesh, [], 'clean', ax);
					set(h, 'displayname', obj.collatedResults(thissesh).sessionID);
                    set(h, 'edgecolor', C(ii,:));
					II = II(1:end-1);
                end
                
            end
            
            legend(ax,'show')
		end
		function [r,p,t_delta, std_tdelta] = RIM_trial_correlation_with_neighboring_trials(obj, seshID, conditioningMode, exclude_ITI)
			% 
			% 	Mouse F3R has very correlated-looking licking...it seems like one trial is much more similar in flick time to the adjacent trials.
			%	Thus examine nearest neighbor f-lick times
			% 
			if nargin < 4, exclude_ITI = false; end
			if nargin < 3, conditioningMode='clean'; disp('Using only ''clean'' trials'); end
			[flick_s_wrtc, Color, trialrewarded] = obj.condition_flicks(seshID, conditioningMode);
			if exclude_ITI
				flick_s_wrtc(flick_s_wrtc>7) = nan;
			end
			pairs_n_minus_1 = nan(numel(flick_s_wrtc),2);
			pairs_n_plus_1 = nan(numel(flick_s_wrtc),2);
			for ii = 1:numel(flick_s_wrtc)
				if ii ~= 1 && sum(~isnan(flick_s_wrtc(ii-1:ii))) == 2 %check before
					pairs_n_minus_1(ii, :) = flick_s_wrtc(ii-1:ii);
				end 
				if ii ~= numel(obj.collatedResults(seshID).flick_s_wrtc) && sum(~isnan(flick_s_wrtc(ii:ii+1))) == 2 %check after
					pairs_n_plus_1(ii, :) = flick_s_wrtc(ii:ii+1);
					
				end
			end
			% remove nans and get correlations...
			pairs_n_minus_1(isnan(pairs_n_minus_1(:,1)),:) = [];
			pairs_n_plus_1(isnan(pairs_n_plus_1(:,1)),:) = [];
			[correlations_n_minus_1, p_n_minus_1] = corr(pairs_n_minus_1);
			[correlations_n_plus_1, p_n_plus_1] = corr(pairs_n_plus_1);
			t_delta = pairs_n_minus_1(:,2) - pairs_n_minus_1(:,1);
			std_tdelta = std(t_delta);

			r = correlations_n_minus_1(2);
			p = p_n_minus_1(2);
		end
		function [flick_s_wrtc, Color, trialrewarded] = condition_flicks(obj, seshID, conditioningMode)
			% 
			% 	If conditioningMode is 'unclean', include everything except null exclusions, thus do nothing.
			% 
			if ~isfield(obj.collatedResults(seshID), 'labeling_complete') || ~obj.collatedResults(seshID).labeling_complete
				error('You must complete custom labeling of trials before using excludeCustom feature. Run label_trials_in_session and labeling_complete on the session')
			end
			ntrials = obj.collatedResults(seshID).ntrials;
		    trialrewarded = obj.collatedResults(seshID).trialrewarded;
			flick_s_wrtc = obj.collatedResults(seshID).flick_s_wrtc;

			if strcmpi(conditioningMode, 'clean')
    			% remove the trials in custom field...
				Rows = 1:numel(obj.collatedResults(seshID).trial_labels(:,1));
                trials = cell2mat(obj.collatedResults(seshID).trial_labels(Rows,4)');
                for iexc = trials
                	if iexc <= ntrials
				        flick_s_wrtc(iexc) = nan;
			    	end
		        end
		        Color = 'b';
	        elseif strcmpi(conditioningMode, 'unclean')
	        	% include everything except null exclusions, thus do nothing.
	        	Color = 'r';
	        else
	        	%  Only plot the named category.
				% identify the desired customlabel from the dictionary along with its color
				[d, colors] = obj.trial_type_label_dictionary;
	        	cc = find(strcmp(d,conditioningMode));
	        	label = conditioningMode;
				Color = colors{cc};
				% figure out if that label is in the dataset
				[C,~,IC] = unique(obj.collatedResults(seshID).trial_labels(:,1));
	        	iii = find(strcmp(C,conditioningMode));

                flwrctemp = flick_s_wrtc;
            	flick_s_wrtc = nan(size(flick_s_wrtc));
            	trtemp = trialrewarded;
				trialrewarded = nan(size(trialrewarded));
				if ~isempty(iii)
                    Rows = find(IC == iii);
                    trials = cell2mat(obj.collatedResults(seshID).trial_labels(Rows,4)');
                    % select only the labeled trials
                    trials(trials > ntrials) = [];
                    flick_s_wrtc = nan(size(flick_s_wrtc));
                    flick_s_wrtc(trials) = flwrctemp(trials);
                    trialrewarded = nan(size(trialrewarded));
					trialrewarded(trials) = trtemp(trials);
            	end
        	end
        	% run null exclusions
			for iexc = obj.collatedResults(seshID).Excluded_Trials
	            if iexc <= numel(flick_s_wrtc)
			        flick_s_wrtc(iexc) = nan;
			        trialrewarded(iexc) = nan;
	            end
		    end
	    end
        function [dict,xs] = RIM_align_helper(obj,animalIdx, alignMode, getXs)
	    	% 
	    	% 	2 possible alignments. we can either align to when concept learning was complete
	    	% 	or we can align to when switched to mature task
	    	% 		concept
	    	% 		mature
	    	% 
            if nargin < 4, getXs = false; end
	    	if strcmpi(alignMode,'concept')
	    		% animal, leaned session, session # range
	    		dict = {{1, 4, [1,10]},... F1R
	    				{2, 5, [1,10]},... F2R
	    				{3, 1, [0,10]},... F3R
	    				{4, 3, [1,10]},... F4R
	    				{5, [11,15], [1,24]},... M1R
	    				{6, 5, [1,10]},... M2R
	    				{7, 4, [1,10]},... M3R
	    				{8, 3, [1,10]},... M4R
	    				{9, 3, [1,10]},... M5R
	    				{10, 8, [1,13]},... M6R
	    				};

			elseif strcmpi(alignMode,'mature')
				dict = {{1, 8, [1,10]},... F1R
	    				{2, 8, [1,10]},... F2R
	    				{3, 7, [0,10]},... F3R
	    				{4, 7, [1,10]},... F4R
	    				{5, 22, [1,24]},... M1R
	    				{6, 8, [1,10]},... M2R
	    				{7, 8, [1,10]},... M3R
	    				{8, 7, [1,10]},... M4R
	    				{9, 7, [1,10]},... M5R
	    				{10, 10, [1,13]},... M6R
	    				};
            else
                error('specify alignMode as either ''concept'' or ''mature''.')
			end
			% make the session idxs x for plotting
			xs = {};
            if getXs
                for ii = 1:numel(animalIdx)
                    mouse = animalIdx(ii);
                    if mouse == 5
                        mn = dict{mouse}{3}(1);
                        mx = dict{mouse}{3}(2);
                        cntr1 = dict{mouse}{2}(1);
                        cntr2 = dict{mouse}{2}(2);
                        xs{end+1} = {dict{mouse}{1}, (mn:mx) - cntr1};
                        xs{end+1} = {dict{mouse}{1}, (mn:mx) - cntr2};
                    else
                        mn = dict{mouse}{3}(1);
                        mx = dict{mouse}{3}(2);
                        cntr = dict{mouse}{2};
                        xs{end+1} = {dict{mouse}{1}, (mn:mx) - cntr};
                    end
                end
            end
    	end
	    function [meanmean, stdmean, meanmedian, stdmedian] = RIM_overlay_pearsonR(obj, animalIdx, conditioningMode, alignMode, exclude_ITI)
			% 
			% 	We will find all the most trained sessions and overlay the Hxgs
			%	nsesh is counting backwards from final day of training
			% 
			% 	alignMode will be a set of sesh Idxs for plotting. We can get these for each animal from the helper fxn
			% 		can either be 'concept' or 'mature'
			% 
			if nargin < 5, exclude_ITI = false; end
			if nargin < 4, alignMode = 'none'; end
			if nargin < 3, conditioningMode = 'clean'; end 
			if nargin < 2, animalIdx = 1:numel(unique([obj.collatedResults.animalIdx])); end

			[f,ax] = makeStandardFigure(3, [1,3]);

			sessionNo = [obj.collatedResults.sessionNo];
			% start by finding the max sesh for each animal
			[Mice,~,I] = unique([obj.collatedResults.animalIdx]);
			C = linspecer(numel(animalIdx));
			for ii = 1:numel(animalIdx)
				jj = find(I == animalIdx(ii));
				seshs = sessionNo(jj);
				if animalIdx(ii) == 5 && strcmp(alignMode, 'concept')
                	% we want to exclude sessions 14+ because mouse had to start over
                	seshs(seshs>13) = [];	
            	end
				% [seshs,II] = sort(seshs);
                
                r = nan(numel(seshs),1);
                p = nan(numel(seshs),1);
                t = cell(numel(seshs),1);
                sdt = nan(numel(seshs),1);
				for kk = 1:numel(seshs)
					try
						[r(kk),p(kk),t{kk},sdt(kk)] = obj.RIM_trial_correlation_with_neighboring_trials(jj(kk), conditioningMode, exclude_ITI);
                    catch ex
                        r(kk)=nan;
                        p(kk)=nan;
                        t{kk}=nan;
                        sdt(kk)=nan;
                    end
                end
                means = cell2mat(cellfun(@(x) mean(abs(x)), t, 'uniformoutput', 0));
                medians = cell2mat(cellfun(@(x) median(abs(x)), t, 'uniformoutput', 0));
                [~,II] = sort(seshs);

                % now one more step...if we are aligning to when concept learning was demonstrated, we need to adjust our seshes
                if ~strcmpi(alignMode, 'none')
	                [dict,~] = obj.RIM_align_helper(jj,alignMode);
	                subtr = dict{animalIdx(ii)}{2};
                else
                	subtr = 0;
                end


            	
            	h = plot(ax(1), seshs(II) - subtr(1), r(II), '.-', 'displayname', obj.collatedResults(jj(2)).sessionID, 'markersize',20);  
            	h2 = plot(ax(2), seshs(II) - subtr(1), means(II), '.-', 'displayname', obj.collatedResults(jj(2)).sessionID, 'markersize',20);    
            	h3 = plot(ax(3), seshs(II) - subtr(1), medians(II), '.-', 'displayname', obj.collatedResults(jj(2)).sessionID, 'markersize',20);    
            
            	% obj.plotCIbar(ax(2), seshs', means,sdt, true, false, obj.collatedResults(jj(2)).sessionID);

            	set(h, 'color', C(ii,:));
	            set(h2, 'color', C(ii,:));
	            set(h3, 'color', C(ii,:));
	            % if animalIdx(ii) == 5
	            % 	h = plot(ax(1), seshs(II) - subtr(2), r(II), '.-', 'displayname', obj.collatedResults(jj(2)).sessionID, 'markersize',20);  
	            % 	h2 = plot(ax(2), seshs(II) - subtr(2), means(II), '.-', 'displayname', obj.collatedResults(jj(2)).sessionID, 'markersize',20);    
	            % 	h3 = plot(ax(3), seshs(II) - subtr(2), medians(II), '.-', 'displayname', obj.collatedResults(jj(2)).sessionID, 'markersize',20);    
	            % 	% obj.plotCIbar(ax(2), seshs', means,sdt, true, false, obj.collatedResults(jj(2)).sessionID);

	            % 	set(h, 'color', C(ii,:));
		           %  set(h2, 'color', C(ii,:));
		           %  set(h3, 'color', C(ii,:));
            	% end
            end
            
            % plot the averages
            [xs, ys, ymean] = FXN_get_chunk_from_plot(ax(2));

% 			for ii = 1:numel(x)
% 				if x{ii}(1) == 0 % ignore
% % 					ys = [nan(size(ys,1), 1), ys];
% 					ys(ii, 1:(numel(y{ii}))-1) = y{ii}(2:end);
% 				else
% 					ys(ii, 1:numel(y{ii})) = y{ii};
% 				end
% 			end
			% ymean = nanmean(ys,1);
			plot(ax(2), xs(1,:), ymean, 'k-', 'linewidth', 2, 'displayname', 'mean')
			meanmean = ymean;
			stdmean = nanstd(ys);

% 			hmed = get(ax(3),'Children');
% 			x=get(hmed,'Xdata');
% 			y=get(hmed,'Ydata');
% 			ys = nan(numel(animalIdx),max(cell2mat(cellfun(@(xx) max(xx), x, 'uniformoutput',0))));
% 			xs = 1 : max(cell2mat(cellfun(@(xx) max(xx), x, 'uniformoutput',0)));
% 			for ii = 1:numel(x)
% 				if x{ii}(1) == 0 % ignore
% % 					ys = [nan(size(ys,1), 1), ys];
% 					ys(ii, 1:(numel(y{ii}))-1) = y{ii}(2:end);
% 				else
% 					ys(ii, 1:numel(y{ii})) = y{ii};
% 				end
% 			end
			[xs, ys, ymean] = FXN_get_chunk_from_plot(ax(3));
			ymean = nanmean(ys,1);
			plot(ax(3), xs, ymean, 'k-', 'linewidth', 2, 'displayname', 'mean')
			meanmedian = ymean;
			stdmedian = nanstd(ys);



			xlabel(ax(1),'session #')
			ylabel(ax(1),'pearson r')
            
            legend(ax(1),'show', 'interpreter', 'none')
            title(ax(2), 'error bars: std')
            ylabel(ax(2), 'mean difference in flick time')
            ylabel(ax(3), 'median difference in flick time')
            set(f, 'userdata', ['obj = CLASS_STATcollate_photometry_roadmapv1_4(''PCAbehavior''), using obj.RIM_overlay_pearsonR(' num2str(animalIdx) ',' num2str(conditioningMode) '); file: ' obj.iv.savedFileName])
			set(f, 'name', ['Trial labeling: ' num2str(conditioningMode)])
		end
		function [hetLast3, KOLast3, KOLast3_typeII] = RIM_get_last_3_sessions(obj, split)
			% 
			% 	split will allow us to divvy up group I vs group II mutants
			% 
			if nargin < 2, split = false; end
			if split
				hetLast3 = {{2,9,10},{67,74,75},{77,84,85},{87,94,95},{97,104,105}};
				KOLast3 = {{56,57,58},{12,19,20},{33,40,41},{108,109,110}};
				KOLast3_typeII = {{23,30,31}};
			else
				hetLast3 = {{2,9,10},{67,74,75},{77,84,85},{87,94,95},{97,104,105}};
				KOLast3 = {{56,57,58},{12,19,20},{23,30,31},{33,40,41},{108,109,110}};
			end
		end
		function [hetLast2, KOLast2] = RIM_get_last_2_sessions(obj)
			hetLast2 = {{2,10},{67,75},{77,85},{87,95},{97,105}};
			KOLast2 = {{57,58},{12,20},{23,31},{33,41},{109,110}};
		end
		function [hetLast1, KOLast1] = RIM_get_last_session(obj)
			hetLast1 = {{2},{67},{77},{87},{97}};
			KOLast1 = {{58},{12},{23},{33},{110}};
		end
		function RIM_plot_last3_hxg(obj, conditioning, hets, KOs, minX)
			% 
			% 	hets and KOs are cell arrays of the sessions for each animal to include. if not supplied, will use last 3
			% 	takes the within animal average of the hets and KOs and overlays them in separate figures
			% 
			if nargin < 5, minX = 0; end
			if nargin < 2, conditioning = 'clean';end
			if nargin < 3
				[hets, KOs] = obj.RIM_get_last_3_sessions;
			end
			[f, ax] = makeStandardFigure(2,[1,2]);
			% plot the hets:
			C = linspecer(numel(hets));
			for ii = 1:numel(hets)
				h = obj.RIMplot_flickhxg(hets{ii}, [], conditioning, ax(1),minX);
				set(h, 'displayname', obj.collatedResults(hets{ii}{1}).mouseName)
                set(h, 'edgecolor', C(ii,:));
			end
			% plot average
			allhets = num2cell(cell2mat(horzcat(hets{:})));
			legend(ax(1), 'show');
			[h,fl] = obj.RIMplot_flickhxg(allhets, [], conditioning, ax(1),minX);
			set(h, 'displayname', 'all')
            set(h, 'edgecolor', 'k');
            title(ax(1), 'Rim c(+/-)^{DA}')
            % plot the CI:
            [CIl, CIu] = obj.RIM_boot_hxg(fl, 0:0.5:17, 10000);
            plot(ax(1), reshape([0, 0.5:0.5:16.5;0.5:0.5:16.5,17],1,2*numel(CIl)), reshape([CIl;CIl],1, 2*numel(CIl)), 'k', 'displayname', 'CIl');
            plot(ax(1), reshape([0, 0.5:0.5:16.5;0.5:0.5:16.5,17],1,2*numel(CIl)), reshape([CIu;CIu],1, 2*numel(CIl)), 'k', 'displayname', 'CIu');
            
			

			% plot the mutants
			C = linspecer(numel(KOs));
			for ii = 1:numel(KOs)
				h = obj.RIMplot_flickhxg(KOs{ii}, [], conditioning, ax(2), minX);
				set(h, 'displayname', obj.collatedResults(KOs{ii}{1}).mouseName)
				set(h, 'edgecolor', C(ii,:));
			end
			legend(ax(2), 'show');
			allKOs = num2cell(cell2mat(horzcat(KOs{:})));
			[h,fl] = obj.RIMplot_flickhxg(allKOs, [], conditioning, ax(2), minX);
			set(h, 'displayname', 'all')
            set(h, 'edgecolor', 'k');
            [CIl, CIu] = obj.RIM_boot_hxg(fl, 0:0.5:17, 10000);
            plot(ax(2), reshape([0, 0.5:0.5:16.5;0.5:0.5:16.5,17],1,2*numel(CIl)), reshape([CIl;CIl],1, 2*numel(CIl)), 'k', 'displayname', 'CIl');
            plot(ax(2), reshape([0, 0.5:0.5:16.5;0.5:0.5:16.5,17],1,2*numel(CIl)), reshape([CIu;CIu],1, 2*numel(CIl)), 'k', 'displayname', 'CIu');
            
            title(ax(2), 'Rim cKO^{DA}')


			set(f, 'userdata', ['obj = CLASS_STATcollate_photometry_roadmapv1_4(''PCAbehavior''), using obj.RIM_plot_last3_hxg(' conditioning ',' num2str(cell2mat(cellfun(@(x) cell2mat(x),hets, 'uniformOutput',0))), ',' num2str(cell2mat(cellfun(@(x) cell2mat(x),KOs, 'uniformOutput',0))) '); file: ' obj.iv.savedFileName])
			set(f, 'name', ['Trial labeling: ' num2str(conditioning)])
		end
		function [CIl, CIu] = RIM_boot_hxg(obj, data, binEdges, nboot)
			%
			%	The idea is to get a 95% CI on a histogram
			%
			Ns = nan(nboot, numel(binEdges)-1);
			for ii = 1:nboot
				b = data(randi(numel(data),[1,numel(data)]));
				[Ns(ii,:),binEdges] = histcounts(b,binEdges);
                Ns(ii,:) = Ns(ii,:)./sum(Ns(ii,:));
			end
			% get the 95% CI
			sortedN = sort(Ns,1);
			Ilow = round(0.05/2 * nboot);
			Ihi = round((1-0.05/2) * nboot);
			CIl = sortedN(Ilow, :);%./(sum(sortedN(Ilow, :)));
			CIu = sortedN(Ihi, :);%./(sum(sortedN(Ilow, :)));
        end
        function [h,p,ks2stat,comparison,anew] = compare_all_last_n_distributions(obj, n, conditioning, rxnBoundary, suppressplot)
        	% 
        	% 	Will gather the last n sessions (either 1, 2 or 3) and compare distributions
        	%
            if nargin < 5, suppressplot = true; end
        	if nargin < 4, rxnBoundary=0.7; end
        	if nargin < 3, conditioning='unclean'; end
        	if n > 3, error('only written for up to 3 last sessions'); end
        	if n == 3, [hetLastn, KOLastn] = obj.RIM_get_last_3_sessions; end
    		if n == 2, [hetLastn, KOLastn] = obj.RIM_get_last_2_sessions; end
			if n == 1, [hetLastn, KOLastn] = obj.RIM_get_last_session; end
            

			All = horzcat(hetLastn,KOLastn);

			anew = obj.RIM_bonferroni_alpha(0.05,10);
			h = [];%nan(nchoosek(10,2),1);
			p = [];%nan(nchoosek(10,2),1);
			ks2stat = [];%nan(nchoosek(10,2),1);
			comparison = {};%cell(nchoosek(10,2),1);

			[f,ax] = makeStandardFigure()
			xlim(ax,[0,10]);
			ylim(ax,[0,10]);
			mice = {};
			for ii = 1:9
				for jj = ii+1:10
					n1 = [All{ii}{:}];
					n2 = [All{jj}{:}];
					[~,p(end+1,1),ks2stat(end+1,1)] = obj.cross_compare_distributions(n1, n2,conditioning, rxnBoundary);
                    if suppressplot, close; end
					h(end+1,1) = p(end)<anew; 
					if h(end) == 1
						rectangle(ax,'Position',[ii-1,jj-1,1,1],'facecolor', 'r')
						rectangle(ax,'Position',[jj-1,ii-1,1,1],'facecolor', 'r')
					else
						rectangle(ax,'Position',[ii-1,jj-1,1,1],'facecolor', 'k')
						rectangle(ax,'Position',[jj-1,ii-1,1,1],'facecolor', 'k')
					end
                    mouse1 = obj.collatedResults(n1(1)).mouseName;
                    mouse2 = obj.collatedResults(n2(1)).mouseName;
%                     mice{end+1} = {mouse1, mouse2};
					comparison{end+1, 1} = {{mouse1,mouse2}, p(end),h(end),n1, n2};
				end
            end
            for ii = 1:5
            	mice{end+1} = obj.collatedResults([hetLastn{ii}{1}]).mouseName;
        	end
        	for ii = 1:5
            	mice{end+1} = obj.collatedResults([KOLastn{ii}{1}]).mouseName;
        	end
            comparison = cellfun(@(x) [x{:}], comparison, 'uniformoutput',0);
            comparison = cell2table(comparison);
            title(ax, 'red is significantly different (bonferroni corrected)')
            xticks(ax, 0.5:9.5)
			xticklabels(ax, mice)
            yticks(ax, 0.5:9.5)
			yticklabels(ax, mice)
			set(f, 'name', conditioning)
			set(f, 'userdata', ['obj = CLASS_STATcollate_photometry_roadmapv1_4(''PCAbehavior''), using obj.compare_all_last_n_distributions(' num2str(n) ',' num2str(conditioning) ',' rxnBoundary '); file: ' obj.iv.savedFileName])

    	end
		function [h,p,ks2stat] = cross_compare_distributions(obj, seshID1, seshID2,conditioningMode, rxnBoundary)
			% 
			% 	The idea will be to generate a distribution object for each mouse and then determine if their distribs are consistent with e/o
			% 
			% 	seshID can be a vector of sessions to include
			% 
			if nargin<5, rxnBoundary = 0.7;end
			if nargin<4, conditioningMode='unclean';end

			if numel(seshID1) > 1
				flick_s_wrtc1 = [];
				flick_s_wrtc2 = [];
				for ii = 1:numel(seshID1)
					[fl,~,~] = obj.condition_flicks(seshID1(ii), conditioningMode);
					flick_s_wrtc1 = vertcat(flick_s_wrtc1,fl);
				end
				for ii = 1:numel(seshID2)
					[fl,~,~] = obj.condition_flicks(seshID2(ii), conditioningMode);
					flick_s_wrtc2 = vertcat(flick_s_wrtc2,fl);
				end
			else
				[flick_s_wrtc1, Color, trialrewarded1] = obj.condition_flicks(seshID1, conditioningMode);
				[flick_s_wrtc2, Color, trialrewarded2] = obj.condition_flicks(seshID2, conditioningMode);
			end

			
			flick_s_wrtc1(flick_s_wrtc1<rxnBoundary) = [];
			flick_s_wrtc2(flick_s_wrtc2<rxnBoundary) = [];
			flick_s_wrtc1(flick_s_wrtc1>7) = [];
			flick_s_wrtc2(flick_s_wrtc2>7) = [];

			[h,p,ks2stat] = kstest2(flick_s_wrtc1, flick_s_wrtc2);
			[f,ax] = makeStandardFigure();
			qqplot(flick_s_wrtc1,flick_s_wrtc2);
			set(f, 'name', conditioningMode)
			if numel(seshID1) > 1
				title(ax, ['x=' num2str(seshID1) ' vs y=' num2str(seshID2) ' pdiff=' num2str(p)])
			else
				title(ax, ['x=' obj.collatedResults(seshID1).sessionID ' vs y=' obj.collatedResults(seshID2).sessionID ' pdiff=' num2str(p)])
			end
			set(f, 'userdata', ['obj = CLASS_STATcollate_photometry_roadmapv1_4(''PCAbehavior''), using obj.cross_compare_distributions(' num2str(seshID1) ',' num2str(seshID2) ',' conditioningMode, ',' num2str(rxnBoundary) '); file: ' obj.iv.savedFileName])
		end
		function anew = RIM_bonferroni_alpha(obj,alpha,ngroups)
			% 
			% 	We set our p threshold for multiple pairs of comparisons (eg 1 vs 2, 1 vs 3, 1 vs 4, 2 vs 3, 2 vs 4, 3 vs 4)
			% 
			kpergroup = 2;
			anew = alpha/(nchoosek(ngroups, kpergroup));
		end
		function SLOSHING_getSliceNames(obj)
			for islice = 1:numel(obj.collatedResults(1).rsq)
				obj.analysis.slicename{islice} = strsplit(obj.collatedResults(1).Theta_Names{1, islice}{1, 1}{1, 2},' ');
				obj.analysis.slicename{islice} = obj.analysis.slicename{islice}{end};
			end
		end
		function SLOSHING_plotCompositeRsq_byAnimal(obj, mouseIdx, modelNo)
			% 
			%  Must call this first to label our animals: obj.setAnimalID;
			% 
			% 	Plots Rsq by timeslice of the sloshing model for each session as well as an average
			% 
			if nargin < 3, modelNo = numel(obj.collatedResults(1).ModelNames);end
			
			if numel(mouseIdx)>1
				[f, ax] = makeStandardFigure();
				C = linspecer(numel(mouseIdx));
				for ii = 1:numel(mouseIdx)
					seshIdx = find(ismember([obj.collatedResults.animalIdx], mouseIdx(ii)));
					Rsqs{ii} = obj.SLOSHING_plotCompositeRsq(seshIdx, modelNo, C(ii,:), ax)
				end
				if nargin < 4
		        % get mean:
		        meanRsqs = cell2mat(cellfun(@(x) cell2mat(x'), Rsqs', 'uniformoutput', 0));
		        meanRsqs = mean(meanRsqs,1);
	            plot(ax, 1:numel(obj.collatedResults(1).rsq), meanRsqs, 'k-', 'linewidth', 2, 'displayname', 'mean')
            end
			else
				seshIdx = find(ismember([obj.collatedResults.animalIdx], mouseIdx));
				obj.SLOSHING_plotCompositeRsq(seshIdx, modelNo)
			end
			set(f, 'userdata', ['obj.SLOSHING_plotCompositeRsq_byAnimal(' mat2str(mouseIdx) ',' num2str(modelNo) ])
			
			
		end
		function Rsqs = SLOSHING_plotCompositeRsq(obj, seshIdx, modelNo, Color, ax)
			% 
			% 	Plots Rsq by timeslice of the sloshing model for each session as well as an average
			% 
			if nargin < 3, modelNo = numel(obj.collatedResults(1).ModelNames);end
			disp(['Model: ', obj.collatedResults(1).ModelNames{modelNo}])
			obj.SLOSHING_getSliceNames;
            slicename = obj.analysis.slicename;
			% extract Rsq for the model for each timeslice
			if nargin < 4
				[f, ax] = makeStandardFigure();
				C = linspecer(numel(seshIdx));
			end
			
			Rsqs = {};
			for ii = 1:numel(seshIdx)
				isesh = seshIdx(ii);
				for islice = 1:numel(obj.collatedResults(1).rsq)
					Rsqs{ii}(islice) = obj.collatedResults(isesh).rsq{1, islice}(modelNo);
				end
				if nargin<4
					plot(ax, 1:numel(obj.collatedResults(1).rsq), Rsqs{ii}, '.-', 'color', C(ii, :), 'displayname', obj.collatedResults(isesh).sessionID)
				else
					plot(ax, 1:numel(obj.collatedResults(1).rsq), Rsqs{ii}, '.-', 'color', Color, 'displayname', obj.collatedResults(isesh).sessionID)
				end
			end
			xticks(ax, 1:numel(obj.collatedResults(1).rsq))
	        xticklabels(ax, obj.analysis.slicename)
            xlabel(ax,'time')
            ylabel(ax,'Rsq')
            title(obj.collatedResults(1).ModelNames{modelNo})
            legend(ax,'show', 'interpreter', 'none')

            if nargin < 4
		        % get mean:
		        meanRsqs = cell2mat(Rsqs');
		        meanRsqs = mean(meanRsqs,1);
	            plot(ax, 1:numel(obj.collatedResults(1).rsq), meanRsqs, 'k-', 'linewidth', 2, 'displayname', 'mean')
            end
		end
		function dummyobj = getavetimeseries(obj, dummyobj, sObj, Z, Mode, nbins, timePad, stimMode, iset)
			% call the runner script
			getavetimeseries
		end
		function getMouseNames(obj)
			components = cellfun(@(x) strsplit(x, '_'), {obj.collatedResults.sessionID}, 'uniformoutput', 0);
			obj.iv.names = unique(cellfun(@(x) lower(x{1}), components, 'uniformoutput', 0));
 			obj.iv.nmice = num2str(numel(obj.iv.names));
 			sesh = cellfun(@(x) strjoin([x(1:3)], '_'), components, 'uniformoutput', 0);
 			obj.iv.nsesh = num2str(numel(unique(sesh)));
 			obj.iv.signal = unique(cellfun(@(x) lower(x{2}), components, 'uniformoutput', 0));
		end
		function [meanTh, propagated_se_th, mdf, CImin, CImax] = getCompositeThetaGeneral(obj, Models)
            % 
            %   Models is cell array with each of the models
            %       Where model is the field with the results of the fit. 
            % 
            % extract the thetas
            ths = {};
            se_ths = {};
            dfs = [];
            for imodel = 1:numel(Models)
                ths{imodel,1} = Models{imodel}.Coefficients.Estimate';
                se_ths{imodel,1} = Models{imodel}.Coefficients.SE';
                dfs(imodel,1) = Models{imodel}.DFE;
            end
            num_ths = numel(Models{1}.Coefficients.Estimate);
            ths = cell2mat(ths)';
            se_ths = cell2mat(se_ths)';
            N = numel(Models);
            % from jl models: # NN = N.*ones(1, size(ths, 2)); # I think the number of ths. We only do one th at a time, so NN is ignored
			% # NN = [number of b0, number of b1, number of b2...] this was needed because not all sets had tdt. We just need N
            % NN = N.*ones(1, size(ths, 2)); I don't think this is right...this was when we were forcing a composite when not all the models had all the predictors...
            % warning('there''s something not indexing right here. i think there was something inverted. find out what the size of these should be...')
            
            
            meanTh = 1/N .* nansum(ths, 2);
            propagated_se_th = 1/N .* sqrt(nansum(se_ths.^2, 2));
            mdf = sum(dfs);
            % mdf = sum(dfs).*ones(1, size(meanTh,1));
            % 
            %   Now, calculate the CI = b +/- t(0.025, n(m-1))*se
            % 
            % for nn = 1:size(meanTh, 1)
                % this was from the forced tdt:
                % CImin(nn) = meanTh(nn) - abs(tinv(.025,numel(NN(nn))*(mdf(nn) - 1))).*propagated_se_th(nn);
                % CImax(nn) = meanTh(nn) + abs(tinv(.025,numel(NN(nn))*(mdf(nn) - 1))).*propagated_se_th(nn);
                % this matches the julia language models: 
                	%   CImin = meanTh - abs( quantile(TDist(N*(mdf - 1)),0.025) ).*propagated_se_th;
					%	CImax = meanTh + abs( quantile(TDist(N*(mdf - 1)),0.025) ).*propagated_se_th;
                % not sure we need to multiply again...we already accounted for all the DOF by summing...
                % CImin(nn) = meanTh - abs(tinv(.025,N*(mdf - 1))).*propagated_se_th(nn);
                % CImax(nn) = meanTh + abs(tinv(.025,N*(mdf - 1))).*propagated_se_th(nn);
                % ok I fussed with this a lot 6-13-23. I looked up how to
                % get regression coeff. it's the df of the model (number of observations) - the
                % number of predictors. I don't think we want to multiply
                % because this will just double our observations. Seems
                % more conservative to not multiply here. could subtract
                % the number of thetas. Basically, whether we subtract the
                % numth or multiply, it doesn't appear to change the
                % answer. effect is on 0.001-0.0001 th digit... our effects are
                % measured more on the order of the 0.1th digit here
                CImin = meanTh - abs(tinv(.025,(mdf - num_ths))).*propagated_se_th;
                CImax = meanTh + abs(tinv(.025,(mdf - num_ths))).*propagated_se_th;
            % end
            % note: theta in rows here, cols are min and 
            obj.analysis.flush.meanTh = meanTh';
            obj.analysis.flush.propagated_se_th = propagated_se_th';
            obj.analysis.flush.mdf = mdf';
            % obj.analysis.flush.N = NN';
            obj.analysis.flush.CImin = CImin';
            obj.analysis.flush.CImax = CImax';
        end
		function [meanTh, propagated_se_th, mdf] = getCompositeThetaSLOSHING(obj,idxs)
			% 
			% 	Same function as decodingFigures, but used on SLOSHING MODEL FITS
			% 
			% 	idxs = the datasets to use
			% 	obj.collatedResults(idx).mdls{1, end}.VariableNames  
			if nargin < 2
				idxs = 1:numel(obj.collatedResults);
			end
			% pull out the thetas for the full model:

			th_names = obj.collatedResults(idxs(1)).mdls{1, end}.VariableNames(2:end);
			mouse_names = {obj.collatedResults(idxs).mouseName};
			animalIdx = [obj.collatedResults(idxs).animalIdx];
			sesh_nos = [obj.collatedResults(idxs).sessionNo];
			Models = {};
			for ii = idxs
				Models{end+1} = obj.collatedResults(ii).mdls{1, end};
			end
			NN = numel(idxs) * numel(th_names);

			[meanTh, propagated_se_th, mdf, CImin, CImax] = obj.getCompositeThetaGeneral(Models)

			obj.analysis.flush.th_names = th_names;
			obj.analysis.flush.nmice = numel(unique(animalIdx));
			obj.analysis.flush.nsesh = numel(mouse_names);
			obj.analysis.flush.meanTh = meanTh;
			obj.analysis.flush.propagated_se_th = propagated_se_th;
			obj.analysis.flush.mdf = mdf;
			obj.analysis.flush.N = NN;
			obj.analysis.flush.CImin = CImin;
			obj.analysis.flush.CImax = CImax;

			obj.plotFlushCoeff;
		end
		function getCompositeThetaSLOSHING_timeslice(obj,idxs)
			% 
			% 	Same function as decodingFigures, but used on SLOSHING MODEL FITS
			% 
			% 	idxs = the datasets to use
			% 	obj.collatedResults(idx).mdls{1, end}.VariableNames  
			if nargin < 2
				idxs = 1:numel(obj.collatedResults);
			end
			% pull out the thetas for the full model:

			
			


			div = obj.collatedResults(1).divs;
			[f,ax] = makeStandardFigure(div, [2, div/2]);

			for dd=1:div
				[meanTh, propagated_se_th, mdf, Name] = obj.getCompositeThetaSLOSHING_timeslice_helper(idxs, dd);
				Title = Name;
				obj.plotFlushCoeff(ax(dd), Title)
			end
			suptitle([num2str(obj.analysis.flush.nmice) ' mice, ' num2str(obj.analysis.flush.nsesh), ' sesh'])
			set(f, 'Name', ['Composite theta, ' obj.collatedResults(1).Mode])
			set(f, 'Units', 'normalized', 'Position', [0, 0.25, 0.95, 0.65])
			arrayfun(@(x) set(x,'LineWidth',8), ax, 'uniformoutput', 0);
			arrayfun(@(x) set(x,'fontsize',20), ax, 'uniformoutput', 0);
			set(ax, 'ticklength', [0.05,0.05])
			yy = cell2mat(arrayfun(@(x) get(x, 'ylim'), ax, 'uniformoutput', 0));
			yy_l = min(min(yy));
			yy_u = max(max(yy));
			arrayfun(@(x) ylim(x, [yy_l, yy_u]), ax, 'uniformoutput', 0);
		end
		function [meanTh, propagated_se_th, mdf, Name] = getCompositeThetaSLOSHING_timeslice_helper(obj,idxs, div)
			
			Models = {};
			for ii = 1:idxs
				Models{end+1} = obj.collatedResults(ii).mdls{div,1};
            end
            mouse_names = {obj.collatedResults(idxs).mouseName};
			animalIdx = [obj.collatedResults(idxs).animalIdx];
			sesh_nos = [obj.collatedResults(idxs).sessionNo];
            th_names = obj.collatedResults(idxs(1)).mdls{1, end}.VariableNames(2:end);

			NN = numel(idxs) * numel(th_names);
			
			[meanTh, propagated_se_th, mdf, CImin, CImax] = obj.getCompositeThetaGeneral(Models);

			obj.analysis.flush.th_names = th_names;
			obj.analysis.flush.nmice = numel(unique(animalIdx));
			obj.analysis.flush.nsesh = numel(mouse_names);
			obj.analysis.flush.meanTh = meanTh;
			obj.analysis.flush.propagated_se_th = propagated_se_th;
			obj.analysis.flush.mdf = mdf;
			obj.analysis.flush.N = NN;
			obj.analysis.flush.CImin = CImin;
			obj.analysis.flush.CImax = CImax;
			obj.analysis.flush.div = div;

			MD = obj.collatedResults(1).ModelDeets{div,1};

			if strcmp(MD.ModelType, 'LTA')
				Name = [num2str(MD.xshift/1000) ':' num2str(MD.xshift/1000+MD.window/1000)];
			elseif strcmp(MD.ModelType, 'LOTA')
				Name = [num2str(MD.xshift/1000 - MD.window/1000) ':' num2str(MD.xshift/1000)];
			end
			obj.analysis.flush.div = div;

		end
		function plotFlushCoeff(obj, ax, Title)
			% plots the composite coeffs in flush SLOSHING VERSION
			Theta_Names = obj.analysis.flush.th_names;
			meanTh = obj.analysis.flush.meanTh;
			CImin = obj.analysis.flush.CImin;
			CImax = obj.analysis.flush.CImax;
			if nargin <2
				[f,ax] = makeStandardFigure();
			end
			% Yl = 'beta';
			if nargin < 3
				Title = [num2str(obj.analysis.flush.nmice) ' mice | ', num2str(obj.analysis.flush.nsesh) ' session'];
			end
            for ii = 1:numel(Theta_Names)
                plot(ax,ii, meanTh(ii), 'r.', 'markersize', 40, 'displayname', Theta_Names{ii});
                plotCIbar(ax,ii,meanTh(ii),[CImin(ii),CImax(ii)],[]);
            end
            plot(ax, [0,numel(meanTh)+1],[0,0], 'linewidth', 5, 'handlevisibility', 'off'); 
%             xlabel(ax,Xl)
            xticks(ax,1:numel(meanTh));
            xticklabels(ax, Theta_Names);
            % ylabel(ax,Yl)
            if ~isempty(Title)
                title(ax,Title)
            end
            % legend(ax,'hide', 'location', 'best') 
        end


        % sloshing stimulation functions----------------------------------
        function espObj = makeCompositeSloshingStimulationESPObj(obj, seshIdx)
        	if nargin<2, seshIdx = 1:numel(obj.collatedResults);end
        	espObj = EphysStimPhot([], obj);
        	espObj.ChR2.stimMode = 'stim';
        	espObj.GLM.flick_s_wrtc = cell2mat({obj.collatedResults.flick_s_wrtc}');
        	espObj.GLM.stim_flicks = cell2mat({obj.collatedResults.stim_flicks}');
        	espObj.GLM.unstim_flicks = cell2mat({obj.collatedResults.unstim_flicks}');
        	espObj.GLM.stim_nexttrial_flicks = cell2mat({obj.collatedResults.stim_nexttrial_flicks}');
        	espObj.GLM.unstim_nexttrial_flicks = cell2mat({obj.collatedResults.unstim_nexttrial_flicks}');
        	espObj.GLM.stim_nexttrial_flicks2 = cell2mat({obj.collatedResults.stim_nexttrial_flicks2}');
        	espObj.GLM.unstim_nexttrial_flicks2 = cell2mat({obj.collatedResults.unstim_nexttrial_flicks2}');

        	% need to get the stim trials indicies...
        	espObj.GLM.stimTrials = [];
        	startidx = 0;
        	for isesh = 1:numel(seshIdx)
        		ii = seshIdx(isesh);
        		if isesh == 1
        			espObj.GLM.stimTrials = obj.collatedResults(ii).stimTrials;
        			espObj.GLM.noStimTrials = obj.collatedResults(ii).noStimTrials';
        			startidx = numel(obj.collatedResults(ii).flick_s_wrtc);
    			else
	    			stimTrialsNext = obj.collatedResults(ii).stimTrials + startidx;
	    			nostimTrialsNext = obj.collatedResults(ii).noStimTrials' + startidx;
	    			espObj.GLM.stimTrials = [espObj.GLM.stimTrials;stimTrialsNext];
	    			espObj.GLM.noStimTrials = [espObj.GLM.noStimTrials;nostimTrialsNext];
	    			startidx =  startidx + numel(obj.collatedResults(ii).flick_s_wrtc);
    			end
    		end

        	espObj.plotStimulation(true);
        	espObj.plotDelTimeVsTrialNByStim(true);
    	end
	end
end



