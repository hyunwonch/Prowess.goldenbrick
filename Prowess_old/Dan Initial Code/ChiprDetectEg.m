clc;
clear all

load ChirpSignalEg.mat;
oversamp = 2;
figure;
plotParams2
pspectrum(y(1,:), oversamp*10^9,'spectrogram',...
    'Leakage',1,'OverlapPercent',90, ...
    'MinThreshold',-20,'FrequencyLimits',[-.5*10^9 .5*10^9]);


winSize = 200;
[nAnt,subSamps] = size(y) ;
nWin = floor(subSamps/winSize) ;

delay = 50; 
for winIn = 1:nWin
    z = y(:,([1:winSize]+(winIn-1)*winSize)) ;
    z1 = [zeros(nAnt,delay) z(:,1:end)];
%     Corr = fft(z).*conj(fft(z1));
    [Corr lagA] = xcorr(sum(z.',2),sum(z1.',2));
%     [CorrZ lagB] = xcorr(sum(downsample(z.',2),2));
    A = abs(Corr);
    AA = abs(fft(Corr));
%     B = abs(CorrZ);
%     BB = abs(fft(CorrZ));
    CorrMA(winIn,:) = A/nAnt/winSize; 
    CorrMFA(winIn,:) = AA/nAnt/winSize; 
%     CorrMB(winIn,:) = B/nAnt/winSize; 
%     CorrMFB(winIn,:) = BB/nAnt/winSize;  
end


figure; plot(CorrMFA(1,:)); title('No Chirp Only Noise')
figure; plot(CorrMFA(1000,:)); title('Chirp Only')

figure; contour(CorrMFA);