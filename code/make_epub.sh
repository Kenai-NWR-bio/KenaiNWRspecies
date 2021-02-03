
## Convert to epub.
pandoc ../documents/checklist_document/checklist.md --metadata-file=../documents/checklist_document/checklist.yaml --css ../documents/checklist_document/style.css --filter pandoc-citeproc --toc --toc-depth=2 -o ../documents/checklist_document/checklist.epub
