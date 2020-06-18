## Get a list of species lacking evidence.

## Load functions and libraries.
source("functions.R")

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
 
data1$taxonRank <- tolower(data1$taxonRank)

data1 <- data1[data1$taxonRank == "species",] ## Limiting the list to species only for now.

sl <- data1$source == ""

write.csv(data1[sl,c("SciName", "SpeciesNote")],
 "../data/species_lacking_evidence.csv",
 row.names=FALSE
 )
 
 