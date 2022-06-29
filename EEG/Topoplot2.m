%% ========================% Setting up %======================= %%

% Data Subject settings
Path = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Processed\';

cap_conf = 'acticap-64ch-standard2.mat';

Freq = [7 9];


%% Prediction data concatenation

% Find all the data
Files = dir([Path, '**\Prediction\FFT.mat']);

clear Fix Low Medium High Det

% Read and concatenate the data 
for file  =  1:length(Files)
    load([Files(file).folder,'\FFT.mat' ]);
    Trials = num2str(Freq_data.trialinfo);
 
    cfg = [];
    cfg.frequency  = Freq;
    cfg.avgoverrpt = 'yes';
    cfg.nanmean    = 'yes';     
    
    cfg.trials    = Trials(:,2) == '0';
    Fix{file} = ft_selectdata(cfg, Freq_data);
    
    cfg.trials    = Trials(:,2) == '1';
    Low{file} = ft_selectdata(cfg, Freq_data);
    
    cfg.trials    = Trials(:,2) == '2';
    Medium{file} = ft_selectdata(cfg, Freq_data);
    
    cfg.trials    = Trials(:,2) == '3';
    High{file} = ft_selectdata(cfg, Freq_data);
    
    cfg.trials    = Trials(:,2) == '4';
    Det{file} = ft_selectdata(cfg, Freq_data);
    
    clear Freq_data Trials
end


%% 
cfg = [];
Fix    = ft_freqgrandaverage(cfg, Fix{:});
Low    = ft_freqgrandaverage(cfg, Low{:});
Medium = ft_freqgrandaverage(cfg, Medium{:});
High   = ft_freqgrandaverage(cfg, High{:});
Det    = ft_freqgrandaverage(cfg, Det{:});


%% Topoplot

cfg = [];
cfg.layout = cap_conf;
cfg.zlim = 'maxmin';

ft_topoplotTFR(cfg,Fix); colorbar
ft_topoplotTFR(cfg,Low); colorbar
ft_topoplotTFR(cfg,Medium); colorbar
ft_topoplotTFR(cfg,High); colorbar
ft_topoplotTFR(cfg,Det); colorbar




