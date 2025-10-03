% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
function det = hypoDet(hypo,buffChar,buffStartIn)

% assumes global variable "subBuffer" (nAnt x nSamp) ;

%nAnt  = buffChar.nAnt ;
%nSamp = buffChar.nSamp ;

approach = hypo.approach ;

% global variable 
sig = subBuffer(:,(1:hypo.nSamp)+(buffStartIn-1)) ;

if hypo.applyBF
    sig = hypo.bf' * sig ;
end

det = detBuffSig(sig, approach) ;


!!!!!!!!!!!!!!!!!!!!
working...


% -----------------------------------------------------------------------
% extract subbands

downSamp = 20 ;

% extractSubband(sigIn, fracFreqShift, nUp, nDown)
subSig = extractSubband(sTot, .1/sim.oversamp, 1, downSamp) ;

figure(3)
plotParams2
pspectrum(subSig(1,:), sim.oversamp*10^9/downSamp,'spectrogram',...
    'Leakage',1,'OverlapPercent',90, ...
    'MinThreshold',-20,'FrequencyLimits',...
    ([-.5*10^9 .5*10^9]/downSamp));

% -----------------------------------------------------------------------
% Analyze subband
[nAnt,subSamps] = size(subSig) ;
winSize = 500;

nWin = floor(subSamps/winSize) ;

eDetTF   = zeros(1,nWin) ;
kDetTF   = zeros(1,nWin) ;
aepDetTF = zeros(1,nWin) ;

eApproach.type = 'energy' ;
eApproach.detail.thresh = .5 ;

kApproach.type = 'kurtosis' ;
kApproach.detail.thresh = -.5 ;

aepApproach.type = 'aep' ;
aepApproach.detail.thresh = 10 ;
aepApproach.detail.nCovSamps  = 50 ;


% 
% % test ek
% kApproach.detail.thresh = 0 ;
% for winIn = 1:nWin
% 
%     z = subSig(:,([1:winSize]+(winIn-1)*winSize)) ;
% 
%     detOut        = detSig(z, kApproach) ;
%     kDetVal(winIn) = detOut.exKur ;
% end
% 
% figure(14)
% plot(kDetVal)
% 

for winIn = 1:nWin
    
    z = subSig(:,([1:winSize]+(winIn-1)*winSize)) ;

    detOut        = detSig(z, eApproach) ;
    eDetTF(winIn) = detOut.decision ;

    if eDetTF(winIn)
        detOut        = detSig(z, kApproach) ;
        kDetTF(winIn) = detOut.decision ;
    end

    if eDetTF(winIn)
        detOut        = detSig(z, aepApproach) ;
        aepDetTF(winIn) = detOut.decision ;
    end

end

figure(4)
clf
plotParams2
p = plot([eDetTF-.05; kDetTF ; aepDetTF+.05].') ;
legend(p,'energy','kurtosis','aep')

disp('done')

