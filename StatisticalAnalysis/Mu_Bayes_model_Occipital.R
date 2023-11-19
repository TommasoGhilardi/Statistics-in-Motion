
####### Libraries ---------------------------------------------------------------

library(brms)
library(easystats)
library(tidyverse)

library(cowplot)


####### Set and read data ---------------------------------------------------------------

setwd("C:\\Users\\tomma\\Desktop\\BabyBrain\\Projects\\EEG_probabilities_infants\\Data\\ProcessedBids\\")

RUN = F

####### Read data ---------------------------------------------------------------


# Find all files and concatenate dataframes
files = list.files(pattern = "*DFmu.csv", recursive = TRUE,full.names = FALSE)
df = map_dfr(files, read_csv,show_col_types = FALSE)

## Create cluster of interest over the motor area
Cluster = c('O1' , 'Oz', 'O2')
df = df[df$Channels %in% Cluster,] # select channels in the cluster

# Make Probabilities more understandable
df$Probability = df$Trial
df[df['Probability']==1,'Probability'] = 25
df[df['Probability']==2,'Probability'] = 50
df[df['Probability']==3,'Probability'] = 75
df[df['Probability']==4,'Probability'] = 100

df$Probabilities =  factor(df$Probability) # categorical for anova


# Plot --------------------------------------------------------------------

ggplot(df, aes(x = Power, color = Probabilities))+
  geom_density()

ggplot(df, aes(x = Probability, y = Power, color = Probabilities))+
  geom_boxplot()+
  facet_wrap(~Channels)

ggplot(df, aes(x = Probability, y = Power, color =  Channels))+
  geom_point()+
  geom_smooth(method = 'lm', color = 'black')+
  facet_wrap(~Channels, scales = 'free')


# Model --------------------------------------------------------------------

# Prepare priors
priors <- c(  set_prior("normal(0, 12)", class = "b"))

if (RUN){
  print('A')
  # Run the model
  mod =  brm(Power ~ Probability * Channels * trialN + (1|Id),
             prior = priors,sample_prior = T,
             data =df, chains=4, cores = 4,
             iter = 10000, warmup = 8000, control=list(max_treedepth = 12))
  
  # save data
  saveRDS(mod, 'C:\\Users\\tomma\\Desktop\\BabyBrain\\Projects\\EEG_probabilities_infants\\Analysis\\NewTest\\modelOcc.rds' )
  
}else{
  
  # Read the model
  mod = readRDS('C:\\Users\\tomma\\Desktop\\BabyBrain\\Projects\\EEG_probabilities_infants\\Analysis\\NewTest\\modelOcc.rds')
}

gc()


#  Check model ------------------------------------------------------

summary(mod)

draws1 <- prior_draws(mod)

posterior = describe_posterior(mod, ci = .89)


# Plot --------------------------------------------------------------------

Slope = estimate_means(mod, at = 'Probability=c(0,25,50,75,100)', ci = 0.89)

ggplot(Slope, aes(x = Probability, y = Mean, color = '#e68613'))+
  geom_ribbon(aes(ymin =CI_low , ymax =CI_high ), fill = '#e68613',color = 'transparent', alpha= 0.2)+
  geom_line(linewidth = 2)+
  theme_minimal(base_size = 30)+
  annotate("text", x = 50, y = 0.72, label = "*", size = 12, color = "black", fontface='bold')+
  scale_x_continuous(labels = c('0%','25%','50%','75%','100%')) + # This will convert to percentage format
  labs(x = 'Probability', y = 'Estimated log10(Alpha power)')+
  theme(legend.position = 'none')

ggsave('C:\\Users\\tomma\\surfdrive - Ghilardi, T. (Tommaso)@surfdrive.surf.nl\\Projects\\InfantEEG\\Results\\OccipitalProbability.png',
       device = "png", width = 40, height = 20, units = "cm",dpi=1000)
