groups <- c('kids','adults')
timewindows <- c('A','B','C')
sensors <- c('Grad', 'Mag')
hemispheres <- c('lh','rh')
ROIs <- c('frontal','temporal','parietal')

for (groupID in 1:length(groups)) {
	group <- groups[groupID]
	inputfilename = paste(Sys.getenv("DATDIR"), "MEG_stats/", group, "/MEG-ClusterStats.txt", sep="")
	activity = read.table(inputfilename)
	names(activity) <- c("cond","group","window","region","sensor","value")
	activity <- within(activity, {
		cond   <- factor(cond)
		group  <- factor(group)
		window <- factor(window)
		region <- factor(region)
		sensor <- factor(sensor)
	})
	for (sensorID in 1:length(sensors)) {
		sensortype <- sensors[sensorID]
		for (hemID in 1:length(hemispheres)) {
			hemisphere <- hemispheres[hemID]
			for (roiID in 1:length(ROIs)) {
				ROI <- ROIs[roiID]
				hemisphericROI <- paste(ROI, hemisphere, sep="-")
				for (timewindowID in 1:length(timewindows)) {
					timewindow <- timewindows[timewindowID]
					print(c(group, ROI, timewindow))
					# Prepare output files
					picstem <- paste(hemisphericROI, timewindow, sensortype, sep="_")
					picname <- paste(Sys.getenv("DATDIR"), "MEG_stats/", group, "/", picstem, ".png", sep="")
					textname <- paste(Sys.getenv("DATDIR"), "MEG_stats/", group, "/", picstem, ".txt", sep="")

					# Perform the actual statistics
					single_roi <- activity[ which(
						activity $ sensor==sensortype &
						activity $ group==group &
						activity $ region==hemisphericROI &
						activity $ window==timewindow), ]
					#with(single_roi,interaction.plot(cond,hem,value,ylab="mean activity",xlab="cond",trace.label="hem"))
					fit <- aov(value~cond, data=single_roi)
					#fit <- aov(value~cond*hem + Error(subj/(cond*hem)),data=single_roi)
					s <- summary(fit)
					capture.output(s, file = textname)
					# print(model.tables(single_roi.aov,"means"),digits=3)

					# Save the boxplot
					#png(picname, width=4, height=4, units="in", res=300)
					#boxplot(value~cond,data=single_roi)
					#dev.off()
				}
			}
		}
	}
}
