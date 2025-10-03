% calculate the autocorrelation function using FFT.
% R(x) = ifft(fft(A).*conj(fft(A)))
% Author: Sheng Liu
% Email: ustc.liu@gmail.com
% Date: 7/16/2015
function x = autocorr_fft(A)
[row,col] = size(A);
if (row ~= 1 && col ~= 1)
    error('The input should be a vector, not a matrix!');
end
y = fft(A);
x = ifft(y.*conj(y));
x = x / max(x);