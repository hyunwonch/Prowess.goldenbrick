function passbandSig = reband(baseS, sysBWbins, targetBWbins, targetIFbin,ovSamp)

% baseband signal, 
% numb of system BW bins, 
% numb of construct BW, 
% numb of target BW
% target IF bin

%if ovSamp > 1
    %baseS = lowpass(baseS,1/ovSamp) ;
%end

p = sysBWbins ;
q = targetBWbins*ovSamp ;

%q = conBWbins*targetBWbins ;

passbandUn = resample(baseS,p,q,0) ;

   
    
passbandSig = ...
    exp(1i*2*pi*(1:length(passbandUn))*targetIFbin/sysBWbins) ...
    .* passbandUn ;

% plot(abs(passbandSig));
