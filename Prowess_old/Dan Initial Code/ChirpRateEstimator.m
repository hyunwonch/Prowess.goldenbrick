%% Create a chirp signal 
clc
clear all

A = 1;
fs = 1e9; % 1GHz sample rate
f0 = 1e6; % initial frequency 
phi = pi/2; % initial phase (rad)
ts = 1/fs; % derived sample period
f1 = -0; % chirp low freq
f2 = 25e6; % chirp high freq, 25MHz chirp
bw = f2-f1; % sweep bandwidth (Hz)
pw = 25e-6; % 25 us pulse width (Seconds)
alpha = bw / pw; % chirp rate (param we are trying to estimate) in Hz/S
n = 0:ts:pw; % sample time indices
T = n*1e6; % time-domain indices in us (for plotting)
nfft = 2^nextpow2(length(n)); % power of 2 fft
F = linspace(-fs/2,fs/2,nfft)/1e6; % approx frequency bins for plotting fft in MHz

SNR = 8; % add some noise for fun, dB
signal = A*exp(1i*(2*pi*((alpha/2)*n.^2 + f0*n) + phi)).'; % complex chirp signal
sigpow = signal*signal';

signal = awgn(signal,SNR);
SIGNAL = fftshift(fft(signal, nfft)); % frequency domain representation

%% Plot the signal
figure(1)
plot(T, real(signal)); hold on; plot(T, imag(signal)); hold off
title('Signal in time'); xlabel('Time (us)'), ylabel('Magnitude'); grid on;
figure(2)
plot(F,10*log(abs(SIGNAL)));
title('Signal in frequency'), xlabel('MHz'), ylabel('dB'); grid on;
figure(3)
pspectrum(signal,'spectrogram');

%% Recover the chirp rate from the signal
% % From the venerable Steven Kay = "Parameter Estimation of Chirp Signals, IEEE 1990)
% 
% % let x_n be denoted by our noisy received signal
% % let y_{n} = (x_{n})(x*_{n-1})
% % let z_{n} = (y_{n})(y*_{n-1})
% % such that z_{n} = (x_{n})(x*_{n-1})(x*_{n-1})(x_{n-2})
% 
% % grab some semi-arbitrary pow2 block of the signal to process
% dataSize = 2^12; 
% x_n = signal(1:dataSize).';
% 
% % create a delayed copy
% x_n1 = delayseq(x_n,1);
% 
% % create another delayed copy
% x_n2 = delayseq(x_n1,1);
% 
% % construct z vector by the above definition
% x_n = x_n(3:end);
% x_n1 = x_n1(3:end);
% x_n2 = x_n2(3:end);
% 
% z = (x_n).*conj(x_n1).*conj(x_n1).*(x_n2);
% 
% % determine the instantaneous phase of z, there are efficient algorithms to
% % do unwrapping on hardware
% % psi = unwrap(angle(z));
% psi = angle(z);
% 
% % this phase is described by the instantaneous phase of z + a phase noise
% % term, psi = 2 * pi * alpha + v_{n}, and here v_{n} can be understood as a
% % moving average window over the phase noise term of the signal. v_{n} is
% % colored noise created by the process of constructing z. Here, v_{n} the
% % colored noise can be defined by its white noise components"
% % v_{n} = w_{n} - 2w_{n1} - w_{n2}. Notice how this follows from how z was
% % constructed. The structure of the covariance matrix of this colored phase
% % noise can be inferred from its definition (see paper)
% 
% % construct C as described
% w = [-1 2 -1]; % structure of phase noise delayed components (above)
% v = conv(w,w); % 
% I = eye(dataSize-2); % temporary
% C = (1/2*A^2)*filter2(v,I); % scalar value from paper
% I = ones(dataSize-2,1); % not temporary, see paper
% 
% % approximate alpha using Gauss-Markov estimate - I must be missing
% % something here, maybe it's just a scaling / units issue. Need to
% % investigate.
% alpha_hat = (1/2*pi)*(I.'*inv(C)*psi.')/(I.'*inv(C)*I); % broken

%% Trying a simpler approach (that is effectively the same as the above)
% multiply the signal with a 1-delayed version of itself, figure out the
% resulting angle, measure that. This only works in higher SNR regimes. I
% was trying to get the above to work, but it is currently buggy.

% delay the signal by 1 sample
signal_n1 = delayseq(signal,1);

% multiply the original signal with its delayed copy
signal_phase_progression = (signal).*(signal_n1);

% take the angle of each entry of the phase progression vector
psi_hat = unwrap(angle(signal.*signal_n1));

% the rate of the phase progression is the second partial derivative of the
% angle of our phase progression vector
alpha_hat_prime = diff(psi_hat);
alpha_hat_prime(1) = 0; 
% if you look at the below, it is the slope of this curve that is the chirp
% rate. the difference from sample to sample represents the phase progression
% over 1 sampling period. the problem is that in any noisy environment, 
% this becomes tough to estimate
plot(alpha_hat_prime)
title('Phase Progression Estimate')
xlabel('Unscaled sample index')
ylabel('Unwrapped phase in radians')

% differentiate again to pull out the chirp rate
alpha_hat = diff(alpha_hat_prime);

%% A simple implementation where we get the benefit of using an FFT

% NOTE: THIS IS THE ONE THAT ACTUALLY WORKS, NEED TO PACKAGE AS A FUNCTION
% IT IS THE SIMPLEST IMPLEMENTATION AND IT MAKES ME SOMEWHAT SAD BUT OH
% WELL. I WILL REVISIT THE TIME DOMAIN ONLY IMPLEMENTATIONS LATER. THEY
% MIGHT NOT EVEN BE MORE EFFICIENT ... but they might be
n100 = 100;
n500 = 500;

signal_n100 = delayseq(signal,n100);
signal_n500 = delayseq(signal,n500);
zz1 = signal.*conj(signal_n100);
zz5 = signal.*conj(signal_n500);

ZZ1 = fftshift(fft(zz1,nfft));
ZZ5 = fftshift(fft(zz5,nfft));

% approx frequency bins for plotting fft in Hz
F = linspace(-fs/2,fs/2,nfft); 

figure(5)
plot(F,abs(ZZ1)); hold on; grid on;
plot(F,abs(ZZ5)); hold off;
title('Chirp multiplied by delayed complex conj');
xlabel('Hz')
ylabel('Magnitude')

% back out the frequency resulting from a delay of 100 samples (in MHz)
[val1,idx1] = max(abs(ZZ1));
[val5, idx5] = max(abs(ZZ5));

fhat1 = F(idx1); % one would expect fhat5 to be ~ 5*fhat1
fhat5 = F(idx5);

t_elapsed1 = ts*n100;
t_elapsed5 = ts*n500;

% Works better with a longer delay, as expected.
alpha_hat1 = fhat1 / t_elapsed1;
alpha_hat5 = fhat5 / t_elapsed5;

disp('True chirp rate MHz:')
disp(alpha/1e6)
disp('Estimated chirp rate MHz:')
disp(alpha_hat5/1e6) 
disp('Error in MHz')
disp((abs(alpha-alpha_hat5)/1e6))
