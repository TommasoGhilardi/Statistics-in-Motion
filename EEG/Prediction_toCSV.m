
%% ========================% Setting up %======================= %%
clear;
clc;

% Data Subject settings
RawPath  = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Bids\';       %location of the participant data
ProcessedPath = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\ProcessedBids\';

% Find all the data
Files = dir([ProcessedPath, '**\Prediction\FFT.mat']);

% Channels of interest definition
Channels.motor     = {'C3','Cz','C4'};
Channels.occipital = {'O1','Oz','O2'};
Channels.clusterC = {'FC1' , 'C3', 'CP1', 'Cz', 'FC2', 'C4', 'CP2'};
Channels.clusterR = {'FC2', 'CP2', 'C4', 'FC6', 'CP6'};
Channels.clusterL = {'FC1', 'CP1', 'C3', 'FC5', 'CP5'};

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
    Col_channels  = [];
    Col_power     = [];
    Col_trialinfo = [];
    Col_frequency = [];
    
        
    % Select specified frequenceis     
    cfg = [];
    cfg.frequency   = Frequencies.value;
    cfg.avgoverfreq = 'yes';
    cfg.channel     = [Channels.motor Channels.occipital, Channels.clusterC,Channels.clusterL,Channels.clusterR];
    avg = ft_selectdata(cfg, Freq_data) ;

    rep = size(avg.powspctrm,1);
    cha = size(avg.powspctrm,2);

    % Extraxt the values to table
    Col_channels =  repelem(avg.label,rep);
    Col_power = reshape(avg.powspctrm.',1,[])';

    Col_trialinfo = repmat(avg.trialinfo,length(avg.label),1);
    Col_frequency = repmat(Frequencies.name,rep*length(avg.label),1);
    Col_subject   = repmat(Subject,rep*cha,1);
    Col_trialinfo = num2str(Col_trialinfo);
    Col_trialinfo = Col_trialinfo(:,2);

    % Video training extraction
    Watched      = VideoWatching(RawPath,Subject);
    Col_training = repmat(Watched,rep*cha,1);
    
    CV = table(Col_subject, Col_frequency, Col_channels, Col_trialinfo, Col_training, Col_power );
    CV.Properties.VariableNames = {'Id','Frequency','Channels','Trial','Training','Power'};

    writetable(CV,[Files(file).folder '\DF.csv']);
    
    % Clean for next subject
    clear Freq_data CV Freq_data Subject avg Watched
    clear Col*
    
end




