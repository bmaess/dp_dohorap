groups <- c('kids','adults')
timewindows <- c('A','B','C','D')
hemispheres <- c('lh','rh')
ROIs <- c('PAC','pSTG','aSTG','aSTS','pSTS','BA45','BA44','BA6v')

for (groupID in 1:length(groups)) {
	group <- groups[groupID]
	inputfilename = paste(Sys.getenv("DATDIR"), "MEG_stats/", group, "/Localized-ClusterStats.txt", sep="")
	activity = read.table(inputfilename)

	## Convert variables to factor
	names(activity) <- c("cond","group","window","region","value")
	activity <- within(activity, {
		cond   <- factor(cond)
		group  <- factor(group)
		window <- factor(window)
		region <- factor(region)
	})
	metric <- "signed"
	for (hemID in 1:length(hemispheres)) {
		hemisphere <- hemispheres[hemID]
		for (roiID in 1:length(ROIs)) {
			ROI <- ROIs[roiID]
			hemisphericROI <- paste(ROI, hemisphere, sep="-")
			for (timewindowID in 1:length(timewindows)) {
				timewindow <- timewindows[timewindowID]
				#print(c(group, ROI, timewindow))
				# Prepare output files
				picstem <- paste(metric, hemisphericROI, timewindow, sep="_")
				picname <- paste(Sys.getenv("DATDIR"), "MEG_stats/", group, "/", picstem, ".png", sep="")
				textname <- paste(Sys.getenv("DATDIR"), "MEG_stats/", group, "/", picstem, ".txt", sep="")

				# Perform the actual statistics
				single_roi <- activity[ which(
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
