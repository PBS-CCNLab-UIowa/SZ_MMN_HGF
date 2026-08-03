function [screen] = setupScreen
Screen('Preference', 'SkipSyncTests', 0); %%% CHANGE

screens = Screen('Screens');                                                % get screen numbers
screenNumber = max(screens);                                                % draw to external screen

screen.black = BlackIndex(screenNumber);
screen.white = WhiteIndex(screenNumber);
screen.gray = screen.white/2;

[screen.window, windowRect] = PsychImaging('OpenWindow', screenNumber, screen.gray, [], 32, 2); %,...
%    [], [],  kPsychNeed32BPCFloat);     
Screen('Flip', screen.window);

[screenXpixels, screenYpixels] = Screen('WindowSize', screen.window);              % size of screen in pixels
[screen.xCenter, screen.yCenter] = RectCenter(windowRect);                                % center of screen in pixels

Screen('BlendFunction', screen.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');  % set up alpha-blending for smooth (anti-aliased) lines

% Hide Cursor
HideCursor(screenNumber);

end