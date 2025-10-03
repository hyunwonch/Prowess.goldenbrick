function helperGenerateModWaveforms(dataDirectory,modulationTypes,numFrames,frameLength,fs)
% This function is only intended to support wavelet deep learning examples.
% It may change or be removed in a future release.


% setup
sps = 8;                % Samples per symbol
spf = frameLength;      % Samples per frame


numFramesPerModType = numFrames;

maxDeltaOff = 5;
deltaOff = (rand()*2*maxDeltaOff) - maxDeltaOff;
C = 1 + (deltaOff/1e6);

channel = helperModClassTestChannel(...
    'SampleRate', fs, ...
    'SNR', 30, ...
    'PathDelays', [0 1.8 3.4] / fs, ...
    'AveragePathGains', [0 -2 -10], ...
    'KFactor', 4, ...
    'MaximumDopplerShift', 4, ...
    'MaximumClockOffset', 5, ...
    'CenterFrequency', 902e6);


% start timing
tic

numModulationTypes = length(modulationTypes);

transDelay = 50;
disp("Data file directory is " + dataDirectory);

fileNameRoot = "frame";


disp("Generating data and saving in data files ...")
[success,msg,msgID] = mkdir(dataDirectory);
if ~success
    error(msgID,msg)
end
for modType = 1:numModulationTypes
    subDir = fullfile(dataDirectory,string(modulationTypes(modType)));
    [success,msg,msgID] = mkdir(subDir);
    if ~success
        error(msgID,msg)
    end

    tmpt = seconds(toc);
    tmpt.Format = 'hh:mm:ss';
    fprintf('%s - Generating %s frames\n',...
        tmpt,modulationTypes(modType))

    label = modulationTypes(modType);
    dataSrc = helperModClassGetSource(modulationTypes(modType), sps, 2*spf, fs);
    modulator = helperModClassGetModulator(modulationTypes(modType), sps, fs);
    if contains(char(modulationTypes(modType)), {'B-FM','DSB-AM','SSB-AM'})
        % Analog modulation types use a center frequency of 100 MHz
        channel.CenterFrequency = 100e6;
    else
        % Digital modulation types use a center frequency of 902 MHz
        channel.CenterFrequency = 902e6;
    end
    for p=1:numFramesPerModType
        % Generate random data
        x = dataSrc();
        
        % Modulate
        y = modulator(x);
        
        % Pass through independent channels
        rxSamples = channel(y);
        
        % Remove transients from the beginning, trim to size, and normalize
        frame = helperModClassFrameGenerator2(rxSamples, spf, spf, transDelay, sps);
        
        % Save data file
        fileName = fullfile(subDir,...
            sprintf("%s%s%05d",fileNameRoot,modulationTypes(modType),p));
        save(fileName,"frame","label")
    end
end
end
