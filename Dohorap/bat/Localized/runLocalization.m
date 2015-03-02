batDir = [getenv('BATDIR') 'Localized/'];
cd(batDir);
system(['python ' batDir 'MNEcalculateSTCs.py']); 			  % ~60min auf Eber
averageSTC			  										  % 6min
system(['python ' batDir 'combineGroupSTCinROIs.py']); % 1min
plotLocalizedActivity									  % 1min
