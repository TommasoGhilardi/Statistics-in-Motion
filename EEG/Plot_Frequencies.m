
%% ========================% Setting up %======================= %%

% Data Subject settings
Path = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Processed\';

% Channels of interest definition
Channels.motor = {'C3','Cz','C4'};


%% Execution data concatenation

% Find all the data
Files = dir([Path, '**\Execution\FFT.mat']);

% Read and concatenate the data 
for file  =  1:length(Files)
    load([Files(file).folder,'\FFT.mat' ]);

    cfg = [];
    cfg.channel = Channels.motor;
    cfg.avgoverrpt  = 'yes';
    cfg.nanmean     = 'yes';
    cfg.avgoverchan = 'yes';

    dat(file) = ft_selectdata(cfg, Freq_data);
    
    clear Freq_data
end

% Select subjects you want to include
cfg = [];
EX  = ft_appendfreq(cfg, dat(1), dat(2), dat(3),dat(4), dat(5), dat(6), dat(7), dat(8), dat(9),dat(10),dat(11));

clear Files dat


%% Prediction (fixation cross) data concatenation

% Find all the data
Files = dir([Path, '**\Prediction\FFT.mat']);

% Read and concatenate the data 
for file  =  1:length(Files)
    load([Files(file).folder,'\FFT.mat' ]);

    Freq_data = rmfield(Freq_data,"subject" );

    cfg = [];
    cfg.channel = Channels.motor;
    cfg.avgoverrpt  = 'yes';
    cfg.nanmean     = 'yes';
    cfg.avgoverchan = 'yes';

    dat(file) = ft_selectdata(cfg, Freq_data);
    
    clear Freq_data
end

% Select subjects you want to include
cfg = [];
BA  = ft_appendfreq(cfg, dat(1), dat(2), dat(3),dat(4), dat(5), dat(6), dat(7), dat(8), dat(9),dat(10),dat(11));

clear Files dat


%% Plot the data

EX_M = mean(EX.powspctrm(:,:),1);
BA_M = mean(BA.powspctrm(:,:),1);

EX_SD = std(EX.powspctrm(:,:));
BA_SD = std(BA.powspctrm(:,:));

% Raw powers
figure;
subplot(2,1,1);
hold on
fill([2:30, fliplr(2:30)], [EX_M+EX_SD, fliplr(EX_M-EX_SD)], [0.85,0.33,0.10],'facealpha',.3);
fill([2:30, fliplr(2:30)], [BA_M+BA_SD, fliplr(BA_M-BA_SD)], [0.00,0.45,0.74],'facealpha',.3);
plot(2:30, EX_M,'LineWidth',2,'Color',[0.85,0.33,0.10]) 
plot(2:30, BA_M,'LineWidth',2,'Color',[0.00,0.45,0.74])
legend('Execution','Baseline')
xlim([2,30]);
ylim([-5,60])
% set(gca,'Xticklabel',[]) %to just get rid of the numbers but leave the ticks.
% % ax = gca
% % ax.YAxis.FontSize = 20


set(gca,'XTickLabel',[],'FontName','Times','fontsize',24)
lab1 = get(gca,'YTickLabel');
set(gca,'YTickLabel',lab1,'FontName','Times','fontsize',24)


% Extract peaks
difference = BA_M-EX_M;

[pks,locs,widths,proms] = findpeaks(difference);
Xpeaks = locs( locs>6 & locs<12);
Ypeaks = pks(locs>6 & locs<12);

% Plot difference
subplot(2,1,2);
hold on
plot(2:30,difference,'LineWidth',2,'color', 'k')
plot(Xpeaks+1,Ypeaks,'o','MarkerSize',8,'LineWidth',2, 'color', 'r')
legend('Difference')

xlim([2,30]);
ylim([-120,10])

lab2 = get(gca,'XTickLabel');
set(gca,'XTickLabel',lab2,'FontName','Times','fontsize',24)
lab3 = get(gca,'YTickLabel');
set(gca,'YTickLabel',lab3,'FontName','Times','fontsize',24)
