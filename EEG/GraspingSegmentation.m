function [trl, event] = GraspingSegmentation(cfg)

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% search for first  events
Fixations = find(strcmp('S 50', {event.value}));
FirstFixation = event(Fixations(1)).sample;


% Read the CSV
colnames  = {'BeginTime_msec','EndTime_msec','Duration_msec','Goodness',...
    'Annotations','ActionExecution'};
T = readtable(cfg.csv);
T.Properties.VariableNames = colnames;

% Center on the first video fixation
Movements = T(ismember( T{:,'ActionExecution'}, {'Still', 'Moving'}),:);
Movements{:,'BeginTime_msec'} = Movements{:,'BeginTime_msec'} - T{1,'BeginTime_msec'};
Movements{:,'EndTime_msec'} = Movements{:,'EndTime_msec'} - T{1,'EndTime_msec'};


% Create the TRL centered to the first fixation
trl = [];
trl(:,1) = round(Movements{:,'BeginTime_msec'}*hdr.Fs + FirstFixation);
trl(:,2) = round(Movements{:,'BeginTime_msec'}*hdr.Fs + FirstFixation + cfg.trialdef.postim * hdr.Fs);
trl(:,3) = -round(cfg.trialdef.prestim * hdr.Fs);

trl(:,4) = [Movements{:,'ActionExecution'}];

end

