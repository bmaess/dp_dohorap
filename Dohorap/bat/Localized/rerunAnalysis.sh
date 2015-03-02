# requires paths to be set

python ${BATDIR}/Localized/writeRdata.py
${BATDIR}/Localized/PrepareStatsAnalysis.sh
Rscript ${BATDIR}/Localized/group_activity_anova_syntax.r
python ${BATDIR}/Localized/summarizeStats.py
