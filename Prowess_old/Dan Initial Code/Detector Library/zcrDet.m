function det = zcrDet(sigIn, approach)

% samp = 50;
det.type      = approach.type ;
[nn, nSamp] = size(sigIn) ;
% fs = approach.detail.Fs;

det.decision = false ;
sigInM = sum(sigIn,1);
window = sigInM.';


% for i=1:(nSamp/samp)
window2 = zeros(size(window));
window2(2:end) = window(1:end-1);
Z = (1/(2*length(window))) * std(abs(sign(window)-sign(window2)));

% sIF(i) = std(IF);
% end
% for i = 1:nSamp
% % IF(i) = fs/(2*pi)*
% IF(i) = (atan(imag(sum(sigIn(:,i)))/real(sum(sigIn(:,i)))));
% end

vals = Z;
det.vals = vals;
% det.IF = sIF;
        
        if vals < approach.detail.thresh
            det.decision = true ;
            
        end
end
