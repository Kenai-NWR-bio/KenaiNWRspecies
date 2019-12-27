## Work toward generating Darwin Core Archives from FWSpecies checklists.

## Guidance:
## https://github.com/gbif/ipt/wiki/DwCAHowToGuide
## https://github.com/gbif/ipt/wiki/checklistData

## Tools:
## http://tools.gbif.org/dwca-assistant/
## https://tools.gbif.org/dwca-validator/
## https://www.gbif.org/tools/data-validator

## Load functions and libraries.
source("functions.R")
library("zip")

## First load data.
data1 <- assemble_csvs(directory="../data/FWSpecies")
fields_crosswalk <- read.csv("../data/field_name_crosswalk.csv", colClasses="character")
establishmentMeans_crosswalk <- read.csv("../data/establishmentMeans_crosswalk.csv", colClasses="character")

## Renaming fields.
for (this_field in 1:nrow(fields_crosswalk))
 {
 sl <- which(names(data1) == fields_crosswalk$FWSpecies_field[this_field])
 names(data1)[sl] <- fields_crosswalk$DwC_field[this_field]
 }
 
## Trying to make a minimal DwC taxon.txt file.
data1$taxonRank <- tolower(data1$taxonRank)
data1 <- data1[order(
 data1$kingdom,
 data1$phylum,
 data1$class,
 data1$order,
 data1$family,
 data1$scientificName
 ),]
data1 <- data1[data1$taxonRank == "species",] ## Limiting the list to species only for now.
data1$occurrenceStatus <- tolower(data1$occurrenceStatus)
data1 <- data1[data1$occurrenceStatus == "present",] ## Limiting the list to only species that are present.
data1$ID <- data1$taxonID
dwc1 <- data1[,c(
 "ID",
 "taxonID",
 "kingdom",
 "phylum",
 "class",
 "order",
 "family",
 "scientificName",
 "taxonRank"
 )]
write.table(
 dwc1,
 file="../data/DwC-A/taxon.txt",
 quote=FALSE,
 sep = "\t",
 row.names=FALSE
 )
 
## Now generate a distribution file.
dist1 <- data1[,c(
 "ID",
 "locality",
 "occurrenceStatus",
 "Origin",
 "source"
 )]
dist1 <- merge(x=dist1, y=establishmentMeans_crosswalk, by="Origin", all.x=TRUE)
dist1 <- dist1[,c(
 "ID",
 "locality",
 "occurrenceStatus",
 "establishmentMeans",
 "source"
 )]
dist1$countryCode <- "US"

write.table(
 dist1,
 file="../data/DwC-A/distribution.txt",
 quote=FALSE,
 sep = "\t",
 row.names=FALSE
 )


## Now generate a meta.xml file. 
## Header...
xml_file <- "../data/DwC-A/meta.xml"
write('<?xml version="1.0"?>
<archive xmlns="http://rs.tdwg.org/dwc/text/">
\t<core encoding="UTF-8" linesTerminatedBy="\\r\\n" fieldsTerminatedBy="\\t" fieldsEnclosedBy="" ignoreHeaderLines="1" rowType="http://rs.tdwg.org/dwc/terms/Taxon">
\t\t<files>
\t\t\t<location>taxon.txt</location>
\t\t</files>
\t\t<id index="0"/>', xml_file, append=FALSE)
for (this_col in 2:ncol(dwc1))
 {
 write(paste0('\t\t<field index="', this_col-1, '" term="http://rs.tdwg.org/dwc/terms/', names(dwc1)[this_col], '"/>'), xml_file, append=TRUE)
 }
write('\t</core>
</archive>', xml_file, append=TRUE) 
 
zipr(
 zipfile="../data/DwC-A/KenaiNWRspecies_DwC-A.zip",
 files=c(
  "../data/DwC-A/meta.xml", 
  "../data/DwC-A/taxon.txt"
  )
 ) 
