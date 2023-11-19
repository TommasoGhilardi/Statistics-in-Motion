
####### Libraries ---------------------------------------------------------------

library(lme4)
library(lmerTest)
library(easystats)
library(tidyverse)

library(cowplot)
library(ggsignif)

####### Set and read data ---------------------------------------------------------------

setwd("C:\\Users\\tomma\\Desktop\\BabyBrain\\Projects\\EEG_probabilities_infants\\Data\\ProcessedBids\\")

# Find all files and concatenate dataframes
files = list.files(pattern = "*DFmu.csv", recursive = TRUE,full.names = FALSE)
df = map_dfr(files, read_csv,show_col_types = FALSE)

## Create cluster of interest over the motor area
Cluster = c('O1' , 'O2', 'Oz')
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
ggplot(df, aes(x = Probability, y = Power, color = Probabilities))+
  geom_boxplot()+
  facet_wrap(~Channels)


## Geom smooth using linear models
ggplot(df, aes(x = Probability, y = Power, color = Channels))+
  geom_point()+
  geom_smooth(method = 'lm')+
  facet_wrap(~Channels)



#######  Run Anovas ---------------------------------------------------------------


### The model
Anova_prob.aov      =  lmer(Power ~  Probabilities + (1|Id/Channels), data=df)
Anova_prob.Training =  lmer(Power ~  Probabilities + Training  +(1|Id/Channels), data=df)


### Extract anova-like table
anova(Anova_prob.aov)
anova(Anova_prob.Training)

### Check assumptions
check_model(Anova_prob.aov)

### Contrast analysis
contr = estimate_contrasts(Anova_prob.aov ,pbkrtest.limit = 5000)




####### Plot ---------------------------------------------------------------

## Preparations
Means =  as.data.frame(estimate_means(Anova_prob.aov,pbkrtest.limit = 4185))
Means$Probability =  as.numeric(as.character(Means$Probabilities))

con =  as.data.frame(contr) %>%
  mutate(Level1 = str_extract(Level1, "\\d+$"),
  Level2 = str_extract(Level2, "\\d+$"),
  Sign = case_when(p<0.05 & p > 0.01  ~'*',
                   p<0.01 & p > 0.001 ~'**',
                   p<0.001            ~'***'))%>%
  filter(Level1 =='0') %>%
  mutate(Y = c(5.4,4.2,4.6, 5))


## Plot
ggplot(df,aes(x = Probabilities, y = Power, color = Probabilities,fill = Probabilities))+
  geom_violinhalf(color = NA)+
  geom_point(aes(x = Probabilities),
             position = ggpp::position_jitternudge(height = 0, width = 0.115,
                                                   x = -0.14,nudge.from = "jittered"),
             colour='transparent',shape= 21, alpha = 0.6, size=2)+
  geom_boxplot(fill = 'white', color = 'black',outlier.shape = NA,width = 0.05)+
  geom_signif(inherit.aes = F,data = con, manual=T,
              aes(xmin = Level1, xmax = Level2, annotations = Sign, y_position  =Y),
              size=1,textsize = 4.5)+
  labs(y = 'log10(Alpha Power)', x = 'Probability')+
  theme_minimal(base_size = 20)+
  theme(legend.position = 'None')



ggsave('C:\\Users\\tomma\\surfdrive - Ghilardi, T. (Tommaso)@surfdrive.surf.nl\\Projects\\InfantEEG\\Results\\\\OccipitalAnova.png',
       device = "png", width = 22, height = 20, units = "cm",dpi=1000)

