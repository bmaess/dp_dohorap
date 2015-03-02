groupNames = {'kids','adults'};
conditionNames= {'Obj','Subj','Contrast'};
ROIselection = 1:8;
docPath = [getenv('DATDIR') 'doc/ROIactivity/'];
locPath = [getenv('DATDIR') 'Localized_avg/'];
ROInames = {'PAC','pSTG','aSTG','pSTS', 'aSTS', 'BA45','BA44','BA6v'};
conditionColors = [[0.8,0,0];[0,0,1]];
hemispheres = {'lh','rh'};
metrics = {'norm','signed'};

% Import time windows from the interval analysis
currentFolder = pwd;
cd([getenv('DATDIR') 'MEG_stats/']);
subjectIDs = [4:12,14:16 52:60, 62:65 67:69, 71];
significance = cell(1,max(subjectIDs));
for subjectID = subjectIDs
	subject = ['dh' sprintf('%02i', subjectID) 'a'];
    eval(['[timewindows, subjectSignificance] = Localized_IntervalMatlab_' subject '();']);
    significance{subjectID} = subjectSignificance;
end
cd(currentFolder);

timescale = -1.0:0.001:2.999;
metricID = 2;
metric = metrics{metricID};
if metricID == 1
	ylims = [0.5, 1.8];
else
	ylims = [-1.8,1.8];
end
for hemisphereIndex = [1,2]
	hemisphere = hemispheres{hemisphereIndex}
	groupData = cell(2, numel(ROInames));
	for subjectID = subjectIDs
		subject = ['dh' sprintf('%02i', subjectID) 'a'];
		for condition = 1:numel(conditionNames)
			finalCondition = condition == numel(conditionNames);
			conditionName = conditionNames{condition};
			data = zeros(numel(ROIselection),numel(timescale));
			ROIselectionNames = cell(1,numel(ROIselection));
         ROIselectionColors = zeros(numel(ROIselection),3);
         if ~finalCondition
             activityFile = [locPath subject '/' conditionName '_', metric, '-', hemisphere, '.mat'];
             l = load(activityFile);
         end
			for ROIindex = 1:numel(ROIselection)
				ROI = ROIselection(ROIindex);
				ROIname = ROInames{ROI};
				if ~finalCondition
    				ROIselectionNames{ROIindex} = ROIname;
					eval(['data = l.' ROIname ';']);
					groupData{condition,ROI} = data;
				else
					picFile = [docPath subject '/' metric '-' ROIname '-' hemisphere '.png'];
					titleText = ['Comparison of responses for label ' ROIname '-' hemisphere];
					conditionText = {'Object-relative clauses','Subject-relative clauses'};
					data = [groupData{1,ROI}; groupData{2,ROI}];
					pValues = significance{subjectID}(ROI,hemisphereIndex,:);
					plotData(timescale, data, conditionText, conditionColors, titleText, picFile, ylims, timewindows, pValues);
				end
			end
		end
	end
end
