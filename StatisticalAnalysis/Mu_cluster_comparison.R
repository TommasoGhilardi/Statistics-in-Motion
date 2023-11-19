
####### Libraries ---------------------------------------------------------------

library(lme4)
library(lmerTest)
library(easystats)
library(tidyverse)


####### Set and read data ---------------------------------------------------------------

setwd("C:\\Users\\tomma\\Desktop\\BabyBrain\\Projects\\EEG_probabilities_infants\\Data\\ProcessedBids\\")

files = list.files(pattern = "*DFmu.csv", recursive = TRUE,full.names = FALSE)

df  = map_dfr(files, read_csv,show_col_types = FALSE)


# Make Probabilities more understandable
df$Probability = df$Trial
df[df['Probability']==1,'Probability'] = 25
df[df['Probability']==2,'Probability'] = 50
df[df['Probability']==3,'Probability'] = 75
df[df['Probability']==4,'Probability'] = 100

df$Probability =  factor(df$Probability) # categorical for anova


####### Multiple clusters ---------------------------------------------------------------

## Clusters
Cluster.s = c('C3' , 'Cz', 'C4')
Cluster.c = c('FC1' , 'CP1', 'Cz', 'FC2', 'CP2')
Cluster.l = c('FC1' , 'CP1', 'C3', 'FC5', 'CP5')
Cluster.r = c('FC2', 'CP2', 'C4', 'FC6', 'CP6')


df.s = df[df$Channels %in% Cluster.s,] # small cluster

df.c = df[df$Channels %in% Cluster.c,] # big central cluster

df.l = df[df$Channels %in% Cluster.l,] # big left cluster

df.r = df[df$Channels %in% Cluster.r,] # big right cluster


####### Run Linear Models ---------------------------------------------------------------

### The models

`C4, Cz, C3`  = lmer(Power ~Probability  +(1|Id/Channels),data=df.s) 
`FC1, C3, CP1, Cz, FC2, C4, CP2`  = lmer(Power ~Probability  +(1|Id/Channels),data=df.c) 
`FC1, CP1, C3, FC5, CP5`  = lmer(Power ~Probability  + (1|Id/Channels),data=df.l) 
`FC2, CP2, C4, FC6, CP6`  = lmer(Power ~Probability  +(1|Id/Channels),data=df.r) 

comp = as.data.frame(compare_performance(`C4, Cz, C3`,`FC1, C3, CP1, Cz, FC2, C4, CP2`,`FC1, CP1, C3, FC5, CP5`,`FC2, CP2, C4, FC6, CP6`, metrics ='AIC'))

ggplot(comp, aes(x=Name, y= AIC, fill= Name))+
         geom_bar(stat = 'identity')+
  scale_x_discrete('Clusters')+
  scale_fill_colorhex_d()+
  theme_minimal(base_size = 20)+
  theme(legend.position = "none")

ggsave('C:\\Users\\tomma\\surfdrive - Ghilardi, T. (Tommaso)@surfdrive.surf.nl\\Projects\\InfantEEG\\Results\\Mu_Comparison.png',
       device = "png", width = 40, height = 25, units = "cm",dpi=500)
