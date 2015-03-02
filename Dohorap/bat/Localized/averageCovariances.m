subjectIDs = {2:16, 52:69};
basePath = [getenv('DATDIR') 'MEG_mc_hp004_ica_l50/'];
groupNames = {'adults','kids'};
for group = 1:numel(groupNames)
    groupName = groupNames{group};
    subjectCount = numel(subjectIDs{group});
    for subjectID = subjectIDs{group}
        subject = sprintf('%02i', subjectID);
        covFilename = [basePath 'dh' subject 'a/Vis_corr-cov.fif'];
        cov = mne_read_noise_cov(covFilename);
        if subjectID == subjectIDs{group}(1)
            averageCov = cov;
        else
            averageCov.data = averageCov.data + cov.data / subjectCount;
        end
    end
    mne_write_cov_file([basePath groupName '-Vis_corr-cov.fif'], averageCov);
end
