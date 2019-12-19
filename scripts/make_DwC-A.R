## Work toward generating Darwin Core Archives from FWSpecies checklists.
## Load functions.
source("functions.R")
library("zip")

## First load data.
data1 <- assemble_csvs(directory="../data/FWSpecies")
categories_kingdoms <- read.csv("../data/CategoryGroup_kingdom_crosswalk.csv", colClasses="character")
fields_crosswalk <- read.csv("../data/field_name_crosswalk.csv", colClasses="character")

## Renaming fields.
for (this_field in 1:nrow(fields_crosswalk))
 {
 sl <- which(names(data1) == fields_crosswalk$FWSpecies_field[this_field])
 names(data1)[sl] <- fields_crosswalk$DwC_field[this_field]
 }

## Add kingdoms
data2 <- merge(
 x=data1,
 y=categories_kingdoms,
 by="TaxonCategoryGroup",
 all.x=TRUE
 )
 
## Phyla and classes are still missing.

## Trying to make a minimal DwC taxon.txt file.
data2 <- data2[order(data2$kingdom, data2$scientificName),]
data2$ID <- data2$taxonID
dwc1 <- data2[,c("ID", "taxonID", "scientificName", "taxonRank", "kingdom")]
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
