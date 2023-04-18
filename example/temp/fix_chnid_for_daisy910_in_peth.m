uniqueExpNames = unique({PETH.ExpName});
for iExp = 1:length(uniqueExpNames)
    expName = uniqueExpNames{iExp};
    if contains(expName, {'daisy9', 'daisy10'})
        tr = TetrodeRecording.BatchLoadSimple(expName);
        inExp = strcmpi({PETH.ExpName}, expName);
        for i = find(inExp)
            oldChannel = PETH(i).Channel;
            PETH(i).Channel = find(tr.SelectedChannels == PETH(i).Channel);
            fprintf(1, '%s, %d -> %d', expName, oldChannel, PETH(i).Channel)
        end
    end
end
