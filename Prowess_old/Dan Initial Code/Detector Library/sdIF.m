function det = sdIF(sigIn, approach)

% samp = 50;
det.type      = approach.type ;
[nn, nSamp] = size(sigIn) ;
fs = approach.detail.Fs;


det.decision = false ;

% for i=1:(nSamp/samp)
[instamp, instphase, instfreq] = instAmpPhaseFreq(sum(sigIn,1),fs);
IFmu = instfreq - mean(instfreq);
IFn = IFmu/fs;
sIF = std(IFn);
% end
% for i = 1:nSamp
% % IF(i) = fs/(2*pi)*
% IF(i) = (atan(imag(sum(sigIn(:,i)))/real(sum(sigIn(:,i)))));
% end

vals = sIF;
det.vals = vals;
det.IF = sIF;

        if vals < approach.detail.thresh
            det.decision = true ;

        end
end