#!/bin/sh
#assemble and preprocess all the sources files

if [ ! -d "./latex" ]; then
   echo "  creating missing directory for(latex)"
   mkdir ./latex
fi

if [ ! -d "./book" ]; then
   echo "  creating missing directory for(book)"
   mkdir ./book
fi

echo "  Compiling the text file from -> text/pre.txt to latex/pre.tex..."
pandoc text/pre.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to latex > latex/pre.tex

echo "  Compiling the text file from -> text/intro.txt to latex/intro.tex..."
pandoc text/intro.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to latex > latex/intro.tex

for filename in text/ch*.txt; do
      [ -e "$filename" ] || continue
      echo "  $filename -> latex/$(basename "$filename" .txt).tex..."
      pandoc --lua-filter=extras.lua "$filename" --to markdown | pandoc --lua-filter=extras.lua --to markdown | pandoc --lua-filter=epigraph.lua --to markdown | pandoc --lua-filter=figure.lua --to markdown | pandoc --lua-filter=contribution.lua --to markdown | pandoc --filter pandoc-fignos --to markdown | pandoc --metadata-file=meta.yml --top-level-division=chapter --citeproc --bibliography=bibliography/"$(basename "$filename" .txt).bib" --reference-location=section --to latex > latex/"$(basename "$filename" .txt).tex"    
   done

echo "  text/epi.txt -> latex/epi.tex..."
pandoc text/epi.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to latex > latex/epi.tex

for filename in text/apx*.txt; do 
   [ -e "$filename" ] || continue
   echo "  $filename -> latex/$(basename "$filename" .txt).tex..."
   pandoc --lua-filter=extras.lua "$filename" --to markdown | pandoc --lua-filter=extras.lua --to markdown | pandoc --lua-filter=epigraph.lua --to markdown | pandoc --lua-filter=figure.lua --to markdown | pandoc --filter pandoc-fignos --to markdown | pandoc --metadata-file=meta.yml --top-level-division=chapter --citeproc --bibliography=bibliography/"$(basename "$filename" .txt).bib" --reference-location=section --to latex > latex/"$(basename "$filename" .txt).tex"   
done

echo " Merging the .tex files into a single one. Please standby, it will take a few minutes."
pandoc -s latex/*.tex -o book/book.tex

echo "  Creating the .pdf book from the .tex files. Please wait."
pandoc -N --quiet --variable "geometry=margin=1.2in" --variable mainfont="MesloLGS NF Regular" --variable sansfont="MesloLGS NF Regular" --variable monofont="MesloLGS NF Regular" --variable fontsize=12pt --variable version=2.0 book/book.tex  --pdf-engine=xelatex --toc -o book/book.pdf

echo "  The creation of the .tex & .pdf file has finished!  ;)"

#sed -i '' 's+Figure+Εικόνα+g' ./latex/ch0*
