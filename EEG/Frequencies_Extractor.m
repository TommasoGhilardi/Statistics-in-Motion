
%% ========================% Setting up %======================= %%

% Fieltrip settings
if ~exist('ft_defaults', 'file')
    addpath('C:\Users\krav\Documents\Matlab\fieldtrip');    % add fieltrip as your toolbox
    ft_defaults();      % set all the default fieltrip functions
end

% Data Subject settings
Path = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Out\';


%% Frequencies extraction settings

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


%% Execution Frequencies

% Find all the data
Files = dir([Path, '**\Execution\Clean.mat']);

% Loop for each subject
for file  =  1:length(Files)
    load([Files(file).folder,'\Clean.mat' ]);
    
    Freq_data        = ft_freqanalysis(cfg, art_final_data);

    Freq_data.powspctrm = log10(Freq_data.powspctrm); %normalizing data using log10
    save([Files(file).folder '\FFT.mat'],'Freq_data');
    
    % Clean for next subject
    clear Freq_data art_final_data       
end


%% Prediction Frequencies

% Find all the data
Files = dir([Path, '**\Prediction\Clean.mat']);

% Loop for each subject
for file  =  1:length(Files)
    load([Files(file).folder,'\Clean.mat' ]);

    Subject = art_final_data.subjetc;
    art_final_data = rmfield(art_final_data,'subjetc');

    Freq_data        = ft_freqanalysis(cfg, art_final_data);

    Freq_data.powspctrm = log10(Freq_data.powspctrm); %normalizing data using log10
    Freq_data.subject =  Subject;
    save([Files(file).folder '\FFT.mat'],'Freq_data');

    clear Freq_data art_final_data   
end








