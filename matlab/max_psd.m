function det = MaxPSDIA(sigIn, approach)

% samp = 50;
det.type      = approach.type ;
[nn, nSamp] = size(sigIn) ;
fs = approach.detail.Fs;


det.decision = false ;


[instamp, instphase, instfreq] = instAmpPhaseFreq(sigIn(:),fs);
mu_IA = mean(instamp);
Acn = (instamp/mu_IA)-mu_IA;
PsIA = (abs(fft(Acn)).^2);
% MaxPsIA = std((abs(fft(Acn)).^2));
MaxPsIA = max((abs(fft(Acn)).^2))/(mu_IA*nn*nSamp);



% for i = 1:nSamp
% % IF(i) = fs/(2*pi)*
% IF(i) = (atan(imag(sum(sigIn(:,i)))/real(sum(sigIn(:,i)))));
% end

vals = MaxPsIA;
det.PsdIAvals = vals;
det.MaxPSDIA = PsIA;

% FM
        % if vals > approach.detail.thresh1
        %     det.decision = true ;
        %
        % end

% FSK

if vals < approach.detail.thresh1
    det.decision = true ;

end

end