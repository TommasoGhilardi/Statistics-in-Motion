
%% ========================% Setting up %======================= %%

% Fieltrip settings
if ~exist('ft_defaults', 'file')
    addpath('C:\Users\krav\Documents\Matlab\fieldtrip');    % add fieltrip as your toolbox
    ft_defaults();      % set all the default fieltrip functions
end

% Data Subject settings
OutPath = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Out\';

% Channels of interest definition
Channels.motor     = {'C3','Cz','C4'};
Channels.occipital = {'O1','Oz','O2'};


%% Execution data concatenation

% Find all the data
Files = dir([OutPath, '**\Execution\FFT.mat']);

% Read and concatenate the data 
for file  =  1:length(Files)
    load([Files(file).folder,'\FFT.mat' ]);
    
    % select data
    cfg = [];
    cfg.channel = Channels.motor;
    cfg.avgoverchan = 'yes';
    cfg.acgoverrpt  = 'yes';
    cfg.nanmean     = 'yes';
    dat = ft_selectdata(cfg, Freq_data);
    
    if exist('db', 'var')
        cfg = [];
        EX = ft_appendfreq(cfg, EX, dat);
    else
        EX = dat;
    end
%     clear Freq_data dat
    
end
clear Files


%% Prediction (fixation cross) data concatenation

% Find all the data
Files = dir([OutPath, '**\Prediction\FFT.mat']);

% Read and concatenate the data 
for file  =  1:length(Files)
    load([Files(file).folder,'\FFT.mat' ]);
    
    % select data
    cfg = [];
    cfg.trials  = find(Freq_data.trialinfo == 50);
    cfg.acgoverrpt  = 'yes';
    cfg.channel = Channels.motor;
    cfg.avgoverchan = 'yes';
    cfg.nanmean     = 'yes';
    dat = ft_selectdata(cfg, Freq_data);
    
    if exist('db', 'var')
        cfg = [];
        Ba = ft_appendfreq(cfg, Ba, dat);
    else
        Ba = dat;
    end
    clear Freq_data dat
    
end


%% Plot the data

cfg= [];
cfg.parameter =  'powspctrm';
cfg.title  = 'Execution vs Baseline Plot';
cfg.showlegend = 'yes';
ft_singleplotER(cfg,  EX, Ba)
