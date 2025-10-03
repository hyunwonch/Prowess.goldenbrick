function sig = extractBand(sigIn,fracCenFreq,bwBins,sysBandwidthBins)

% band.cenFreq 

sigCent = exp(2*pi*1i* (1:length(sigIn))*(-fracCenFreq)) ...
    .* sigIn ;

sig = resample(sigCent,bwBins,sysBandwidthBins) ;

