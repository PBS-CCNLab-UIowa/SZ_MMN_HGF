function audios = initializeSounds(audios, MMN)

% intialize sounds
InitializePsychSound('reallyneedlowlatency=1')
audios.devices = PsychPortAudio('GetDevices', [], []);

% fill tone buffers
audios.buffer = [];
audios.buffer(end+1) = PsychPortAudio('CreateBuffer', [], audios.wav1); 
audios.buffer(end+1) = PsychPortAudio('CreateBuffer', [], audios.wav2); 

% get handle and set to run mode
%audios.pahandle = PsychPortAudio('Open', [], [], 1, audios.freq, audios.nrchannels);

devices = PsychPortAudio('GetDevices' );
myDeviceID = 6; % set to play in headphones in CCN Lab

audios.pahandle = PsychPortAudio('Open', myDeviceID, [], 1, audios.freq, audios.nrchannels);
runMode = 1;
PsychPortAudio('RunMode', audios.pahandle, runMode);

% fill playbuffer with tone of first trial:
PsychPortAudio('FillBuffer', audios.pahandle, audios.buffer(MMN.stimuli.audSequence(1)));


end