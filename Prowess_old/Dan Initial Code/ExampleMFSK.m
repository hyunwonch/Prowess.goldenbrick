clc;
clear all

mfsk = {'10', '01', '01', '01', '10', '10', '01', '11'};
nfsk = length(mfsk); % length of mfsk string

fc = 100*10^6;
fd = 500;
M = 4;

%Equation 7.3 used to create 4 M=4 signals
%fi(1) = '00', %fi(2) = '01', %fi(3) = '10', %fi(4) = '11'
fi = fc + ((2 * (1:M) ) - 1 - M) * fd;

tbit = 5e-3; % time per fsk bit [seconds]
nbit = tbit*fc*5; % # data points in one fsk bit, including Nyquist factor

tSample = linspace(0,nfsk*tbit, 1+nfsk*nbit);
% find frequency fi for every time points
freqSample = 0*tSample;
for nn = 1:nfsk
    nCurrentBit = (1+(nn-1)*nbit) : (nn*nbit);
    switch char(mfsk(nn))
        case '00'
            fCurrentBit = fi(1);
        case '01'
            fCurrentBit = fi(2);
        case '10'
            fCurrentBit = fi(3);
        case '11'
            fCurrentBit = fi(4);
        otherwise % wrong mfsk code
            fCurrentBit = 0;
    end
    freqSample(nCurrentBit) = fCurrentBit;
end
freqSample(end) = freqSample(end-1);

% evaluate carrier signal on each time point
A = 1; % amplitude
mfskSample = cos(2*pi * freqSample .* tSample);
plot(tSample, mfskSample)