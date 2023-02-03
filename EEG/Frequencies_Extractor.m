
%% ========================% Setting up %======================= %%
clear;
clc;

% Data Subject settings
Path = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\ProcessedBids\';


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
Sub_rejection_Execution =  {'sub-08','sub-11','sub-12','sub-19','sub-28','sub-39',...
    'sub-43','sub-51','sub-55','sub-58','sub-60','sub-76'};

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
Sub_rejection_Prediction =  {'sub-06','sub-09','sub-19','sub-21',...
    'sub-22','sub-32','sub-42','sub-44','sub-51','sub-58','sub-64',...
    'sub-68','sub-76','sub-77'};

% Find all the data
Files = dir([Path, '**\Prediction\Clean.mat']);

% Loop for each subject
for file  =  1:length(Files)
    load([Files(file).folder,'\Clean.mat' ]);
    
    Subject = art_final_data.subjetc;
    
    if ~ismember(Subject, Sub_rejection_Prediction)
    
        disp([num2str(file) ' -- ' Subject])
        disp(length(art_final_data.trialinfo))
        art_final_data = rmfield(art_final_data,'subjetc');

        Freq_data = ft_freqanalysis(cfg_freq, art_final_data);
        Freq_data.subject =  Subject;
        save([Files(file).folder '\FFT.mat'],'Freq_data');

        % Clean for next subject
        clear Freq_data art_final_data
    end
end














