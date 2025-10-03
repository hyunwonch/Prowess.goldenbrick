function drawDiGraph(MAIN,Label,str)

G = digraph(MAIN);
if size(G.Edges, 1)>0
    LWidths = 5*abs(G.Edges.Weight)/max(abs(G.Edges.Weight));
    LWidths(isnan(LWidths))= 0.1;
    p = plot(G,'Layout','circle','NodeLabel',Label,'LineWidth',LWidths);
%     highlight(p,[A+1:A+AA],'NodeColor','r');
    p.MarkerSize = 20;
    nl = p.NodeLabel;
    p.NodeLabel = '';
    xd = get(p,'XData');
    yd = get(p,'YData');
    title(['\fontsize{20}' str]); set(gca,'XTickLabel',[], 'YTickLabel',[])
else
    p = plot(G,'Layout','circle','NodeLabel',Label);
%     highlight(p,[A+1:A+AA],'NodeColor','r');
    p.MarkerSize = 20;
    nl = p.NodeLabel;
    p.NodeLabel = '';
    xd = get(p,'XData');
    yd = get(p,'YData');
    title(['\fontsize{16}' str]); set(gca,'XTickLabel',[], 'YTickLabel',[])
end
text(xd,yd,nl,'FontSize',16,'FontWeight','bold', 'HorizontalAlignment','left', 'VerticalAlignment','middle');
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
drawnow;
%                 pause(0.1);
frame = getframe(gcf);
%                 kkk = kkk +1;
writeVideo(v,frame);
