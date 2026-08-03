function audios = createAuditoryStimuli(session)

% load tones
[y1, ~] = audioread(session.tone1);
[y2, audios.freq] = audioread(session.tone2);

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

audios.wav1 = wavedata1;
audios.wav2 = wavedata2;
audios.nrchannels = nrchannels;

end