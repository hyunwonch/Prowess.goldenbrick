function out = ind2rgb_custom_ecg_jetson_ex(a, cm)
% This function is only intended to support wavelet deep learning examples.
% It may change or be removed in a future release.
   
%%   ORIGNAL implementation
%    if ~isfloat(a)
%        indexedImage = double(a)+1;    % Switch to one based indexing
%    else
%        indexedImage = a;
%    end

%% SIMPLIFIED implementation (valid only if cwt_ecg function calls this function)
%    assert(isfloat(a))
   indexedImage = a;
   
%%
   % Make sure indexedImage is in the range from 1 to number of colormap
   % entries
   numColormapEntries = size(cm,1);
   indexedImage = max( 1, min(indexedImage, numColormapEntries) );


   height = size(indexedImage, 1);
   width = size(indexedImage, 2);
   
   %rgb = zeros(height, width, 3);
   rgb = coder.nullcopy(zeros(height,width,3));
   rgb(1:height, 1:width, 1) = reshape(cm(indexedImage, 1), [height width]);
   rgb(1:height, 1:width, 2) = reshape(cm(indexedImage, 2), [height width]);
   rgb(1:height, 1:width, 3) = reshape(cm(indexedImage, 3), [height width]);
   
   out = rgb;

end