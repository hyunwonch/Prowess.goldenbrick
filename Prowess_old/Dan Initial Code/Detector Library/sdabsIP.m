function det = sdabsIP(sigIn, approach)

% samp = 50;
det.type      = approach.type ;
[nn, nSamp] = size(sigIn) ;
fs = approach.detail.Fs;


det.decision = false ;


[instamp, instphase, instfreq] = instAmpPhaseFreq(sum(sigIn,1),fs);
% mu_IA = mean(instamp);
% Acn = (instamp/mu_IA)-1;
sd_IP = std(abs(instphase));



% for i = 1:nSamp
% % IF(i) = fs/(2*pi)*
% IF(i) = (atan(imag(sum(sigIn(:,i)))/real(sum(sigIn(:,i)))));
% end

vals = sd_IP;
det.vals = vals;
det.IP = instphase;
        
        if vals < approach.detail.thresh
            det.decision = true ;
            
        end
end