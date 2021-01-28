pandoc README.md --filter pandoc-citeproc --toc --toc-depth=3 -o ../../README.md -t gfm -s

pandoc ../../README.md -o ../../README.html

pandoc ../../README.md -t plain -o ../../README.txt

