
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
Cluster = c('C3' , 'Cz', 'C4')
df = df[df$Channels %in% Cluster,] # select channels in the cluster
df$Channels = factor(df$Channels, levels = c('C4','C3','Cz'))

# Make Probabilities more understandable
df$Probability = df$Trial
df[df['Probability']==1,'Probability'] = 25
df[df['Probability']==2,'Probability'] = 50
df[df['Probability']==3,'Probability'] = 75
df[df['Probability']==4,'Probability'] = 100

df$Probabilities =  factor(df$Probability) # categorical for anova


#######  Plot to explore the data --------------------------------------------------------------------

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


ggplot(df, aes())



# Model --------------------------------------------------------------------

# Prepare priors
priors <- c(  set_prior("normal(0, 12)", class = "b"))

if (RUN){
  # Run the model
  mod =  brm(Power ~ Probability * Channels * trialN + (1|Id),
             prior = priors,sample_prior = T,
             data =df, chains=4, cores = 4,
             iter = 10000, warmup = 8000, control=list(max_treedepth = 12))
  
  # save data
  saveRDS(mod, 'C:\\Users\\tomma\\Desktop\\BabyBrain\\Projects\\EEG_probabilities_infants\\Analysis\\NewTest\\model.rds' )

}else{
  
  # Read the model
  mod = readRDS('C:\\Users\\tomma\\Desktop\\BabyBrain\\Projects\\EEG_probabilities_infants\\Analysis\\NewTest\\model.rds')
}

gc()



#  Check model ------------------------------------------------------

summary(mod)

# Check the model
posterior = describe_posterior(mod, ci = .89,)


# Plot the slope effect Channels number--------------------------------------------------------------------

Sl = as.data.frame(estimate_slopes(mod, trend = "Probability", at = "Channels", ci = 0.89))
Sl = Sl %>%
  mutate(Sign = if_else(CI_low<=0 & CI_high >=0, 'Not significative','Significative'))


ggplot(Sl, aes(x = Channels, y = Coefficient, color = Channels))+
  geom_point(size = 3)+
  geom_errorbar(aes(ymin=CI_low, ymax=CI_high), width = 0.2)+
  geom_hline(yintercept = 0,linetype = "dashed", alpha = 0.6, linewidth =1)+
  labs(x= 'Channels', y = 'Estimated beta coefficient')+
  theme_minimal(base_size  = 20)


# Plot the slope effect Channels*trial number--------------------------------------------------------------------

Slopes = as.data.frame(estimate_slopes(mod, trend = "Probability", at = c("Channels","trialN"), ci = 0.89,length = 73))
Slopes = Slopes %>%
  mutate(Significance = if_else(CI_low<=0 & CI_high >=0, 'Not significative','Significative'))

# Perpare data
Slopes$Sign = factor(Slopes$Sign, levels = c('Significative','Not significative'))
Slopes$Channels <- factor(Slopes$Channels, levels = c("C3", "C4", "Cz"))

# Perepare colors
channel_colors <- c('C3' = '#f8766d', 'C4' = '#00ba38', 'Cz' = '#619cff')


Sl_plot = ggplot(Slopes, aes(x = trialN, y = Coefficient, color = Channels))+
  geom_line(linewidth = 1.6, aes(linetype = Significance))+
  scale_linetype_manual(values=c("Significative"="solid", "Not significative"="dotted")) + # Map 'positive' to solid and 'negative' to dotted
  geom_ribbon(aes(ymin=CI_low, ymax=CI_high, fill = Channels),color = NA, alpha = 0.3)+
  geom_hline(yintercept = 0,linetype = "dashed", alpha = 0.8, linewidth =1.2)+
  scale_color_manual(values = channel_colors) +
  scale_fill_manual(values = channel_colors) + 
  labs(x= 'Trial number', y = 'Estimated beta coefficient')+
  theme_minimal(base_size  = 20)+
  theme(legend.title=element_blank(),
        legend.key.size=unit(3,"lines"))
Sl_plot

ggsave('C:\\Users\\tomma\\surfdrive - Ghilardi, T. (Tommaso)@surfdrive.surf.nl\\Projects\\InfantEEG\\Results\\InteractionSlope.png',
       device = "png", width = 50, height = 20, units = "cm",dpi=1000)



# Line facet --------------------------------------------------------------------


# Create an empty data frame
empty_data <- data.frame(x = numeric(0), y = numeric(0))

# Plot with only y-axis label with increased size
Ylabe = ggplot(empty_data, aes(x = x, y = y)) +
  geom_blank() + # Adds nothing to the plot but ggplot needs data to define a plot
  labs(y = "Estimated log10(Mu power)") + # Add y-axis label
  theme(
    axis.title.x = element_blank(), 
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.background = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.background = element_blank(),
    axis.title.y = element_text(size = 20) # Increase the size of the y-axis label
  )



MeansC3 = estimate_means(mod,at = c('Probability=c(0,25,50,75,100)','Channels="C3"','trialN = c(10,24,40,54)'),ci = 0.89)
MeansC4 = estimate_means(mod,at = c('Probability=c(0,25,50,75,100)','Channels="C4"','trialN = c(10,24,40,54)'),ci = 0.89)
MeansCz = estimate_means(mod,at = c('Probability=c(0,25,50,75,100)','Channels="Cz"','trialN = c(10,24,40,54)'),ci = 0.89)

labelS = c( `10` = 'Trial 10',
            `24` = 'Trial 24',
            `40` = 'Trial 40',
            `54` = 'Trial 54')


Ast = data_frame(Sign = c('*','*','',''),
                 trialN = c(10,24,40,54))



P3 = ggplot(MeansC3, aes(x = Probability, y = Mean, color = Channels))+
  geom_line(linewidth = 2,color = '#f8766d')+
  geom_ribbon(aes(ymin = CI_low, ymax = CI_high, fill=  Channels),alpha = 0.16, fill = '#f8766d',color = 'transparent')+
  geom_text(inherit.aes = F, data = Ast,aes(label = Sign, x = 50, y =0.6), size = 12, color = "black", fontface='bold')+
  facet_wrap(~trialN, nrow =  1,
             labeller = labeller(trialN = labelS))+
  ylim(0.10, 0.65)+
  labs(y = '')+
  scale_x_continuous(breaks = c(0,25,50,75,100))+
  theme_bw(base_size  = 18)+
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        legend.position = "none")

P4 = ggplot(MeansC4, aes(x = Probability, y = Mean, color = Channels))+
  geom_line( linewidth = 2, color = '#00ba38')+
  geom_ribbon(aes(ymin = CI_low, ymax = CI_high, fill=  Channels),alpha = 0.16, fill = '#00ba38',color = 'transparent')+
  facet_wrap(~trialN, nrow =  1)+
  ylim(0.10, 0.65)+
  labs(y = '')+
  scale_x_continuous(breaks = c(0,25,50,75,100))+
  theme_bw(base_size  = 18)+
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        legend.position = "none",
        strip.background = element_blank(),
        strip.text.x = element_blank())

Pz = ggplot(MeansCz, aes(x = Probability, y = Mean, color = Channels))+
  geom_line( linewidth = 2, color = '#619cff')+
  geom_ribbon(aes(ymin = CI_low, ymax = CI_high, fill=  Channels),alpha = 0.16, fill = '#619cff',color = 'transparent')+
  facet_wrap(~trialN, nrow =  1)+
  ylim(0.10, 0.65)+
  labs(y = '')+
  scale_x_continuous(breaks = c(0,25,50,75,100), labels = c('0%','25%','50%','75%','100%'))+
  theme_bw(base_size  = 18)+
  theme(legend.position = "none",
        strip.background = element_blank(),
        strip.text.x = element_blank(),
        axis.title.x = element_text(size = 20))

Comb_facet = plot_grid(P3,P4,Pz, labels = c('C3','C4','Cz'), ncol = 1, label_size=22, vjust = c(1.5,1,1))
Comb_facet = plot_grid(Ylabe,Comb_facet, ncol = 2,rel_widths = c(0.05,1.7))
Comb_facet

ggsave('C:\\Users\\tomma\\surfdrive - Ghilardi, T. (Tommaso)@surfdrive.surf.nl\\Projects\\InfantEEG\\Results\\InteractionCategorical.png',
       device = "png", width = 40, height = 20, units = "cm",dpi=1000)






# Plot trialN -------------------------------------------------------------

# Create a new column 'trial_group' to indicate the group of each trial
db = df %>%
  group_by(trialN) %>%
  summarise(n_trials = n()/3)

ggplot(db , aes(x = trialN))+
  geom_density(linewidth =1.5)


M = glm(n_trials ~ trialN, family = "poisson", data = db)
summary(M)

f = estimate_expectation(M)

ggplot(f, aes(x= trialN, y = Predicted))+
  geom_line(color =  '#cc79a7', size =1.2)+
  geom_ribbon(aes(ymin = Predicted-SE, ymax = Predicted+SE),alpha = 0.4, fill = '#cc79a7',color = 'transparent')+
  labs(y = 'Estimated number of infants\nwho contributed to usable trials', x = 'Trial number')+
  theme_minimal(base_size = 20)
ggsave('C:\\Users\\tomma\\surfdrive - Ghilardi, T. (Tommaso)@surfdrive.surf.nl\\Projects\\InfantEEG\\Results\\TrialNumber.png',
       device = "png", width = 40, height = 20, units = "cm",dpi=1000)



