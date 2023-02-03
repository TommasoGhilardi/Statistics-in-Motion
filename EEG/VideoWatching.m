 
 
function [value] = VideoWatching(Path, sub)


%% Settings
watched = fullfile(Path,'TrainingVideoLength.csv');

%% Import the Duration of watching

colnamesW= {'ID','Done','TotalTraining','PercentageTraining', 'Keep'};
W = readtable(watched, 'Delimiter',',','ReadVariableNames',false);
W.Properties.VariableNames = colnamesW;

W = W(contains(W{:, 'ID'}, sub),:); %select specific subject
value = W{:,'TotalTraining'};

if W{:,'Keep'} == "False"
    warning(['Subject ' sub ' has watched less than 20% more than 2 times!!  Probably need rejection']);
end


end

