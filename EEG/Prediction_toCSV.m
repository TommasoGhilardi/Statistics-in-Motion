
%% ========================% Setting up %======================= %%
clear;
clc;

% Data Subject settings
RawPath  = 'C:\Users\tomma\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Bids\';       %location of the participant data
ProcessedPath = 'C:\Users\tomma\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\ProcessedBids\';

% Find all the data
Files = dir([ProcessedPath, '**\Prediction\FFT.mat']);

% Channels of interest definition
Channels.motor     = {'C3','Cz','C4'};
Channels.occipital = {'O1','Oz','O2'};
Channels.clusters = {'CP1', 'CP2', 'CP5', 'CP6', 'FC1', 'FC2', 'FC5', 'FC6'};

% Frequencies
% Define the frequencies from action execution phase
Frequencies.value = [7 9];
Frequencies.name = "mu";


%% Extract Frequencies
for file  =  1:length(Files)
    load([Files(file).folder,'\FFT.mat' ]);
    
    Subject = Freq_data.subject;    
    disp(Subject);
    Freq_data = rmfield(Freq_data,'subject');
    
    % Normalize data
    Freq_data.powspctrm = log10(Freq_data.powspctrm); %normalizing data using log10
    
    
    %% ========================% CSV export %======================= %%

    % Select specified frequenceis     
    cfg = [];
    cfg.frequency   = Frequencies.value;
    cfg.avgoverfreq = 'yes';
    cfg.nanmean     = 'yes';
    avg = ft_selectdata(cfg, Freq_data) ;

    rep = size(avg.powspctrm,1);

    CV = array2table(avg.powspctrm);
    CV.Properties.VariableNames = avg.label;
    
    trials = num2str(avg.trialinfo);
    CV.Trial = trials(:,2);
    
    CV.trialN = find_indices(Subject, ProcessedPath);

    CV.Id = repmat(Subject,rep,1);
    CV.Frequency = repmat(Frequencies.name,rep,1);

    % Video training extraction
    Watched      = VideoWatching(RawPath,Subject);
    CV.Training = repmat(Watched,rep,1);

    CV = stack(CV,avg.label,...
              'NewDataVariableName','Power',...
              'IndexVariableName','Channels');


    writetable(CV,join([Files(file).folder '\DF' Frequencies.name '.csv'],''));
    
    % Clean for next subject
    clear Freq_data CV Freq_data Subject avg Watched
    clear Col*
    
end




