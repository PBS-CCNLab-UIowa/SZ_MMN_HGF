function MMN = createMMN(session,scanner_mode)

MMN.subject.ID  = session.subject;
MMN.subject.hand = session.hand;

de = load(session.desFile);                                                         % load stimulus sequence
MMN.stimuli.audSequence = de.designMatrix(1, :);                            % tone sequence
MMN.stimuli.audSequence = [MMN.stimuli.audSequence 1];                      % add dummy tone for loop
MMN.stimuli.visSequence = de.designMatrix(4, :);                            % sequence of visual events
MMN.stimuli.visTypes = MMN.stimuli.visSequence(find(MMN.stimuli.visSequence));

MMN.stimuli.startTimes = [];                                                % times of tone start (from PsychToolBox)
MMN.stimuli.audTimes = [];                                                  % times of tones (from GetSecs)
MMN.stimuli.visTimes = [];                                                  % times of flips (from GetSecs)

MMN.times.visDuration = 200;
MMN.times.audDuration = 70;
MMN.times.ISI = de.designMatrix(3, :);                                      % interstimulus intervals
MMN.times.SOT = de.designMatrix(5, :);                                      % stimulus presentation times (visual)
MMN.times.rest = de.designMatrix(6, :);                                     % time left per visual trial
MMN.times.end = 5000;                                                       % how long endtext is presented

MMN.scanner.mode = 1;
MMN.scanner.boxport = 4;
MMN.scanner.trigger = 53;

MMN.responses.times = [];
MMN.responses.keys = [];

%% Configure keys
MMN.keys.escapeKey = KbName('ESCAPE');   % for escape by the experimenter
MMN.keys.escape = 52;
   
switch scanner_mode
    case {0,3} % keyboard
        MMN.keys.left = 97; % arrow key left
        MMN.keys.right = 98; % arrow key right   
        
%         MMN.keys.left = KbName('LeftArrow');    %PTB key 37 or arrow key left
%         MMN.keys.right = KbName('RightArrow');  % PTB key 39 or arrow key right   
        
        
    case 1   % MRI
        MMN.keys.left = 30; 
        MMN.keys.right = 28; 
        MMN.keys.up = 31;
        MMN.keys.down = 29;
        MMN.keys.scanner_trigger = 32; % Key to receive scanner trigger
end


% switch session.hand
%     case 'l'
%         MMN.keys.left = 49;
%         MMN.keys.right = 50;
%     case 'r'
%         MMN.keys.left = 51;
%         MMN.keys.right = 52;
% end

end
