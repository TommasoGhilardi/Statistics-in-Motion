

# Libraries ---------------------------------------------------------------
library(brms)
library(fitdistrplus)
library(ggplot2)
library(performance)
library(modelbased)
library(bayestestR)
library(report)


Palette1 = c("#3f6d9b", "#6e8dab", "#cccccc")
Palette2<- c("#a00000","#dc2c25","#f35c40")

My_Theme = theme(
  panel.background = element_rect(fill = 'white', colour = 'black'),
  axis.title.x = element_text(size = 20,face = "bold"),
  axis.text.x = element_text(size = 18, color= "black"),
  axis.text.y = element_text(size = 18, color= "black"),
  axis.title.y = element_text(size = 20, face = "bold"),
  legend.text = element_text(size = 20),
  legend.title = element_text(size = 20, face = "bold"))

# Setting files ---------------------------------------------------------------

Directory = 'C:\\Users\\krav\\surfdrive\\Monique_Infant_EEG\\Processed\\'
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


LmMotor = brm(Power ~ Trial  + (1|Id/Channels), data= Motor,family = poisson())
check_model(LmMotor)

summary(LmMotor)




estimate_contrasts(fit1,levels = 'Trt')





