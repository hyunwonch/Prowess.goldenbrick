function s = SSBAM(nS, ovSamp)
    % m is constellation order
    % nS is the number of critical samples
    % s  : 1 x nS row vector of random modulation
    
    
    sps = 8;                % Samples per symbol
    % spf = 1024;             % Samples per frame
    symbolsPerFrame = nS / sps;
    fs = 200e3;             % Sample rate
    numFramesPerModType = 1;
    numSymbols = (numFramesPerModType / sps);
    modType = categorical(["SSB-AM"]);
    dataSrc = helperModClassGetSource(modType, sps, 2*nS, fs);
    modulator = helperModClassGetModulator(modType, sps, fs);
    % Generate random data
      x = dataSrc();
      
      % Modulate
      baseS = modulator(x); baseS = baseS.';
      % s = baseS;
    
    a0 = sinc(1/ovSamp) ;
    b = [a0 1 a0] ;

    sOv = [baseS ; zeros(ovSamp-1,length(baseS))] ;

    s = filter(b, 1, sOv(:)).' ;
