function det = SpecRolloff(sigIn, approach)

% samp = 50;
det.type      = approach.type ;
[nn, nSamp] = size(sigIn) ;
det.decision = false ;
sigInM = sum(sigIn,1);
frame = sigInM.';

fs = approach.detail.Fs;
c = approach.detail.C;
% convert window length and step from seconds to samples:
windowLength = nSamp;
Ham = window(@hamming, windowLength);
frame  = frame .* Ham;
frameFFT = getDFT(frame, fs);
windowFFT = frameFFT; 

% compute total spectral energy:
totalEnergy = sum(windowFFT.^2);
curEnergy = 0.0;
countFFT = 1;
fftLength = length(windowFFT);

% find the spectral rolloff as the frequency position where the 
% respective spectral energy is equal to c*totalEnergy
while ((curEnergy<=c*totalEnergy) && (countFFT<=fftLength))
    curEnergy = curEnergy + windowFFT(countFFT).^2;
    countFFT = countFFT + 1;
end
countFFT = countFFT - 1;

% normalization:
mC = ((countFFT-1))/(fftLength);

vals = mC;
det.vals = vals;
% det.IF = sIF;
        
        if vals < approach.detail.thresh
            det.decision = true ;
            
        end
end

