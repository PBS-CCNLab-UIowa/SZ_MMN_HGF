function MMN_EEG(subject, hand, scanner_mode)

%% Script for Volatility MMN task 
% based on task used in Charlton et al., 2025 paper in Imaging Neuroscience
% modified by Joemari P., Last updated: August 3 2026

% Task design: 
% Auditory stimuli presented in the background through headphones
% 2 tones: 528 & 440Hz, duration 70 milliseconds, 5ms fadein, 5ms fadeout
% systematic modulation of probability 
% 1800 trials, 
% ITI ~ 500ms 

% Visual distraction task
% Look at central white square and indicate whether opening to the left vs
% right - 36 square openings (18 left, 18 right)

% Participants are instructed to respond to whether the fixation box has an
% opening in the right or left side, tones are passively played in their
% ears through headphones, they are told not to attend to the tones
% -----------------------------------------------------------------------%


% to run script type in MatLab Terminal
% 'MMN_EEG('subjectID', 'hand', 'scanner_mode')
% subjectID : string, type in subjectID as a string
% hand: string, type in l for left and right 
% scanner_mode: int, type in 3 for eeg to

%% ---------------------- setting up session -------------------------- %%
% path when running script from CCN Lab Room C - Stimulus Computer: 
rootpath = 'C:\Users\Cockburn_Lab\OneDrive - University of Iowa\Documents\GitHub\SZ_MMN_HGF\Task_Code';
addpath(fullfile(rootpath, 'helper_functions'))
addpath(fullfile(rootpath, 'design'))
addpath(fullfile(rootpath, 'stimuli'))
addpath(fullfile(rootpath,'cogent2000v1.32', 'Toolbox')) 
KbName('UnifyKeyNames');

session = setupSession(subject, hand, 'win', 'full', scanner_mode);
MMN = createMMN(session,scanner_mode);

%% ------------------------- initializing ----------------------------- %%
cd('C:\Users\Cockburn_Lab\OneDrive - University of Iowa\Documents\GitHub\SZ_MMN_HGF\Task_Code')
disp('This is the MMN-volatility experiment');

initializePsychToolBox;

%Initialize triggers
MMN.triggers.test = 99;
MMN.triggers.start = 1;
MMN.triggers.instructions = 4;
MMN.triggers.visualDummy = 128;
MMN.triggers.visualRight = 32;
MMN.triggers.visualLeft = 64;
MMN.triggers.tones = MMN.stimuli.audSequence; %%%% adjust triggers here

% Initialize serial port
if scanner_mode == 3
    IPI = 4;
    % trigger info CCN Iowa
    targetPort = 'COM3';
    baudRate = 2000000;
    port = serialport(targetPort,baudRate);
    sp = port;
    write(sp, MMN.triggers.test, 'uint8')
    wait(IPI);
    addpath('C:\Users\Cockburn_Lab\OneDrive - University of Iowa\Documents\GitHub\SZ_MMN_HGF\Task_Code');
    IPI = 0.004;  % 4ms in seconds
    write(port, uint8(MMN.triggers.test), "uint8");
    pause(IPI);
    write(port, uint8(0), "uint8");
    disp(['Serial port connected on ' targetPort]);
end

[screen] = setupScreen;
visuals = createVisualStimuli(screen);

config_keyboard(5,1,'nonexclusive'); % Set up key board
initializeCogent(MMN);

audios = createAuditoryStimuli(session);
audios = initializeSounds(audios, MMN);


%% ---------------------- start presentation -------------------------- %%
% start screen
Screen('TextSize', visuals.window, visuals.instrSize);
MMN.startScreen.Date       = datestr(now, 30);
MMN.startScreen.GetSecs    = GetSecs;
MMN.startScreen.Cogent     = time;

% instructions
DrawFormattedText(visuals.window, visuals.instrText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

if scanner_mode == 3
    write(sp, MMN.triggers.instructions, 'uint8')
    % tone actually starts 25ms later!!!
    wait(IPI); 
    % duration of the trigger
    write(sp, 0, 'uint8')

end

% wait for an experimenter button press
KbStrokeWait;

% start with center square
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('Flip', visuals.window);

if scanner_mode == 3
    write(sp, MMN.triggers.start, 'uint8');
    wait(IPI);
    write(sp, 0, 'uint8');
end

% save start time of main loop
MMN.startLoop.Date      = datestr(now, 30);
MMN.startLoop.GetSecs   = GetSecs;
MMN.startLoop.Cogent    = time;

% Responses: 
MMN.responses.times = [];
MMN.responses.keys = [];
MMN.responses.trials = [];
MMN.responses.keyboard = {};
KbQueueCreate();
KbQueueStart();



%% ---------------------- main loop -------------------------- %%
idx_resp = 1;
clearkeys;
readkeys;


for trial = 1:length(MMN.stimuli.audSequence) - 1
    %load tone
    nexttone = MMN.stimuli.audSequence(trial + 1);
    tic
    %send trigger
    if scanner_mode == 3
        write(sp, MMN.triggers.tones(trial), 'uint8');
        wait(IPI);
        write(sp, 0, 'uint8')
    end
    toc
    %Play tone & record time
    
    MMN.stimuli.startTimes(trial) = PsychPortAudio('Start', audios.pahandle, 1, 0, 1); % tone of 1st trial is already in the buffer
    MMN.stimuli.audTimes(trial) = GetSecs - MMN.startLoop.GetSecs;           % START sec of tone presentation
    
    %Update buffer
    PsychPortAudio('FillBuffer', audios.pahandle, audios.buffer(nexttone));
    
    wait2(MMN.times.SOT(trial));                                            % stimulus onset time
    
    
    % draw new visual screens
    if MMN.stimuli.visSequence(trial) == 1                                  % open on the right
        Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
        Screen('FrameRect', visuals.window, visuals.openCol, visuals.openRightCoords, visuals.openWidth);
        Screen('Flip', visuals.window);
        MMN.stimuli.visTimes(trial) = GetSecs - MMN.startLoop.GetSecs;
        
        if scanner_mode == 3
            write(sp, MMN.triggers.visualRight, 'uint8');                        % set the trigger
            wait(IPI);
            write(sp, 0, 'uint8')
        end
        
    elseif MMN.stimuli.visSequence(trial) == 2                              % open on the left
        Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
        Screen('FrameRect', visuals.window, visuals.openCol, visuals.openLeftCoords, visuals.openWidth);
        Screen('Flip', visuals.window);
        MMN.stimuli.visTimes(trial) = GetSecs - MMN.startLoop.GetSecs;
        
        if scanner_mode == 3
            write(sp, MMN.triggers.visualLeft, 'uint8');                      % set the trigger
            wait(IPI);
            write(sp, 0, 'uint8')
        end
        
    elseif MMN.stimuli.visSequence(trial) == 0                              % don't open, dummy flip
        Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
        Screen('Flip', visuals.window);
        MMN.stimuli.visTimes(trial) = GetSecs - MMN.startLoop.GetSecs;
        
        if scanner_mode == 3
            write(sp, MMN.triggers.visualDummy, 'uint8');                     % set the trigger
            wait(IPI);
            write(sp, 0, 'uint8')
        end
    end
    
    % go back to closed square after stimulus duration
    wait2(MMN.times.visDuration - 5);
    Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
    Screen('Flip', visuals.window);
    
    wait2(MMN.times.rest(trial));                                           % wait until ISI is over

 readkeys;
    k = [];  
    t = [];  
   if ~isempty(k)
        if any(k == MMN.keys.escape)
            DrawFormattedText(visuals.window, visuals.abortText, 'center', 'center', screen.black);
            Screen('Flip', visuals.window);
            PsychPortAudio('DeleteBuffer');
            PsychPortAudio('Close');
            stop_cogent;
            sca;
            return;
        else
            MMN.responses.times(idx_resp)   = (t(1) - MMN.startLoop.Cogent)/1000;
            MMN.responses.keys(idx_resp)    = k(1);
            idx_resp = idx_resp + 1;
        end
    end
end


    % Record responses
    readkeys;
    k = [];  
    t = [];    
    
   % Pull all keyboard responses
    [pressed, firstPress] = KbQueueCheck;

    while pressed
        key_indices = find(firstPress);

        for idx = 1:length(key_indices)
            k_raw = key_indices(idx);
            t_raw = firstPress(k_raw);

            % Map keys to codes
            if k_raw == KbName('LeftArrow')
                k(idx) = 112;
            elseif k_raw == KbName('RightArrow')
                k(idx) = 113;
            elseif k_raw == KbName('ESCAPE')
                k(idx) = MMN.keys.escape;
            else
                k(idx) = k_raw;
            end

            t(idx) = t_raw;

            % Store detailed response info
            MMN.responses.keyboard{end+1} = struct(...
                'raw', k(idx), ...
                'rawtime', t_raw, ...
                'trial', trial, ...
                'keyCode', k_raw);
        end

        [pressed, firstPress] = KbQueueCheck;
    end


% save end time of main loop
MMN.stopLoop.Date       = datestr(now, 30);
MMN.stopLoop.GetSecs    = GetSecs - MMN.startLoop.GetSecs;
MMN.stopLoop.Cogent     = time - MMN.startLoop.Cogent;



%% ------------- response time correction and warning ----------------- %%
% correct start times
MMN.stimuli.startTimes = MMN.stimuli.startTimes - MMN.startLoop.GetSecs;
MMN.responses.dummy = MMN.responses.keys == MMN.keys.right;
MMN.responses.dummy = MMN.responses.dummy + (MMN.responses.keys == MMN.keys.left)*2;


% Output warning, when they where no responses
if isempty(MMN.responses.times )
    warning('NO RESPONSES RECORDED!');
    MMN.responses.times     = NaN;
    MMN.responses.keys      = NaN;
end

% JG_ADD 
disp('')
disp('')
disp('session basename')
disp(session.baseName)
disp('cwd')
disp(pwd)

% JG_ADD - HACKY!
outdir = fullfile(pwd,fileparts(session.baseName));
if exist(outdir) ~=7
    mkdir(outdir)
end

% security save at this point
save(session.baseName, 'MMN');

% please wait screen
DrawFormattedText(visuals.window, visuals.waitText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);


%% ------------- timing check ----------------- %%
% measure time once again, to compare
clearkeys;

% please press button screen
DrawFormattedText(visuals.window, visuals.pressText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

% wait for an experimenter button press
KbStrokeWait;

% save stop time
MMN.stopScreen.Date     = datestr(now, 30);
MMN.stopScreen.GetSecs  = GetSecs;
MMN.stopScreen.Cogent   = time; % this is cogent time


%% ------------- goodbye ----------------- %%

% goodbye screen
DrawFormattedText(visuals.window, visuals.endText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);


% save all data in workspace

disp('session basename')
disp(session.baseName)
disp('cwd')
disp(pwd)

% JG_ADD - HACKY!
outdir = fullfile(pwd,fileparts(session.baseName));
if exist(outdir) ~=7
    mkdir(outdir)
end

save(session.baseName, 'MMN');

%% ---------------------- shut down ------------------------ %%

% Wait for end of playback, then stop:
PsychPortAudio('Stop', audios.pahandle, 1);

% Delete all dynamic audio buffers:
PsychPortAudio('DeleteBuffer');

% Close audio device, shutdown driver:
PsychPortAudio('Close');

% Close all screens
sca;

% Stop cogent
stop_cogent;

end

