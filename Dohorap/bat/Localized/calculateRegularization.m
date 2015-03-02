subjectIDs = {[4:12,14:16], [52:60, 62:69, 71]};
basePath = [getenv('DATDIR') 'MEG_mc_hp004_ica_l50/'];
groupNames = {'adults','kids'};
filename = [basePath 'regularization.txt'];
outFile = fopen(filename,'w');
fprintf(outFile, 'Subject Dimension Regularization\n');
mags = 3:3:306;
grads = sort([1:3:304 2:3:305]);
for group = 1:numel(groupNames)
    groupName = groupNames{group};
    subjectCount = numel(subjectIDs{group});
    for subjectID = subjectIDs{group}
        subject = sprintf('%02i', subjectID);
        covFilename = [basePath 'dh' subject 'a/Vis-cov.fif'];
        cov = mne_read_noise_cov(covFilename);
        gradSVD = svd(cov.data(grads,grads));
        [~,usableDimension] = max(abs(diff(log(gradSVD)))); % Determine the amount of usable dimensions
        lowerCutoffValue = prctile(log(gradSVD(1:usableDimension)),15); % remove the lower 15% of usable dimensions
        [~,lowerCutoffDimension] = min(abs(log(gradSVD) - lowerCutoffValue));
        reg = gradSVD(lowerCutoffDimension) / gradSVD(1);
        fprintf(outFile, '%s %i %10.10f\n', subject, usableDimension, reg);
        if subjectID == 60
            temp = 3; % for inserting breakpoints
        end
    end
end
fclose(outFile);
