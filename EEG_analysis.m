
%% ========================% Setting up %======================= %%

% Fieltrip settings
addpath('C:\Users\krav\Documents\Matlab\fieldtrip');    % add fieltrip as your toolbox
ft_defaults();      % set all the default fieltrip functions

% Data Subject settings
Path = 'C:\Users\krav\Desktop\BabyBrain\Internship\Monique\Analysis\';       %location of the participant data
Subject = 'p1';

% Triggers specification
Triggers.fixation_cross = 'S 50';
Triggers.predictive_window.low           = {'S 11','S 21','S 31','S 41'};
Triggers.predictive_window.medium        = {'S 12','S 22','S 32','S 42'};
Triggers.predictive_window.high          = {'S 13','S 23','S 33','S 43'};
Triggers.predictive_window.deterministic = {'S 14','S 24','S 34','S 44'};

% Channels of interest definition
Channels.motor = {'C3','Cz','C4'};
Channels.occipital = {'O1','Oz','O2'};

% Frequencies
Frequencies.value   = [9 11; 17 20];
Frequencies.names = ['alpha'; 'beta'];

% Cap configuration used to plot with layout
cap_conf = 'acticap-64ch-standard2.mat';


%% ========================% Define trials and read data %======================= %%

%%%%% Segmenting definition %%%%%
cfg                         = [];
cfg.dataset                 = [Path,Subject,'.eeg'];
cfg.trialdef.eventtype      = 'Stimulus';
cfg.trialdef.eventvalue     = [Triggers.predictive_window.low,...
    Triggers.predictive_window.medium, Triggers.predictive_window.high...
    Triggers.predictive_window.deterministic, Triggers.fixation_cross]; % the value of the stimulus trigger for fully incongruent (FIC).
cfg.trialdef.prestim        = 0.25; % in seconds
cfg.trialdef.poststim       = 1.25; % in seconds
cfg = ft_definetrial(cfg);

%%%%% read data and segment %%%%%
cfg.hpfilter    = 'yes';        % enable high-pass filtering
cfg.lpfilter    = 'yes';        % enable low-pass filtering
cfg.hpfreq      = 1;            % set up the frequency for high-pass filter
cfg.lpfreq      = 40;
cfg.detrend     = 'yes';
cfg.demean      = 'yes';    
data = ft_preprocessing(cfg); % read raw data

if isequal(data.label{end},'FP1')
    data.label{end} = 'Fp1';
end

%%%% Plot %%%%
cfg = [];
cfg.viewmode = 'vertical';
ft_databrowser(cfg, data);


%% ========================% Artifacts %======================= %%

%%%%% Initial visual rejection with summary %%%%%
cfg = [];
cfg.metric      = 'kurtosis';  % use by default kurtosis method
cfg.method      = 'summary'; % use by default summary method
cfg.latency     = [0 1];
art1_data       = ft_rejectvisual(cfg,data);


%%%%% ICA %%%%%
cfg             = [];
cfg.method      = 'runica'; % default implementation from EEGLAB
components      = ft_componentanalysis(cfg, art1_data);

% plot the components for visual inspection
figure('units','normalized','outerposition',[0 0 1 1])
cfg             = [];
cfg.marker      = 'labels';
cfg.component   = 1:20;       % specify the component(s) that should be plotted
cfg.layout      = cap_conf;   % specify the layout file that should be used for plotting
cfg.comment     = 'no';
ft_topoplotIC(cfg, components)

% Select the ones you don't initially like 
prompt      = {'Components to reject: '};
dlgtitle    = 'Input';
dims        = [1 60];
answer      = inputdlg(prompt,dlgtitle,dims);
reject      = str2num(char(answer{1}));

close all

% Control the components
% cfg = [];
% cfg.rejcomp  = reject;
% cfg.powscale = 'linear';
% cfg.layout   = cap_conf; % specify the layout file that should be used for plotting
% reject = ft_icabrowser(cfg, components);

% Rejecting
cfg             = [];
cfg.component   = answer; % to be removed component(s)
ica_data = ft_rejectcomponent(cfg, components, art1_data);


%%%%% Final visual rejection %%%%%

% Summary view
cfg = [];
cfg.metric      = 'kurtosis';  % use by default kurtosis method
cfg.method      = 'summary'; % use by default summary method
cfg.keepchannel = 'nan';
art2_data = ft_rejectvisual(cfg,ica_data);

% Trial rejection
cfg = [];
cfg.method  = 'trial';
cfg.keepchannel = 'nan';
cfg.latency     = [0 1];
art_final_data = ft_rejectvisual(cfg,art2_data);


%% ========================% Frequencies Extraction %======================= %%

% Cut the data
cfg = [];
cfg.toilim = [0 1];
art_final_data = ft_redefinetrial(cfg, art_final_data);

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

writetable(T,[Path Subject '_data.csv'])



