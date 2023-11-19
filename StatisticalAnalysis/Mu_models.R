
####### Libraries ---------------------------------------------------------------

library(lme4)
library(lmerTest)
library(easystats)
library(tidyverse)

library(cowplot)
library(brms)

####### Set and read data ---------------------------------------------------------------

setwd("C:\\Users\\tomma\\Desktop\\BabyBrain\\Projects\\EEG_probabilities_infants\\Data\\ProcessedBids\\")

# Find all files and concatenate dataframes
files = list.files(pattern = "*DFmu.csv", recursive = TRUE,full.names = FALSE)
df = map_dfr(files, read_csv,show_col_types = FALSE)

## Create cluster of interest over the motor area
Cluster = c('C3' , 'Cz', 'C4')
df = df[df$Channels %in% Cluster,] # select channels in the cluster

# Make Probabilities more understandable
df$Probability = df$Trial
df[df['Probability']==1,'Probability'] = 25
df[df['Probability']==2,'Probability'] = 50
df[df['Probability']==3,'Probability'] = 75
df[df['Probability']==4,'Probability'] = 100

df$Probabilities =  factor(df$Probability) # categorical for anova


#######  Plot to explroe the data --------------------------------------------------------------------

## Distributions
DistP = ggplot(df, aes(x = Power, color = Probabilities))+
  geom_density()+
  ggtitle("Exploring data distribution over the probability")

DistC = ggplot(df, aes(x = Power, color = Channels))+
  geom_density()+
  ggtitle("Exploring data distribution over the Channels")

plot_grid(DistP, DistC, nrow = 1, align = 'hv')


## Boxplot of the data
one = ggplot(df, aes(x = Probability, y = Power, color = Probabilities))+
  geom_boxplot(linewidth =1)+
  facet_wrap(~Channels)+
  theme_bw(base_size = 20)+
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        legend.position = "none")


## Geom smooth using linear models
two = ggplot(df, aes(x = Probability, y = Power, color = Channels))+
  geom_point()+
  geom_smooth(method = 'lm')+
  facet_wrap(~Channels)+
  scale_fill_brewer(palette="Dark2")+
  scale_color_brewer(palette="Dark2")+
  theme_bw(base_size = 20)+
  theme(legend.position = "none",
        strip.background = element_blank(),
        strip.text.x = element_blank())

plot_grid(one, two, nrow = 2, align = 'hv')
ggsave('C:\\Users\\tomma\\surfdrive - Ghilardi, T. (Tommaso)@surfdrive.surf.nl\\Projects\\InfantEEG\\Results\\Lines.jpg',
       width = 30, height = 40, units = "cm",dpi=1000)


#######  Run Anovas ---------------------------------------------------------------

### The model
Anova_prob.aov      =  lmer(Power ~  Probabilities + (1|Id/Channels), data=df)
Anova_prob.Training =  lmer(Power ~  Probabilities + Training  +(1|Id/Channels), data=df)


### Extract anova-like table
anova(Anova_prob.aov)
anova(Anova_prob.Training)

### Check assumptions
check_model(Anova_prob.aov)



####### Run Linear Model ---------------------------------------------------------------

### The model
Model  = lmer(Power ~Probability +(1|Id/Channels),data=df) # Basic
ModelT = lmer(Power ~Probability + Training  +(1|Id/Channels),data=df) # With training
ModelXT = lmer(Power ~ Probability + trialN + Training  +(1|Id/Channels),data=df,
               control = lmerControl(optimizer ="Nelder_Mead")) # With training

### Check Best Model
test_performance(Model, ModelT,ModelXT)
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
  geom_line(  data = Predicted, aes( x=Probability  ,y=Predicted),linewidth=1.6)+
  
  # Add pointrange
  geom_errorbar(data = means, aes(as.numeric(as.character(Probabilities)),
                                    y = Mean, ymin = CI_low, ymax = CI_high), linewidth = 1.2, color = "white",width=3)+
  geom_point(data = means, aes(as.numeric(as.character(Probabilities)),
  y = Mean), size = 3, color = "white") +
  labs(y = "log(Mu Power)", title = 'Central mu power for the different levels of probability' )+
  scale_x_continuous(labels = c('baseline' ,'25','50','75','100'), breaks = c(0,25,50,75,100))+
  theme_grey(base_size=20)+theme(legend.position="none",plot.title = element_text(size = 17))
  

ggsave('C:\\Users\\krav\\surfdrive\\Projects\\InfantEEG\\Results\\Mu_HalfViolin.png',device = "png", width = 18, height = 20, units = "cm",dpi=500)

