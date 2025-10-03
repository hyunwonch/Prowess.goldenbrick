function helperGenerateCWTfiles2(dataDirectory,modulationTypes,frameLength,fs)
% This function is only intended to support wavelet deep learning examples.
% It may change or be removed in a future release.


fb = cwtfilterbank('SignalLength',frameLength,...
    'SamplingFrequency',fs,...
    'VoicesPerOctave',48);
tic;
disp("Generating scalograms ...")
for modType=1:length(modulationTypes)
    scalogramDir = fullfile(dataDirectory,string(modulationTypes(modType)));
    
    %if ~exist(scalogramDir,'dir') % create directory and populate with images
        
        tmpt = seconds(toc);
        tmpt.Format = 'hh:mm:ss';
        fprintf('%s - Generating %s scalograms\n',...
            tmpt,modulationTypes(modType))
        
        [success,msg,msgID] = mkdir(scalogramDir);
        if ~success
            error(msgID,msg)
        end
        
        %files = dir(fullfile(dataDirectory,"frame" + string(modulationTypes(modType)) + "*"));
        files = dir(fullfile(dataDirectory,string(modulationTypes(modType)),"*" + string(modulationTypes(modType)) + "*" + ".mat"));
        % generate scalograms and save as RGB images
        for k=1:numel(files)
            load(fullfile(files(k).folder, files(k).name), 'frame');
            cfs = fb.wt(frame);
            mstrCoeff = abs([cfs(:,:,1); cfs(:,:,2)]);
            im = ind2rgb(im2uint8(rescale(mstrCoeff)),jet(128));
            
            % strip '.mat' from filename
            fName = files(k).name(1:end-4);
            
            fileName = fullfile(scalogramDir,sprintf('%s.jpg',fName));
            imwrite(imresize(im,[227 227]),fileName);
            
        end
    %end
    
end