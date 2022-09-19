
%% ========================% Setting up %======================= %%
clear;
clc;

% Data Subject settings
RawPath  = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Raw_data\';       %location of the participant data
ProcessedPath = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Processed\';

% Find all the data
Files = dir([ProcessedPath, '**\Prediction\FFT.mat']);

% Channels of interest definition
Channels.motor     = {'C3','Cz','C4'};
Channels.occipital = {'O1','Oz','O2'};

% Frequencies
% Define the frequencies from action execution phase
Frequencies.value = [7 9; 12 14];
Frequencies.names = ["mu", "beta"];


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
    
    for x = 1:length(Frequencies.names)
        
        % Select specified frequenceis     
        cfg = [];
        cfg.frequency   = [Frequencies.value(x,1) Frequencies.value(x,2)] ;
        cfg.avgoverfreq = 'yes';
        cfg.channel     = [Channels.motor Channels.occipital];
        avg = ft_selectdata(cfg, Freq_data) ;
        
        rep = size(avg.powspctrm,1);
        cha = size(avg.powspctrm,2);
        
        % Extraxt the values to table
        Col_channels = [Col_channels; repmat( avg.label(1),rep,1);...
            repmat( avg.label(2),rep,1);...
            repmat( avg.label(3),rep,1);...
            repmat( avg.label(4),rep,1);...
            repmat( avg.label(5),rep,1);...
            repmat( avg.label(6),rep,1)];

        Col_power = [Col_power; avg.powspctrm(:,1); avg.powspctrm(:,1); avg.powspctrm(:,2);...
            avg.powspctrm(:,3); avg.powspctrm(:,4); avg.powspctrm(:,5)];

        Col_trialinfo = [Col_trialinfo; repmat(avg.trialinfo,length(avg.label),1)];
        Col_frequency = [Col_frequency; repmat(Frequencies.names(x),rep*length(avg.label),1)];
    end
    Col_subject   = repmat(Subject,rep*cha*length(Frequencies.names),1);

    Col_trialinfo = num2str(Col_trialinfo);
    Col_trialinfo = Col_trialinfo(:,2);

    % Video training extraction
    Watched      = VideoWatching(Subject);
    Col_training = repmat(Watched,rep*cha*length(Frequencies.names),1);
    
    CV = table(Col_subject, Col_frequency, Col_channels, Col_trialinfo, Col_training, Col_power );
    CV.Properties.VariableNames = {'Id','Frequency','Channels','Trial','Training','Power'};

    writetable(CV,[Files(file).folder '\DF.csv']);
    
    % Clean for next subject
    clear Freq_data CV Freq_data Subject avg Watched
    clear Col*
    
end



