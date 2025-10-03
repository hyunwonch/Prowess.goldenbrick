% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% Build and analyze RF environment
clear all

% -----------------------------------------------------------------------
% simulation control parameters
sim.nThrow   = 15 ;
sim.oversamp = 2 ;
sim.maxStartDelay = 80000 ;

% Overall environmental and system parameters
sys.nAnt          = 1 ;
sys.bandwidthBins = 10^3 * sim.oversamp ; % unitless frequency bins

%envParam.nSamp       = 2000
%envParam.delaySpread = 1 ;


% -----------------------------------------------------------------------
% randomly build environmental parameters
% -- hand build one

% {
%    WAVEFORM, 
%    centerFreq, 
%    bandwidth (in # bins), 
%    packet duration (in waveform critical samples),
%    {waveform-dependent parameters} }

env = {} ;

wave.mod = 'bpsk' ;
wave.cenFreqBin = round(.1 * sys.bandwidthBins/sim.oversamp) ;
wave.bwBins = 100 ;
wave.critSamps = 400 ;
% wave.details = {} ;
env{1} = wave ;

wave.mod = 'mPsk' ;
wave.cenFreqBin = round(.2 * sys.bandwidthBins/sim.oversamp) ;
wave.bwBins = 100 ;
wave.critSamps = 500 ;
wave.details.nPhase = 8 ;
env{2} = wave ;

wave.mod = 'ranFreqHop' ;
wave.cenFreqBin = round(.3 * sys.bandwidthBins /sim.oversamp) ;
wave.bwBins = 100 ;
wave.critSamps = 300 ;
wave.details.hopBins  = 25 ; 
wave.details.hopNSyms = 10 ;
wave.details.hopGap   = 10 ;
wave.details.hopOvSamp = 4 ;
env{3} = wave ;

wave.mod = 'bpsk' ;
wave.cenFreqBin = round(-.4 * sys.bandwidthBins /sim.oversamp) ;
wave.bwBins = 100 ;
wave.critSamps = 500 ;
% wave.details = {} ;
env{4} = wave ;

wave.mod = 'ofdm' ;
wave.cenFreqBin = round(-.2 * sys.bandwidthBins /sim.oversamp) ;
wave.bwBins = 100 ;
wave.critSamps = 4000 ;
wave.details.nPoint = 128 ;
wave.details.nCyc = 16
env{5} = wave ;

wave.mod = 'ofdm' ;
wave.cenFreqBin = round(-.3 * sys.bandwidthBins /sim.oversamp) ;
wave.bwBins = 100 ;
wave.critSamps = 2000 ;
wave.details.nPoint = 128 ;
wave.details.nCyc = 16
env{6} = wave ;

wave.mod = 'ranFreqHop' ;
wave.cenFreqBin = round(.0 * sys.bandwidthBins /sim.oversamp) ;
wave.bwBins = 100 ;
wave.critSamps = 300 ;
wave.details.hopBins  = 20 ; 
wave.details.hopNSyms = 10 ;
wave.details.hopGap   = 20 ;
wave.details.hopOvSamp = 4 ;
env{7} = wave ;

%wave.mod = 'ranFreqHop' ;
%wave.cenFreqBin = round(.0 * sys.bandwidthBins) ;
%wave.bwBins = 100 ;
%wave.critSamps = 300 ;
%wave.details.hopBins  = 20 ; 
%wave.details.hopNSyms = 10 ;
%wave.details.hopGap   = 20 ;
%wave.details.hopOvSamp = 4 ;
%env{8} = wave ;

%wave.mod = 'ranFreqHop' ;
%wave.cenFreqBin = round(.0 * sys.bandwidthBins) ;
%wave.bwBins = 100 ;
%wave.critSamps = 300 ;
%wave.details.hopBins  = 20 ; 
%wave.details.hopNSyms = 10 ;
%wave.details.hopGap   = 20 ;
%wave.details.hopOvSamp = 4 ;
%env{9} = wave ;

wave.mod = 'chirp' ;
wave.cenFreqBin = round(-.15 * sys.bandwidthBins /sim.oversamp) ;
wave.bwBins = 100 ; % nBbins
wave.critSamps = 40000 ;
wave.details.nCritPulseSamp    = 1000 ; 
wave.details.nPulseToPulseCrit = 4000 ;
wave.details.freqOvSamp = 4 ;
env{8} = wave ;



% -----------------------------------------------------------------------
% build environment
%

% ignoring wave.cenFreqBin

nThrow = sim.nThrow ;

for throwIn = 1:nThrow

    waveIn = randi(length(env)) ;
    wave   = env{waveIn} ; 
   
    cenFreq = (rand()-1/2) ;
    cenFreqBin = round(cenFreq * sys.bandwidthBins /sim.oversamp) ;
    
    timeOffBin(throwIn) = floor(rand()* sim.maxStartDelay) ;
      
    disp(['throwIn = ' num2str(throwIn) ...
        ', mod = ' wave.mod, ', cenFreq = ' num2str(cenFreq)])
    
    switch wave.mod
        case 'bpsk'
           baseS = bpsk(wave.critSamps,sim.oversamp) ;
           
           PBS{throwIn} = reband(baseS, sys.bandwidthBins, wave.bwBins, cenFreqBin, sim.oversamp) ;

        case 'mPsk'
           baseS = mPsk(wave.critSamps, wave.details.nPhase,sim.oversamp) ;

           PBS{throwIn} = reband(baseS, sys.bandwidthBins, wave.bwBins, cenFreqBin , sim.oversamp) ;            

        case 'ranFreqHop'
           nHop = floor(wave.critSamps/(wave.details.hopNSyms+wave.details.hopGap)) ;

           baseS = ranFreqHop(nHop, wave.details.hopNSyms, wave.details.hopBins, wave.details.hopGap,sim.oversamp,wave.details.hopOvSamp) ;

           PBS{throwIn} = reband(baseS, sys.bandwidthBins, wave.bwBins, cenFreqBin , sim.oversamp*wave.details.hopOvSamp) ;              

        case 'ofdm'
           baseS = ... 
               ofdmFrame(wave.critSamps, wave.details.nPoint, wave.details.nCyc, sim.oversamp) ;

           PBS{throwIn} = ...
               reband(baseS, sys.bandwidthBins, wave.bwBins, cenFreqBin , sim.oversamp) ;
           
        case 'chirp'
            
           nPulses = floor(wave.critSamps/wave.details.nPulseToPulseCrit) ;
            
%            baseS = ...
%                 chirp(wave.bwBins, wave.details.nCritPulseSamp, wave.details.nPulseToPulseCrit, nPulses , wave.details.freqOvSamp) ;
            baseS = ...
                chirp(wave.details.nCritPulseSamp, wave.details.nPulseToPulseCrit, nPulses , wave.details.freqOvSamp) ;

           PBS{throwIn} = ...
               reband(baseS, sys.bandwidthBins, wave.bwBins * sim.oversamp* wave.details.freqOvSamp, cenFreqBin , 1) ;
           
%               reband(baseS, sys.bandwidthBins, wave.bwBins, wave.bwBins, wave.cenFreqBin, sim.oversamp) ;
           % reband(baseS, sysBWbins, conBWbins, targetBWbins, targetIFbin,ovSamp)

        otherwise
       
            disp('Err: Unknown case')
    end
end


% dummy combinations

mxLen = 0 ;
for throwIn = 1:nThrow
    mxLen = max(mxLen, ...
        length(PBS{throwIn})+ timeOffBin(throwIn)) ;
end

sTot = zeros(1,mxLen) ;
for throwIn = 1:nThrow
    sTot(1,(1:length(PBS{throwIn}))+timeOffBin(throwIn)) ...
        =  sTot(1,(1:length(PBS{throwIn}))+timeOffBin(throwIn)) + PBS{throwIn} ;
end

pspectrum(sTot, sim.oversamp*10^9,'spectrogram',...
    'Leakage',1,'OverlapPercent',90, ...
    'MinThreshold',-20,'FrequencyLimits',[-.5*10^9 .5*10^9]);

disp('done')

