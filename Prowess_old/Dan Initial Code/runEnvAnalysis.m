% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% Build and analyze RF environment
clear all

% -----------------------------------------------------------------------
% simulation control parameters
sim.oversamp = 2 ;

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
wave.cenFreqBin = round(.1 * sys.bandwidthBins) ;
wave.bwBins = 100 ;
wave.critSamps = 1000 ;
% wave.details = {} ;
env{1} = wave ;

wave.mod = 'mPsk' ;
wave.cenFreqBin = round(.2 * sys.bandwidthBins) ;
wave.bwBins = 100 ;
wave.critSamps = 5000 ;
wave.details.nPhase = 8 ;
env{2} = wave ;

wave.mod = 'ranFreqHop' ;
wave.cenFreqBin = round(.3 * sys.bandwidthBins) ;
wave.bwBins = 100 ;
wave.critSamps = 300 ;
wave.details.hopBins  = 25 ; 
wave.details.hopNSyms = 10 ;
wave.details.hopGap   = 10 ;
wave.details.hopOvSamp = 4 ;
env{3} = wave ;

wave.mod = 'bpsk' ;
wave.cenFreqBin = round(-.4 * sys.bandwidthBins) ;
wave.bwBins = 100 ;
wave.critSamps = 5000 ;
% wave.details = {} ;
env{4} = wave ;

wave.mod = 'ofdm' ;
wave.cenFreqBin = round(-.2 * sys.bandwidthBins) ;
wave.bwBins = 100 ;
wave.critSamps = 8000 ;
wave.details.nPoint = 128 ;
wave.details.nCyc = 16
env{5} = wave ;

wave.mod = 'ofdm' ;
wave.cenFreqBin = round(-.3 * sys.bandwidthBins) ;
wave.bwBins = 100 ;
wave.critSamps = 8000 ;
wave.details.nPoint = 128 ;
wave.details.nCyc = 16
env{6} = wave ;

wave.mod = 'ranFreqHop' ;
wave.cenFreqBin = round(.0 * sys.bandwidthBins) ;
wave.bwBins = 100 ;
wave.critSamps = 300 ;
wave.details.hopBins  = 20 ; 
wave.details.hopNSyms = 10 ;
wave.details.hopGap   = 20 ;
wave.details.hopOvSamp = 4 ;
env{7} = wave ;

wave.mod = 'ranFreqHop' ;
wave.cenFreqBin = round(.0 * sys.bandwidthBins) ;
wave.bwBins = 100 ;
wave.critSamps = 300 ;
wave.details.hopBins  = 20 ; 
wave.details.hopNSyms = 10 ;
wave.details.hopGap   = 20 ;
wave.details.hopOvSamp = 4 ;
env{8} = wave ;

wave.mod = 'ranFreqHop' ;
wave.cenFreqBin = round(.0 * sys.bandwidthBins) ;
wave.bwBins = 100 ;
wave.critSamps = 300 ;
wave.details.hopBins  = 20 ; 
wave.details.hopNSyms = 10 ;
wave.details.hopGap   = 20 ;
wave.details.hopOvSamp = 4 ;
env{9} = wave ;

wave.mod = 'chirp' ;
wave.cenFreqBin = round(-.15 * sys.bandwidthBins) ;
wave.bwBins = 100 ; % nBbins
wave.critSamps = 10000 ;
wave.details.nCritPulseSamp    = 1000 ; 
wave.details.nPulseToPulseCrit = 4000 ;
wave.details.freqOvSamp = 4 ;
env{10} = wave ;



% -----------------------------------------------------------------------
% build environment
%


for waveIn = 1:length(env)

    wave = env{waveIn} ; 
   
    disp(['waveIn = ' num2str(waveIn) ...
        ', mod = ' wave.mod])
    
    switch wave.mod
        case 'bpsk'
           baseS = bpsk(wave.critSamps,sim.oversamp) ;
           
           PBS{waveIn} = reband(baseS, sys.bandwidthBins, sim.oversamp, wave.bwBins, wave.cenFreqBin, sim.oversamp) ;

        case 'mPsk'
           baseS = mPsk(wave.critSamps, wave.details.nPhase,sim.oversamp) ;

           PBS{waveIn} = reband(baseS, sys.bandwidthBins, sim.oversamp, wave.bwBins, wave.cenFreqBin , sim.oversamp) ;            

        case 'ranFreqHop'
           nHop = floor(wave.critSamps/(wave.details.hopNSyms+wave.details.hopGap)) ;

           baseS = ranFreqHop(nHop, wave.details.hopNSyms, wave.details.hopBins, wave.details.hopGap,sim.oversamp,wave.details.hopOvSamp) ;

           PBS{waveIn} = reband(baseS, sys.bandwidthBins, wave.details.hopOvSamp, wave.bwBins, wave.cenFreqBin , sim.oversamp) ;              

        case 'ofdm'
           baseS = ... 
               ofdmFrame(wave.critSamps, wave.details.nPoint, wave.details.nCyc, sim.oversamp) ;

           PBS{waveIn} = ...
               reband(baseS, sys.bandwidthBins, sim.oversamp, wave.bwBins, wave.cenFreqBin , sim.oversamp) ;
           
        case 'chirp'
            
           nPulses = floor(wave.critSamps/wave.details.nPulseToPulseCrit) ;
            
           baseS = ...
                chirp(wave.bwBins, wave.details.nCritPulseSamp, wave.details.nPulseToPulseCrit, nPulses , wave.details.freqOvSamp) ;

           PBS{waveIn} = ...
               reband(baseS, sys.bandwidthBins, 1, wave.bwBins * sim.oversamp* wave.details.freqOvSamp, wave.cenFreqBin , 1) ;
           
%               reband(baseS, sys.bandwidthBins, wave.bwBins, wave.bwBins, wave.cenFreqBin, sim.oversamp) ;
           % reband(baseS, sysBWbins, conBWbins, targetBWbins, targetIFbin,ovSamp)

        otherwise
       
            disp('Err: Unknown case')
    end
end


% dummy combinations

mxLen = 0 ;
for waveIn = 1:length(PBS)
    mxLen = max(mxLen,length(PBS{waveIn})) ;
end

sTot = zeros(1,mxLen) ;
for waveIn = 1:length(PBS)
    sTot(1,1:length(PBS{waveIn})) ...
        =  sTot(1,1:length(PBS{waveIn})) + PBS{waveIn} ;
end

pspectrum(sTot,10^9,'spectrogram','Leakage',1,'OverlapPercent',90, ...
    'MinThreshold',-20,'FrequencyLimits',[-.5*10^9 .5*10^9]);

disp('done')