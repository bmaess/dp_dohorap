function writeAverageFif(avgData, averageFifFileStem)
    for condition = 1:2    
        raw_header = fiff_setup_read_raw('/scr/kuba1/Dohorap/Main/Data/MEG/dh52a/dh52a1.fif');
        MNEevoked.info               = raw_header.info;
        MNEevoked.info.projs         = MNEevoked.info.comps;
        MNEevoked.evoked.aspect_kind =  100;
        MNEevoked.evoked.is_smsh     =    0;
        MNEevoked.evoked.nave        = length(avgData{condition}.cfg.trials);
        MNEevoked.evoked.first       = avgData{condition}.time(1,1)*1000; % in ms
        MNEevoked.evoked.last        = avgData{condition}.time(1,end)*1000; % am ende in ms 
        MNEevoked.evoked.times       = linspace(MNEevoked.evoked.first,MNEevoked.evoked.last,1000);
        MNEevoked.evoked.comment     = avgData{condition}.cfg.triggertype;
        MNEevoked.evoked.epochs      = avgData{condition}.avg(1:MNEevoked.info.nchan,:);
        fiff_write_evoked([averageFifFileStem '-c' num2str(condition) '.fif'],MNEevoked);
    end;
end