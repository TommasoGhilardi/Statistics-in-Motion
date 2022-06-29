%% ========================% Setting up %======================= %%

% Data Subject settings
Path = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Processed\';

cap_conf = 'acticap-64ch-standard2.mat';

Freq = [7 9];


%% Prediction data concatenation

% Find all the data
Files = dir([Path, '**\Prediction\FFT.mat']);

% Read and concatenate the data 
for file  =  1:length(Files)
    load([Files(file).folder,'\FFT.mat' ]);

    if exist('Pre','var') == 1
       cfg = [];
       cfg.appendim = 'rpt';
       Pre = ft_appendfreq(cfg, Pre, Freq_data);
    else
       Pre = Freq_data;   
    end
    
    clear Freq_data
end


%% Divide data for each level

Trials = num2str(Pre.trialinfo);

cfg = [];
cfg.avgoverrpt = 'no';
cfg.frequency = Freq;

cfg.trials    = Pre.trialinfo == 50;
Fix = ft_selectdata(cfg, Pre);

cfg.trials    = Trials(:,2) == '1';
Low = ft_selectdata(cfg, Pre);

cfg.trials    = Trials(:,2) == '2';
Medium = ft_selectdata(cfg, Pre);

cfg.trials    = Trials(:,2) == '3';
High = ft_selectdata(cfg, Pre);

cfg.trials    = Trials(:,2) == '4';
Det = ft_selectdata(cfg, Pre);


%% Topoplot

cfg = [];
cfg.layout = cap_conf;
cfg.zlim = [3.63 125];

ft_topoplotTFR(cfg,Fix); colorbar
title('Fixation: 0%');
axis tight

ft_topoplotTFR(cfg,Low);
title('Low Probability: 25%');
axis tight

ft_topoplotER(cfg, Medium);
title('Medium Probability: 50%');
axis tight

ft_topoplotER(cfg, High);
title('High Probability: 75%');
axis tight

subplot(2,2,1)
cfg.figure =  subplot(2,2,1);
ft_topoplotER(cfg, Medium);
title('Deterministic: 100%');
axis tight















