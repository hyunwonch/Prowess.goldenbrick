function s = nQam(nS, m, ovSamp)
    % m is constellation order m = k^2
    % nS is the number of critical samples
    % s  : 1 x nS row vector of random modulation
    
    k = floor(sqrt(m)) ;
    
    sUnNorm = randi(k,1,nS) - (k+1)/2 + 1i * (randi(k,1,nS)-(k+1)/2) ;
    
    if mod(k,2) == 0      
        v   = (1:((k/2))) - 1/2 ;       
        mat   = repmat(v,length(v),1) + i*repmat(v.',1,length(v)) ;
        scale = rms(mat(:)) ;
    else
        v = (-((k-1)/2)):((k-1)/2) ;
        mat = repmat(v,length(v),1) + i*repmat(v.',1,length(v)) ;
        scale = rms(mat(:)) ;
    end
    
    sBase = sUnNorm / scale ;
   
    a = sinc(1/ovSamp) ;
    b = [a 1 a] ;
   
    sOv = [sBase ; zeros(ovSamp-1,length(sBase))] ;
    
    s = filter(b, 1, sOv(:)).' ;
