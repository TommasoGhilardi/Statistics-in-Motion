

# Libraries ---------------------------------------------------------------
library(lme4)
library(lmerTest)
library(fitdistrplus)
library(ggplot2)
library(performance)
library(modelbased)
library(report)

options(contrasts = c("contr.sum","contr.poly"))

# Theme ---------------------------------------------------------------

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

Directory = 'C:\\Users\\krav\\surfdrive\\Jule_Infant_EEG\\Processed\\'
files = list.files(Directory,recursive = TRUE, full.names = TRUE, pattern = "\\DF.csv$")


## Concatenate files
DF = read.csv(files[1], header=TRUE, sep=",")

for (file in files[2:length(files)])
{
  db = read.csv(file, header=TRUE, sep=",")
  DF = rbind(DF,db)
}

DF = DF[(DF$Frequency=='beta'),]


## Setting factors
DF$Id        = factor(DF$Id) 
DF$Channels  = factor(DF$Channels)
DF$Trial     = factor(DF$Trial)
DF$Frequency = factor(DF$Frequency)

## Remove Nan rows
DF = DF[complete.cases(DF), ]

## Reduce dimension of training
DF$Training = as.numeric(format(round(DF$Training, 2), nsmall = 2))

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
Motor$Training = scale(Motor$Training,scale=FALSE)


LmMotor = lmer(Power ~ Trial + scale(Training,scale=FALSE)   + (1|Id/Channels), data= Motor)
check_model(LmMotor)

summary(LmMotor)

## Check main effects as anova
AnMotor = anova(LmMotor)
AnMotor

# Contrast
estimate_contrasts(LmMotor)

report(LmMotor)
report(AnMotor)

#### Plot
Anova_motor <- ggplot(Motor, aes(Trial, Power)) +
  stat_summary(fun = mean, geom = "bar",colour='black' ,fill = Palette1[1],width=0.5, alpha =seq(0.4, 1, by=0.15))+
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2)+
  labs(title="Probability - Motor Area",x="\nProbability",y="Beta log(Power)\n")+
  geom_hline(yintercept=0)+
  My_Theme + theme(legend.position = "none")+
  scale_x_discrete(labels=c("Baseline","25%","50%","75%","100%"))
Anova_motor

ggsave(paste(Directory,"Anova_Probability_motor_Beta.png",sep=''),
       width = 28, height = 28, units = "cm", dpi="retina")



# Motor Analysis continuos ---------------------------------------------------------------

MotorCon = DF[(DF$Channels == 'C3' | DF$Channels == 'Cz' | DF$Channels == 'C4' & DF$Trial != 0),]
MotorCon = Motor[Motor$Trial != 0,]

MotorCon$Trial = as.numeric(MotorCon$Trial)
MotorCon$Trial = scale(MotorCon$Trial, center = TRUE, scale = FALSE)
MotorCon$Training = scale(MotorCon$Training,scale=FALSE)

LmMotorCon = lmer(Power ~ Trial + Training   + (1|Id/Channels), data= MotorCon)
check_model(LmMotorCon)

summary(LmMotorCon)
