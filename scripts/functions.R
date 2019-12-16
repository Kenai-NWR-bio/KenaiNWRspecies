## Until the feature adding taxonomic ranks to FWSpecies output is added, we will need to be able to assign these, either from the data or by using an external source to check the names.
flag_spp_intern <- function(spp_list, names_field="Scientific.Name")
 {
 spp_col <- which(names(spp_list) == names_field)
 sl <- grepl(" ", spp_list[,spp_col])
 sn <- strsplit(as.character(spp_list[,spp_col]), " ")
 n1 <- sapply(sn, "[", 1)
 n2 <- sapply(sn, "[", 2)
 spp_list$Scientific.Name.filtered <- n1
 spp_list$Scientific.Name.filtered[sl] <- paste(n1[sl], n2[sl])
 spp_list$rank <- "unassigned"
 spp_list$rank[sl] <- "species"
 spp_list
 }
