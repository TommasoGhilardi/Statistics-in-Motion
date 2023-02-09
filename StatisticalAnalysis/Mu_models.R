
####### Libraries ---------------------------------------------------------------

library(lme4)
library(lmerTest)
library(easystats)
library(tidyverse)

library(cowplot)


####### Set and read data ---------------------------------------------------------------

setwd("C:\\Users\\krav\\Desktop\\BabyBrain\\Projects\\EEG_probabilities_infants\\Data\\ProcessedBids\\")

files = list.files(pattern = "*.csv", recursive = TRUE,full.names = FALSE)

df  = map_dfr(files, read_csv,show_col_types = FALSE)

## Select only Mu and Motor area
df = df[df$Frequency=='mu',]
df<- df[ df$Channels != 'O1'& df$Channels != 'O2' & df$Channels != 'Oz',]


# Make Probabilities more understandable
df$Probability = df$Trial
df[df['Probability']==1,'Probability'] = 25
df[df['Probability']==2,'Probability'] = 50
df[df['Probability']==3,'Probability'] = 75
df[df['Probability']==4,'Probability'] = 100

df$Probabilities =  factor(df$Probability) # categorical for anova


####### Run Anova ---------------------------------------------------------------

### The model
Anova_prob.aov<- lmer(Power ~  Probabilities +(1|Id/Channels),data=df)
Anova_prob.aovT<- lmer(Power ~  Probabilities +Training  +(1|Id/Channels),data=df)

### Check if TIME is influential
anova(Anova_prob.aov, Anova_prob.aovT)
test_likelihoodratio(Anova_prob.aov, Anova_prob.aovT)

### Parameters of the model
print_html(parameters(Anova_prob.aov))

### Check assumptions
check_model(Anova_prob.aov)

### Extract anova-like table
anova(Anova_prob.aov)

### Contrast analysis
contrasts = estimate_contrasts(Anova_prob.aov, contrast  = "Probabilities",adjustment= 'holm',
                               pbkrtest.limit = 100000,lmerTest.limit = 100000)
print_html(contrasts)


###  mean estimates
means = estimate_means(Anova_prob.aov,pbkrtest.limit = 3285,lmerTest.limit = 3285)
means$SE_L = means$Mean - means$SE
means$SE_H = means$Mean + means$SE




####### Run Linear Model ---------------------------------------------------------------

### The model
Model  = lmer(Power ~Probability +(1|Id/Channels),data=df) # Basic
ModelT = lmer(Power ~Probability + Training  +(1|Id/Channels),data=df) # With training

### Check Best Model
test_performance(Model, ModelT)
print_html(parameters(Model))

### Check assumptions
check_model(Model)


### Plot
Predicted = estimate_expectation(Model)
Predicted$SE_low = Predicted$Predicted - Predicted$SE
Predicted$SE_high = Predicted$Predicted + Predicted$SE


### Plot Half Violin
df$test = unlist(df['Probability']-3.2)

ggplot(df, aes(x = Probability, y = Power)) +
  geom_violinhalf(aes(fill = Probabilities), color = "white") +
  
  geom_jitter(aes(x=test ,fill = Probabilities), colour='transparent',stroke = 0,shape= 21,width = 3, alpha = 0.6, size=1.8) +
  
  # The model
  geom_ribbon( aes(ymin=Predicted$CI_low, ymax=Predicted$CI_high), linetype=2, alpha=0.2)+
  geom_line(  data = Predicted, aes( x=Probability  ,y=Predicted),size=1.6)+
  
  # Add pointrange
  geom_errorbar(data = means, aes(as.numeric(as.character(Probabilities)),
                                    y = Mean, ymin = CI_low, ymax = CI_high), size = 1.2, color = "white",width=3)+
  geom_pointrange(data = means, aes(as.numeric(as.character(Probabilities)),
  y = Mean, ymin = CI_low, ymax = CI_high), size = 1, color = "white") +
  labs(y = "log(Mu Power)", title = 'Central mu power for the different levels of probability' )+
  scale_x_continuous(labels = c('0 [baseline]' ,'25','50','75','100'), breaks = c(0,25,50,75,100))+
  theme_grey(base_size=20)+theme(legend.position="none",plot.title = element_text(size = 17))
  

ggsave('C:\\Users\\krav\\surfdrive\\Projects\\InfantEEG\\Results\\Mu_HalfViolin.png',device = "png", width = 18, height = 20, units = "cm",dpi=500)

