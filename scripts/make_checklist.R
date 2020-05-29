## Generating a checklist document.

library("zip")

## First load data.
unzip("../data/DwC-A/dwca-kenainationalwildliferefuge.zip", exdir = "../data/DwC-A")

cl1 <- read.delim("../data/DwC-A/taxon.txt")
## Sorting.
cl1 <- cl1[order(cl1$kingdom, cl1$phylum, cl1$class, cl1$order, cl1$family, cl1$scientificName),]

outfile <- "../text/checklist.md"
write("# Kenai National Wildlife Refuge Species List\n", file=outfile, append=FALSE)

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
 write(paste(rank, name, "\n"), file=outfile, append=TRUE)
 }

kdm <- "NA"
plm <- "NA"
cls <- "NA"
odr <- "NA"
fml <- "NA"
gns <- "NA" 
 
for (this_record in 1:nrow(cl1))
 {
 
 if (!(kdm == cl1$kingdom[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$kingdom[this_record], rank="## Kingdom")
  kdm <- cl1$kingdom[this_record]
  }
 
  if (!(plm == cl1$phylum[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$phylum[this_record], rank="### Phylum")
  plm <- cl1$phylum[this_record]
  }
  
  if (!(cls == cl1$class[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$class[this_record], rank="#### Class")
  cls <- cl1$class[this_record]
  }
 
  if (!(odr == cl1$order[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$order[this_record], rank="##### Order")
  odr <- cl1$order[this_record]
  }
  
  if (!(fml == cl1$family[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$family[this_record], rank="###### Family")
  fml <- cl1$family[this_record]
  }
 
  if (!(gns == cl1$genus[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$genus[this_record], rank="Genus")
  gns <- cl1$genus[this_record]
  }
 
 print_taxon(outfile=outfile, name=cl1$scientificName[this_record], rank="Species")
 }

## Clean up.
unlink("../data/DwC-A/meta.xml") 
unlink("../data/DwC-A/taxon.txt")
unlink("../data/DwC-A/distribution.txt")
unlink("../data/DwC-A/reference.txt")
