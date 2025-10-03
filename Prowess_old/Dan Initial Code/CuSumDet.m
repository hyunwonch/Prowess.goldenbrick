clc;
clear all;

simSysEnvFile     = 'simSysEnv-2024-01-17--14-51.mat' ;
load(simSysEnvFile)
winSize = 200;

nThrow = sim.nThrow ;
mxLen = 0 ;
for throwIn = 1:nThrow
    thisPbs   = PBS{throwIn} ;

    mxLen = max(mxLen, ...
        length(thisPbs.sig)+ thisPbs.timeOffBin) ;
end


sTot = zeros(sys.nAnt, mxLen) ;
thisPbs = PBS{2} ;

sTot(1:sys.nAnt,(1:length(thisPbs.sig)) + thisPbs.timeOffBin) ...
    =  sTot(1:sys.nAnt, ...
    (1:length(thisPbs.sig)) + thisPbs.timeOffBin) ...
    + thisPbs.sig ;

ISNRgain = 10*(log10(winSize));
SNR    = 0;        % Target SNR in dBs
ISNR = SNR+ISNRgain;
y = awgn(sTot,SNR);
[nAnt,subSamps] = size(y) ;
figure(2)
plotParams2
pspectrum(y(1,:), sim.oversamp*10^9,'spectrogram',...
    'Leakage',1,'OverlapPercent',90, ...
    'MinThreshold',-20,'FrequencyLimits',[-.5*10^9 .5*10^9]);


for i = 1:size(y,2)
   Eng(i) = sum(y(:,i) .* conj(y(:,i))) / nAnt  ; 

end

cusum(Eng)



