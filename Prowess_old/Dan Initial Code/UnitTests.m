clc;
clear all;

simSysEnvFile     = 'simSysEnv-2024-03-17--21-52.mat' ;
load(simSysEnvFile)
winSize = 200;
nThrow = sim.nThrow ;

%%

% mxLen = 0 ;
% for throwIn = 1:nThrow
%     thisPbs   = PBS{throwIn} ;
%
%     mxLen = max(mxLen, ...
%         length(thisPbs.sig)+ thisPbs.timeOffBin) ;
% end
%
% sTot = zeros(sys.nAnt, mxLen) ;
% % sig = 2;
% % thisPbs = PBS{sig} ;
%
% sTot(1:sys.nAnt,(1:length(thisPbs.sig)) + thisPbs.timeOffBin) ...
%     =  sTot(1:sys.nAnt, ...
%     (1:length(thisPbs.sig)) + thisPbs.timeOffBin) ...
%     + thisPbs.sig ;
%
% ISNRgain = 10*(log10(winSize));
% SNR    = 20;        % Target SNR in dBs
% ISNR = SNR+ISNRgain;
% y = awgn(sTot,SNR);
%
% if sim.addNoise
%     noise = (randn(size(sTot))+1i*randn(size(sTot)))/sqrt(2) ;
%     sTot = sTot + noise ;
%     % sTot = awgn(x,SNR);
% end
%
% figure(1)
% plotParams2
% pspectrum(sTot(1,:), sim.oversamp*10^9,'spectrogram',...
%     'Leakage',1,'OverlapPercent',90, ...
%     'MinThreshold',-20,'FrequencyLimits',[-.5*10^9 .5*10^9]);

%%
SigFeat = [];
for i=1:length(env)
    waveF{i} = env{1, i}.mod;
end
PBS1 = PBS;
for jj = 1:4
    PBS = PBS1(jj);
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
    SNR = 20;
    % lower signal power
    x = sTot;
    % sTot = 1/db2mag(SNR)*x;
    if sim.addNoise
        % noise = (randn(size(sTot))+1i*randn(size(sTot)))/sqrt(2) ;
        % sTot = sTot + noise ;
        sTot = awgn(x,SNR);
    end
    % sTot = x;
    % 
    % figure(1)
    % plotParams2
    % pspectrum(sTot(2,:), sim.oversamp*10^9,'spectrogram',...
    %     'Leakage',1,'OverlapPercent',90, ...
    %     'MinThreshold',-20);



    %%

    fracBW = .1;
    % fracBW = 1;
    nUp = 1;
    downSamp = sim.oversamp/fracBW ;
    % downSamp = 1 ;
    fracFreqShift = 0.05;

    y = extractSubband(sTot, fracFreqShift, nUp, downSamp);
    % y = sTot;

    figure(jj); subplot(2,1,1);
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
    mmEigDetTF = zeros(1,nWin) ;

    eApproach.type = 'energy' ;
    eApproach.detail.thresh = .5 ;

    kApproach.type = 'kurtosis' ;
    kApproach.detail.thresh = -.4 ;

    AEPApproach.type = 'aep' ;
    aepApproach.detail.thresh = 5;
    AEPApproach.detail.nCovSamps  = 50 ;
    maxEig = [];

    %%

    chirpApproach.type = 'chirpdet';
    chirpApproach.detail.thresh = 0.2;
    chirpApproach.detail.lag = 50;
    chirpApproach.detail.fs = 10^9*fracBW/downSamp;

    cyclicApproach.type = 'cyclicdet';
    cyclicApproach.detail.thresh = 0.3;
    % cyclicApproach.detail.thresh = 0.5*10^4; %for CPDetect2
    cyclicApproach.detail.lag = 5;
    cyclicApproach.detail.cycSamps = 16;

    %%

    sDIFApproach.type = 'sDIF' ;
    % sDIFApproach.detail.threshChirp = 6.815224503341669e+05;
    sDIFApproach.detail.thresh = 6.815224503341669e+05;
    % sDIFApproach.detail.threshOFDM = 9.498044435570168e+05;
    sDIFApproach.detail.Fs = 10^9*fracBW/downSamp;

    MaxPSDIAApproach.type = 'MaxPSDIA' ;
    MaxPSDIAApproach.detail.thresh = 0.05;
    MaxPSDIAApproach.detail.Fs = 10^9*fracBW/downSamp;

    sdIAApproach.type = 'sDIA' ;
    sdIAApproach.detail.thresh = 0.05;
    sdIAApproach.detail.Fs = 10^9*fracBW/downSamp;

    sdIPApproach.type = 'sDIP' ;
    sdIPApproach.detail.thresh = 0.05;
    sdIPApproach.detail.Fs = 10^9*fracBW/downSamp;

    sdabsIAApproach.type = 'sDAbsIA' ;
    sdabsIAApproach.detail.thresh = 0.05;
    sdabsIAApproach.detail.Fs = 10^9*fracBW/downSamp;

    sdabsIPApproach.type = 'sDAbsIP' ;
    sdabsIPApproach.detail.thresh = 0.05;
    sdabsIPApproach.detail.Fs = 10^9*fracBW/downSamp;

    %%

    mmEigApproach.type = 'MaxMinEIG' ;
    mmEigApproach.detail.thresh = 4;

    EngEigApproach.type = 'EngEig' ;
    EngEigApproach.detail.thresh = 0.04;

    mmEigApproach.type = 'MaxEigStd' ;
    mmEigApproach.detail.thresh = 4;

    %% 
    zcrApproach.type = 'ZCR';
    zcrApproach.detail.thresh = 0.5;

    EnEntropyApproach.type = 'EngEntropy';
    EnEntropyApproach.detail.thresh = 1;
    EnEntropyApproach.detail.numOfShortBlocks = 10;

    SpecCApproach.type = 'SpecCent';
    SpecCApproach.detail.thresh = 0.3;
    SpecCApproach.detail.Fs = 10^9*fracBW/downSamp;

    SpecSApproach.type = 'SpecSpread';
    SpecSApproach.detail.thresh = 0.24;
    SpecSApproach.detail.Fs = 10^9*fracBW/downSamp;

    SpecEntApproach.type = 'SpecEntropy';
    SpecEntApproach.detail.thresh = 0.24;
    SpecEntApproach.detail.Fs = 10^9*fracBW/downSamp;
    SpecEntApproach.detail.numOfShortBlocks = 10;

    SpecRolloffApproach.type = 'SpecRolloff';
    SpecRolloffApproach.detail.thresh = 0.7;
    SpecRolloffApproach.detail.Fs = 10^9*fracBW/downSamp;
    SpecRolloffApproach.detail.C = 0.9;

    SpecFluxApproach.type = 'SpecFlux';
    SpecFluxApproach.detail.thresh = 0.7;
    SpecFluxApproach.detail.Fs = 10^9*fracBW/downSamp;
    % SpecFluxApproach.detail.windowFFTPrev = zeros(winSize/2,1);

    nPowerApproach.type = 'nPower';
    nPowerApproach.detail.thresh = 0.7;
    nPowerApproach.detail.Fs = 10^9*fracBW/downSamp;

    nCumulantApproach.type = 'nCumulant';
    nCumulantApproach.detail.thresh = 0.7;
    nCumulantApproach.detail.Fs = 10^9*fracBW/downSamp;

    %%


    % Features = stFeatureExtraction(y.', sDIFApproach.detail.Fs, 200/sDIFApproach.detail.Fs, 200/sDIFApproach.detail.Fs);
    % Features = Features(1:8,:);
    % %
    % SigFeat{jj} = Features;


    % Markers = {'r-','b--','r-','k-.','c','b--','k-.','r-','g-.','g-.'};
    % FeatDetails = {'feature zcr','feature energy','feature energy entropy','feature spectral centroid','feature spectral spread','feature spectral entropy','feature spectral flux','feature spectral rolloff'};
    % for kk = 1:8
    %
    %     for i=1:10
    %         plotParams2;
    %         figure(kk+1)
    %         plot(abs(SigFeat{1,i}(kk,:)),Markers{i}); hold on;
    %         Label{i} = env{1,i}.label;
    %         title(sprintf('%s',FeatDetails{kk}))
    %     end
    %     legend(Label)
    % end


    % y = y(:,1000:end);


    for winIn = 1:nWin
        z = y(:,([1:winSize]+(winIn-1)*winSize)) ;
        %%
          % detOut = detSig(z,kApproach);
          % kDetTF(winIn) = detOut.decision;
          % Val(winIn) = detOut.exKur;

        %%
        % detOut = ChirpDetect(z, chirpApproach);
        % ChirpDetTF(winIn) = detOut.decision;
        % Corr(winIn,:) = detOut.Corr;
        % Val(winIn) = detOut.vals;
        % ChirpRate(winIn) = detOut.ChirpRate;

        %%
        % detOut = CPDetect(z, cyclicApproach);
        % CPDetTF(winIn) = detOut.decision;
        % % CorrVals(winIn,:)= detOut.Corrvals;
        % Corr(winIn,:)= detOut.CPCorr;
        % CorrVal(winIn)= detOut.CPCAF;
        % lags = detOut.lags;

        % %
        %     detOut = MaxMinEig(z,mmEigApproach);
        %     mmEigDetTF(winIn) = detOut.decision;
        %     Val(winIn) = detOut.vals;

        %%
        % detOut = EngMinEig(z,EngEigApproach);
        % mmEigDetTF(winIn) = detOut.decision;
        % Val(winIn) = detOut.vals;

        %%
        % detOut = sdIF(z,sDIFApproach);
        % mmEigDetTF(winIn) = detOut.decision;
        % Val(winIn) = detOut.vals;
        % ValIF(winIn,:) = detOut.IF;

        %%
        % detOut = MaxPSDIA(z,MaxPSDIAApproach);
        % mmEigDetTF(winIn) = detOut.decision;
        % Val(winIn) = detOut.vals;
        % ValIF(winIn,:) = detOut.IA;

        %%
        % detOut = sdIP(z,sdIPApproach);
        % mmEigDetTF(winIn) = detOut.decision;
        % Val(winIn) = detOut.vals;
        % ValIF(winIn,:) = detOut.IP;

        %%
        % detOut = sdIA(z,sdIAApproach);
        % mmEigDetTF(winIn) = detOut.decision;
        % Val(winIn) = detOut.vals;
        % ValIF(winIn,:) = detOut.IA;

        %%
        detOut = zcrDet(z,zcrApproach);
        mmEigDetTF(winIn) = detOut.decision;
        Val(winIn) = detOut.vals;

        %%
        % detOut = EnEntropy(z,EnEntropyApproach);
        % mmEigDetTF(winIn) = detOut.decision;
        % Val(winIn) = detOut.vals;

        %%
        % detOut = SpecCentSpread(z,SpecSApproach);
        % mmEigDetTF(winIn) = detOut.decision;
        % Val(winIn) = detOut.vals;

        %%
        % detOut = SpecEntropy(z,SpecEntApproach);
        % mmEigDetTF(winIn) = detOut.decision;
        % Val(winIn) = detOut.vals;

        %%
        % detOut = SpecRolloff(z,SpecRolloffApproach);
        % mmEigDetTF(winIn) = detOut.decision;
        % Val(winIn) = detOut.vals;
        %

        %%
        % SpecFluxApproach.detail.winIn = winIn;
        % detOut = SpecFlux(z,SpecFluxApproach);
        % mmEigDetTF(winIn) = detOut.decision;
        % Val(winIn) = detOut.vals;
        % windowFFT = detOut.windowFFT;
        % SpecFluxApproach.detail.windowFFTPrev = windowFFT;

        %%
        % detOut = nPower(z,nPowerApproach);
        % mmEigDetTF(winIn) = detOut.decision;
        % Val(winIn) = detOut.vals;

        %%
        % detOut = nCumulant(z,nCumulantApproach);
        % mmEigDetTF(winIn) = detOut.decision;
        % Val(winIn) = detOut.vals2;


        %%
        % detOut = MaxEigStd(z,sDIFApproach);
        % mmEigDetTF(winIn) = detOut.decision;
        % Val(winIn) = detOut.vals;

        %%


        %     Eng(winIn) = sum(sum(z .* conj(z))) / nAnt /winSize ;
        %     exKurR       = kurtosis(real(z(:))) - 3 ;
        %     exKurI       = kurtosis(imag(z(:))) - 3 ;
        %     exKur(winIn)        = (exKurR+exKurI)/2 ;
        %     nCovSamp = AEPApproach.detail.nCovSamps ;
        %     nCov     = floor(winSize/nCovSamp) ;
        %
        %     z1 = z(:,1:nCovSamp) ;
        %     oldCov = z1 * z1' ;
        %
        %     for covIn = 1:(nCov-1)
        %         z2 = z(:,((1:nCovSamp)+covIn*nCovSamp)) ;
        %         cov = z2*z2';
        %         %             [eVec,eVal] = eigs(oldCov-cov,1) ;
        %         [eVec,eVal] = eigs(inv(oldCov)*cov,1) ;
        %         maxEig = [maxEig real(eVal)] ;
        %     end
    end



    figure(jj); subplot(2,1,2);
    plotParams2
    plot((1:length(Val(1:end)))*winSize/(10^9*fracBW)*10^6, Val(1:end)); %hold on;
    title(sprintf('%s', waveF{jj}));

    % end
waveF{jj}
    % figure;
        % clf
    % plotParams2
    % % p = plot((1:length(e8DetTF))*winSize/(10^9*fracBW)*10^6, ...
    % %     [eDetTF-.05; kDetTF ; aepDetTF+.05; aepKDetTF+.1].') ;
    % p = plot((1:length(mmEigDetTF))*winSize/(10^9*fracBW)*10^6, ...
    %     [mmEigDetTF-.05].') ;
    % xlabel('Time (µs)')
    % ylabel('Detection')
    % ax = gca ;
    % ax.YTick = [0 1] ;
    % ax.YTickLabel = {'no','det'} ;
    % axis([ 1 (length(mmEigDetTF)*winSize/(10^9*fracBW)*10^6) -.2 1.3])
    % legend(p, 'energy', 'kurtosis', 'aep', 'aep kurt',...
    %     'Location','NorthEastOutside')
end

% nth = 100;
% th_low = min(Eng); th_high = max(Eng);
% th_range = linspace(th_low, th_high, nth);
% % kth_low = min(exKur); kth_high = max(exKur);
% % kth_range = linspace(kth_low, kth_high, nth);
% % AEPth_low = min(maxEig); AEPth_high = max(maxEig);
% % AEPth_range = linspace(AEPth_low, AEPth_high, nth);
% 
% 
% 
% for ii = 1:nth
%     eApproach.detail.thresh = th_range(ii);
%     %     kApproach.detail.thresh = kth_range(ii);
%     %     AEPApproach.detail.thresh = AEPth_range(ii);
% 
% 
% 
%     for winIn = 1:nWin
% 
%         z = y(:,([1:winSize]+(winIn-1)*winSize)) ;
% 
%         detOut        = detSig(z, eApproach) ;
%         eDetTF(winIn) = detOut.decision ;
%         %         detOut        = detSig(z, kApproach) ;
%         %         eDetTF(winIn) = detOut.decision ;
%         %         detOut        = detSig(z, AEPApproach) ;
%         %         eDetTF(winIn) = detOut.decision ;
% 
%         z1 = sTot(1,([1:winSize]+(winIn-1)*winSize));
%         if any(z1)
%             DetTruth(winIn) = 1;
%         end
% 
%     end
% 
%     a = find(DetTruth==1);
%     b = find(DetTruth==0);
%     j=1;
%     k=1;
%     for i=1:length(DetTruth)
%         if DetTruth(i)==1
%             if eDetTF(i)==1
%                 pd(j) = 1;
%             else
%                 pd(j) = 0;
%             end
%             j = j+1;
%         else
%             if eDetTF(i)==1
%                 pfa(k) = 1;
%             else
%                 pfa(k) = 0;
%             end
%             k = k+1;
%         end
%     end
% 
%     Pd(ii) = length(find(pd==1))/length(pd);
%     Pfa(ii) = length(find(pfa==1))/length(pfa);
%     pd = []; pfa = [];
% 
% end
% 
% figure;
% plotParams2
% plot(flipud(Pfa),flipud (Pd));
% xlabel('Probability of False Alarm')
% ylabel('Probability of Detection')
% 
% figure(4)
% clf
% plotParams2
% p = plot((1:length(eDetTF))*winSize/(10^9)*10^6, ...
%     [eDetTF-.05].') ;
% xlabel('Time (µs)')
% ylabel('Detection')
% ax = gca ;
% ax.YTick = [0 1] ;
% ax.YTickLabel = {'no','det'} ;
% axis([ 1 (length(eDetTF)*winSize/(10^9)*10^6) -.2 1.3])
% 
% 
% 
