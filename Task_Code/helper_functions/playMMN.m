function playMMN( MMN )
%PLAYMMN Starts the MMN paradigm


%% ---------------------- initializing -------------------------- %%

%cd(MMN.setup.expPath)
cd('C:\Users\Cockburn_Lab\OneDrive - University of Iowa\Desktop\MMN')
disp('This is the MMN-volatility experiment');

% PsychToolBox
PsychDefaultSetup(2);
PsychImaging('PrepareConfiguration');
t = GetSecs;    

% cogent
%config_serial(params.boxport, 19200, 0, 0, 8);
start_cogent;


%% ---------------------- set up screen -------------------------- %%

screens = Screen('Screens');                                                % get screen numbers
screenNumber = max(screens);                                                % draw to external screen

black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
gray = white/2;

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, ...
    gray, [], 32, 2, [], [],  kPsychNeed32BPCFloat);     
Screen('Flip', window);

[screenXpixels, screenYpixels] = Screen('WindowSize', window);              % size of screen in pixels
[xCenter, yCenter] = RectCenter(windowRect);                                % center of screen in pixels

Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');  % set up alpha-blending for smooth (anti-aliased) lines

% Hide Cursor
HideCursor(screenNumber);

%% ---------------------- visual stimuli -------------------------- %%

% text (instructions)
instrSize = 30;
instrText = MMN.stimuli.instrText;
abortText = 'Abbruch';
endText = 'Ende';

% fixation square
fixSize = 30;                                                               % size of square side in pixels
fixWidth = 2;
fixCol = white;
fixRect = [0 0 fixSize fixSize];
fixCoords = CenterRectOnPointd(fixRect, xCenter, yCenter);

% openings
openWidth = 5;
openCol = gray;
openDist = fixSize - fixWidth;
openLeftCoords = CenterRectOnPointd(fixRect, xCenter - openDist, yCenter);
openRightCoords = CenterRectOnPointd(fixRect, xCenter + openDist, yCenter);


%% ---------------------- auditory stimuli -------------------------- %%

% load tones
[y1, freq] = audioread(tone1);
[y2, freq] = audioread(tone2);

% setup tone 1
wavedata1 = y1';                                                            
nrchannels = size(wavedata1, 1);                                            % Number of rows == number of channels.
% stereo
if nrchannels < 2
    wavedata1 = [wavedata1; wavedata1];
end

% setup tone 2
wavedata2 = y2';
nrchannels = size(wavedata2, 1);                                            % Number of rows == number of channels.
% stereo
if nrchannels < 2
    wavedata2 = [wavedata2; wavedata2];
end

nrchannels = 2;

%% ---------------------- initialize sounds -------------------------- %%

% intialize sounds
InitializePsychSound('reallyneedlowlatency=1')
devices = PsychPortAudio('GetDevices', [], []);

% fill tone buffers
buffer = [];
buffer(end+1) = PsychPortAudio('CreateBuffer', [], wavedata1); 
buffer(end+1) = PsychPortAudio('CreateBuffer', [], wavedata2); 

% get handle and set to run mode
pahandle = PsychPortAudio('Open', [], [], 1, freq, nrchannels);
runMode = 1;
PsychPortAudio('RunMode', pahandle, runMode);

% fill playbuffer with tone of first trial:
PsychPortAudio('FillBuffer', pahandle, buffer(MMN.stimuli.audSequence(1)));


%% ---------------------- start presentation -------------------------- %%

Screen('TextSize', window, instrSize);
MMN.startScreen = datestr(now, 30);
if scanner == 1
    %PsychRTBox('Start', rtHandle, 0);
end

% instructions
DrawFormattedText(window, instrText, 'center', 'center', black);
Screen('Flip', window);

%outp(address, MMN.triggers.instructions);                                   % tone actually starts 25ms later!!!      
%wait2(5);                                                                   % duration of the trigger
%outp(address,0);

if scanner == 1
    [~,t] = waitserialbyte(params.boxport, inf, params.sliceSignalNum);
    MMN.scanstartSerial = t(1);
    MMN.scanstartGetSecs = GetSecs;
    clearserialbytes(params.boxport);
    %keyPress = [];
    %while isempty(keyPress)
    %    [~, keyPress, ~] = PsychRTBox('GetSecs', rtHandle);
    %end
elseif scanner == 0
    MMN.startscanGetSecs = GetSecs;
    MMN.startscanSerial = time; % this is cogent time
    KbStrokeWait;
end



% start with center square
Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
Screen('Flip', window);

% save start time of main loop
MMN.startLoop = datestr(now, 30);

% record time as baseline
if scanner == 1
    MMN.startLoopToScan = GetSecs - MMN.scanstartGetSecs;
end

%% ---------------------- loop over trials -------------------------- %%

for trial = 1: length(MMN.stimuli.audSequence) - 1
        
    nexttone = MMN.stimuli.audSequence(trial + 1);
    
    MMN.stimuli.startTimes(trial) = PsychPortAudio('Start', pahandle, 1, 0, 1); % tone of 1st trial is already in the buffer
    MMN.stimuli.audTimes(trial) = GetSecs - MMN.scanstartGetSecs;           % START sec of tone presentation
    
    PsychPortAudio('FillBuffer', pahandle, buffer(nexttone));
    
    wait2(MMN.times.SOT(trial));                                            % stimulus onset time
    
    % draw new visual screens
    if MMN.stimuli.visSequence(trial) == 1                                  % open on the right
        Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
        Screen('FrameRect', window, openCol, openRightCoords, openWidth);
        Screen('Flip', window);
        MMN.stimuli.visTimes(trial) = GetSecs - MMN.scanstartGetSecs;
    elseif MMN.stimuli.visSequence(trial) == 2                              % open on the left
        Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
        Screen('FrameRect', window, openCol, openLeftCoords, openWidth);
        Screen('Flip', window);
        MMN.stimuli.visTimes(trial) = GetSecs - MMN.scanstartGetSecs;
    elseif MMN.stimuli.visSequence(trial) == 0                              % don't open, dummy flip
        Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
        Screen('Flip', window);
        MMN.stimuli.visTimes(trial) = GetSecs - MMN.scanstartGetSecs;
    end

    % go back to closed square after stimulus duration
    wait2(MMN.times.visDuration - 5);
    Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
    Screen('Flip', window);

    wait2(MMN.times.rest(trial) - 5);                                       % wait until ISI is over
    
    [~, ~, keyCode] = KbCheck;
    if keyCode(MMN.keys.escapeKey)
        DrawFormattedText(window, abortText, 'center', 'center', black);
        Screen('Flip', window);
        PsychPortAudio('DeleteBuffer');
        PsychPortAudio('Close');
        stop_cogent;
        sca;
        return;
    end
end

% save end time of main loop
MMN.stopLoop = datestr(now, 30);

%% ---------------------- goodbye -------------------------- %%

% good-bye screen
DrawFormattedText(window, endText, 'center', 'center', black);
Screen('Flip', window);

wait2(MMN.times.end);

%% --------------- response time calculation --------------- %%

% correct start times
MMN.stimuli.startTimes = MMN.stimuli.startTimes - MMN.scanstartGetSecs;

% save all responses
readserialbytes(params.boxport);
[responses, responseTimes] = getserialbytes(params.boxport);
MMN.responseTimes = responseTimes - MMN.scanstartSerial;
MMN.responses = responses;

% save all data in workspace
MMN.stopScreen = datestr(now, 30);
save(baseName, 'MMN');

%% ---------------------- shut down ------------------------ %%

% Wait for end of playback, then stop:
PsychPortAudio('Stop', pahandle, 1);

% Delete all dynamic audio buffers:
PsychPortAudio('DeleteBuffer');

% Close audio device, shutdown driver:
PsychPortAudio('Close');

% Close all screens
sca;

% Stop cogent
stop_cogent;


end

