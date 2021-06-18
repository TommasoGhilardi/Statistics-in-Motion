
%% ========================% Setting up %======================= %%

% Fieltrip settings
if ~exist('ft_defaults', 'file')
    addpath('C:\Users\krav\Documents\Matlab\fieldtrip');    % add fieltrip as your toolbox
    ft_defaults();      % set all the default fieltrip functions
end

% Data Subject settings
OutPath = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Out\';

% Find all the data
Files = dir([OutPath, '**\Prediction\Clean.mat']);

% Channels of interest definition
Channels.motor     = {'C3','Cz','C4'};
Channels.occipital = {'O1','Oz','O2'};

% Frequencies
% Define the frequencies from action execution phase
Frequencies.value = [9 11; 17 20];
Frequencies.names = ["alpha"; "beta"];

%% Extract Frequencies
for file  =  1:length(Files)
    load([Files(file).folder,'\Clean.mat' ]);
    
    Subject = art_final_data.subjetc;
    art_final_data = rmfield(art_final_data,'subjetc');
    
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
    
    
    %% ========================% CSV export %======================= %%
    Col_channels  = [];
    Col_power     = [];
    Col_trialinfo = [];
    Col_frequency = [];
    rep = length(Freq_data.powspctrm);
    
    for x = 1:length(Frequencies.names)

        cfg = [];
        cfg.frequency   = [Frequencies.value(x,1) Frequencies.value(x,2)] ;
        cfg.avgoverfreq = 'yes';
        cfg.channel     = [Channels.motor Channels.occipital];
        avg = ft_selectdata(cfg, Freq_data) ;

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
    Col_subject   = repmat(Subject,rep*length(avg.label)*2,1);

    Col_trialinfo = num2str(Col_trialinfo);
    Col_trialinfo = Col_trialinfo(:,2);

    CV = table(Col_subject, Col_frequency, Col_channels, Col_trialinfo, Col_power );
    CV.Properties.VariableNames = {'Id','Frequency','Channels','Trial','Power'};

    writetable(CV,[Files(file).folder '\DF.csv']);
    
    % Clean for next subject
    clear Freq_data CV art_final_data Subject  
    clear Col*
    
end




