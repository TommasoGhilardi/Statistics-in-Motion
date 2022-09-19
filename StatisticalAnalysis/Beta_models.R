
####### Libraries ---------------------------------------------------------------

library(lme4)
library(lmerTest)
library(modelbased)

library(parameters)
library(performance)

library(ggplot2)
library(insight)
library(see)
library(cowplot)

####### Set and read data ---------------------------------------------------------------

directory = "C:\\Users\\krav\\Desktop\\BabyBrain\\Projects\\EEG_probabilities_infants\\Data\\Processed\\"

rejection = c('S_Stat_06','S_Stat_09','S_Stat_19','S_Stat_21','S_Stat_28',
              'S_Stat_22','S_Stat_42','S_Stat_64','S_Stat_68' )

files = list.files(directory ,pattern = "*.csv", recursive = TRUE)

## Concatenate dataframes
df = data.frame()
for(sub in 1:length(files)){
  
  if (!any(grepl(strsplit(files[sub], '/', fixed=T)[[1]][1], rejection, fixed = TRUE))){
    
    df = rbind(df, read.csv(paste(directory,files[sub], sep = '\\' )))
  }
}

## Select only Mu and Motor area
df = df[df$Frequency=='beta',]
df<- df[ df$Channels != 'O1'& df$Channels != 'O2' & df$Channels != 'Oz',]


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
anova(Anova_prob.aov)

### Contrast analysis
contrasts = estimate_contrasts(Anova_prob.aov, contrast  = "Probabilities",adjustment= 'bonferroni',
                               pbkrtest.limit = 3285,lmerTest.limit = 3285)
print_html(contrasts)

######### Visualization

result <- parameters(Anova_prob.aov, effects = "fixed")
plot(result)


### Plot mean estimates
means = estimate_means(Anova_prob.aov,pbkrtest.limit = 3285,lmerTest.limit = 3285)
means$SE_L = means$Mean - means$SE
means$SE_H = means$Mean + means$SE

ErroBar = ggplot(means, aes(x =  Probabilities, y = Mean)) +
  geom_line(aes(group = 1),size=1.2, alpha=0.4) +
  geom_point(aes(colour =  Probabilities),size=6)+
  geom_errorbar(aes( colour= Probabilities, ymin = CI_low, ymax = CI_high),width = 0.4,size = 1.5)+
  ylab("log(Mu Power)")+
  theme(legend.position="none",panel.grid.minor = element_line(size = 1),
        panel.grid.major = element_line(size = 1))
ggsave('C:\\Users\\krav\\surfdrive\\Projects\\InfantEEG\\Results\\Beta_AnovaErrorbar.png',device = "png", width = 20, height = 20, units = "cm",dpi=500)

ErroBar = ErroBar +theme(axis.ticks.x=element_blank(),axis.text.x=element_blank())+xlab(element_blank())

### Plot Violin
ViolinANova = ggplot(df, aes(x = Probabilities, y = Power)) +
  # Add base data
  geom_violin(aes(fill = Probabilities), color = "white") +
  geom_jitter2(aes(color = Probabilities), width = 0.4, alpha = 0.5) +
  
  # Add pointrange and line from means
  geom_line(data = means, aes(y = Mean, group = 1.5), size = 1.3,alpha=0.6) +
  geom_pointrange(
    data = means, aes(y = Mean, ymin = CI_low, ymax = CI_high), size = 1, color = "white" ) +
  ylab("log(Mu Power)")+ylim(-2.5, 2.5)+
  theme(legend.position="none",panel.grid.minor = element_line(size = 1),
        panel.grid.major = element_line(size = 1))


Final = plot_grid(ErroBar,ViolinANova, align ='v',ncol=1)
Final
ggsave('C:\\Users\\krav\\surfdrive\\Projects\\InfantEEG\\Results\\Beta_AnovaAll.png',Final,device = "png", width = 20, height = 20, units = "cm",dpi=500)


####### Run Linear Model ---------------------------------------------------------------

### The model
Model  = lmer(Power ~Probability +(1|Id/Channels),data=df) # Basic
ModelT = lmer(Power ~Probability + Training  +(1|Id/Channels),data=df) # With training
ModelQ = lmer(Power ~poly(Probability,2,raw = TRUE) + Training  +(1|Id/Channels),data=df) # Quadratic

### Check Best Model
test_performance(Model, ModelT)
print_html(parameters(Model))

### Check assumptions
check_model(Model)


### PLot
Predicted = estimate_expectation(Model)
Predicted$SE_low = Predicted$Predicted - Predicted$SE
Predicted$SE_high = Predicted$Predicted + Predicted$SE


### Plot Half Violin
df$test = unlist(df['Probability']-3.2)

ggplot(df, aes(x = Probability, y = Power)) +
  geom_violinhalf(aes(fill = Probabilities), color = "white") +
  
  geom_jitter2(aes(x=test ,fill = Probabilities),shape= 21,width = 3, alpha = 0.6) +
  
  # The model
  geom_ribbon(data = Predicted,aes(ymin=CI_low, ymax=CI_high), linetype=2, alpha=0.2)+
  geom_line(data = Predicted,aes( x=Probability  ,y=Predicted),size=1.6)+
  
  # Add pointrange
  geom_pointrange(data = means, aes(as.numeric(as.character(Probabilities)),
                                    y = Mean, ymin = CI_low, ymax = CI_high), size = 1, color = "white" ) +
  ylim(-2.5,2.5)+ scale_x_continuous( breaks = seq(-25, 100, by = 25))+ ylab("log(Mu Power)")+
  theme(panel.grid.minor = element_line(size = 1), panel.grid.major = element_line(size = 1))
ggsave('C:\\Users\\krav\\surfdrive\\Projects\\InfantEEG\\Results\\Beta_HalfViolin.png',device = "png", width = 18, height = 20, units = "cm",dpi=500)


### Plot entire violin
ggplot(df, aes(x = Probability, y = Power)) +
  
  # Add base data
  geom_violin(aes(fill = Probabilities), color = "white") +
  geom_jitter2(aes(color = Probabilities), width = 10, alpha = 0.5)+
  
  # The model
  geom_ribbon(data = Predicted,aes(ymin=CI_low, ymax=CI_high), linetype=2, alpha=0.2)+
  geom_line(data = Predicted,aes( x=Probability  ,y=Predicted),size=1.6)+
  
  # Add pointrange
  geom_pointrange(data = means, aes(as.numeric(as.character(Probabilities)),
                                    y = Mean, ymin = CI_low, ymax = CI_high), size = 1, color = "white" ) +
  ylim(-2.5,2.5) + scale_x_continuous(limits=c(-12, 112),breaks = seq(0, 100, by = 25))+ylab("log(Mu Power)")+
  theme(panel.grid.minor = element_line(size = 1), panel.grid.major = element_line(size = 1))
ggsave('C:\\Users\\krav\\surfdrive\\Projects\\InfantEEG\\Results\\Beta_WholeViolin.png',device = "png", width = 20, height = 20, units = "cm",dpi=500)


#### Plot Smaller
ggplot(means, aes(x =  as.numeric(as.character(Probabilities)), y = Mean)) +
  # The model
  geom_ribbon(data = Predicted, aes(x=Probability  ,y=Predicted, ymin=CI_low, ymax=CI_high), linetype=2, alpha=0.2)+
  geom_line(data = Predicted, aes(x=Probability  ,y=Predicted), size=1.6,color = '#878787')+
  
  #geom_line(aes(group = 1),size=1.2, alpha=0.4) +
  geom_point(aes(colour =  Probabilities),size=6)+
  geom_errorbar(aes( colour= Probabilities, ymin = CI_low, ymax = CI_high),width = 4,size = 1.5)+
  ggtitle('Estimated Means')+ ylab("Power")+ylab("log(Mu Power)")+
  theme(legend.position="none",panel.grid.minor = element_line(size = 1), panel.grid.major = element_line(size = 1))

ggsave('C:\\Users\\krav\\surfdrive\\Projects\\InfantEEG\\Results\\Beta_Zoomed.png',device = "png", width = 15, height = 20, units = "cm",dpi=500)





####### Run Model on Surprise ---------------------------------------------------------------

dc = df[df['Trial']!=0,]

dc['Expectancy'] = dc['Trial']
dc[dc['Expectancy']==1,'Expectancy'] = -log2(0.25)
dc[dc['Expectancy']==2,'Expectancy'] = -log2(0.5)
dc[dc['Expectancy']==3,'Expectancy'] = -log2(0.75)
dc[dc['Expectancy']==4,'Expectancy'] = -log2(1)

### The model
ModelE <- lmer(Power ~ Expectancy+Training  +(1|Id/Channels),data=dc)
print_html(parameters(ModelE))

### Check assumptions
check_model(ModelE)


