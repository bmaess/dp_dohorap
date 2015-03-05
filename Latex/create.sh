# Create the intro chapter
echo "" > "chapter/Introduction.tex"
cat ../"1.1 The role of white matter tracts in syntax processing.tex" >> "chapter/Introduction.tex"
cat ../"1.2 Functional anatomy of syntax processing.tex" >> "chapter/Introduction.tex"
cat ../"1.3 Experimental paradigm.tex" >> "chapter/Introduction.tex"
cat ../"1.4 Research questions.tex" >> "chapter/Introduction.tex"
cat ../"1.5 Choice of measurement methods.tex" >> "chapter/Introduction.tex"

# Create the methods chapter
echo "" > "chapter/Methods.tex"
cat ../"3.1. Participants and Stimuli.tex" >> "chapter/Methods.tex"
cat ../"3.2. Data acquisition.tex" >> "chapter/Methods.tex"
cat ../"3.3. Data analysis.tex" >> "chapter/Methods.tex"

# Create the results chapter
echo "" > "chapter/Results.tex"
cat ../"4.1 Behavioral results.tex" >> "chapter/Results.tex"
cat ../"4.2 Sensor-space activity.tex" >> "chapter/Results.tex"
cat ../"4.3 Source-space activity.tex" >> "chapter/Results.tex"
#cat ../4.4 Source-space interactions" >> "chapter/Results.tex"

# Create the discussion chapter
echo "" > "chapter/Discussion.tex"
cat ../"5. Discussion.tex" >> "chapter/Discussion.tex"

pdflatex dissertation.tex

# Create the bibliography file
bibFiles=`ls ../*.bib`
echo "" > bibliography.bib
bibFiles=`ls ../*.bib`
for bibFile in $bibFiles; do cat ${bibFile} >> bibliography.bib; done
bibtex bibliography.bib
pdflatex dissertation.tex