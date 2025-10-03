function det = EnergyDet(sigIn, nAnt, approach)

det.type      = approach.type ;
[nn, nSamp] = size(sigIn) ;

% default
det.decision = false ;

vals = sum(sum(sigIn(1:nAnt,:) .* conj(sigIn(1:nAnt,:)))) / nAnt /nSamp ;
        
        if vals > approach.detail.thresh
            det.decision = true ;
            
        end
        det.vals = vals ;
end