function [s, symMat, hopPattern] = ranFreqHopQPSK(nHop,hopDur, nFreqBins,hopGap, ovSamp,hopOvSamp)
    % nHop = number of hops
    % hopDur = numble of symbols
    % nFreqBins units of single hop bandwidth
    % hopGap single hop critical samples

    % s  : 1 x nS row vector of random modulation
    % symMat : matrix of symbols (row for each hop)
    % hopPattern frequency channels (1 .. nFreqBins)

    % default is to use QPSK

    symMat = zeros(nHop,hopDur*ovSamp) ;


    for hopIn = 1:nHop
      symMat(hopIn,:) = mPsk(hopDur,4,ovSamp) ;
   end

    hopPattern = randi(nFreqBins, 1, nHop) - nFreqBins/2;


    s = freqHop(symMat,nFreqBins,hopGap,hopPattern,hopOvSamp) ;

    %sUn = freqHop(symMat,nFreqBins,hopGap,hopPattern) ;

    %a = sinc(1/ovSamp) ;
    %b = [a 1 a] ;

    %s = filter(b, 1, sUn) ;

