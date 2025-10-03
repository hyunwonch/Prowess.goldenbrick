% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
function det = kurtosis(sigIn, threshold)

[nAnt, nSamp] = size(sigIn) ;

% default
det.decision = false ;

% look for constant modulus
% requires Statistics and Machine Learning Toolbox

exKurR       = kurtosis(real(sigIn(:))) - 3 ;
exKurI       = kurtosis(imag(sigIn(:))) - 3 ;
exKur        = (exKurR+exKurI)/2 ;

det.decision = (exKur < threshold) ;
det.exKur    = exKur ;

end

