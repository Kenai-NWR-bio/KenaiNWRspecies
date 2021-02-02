## Assemble all identically formatted csv data from a directory.
assemble_csvs <- function(directory="../data/FWSpecies")
 {
 file_list <- dir(directory)
 for (this_file in 1:length(file_list))
  {
  temp_data <- read.csv(paste0(directory, "/", file_list[this_file]), colClasses="character")
  if (this_file == 1)
   {
   comp_data <- temp_data
   }
  if (this_file > 1)
   {
   comp_data <- rbind(comp_data, temp_data)
   }
  }
 comp_data
 }

## Convert current time to ISO time format. 
nowstring <- function()
 {
 format(Sys.time(), format="%Y-%m-%dT%H%M")
 }
 
## Convert current date to ISO time format. 
datestring <- function()
 {
 format(Sys.time(), format="%Y-%m-%d")
 }

## Convert current date to format for title page.
datetext <- function()
 {
 format(Sys.time(), format="%B %e, %Y")
 }
 
 