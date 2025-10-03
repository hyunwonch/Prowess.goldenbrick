function [stat] = dumpFig(filename,figNum)

if nargin <2
  figNum = gcf ;
end
set(figNum, 'PaperPositionMode', 'auto')
figure(figNum)

set(gcf, 'PaperPositionMode', 'auto');
print('-dtiff', '-r150',  [filename '.tiff'])
print('-depsc', [filename '.eps'])
print('-djpeg', [filename '.jpg'])
print('-dpng', [filename '.png'])
hgsave(figNum,[filename '.fig'])
% exportgraphics(gca, [filename '.pdf']); 
%print('-dpdf', '-fillpage', [filename '.pdf'])
print('-dpdf',  [filename '.pdf'])
%exportgraphics(gcf,[filename '-eg.pdf'])
stat = 1;
