function helperPlotScalogramsMod2(dataDirectory,modulationTypes,frameLength,fs)
% This function is only intended to support wavelet deep learning examples.
% It may change or be removed in a future release.

fb = cwtfilterbank('SignalLength',frameLength,...
    'SamplingFrequency',fs,...
    'VoicesPerOctave',48);

numRows = ceil(length(modulationTypes) / 4);
for modType=1:length(modulationTypes)
  
  %files = dir(fullfile(dataDirectory,"*" + string(modulationTypes(modType)) + "*"));
  files = dir(fullfile(dataDirectory,string(modulationTypes(modType)),"*" + string(modulationTypes(modType)) + "*" + ".mat"));
  idx = 10;
  load(fullfile(files(idx).folder, files(idx).name), 'frame');

  [cfs,frq] = fb.wt(frame);
  t = (0:size(cfs,2)-1)/fs;
  
  
  scalogram = abs([cfs(:,:,1); cfs(:,:,2)]);
  subplot(numRows,4,modType)
  imagesc(scalogram)
  set(gca,'xtick',[])
  set(gca,'ytick',[])
  title(string(modulationTypes(modType)))
  
  
  
  
end
%h = gcf; delete(findall(h.Children, 'Type', 'ColorBar'))
end



    