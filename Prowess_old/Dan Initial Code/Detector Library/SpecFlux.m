function det = SpecFlux(sigIn, approach)

% samp = 50;
det.type      = approach.type ;
[nn, nSamp] = size(sigIn) ;
det.decision = false ;
sigInM = sum(sigIn,1);
frame = sigInM.';

fs = approach.detail.Fs;
% convert window length and step from seconds to samples:
windowLength = nSamp;
Ham = window(@hamming, windowLength);
frame  = frame .* Ham;
frameFFT = getDFT(frame, fs);
WindowFFT = frameFFT;
if approach.detail.winIn ==1
    windowFFTPrev = WindowFFT;
else
    windowFFTPrev = approach.detail.windowFFTPrev;
end

% normalize the two spectra:
windowFFT = WindowFFT / sum(WindowFFT);
windowFFTPrev = windowFFTPrev / sum(windowFFTPrev+eps);

% compute the spectral flux as the sum of square distances:
F = sum((windowFFT - windowFFTPrev).^2);

vals = F;
det.vals = vals;
det.windowFFT = windowFFT;
% det.IF = sIF;
if approach.detail.winIn>1
    if vals > approach.detail.thresh
        det.decision = true ;

    end
end
end
