clc;
clear all


load('ExampleWidebandSignal.mat')
x = [sTot(1,:),zeros(1,4)]; % input signal


figure(1)
title("Spectrogram of Input Wideband Signal")
pspectrum(x, 10^9*2,'spectrogram',...
    'Leakage',1,'OverlapPercent',90, ...
    'MinThreshold',-20,'FrequencyLimits',...
    ([-.5*10^9 .5*10^9])); % input spectrogram


N   = 239;        % FIR filter order
Fp  = 1e8;       % 20 kHz passband-edge frequency
Fs  = 2e9;       % 96 kHz sampling frequency
Rp  = 0.00057565; % Corresponds to 0.01 dB peak-to-peak ripple
Rst = 1e-4;       % Corresponds to 80 dB stopband attenuation

h = firceqrip(N,Fp/(Fs/2),[Rp Rst],'passedge'); % eqnum = vec of coeffs
hp = zeros(10,24);   % polyphase partition
y_temp = zeros(10, length(x)/10);
for i = 1:10
    hp(i,:) = h(i:10:end);
    opt_temp = x(i:10:end);
    % for j = 1:(length(x)/10)
    %         if j-k+1>0
    %             y_temp(i,j)=y_temp(i,j)+hp(i,k)*opt_temp(j-k+1);
    %         end
    %     end
    % end
    y_temp(i,:) = filter(hp(i,:),1,opt_temp);

end
y = fftshift(fft(y_temp),1); % output narrowband signal 

title("Spectrogram Of Output Narrowband Signals")
figure(2)
for i = 1:10
    subplot(2,5,i)
    pspectrum(y(i,:), 10^8*2,'spectrogram','Leakage',1,'OverlapPercent',90, 'MinThreshold',-20,'FrequencyLimits',([-.5*10^8 .5*10^8]*2));
    % output spectrograms
end


%%

FreqSh = -0.25:0.05:0.25; FreqSh(6)=[];
figure(3);
for i=1:10
fracBW = .1;
nUp = 1;
downSamp = 2/fracBW ;
fracFreqShift = FreqSh(i);

subSig = extractSubband(sTot, fracFreqShift, nUp, downSamp);
% subSig = extractSubband(sTot, 1/downSamp, 1, downSamp) ;

subplot(2,5,i)
plotParams2
pspectrum(subSig(1,:), 10^9*fracBW,'spectrogram',...
    'Leakage',1,'OverlapPercent',90, ...
    'MinThreshold',-20,'FrequencyLimits',...
    ([-.5*10^9 .5*10^9]*fracBW));
end

