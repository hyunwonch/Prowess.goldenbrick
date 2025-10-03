function det = MaxEigStd(sigIn, approach)

det.type      = approach.type ;
[nn, nSamp] = size(sigIn) ;

det.decision = false ;

% sigIn = (sigIn - mean(sigIn))/var(sigIn);
sigIn = (sigIn - mean(mean(sigIn)))/var(var(sigIn));
Eng = sum(sum((sigIn.* conj(sigIn)).^2)) / nn /nSamp ;

Rcov = sigIn' * sigIn;
[eVec,eVal] = eigs(Rcov) ; 
Eigvals = max(eVal);
maxEig = max(Eigvals);
vals = maxEig/Eng; 
det.vals = vals ;
        
        if vals > approach.detail.thresh 
            det.decision = true ;
            
        end
end