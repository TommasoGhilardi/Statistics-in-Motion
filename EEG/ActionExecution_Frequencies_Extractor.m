
%% ========================% Setting up %======================= %%

% Fieltrip settings
if ~exist('ft_defaults', 'file')
    addpath('C:\Users\krav\Documents\Matlab\fieldtrip');    % add fieltrip as your toolbox
    ft_defaults();      % set all the default fieltrip functions
end

% Data Subject settings
OutPath = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Out\';

% Find all the data
Files = dir([OutPath, '**\Execution\Clean.mat']);


%% Extract Frequencies
for file  =  1:length(Files)
    load([Files(file).folder,'\Clean.mat' ]);
    
    % FFT decomposition
    cfg              = [];
    cfg.output       = 'pow';
    cfg.channel      = 'EEG';
    cfg.method       = 'mtmfft';
    cfg.taper        = 'hanning';
    cfg.pad          = 2;
    cfg.padtype      = 'mean';
    cfg.keeptrials   = 'yes';
    cfg.foi          = 2:1:30; % analysis 2 to 30 Hz in steps of 1 Hz
    Freq_data        = ft_freqanalysis(cfg, art_final_data);

    Freq_data.powspctrm = log10(Freq_data.powspctrm); %normalizing data using log10
    save([Files(file).folder '\FFT.mat'],'Freq_data');
    
    % Clean for next subject
    clear Freq_data art_final_data       
end




