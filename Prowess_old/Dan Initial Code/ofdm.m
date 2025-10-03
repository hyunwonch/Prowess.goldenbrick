function s = ofdm(sym,nCyc,ovSamp)
    % sym is list of symbols
    % nCyc is the length of cyclic prefix
    % s  : 1 x nS row vector of random modulation
    
    
    baseOfdm = ifft(sym(:)) ;
    cyc = baseOfdm((end-(nCyc-1)):end) ;
    
    sUn = [cyc.' baseOfdm.'] ;
    sBase = sUn / rms(sUn) ;
    
    a0 = sinc(1/2) ;
    b = [a0 1 a0] ;
   
    sOv = [sBase ; zeros(ovSamp-1,length(sBase))] ;
    
    s = filter(b, 1, sOv(:)).' ;

  
    