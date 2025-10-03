function [IA, IP, IF] = instAmpPhaseFreq(x, fs)

%Compute Instantaneous Frequency using the hilbert method

z = hilbert(x);
% xr = real(x);
% x = fft(xr,256,1); % n-point FFT over columns.
% % h  = zeros(n,~isempty(x),'like',x); % nx1 for nonempty. 0x0 for empty.
% if n > 0 && 2*fix(n/2) == n
%   % even and nonempty
%   h([1 n/2+1]) = 1;
%   h(2:n/2) = 2;
% elseif n>0
%   % odd and nonempty
%   h(1) = 1;
%   h(2:(n+1)/2) = 2;
% end
% z = ifft(x.*h(:,ones(1,size(x,2))),[],1);


IA = abs(z);
IP = fs/(2*pi)*unwrap(angle(z));
IF = fs/(2*pi)*diff(unwrap(angle(z)));

end
