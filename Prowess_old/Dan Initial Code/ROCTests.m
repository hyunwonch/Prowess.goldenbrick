clc;
clear all;

simSysEnvFile     = 'simSysEnv-2024-02-15--22-07.mat' ;
load(simSysEnvFile)
    winSize = 400;
nThrow = sim.nThrow ;


%% 
SigFeat = [];
PBS1 = PBS;

    PBS = PBS1(10);
nThrow = length(PBS);

% find longest duration waveform contribution
mxLen = 0 ;
for throwIn = 1:nThrow
    thisPbs   = PBS{throwIn} ;

    mxLen = max(mxLen, ...
        length(thisPbs.sig)+ thisPbs.timeOffBin) ;
end


% -----------------------------------------------------------------------
% combine received waveforms
%
sTot = zeros(sys.nAnt, mxLen) ;

for throwIn = 1:nThrow
    %disp(['building waveform: ' num2str(throwIn)])

    thisPbs = PBS{throwIn} ;

    sTot(1:sys.nAnt,(1:length(thisPbs.sig)) + thisPbs.timeOffBin) ...
        =  sTot(1:sys.nAnt, ...
        (1:length(thisPbs.sig)) + thisPbs.timeOffBin) ...
        + thisPbs.sig ;
end

% -----------------------------------------------------------------------
% add receiver noise (unit variance noise per sample)
%

    SNRvals = [-30 -25 -20 -10 -5 0];
%SNRvals = [-5 0 5 10];
for thisSNR = 1:length(SNRvals)
    SNR = SNRvals(thisSNR);
TotalSNR = SNR + log(sys.nAnt) + log(winSize)
% lower signal power
x = sTot;
% sTot = 1/db2mag(SNR)*x;
if sim.addNoise
    % noise = (randn(size(sTot))+1i*randn(size(sTot)))/sqrt(2) ;
    % sTot = sTot + noise ;
    sTot1 = awgn(x,SNR);
end

% figure(1)
% plotParams2
% P = pspectrum(sTot(1,:), sim.oversamp*10^9,'spectrogram',...
%     'Leakage',1,'OverlapPercent',90, ...
%     'MinThreshold',-20,'FrequencyLimits',[-.5*10^9 .5*10^9]);



%%

fracBW = .1;
% fracBW = 1;
nUp = 1;
downSamp = sim.oversamp/fracBW ;
% downSamp = 1 ;
fracFreqShift = 0.05;

y = extractSubband(sTot1, fracFreqShift, nUp, downSamp);
% y = sTot;

figure
plotParams2
pspectrum(y(1,:), 10^9*fracBW,'spectrogram',...
    'Leakage',1,'OverlapPercent',90, ...
    'MinThreshold',-20,'FrequencyLimits',...
    ([-.5*10^9 .5*10^9]*fracBW));

 [nAnt,subSamps] = size(y) ;
nWin = floor(subSamps/winSize) ;

DetTruth = zeros(1,nWin) ;
eDetTF    = zeros(1,nWin) ;
kDetTF    = zeros(1,nWin) ;
aepDetTF  = zeros(1,nWin) ;
aepKDetTF = zeros(1,nWin) ;
CPDetTF = zeros(1,nWin) ; 
DetTF = zeros(1,nWin) ;

eApproach.type = 'energy' ;
eApproach.detail.thresh = .5 ;

kApproach.type = 'kurtosis' ;
kApproach.detail.thresh = -.4 ;

AEPApproach.type = 'aep' ;
aepApproach.detail.thresh = 5;
AEPApproach.detail.nCovSamps  = 50 ;
maxEig = [];

chirpApproach.type = 'chirpdet';
chirpApproach.detail.thresh = 0.803398908444998;
chirpApproach.detail.lag = 50;
chirpApproach.detail.fs = 10^9*fracBW/downSamp;

cyclicApproach.type = 'cyclicdet';
cyclicApproach.detail.threshIFFT = 0.0077;
cyclicApproach.detail.thresh = 0.197436976921083;
cyclicApproach.detail.lag = 5;
cyclicApproach.detail.cycSamps = 20;

mmEigApproach.type = 'MaxMinEIG' ;
mmEigApproach.detail.thresh = 25.4846290491203;

EngEigApproach.type = 'EngEig' ;
EngEigApproach.detail.thresh = 0.018221798058277;

MaxEigStdApproach.type = 'MaxEigStd' ;
MaxEigStdApproach.detail.thresh = 1.296620621175778e+02;

sDIFApproach.type = 'sDIF' ;
sDIFApproach.detail.threshChirp = 6.815224503341669e+05;
sDIFApproach.detail.thresh = 6.815224503341669e+05;
sDIFApproach.detail.Fs = 10^9*fracBW/downSamp;

zcrApproach.type = 'ZCR';
zcrApproach.detail.thresh = 0.4; 

SpecApproach.type = 'SpecCentSpread';
SpecApproach.detail.thresh = 0.3; 
SpecApproach.detail.Fs = 10^9*fracBW/downSamp;
SpecApproach.detail.step = 50/10^9*fracBW/downSamp;

SpecEntApproach.type = 'SpecEntropy';
% SpecApproach.detail.thresh = 0.3; 
SpecEntApproach.detail.thresh = 0.24; 
SpecEntApproach.detail.Fs = 10^9*fracBW/downSamp;
SpecEntApproach.detail.numOfShortBlocks = 10;

SpecRolloffApproach.type = 'SpecRolloff';
SpecRolloffApproach.detail.thresh = 0.24; 
SpecRolloffApproach.detail.Fs = 10^9*fracBW/downSamp;
SpecRolloffApproach.detail.C = 0.9;

SpecFluxApproach.type = 'SpecFlux';
SpecFluxApproach.detail.thresh = 0.7; 
SpecFluxApproach.detail.Fs = 10^9*fracBW/downSamp;

aApproach = chirpApproach; 



for winIn = 1:nWin
    z = y(:,([1:winSize]+(winIn-1)*winSize)) ;
    aApproach.detail.winIn = winIn;
    detOut = ChirpDetect(z,aApproach);
    DetTF(winIn) = detOut.decision;
    Val(winIn) = detOut.vals;
    % windowFFT = detOut.windowFFT;
    % aApproach.detail.windowFFTPrev = windowFFT;

end

nth = 100;
th_low = min(Val(2:end)); th_high = max(Val(2:end));
th_range = linspace(th_low, th_high, nth);
x1 = downsample(x.',20); x1 = x1.';

for ii = 1:nth
    % mmEigApproach.detail.thresh = th_range(ii);
    aApproach.detail.thresh = th_range(ii);
    % MaxEigStdApproach.detail.thresh2 = th_range(ii);
%     kApproach.detail.thresh = kth_range(ii);
%     AEPApproach.detail.thresh = AEPth_range(ii);



    for winIn = 1:nWin

        z = y(:,([1:winSize]+(winIn-1)*winSize)) ;
        aApproach.detail.winIn = winIn;
        detOut = ChirpDetect(z, aApproach);
        eDetTF(winIn) = detOut.decision ;
        % windowFFT = detOut.windowFFT;
        % aApproach.detail.windowFFTPrev = windowFFT;
%         detOut        = detSig(z, kApproach) ;
%         eDetTF(winIn) = detOut.decision ;
%         detOut        = detSig(z, AEPApproach) ;
%         eDetTF(winIn) = detOut.decision ;

        z1 = x1(1,([1:winSize]+(winIn-1)*winSize));
        if any(z1)
            DetTruth(winIn) = 1;
        end

    end

    a = find(DetTruth==1);
    b = find(DetTruth==0);
    j=1;
    k=1;
    for i=1:length(DetTruth)
        if DetTruth(i)==1
            if eDetTF(i)==1
                pd(j) = 1;
            else
                pd(j) = 0;
            end
            j = j+1;
        else
            if eDetTF(i)==1
                pfa(k) = 1;
            else
                pfa(k) = 0;
            end
            k = k+1;
        end
    end

    Pd(thisSNR, ii) = length(find(pd==1))/length(pd);
    Pfa(thisSNR, ii) = length(find(pfa==1))/length(pfa);
    % pd = []; pfa = [];

end

figure(5);
plotParams2
plot(flipud(Pfa(thisSNR,:)),flipud (Pd(thisSNR,:))); hold on;
xlabel('Probability of False Alarm')
ylabel('Probability of Detection')
title('Cyclic Prefix Detect ROC Chirp')

end






