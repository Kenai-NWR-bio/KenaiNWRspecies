
## Convert to epub.
pandoc ../documents/checklist_document/checklist.md --metadata-file=../documents/checklist_document/checklist.yaml --css ../documents/checklist_document/style.css --filter pandoc-citeproc --toc --toc-depth=2 -o ../documents/checklist_document/checklist.epub

## Generate html.
pandoc ../documents/checklist_document/checklist.md --metadata-file=../documents/checklist_document/checklist.yaml --css ../documents/checklist_document/style.css --filter pandoc-citeproc --toc --toc-depth=2 -o ../documents/checklist_document/checklist.html

## Generate simple text.
pandoc ../documents/checklist_document/checklist.md --metadata-file=../documents/checklist_document/checklist.yaml --css ../documents/checklist_document/style.css --filter pandoc-citeproc --toc --toc-depth=2 -t plain -o ../documents/checklist_document/checklist.txt

## Generate tex.
pandoc ../documents/checklist_document/checklist.md --metadata-file=../documents/checklist_document/checklist.yaml --filter pandoc-citeproc --toc --toc-depth=2 --pdf-engine=xelatex -o ../documents/checklist_document/checklist.pdf
