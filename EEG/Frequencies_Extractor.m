
%% ========================% Setting up %======================= %%
clear;
clc;

% Data Subject settings
Path = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Processed\';


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

% Subject to reject
Sub_rejection_Execution =  {'S_Stat_08','S_Stat_11','S_Stat_28','S_Stat_43','S_Stat_51'};

% Find all the data
Files = dir([Path, '**\Execution\Clean.mat']);

% Loop for each subject
for file  =  1:length(Files)
    load([Files(file).folder,'\Clean.mat' ]);
    
    Subject = art_final_data.subjetc;
    
    if ~ismember(Subject, Sub_rejection_Execution) % don't extract the subejt to reject

        art_final_data = rmfield(art_final_data,'subjetc');
        Freq_data = ft_freqanalysis(cfg_freq, art_final_data);
        Freq_data.subject =  Subject;
        save([Files(file).folder '\FFT.mat'],'Freq_data');

        % Clean for next subject
        clear Freq_data art_final_data
    end
end


%% Prediction Frequencies

% Subject to reject
Sub_rejection_Prediction =  {'S_Stat_06','S_Stat_09','S_Stat_19','S_Stat_21',...
    'S_Stat_22','S_Stat_42','S_Stat_64','S_Stat_68'};

% Find all the data
Files = dir([Path, '**\Prediction\Clean.mat']);

% Loop for each subject
for file  =  1:length(Files)
    load([Files(file).folder,'\Clean.mat' ]);
    
    Subject = art_final_data.subjetc;
    
    if ~ismember(Subject, Sub_rejection_Prediction)
    
        disp(Subject)
        disp(length(art_final_data.trialinfo))
        art_final_data = rmfield(art_final_data,'subjetc');

        Freq_data = ft_freqanalysis(cfg_freq, art_final_data);
        Freq_data.subject =  Subject;
        save([Files(file).folder '\FFT.mat'],'Freq_data');

        % Clean for next subject
        clear Freq_data art_final_data
    end
end








