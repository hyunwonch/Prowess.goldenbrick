function est = chirpRate(sigIn, fs, nDelay)
% Coarse estimation of the chirp rate of an LFM signal
% this is the straightforward approach that requires an FFT and a
% max-search within a vector

%TODO: Assume coherent sum of signals?

sigIn = sigIn(:); % ensure column vector

%sigDel = delayseq(sigIn, nDelay);
sigDel = [zeros(nDelay,1); sigIn(1:end-nDelay)]; % same as above, no toolbox requirement

% specify frequency domain bins
nfft = 2^nextpow2(length(sigIn));
F = linspace(-fs/2,fs/2,nfft); 

% Multiply the chirp with its delayed self to back out the phase
% progression
z = sigIn.*conj(sigDel);

% there is some superfluous computation happening here that needn't occur
% on hardware ... the beauty of matlab
Z = fftshift(fft(z, nfft));
[~, max_idx] = max(abs(Z)); 

% the below line describes how much the phase of the signal has progressed
% over the delay interval. this could all be done on one line, but I am
% being verbose for the sake of understanding

% find the fft frequency corresponding to the resulting tone in z
phase_progression = F(max_idx);

% do some algebra to get the units right
t_elapsed = nDelay * (1/fs);

% rate = distance / time
est.rate_Hz =  phase_progression / t_elapsed;
end

