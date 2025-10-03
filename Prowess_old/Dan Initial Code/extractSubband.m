% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
function sig = extractSubband(sigIn, fracFreqShift, nUp, nDown)

[nAnt, nSamp] = size(sigIn) ;

sigDC = (ones(nAnt,1) * exp(-1i*2*pi*fracFreqShift*(1:nSamp))) .* sigIn ;

sig = resample(sigDC.', nUp, nDown).' ;

% figure;
% periodogram(sigIn(1,:),'power');figure;
% periodogram(sigDC(1,:),'power');figure;
% periodogram(sig(1,:),'power');
