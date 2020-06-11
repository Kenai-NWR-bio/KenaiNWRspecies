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
 write(paste0("\n\\vspace{", vspace, "}\\noindent\\hspace{", hspace, "}", rank, " ", name), file=outfile, append=TRUE)
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
 
  if (!(gns == cl1$genus[this_record]))
  {
  if(!(gns=="NA"))
   {
   write(paste0("\\index{", gns, "@\\textit{", gns, "}|)}\n"), file=outfile, append=TRUE)
   }
  }
 
 if (!(fml == cl1$family[this_record]))
  {
  if(!(fml=="NA"))
   {
   write(paste0("\\index{", fml, "|)}\n"), file=outfile, append=TRUE)
   }
  }
 
 if (!(odr == cl1$order[this_record]))
  {
  if(!(odr=="NA"))
   {
   write(paste0("\\index{", odr, "|)}\n"), file=outfile, append=TRUE)
   }
  }
   
 if (!(cls == cl1$class[this_record]))
  {
  if(!(cls=="NA"))
   {
   write(paste0("\\index{", cls, "|)}\n"), file=outfile, append=TRUE)
   }
  }
 
 if (!(plm == cl1$phylum[this_record]))
  {
  if(!(plm=="NA"))
   {
   write(paste0("\n\\index{", plm, "|)}\n"), file=outfile, append=TRUE)
   }
  }
 
 if (!(kdm == cl1$kingdom[this_record]))
  {
  if(!(kdm=="NA"))
   {
   write(paste0("\\index{", kdm, "|)}\n"), file=outfile, append=TRUE)
   }
  kdm <- cl1$kingdom[this_record] 
  write(paste0("\n\\index{", kdm, "|(}"), file=outfile, append=TRUE) 
  print_taxon(outfile=outfile, name=cl1$kingdom[this_record], rank="Kingdom")
  }
 
 if (!(plm == cl1$phylum[this_record]))
  {
  plm <- cl1$phylum[this_record]
  write(paste0("\n\\index{", plm, "|(}"), file=outfile, append=TRUE) 
  print_taxon(outfile=outfile, name=cl1$phylum[this_record], rank="Phylum",
 hspace="6pt")
  
  }
  
 if (!(cls == cl1$class[this_record]))
  {
  cls <- cl1$class[this_record]
  write(paste0("\n\\index{", cls, "|(}"), file=outfile, append=TRUE)
  print_taxon(outfile=outfile, name=cl1$class[this_record], rank="Class",
 hspace="12pt")
  }
 
 if (!(odr == cl1$order[this_record]))
  {
  odr <- cl1$order[this_record]
  write(paste0("\n\\index{", odr, "|(}"), file=outfile, append=TRUE)
  print_taxon(outfile=outfile, name=cl1$order[this_record], rank="Order",
 hspace="18pt")
  }
  
 if (!(fml == cl1$family[this_record]))
  {
  fml <- cl1$family[this_record]
  write(paste0("\n\\index{", fml, "|(}"), file=outfile, append=TRUE)
  print_taxon(outfile=outfile, name=cl1$family[this_record], rank="Family",
 hspace="24pt")
  }
 
 if (!(gns == cl1$genus[this_record]))
  {
  gns <- cl1$genus[this_record]
  write(paste0("\\index{", gns, "@\\textit{", gns, "}|(}\n"), file=outfile, append=TRUE)
  print_taxon(outfile=outfile, name=paste0("\\textit{", cl1$genus[this_record], "}"), rank="Genus",
 hspace="30pt")
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
write(paste0("\\index{", gns, "@\\textit{", gns, "}|)}\n"), file=outfile, append=TRUE)
write(paste0("\\index{", fml, "|)}"), file=outfile, append=TRUE)
write(paste0("\\index{", odr, "|)}"), file=outfile, append=TRUE)
write(paste0("\\index{", cls, "|)}"), file=outfile, append=TRUE)
write(paste0("\\index{", plm, "|)}"), file=outfile, append=TRUE)
write(paste0("\\index{", kdm, "|)}"), file=outfile, append=TRUE)
 
wline <- "\n\\printindex\n
\\end{multicols}\n\
\\end{document}"
write(wline, outfile, append=TRUE)
 
## Clean up.
unlink("../data/DwC-A/meta.xml") 
unlink("../data/DwC-A/taxon.txt")
unlink("../data/DwC-A/distribution.txt")
unlink("../data/DwC-A/reference.txt")
