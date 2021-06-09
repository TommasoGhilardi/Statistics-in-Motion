
%% ========================% Setting up %======================= %%

% Fieltrip settings
addpath('C:\Users\krav\Documents\Matlab\fieldtrip');    % add fieltrip as your toolbox
ft_defaults();      % set all the default fieltrip functions

% Data Subject settings
OutPath = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Out\';

% Find all the data
Files = dir([OutPath, '**\Execution\FFT.mat']);


%% ========================% Read and concatenate the data %======================= %%

for file  =  1:length(Files)
    load([Files(file).folder,'\FFT.mat' ]);
    
    if exist('db', 'var')
        cfg = [];
        db = ft_appendfreq(cfg, db, Freq_data);
    else
        db = Freq_data;
    end
    clear Freq_data;
    
end


%% Plot the data

cfg= [];
cfg.channel = {'C3','Cz','C4'};
cfg.parameter =  'powspctrm';
ft_singleplotER(cfg,db)
