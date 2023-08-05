% binningHelper.m
% 
% 	ahamilos, 11-6-2020, from CLASS_photometry_roadmapv1_4.m, init_v3x
% 
% 
% 	Multirunning ave: must multiply each existing ave by its total components first, then divide by overall total
% 		eg:
% 			ave n1: nbar1 = sum(n1)/s1, where s1 is the number of samples in set n1
% 			ave n2: nbar2 = sum(n2)/s2, where s2 is the number of samples in set n2
% 			ave (n1, n2): [(s1 * nbar1) + (s2 * nbar2)]/(s1 + s2)
% 						= [N1 + N2]
% 
% 	n1 is the set of trials already in obj
% 	n2 is the set of trials to be added from sObj
% 

runningCTA = obj.analysis.ts.BinnedData.CTA;
runningLTA = obj.analysis.ts.BinnedData.LTA;
nRunning = obj.analysis.ts.NperBin;
						
newCTA = sObj.ts.BinnedData.CTA;
newLTA = sObj.ts.BinnedData.LTA;
newCTA(cellfun(@isempty, newCTA)) = {nan(1,cc)};
newLTA(cellfun(@isempty, newLTA)) = {nan(1,ll)};
nNew = cell2mat(cellfun(@(x) numel(x), sObj.ts.BinParams.trials_in_each_bin, 'uniformoutput', 0));

obj.analysis.ts.NperBin = nRunning + nNew;

nRunningC = reshape(nRunning, size(runningCTA));
nNewC = reshape(nNew, size(runningCTA));
NperBinC = reshape(obj.analysis.ts.NperBin, size(runningCTA));
assert(sum(nRunningC == nRunning) == numel(nRunning))
assert(sum(nNewC == nNew) == numel(nNew))
assert(sum(NperBinC == NperBinC) == numel(NperBinC))


runningCTA = cellfun(@(running, nrunning, new, nnew, ntotal) nansum([new.*(nnew/ntotal); running.*(nrunning/ntotal)], 1), runningCTA, num2cell(nRunningC), newCTA, num2cell(nNewC), num2cell(NperBinC),'uniformoutput', 0);
runningLTA = cellfun(@(running, nrunning, new, nnew, ntotal) nansum([new.*(nnew/ntotal); running.*(nrunning/ntotal)], 1), runningLTA, num2cell(nRunningC), newLTA, num2cell(nNewC), num2cell(NperBinC),'uniformoutput', 0);

runningCTA = cellfun(@(running) sObj.zero2nan(running), runningCTA, 'uniformoutput', 0);
runningLTA = cellfun(@(running) sObj.zero2nan(running), runningLTA, 'uniformoutput', 0);


obj.analysis.ts.BinnedData.CTA = runningCTA;
obj.analysis.ts.BinnedData.LTA = runningLTA;


	        