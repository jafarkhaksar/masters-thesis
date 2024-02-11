library(Hmisc)
library(haven)

HIES_row_path <- "/home/jafar/RA/data/HIES/"
HIES_dta_path <- "/home/jafar/RA/data/HIES/dta/"

firstYear <- 84 
lastYear <- 98


for (j in 1:length(firstYear:lastYear)) {
  
  dir.create(paste0(HIES_dta_path, as.character(firstYear-1+j)))
  
  desired_tables <- c(  paste0("R", as.character(first-1+j), "P1"),
                        paste0("U", as.character(first-1+j), "P1"),
                        paste0("R", as.character(first-1+j), "P4S01"),
                        paste0("U", as.character(first-1+j), "P4S01"),
                        paste0("R", as.character(first-1+j), "P4S02"),
                        paste0("U", as.character(first-1+j), "P4S02"))
    
  names(desired_tables) <- c("socio_rural", "socio_urban",
                           "wageIncome_rural", "wageIncome_urban",
                           "selfIncome_rural", "selfIncome_urban")
  
  format <- ifelse(firstYear-1+j==89, ".accdb", ".mdb")
  
  for (i in 1:length(desired_tables)) {

    temp <- mdb.get(file = paste0(HIES_row_path, "Data", as.character(firstYear-1+j), format), tables = desired_tables[i])
    
    write_dta(temp, paste(HIES_dta_path, as.character(firstYear-1+j), "/", names(desired_tables[i]),
                          "_", as.character(firstYear-1+j), ".dta", sep = ""))
  }

}
