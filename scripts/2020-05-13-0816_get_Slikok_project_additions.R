## Get new records from Slikok project dataset.

## First load data.
data1 <- assemble_csvs(directory="../data/FWSpecies")
fields_crosswalk <- read.csv("../data/field_name_crosswalk.csv", colClasses="character")
establishmentMeans_crosswalk <- read.csv("../data/establishmentMeans_crosswalk.csv", colClasses="character")
fillin <- read.csv("../data/taxonomy_fill-in.csv", colClasses="character")

## Renaming fields.
for (this_field in 1:nrow(fields_crosswalk))
 {
 sl <- which(names(data1) == fields_crosswalk$FWSpecies_field[this_field])
 names(data1)[sl] <- fields_crosswalk$DwC_field[this_field]
 }
 
## Filling in some missing values.
data1$scientificName[data1$scientificName == ""] <- data1$SciName[data1$scientificName == ""]
 
## Now load Slikok project records.
slikok1 <- read.csv("../data/2020-05-13-0800_Slikok_project_download.csv", colClasses="character")

## Get the list of names from the Slikok project that are not yet in FWSpecies.
fwspecies_names <- levels(as.factor(data1$SciName))

slikok_names <- levels(as.factor(slikok1$SCIENTIFIC_NAME))

new_names <- setdiff(slikok_names, fwspecies_names)

## How many new names?
length(new_names)
[1] 974 ## A lot of these are provisional names, though.

## How many were already known?
length(intersect(slikok_names, fwspecies_names))
[1] 339

## Now pull representative records from the Slikok project.
slikok_new <- slikok1[slikok1$SCIENTIFIC_NAME %in% new_names,]

## Now select representative records.
slikok_selected <- slikok_new[rep(1, length(new_names)),]
for (this_name in 1:length(new_names))
 {
 this_sp_records <- which(slikok_new$SCIENTIFIC_NAME == new_names[this_name])
 print(this_sp_records)
 if(length(this_sp_records)==1)
  {
  selected_record <- this_sp_records
  }
 else
  {
  selected_record <- sample(this_sp_records, 1)
  }
 print(selected_record)
 if (this_name == 1)
  {
  slikok_selected <- slikok_new[selected_record,]
  }
 else
  {
  slikok_selected <- rbind(slikok_selected, slikok_new[selected_record,])
  }
 }

## Now load the file of records to add to FWSpecies so that we can append these new ones.
additions1 <- read.csv("../data/non_FWSpecies_records.csv")

## Modify column names.
names(additions1) <- gsub("\\.", "_", names(additions1))
names(additions1) <- gsub("__", "_", names(additions1))

## Check to see that none of these "new" names were not already among the additions.

add_names <- levels(as.factor(additions1$Scientific_Name))

already_listed_to_add <- intersect(add_names, new_names)

## How many were already on the list?
length(already_listed_to_add)
[1] 19

## Removing these.
slikok_selected <- slikok_selected[!(slikok_selected$SCIENTIFIC_NAME %in% already_listed_to_add),]
dim(slikok_selected)
[1] 955  12

## Adding URLs.
slikok_selected$evidence_URL <- paste0("http://arctos.database.museum/guid/", slikok_selected$GUID)

## appending.
additions_new <- additions1[rep(1,nrow(slikok_selected)),]
additions_new[,] <- NA
additions_new$Scientific_Name <- slikok_selected$SCIENTIFIC_NAME
additions_new$evidence_URL <- slikok_selected$evidence_URL
additions_new$Valid_in_Gbif_refuge_YY_NN_ <- "?Y"
additions1$evidence_URL <- NA
additions2 <- rbind(additions1, additions_new)
dim(additions2)

## Now dropping records that have already been transferred to FWSpecies.
levels(as.factor(additions2$transferred_to_FWSpecies_date))
to_drop <- grepl("2020", additions2$transferred_to_FWSpecies_date)
sum(to_drop)
[1] 190 ## So Jake got 190 records transferred (actually 189. I had transferred one.). He has done some good work.

additions2 <- additions2[!to_drop,]
dim(additions2)
[1] 1325   34

## Ok, overwriting the old addtions file.
write.csv(additions2, "../data/non_FWSpecies_records.csv", row.names=FALSE)
