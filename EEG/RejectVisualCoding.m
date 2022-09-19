
function [DATA] = RejectVisualCoding(Configuration, datafile)

% Read the CSV
colnames  = {'BeginTime_msec','EndTime_msec','Duration_msec','Goodness',...
    'Annotations','ActionExecution','File','File Path'};

T = readtable(Configuration.file, 'Delimiter',',','ReadVariableNames',false);
T.Properties.VariableNames = colnames;
T_Subject = T(contains(T{:, 'File Path'}, Configuration.sub),:); %select specific subject


%%%% Check if there is the same number of trials between videocoding and EEG %%%%
Trials = T_Subject(ismember( T_Subject{:,'Goodness'}, {'Accept', 'Reject'}),:);

%Fixing up subject 30(eeg recording started late)
if endsWith(Configuration.sub,'30')
    cut = -(length(datafile.trialinfo) - length(Trials{:,'Goodness'}))+1;
    Trials = Trials(cut:end,:);
end

% Adjust sub 60
if Configuration.sub == "S_Stat_60" 
        Trials = Trials(1:length(datafile.trial),:);
       
end


if length(Trials{:,'Goodness'}) ~= length(datafile.trialinfo)

    % Error if the number is different
    error(['Error!!!!!!!!!' newline ... 
        'Trials defined during videocoding mismatch trials in the EEG data.' newline ...
        'Please check the videocoding or the trialdefinition' newline ...
        num2str(length(Trials{:,'Goodness'})) ' - ' ...
        num2str(length(datafile.trialinfo))]);      
else
    
    % If it the same number elimintaes the bad ones
    GoodOnes = ~ismember( Trials{:,'Goodness'}, 'Reject');
    
    cfg        = [];
    cfg.trials = GoodOnes;
    DATA = ft_selectdata(cfg, datafile);
        
end


end







