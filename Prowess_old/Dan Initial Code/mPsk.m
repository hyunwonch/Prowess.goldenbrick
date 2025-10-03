function s = mPsk(nS, m, ovSamp)
    % m is constellation order
    % nS is the number of critical samples
    % s  : 1 x nS row vector of random modulation


    phi = randi(m,1,nS)/m*2*pi ;

    baseS = exp(1i*phi) ;

    a0 = sinc(1/ovSamp) ;
    b = [a0 1 a0] ;

    sOv = [baseS ; zeros(ovSamp-1,length(baseS))] ;

    s = filter(b, 1, sOv(:)).' ;
