function im = generateImagefromCWTCoeff(cfs, imgSize)
% This function is only intended to support wavelet deep learning examples.
% It may change or be removed in a future release.

im = ind2rgb_custom_ecg_jetson_ex(round(255*rescale(cfs))+1, jet_custom(128));

im = im2uint8(imresize(im, imgSize)); % resize and convert to uint8 

end
   
