clc;clear all
load('ExampleWidebandSignal.mat')

oversamp = 2;

figure(1)
plotParams2
pspectrum(sTot(1,:), oversamp*10^9,'spectrogram',...
    'Leakage',1,'OverlapPercent',90, ...
    'MinThreshold',-20,'FrequencyLimits',[-.5*10^9 .5*10^9]);


%%

oversamp = 2;
fracBW = 0.1;
nUp = 1;
nDown = oversamp/fracBW ;
% FracShift = [-0.15 -0.1 -0.05 0 0.05 0.1 0.15];
FracShift = -0.25:0.05:0.25;

[nAnt, nSamp] = size(sTot) ;

for i=1:length(FracShift)
fracFreqShift = FracShift(i);
sigDC = (ones(nAnt,1) * exp(-1i*2*pi*fracFreqShift*(1:nSamp))) .* sTot ;
sig = resample(sigDC.', nUp, nDown).' ;

% figure
% plotParams2
% pspectrum(sig(1,:), 10^9*fracBW,'spectrogram',...
%     'Leakage',1,'OverlapPercent',90, ...
%     'MinThreshold',-20,'FrequencyLimits',...
%     ([-.5*10^9 .5*10^9]*fracBW));


end

fdm_data = sTot(1,:); fdm_data = fdm_data.';
channelizer = dsp.Channelizer(10);

y = channelizer(fdm_data);
for i=1:10
    figure
    plotParams2
    pspectrum(y(:,i), 10^9*fracBW,'spectrogram',...
        'Leakage',1,'OverlapPercent',90, ...
        'MinThreshold',-20)
end


