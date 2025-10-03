function det = nPower(sigIn, approach)

det.type      = approach.type ;
[nn, nSamp] = size(sigIn) ;

% default
det.decision = false ;
Sig = sum(sigIn,1);
Pwr2 = Sig.^2/ nn /nSamp;
Pwr4 = Sig.^4/ nn /nSamp;
Pwr6 = Sig.^6/ nn /nSamp;
Pwr8 = Sig.^8/ nn /nSamp;

vals1 = var(abs(Pwr2));
vals2 = var(abs(Pwr4));
vals3 = var(abs(Pwr6));
vals4 = var(abs(Pwr8));
det.vals1 = vals1;
det.vals2 = vals2;
det.vals3 = vals3;
det.vals4 = vals4;
        
        if vals1 > approach.detail.thresh
            det.decision = true ;
            % det.vals = vals ;
        end
end