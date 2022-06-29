
%% ========================% Setting up %======================= %%
clear;
clc;

% Data Subject settings
Path = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Processed\';

% Channels of interest definition
Channels.motor = {'C3','Cz','C4'};

blu_area    = [128 193 219]./255;    % Blue theme
blu_line    = [ 52 148 186]./255;
orange_area = [243 169 114]./255;    % Orange theme
orange_line = [236 112  22]./255;

%% Execution data concatenation

% Find all the data
Files = dir([Path, '**\Execution\FFT.mat']);

% Read and concatenate the data 
for file  =  1:length(Files)
    load([Files(file).folder,'\FFT.mat' ]);

    if exist('EX','var') == 1
       cfg = [];
       cfg.appendim = 'rpt';
       EX = ft_appendfreq(cfg, EX, Freq_data);
    else
       EX = Freq_data;   
    end
    
    clear Freq_data
end

clear Files 

% Select only fixation
cfg = [];
cfg.avgoverrpt  = 'yes';
cfg.nanmean     = 'yes';
cfg.channel    =  Channels.motor;
% cfg.avgoverchan = 'yes';
EX = ft_selectdata(cfg, EX);


%% Prediction (fixation cross) data concatenation

% Find all the data
Files = dir([Path, '**\Prediction\FFT.mat']);

% Read and concatenate the data 
for file  =  1:length(Files)
    load([Files(file).folder,'\FFT.mat' ]);

    if exist('Pre','var') == 1
       cfg = [];
       cfg.appendim = 'rpt';
       Pre = ft_appendfreq(cfg, Pre, Freq_data);
    else
       Pre = Freq_data;   
    end
    
    clear Freq_data
end

clear Files 

% Select only fixation
cfg = [];
cfg.avgoverrpt  = 'yes';
cfg.nanmean     = 'yes';
% cfg.avgoverchan = 'yes';
cfg.channel    =  Channels.motor;
cfg.trials      = Pre.trialinfo == 50;
BA = ft_selectdata(cfg, Pre);


%% Plot the data

EX_M = squeeze(mean(EX.powspctrm,1));
BA_M = squeeze(mean(BA.powspctrm,1));

EX_SD = squeeze(std(EX.powspctrm,1));
BA_SD = squeeze(std(BA.powspctrm,1));

EX_Err = (EX_SD/sqrt(size(EX.powspctrm,1)));
BA_Err = (BA_SD/sqrt(size(BA.powspctrm,1)));

% Raw powers
figure;
subplot(2,1,1);
hold on
fill([2:30, fliplr(2:30)], [EX_M+EX_Err, fliplr(EX_M-EX_Err)], blu_area,'facealpha',.5,'LineStyle','none');
fill([2:30, fliplr(2:30)], [BA_M+BA_Err, fliplr(BA_M-BA_Err)], orange_area,'facealpha',.5,'LineStyle','none');
plott(1) = plot(2:30, EX_M,'LineWidth',2,'Color',blu_line);
plott(2) = plot(2:30, BA_M,'LineWidth',2,'Color',orange_line);
ylabel('Power');
legend(plott,{'Execution','Baseline'});
xlim([2,30]);
ylim([-2,45])
set(gca,'Xticklabel',[]) %to just get rid of the numbers but leave the ticks.

set(gca,'XTickLabel',[],'FontName','Times','fontsize',24)
lab1 = get(gca,'YTickLabel');
set(gca,'YTickLabel',lab1,'FontName','Times','fontsize',24)


% Extract peaks
difference = EX_M-BA_M;
[pks,locs,widths,proms] = findpeaks(-difference);

Xpeaks = locs( locs>2 & locs<10);
Ypeaks = pks(locs>2 & locs<10);

% Plot difference
subplot(2,1,2);
hold on
plot(2:30,difference,'LineWidth',2.5,'color', 'k')
xlabel('Frequency (Hz)');
ylabel('Power');
legend('Difference')
plot(Xpeaks+1,-Ypeaks,'o','MarkerSize',8,'LineWidth',2, 'color', 'r')
% yline(0, '--k','LineWidth',2,'Alpha',0.3)


%%% Frequency indicators
% Writin the labels of the points
for x = 1:length(Xpeaks)
    text(Xpeaks(x)+1.5,-Ypeaks(x),num2str(Xpeaks(x)+1),'FontSize',16)
end

%add square 
rectangle('Position',[7 -5 2 100],'FaceColor',[0 0 0 0.1],'EdgeColor',[0 0 0 0.1]...
    ,'Curvature',0.1);


%%% Text of the plots

xlim([2,30]);
ylim([-5,10])
lab2 = get(gca,'XTickLabel');
set(gca,'XTickLabel',lab2,'FontName','Times','fontsize',24)
lab3 = get(gca,'YTickLabel');
set(gca,'YTickLabel',lab3,'FontName','Times','fontsize',24)












