## Generating a checklist document.

library("zip")

simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
      sep="", collapse=" ")
}

italicize_sp <- function(x)
 {
 s <- strsplit(x, " ")[[1]]
 formatted_name <- paste0("\\textit{", s[1], " ", s[2], "}")
 if (length(s)>2)
  {
  formatted_name <- paste(formatted_name, paste(s[3:length(s)], collapse=" "))
  }
 formatted_name
 }

print_taxon <- function(outfile,
 name="",
 rank="",
 hspace="0pt",
 vspace="6pt",
 vernacularName=""
 )
 {
 if (name=="")
  {
  name <- "taxon name missing"
  }
 rank <- simpleCap(rank)
 write(paste0("\\vspace{", vspace, "}\\noindent\\hspace{", hspace, "}", rank, " ", name, "\n\n"), file=outfile, append=TRUE)
 if(!vernacularName=="")
  {
  write(
   paste0("Common name: ", vernacularName, "\n"),
   file=outfile,
   append=TRUE
   )
  }
 }

## First load data.
unzip("../data/DwC-A/dwca-kenainationalwildliferefuge.zip", exdir = "../data/DwC-A")
cl1 <- read.delim("../data/DwC-A/taxon.txt", stringsAsFactors=FALSE)
rf1 <- read.delim("../data/DwC-A/reference.txt", stringsAsFactors=FALSE)

## Filtering problematic characters for TeX.
cl1$scientificName <- gsub("&", "\\\\&", cl1$scientificName)

## Sorting.
cl1 <- cl1[order(cl1$kingdom, cl1$phylum, cl1$class, cl1$order, cl1$family, cl1$scientificName),]

outfile <- "../text/checklist.tex"
write("\\documentclass[9pt, article]{memoir}\n
\\input{checklist_style}
\\title{Kenai National Wildlife Refuge Species List}\n
\\begin{document}\n
\\maketitle\n", file=outfile, append=FALSE)

write("\\chapter{Checklist}\n
\\begin{multicols}{2}\n", file=outfile, append=TRUE) 

kdm <- "NA"
plm <- "NA"
cls <- "NA"
odr <- "NA"
fml <- "NA"
gns <- "NA" 
 
for (this_record in 1:nrow(cl1)) #nrow(cl1)
 {
 
 if (!(kdm == cl1$kingdom[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$kingdom[this_record], rank="Kingdom")
  kdm <- cl1$kingdom[this_record]
  }
 
  if (!(plm == cl1$phylum[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$phylum[this_record], rank="Phylum",
 hspace="6pt")
  plm <- cl1$phylum[this_record]
  }
  
  if (!(cls == cl1$class[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$class[this_record], rank="Class",
 hspace="12pt")
  cls <- cl1$class[this_record]
  }
 
  if (!(odr == cl1$order[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$order[this_record], rank="Order",
 hspace="18pt")
  odr <- cl1$order[this_record]
  }
  
  if (!(fml == cl1$family[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$family[this_record], rank="Family",
 hspace="24pt")
  fml <- cl1$family[this_record]
  }
 
  if (!(gns == cl1$genus[this_record]))
  {
  print_taxon(outfile=outfile, name=paste0("\\textit{", cl1$genus[this_record], "}"), rank="Genus",
 hspace="30pt")
  gns <- cl1$genus[this_record]
  }
 
 print_taxon(
  outfile=outfile,
  name=italicize_sp(as.character(cl1$scientificName[this_record])),
  rank="Species",
  hspace="36pt",
  vernacularName=cl1$vernacularName[this_record],
  )
 
 ## If there are any references, print them.
 rfs <- rf1[rf1$ID==cl1$ID[this_record],]
 if (nrow(rfs) == 0)
  {
  }
 if (nrow(rfs) > 0)
  {
  if (nrow(rfs) == 1)
   {
   write("Reference: ", outfile, append=TRUE)
   }
  if (nrow(rfs) > 1)
   {
   write("References: ", outfile, append=TRUE)
   }
  for (this_reference in 1:nrow(rfs))
   {
   if (this_reference < nrow(rfs))
    {
    wline <- paste0("\\url{", rfs$source[this_reference], "}, ")
    }
   if (this_reference == nrow(rfs))
    {
    wline <- paste0("\\url{", rfs$source[this_reference], "}.\n")
    }
   write(wline, outfile, append=TRUE)
   }  
  }
 }
 
wline <- "\\end{multicols}\n\
\\end{document}"
write(wline, outfile, append=TRUE)
 
## Clean up.
unlink("../data/DwC-A/meta.xml") 
unlink("../data/DwC-A/taxon.txt")
unlink("../data/DwC-A/distribution.txt")
unlink("../data/DwC-A/reference.txt")
