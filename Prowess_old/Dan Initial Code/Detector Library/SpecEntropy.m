function det = SpecEntropy(sigIn, approach)

% samp = 50;
det.type      = approach.type ;
[nn, nSamp] = size(sigIn) ;
det.decision = false ;
sigInM = sum(sigIn,1);
frame = sigInM.';

fs = approach.detail.Fs;
numOfShortBlocks = approach.detail.numOfShortBlocks;
% convert window length and step from seconds to samples:
windowLength = nSamp;
Ham = window(@hamming, windowLength);
frame  = frame .* Ham;
frameFFT = getDFT(frame, fs);
windowFFT = frameFFT; 

% number of DFT coefs
fftLength = length(windowFFT);

% total frame (spectral) energy 
Eol = sum(windowFFT.^2);

% length of sub-frame:
subWinLength = floor(fftLength / numOfShortBlocks);
if length(windowFFT)~=subWinLength* numOfShortBlocks
    windowFFT = windowFFT(1:subWinLength* numOfShortBlocks);
end

% define sub-frames:
subWindows = reshape(windowFFT, subWinLength, numOfShortBlocks);

% compute spectral sub-energies:
s = sum(subWindows.^2) / (Eol+eps);

% compute spectral entropy:
En = -sum(s.*log2(s+eps));

vals = En;
det.vals = vals;
% det.IF = sIF;
        
        if vals < approach.detail.thresh
            det.decision = true ;
            
        end
end
