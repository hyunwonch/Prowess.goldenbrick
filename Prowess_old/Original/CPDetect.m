function det = CPDetect(sigIn, approach)

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
    lag = [16];
    for i=1:length(lag)
        zlag = [zeros(1,lag(i)) z];
    % zlag = delayseq(z, lag);
        CAF = fftshift(ifft(fft(z,256).*conj(fft(zlag,256))));
        CAFMain(i,:) = abs(CAF)/(nn*nSamp);
    end
    CAFMain = mean(CAFMain,1);
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
    [pk ind] = max(CAFMain);
    [p in] = findpeaks(CAFMain(ind+1:ind+30));
    p = sort(p,'descend');
    if isempty(p)
    pval = 0;
    else
    pval = (pk - p(1))/pk;
    end
    % val2 = pk/mode(CAFMain);
    val2 = pk/mean(CAFMain);

    % if (max(CAFMain))> approach.detail.thresh1 && val2> approach.detail.thresh2
    if pval> approach.detail.thresh1 && val2 >approach.detail.thresh2
        
    % [pk pval] = findpeaks(nCorIn,'MinPeakHeight',approach.detail.thresh);
    % 
    % if length(pk)>=1
        det.decision = true ;
    end 
    % det.decision = (det.decision | thisDet(CorIn)) ;
    % det.Corrvals = nCorIn;
    det.CPCorr = CAFMain;
    % det.lags = lags;
    det.CPCAF = max(CAFMain);
    det.CPPk = pval;
    % det.CPval2 = pk/mean(CAFMain);
    det.CPval2 = val2; 
    

end