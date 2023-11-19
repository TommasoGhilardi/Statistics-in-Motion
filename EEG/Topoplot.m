
%% ========================% Setting up %======================= %%
clear;
clc;

% Data Subject settings
RawPath  = 'C:\Users\tomma\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Bids\';       %location of the participant data
ProcessedPath = 'C:\Users\tomma\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\ProcessedBids\';

%cap configuration
cap_conf = 'acticap-64ch-standard2.mat';

% Find all the data
Files = dir([ProcessedPath, '**\Prediction\FFT.mat']);


% Frequencies
% Define the frequencies from action execution phase
Frequencies.value = [7 9];
Frequencies.name = "mu";

% Triggers ID
Triggers.fixation_cross = 50;
Triggers.predictive_window.low              = [11,21,31,41];
Triggers.predictive_window.medium           = [12,22,32,42];
Triggers.predictive_window.high             = [13,23,33,43];
Triggers.predictive_window.deterministic    = [14,24,34,44];


%% Combine data

for file  = 1:length(Files)
    load([Files(file).folder,'\FFT.mat' ]);
    Freq_data = rmfield(Freq_data,'subject');

    Freq_data.powspctrm = log10(Freq_data.powspctrm);
    
    %% Extract each trial
    
    cfg = [];
    cfg.avgoverrpt  = 'yes';
    cfg.nanmean     = 'yes';


    % Expectancy
    cfg.trials      = find(ismember(Freq_data.trialinfo, Triggers.fixation_cross));
    base            = ft_selectdata(cfg, Freq_data);
    
    cfg.trials      = find(ismember(Freq_data.trialinfo, Triggers.predictive_window.low));
    low             = ft_selectdata(cfg, Freq_data);
    
    cfg.trials      = find(ismember(Freq_data.trialinfo, Triggers.predictive_window.medium));
    medium          = ft_selectdata(cfg, Freq_data);
    
    cfg.trials      = find(ismember(Freq_data.trialinfo, Triggers.predictive_window.high));
    high            = ft_selectdata(cfg, Freq_data);
    
    cfg.trials      = find(ismember(Freq_data.trialinfo, Triggers.predictive_window.deterministic));
    det             = ft_selectdata(cfg, Freq_data);
    
    
        
    %% Export as cell array
    
    if ~isnan(base.powspctrm)    Base{file}    = base ;    end    
    if ~isnan(low.powspctrm)    Low{file}     = low ;     end    
    if ~isnan(medium.powspctrm) Medium{file}  = medium;   end
    if ~isnan(high.powspctrm)   High{file}    = high;     end
    if ~isnan(det.powspctrm)    Det{file}     = det;      end        
        
    clear Freq_data medium low base high det
end
    
% Baseline corrections
for x= 1:length(Base)
    if ~isempty(Low{x})     Low{x}.powspctrm    = Low{x}.powspctrm - Base{x}.powspctrm;     end
    if ~isempty(Medium{x})  Medium{x}.powspctrm = Medium{x}.powspctrm - Base{x}.powspctrm;  end
    if ~isempty(High{x})     High{x}.powspctrm   = High{x}.powspctrm - Base{x}.powspctrm;    end
    if ~isempty(Det{x})     Det{x}.powspctrm	= Det{x}.powspctrm - Base{x}.powspctrm;     end
end

% Remove empty cells
Low     = Low(~cellfun('isempty',Low));
Medium  = Medium(~cellfun('isempty',Medium));
High    = High(~cellfun('isempty',High));
Det     = Det(~cellfun('isempty',Det));


%% Concatenate different subjects
cfg = [];
Low         = ft_appendfreq(cfg,Low{:});
Medium      = ft_appendfreq(cfg,Medium{:});
High        = ft_appendfreq(cfg,High{:});
Det         = ft_appendfreq(cfg,Det{:});

% Average
cfg = [];
cfg.avgoverrpt = 'yes';
Low         = ft_selectdata(cfg,Low);
Medium      = ft_selectdata(cfg,Medium);
High        = ft_selectdata(cfg,High);
Det         = ft_selectdata(cfg,Det);


%% Topoplots Mu

% Common
cfg = [];
cfg.layout  = cap_conf;
cfg.xlim    = Frequencies.value;  
cfg.zlim    = [-0.16 0.16];
cfg.comment =  'no';         
cfg.colorbar = 'no';

cfg.colormap = 'jet';
fontsize= 35;

figure;
cfg.figure = subplot(2,2,1);
ft_topoplotER(cfg, Low);
t = title('25%');
t.FontSize = 25;

cfg.figure = subplot(2,2,2);
ft_topoplotER(cfg, Medium);
t = title('50%');
t.FontSize = 25;

cfg.figure = subplot(2,2,3);
ft_topoplotER(cfg, High);
t = title('75%');
t.FontSize = 25;

cfg.figure = subplot(2,2,4);
ft_topoplotER(cfg, Det);
t = title('100%');
t.FontSize = 25;

sgtitle('Mu rhythm difference with baseline',fontsize=fontsize)
    



    
    
    
    