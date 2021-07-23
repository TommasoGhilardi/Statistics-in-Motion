 
 
function [value] = VideoWatching(PATH, sub)


%% Settings
maximum = 511.2;
tot = [];
percentage = [];


%% Find and read videos
Videos = dir([PATH, sub, '\CodingTraining_d*']);

for x  =  1:length(Videos)
    
    vid = [Videos(x).folder '\' Videos(x).name];
    T = readtable(vid, 'Delimiter', ',');
    
    amount =  maximum - sum(T{:,3});
    
    % Health check
    percentage = [percentage, amount/maximum*100];
    
    tot = [tot, amount]; 
    
end

percentage(3) = 0;
if sum(percentage< 20) > 2
    warning(['Subejct ' sub ' has watched less than 20% more than 2 times!!  Probably need rejection']);
end


value = sum(tot)/(maximum*3)*100;


end



