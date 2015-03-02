# Create the methods chapter
echo "" > "chapter/Methods.tex"
cat ../"3.1. Participants and Stimuli.tex" >> "chapter/Methods.tex"
cat ../"3.2. Data acquisition.tex" >> "chapter/Methods.tex"
cat ../"3.3. Data analysis.tex" >> "chapter/Methods.tex"

# Create the results chapter
echo "" > "chapter/Results.tex"
cat ../"4.1 Behavioral results.tex" >> "chapter/Results.tex"
cat ../"4.2 Sensor-space activity.tex" >> "chapter/Results.tex"
#cat ../"4.3 Source-space activity.tex" >> "chapter/Results.tex"
#cat ../4.4 Source-space interactions" >> "chapter/Results.tex"

pdflatex dissertation.tex

# Create the bibliography file
bibFiles=`ls chapter/*.bib`
echo "" > bibliography.bib
bibFiles=`ls ../*.bib`
for bibFile in $bibFiles; do cat ${bibFile} >> bibliography.bib; done
bibtex bibliography.bib
pdflatex dissertation.tex