function session = setupSession(subject, hand, OS, seqVersion, scanner_mode)

%% Get Scanner mode identifier
switch scanner_mode
    case 0 
        mode_id = 'behav';
    case 1
        mode_id = 'fMRI';
    case 3
        mode_id = 'EEG';
end

%% create unique name for saving results
project_name = 'SZ_MMN_HGF'; % changed project name 
session.subject = subject;
session.datetime = datetime("now")%datestr(now,30);
folder = [project_name '_' subject];
folder_path    = fullfile(cd,'behav_data', folder);


%% Create subject_folder
if exist(folder_path)~=7             % check whether subject folder exists
    mkdir(folder_path);              % create new subject folder
    
    
    
    
elseif ~strcmp(subject,'DH_test')
    switch seqVersion
        case 'instructions' % only check for existing files in practice    
            u_resp = input('File for this subject exists already! Continue? [y/n]:','s');
            if strcmp(u_resp,'y')
                disp('Continuing...');
            else
                disp('Aborting...');
                clear all; return;           % if file exists: abort
            end
    end
end


%% Set save path
switch seqVersion
    case 'full'
        session.baseName = fullfile('behav_data',folder,[folder '_MMN_' mode_id '_task.mat']);
    case 'short'
        session.baseName = fullfile('behav_data',folder,[folder '_MMN_testing_' datestr(now,'ddmmyy_HHMM')]);
    case 'training'
        session.baseName = fullfile('behav_data',folder,[folder '_MMN_' mode_id '_practice.mat']);
    case 'instructions'
        session.baseName = fullfile('behav_data',folder,[folder '_MMN_' mode_id '_instructions.mat']);
end

session.hand = hand;

%% set paths
switch OS
    case 'win'
        [~, uid] = unix('whoami');
        switch uid(1:end-1)
            case 'ifp-b-082\labor'
                session.expPath  = 'D:\COMPI\MMN';
            case 'desktop-pllks1m\daniel'
                session.expPath = 'C:\Users\Danie\Dropbox\EEG_IOIO\COMPI\COMPI_paradigms\MMN';
            case 'daniel-hp\daniel'
                session.expPath = 'C:\Users\Daniel\Dropbox\EEG_IOIO\COMPI\COMPI_paradigms\MMN';
            case 'desktop-ctoao6k\compi'
                session.expPath = 'C:\Users\compi\Dropbox\EEG_IOIO\COMPI\COMPI_paradigms\MMN';
        end
        addpath('cogent2000v1.32\Toolbox');     
    case 'lin'
        session.expPath = '/home/laew/prj/prssi/exp/lab/MMN';
        addpath('cogent2000v1.32/Toolbox');
    case 'mac'
        session.expPath = '/Users/drea/Dropbox/EEG_IOIO/paradigms/MMN';
end

%% set file names
session.tone1 = 'tone1_c1_263_61Hz_70ms_duration_5ms_fadeInOut.wav';
session.tone2 = 'tone2_c2_440Hz_70ms_duration_5ms_fadeInOut.wav';

%% choose design file
switch seqVersion
    case 'full'
        session.desFile = 'designMatrix.mat';
    case 'training'
        session.desFile = 'designMatrix_training.mat';
    case 'short'
        session.desFile = 'designMatrix_short.mat';
    case 'instructions'
        session.desFile = 'designMatrix_training.mat';
end
