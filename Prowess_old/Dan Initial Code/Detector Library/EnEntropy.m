function det = EnEntropy(sigIn, approach)

% samp = 50;
det.type      = approach.type ;
[nn, nSamp] = size(sigIn) ;
numOfShortBlocks = approach.detail.numOfShortBlocks;
% fs = approach.detail.Fs;

det.decision = false ;
sigInM = sum(sigIn,1);
window = sigInM.';

% total frame energy:
Eol = sum(window.^2);
winLength = length(window);
subWinLength = floor(winLength / numOfShortBlocks);

if length(window)~=subWinLength* numOfShortBlocks
    window = window(1:subWinLength* numOfShortBlocks);
end
% get sub-windows:
subWindows = reshape(window, subWinLength, numOfShortBlocks);

% compute normalized sub-frame energies:
s = sum(subWindows.^2) / (Eol);

% compute entropy of the normalized sub-frame energies:
Entropy = -sum(s.*log2(s));


vals = Entropy;
det.vals = vals;
% det.IF = sIF;
        
        if vals < approach.detail.thresh
            det.decision = true ;
            
        end
end
