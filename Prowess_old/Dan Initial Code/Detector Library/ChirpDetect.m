function det = ChirpDetect(sigIn, approach)

det.type      = approach.type ;
[nn, nSamp] = size(sigIn) ;
lag = approach.detail.lag;
fs = approach.detail.fs;
ts = 1/fs;
nfft = 256;

% default
det.decision = false ;
det.vals = NaN;
z = sum(sigIn,1); z = z.';
z1 = delayseq(z,lag);
% z1 = [zeros(nn,lag) sigIn(:,1:end)];
% [Corr lags] = xcorr(sum(z.',2),sum(z1.',2));
Corr = z.*conj(z1);
AA = abs(fftshift(fft(Corr,nfft)))/nn/nSamp;
det.Corr = AA;
pval = max(AA);
F = linspace(-fs/2,fs/2,nfft);
det.ChirpRate = 0;
det.vals = pval;

if max(AA)> approach.detail.thresh
    det.decision = true ;
    det.vals = pval ;
    [val1,idx1] = max(AA);
    fhat1 = F(idx1);
    t_elapsed1 = ts*lag;
    alpha_hat1 = fhat1 / t_elapsed1;
    det.ChirpRate = alpha_hat1/1e6;
end

% [pk ind] = findpeaks(AA,'MinPeakHeight',approach.detail.thresh);
% pval = var(ind);
%
%         if length(pk)>=3 && pval<400
%             det.decision = true ;
%             det.vals = pval ;
%         end
end