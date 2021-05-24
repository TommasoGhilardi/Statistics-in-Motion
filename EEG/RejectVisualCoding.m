function [Configuration] = RejectVisualCoding(Configuration, file)

% Read the CSV
colnames  = {'BeginTime_msec','EndTime_msec','Duration_msec','Goodness',...
    'Annotations','ActionExecution'};
T = readtable(file);
T.Properties.VariableNames = colnames;

% Check if there is the same number of trials between videocoding and EEG data
Trials = T(ismember( T{:,'Goodness'}, {'Accept', 'Reject'}),:);

if length(Trials{:,'ActionExecution'}) ~= length(Configuration.trl)
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


