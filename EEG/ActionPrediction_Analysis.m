
%% ========================% Setting up %======================= %%
% 3 trials for 2
% at least 19 channels
clear;
clc;

% Function to check if there are nans
CheckNana = @(vv) ~any(any(isnan(vv)));  

% Set script directory
PATH = matlab.desktop.editor.getActiveFilename;
cd(PATH(1:strfind(PATH,'ActionPrediction_Analysis.m')-1));

% Data Subject settings
InPath  = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Bids\';       %location of the participant data
OutPath = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\BidsProcessed\';
Subject = 'sub-06';

% Create output folder if it dosen't exist
if ~exist([OutPath Subject], 'dir')
   mkdir([OutPath Subject])
   mkdir([OutPath Subject '\Prediction'])
   mkdir([OutPath Subject '\Execution'])
end

SavingLocation = [OutPath Subject '\Prediction\'];

% Triggers specification
Triggers.fixation_cross = 50;
Triggers.predictive_window.low           = [11,21,31,41];
Triggers.predictive_window.medium        = [12,22,32,42];
Triggers.predictive_window.high          = [13,23,33,43];
Triggers.predictive_window.deterministic = [14,24,34,44];

% Cap configuration used to plot with layout
cap_conf = 'acticap-64ch-standard2.mat';

% Prepare neighbouring channels
cfg = [];
cfg.layout = cap_conf;
cfg.method = 'triangulation';
cfg.compress = 'yes';
% cfg.feedback = 'yes';
neighbours = ft_prepare_neighbours(cfg);


%% ========================% Define trials and read data %======================= %%

%%%%% Segmenting definition %%%%%
cfg                         = [];
cfg.sub                     = Subject;
cfg.dataset                 = fullfile(InPath,Subject,'eeg', [Subject '_eeg.eeg']);
cfg.trialfun                = 'PredictionSegmentation';
cfg.trialdef.eventtype      = 'Stimulus';
cfg = ft_definetrial(cfg);

%%%%% Read data and segment %%%%%
cfg.hpfilter    = 'yes';        % enable high-pass filtering
cfg.lpfilter    = 'yes';        % enable low-pass filtering
cfg.hpfreq      = 1;            % set up the frequency for high-pass filter
cfg.lpfreq      = 40;
cfg.detrend     = 'yes';
data = ft_preprocessing(cfg); % read raw data

if isequal(data.label{end},'FP1')
    data.label{end} = 'Fp1';
end

%%%% Plot %%%%
cfg = [];
cfg.viewmode = 'vertical';
waitfor(ft_databrowser(cfg, data));
save([SavingLocation 'Epoched.mat'],'data');


%% ========================% ICA %======================= %%

%%%%% Initial visual rejection with summary %%%%%
cfg = [];
cfg.metric      = 'kurtosis';  % use by default kurtosis method
cfg.method      = 'summary'; % use by default summary method
cfg.keepchannel = 'repair';
cfg.keeptrial   = 'no';

cfg.neighbours = neighbours;
art1_data       = ft_rejectvisual(cfg,data);
save([SavingLocation 'Summary1.mat'],'art1_data');

%%%%% ICA %%%%%
cfg             = [];
cfg.trials      = cellfun(CheckNana, art1_data.trial);
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

% Databrowser visualization
cfg = [];
cfg.layout = cap_conf;
cfg.component   = {'runica001'};
cfg.viewmode = 'component';
waitfor(ft_databrowser(cfg, components));

% Confirm the selected 
prompt      = {'Confirm components: '};
dlgtitle    = 'Input';
dims        = [1 60];
definput    = {int2str(reject)};
answer      = inputdlg(prompt,dlgtitle,dims,definput);
reject_f    = str2num(char(answer{1}));
close all

% Rejecting
cfg             = [];
cfg.demean      = 'no';
cfg.component   = reject_f; % to be removed component(s)
ica_data = ft_rejectcomponent(cfg, components, art1_data);
save([SavingLocation 'ICA.mat'],'ica_data');


%% ========================% Trials Selection %======================= %%

%%%%% Select trials of interest %%%%%
cfg        = [];
cfg.trials = ismember(ica_data.trialinfo , [Triggers.predictive_window.low,...
    Triggers.predictive_window.medium, Triggers.predictive_window.high...
    Triggers.predictive_window.deterministic, Triggers.fixation_cross]);
Selected_trials = ft_selectdata(cfg, ica_data);

%%%%% Reject the trials that were excluded with videocoding %%%%%
cfg      = [];
cfg.sub  = Subject;
cfg.file = [InPath 'VideoRejection.csv'];
Selected_trials = RejectVisualCoding(cfg, Selected_trials);
save([SavingLocation 'SelectedTrials.mat'],'Selected_trials');


%% ========================% Final visual rejection %======================= %%

% Summary view
cfg = [];
cfg.metric      = 'kurtosis';  % use by default kurtosis method
cfg.method      = 'summary'; % use by default summary method
cfg.keepchannel = 'repair';
cfg.neighbours  = neighbours;
art2_data = ft_rejectvisual(cfg,Selected_trials);
save([SavingLocation 'Summary2.mat'],'art2_data');


% Trial rejection
cfg = [];
cfg.method      = 'trial';
cfg.keepchannel = 'repair';
cfg.neighbours  = neighbours;
art_final_data = ft_rejectvisual(cfg,art2_data);


% Rereferencing to average
cfg = [];
cfg.reref = 'yes';
cfg.refmethod = 'avg';
cfg.refchannel = 'all';
art_final_data = ft_preprocessing(cfg, art_final_data);

art_final_data.subjetc = Subject;
save([SavingLocation 'Clean.mat'],'art_final_data');


%% ========================% Show trial distribution %======================= %%

repetition = rem(art_final_data.trialinfo,10);
[cnt_unique, unique] = hist(repetition,unique(repetition));
T = array2table([unique, cnt_unique'], 'VariableNames',{'Type','Count'}); 

disp(T);
disp(int2str(cnt_unique));

clear T *unique








