 
 
function [value] = VideoWatching(sub)


%% Settings
maximum = (533+2.5)*1000;
coded   = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Raw_data\TrainingCoding.csv';
watched = 'C:\Users\krav\Desktop\BabyBrain\Projects\EEG_probabilities_infants\Data\Raw_data\TrainingVideoLength.csv';

%% Import the videocoding

colnamesT  = {'BeginTime_msec','EndTime_msec','Duration_msec','NotWatching',...
    'File','Path'};


T = readtable(coded, 'Delimiter',',','ReadVariableNames',false);
T.Properties.VariableNames = colnamesT;
T_Subject = T(contains(T{:, 'Path'}, sub),:); %select specific subject


%% Import the Duration of watching

colnamesW= {'ID','Set','Consent1','Consent2','Consent3','additional info','Good session','Coders','Done',...
    'ActionExecution','Sum_training','Training'};
W = readtable(watched, 'Delimiter',',','ReadVariableNames',false);
W.Properties.VariableNames = colnamesW;

W = W(contains(W{:, 'ID'}, sub),:); %select specific subject
amount_watched = str2num( cell2mat(W{:,'Training'}))*1000;


%% Percentage

Unique = unique(T_Subject{:,'Path'});

tot = [];
percentage = [0,0,0];
for fil = 1:length(Unique)

    t = T_Subject(contains(T_Subject{:, 'Path'}, Unique(fil)),:); %select specific subject

    amount =  amount_watched(fil) - sum(t{:,'Duration_msec'});
    
    % Health check
    percentage(fil) = amount/maximum*100;
    
    tot = [tot, amount]; 
end


if sum(percentage< 20) >= 2
    warning(['Subject ' sub ' has watched less than 20% more than 2 times!!  Probably need rejection']);
end


value = sum(tot)/(maximum*3)*100;


end

