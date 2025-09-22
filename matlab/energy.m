function det = energy(sigIn, threshold)

[nAnt, nSamp] = size(sigIn) ;

% default
det.decision = false ;

% -------------------------------------

vals = sum(sum(sigIn .* conj(sigIn))) / nAnt /nSamp ;

if vals > threshold
    det.decision = true ;
    det.vals = vals ;
end

end

