
## Generating a checklist document.

dirdata <- "../data/final_data/DwC-A/"
dirdoc <- "../documents/checklist_document/"

library("zip")

simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
      sep="", collapse=" ")
}

print_taxon <- function(outfile, name="", rank="")
 {
 if (name=="")
  {
  name <- "taxon name missing"
  }
 rank <- simpleCap(rank)
 write(paste("###", rank, name, "\n"), file=outfile, append=TRUE)
 }

## First load data.
unzip(paste0(dirdata, "dwca-kenainationalwildliferefuge.zip"), exdir=dirdata)
cl1 <- read.delim(paste0(dirdata, "taxon.txt"))
rf1 <- read.delim(paste0(dirdata, "reference.txt"))

## Sorting.
cl1 <- cl1[order(cl1$kingdom, cl1$phylum, cl1$class, cl1$order, cl1$family, cl1$scientificName),]

outfile <- paste0(dirdoc, "checklist.md")
write("# Kenai National Wildlife Refuge Species List\n", file=outfile, append=FALSE)

write("## Checklist\n", file=outfile, append=TRUE) 

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
  print_taxon(outfile=outfile, name=cl1$phylum[this_record], rank="Phylum")
  plm <- cl1$phylum[this_record]
  }
  
  if (!(cls == cl1$class[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$class[this_record], rank="Class")
  cls <- cl1$class[this_record]
  }
 
  if (!(odr == cl1$order[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$order[this_record], rank="Order")
  odr <- cl1$order[this_record]
  }
  
  if (!(fml == cl1$family[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$family[this_record], rank="Family")
  fml <- cl1$family[this_record]
  }
 
  if (!(gns == cl1$genus[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$genus[this_record], rank="Genus")
  gns <- cl1$genus[this_record]
  }
 
 print_taxon(outfile=outfile, name=cl1$scientificName[this_record], rank="Species")
 
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
    wline <- paste0("<", rfs$source[this_reference], ">, ")
    }
   if (this_reference == nrow(rfs))
    {
    wline <- paste0("<", rfs$source[this_reference], ">.\n")
    }
   write(wline, outfile, append=TRUE)
   }  
  }
 }
 
## Clean up.
unlink(paste0(dirdata, "meta.xml")) 
unlink(paste0(dirdata, "taxon.txt"))
unlink(paste0(dirdata, "distribution.txt"))
unlink(paste0(dirdata, "reference.txt"))
