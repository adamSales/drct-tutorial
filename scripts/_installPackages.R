## run this at the beginning, let it run while we're blabbering on, save time later:

needed.packages <- c("dplyr", "tidyr", "devtools","randomForest","optmatch",
                     "kableExtra","SuperLearner")

new.packages <- needed.packages[!(needed.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

devtools::install_github("manncz/dRCT")
