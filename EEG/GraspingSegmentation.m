function [trl, event] = GraspingSegmentation(cfg)

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% search for first  event
Fixations = find(strcmp('S 50', {event.value}));
FirstFixation = event(Fixations(1)).sample;

% Read the CSV
colnames  = {'BeginTime_msec','EndTime_msec','Duration_msec','Goodness',...
    'Annotations','ActionExecution','File','File Path'};

T = readtable(cfg.csv, 'Delimiter',',','ReadVariableNames',false);
T.Properties.VariableNames = colnames;
T_Subject = T(contains(T{:, 'File Path'}, cfg.sub),:); %select specific subject


% Center on the first video fixation
Movements = T_Subject(ismember( T_Subject{:,'ActionExecution'}, {'Moving'}),:);
Movements{:,'BeginTime_msec'} = Movements{:,'BeginTime_msec'} - T_Subject{1,'BeginTime_msec'};
Movements{:,'EndTime_msec'} = Movements{:,'EndTime_msec'} - T_Subject{1,'BeginTime_msec'};

% Create the TRL centered to the first fixation
trl = [];
trl(:,1) = round(Movements{:,'BeginTime_msec'}/(1000/hdr.Fs) + FirstFixation);
trl(:,2) = round(Movements{:,'EndTime_msec'}/(1000/hdr.Fs) + FirstFixation);
trl(:,3) = -round(cfg.trialdef.prestim * hdr.Fs);
trl(trl(:,1)> hdr.nSamples,:)=[];
trl(trl(:,2)> hdr.nSamples,2)=hdr.nSamples;

end







