function indices = find_indices(Sub, path)

    epoched     = load(fullfile(path, Sub, 'Prediction\Epoched.mat' ));
    clean       = load(fullfile(path, Sub, 'Prediction\Clean.mat' ));

    trialsE = epoched.data.sampleinfo(:,1);
    trialsC = clean.art_final_data.sampleinfo(:,1);
    
    % this basically counts the trial number based on 
    % the number 50 that is the fixation cross
    trialsN = cumsum(epoched.data.trialinfo == 50); 
    
    % Find the logical indices of the elements in 'a' that are also in 'b'
    logicalIndices = ismember(trialsE,trialsC);

    % Find the indices of the trialsN
    indices =  trialsN(logicalIndices);
        
end



