#!/bin/sh
#assemble and preprocess all the sources files

if [ ! -d "./latex" ]; then
   echo "  creating missing directory latex"
   mkdir ./latex
fi

if [ ! -d "./book" ]; then
   echo "  creating missing directory book"
   mkdir ./book
fi

echo "  Compiling the text file from -> text/pre.txt to latex/pre.tex..."
pandoc text/pre.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to latex > latex/pre.tex

echo "  Compiling the text file from -> text/intro.txt to latex/intro.tex..."
pandoc text/intro.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to latex > latex/intro.tex

for filename in text/ch*.txt; do
      [ -e "$filename" ] || continue
      echo " Converting $filename to latex/$(basename "$filename" .txt).tex"
      pandoc --lua-filter=extras.lua "$filename" --to markdown | pandoc --lua-filter=extras.lua --to markdown | pandoc --lua-filter=epigraph.lua --to markdown | pandoc --lua-filter=figure.lua --to markdown | pandoc --lua-filter=contribution.lua --to markdown | pandoc --filter pandoc-fignos --to markdown | pandoc --metadata-file=meta.yml --top-level-division=chapter --citeproc --bibliography=bibliography/"$(basename "$filename" .txt).bib" --reference-location=section --to latex > latex/"$(basename "$filename" .txt).tex"    
   done

echo " Converting text/epi.txt to latex/epi.tex"
pandoc text/epi.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to latex > latex/epi.tex

for filename in text/apx*.txt; do 
   [ -e "$filename" ] || continue
   echo " Converting $filename to latex/$(basename "$filename" .txt).tex"
   pandoc --lua-filter=extras.lua "$filename" --to markdown | pandoc --lua-filter=extras.lua --to markdown | pandoc --lua-filter=epigraph.lua --to markdown | pandoc --lua-filter=figure.lua --to markdown | pandoc --filter pandoc-fignos --to markdown | pandoc --metadata-file=meta.yml --top-level-division=chapter --citeproc --bibliography=bibliography/"$(basename "$filename" .txt).bib" --reference-location=section --to latex > latex/"$(basename "$filename" .txt).tex"   
done

echo " Commencing the merger of the .tex files. Please wait."
pandoc -s latex/*.tex -o book/book.tex

echo " Starting the creation of the .pdf book from the .tex files."
pandoc -N --quiet --variable "geometry=margin=1.2in" --variable mainfont="MesloLGS NF Regular" --variable sansfont="MesloLGS NF Regular" --variable monofont="MesloLGS NF Regular" --variable fontsize=12pt --variable version=2.0 book/book.tex  --pdf-engine=xelatex --toc -o book/book.pdf

echo " The .tex & .pdf files have been finalized!"

#sed -i '' 's+Figure+Εικόνα+g' ./latex/ch0*
