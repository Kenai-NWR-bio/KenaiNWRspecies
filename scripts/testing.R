spp_list <- read.csv("../data/FWSpecies_FullListWithDetails.csv")

source("functions.R")

spp_list_flagged <- flag_spp_intern(spp_list)

head(spp_list_flagged)
## That looked good.