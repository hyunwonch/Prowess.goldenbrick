function det = EngMinEig(sigIn, approach)

det.type      = approach.type ;
[nn, nSamp] = size(sigIn) ;

det.decision = false ;

Eng = sum(sum(sigIn.* conj(sigIn))) / nn /nSamp ;

Rcov = sigIn' * sigIn;
[eVec,eVal] = eigs(Rcov) ; 
Eigvals = max(eVal);
maxEig = max(Eigvals);
minEig = min(Eigvals);
vals = Eng/minEig; 
det.vals = vals ;
        
        if vals > approach.detail.thresh
            det.decision = true ;
            
        end
end