function s = ofdmFrame(nSym,nPoint,nCyc,ovSamp)

nOfdmSym = floor(nSym/nPoint) ;

s = zeros(1,nOfdmSym*(nPoint+nCyc)*ovSamp) ;

for symIn = 1:nOfdmSym
    range = (symIn-1)*(nPoint+nCyc)*ovSamp +(1: (ovSamp*(nPoint+nCyc))) ;
    sym = nQam(nPoint,16,1) ;
    s(1,range) = ofdm(sym,nCyc,ovSamp) ;
end
