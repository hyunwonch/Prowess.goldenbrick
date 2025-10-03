
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% build environment
function [PBS] = envSetup(sim,sys,env)


% simplify
nThrow = sim.nThrow ;

% -----------------------------------------------------------------------
% for each waveform
for throwIn = 1:nThrow

    % % select waveform type
    % waveIn = randi(length(env)) ;
    % wave   = env{waveIn} ;
    wave = env{throwIn};
    %
    % PBS{throwIn}.wave = wave ;

    % set boundaries for frequency range "i" is for entire range
    % if imag(wave.fracFreqRangeCen)>0
        % cenFreqBin = ...
        %     round((rand()-1/2) * sys.bandwidthBins /sim.oversamp) ;
        cenFreqBin = ...
            round((rand()) * sys.bandwidthBins /sim.oversamp) ;
    % else
    %     % cenFreqBin = ...
    %     %     round(((rand()-1/2) * wave.fracFreqRangeBins + wave.fracFreqRangeCen) * sys.bandwidthBins /sim.oversamp) ;
    %     cenFreqBin = ...
    %         round(((rand()) * wave.fracFreqRangeBins + wave.fracFreqRangeCen) * sys.bandwidthBins /sim.oversamp) ;
    % end

    %%
    % population = 1:length(env);
    % sample_size = 1;
    % if cenFreqBin>0 && cenFreqBin<=3
    %     prob = sim.band1;
    %     waveIn = randsample(population,sample_size,'true',prob);
    %     wave   = env{waveIn} ;
    % 
    % elseif cenFreqBin>3 && cenFreqBin<=30
    %     prob = sim.band2;
    %     waveIn = randsample(population,sample_size,'true',prob);
    %     wave   = env{waveIn} ;
    % 
    % elseif cenFreqBin>30 && cenFreqBin<=300
    %     prob = sim.band3;
    %     waveIn = randsample(population,sample_size,'true',prob);
    %     wave   = env{waveIn} ;
    % 
    % elseif cenFreqBin>300 && cenFreqBin<=1000
    %     prob = sim.band4;
    %     waveIn = randsample(population,sample_size,'true',prob);
    %     wave   = env{waveIn} ;
    % end
    % 
    PBS{throwIn}.wave = wave ;

    % PBS{throwIn}.cenFreqBin = cenFreqBin ;
    PBS{throwIn}.cenFreqBin = 107 ;
    cenFreqBin = 107;

    % randomly set start point of waveform
    PBS{throwIn}.timeOffBin ...
        = floor(rand()* sim.maxStartDelay) ;

    % setup array response (narrowband model)
    switch sim.arrayModel
        case 'gaussian'
            v = (randi(sys.nAnt,1) + 1i*randn(sys.nAnt,1))/sqrt(2) ;
        case 'ranPhase'
            v = exp(1i*2*pi*rand(sys.nAnt,1)) ;
    end
    PBS{throwIn}.v = v ;

    % ---------------------------------------------------------
    % evaluate details of waveform type

    switch wave.mod

        % -------------------------------------
        case 'bpsk'
            baseSRaw = bpsk(wave.critSamps, ...
                sim.oversamp) ;

            % need to add channel here
            baseS = baseSRaw;


            PBS{throwIn}.sig = v * reband(baseS, ...
                sys.bandwidthBins, ...
                wave.bwBins, ...
                cenFreqBin, ...
                sim.oversamp) ;

            % -------------------------------------
        case 'mPsk'
            baseSRaw = mPsk(wave.critSamps, ...
                wave.details.nPhase, ...
                sim.oversamp) ;

            % need to add channel here
            baseS = baseSRaw;

            PBS{throwIn}.sig = v * reband(baseS, ...
                sys.bandwidthBins, ...
                wave.bwBins, ...
                cenFreqBin, ...
                sim.oversamp) ;

            % -------------------------------------
        case 'GFsk'
            baseSRaw = GFsk(wave.critSamps, ...
                sim.oversamp) ;

            % need to add channel here
            baseS = baseSRaw;

            PBS{throwIn}.sig = v * reband(baseS, ...
                sys.bandwidthBins, ...
                wave.bwBins, ...
                cenFreqBin, ...
                sim.oversamp) ;

            % -------------------------------------
        case 'CPFsk'
            baseSRaw = CPFsk(wave.critSamps, ...
                sim.oversamp) ;

            % need to add channel here
            baseS = baseSRaw;

            PBS{throwIn}.sig = v * reband(baseS, ...
                sys.bandwidthBins, ...
                wave.bwBins, ...
                cenFreqBin, ...
                sim.oversamp) ;
            
            % -------------------------------------
        
        case 'FM'
            baseSRaw = BFM(wave.critSamps, ...
                sim.oversamp) ;

            % need to add channel here
            baseS = baseSRaw;

            PBS{throwIn}.sig = v * reband(baseS, ...
                sys.bandwidthBins, ...
                wave.bwBins, ...
                cenFreqBin, ...
                sim.oversamp) ;
 
            % -------------------------------------
        
        case 'AM'
            baseSRaw = DSBAM(wave.critSamps, ...
                sim.oversamp) ;

            % need to add channel here
            baseS = baseSRaw;

            PBS{throwIn}.sig = v * reband(baseS, ...
                sys.bandwidthBins, ...
                wave.bwBins, ...
                cenFreqBin, ...
                sim.oversamp) ;

        % -------------------------------------
        
        case 'SSB'
            baseSRaw = SSBAM(wave.critSamps, ...
                sim.oversamp) ;

            % need to add channel here
            baseS = baseSRaw;

            PBS{throwIn}.sig = v * reband(baseS, ...
                sys.bandwidthBins, ...
                wave.bwBins, ...
                cenFreqBin, ...
                sim.oversamp) ;

            % -------------------------------------
        case 'ranFreqHop-qpsk'
            nHop = floor(wave.critSamps ...
                /(wave.details.hopNSyms+wave.details.hopGap)) ;

            baseSRaw = ranFreqHopQPSK(nHop, ...
                wave.details.hopNSyms, ...
                wave.details.hopBins, ...
                wave.details.hopGap, ...
                sim.oversamp, ...
                wave.details.hopOvSamp) ;

            % need to add channel here
            baseS = baseSRaw;

            PBS{throwIn}.sig = v * reband(baseS, ...
                sys.bandwidthBins, ...
                wave.bwBins, ...
                cenFreqBin, ...
                sim.oversamp*wave.details. ...
                hopOvSamp) ;

            % -------------------------------------
        case 'ranFreqHop-qam'
            nHop = floor(wave.critSamps ...
                /(wave.details.hopNSyms+wave.details.hopGap)) ;

            baseSRaw = ranFreqHop(nHop, ...
                wave.details.hopNSyms, ...
                wave.details.hopBins, ...
                wave.details.hopGap, ...
                sim.oversamp, ...
                wave.details.hopOvSamp) ;

            % need to add channel here
            baseS = baseSRaw;

            PBS{throwIn}.sig = v * reband(baseS, ...
                sys.bandwidthBins, ...
                wave.bwBins, ...
                cenFreqBin, ...
                sim.oversamp*wave.details. ...
                hopOvSamp) ;
            % -------------------------------------
        case 'ofdm'
            baseSRaw = ...
                ofdmFrame(wave.critSamps, ...
                wave.details.nPoint, ...
                wave.details.nCyc, ...
                sim.oversamp) ;

            % need to add channel here
            baseS = baseSRaw;

            PBS{throwIn}.sig = ...
                v * reband(baseS, ...
                sys.bandwidthBins, ...
                wave.bwBins, ...
                cenFreqBin, ...
                sim.oversamp) ;

            % -------------------------------------
        case 'chirp'

            nPulses = floor(wave.critSamps...
                /wave.details.nPulseToPulseCrit) ;

            baseSRaw = ...
                chirp( ...
                wave.details.nCritPulseSamp, ...
                wave.details.nPulseToPulseCrit, ...
                nPulses, ...
                wave.details.freqOvSamp) ;

            switch wave.details.chirpSign
                case 0
                    if randi(2)>1
                        baseSRaw = conj(baseSRaw) ;
                    end
                case -1
                    baseSRaw = conj(baseSRaw) ;
            end

            % need to add channel here
            baseS = baseSRaw;

            PBS{throwIn}.sig = ...
                v * reband(baseS, ...
                sys.bandwidthBins, ...
                wave.bwBins* wave.details.freqOvSamp, ...
                cenFreqBin, ...
                1) ;

        case 'qam'
            baseSRaw = nQam(wave.critSamps, ...
                wave.details.modOrder, ...
                sim.oversamp) ;

            % need to add channel here
            baseS = baseSRaw;

            PBS{throwIn}.sig = v * reband(baseS, ...
                sys.bandwidthBins, ...
                wave.bwBins, ...
                cenFreqBin, ...
                sim.oversamp) ;

        otherwise

            disp(['EnvSetup.m: Unknown case ' wave.mod])
    end
end

