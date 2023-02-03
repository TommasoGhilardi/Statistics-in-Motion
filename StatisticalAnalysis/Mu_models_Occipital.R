
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
df<- df[ df$Channels != 'C3'& df$Channels != 'C4' & df$Channels != 'Cz',]


# Make Probabilities more understandable
df$Probability = df$Trial
df[df['Probability']==1,'Probability'] = 25
df[df['Probability']==2,'Probability'] = 50
df[df['Probability']==3,'Probability'] = 75
df[df['Probability']==4,'Probability'] = 100

df$ Probabilities =  factor(df$Probability) # categorical for anova


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
Anova = anova(Anova_prob.aov)
Anova

### Contrast analysis
contrasts = estimate_contrasts(Anova_prob.aov, contrast  = "Probabilities",adjustment= 'holm',
                               pbkrtest.limit = 100000,lmerTest.limit = 1000000)

print_html(contrasts)



####### Plot ---------------------------------------------------------------

### Plot half Violin
df$test = unlist(df['Probability']-3.2)

ggplot(df, aes(x = Probability, y = Power)) +
  geom_violinhalf(aes(fill = Probabilities), color = "white") +
  
  geom_jitter(aes(x=test ,fill = Probabilities), colour='transparent',stroke = 0,shape= 21,width = 3, alpha = 0.6, size=1.8) +
  geom_boxplot(aes(x= Probability, group= Probability), width=2,outlier.shape = NA)+
  labs(y = "log(Mu Power)", title = 'Occipital mu power for the different levels of probability' )+
  scale_x_continuous(breaks = c(0,25,50,75,100))+
  theme_grey(base_size=20)+theme(legend.position="none",plot.title = element_text(size = 17))


ggsave('C:\\Users\\krav\\surfdrive\\Projects\\InfantEEG\\Results\\OccipitalAnova.png',device = "png", width = 18, height = 20, units = "cm",dpi=500)
















































####### Run Linear Model ---------------------------------------------------------------

### The model
Model  = lmer(Power ~Probability +(1|Id/Channels),data=df) # Basic
ModelT = lmer(Power ~Probability + Training  +(1|Id/Channels),data=df) # With training
ModelQ = lmer(Power ~ poly(Probability, 2, raw = TRUE) +(1|Id/Channels),data=df)

test_performance(Model, ModelT,ModelQ)

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
  
  geom_jitter2(aes(x=test ,fill = Probabilities),shape= 21,width = 3, alpha = 0.6) +
  
  # The model
  geom_ribbon(data = Predicted, aes(x=Probability,ymin=CI_low, ymax=CI_high), linetype=2, alpha=0.2,inherit.aes = F)+
  geom_line(data = Predicted,aes( x=Probability  ,y=Predicted),size=1.6,inherit.aes = F)+
  
  # Add pointrange 
  geom_point( data = means, aes(x= as.numeric(as.character(Probabilities)),y = Mean), size =6, color = "white",inherit.aes = F ) +
  geom_linerange( data = means, aes(x= as.numeric(as.character(Probabilities)),y = Mean, ymin = CI_low, ymax = CI_high),
                  linewidth =2, color = "white",inherit.aes = F ) +
  
  
   scale_x_continuous( breaks = seq(-25, 100, by = 25))+ ylab("log(Mu Power)")+
  theme(panel.grid.minor = element_line(size = 1), panel.grid.major = element_line(size = 1))
ggsave('C:\\Users\\krav\\surfdrive\\Projects\\InfantEEG\\Results\\OccipitalHalfViolin.png',device = "png", width = 18, height = 20, units = "cm",dpi=500)


### Plot entire violin
ggplot(df, aes(x = Probability, y = Power)) +
  geom_violin(aes(fill = Probabilities), color = "white") +
  geom_jitter2(aes(x=Probability ,fill = Probabilities,color = Probabilities),width = 10, alpha = 0.5) +
  
  # The model
  geom_ribbon(data = Predicted, aes(x=Probability,ymin=CI_low, ymax=CI_high), linetype=2, alpha=0.2,inherit.aes = F)+
  geom_line(data = Predicted,aes( x=Probability  ,y=Predicted),size=1.6,inherit.aes = F)+
  
  # Add pointrange
  geom_point( data = means, aes(x= as.numeric(as.character(Probabilities)),y = Mean), size =6, color = "white",inherit.aes = F ) +
  geom_linerange( data = means, aes(x= as.numeric(as.character(Probabilities)),y = Mean, ymin = CI_low, ymax = CI_high),
                  linewidth =2, color = "white",inherit.aes = F ) +
  
  
  scale_x_continuous( breaks = seq(-25, 100, by = 25))+ ylab("log(Mu Power)")+
  theme(panel.grid.minor = element_line(size = 1), panel.grid.major = element_line(size = 1))


ggsave('C:\\Users\\krav\\surfdrive\\Projects\\InfantEEG\\Results\\OccipitalWholeViolin.png',device = "png", width = 20, height = 20, units = "cm",dpi=500)


#### Plot Smaller
ggplot(means, aes(x =  as.numeric(as.character(Probabilities)), y = Mean)) +
  # The model
  geom_ribbon(data = Predicted, aes(x=Probability  ,y=Predicted, ymin=CI_low, ymax=CI_high), linetype=2, alpha=0.2)+
  geom_line(data = Predicted, aes(x=Probability  ,y=Predicted), size=1.6,color = '#878787')+
  
  #geom_line(aes(group = 1),size=1.2, alpha=0.4) +
  geom_point(aes(colour =  Probabilities),size=6)+
  geom_errorbar(aes( colour= Probabilities, ymin = CI_low, ymax = CI_high),width = 4,size = 1.5)+
  ggtitle('Estimated Means')+ ylab("Power")+ ylim(0.25,0.75)+ylab("log(Mu Power)")+
  theme(legend.position="none",panel.grid.minor = element_line(size = 1), panel.grid.major = element_line(size = 1))

ggsave('C:\\Users\\krav\\surfdrive\\Projects\\InfantEEG\\Results\\OccipitalZoomed.png',device = "png", width = 15, height = 20, units = "cm",dpi=500)



