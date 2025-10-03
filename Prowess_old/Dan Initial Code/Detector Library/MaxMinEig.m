function det = MaxMinEig(sigIn, approach)

det.type      = approach.type ;
[nn, nSamp] = size(sigIn) ;

det.decision = false ;

% vals = sum(sum(sigIn.* conj(sigIn))) / nn /nSamp ;

Rcov = sigIn' * sigIn;
[eVec,eVal] = eigs(Rcov) ; 
Eigvals = max(eVal);
maxEig = max(Eigvals);
minEig = min(Eigvals);
vals = maxEig/minEig; 
det.vals = vals ;
        
        if vals > approach.detail.thresh
            det.decision = true ;
            
        end
end