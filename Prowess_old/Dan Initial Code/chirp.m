function s = chirp(nCritPulseSamp, nPulseToPulseCrit, ...
    nPulses, bOvSamp)
   %
        
   nSamp = nCritPulseSamp ;
   
   tRange = ((1:(nSamp))-nSamp/2) ;
   
   sPulse = exp(1i * 2*pi /nSamp /bOvSamp * (tRange).^2 /2) ;
   %* nSamp)) ;
   
   sOneP = zeros(nPulseToPulseCrit,1) ;
   sOneP(1:nSamp,1) = sPulse ;
   
   sRep = repmat(sOneP, 1, nPulses) ;
   
   s = sRep(:).' ;
   
   
   
  