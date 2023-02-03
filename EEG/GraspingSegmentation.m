function [trl, event] = GraspingSegmentation(cfg)

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

%Fixing up subject 30(eeg recording started late)
if endsWith(cfg.sub,'30')
    
    % Triggers specification
    Triggers.fixation_cross = 50;
    Triggers.predictive_window.low           = [11,21,31,41];
    Triggers.predictive_window.medium        = [12,22,32,42];
    Triggers.predictive_window.high          = [13,23,33,43];
    Triggers.predictive_window.deterministic = [14,24,34,44];
    
    PositionTriggers = cellfun(@(c)ismember(str2double(c(2:end)) , [Triggers.predictive_window.low,...
    Triggers.predictive_window.medium, Triggers.predictive_window.high...
    Triggers.predictive_window.deterministic, Triggers.fixation_cross]), {event.value});
    PositionTriggers = find(PositionTriggers);
   
    % search last event even if not fixation
    FirstFixation = event(PositionTriggers(end)).sample;
else
    
    % search for first  event
    Fixations = find(strcmp('S 50', {event.value}));
    FirstFixation = event(Fixations(1)).sample;
    
end




% Read the CSV
colnames  = {'BeginTime_msec','EndTime_msec','Duration_msec','Goodness',...
    'Annotations','ActionExecution','File','Subject'};

T = readtable(cfg.csv, 'Delimiter',',','ReadVariableNames',false);
T.Properties.VariableNames = colnames;
T_Subject = T(contains(T{:, 'Subject'}, cfg.sub),:); %select specific subject

if endsWith(cfg.sub,'30')
    % Center on the first video fixation
    Movements = T_Subject(ismember( T_Subject{:,'Goodness'}, {''}),:);
    onlyPrediction = T_Subject(~ismember( T_Subject{:,'Goodness'}, {''}),:);
    Movements{:,'BeginTime_msec'} = Movements{:,'BeginTime_msec'} - onlyPrediction{end,'BeginTime_msec'};
    Movements{:,'EndTime_msec'} = Movements{:,'EndTime_msec'} - onlyPrediction{end,'BeginTime_msec'};
    
else
    
    % Center on the first video fixation
    Movements = T_Subject(ismember( T_Subject{:,'Goodness'}, {''}),:);
    Movements{:,'BeginTime_msec'} = Movements{:,'BeginTime_msec'} - T_Subject{1,'BeginTime_msec'};
    Movements{:,'EndTime_msec'} = Movements{:,'EndTime_msec'} - T_Subject{1,'BeginTime_msec'};
    
end


% Create the TRL centered to the first fixation
trl = [];
trl(:,1) = round(Movements{:,'BeginTime_msec'}/(1000/hdr.Fs) + FirstFixation);
trl(:,2) = round(Movements{:,'EndTime_msec'}/(1000/hdr.Fs) + FirstFixation);
trl(:,3) = -round(cfg.trialdef.prestim * hdr.Fs);
trl(trl(:,1)> hdr.nSamples,:)=[];
trl(trl(:,2)> hdr.nSamples,2)=hdr.nSamples;

end







