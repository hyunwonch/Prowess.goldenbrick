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

wave.mod = 'ofdm' ;
wave.label = 'ofdm-40MHz-256+16-long-fixed100MHz' ;
wave.bwBins = 80 ;
wave.critSamps = 4000 ;
wave.details.nPoint = 256 ;
wave.details.nCyc = 16 ;
wave.fracFreqRangeCen = .1 ;
wave.fracFreqRangeBins = 0 ;
env = {env{:}, wave} ;
wave = [];

wave.mod = 'ofdm' ;
wave.label = 'ofdm-40MHz-256+16-long' ;
wave.bwBins = 40 ;
wave.critSamps = 4000 ;
wave.details.nPoint = 256 ;
wave.details.nCyc = 16 ;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
env = {env{:}, wave} ;
wave = [];

wave.mod = 'ofdm' ;
wave.label = 'ofdm-40MHz-128+16-short' ;
wave.bwBins = 40 ;
wave.critSamps = 1000 ;
wave.details.nPoint = 128 ;
wave.details.nCyc = 16 ;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
env = {env{:}, wave} ;
wave = [];

wave.mod = 'ofdm' ;
wave.label = 'ofdm-20MHz-256+32-long' ;
wave.bwBins = 20 ;
wave.critSamps = 1000 ;
wave.details.nPoint = 128 ;
wave.details.nCyc = 16 ;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
env = {env{:}, wave} ;
wave = [];

wave.mod = 'bpsk' ;
wave.label = 'bpsk-10MHz-short' ;
%wave.cenFreqBin = round(.1 * sys.bandwidthBins/sim.oversamp) ;
wave.bwBins = 10 ;
wave.critSamps = 100 ;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
% wave.details = {} ;
env = {env{:}, wave} ;
wave = [];

wave.mod = 'bpsk' ;
wave.label = 'bpsk-1MHz-short' ;
wave.bwBins = 1 ;
wave.critSamps = 25 ;
% wave.details = {} ;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
env = {env{:}, wave} ;
wave = [];

wave.mod = 'mPsk' ;
wave.label = '5MHz-8psk' ;
wave.bwBins = 5 ;
wave.critSamps = 100 ;
wave.details.nPhase = 8 ;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
env = {env{:}, wave} ;
wave = [];

% 16Qam
% ----------------------------------
wave.mod = 'qam' ;
wave.label = '16qam-5MHz' ;
wave.bwBins = 5 ; % nBbins
wave.critSamps = 1000 ;
wave.details.modOrder = 16;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
env = {env{:}, wave} ;
wave = [];
% 64Qam
% ----------------------------------
wave.mod = 'qam' ;
wave.label = '64qam-20MHz' ;
wave.bwBins = 20 ; % nBbins
wave.critSamps = 2000 ;
wave.details.modOrder = 64;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
env = {env{:}, wave} ;
wave = [];

wave.mod = 'GFsk' ;
wave.label = 'GFsk-5MHz' ;
wave.bwBins = 10 ;
wave.critSamps = 500 ;
% wave.details.nFreq = 8 ;
% wave.details = {} ;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
env = {env{:}, wave} ;
wave = [];

wave.mod = 'CPFsk' ;
wave.label = 'CPFsk-6MHz' ;
wave.bwBins = 6 ;
wave.critSamps = 600 ;
% wave.details.nAmp = 4 ;
% wave.details = {} ;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
env = {env{:}, wave} ;
wave = [];

wave.mod = 'ranFreqHop-qam' ;
wave.label = 'hop-2MHz-16sym-nqam' ;
wave.bwBins = 100 ;
wave.critSamps = 300 ;
wave.details.hopBins  = 50 ; 
wave.details.hopNSyms = 16 ;
wave.details.hopGap   = 20 ;
wave.details.hopOvSamp = 4 ;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
env = {env{:}, wave} ;
wave = [];

wave.mod = 'ranFreqHop-qpsk' ;
wave.label = 'hop-8MHz-32sym-qpsk' ;
wave.bwBins = 200 ;
wave.critSamps = 300 ;
wave.details.hopBins  = 25 ; 
wave.details.hopNSyms = 32 ;
wave.details.hopGap   = 10 ;
wave.details.hopOvSamp = 4 ;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
env = {env{:}, wave} ;
wave = [];

wave.mod = 'chirp' ;
wave.label = 'chirp-200MHz' ;
wave.bwBins = 200 ; % nBbins
wave.critSamps = 100000 ;
wave.details.nCritPulseSamp    = 10000 ; 
wave.details.nPulseToPulseCrit = 40000 ;
wave.details.freqOvSamp = 4 ;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
wave.details.chirpSign = 0 ; % for random (-1, 0, 1)
env = {env{:}, wave} ;
wave = [];

wave.mod = 'chirp' ;
wave.label = 'chirp-40MHz' ;
wave.bwBins = 40 ; % nBbins
wave.critSamps = 10000 ;
wave.details.nCritPulseSamp    = 1000 ; 
wave.details.nPulseToPulseCrit = 4000 ;
wave.details.freqOvSamp = 4 ;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
wave.details.chirpSign = 0 ; % for random (-1, 0, 1)
env = {env{:}, wave} ;
wave = [];

wave.mod = 'FM' ;
wave.label = 'FM-1MHz' ;
wave.bwBins = 1 ;
wave.critSamps = 100 ;
% wave.details.nFreq = 8 ;
% wave.details = {} ;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
env = {env{:}, wave} ;
wave = [];

wave.mod = 'AM' ;
wave.label = 'DSBAM-1MHz' ;
wave.bwBins = 2 ;
wave.critSamps = 100 ;
% wave.details.nFreq = 8 ;
% wave.details = {} ;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
env = {env{:}, wave} ;
wave = [];

wave.mod = 'SSB' ;
wave.label = 'SSBAM-1MHz' ;
wave.bwBins = 2 ;
wave.critSamps = 100 ;
% wave.details.nFreq = 8 ;
% wave.details = {} ;
wave.fracFreqRangeCen = i ;
wave.fracFreqRangeBins = i ;
env = {env{:}, wave} ;
wave = [];
