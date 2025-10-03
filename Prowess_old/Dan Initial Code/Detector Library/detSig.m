% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
function det = detSig(sigIn, approach)

det.type      = approach.type ;
[nAnt, nSamp] = size(sigIn) ;

% default
det.decision = false ;

switch approach.type

    % -------------------------------------
    case 'energy'

        vals = sum(sum(sigIn .* conj(sigIn))) / nAnt /nSamp ;
        
        if vals > approach.detail.thresh
            det.decision = true ;
            det.vals = vals ;
        end

    % -------------------------------------
    case 'bartlett'

        nCopy = floor(length(sigIn)/approach.nBin) ;

        sigMat = reshape(sigIn(1:(nSamp*approach.nBin)), ...
            approach.nBin,nCopy) ;

        sigFft = fft(sigMat)  ;

        sigEnergy = sigFft .* conj(sigFft) / approach.nBin ;

        psd = fftshift(sum(sigEnergy,2).')/nCopy ;

        binDet = psd > approach.detail.threshold ;

        if sum(binDet)> 0
            det.decision = true ;
            det.vals = psd ;
        end

    % -------------------------------------
    case 'kurtosis'
        % look for constant modulus 

        exKurR       = kurtosis(real(sigIn(:))) - 3 ;
        exKurI       = kurtosis(imag(sigIn(:))) - 3 ;
        exKur        = (exKurR+exKurI)/2 ;

        det.decision = (exKur < approach.detail.thresh) ;
        det.exKur    = exKur ;

    % -------------------------------------
    case 'aep'
        % look for constant modulus 

        nCovSamp = approach.detail.nCovSamps ;
        nCov     = floor(nSamp/nCovSamp) ;

        z = sigIn(:,1:nCovSamp) ;
        oldCov = z * z' ;

        for covIn = 1:(nCov-1)
            z = sigIn(:,((1:nCovSamp)+covIn*nCovSamp)) ;
            cov = z*z';
%             [eVec,eVal] = eigs(oldCov-cov,1) ;
            [eVec,eVal] = eigs(inv(oldCov)*cov,1) ;
            maxEig = real(eVal) ;

            thisEig(covIn)      = maxEig ;
            thisEigVec(:,covIn) = eVec ;
            thisDet(covIn)      = (maxEig > approach.detail.thresh) ;
            
            det.decision   = (det.decision | thisDet(covIn)) ;
        end
        det.detail.aepList    = thisEig ;
        det.detail.aepDetList = thisDet ;
        det.detail.aepEigVec  = thisEigVec ;
        %thisEig

    case ''



    % -------------------------------------
    otherwise
        disp(['detSig.m: no matching detector for ' approach.type])

end

