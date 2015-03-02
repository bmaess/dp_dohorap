% Requires about 24 minutes to run and 3GB RAM (4GB peak)
clear;
% Define the basic variables
subjects = {[04 05 06 07 08 09 10 11 12 14 15 16], [52 53 54 55 56 57 58 59 60 62 63 64 65 67 68 69 71]};
groupNames = {'kids','adults'};
conditionNames = {'Obj','Subj'};
hemisphereNames = {'lh','rh'};
locDir = [getenv('DATDIR') 'Localized_avg/'];
metrics={'norm','signed'};

% Determine the format of the localized activity
stcFile = mne_read_stc_file([locDir 'dh12a/Obj_norm-lh.stc']);
nodeCount = size(stcFile.data,1);
dataLength = size(stcFile.data,2);
conditionCount = numel(conditionNames);

for metric = 1:numel(metrics)
    m = metrics{metric};
    
    for hemisphere = 1:2
        h = hemisphereNames{hemisphere};

        for group = 1:2
            g = groupNames{group};
            groupCount = numel(subjects{group});
            activity = zeros(conditionCount, nodeCount, dataLength);

            for subject = subjects{group}
                subjectData = zeros(conditionCount, nodeCount, dataLength);
                s = ['dh' num2str(subject,'%02i') 'a'];

                for condition = 1:numel(conditionNames)
                    c = conditionNames{condition};
                    stcFile = [locDir s '/' c '_' m '-' h '.stc'];
                    disp([metric, hemisphere, subject, condition]);
                    thisSTC = mne_read_stc_file(stcFile);
                    subjectData(condition, :,:) = thisSTC.data;
                end;

                % Normalizing the data
                if strcmp(m,'norm')
                    % Average over conditions first, then average over the timeline
                    subjectAmplitude = squeeze(mean(mean(subjectData(1:2,:,:),1),3));
                elseif strcmp(m,'signed')
                    % Average over conditions first, then calculate the standard deviation over the timeline
                    subjectAmplitude = std(squeeze(mean(subjectData(1:2,:,:),1))');
                end
                % subjectAmplitude represents the average activity for each node
                % Since a node-based normalization doesn't make a lot of sense, we'll average that as well
                % disp(mean(subjectAmplitude))
                subjectData = subjectData / mean(subjectAmplitude);

                % Memory-saving averaging across subjects
                activity = activity + subjectData ./ groupCount;
            end;

            % Save the post-processed STC files
            for condition = 1:numel(conditionNames)
                c = conditionNames{condition};
                thisSTC.data = squeeze(activity(condition,:,:));
                mne_write_stc_file([locDir '/' m '-' g '-' c '-' h '.stc'], thisSTC);
            end;
            % Generate the contrast STC file
            thisSTC.data = squeeze(activity(1,:,:) - activity(2,:,:));
            mne_write_stc_file([locDir '/' m '-' g '-Contrast-' h '.stc'], thisSTC);
        end;
    end;
end;
