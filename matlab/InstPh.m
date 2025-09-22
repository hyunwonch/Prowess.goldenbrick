function det = InstPh(sigIn, approach)

% samp = 50;
det.type      = approach.type ;
[nn, nSamp] = size(sigIn) ;
fs = approach.detail.Fs;


det.decision = false ;

% sigIn = sum(sigIn,1);

InsPh = diff(unwrap(angle(sigIn(:))));
sd_IA = std(InsPh);

vals = sd_IA;
det.InsPh = InsPh;
det.IAvals = vals;
        
        if vals > approach.detail.thresh
            det.decision = true ;
            
        end
end