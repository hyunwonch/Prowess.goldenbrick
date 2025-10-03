function s = mFsk(nS, m, ovSamp)
    % m is constellation order
    % nS is the number of critical samples
    % s  : 1 x nS row vector of random modulation



% mfsk = {'00', '10', '01', '01', '01', '10', '10', '01', '11'};
% nfsk = length(mfsk); % length of mfsk string
% 
% fc = 5000;
% fd = 500;
% M = 4;
% ovSamp = 2;
% 
% %Equation 7.3 used to create 4 M=4 signals
% %fi(1) = '00', %fi(2) = '01', %fi(3) = '10', %fi(4) = '11'
% fi = fc + ((2 * (1:M) ) - 1 - M) * fd;
% 
% tbit = 5e-3; % time per fsk bit [seconds]
% nbit = tbit*fc*5; % # data points in one fsk bit, including Nyquist factor
% 
% tSample = linspace(0,nfsk*tbit, 1+nfsk*nbit);
% % find frequency fi for every time points
% freqSample = 0*tSample;
% for nn = 1:nfsk
%     nCurrentBit = (1+(nn-1)*nbit) : (nn*nbit);
%     switch char(mfsk(nn))
%         case '00'
%             fCurrentBit = fi(1);
%         case '01'
%             fCurrentBit = fi(2);
%         case '10'
%             fCurrentBit = fi(3);
%         case '11'
%             fCurrentBit = fi(4);
%         otherwise % wrong mfsk code
%             fCurrentBit = 0;
%     end
%     freqSample(nCurrentBit) = fCurrentBit;
% end
% freqSample(end) = freqSample(end-1);


freq = 0:10^6:(m-1)*10^6;
fs = 2*freq(end); 
ts = 1/fs;
tSample = 0:ts:(ts*nS);
tSample = tSample(1:(end-1));
ff = randi(length(freq),1,nS);
freqSample = freq(ff);
% evaluate carrier signal on each time point
baseS = exp(2j*pi * freqSample .* tSample);
% plot(tSample, baseS);

a0 = sinc(1/ovSamp) ;
b = [a0 1 a0] ;   
sOv = [baseS ; zeros(ovSamp-1,length(baseS))] ;
s = filter(b, 1, sOv(:)).' ;

figure(1)
plotParams2
pspectrum(s(1,:), ovSamp*10^9,'spectrogram',...
    'Leakage',1,'OverlapPercent',90, ...
    'MinThreshold',-20,'FrequencyLimits',[-.5*10^9 .5*10^9]);





