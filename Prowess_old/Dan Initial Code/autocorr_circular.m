% calculate the autocorrelation function of A, A must be a column vector
% Author: Sheng Liu
% Email: ustc.liu@gmail.com
% Date: 7/16/2015
function x = autocorr_circular(A)
% get the size of A
[row,col] = size(A);
if (row ~= 1 && col ~= 1)
    error('The input should be a vector, not a matrix!');
end

if row == 1
    A = A';
end
N = length(A);
% allocate the memory to store currelation function
x = zeros(N,1);
% x(1) = sum(A.*A);
% xx = sum(A.*A);
for ii = 1:N
    x(ii) = sum(circshift(A,-(ii-1)).*A);
end
% normalize the correlation function
% x = x/xx;