## Work toward generating Darwin Core Archives from FWSpecies checklists.
## Load functions and libraries.
source("functions.R")
library("zip")

## First load data.
data1 <- assemble_csvs(directory="../data/FWSpecies")
fields_crosswalk <- read.csv("../data/field_name_crosswalk.csv", colClasses="character")

## Renaming fields.
for (this_field in 1:nrow(fields_crosswalk))
 {
 sl <- which(names(data1) == fields_crosswalk$FWSpecies_field[this_field])
 names(data1)[sl] <- fields_crosswalk$DwC_field[this_field]
 }

## Trying to make a minimal DwC taxon.txt file.
data1 <- data1[order(data1$kingdom, data1$scientificName),]
data1$ID <- data1$taxonID
dwc1 <- data1[,c("ID", "taxonID", "scientificName", "taxonRank", "kingdom")]
write.table(
 dwc1,
 file="../data/DwC-A/taxon.txt",
 quote=FALSE,
 sep = "\t",
 row.names=FALSE
 )
 
zipr(
 zipfile="../data/DwC-A/KenaiNWRspecies_DwC-A.zip",
 files=c(
  "../data/DwC-A/meta.xml", 
  "../data/DwC-A/taxon.txt"
  )
 ) 
