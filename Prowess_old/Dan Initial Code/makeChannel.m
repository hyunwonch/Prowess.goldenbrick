% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
function chan = makeChannel(power, type, ...
    nAnt, delaySpread, dopplerSpread)

chan.power       = power ;
chan.type        = 'noise' ;
chan.nAnt         = 1 ;
chan.delaySpread = 1 ;
chan.dopplerSpread = 0 ;

switch nargin
    case 2
        chan.type = type ;
    case 3
        chan.type = type ;
        chan.nAnt  = nAnt ;
    case 4
        chan.type = type ;
        chan.nAnt  = nAnt ;
        chan.delaySpread = delaySpread ;
    case 5
        chan.type = type ;
        chan.nAnt  = nAnt ;
        chan.delaySpread = delaySpread ;
        chan.dopplerSpread = dopplerSpread ;
end


rn = (randn(1, chan.delaySpread) ...
    + 1i * randn(1,chan.delaySpread)) ;

firTap = rn .* exp(-(0:(chan.delaySpread-1)) ...
    / (chan.delaySpread/2)) ;

chan.firTap = firTap/norm(firTap) ;

switch chan.type 
    case 'noise'
    otherwise
end


