function s = freqHop(symMat,nFreqBins,hopGap,hopPattern,hopOvSamp)
    % matrix of symbols (row for each hop)
    % nFreqBins units of single hop bandwidth
    % hopGap single hop critical samples
    % hopPattern frequency channels (1 .. nFreqBins)
    % s  : 1 x nS row vector of random modulation
    
    [nHops, nSymPerHop] = size(symMat) ;

    s = zeros(1,nHops*(nSymPerHop+hopGap)*nFreqBins, hopOvSamp) ;
    %win = tukeywin(nSymPerHop*nFreqBins,.5).' ;
    
    upSymMat = zeros(nHops,(nSymPerHop+hopGap)*nFreqBins* hopOvSamp) ;
    for hopIn = 1:nHops
        rs = resample(symMat(hopIn,:),nFreqBins* hopOvSamp,1,0) ;
        upSymMat(hopIn,1:(nSymPerHop*nFreqBins*hopOvSamp)) ...
           = lowpass(rs,1/hopOvSamp) ;
     %  .* win;
    end
    
    upHopLen = (nSymPerHop+hopGap)*nFreqBins*hopOvSamp ;
    s = zeros(1, nHops*upHopLen) ;
    for hopIn = 1:nHops
       s((1+(hopIn-1)*upHopLen):(hopIn*upHopLen)) ...
            = upSymMat(hopIn,:) ...
            .* exp(1i*2*pi*(hopPattern(hopIn)-1)...
            *(0:(upHopLen-1))/(nFreqBins*hopOvSamp)) ;
    end
    
