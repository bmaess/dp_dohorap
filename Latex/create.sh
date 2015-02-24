pdflatex dissertation.tex
bibFiles=`ls chapter/*.bib`
" " > bibliography.bib
for bibFile in $bibFiles; do
	cat chapter/bibFile >> bibliography.bib
done
bibtex bibliography.bib
pdflatex dissertation.tex