## Work toward generating Darwin Core Archives from FWSpecies checklists.

## Guidance:
## https://github.com/gbif/ipt/wiki/DwCAHowToGuide
## https://github.com/gbif/ipt/wiki/checklistData
## https://tools.gbif.org/dwca-validator/extension.do?id=gbif:Distribution

## Tools:
## http://tools.gbif.org/dwca-assistant/
## https://tools.gbif.org/dwca-validator/
## https://www.gbif.org/tools/data-validator

## Load functions and libraries.
source("functions.R")
library("zip")
library("reshape2")

## First load data.
data1 <- assemble_csvs(directory="../data/FWSpecies")
fields_crosswalk <- read.csv("../data/field_name_crosswalk.csv", colClasses="character")
establishmentMeans_crosswalk <- read.csv("../data/establishmentMeans_crosswalk.csv", colClasses="character")
fillin <- read.csv("../data/taxonomy_fill-ins.csv", colClasses="character")

## Renaming fields.
for (this_field in 1:nrow(fields_crosswalk))
 {
 sl <- which(names(data1) == fields_crosswalk$FWSpecies_field[this_field])
 names(data1)[sl] <- fields_crosswalk$DwC_field[this_field]
 }
 
## Filling in some missing values.
data1$scientificName[data1$scientificName == ""] <- data1$SciName[data1$scientificName == ""]
 
## Trying to make a minimal DwC taxon.txt file.
data1$taxonRank <- tolower(data1$taxonRank)

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
 "genus",
 "scientificName",
 "taxonRank",
 "vernacularName"
 )] 

## Now replacing problematic records.
dwc1 <- dwc1[!(dwc1$ID %in% fillin$ID),] 
dwc1 <- rbind(dwc1, fillin)
dwc1 <- dwc1[order(
 dwc1$kingdom,
 dwc1$phylum,
 dwc1$class,
 dwc1$order,
 dwc1$family,
 dwc1$scientificName
 ),]
 
write.table(
 dwc1,
 file="../data/DwC-A/taxon.txt",
 quote=FALSE,
 sep = "\t",
 row.names=FALSE
 )
 
## Generate a distribution file.
dist1 <- data1[,c(
 "ID",
 "locality",
 "occurrenceStatus",
 "Origin"
 )]
dist1 <- merge(x=dist1, y=establishmentMeans_crosswalk, by="Origin", all.x=TRUE)
dist2 <- dist1[,c(
 "ID",
 "locality",
 "occurrenceStatus",
 "establishmentMeans"
 )]
## Add country and area code.
dist2$countryCode <- "US"
dist2$locationID <- "GADM:Kenai Peninsula" ## Kenai National Wildlife Refuge is not available in any of the listed coding schemes  at http://rs.gbif.org/areas/
write.table(
 dist2,
 file="../data/DwC-A/distribution.txt",
 quote=FALSE,
 sep = "\t",
 row.names=FALSE
 )

## Generate a literature references file.
ref1 <- data1[,c(
 "ID",
 "source"
 )]
sources <- strsplit(ref1$source, ", ")
sources <- melt(sources)
names(sources) <- c("source", "ID")
sources$ID <- ref1$ID[sources$ID]
ref2 <- sources[,c("ID", "source")]
write.table(
 ref2,
 file="../data/DwC-A/reference.txt",
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
\t<extension encoding="UTF-8" linesTerminatedBy="\\r\\n" fieldsTerminatedBy="\\t" fieldsEnclosedBy="" ignoreHeaderLines="1" rowType="http://rs.gbif.org/terms/1.0/Distribution">
\t\t<files>
\t\t\t<location>distribution.txt</location>
\t\t</files>
\t\t<coreid index="0"/>', xml_file, append=TRUE)
for (this_col in 2:ncol(dist2))
 {
 write(paste0('\t\t<field index="', this_col-1, '" term="http://rs.tdwg.org/dwc/terms/', names(dist2)[this_col], '"/>'), xml_file, append=TRUE)
 }
write('\t</extension>
\t<extension encoding="UTF-8" linesTerminatedBy="\\r\\n" fieldsTerminatedBy="\\t" fieldsEnclosedBy="" ignoreHeaderLines="1" rowType="http://rs.gbif.org/terms/1.0/Reference">
\t\t<files>
\t\t\t<location>reference.txt</location>
\t\t</files>
\t\t<coreid index="0"/>', xml_file, append=TRUE)
for (this_col in 2:ncol(ref2))
 {
 if (names(ref2)[this_col] == "source")
  {
  write(paste0('\t\t<field index="', this_col-1, '" term="http://purl.org/dc/terms/', names(ref2)[this_col], '"/>'), xml_file, append=TRUE)
  }
 else
  {
  write(paste0('\t\t<field index="', this_col-1, '" term="http://rs.tdwg.org/dwc/terms/', names(ref2)[this_col], '"/>'), xml_file, append=TRUE)
  }
 }
write('\t</extension> 
</archive>', xml_file, append=TRUE) 
 
zipr(
 zipfile="../data/DwC-A/dwca-kenainationalwildliferefuge.zip",
 files=c(
  "../data/DwC-A/meta.xml", 
  "../data/DwC-A/taxon.txt",
  "../data/DwC-A/distribution.txt",
  "../data/DwC-A/reference.txt"
  )
 ) 
 
## Clean up.
unlink("../data/DwC-A/meta.xml") 
unlink("../data/DwC-A/taxon.txt")
unlink("../data/DwC-A/distribution.txt")
unlink("../data/DwC-A/reference.txt")
