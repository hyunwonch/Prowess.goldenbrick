function J = jet_custom(m)
% This function is only intended to support wavelet deep learning examples.
% It may change or be removed in a future release.
%
%JET    Variant of HSV
%   JET(M) returns an M-by-3 matrix containing the jet colormap, a variant
%   of HSV(M). The colors begin with dark blue, range through shades of
%   blue, cyan, green, yellow and red, and end with dark red. JET, by
%   itself, is the same length as the current figure's colormap. If no
%   figure exists, MATLAB uses the length of the default colormap.
%
%   See also PARULA, HSV, HOT, PINK, FLAG, COLORMAP, RGBPLOT.

%   Copyright 1984-2015 The MathWorks, Inc.

n = ceil(m/4);
u = [(1:1:n)/n ones(1,n-1) (n:-1:1)/n]';
g = ceil(n/2) - (mod(m,4)==1) + (1:length(u))';
r = g + n;
b = g - n;
% g(g>m) = [];
% r(r>m) = [];
% b(b<1) = [];
g = g(g<=m);
r = r(r<=m);
b = b(b>=1);

J = zeros(m,3);
J(r,1) = u(1:length(r));
J(g,2) = u(1:length(g));
J(b,3) = u(end-length(b)+1:end);