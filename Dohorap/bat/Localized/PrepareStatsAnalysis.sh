mkdir MEG_stats/kids
mkdir MEG_stats/adults
cat MEG_stats/dh[012]?a/Stats-localized-norm.txt >MEG_stats/kids/Stats-localized-norm.txt
cat MEG_stats/dh[567]?a/Stats-localized-norm.txt >MEG_stats/adults/Stats-localized-norm.txt
cat MEG_stats/dh[012]?a/Stats-localized-signed.txt >MEG_stats/kids/Stats-localized-signed.txt
cat MEG_stats/dh[567]?a/Stats-localized-signed.txt >MEG_stats/adults/Stats-localized-signed.txt

