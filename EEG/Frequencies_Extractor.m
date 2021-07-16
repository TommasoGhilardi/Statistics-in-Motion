
%% ========================% Setting up %======================= %%

% Fieltrip settings
if ~exist('ft_defaults', 'file')
    addpath('C:\Users\moniq\Documents\Psychologie\Master Gezondheidszorgpsychologie\Scriptie\Matlab\fieldtrip-20210603\fieldtrip-20210603');    % add fieltrip as your toolbox
    ft_defaults();      % set all the default fieltrip functions
end

% Data Subject settings
Path = 'C:\Users\moniq\surfdrive\Shared\Monique_Infant_EEG\Processed\';


%% Frequencies extraction settings

% FFT decomposition
cfg_freq              = [];
cfg_freq.output       = 'pow';
cfg_freq.channel      = 'EEG';
cfg_freq.method       = 'mtmfft';
cfg_freq.taper        = 'hanning';
cfg_freq.pad          = 2;
cfg_freq.padtype      = 'mean';
cfg_freq.keeptrials   = 'yes';
cfg_freq.foi          = 2:1:30; % analysis 2 to 30 Hz in steps of 1 Hz


%% Execution Frequencies

% Find all the data
Files = dir([Path, '**\Execution\Clean.mat']);

% Loop for each subject
for file  =  1:length(Files)
    load([Files(file).folder,'\Clean.mat' ]);
        
    Freq_data = ft_freqanalysis(cfg_freq, art_final_data);
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

    Freq_data = ft_freqanalysis(cfg_freq, art_final_data);
    Freq_data.subject =  Subject;
    save([Files(file).folder '\FFT.mat'],'Freq_data');

    clear Freq_data art_final_data   
end








