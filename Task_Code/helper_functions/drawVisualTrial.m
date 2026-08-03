function MMN = drawVisualTrial(MMN, trial, visuals)

% do the square opening
if MMN.stimuli.visSequence(trial) == 1                                  % open on the right
    Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
    Screen('FrameRect', visuals.window, visuals.openCol, visuals.openRightCoords, visuals.openWidth);
    Screen('Flip', visuals.window);
    
    MMN.stimuli.visTimes(trial) = GetSecs - MMN.startScan.GetSecs;

elseif MMN.stimuli.visSequence(trial) == 2                              % open on the left
    Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
    Screen('FrameRect', visuals.window, visuals.openCol, visuals.openLeftCoords, visuals.openWidth);
    Screen('Flip', visuals.window);

    MMN.stimuli.visTimes(trial) = GetSecs - MMN.startScan.GetSecs;

elseif MMN.stimuli.visSequence(trial) == 0                              % don't open, dummy flip
    Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
    Screen('Flip', visuals.window);
    
    MMN.stimuli.visTimes(trial) = GetSecs - MMN.startScan.GetSecs;

end

% go back to closed square after stimulus duration
wait2(MMN.times.visDuration);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('Flip', visuals.window);

end