function s = bpsk(nS, ovSamp)
   % nS is the number of critical samples
   % s  : 1 x nS row vector of random modulation
   sRaw = 2*randi([0 1],1,nS) - 1;
   
    a0 = sinc(1/2) ;
    b = [a0 1 a0] ;
   
    sOv = [sRaw ; zeros(ovSamp-1,length(sRaw))] ;
    
    s = filter(b, 1, sOv(:)).' ;

  