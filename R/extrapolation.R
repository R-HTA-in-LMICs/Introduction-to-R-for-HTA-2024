# Load libraries ----------------------------------------------------------
## names of required packages for analysis:
pkgs <- c("tidyverse", "survival", "survminer", "flexsurv", "gtsummary", 
          "eeptools", "muhaz")
## install packages not yet installed:
installed_packages <- pkgs %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(pkgs[!installed_packages])
}
## loop through packages list by applying lapply function and load packages 
invisible(lapply(pkgs, library, character.only = TRUE))

# Source ------------------------------------------------------------------
## call cleaned data objects from data transformation script
#source()