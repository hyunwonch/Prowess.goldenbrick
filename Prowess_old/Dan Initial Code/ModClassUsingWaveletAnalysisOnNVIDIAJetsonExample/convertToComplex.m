function cinputSig = convertToComplex(inputSig)
% This function is only intended to support wavelet deep learning examples.
% It may change or be removed in a future release.

    inPhaseComp  = inputSig(:,1);
    quadComp = inputSig(:,2); 
    cinputSig= inPhaseComp' + 1i*quadComp'; 
    
end