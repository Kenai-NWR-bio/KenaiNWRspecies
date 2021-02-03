
## Generating a checklist document.

options(encoding="native.enc")

dirdata <- "../data/final_data/DwC-A/"
dirdoc <- "../documents/checklist_document/"

## Load libraries and functions.
library(knitr)
library("zip")
source("functions.R")

simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
      sep="", collapse=" ")
}

print_taxon <- function(outfile,
 name="",
 rank="",
 prefix="######",
 establishmentMeans=""
 )
 {
 if (name=="")
  {
  name <- "taxon name missing"
  }
 rank <- simpleCap(rank)
 write(paste0(prefix, " ", rank, " ", name, "\n"), file=outfile, append=TRUE)
 if (!establishmentMeans=="")
  {
  write(paste0("Establishment means: ", establishmentMeans, "\n"), file=outfile, append=TRUE)
  }
 }

## First load data.
unzip(paste0(dirdata, "dwca-kenainationalwildliferefuge.zip"), exdir=dirdata)
cl1 <- read.delim(paste0(dirdata, "taxon.txt"))
rf1 <- read.delim(paste0(dirdata, "reference.txt"))
ds1 <- read.delim(paste0(dirdata, "distribution.txt"))
cl1 <- merge(cl1, ds1)

## Sorting.
cl1 <- cl1[order(cl1$kingdom, cl1$phylum, cl1$class, cl1$order, cl1$family, cl1$scientificName),]

## Prepare summary data for the document.

nspecies <- sum(cl1$taxonRank=="species")

tblem <- aggregate(cl1$scientificName, by=list(cl1$establishmentMeans), length)
names(tblem) <- c("Establishment means", "Count")


## Now start assembling the document.

options(encoding="utf-8") ## pandoc apparently needs utf-8 input.

outfile <- paste0(dirdoc, "checklist.md")
metafile <- paste0(dirdoc, "checklist.yaml")

title <- paste("Kenai National Wildlife Refuge Species List, version", datestring())
author <- "Kenai National Wildlife Refuge biology staff"

## Start metadata.

write(paste0("---\n"), file=metafile, append=FALSE)
write(paste0("title:
- type: main
  text: ", title, "
creator:
- role: author
  text: ", author, "
  affiliation: USFWS Kenai National Wildlife Refuge
publisher: USFWS Kenai National Wildlife Refuge
rights: CC0
language: en-US
toc-title: 'Contents'
...", "\n"), file=metafile, append=TRUE)

## Start main document.
write(paste0("# ", title, "\n"), file=outfile, append=FALSE)
write(paste0(author, "\n"), file=outfile, append=TRUE)
write(paste0(datetext(), "\n"), file=outfile, append=TRUE)
write("USFWS Kenai National Wildlife Refuge, Soldotna, Alaska\n", file=outfile, append=TRUE)

wline <- '# Introduction

## Purpose

A primary purpose for which the Kenai National Wildlife Refuge was established in the Alaska National Interest Lands Conservation Act of 1980 was, “to conserve fish and wildlife populations and habitats in their natural diversity…,” where the term “fish and wildlife” was defined as “any member of the animal kingdom, including without limitation any mammal, fish, bird…, amphibian, reptile, mollusk, crustacean, arthropod or other invertebrate.”  An obvious first step toward fulfilling this purpose is to know what fish and wildlife, habitats, and natural diversity are to be conserved.  This checklist is intended to be a frequently-updated document reflecting our current knowledge of which living things call the Kenai National Wildlife Refuge home.
'
write(wline, file=outfile, append=TRUE)

wline <- paste0("## About the list

The present list includes a total of ", nspecies, " species, of which ", tblem$Count[tblem[,1]=="native"], " are native, ", tblem$Count[tblem[,1]=="native"], " are exotic, and ", tblem$Count[tblem[,1]=="uncertain"], " is of uncertain origin.

")

write(wline, file=outfile, append=TRUE)

write(kable(tblem, caption="Counts of species by establisment means."), file=outfile, append=TRUE)

write("# Checklist\n", file=outfile, append=TRUE) 

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
  print_taxon(outfile=outfile, name=cl1$kingdom[this_record], rank="Kingdom", prefix="##")
  kdm <- cl1$kingdom[this_record]
  }
 
  if (!(plm == cl1$phylum[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$phylum[this_record], rank="Phylum", prefix="###")
  plm <- cl1$phylum[this_record]
  }
  
  if (!(cls == cl1$class[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$class[this_record], rank="Class", prefix="####")
  cls <- cl1$class[this_record]
  }
 
  if (!(odr == cl1$order[this_record]))
  {
  print_taxon(outfile=outfile, name=cl1$order[this_record], rank="Order", prefix="#####")
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
 
 print_taxon(outfile=outfile, name=cl1$scientificName[this_record], rank="Species", establishmentMeans=cl1$establishmentMeans[this_record])
 
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
