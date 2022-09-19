function [trl, event] = PredictionSegmentation(cfg)

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

trl = [];
for x=1:length(event)
   if  ischar(event(x).value) && numel(event(x).value)>1 && (event(x).value(1)=='S')
      
      % on brainvision these are called 'S  1' for stimuli or 'R  1' for responses
      trlval = str2double(event(x).value(2:end));
      
      % 2 sec for the actions
      if trlval > 100
        trl = cat(1, trl , [event(x).sample, (event(x).sample+hdr.Fs*2-1) , 0, trlval]);
       
      % 1 sec for the rest
      elseif trlval < 100 &&  trlval > 1 && trlval ~= 70 && trlval ~= 60
        trl = cat(1, trl , [event(x).sample, (event(x).sample+hdr.Fs-1) , 0, trlval]);
        
      end     
   end

end
end

