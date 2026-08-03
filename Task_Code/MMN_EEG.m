%% Script for Volatility MMN task 
% based on task used in Charlton et al., 2025 paper in Imaging Neuroscience
% modified by Joemari P., Last updated: August 3 2026

% Task design: 
% Auditory stimuli presented in the background through headphones
% 2 tones: 528 & 440Hz, duration 70milliseconds, 5ms fadein, 5ms fadeout
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
function MMN_EEG()
subject_id = 0;
mode = 0;
subject_id =input("Enter Subject Id: ")
mode =input("Enter mode(1 for eeg, 0 for just behavior: ")

%% housekeeping ----------------------------------------------------------
clc; 
clear; 
sca;

%% setup -----------------------------------------------------------------
cd('C:\Users\Cockburn_Lab\OneDrive - University of Iowa\Desktop\MMN');
rootPath = 'C:\Users\Cockburn_Lab\OneDrive - University of Iowa\Desktop\MMN';
addpath(fullfile(rootPath, 'lib'));
addpath(fullfile(rootPath, 'design'));
addpath(fullfile(rooPath, 'stimuli'));

disp('This is the MMN-volatility experiment');
initializePsychToolBox;


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


HideCursor(screenNumber); % Hide Cursor

% connect to the EEG amp ------------------------------------------------

if mode == 1 % if running eeg 
[port, eeg_connected] = connectToEEG();
if eeg_connected == 0
    isNoEEG_OK = input('EEG amplifier not connected. Press "y" to continue anyway\n', 's');
    if ~strcmp(isNoEEG_OK, 'y')
        disp('Terminating due to failed EEG connection');
        return;
    end
end
end

% Initialize Triggers ---------------------------------------------------
%Initialize triggers
MMN.triggers.test = 99;
MMN.triggers.start = 1;
MMN.triggers.instructions = 4;
MMN.triggers.visualDummy = 128;
MMN.triggers.visualRight = 32;
MMN.triggers.visualLeft = 64;
MMN.triggers.tones = MMN.stimuli.audSequence;