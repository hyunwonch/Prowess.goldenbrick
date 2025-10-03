function det = CPDetect3(sigIn, approach)

det.type      = approach.type ;
[nn, nSamp] = size(sigIn) ;
lag = approach.detail.lag;
cyc = approach.detail.cycSamps;

% default
det.decision = false ;
% z = sigIn;
nCorr    = floor(nSamp/cyc) ;
% z1 = [zeros(nn,lag) sigIn(:,1:end)];
nCorIn = [];
% for CorIn = 1:(nCorr-1)
    % z1 = [];
    % z = sigIn(:,(1:cyc)) ;
    % % for lag = 1:10
    % z1 = [zeros(nn,lag) z(:,1:end)];
    % z1 = sum(z,1); z1 = z1.';
    z = sum(sigIn,1);
    % z = z.';
    % lag = [16; 32; 64; 128];
    lag = [1:32];
    for i=1:length(lag)
        % zcyc = z(1:lag(i));
    zlag = delayseq(z, lag);

        CAF = xcorr(zcyc,z);
        CAFMain(i,:) = abs(CAF)/(nn*nSamp);
    end
    % CAFMain = mean(CAFMain,1);
    % Corr = fft(z).*conj(fft(zlag));
    % CAF = abs(fftshift(Corr)).^2;
    % CAF = CAF/(nn*nSamp);
    % [Corr lags] = xcorr(z1,z2);




    % Corr = xcorr(fft(z1), fft(z2));
    % Corr = autocorr_circular(sum(z,1));
    % AA = abs(Corr)/nn/cyc;
    % AA = abs(Corr);
    % AA = abs(fftshift(fft(Corr)))/nn/nSamp;
    % nCorIn = AA;
% end
    if max(max(CAFMain))> approach.detail.thresh
    % [pk pval] = findpeaks(nCorIn,'MinPeakHeight',approach.detail.thresh);
    %
    % if length(pk)>=1
        det.decision = true ;
    end
    % det.decision = (det.decision | thisDet(CorIn)) ;
    % det.Corrvals = nCorIn;
    det.CPCorr = CAFMain;
    % det.lags = lags;
    det.CPCAF = max(max(CAFMain));

end