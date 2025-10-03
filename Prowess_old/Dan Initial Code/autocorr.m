% calculate the autocorrelation function of A, A must be a column vector
% Author: Sheng Liu
% Email: ustc.liu@gmail.com
% Date: 7/16/2015
function x = autocorr(A)
% get the size of A
[row,col] = size(A);
if (row ~= 1 && col ~= 1)
    error('The input should be a vector, not a matrix!');
end

if row == 1
    A = A';
end

N = length(A);
x = zeros(N,1);
x(1) = sum(A.*A);
for ii = 2:N
    B = circshift(A,-(ii-1));
    B = B(1:(N-ii+1));
    x(ii) = sum(B.*A(1:(N-ii+1)));
end
x = x/x(1);