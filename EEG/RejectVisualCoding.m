
function [Configuration] = RejectVisualCoding(Configuration, file)

% Read the CSV
colnames  = {'BeginTime_msec','EndTime_msec','Duration_msec','Goodness',...
    'Annotations','ActionExecution','File','File Path'};

T = readtable(file, 'Delimiter',',','ReadVariableNames',false);
T.Properties.VariableNames = colnames;
T_Subject = T(contains(T{:, 'File Path'}, Subject),:); %select specific subject


% Check if there is the same number of trials between videocoding and EEG data
Trials = T_Subject(ismember( T_Subject{:,'Goodness'}, {'Accept', 'Reject'}),:);

%workaround given by starting recording after EEG
if Configuration.sub == "S_Stat_04"
    Configuration.trl(1:4,:) = [];
end

if length(Trials{:,'Goodness'}) ~= length(Configuration.trl)
    % Error if the number is different
    error(['Error!!!!!!!!!' newline ... 
        'Trials defined during videocoding mismatch trials in the EEG data.' newline ...
        'Please check the videocoding or the trialdefinition'])

else
    
    % If it the same number elimintaes the bad ones
    Bad_ones = ismember( Trials{:,'Goodness'}, 'Reject');
    Configuration.trl(Bad_ones ,:)= [];    
    
end


end


