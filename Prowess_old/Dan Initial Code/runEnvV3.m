% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% Build and analyze RF environment
clear all

% simSysEnvFile     = '' ;
% simSysEnvFile     = 'simSysEnv-2023-11-19--14-59.mat' ;
simSysEnvFile     = 'simSysEnv-2024-03-13--01-36.mat' ;
loadSimSysEnvFile = false ;
saveSimSysEnvFile = true ;
% loadSimSysEnvFile = true ;
% saveSimSysEnvFile = false ;

% -----------------------------------------------------------------------
% environment

if loadSimSysEnvFile


    %load env file
    load(simSysEnvFile)

else
    % ---------------------
    % simulation control parameters
    sim.nThrow   = 17;
    sim.oversamp = 2 ;
    sim.maxStartDelay = 5*10^5 ;
    sim.arrayModel    = "ranPhase" ; % options "gaussian" or "ranPhase"
    sim.addNoise      = true ; % true or false
    sim.band1 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.35, 0.35, 0.3];
    sim.band2 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.35, 0.35, 0.3];
    sim.band3 = [0, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.3, 0.3, 0.3];
    sim.band4 = [0.06 0.131 0.131 0.131 0.065 0.065 0.131 0.065 0.065 ...
    	0.0328 0.0328 0.0328 0.0328	0.065 0.006	0.006 0];

    % ---------------------
    % Overall environmental and system parameters
    sys.nAnt          = 8 ;
    sys.bandwidthBins = 10^3 * sim.oversamp ; % unitless frequency bins


    % ---------------------
    %load envParams
    envParams
    for i=1:length(env)
        waveF{i} = env{1, i}.mod;
    end

    % ---------------------
    % build environment
    PBS = envSetup(sim,sys,env) ;

    dt    = datetime('now') ;
    dtStr = datestr(dt,'yyyy-mm-dd--HH-MM') ;
    fName = ['simSysEnv-' dtStr]

    if (~loadSimSysEnvFile) && saveSimSysEnvFile
        save(fName, 'sim', 'sys', 'env', 'PBS') ;
    end
end


% simplify
nThrow = sim.nThrow ;
% nThrow = 7;
% PBS = PBS([1 2 4 6 10 11 13 15]);
% PBS(4)= [];
% nThrow = length(PBS);
% -----------------------------------------------------------------------
% display waveforms
for throwIn = 1:nThrow
    thisPbs = PBS{throwIn} ;

    disp([num2str(throwIn) ...
        '. ' thisPbs.wave.label ...
        ', mod = ' thisPbs.wave.mod, ...
        ', cenFreq = ' num2str(thisPbs.cenFreqBin) ...
        ', bwBins = ' num2str(thisPbs.wave.bwBins) ...
        ])
end

% -----------------------------------------------------------------------
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
% y = 1/db2mag(10)*x;
if sim.addNoise
    noise = (randn(size(sTot))+1i*randn(size(sTot)))/sqrt(2) ;
    sTot = sTot + noise ;
    % sTot = awgn(x,SNR);
end

% -----------------------------------------------------------------------
% plot spectral waterfall
%
figure(1)
plotParams2
pspectrum(sTot(1,:), sim.oversamp*10^9,'spectrogram',...
    'Leakage',1,'OverlapPercent',90, ...
    'MinThreshold',-20,'FrequencyLimits',[0*10^9 1*10^9]);

% if sys.nAnt > 1
%     figure(2)
%     plotParams2
%     pspectrum(sTot(2,:), sim.oversamp*10^9,'spectrogram',...
%         'Leakage',1,'OverlapPercent',90, ...
%         'MinThreshold',-20,'FrequencyLimits',[-.5*10^9 .5*10^9]);
% end

% -----------------------------------------------------------------------
% extract subbands


fracBW = .1;
nUp = 1;
downSamp = sim.oversamp/fracBW ;
fracFreqShift = 0.05;

subSig = extractSubband(sTot, fracFreqShift, nUp, downSamp);
% subSig = extractSubband(sTot, 1/downSamp, 1, downSamp) ;

figure
plotParams2
pspectrum(subSig(1,:), 10^9*fracBW,'spectrogram',...
    'Leakage',1,'OverlapPercent',90, ...
    'MinThreshold',-20,'FrequencyLimits',...
    ([-.5*10^9 .5*10^9]*fracBW));

% -----------------------------------------------------------------------
% Analyze subband
[nAnt,subSamps] = size(subSig) ;
winSize = 200;

nWin = floor(subSamps/winSize) ;

eDetTF    = zeros(1,nWin) ;
e1DetTF    = zeros(1,nWin) ;
e2DetTF    = zeros(1,nWin) ;
e4DetTF    = zeros(1,nWin) ;
e8DetTF    = zeros(1,nWin) ;
kDetTF    = zeros(1,nWin) ;
aepDetTF  = zeros(1,nWin) ;
aepKDetTF = zeros(1,nWin) ;
aepCPDetTF = zeros(1,nWin) ;
aepChirpDetTF = zeros(1,nWin) ;
ChirpDetTF = zeros(1,nWin) ;
CPDetTF = zeros(1,nWin) ;

eExTF    = zeros(1,nWin) ;
e1ExTF    = zeros(1,nWin) ;
e2ExTF    = zeros(1,nWin) ;
e4ExTF    = zeros(1,nWin) ;
e8ExTF    = zeros(1,nWin) ;
kExTF    = zeros(1,nWin) ;
aepExTF  = zeros(1,nWin) ;
aepKExTF = zeros(1,nWin) ;
aepCPExTF = zeros(1,nWin) ;
aepChirpExTF = zeros(1,nWin) ;
ChirpExTF = zeros(1,nWin) ;
CPExTF = zeros(1,nWin) ;

eApproach.type = 'energy' ;
eApproach.detail.thresh = .5 ;

kApproach.type = 'kurtosis' ;
kApproach.detail.thresh = -.5 ;

aepApproach.type = 'aep' ;
aepApproach.detail.thresh = 5;
aepApproach.detail.nCovSamps  = 50 ;

chirpApproach.type = 'chirpdet';
chirpApproach.detail.thresh = 3;
% chirpApproach.detail.thresh = 0.803398908444998;
% chirpApproach.detail.thresh = 0.4;
chirpApproach.detail.lag = 50;
chirpApproach.detail.fs = 10^9*fracBW/downSamp;

cyclicApproach.type = 'cyclicdet';
% cyclicApproach.detail.thresh = 1.5;
cyclicApproach.detail.thresh = 1.019892932078607;
% cyclicApproach.detail.thresh = 0.3;
cyclicApproach.detail.lag = 5;
cyclicApproach.detail.cycSamps = 16;


%% Tree 1

% for winIn = 1:nWin
%
%     z = subSig(:,([1:winSize]+(winIn-1)*winSize)) ;
%
%     detOut        = detSig(z, eApproach) ;
%     eDetTF(winIn) = detOut.decision ;
%
%     if eDetTF(winIn)
%         detOut        = detSig(z, kApproach) ;
%         kDetTF(winIn) = detOut.decision ;
%     end
%
%     if eDetTF(winIn)
%         detOut        = detSig(z, aepApproach) ;
%         aepDetTF(winIn) = detOut.decision ;
%
%         thisAepKdet = false ;
%         for testIn = 1:length(detOut.detail.aepDetList)
%
%             if detOut.detail.aepDetList(testIn)
%                 z1 = detOut.detail.aepEigVec(:,testIn)' * z ;
%                 thisDetOut  = detSig(z1, kApproach) ;
%                 thisAepKdet = thisAepKdet | thisDetOut.decision ;
%             end
%         end
%         aepKDetTF(winIn) = thisAepKdet ;
%
%     end
%
% end

%% Tree 2

for winIn = 1:nWin
    e1ExTF(winIn) = 1;

    z = subSig(:,([1:winSize]+(winIn-1)*winSize)) ;

    detOut        = EnergyDet(z, 1, eApproach) ;
    e1DetTF(winIn) = detOut.decision ;

    if e1DetTF(winIn)
        detOut        = detSig(z, kApproach) ;
        kDetTF(winIn) = detOut.decision ;
        kExTF(winIn) = 1;
        if kDetTF(winIn)
            detOut  = ChirpDetect(z,chirpApproach);
            ChirpDetTF(winIn) = detOut.decision ;
            % Chirpval(winIn) = detOut.vals;
            ChirpExTF(winIn) = 1;
        else
            detOut = CPDetect(z,cyclicApproach);
            CPDetTF(winIn) = detOut.decision ;
            % CPval(winIn) = detOut.CPCAF;
            CPExTF(winIn) = 1;
            if CPDetTF(winIn)

            else
                detOut        = detSig(z, aepApproach) ;
                aepDetTF(winIn) = detOut.decision ;
                aepExTF(winIn) = 1;

                thisAepChirpdet = false ;
                thisAepKdet = false;
                for testIn = 1:length(detOut.detail.aepDetList)

                    if detOut.detail.aepDetList(testIn)
                        aepChirpExTF(winIn) = 1;
                        aepCPExTF(winIn) = 1;
                        z1 = detOut.detail.aepEigVec(:,testIn)' * z ;
                        thisDetOut1  = ChirpDetect(z1, chirpApproach) ;
                        thisDetOut2  = detSig(z1, kApproach) ;
                        thisAepChirpdet = thisAepChirpdet | thisDetOut1.decision ;
                        thisAepKdet = thisAepKdet | thisDetOut2.decision ;
                    end
                end
                aepChirpDetTF(winIn) = thisAepChirpdet ;
                aepKDetTF(winIn) = thisAepKdet;



            end
        end
    else

        detOut        = EnergyDet(z, 4, eApproach) ;
        e4DetTF(winIn) = detOut.decision ;
        e4ExTF(winIn) = 1;
        e2ExTF(winIn) = 0;



        if e4DetTF(winIn)
            detOut        = detSig(z, kApproach) ;
            kDetTF(winIn) = detOut.decision ;
            kExTF(winIn) = 1;
            if kDetTF(winIn)
                detOut  = ChirpDetect(z, chirpApproach);
                ChirpDetTF(winIn) = detOut.decision ;
                ChirpExTF(winIn) = 1;
            else
                detOut = CPDetect(z,cyclicApproach);
                CPDetTF(winIn) = detOut.decision ;
                CPExTF(winIn) = 1;
                if CPDetTF(winIn)

                else
                    detOut        = detSig(z, aepApproach) ;
                    aepDetTF(winIn) = detOut.decision ;
                    aepExTF(winIn) = 1;

                    thisAepChirpdet = false ;
                    thisAepKdet = false;
                    for testIn = 1:length(detOut.detail.aepDetList)

                        if detOut.detail.aepDetList(testIn)
                            aepChirpExTF(winIn) = 1;
                            aepCPExTF(winIn) = 1;
                            z1 = detOut.detail.aepEigVec(:,testIn)' * z ;
                            thisDetOut1  = ChirpDetect(z1, chirpApproach) ;
                            thisDetOut2  = detSig(z1, kApproach) ;
                            thisAepChirpdet = thisAepChirpdet | thisDetOut1.decision ;
                            thisAepKdet = thisAepKdet | thisDetOut2.decision ;
                        end
                    end
                    aepChirpDetTF(winIn) = thisAepChirpdet ;
                    aepKDetTF(winIn) = thisAepKdet;


                end
            end
        else
            detOut        = EnergyDet(z, 8, eApproach) ;
            e8DetTF(winIn) = detOut.decision ;
            e8ExTF(winIn) = 1;
            e4ExTF(winIn) = 0;


            if e8DetTF(winIn)
                detOut        = detSig(z, kApproach) ;
                kDetTF(winIn) = detOut.decision ;
                kExTF(winIn) = 1;
                if kDetTF(winIn)
                    detOut  = ChirpDetect(z, chirpApproach);
                    ChirpDetTF(winIn) = detOut.decision ;
                    ChirpExTF(winIn) = 1;
                else
                    detOut = CPDetect(z,cyclicApproach);
                    CPDetTF(winIn) = detOut.decision ;
                    CPExTF(winIn) = 1;
                    if CPDetTF(winIn)

                    else
                        detOut        = detSig(z, aepApproach) ;
                        aepDetTF(winIn) = detOut.decision ;
                        aepExTF(winIn) = 1;

                        thisAepChirpdet = false ;
                        thisAepKdet = false;
                        for testIn = 1:length(detOut.detail.aepDetList)

                            if detOut.detail.aepDetList(testIn)
                                aepChirpExTF(winIn) = 1;
                                aepCPExTF(winIn) = 1;
                                z1 = detOut.detail.aepEigVec(:,testIn)' * z ;
                                thisDetOut1  = ChirpDetect(z1, chirpApproach) ;
                                thisDetOut2  = detSig(z1, kApproach) ;
                                thisAepChirpdet = thisAepChirpdet | thisDetOut1.decision ;
                                thisAepKdet = thisAepKdet | thisDetOut2.decision ;
                            end
                        end
                        aepChirpDetTF(winIn) = thisAepChirpdet ;
                        aepKDetTF(winIn) = thisAepKdet;


                    end
                end
            end
        end
    end
end






figure(4)
clf
plotParams2
p = plot((1:length(e8DetTF))*winSize/(10^9*fracBW)*10^6, ...
    [e1DetTF-.15; e4DetTF-.1; e8DetTF-.05; kDetTF ; CPDetTF+.05; ChirpDetTF+.1; aepDetTF+.15; aepChirpDetTF+.2; aepKDetTF+.25].') ;
xlabel('Time (µs)')
ylabel('Detection')
title('Detection Output');
ax = gca ;
ax.YTick = [0 1] ;
ax.YTickLabel = {'no','det'} ;
axis([ 1 (length(eDetTF)*winSize/(10^9*fracBW)*10^6) -.2 1.3])
legend(p, 'energy 1', 'energy 4', 'energy 8', 'kurtosis', 'cyclic prefix', 'chirp', 'aep', 'aep chirp', 'aep kurtosis', ...
    'Location','NorthEastOutside')

makePlots = false ;
dt    = datetime('now') ;
dtStr = datestr(dt,'yyyy-mm-dd--HH-MM') ;

if makePlots
    dumpFig([ 'Spectrum' dtStr],1) ;
    dumpFig([ 'SubSpectrum' dtStr],3) ;
    dumpFig([ 'SubSpecDet' dtStr],4) ;
end

DetOut = [e1DetTF; e4DetTF; e8DetTF; kDetTF; CPDetTF; ChirpDetTF; aepDetTF; aepChirpDetTF; aepKDetTF];

disp('done')

figure(5)
clf
plotParams2
p = plot((1:length(e8ExTF))*winSize/(10^9*fracBW)*10^6, ...
    [e1ExTF-.15; e4ExTF-.1; e8ExTF-.05; kExTF ; CPExTF+.05; ChirpExTF+.1; aepExTF+.15; aepChirpExTF+.2; aepKExTF+.25].') ;
xlabel('Time (µs)')
ylabel('Usage')
title('Detector Usage')
ax = gca ;
ax.YTick = [0 1] ;
ax.YTickLabel = {'no','yes'} ;
axis([ 1 (length(eDetTF)*winSize/(10^9*fracBW)*10^6) -.2 1.3])
legend(p, 'energy 1', 'energy 4', 'energy 8', 'kurtosis', 'cyclic prefix', 'chirp', 'aep', 'aep chirp', 'aep kurtosis', ...
    'Location','NorthEastOutside')

DetUsage = [e1ExTF; e4ExTF; e8ExTF; kExTF; CPExTF; ChirpExTF; aepExTF; aepChirpExTF; aepKExTF];

