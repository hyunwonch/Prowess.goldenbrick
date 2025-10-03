clc;
clear all


% Set the random number generator to a known state to be able to regenerate
% the same frames every time the simulation is run
modulationTypes = categorical(["BPSK", "QPSK", "8PSK", ...
  "16QAM", "64QAM", "PAM4", "GFSK", "CPFSK", ...
  "B-FM", "DSB-AM", "SSB-AM"]);


SNR = 20;
sps = 8;                % Samples per symbol
spf = 1024;             % Samples per frame
symbolsPerFrame = spf / sps;
fs = 200e3;             % Sample rate
fc = [902e6 100e6];     % Center frequencies

channel = helperModClassTestChannel(...
  'SampleRate', fs, ...
  'SNR', SNR, ...
  'PathDelays', [0 1.8 3.4] / fs, ...
  'AveragePathGains', [0 -2 -10], ...
  'KFactor', 4, ...
  'MaximumDopplerShift', 4, ...
  'MaximumClockOffset', 5, ...
  'CenterFrequency', 902e6)

rng(12)

tic

numModulationTypes = length(modulationTypes);
numFramesPerModType = 1;

% channelInfo = info(channel);
transDelay = 50;
% pool = getPoolSafe();
% if ~isa(pool,"parallel.ClusterPool")
%   dataDirectory = fullfile(tempdir,"ModClassDataFiles");
% else
%   dataDirectory = uigetdir("","Select network location to save data files");
% end
% disp("Data file directory is " + dataDirectory)
% % Data file directory is C:\TEMP\ModClassDataFiles
% fileNameRoot = "frame";

% Check if data files exist
% dataFilesExist = false;
% if exist(dataDirectory,'dir')
%   files = dir(fullfile(dataDirectory,sprintf("%s*",fileNameRoot)));
%   if length(files) == numModulationTypes*numFramesPerModType
%     dataFilesExist = true;
%   end
% end

% if ~dataFilesExist
%   disp("Generating data and saving in data files...")
%   [success,msg,msgID] = mkdir(dataDirectory);
%   if ~success
%     error(msgID,msg)
%   end
  for modType = 1:numModulationTypes
    elapsedTime = seconds(toc);
    elapsedTime.Format = 'hh:mm:ss';
    fprintf('%s - Generating %s frames\n', ...
      elapsedTime, modulationTypes(modType))
    
    label = modulationTypes(modType);
    numSymbols = (numFramesPerModType / sps);
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
      
      Sig(modType,:) = y;
      % Pass through independent channels
%       rxSamples = channel(y);
      
      % Remove transients from the beginning, trim to size, and normalize
%       frame(p,:) = helperModClassFrameGenerator2(rxSamples, spf, spf, transDelay, sps);
      
      % Save data file
%       fileName = fullfile(dataDirectory,...
%         sprintf("%s%s%03d",fileNameRoot,modulationTypes(modType),p));
%       save(fileName,"frame","label")
    end
  end
% else
%   disp("Data files exist. Skip data generation.")
% end


for i=1:modType
    z = Sig(i,:);
    exKurR       = kurtosis(real(z(:))) - 3 ;
    exKurI       = kurtosis(imag(z(:))) - 3 ;
    exKur(i)        = (exKurR+exKurI)/2 ;

end

