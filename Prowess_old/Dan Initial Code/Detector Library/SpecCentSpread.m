function det = SpecCentSpread(sigIn, approach)

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



% for i=1:(nSamp/samp)
% number of DFT coefs
windowLength = length(frameFFT);
% sample range
m = ((fs/(2*windowLength))*[1:windowLength])';
% normalize the DFT coefs by the max value:
window_FFT = frameFFT / max(frameFFT);
% compute the spectral centroid:
C = sum(m.*window_FFT)/ (sum(window_FFT)+eps);
% compute the spectral spread
S = sqrt(sum(((m-C).^2).*window_FFT)/ (sum(window_FFT)+eps));

% normalize by fs/2 
% (so that 1 correponds to the maximum signal frequency, i.e. fs/2):
C = C / (fs/2);
S = S / (fs/2);

vals = S;
det.vals = vals;
% det.IF = sIF;
        
        if vals < approach.detail.thresh
            det.decision = true ;
            
        end
end
