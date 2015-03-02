function writeCovarianceMatrix(avgData, covFileStem)
    for condition = 1:2
        kov_example=mne_read_noise_cov('/scr/kuba1/Dohorap/Main/Data/MEG/pa99a2_mch05l30ss_avr-cov.fif');
        kov_example.data = avgData{condition}.cov;
        mne_write_cov_file([covFileStem '-c' num2str(condition) '.fif'], kov_example);
    end;
end