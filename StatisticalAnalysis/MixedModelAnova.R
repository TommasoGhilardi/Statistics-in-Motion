

# Libraries ---------------------------------------------------------------
library(lme4)
library(lmerTest)


# Setting files ---------------------------------------------------------------

Directory = 'C:/Users/krav/Desktop/BabyBrain/Projects/EEG_probabilities_infants/Data/Out'
files = list.files(Directory,recursive = TRUE, full.names = TRUE, pattern = "\\DF.csv$")


DF = read.csv(files[1], header=TRUE, sep=",")


for (file in files[2:length(files)])
{
  db = read.csv(file, header=TRUE, sep=",")
  DF = rbind(DF,db)
}

