mkdir MEG_stats/kids
mkdir MEG_stats/adults
metrics="ERP Power"
sensors="Grad Mag"
for metric in ${metrics}; do
	for sensor in ${sensors}; do
		cat MEG_stats/dh[012]?a/Stats-${metric}-${sensor}.txt >MEG_stats/kids/Stats-${metric}-${sensor}.txt
		cat MEG_stats/dh[567]?a/Stats-${metric}-${sensor}.txt >MEG_stats/adults/Stats-${metric}-${sensor}.txt
	done
done
