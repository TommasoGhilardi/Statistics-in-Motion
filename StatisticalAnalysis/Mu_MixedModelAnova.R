

# Libraries ---------------------------------------------------------------
library(lme4)
library(lmerTest)
library(fitdistrplus)
library(ggplot2)
library(performance)
library(modelbased)
library(report)

# Setting files ---------------------------------------------------------------

Directory = 'C:/Users/krav/Desktop/BabyBrain/Projects/EEG_probabilities_infants/Data/Out'
files = list.files(Directory,recursive = TRUE, full.names = TRUE, pattern = "\\DF.csv$")


## Concatenate files
DF = read.csv(files[1], header=TRUE, sep=",")

for (file in files[2:length(files)])
{
  db = read.csv(file, header=TRUE, sep=",")
  DF = rbind(DF,db)
}

## Setting factors
DF$Id        = factor(DF$Id) 
DF$Channels  = factor(DF$Channels)
DF$Trial     = factor(DF$Trial)

## Remove Nan rows
DF = DF[complete.cases(DF), ]

## Subjects to remove
remove = c() #write here the strings of subjects to remove
DF = DF[!is.element(DF$Id, remove),]


summary(DF)


# Checking the distribution of the data ---------------------------------------------------------------

## Histogram overlaid with kernel density curve
ggplot(DF, aes(x=Power)) + 
  geom_histogram(aes(y=..density..),      # Histogram with density instead of count on y-axis
                 binwidth=.5,
                 colour="black", fill="white") +
  geom_density(alpha=.2, fill="#FF6666")  # Overlay with transparent density plot


## Distribution exploration
descdist(DF$Power, discrete=FALSE, boot=1000)
plot(fitdist(DF$Power, "norm"))


# Motor Analysis ---------------------------------------------------------------

Motor = DF[(DF$Channels == 'C3' | DF$Channels == 'Cz' | DF$Channels == 'C4'),]


LmMotor = lmer(Power ~ Trial  + (1|Id/Channels), data= Motor)
check_model(LmMotor)

summary(LmMotor)

## Check main effects as anova
AnMotor = anova(LmMotor)

## Check contrasts
estimate_contrasts(LmMotor)

report(LmMotor)
report(AnMotor)

# Visual Analysis ---------------------------------------------------------------

Visual = DF[(DF$Channels != 'C3' | DF$Channels != 'Cz' | DF$Channels != 'C4'),]


LmVisual = lmer(Power ~ Trial  + (1|Id/Channels), data= Visual)
check_model(LmVisual)

## Check main effects as anova
AnVisual = anova(LmVisual)

## Check contrasts
estimate_contrasts(LmVisual)


report(LmVisual)
report(AnVisual)









