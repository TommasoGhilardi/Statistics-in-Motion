
%% ========================% Setting up %======================= %%
addpath('C:\Users\krav\Documents\Matlab\fieldtrip');
ft_defaults();

file_location = 'C:\Users\krav\Desktop\BabyBrain\Internship\Monique\Analysis\p1.eeg';

Triggers.fixation_cross = 'S 50';
Triggers.predictive_window.low           = {'S 11','S 21','S 31','S 41'};
Triggers.predictive_window.medium1       = {'S 12','S 22','S 32','S 42'};
Triggers.predictive_window.medium2       = {'S 13','S 23','S 33','S 43'};
Triggers.predictive_window.high1         = {'S 14','S 24','S 34','S 44'};
Triggers.predictive_window.high2         = {'S 15','S 25','S 35','S 45'};
Triggers.predictive_window.deterministic = {'S 16','S 26','S 36','S 46'};

cap_conf = 'acticap-64ch-standard2.mat';


%% ========================% Define trials and read data %======================= %%

%%%%% Segmenting definition %%%%%
cfg                         = [];
cfg.dataset                 = file_location;
cfg.trialdef.eventtype      = 'Stimulus';
cfg.trialdef.eventvalue     = [Triggers.predictive_window.low,...
    Triggers.predictive_window.medium1,Triggers.predictive_window.medium2...
    Triggers.predictive_window.high1, Triggers.predictive_window.high2...
    Triggers.predictive_window.deterministic, Triggers.fixation_cross]; % the value of the stimulus trigger for fully incongruent (FIC).
cfg.trialdef.prestim        = 0; % in seconds
cfg.trialdef.poststim       = 1; % in seconds
cfg = ft_definetrial(cfg);

%%%%% read data and segment %%%%%
cfg.hpfilter    = 'yes';        % enable high-pass filtering
cfg.lpfilter    = 'yes';        % enable low-pass filtering
cfg.hpfreq      = 1;           % set up the frequency for high-pass filter
cfg.lpfreq      = 40;
cfg.detrend     = 'yes';
cfg.demean      = 'yes';    
data          = ft_preprocessing(cfg); % read raw data

if isequal(data.label{end},'FP1')
    data.label{end} = 'Fp1';
end

%%%% plot %%%%
cfg = [];
cfg.viewmode = 'vertical';
ft_databrowser(cfg, data);

%% ========================% Artifacts %======================= %%

%%%%% Initial visual rejection with summary %%%%%
cfg = [];
cfg.metric      = 'kurtosis';  % use by default zvalue method
cfg.method      = 'summary'; % use by default summary method
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
cfg.layout      = cap_conf; % specify the layout file that should be used for plotting
cfg.comment     = 'no';
ft_topoplotIC(cfg, components)

% select the ones you don't initially like 
prompt      = {'Components to reject: '};
dlgtitle    = 'Input';
dims        = [1 60];
answer      = inputdlg(prompt,dlgtitle,dims);
answer      = str2num(char(answer{1}));

% Control the components
cfg = [];
cfg.rejcomp  = answer;
cfg.powscale = 'linear';
cfg.layout   = cap_conf; % specify the layout file that should be used for plotting
reject = ft_icabrowser(cfg, components);

%rejecting
cfg             = [];
cfg.component   = answer; % to be removed component(s)
ica_data          = ft_rejectcomponent(cfg, components, art1_data);


%%%%% Final visual rejection %%%%%

% Summary view
cfg = [];
cfg.metric      = 'kurtosis';  % use by default zvalue method
cfg.method      = 'summary'; % use by default summary method
art2_data          = ft_rejectvisual(cfg,ica_data);

% Trial rejection
cfg = [];
cfg.method  = 'trial';
art_final_data      = ft_rejectvisual(cfg,art2_data);






