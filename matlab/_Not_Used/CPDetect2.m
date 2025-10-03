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
    z = z.';
    % z = z.';


    P2 = fft(z);
    P_fft1 = fftshift(P2,1);
    P_parallel1 = P_fft1';
    P_tensor = zeros(nSamp,nSamp);

    P1 = P_fft1*P_parallel1;
    P_abs = abs(P1);
    CAF = P_abs;



% for k=1:1000
%     P2=fft(P_paralel(:,k));
%     P_fft(:,k)=P2;
% end
% %% calculate autocorrelation function
% P_fft1=fftshift(P_fft,1);
% P_paralel1=P_fft1';
% P_tensor=zeros(100,100,1000);
% for i=1:1000
%     P1=P_fft1(:,i)*P_paralel1(i,:);
%     P_tensor(:,:,i)=P1;
% end
% P_abs=abs(P_tensor);
% P_mean=mean(P_abs,3);
% figure(1)
% surf(P_mean)
%



    % Corr = xcorr(fft(z1), fft(z2));
    % Corr = autocorr_circular(sum(z,1));
    % AA = abs(Corr)/nn/cyc;
    % AA = abs(Corr);
    % AA = abs(fftshift(fft(Corr)))/nn/nSamp;
    % nCorIn = AA;
% end
        if max(max(CAF))> approach.detail.thresh
    % [pk pval] = findpeaks(nCorIn,'MinPeakHeight',approach.detail.thresh);
    %
    % if length(pk)>=1
        det.decision = true ;
    end
    % det.decision = (det.decision | thisDet(CorIn)) ;
    % det.Corrvals = nCorIn;
    det.CPCorr = CAF;
    % det.lags = lags;
    det.CPCAF = max(max(CAF));

end