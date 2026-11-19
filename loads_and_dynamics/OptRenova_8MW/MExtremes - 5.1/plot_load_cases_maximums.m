% function plot_load_cases_maximums(iPlot, plotValues, loadCases, channelNames, titleStr, yLabel)
%
% Create a bar plot, grouping channels by load case
%
% iPlot        - index of the current plot
% plotValues   - (nDLC x nChartChannels) array of data values
% loadCases    - cell array with the names of the load cases
% channelNames - cell array with the channel names
% titleStr     - title string to appear in the plot window
% yLabel       - string label for the y-axis
%

function plot_load_cases_maximums(outputFileRoot, iPlot, PlotFormat, plotValues, loadCases, channelNames, titleStr, yLabel)
hfig  = figure(44000 + iPlot);
close(hfig);
hfig  = figure(44000 + iPlot);
set( hfig, 'Color',[1 1 1], 'Name',titleStr, 'NumberTitle','off', 'PaperOrientation','landscape', 'PaperSize',[11.0, 8.5], 'PaperPosition',[0.25 0.75 10.5 7.0], 'PaperType','usletter' );

nDLCs = length(loadCases);
L = bar(plotValues,0.5);

if ( nDLCs == 1 )
   hText = xticklabel_rotate([1:length(channelNames)],60.0,channelNames,'interpreter','none');
   set(get(gca,'XLabel'), 'String',loadCases);
else
   hleg = legend(channelNames,'Location','SouthEast');
   set(hleg,'FontAngle','italic');
   hText = xticklabel_rotate([1:nDLCs],60.0,loadCases,'interpreter','none');
   set(get(gca,'XLabel'), 'String','Load Cases');   
end

set(get(gca,'YLabel'),'String', yLabel);

 % save the figure
if ( PlotFormat == 1 ) 
   FigName = strcat( outputFileRoot, '_', titleStr, '.png' );
   saveas(hfig,FigName);        
else
   FigName = strcat( outputFileRoot, '_', titleStr, '.fig' );
   hgsave(hfig,FigName);       
end 


   %apply mouse motion function
%set(hfig,'windowbuttonmotionfcn',{@mousemove,L,plotValues});

end

function mousemove(src,ev,L,plotValues)
 
%since this is a figure callback, the first input is the figure handle:
f=src;
 
%like all callbacks, the second input, ev, isn't used. 
 
%determine which object is below the cursor:
obj=hittest(f); %<-- the important line in this demo
 
if obj==L %if over the plot...
    %get cursor coordinates in its axes:
    a=get(L,'parent');
    point=get(a,'currentpoint');
    xclick=point(1,1,1);
    yclick=point(1,2,1);
 
    %determine which point we're over:
    idx=findclosestpoint2D(xclick,yclick,L);
 
    %make a "tool tip" that displays this animal.
    xoffset=.05;
    yoffset=20;
 
    delete(findobj(f,'tag','mytooltip')); %delete last tool tip
    text(xclick+xoffset,yclick+yoffset,num2str(plotValues(idx)),...
        'backgroundcolor',[1 1 .8],'tag','mytooltip','edgecolor',[0 0 0],...
        'hittest','off');
else
    delete(findobj(f,'tag','mytooltip')); %delete last tool tip
 
end
end
function index=findclosestpoint2D(xclick,yclick,datasource)
%this function checks which point in the plotted line "datasource"
%is closest to the point specified by xclick/yclick. It's kind of 
%complicated, but this isn't really what this demo is about...
 
xdata=get(datasource,'xdata');
ydata=get(datasource,'ydata');
 
activegraph=get(datasource,'parent');
 
pos=getpixelposition(activegraph);
xlim=get(activegraph,'xlim');
ylim=get(activegraph,'ylim');
 
%make conversion factors, units to pixels:
xconvert=(xlim(2)-xlim(1))/pos(3);
yconvert=(ylim(2)-ylim(1))/pos(4);
 
Xclick=(xclick-xlim(1))/xconvert;
Yclick=(yclick-ylim(1))/yconvert;
 
Xdata=(xdata-xlim(1))/xconvert;
Ydata=(ydata-ylim(1))/yconvert;
 
Xdiff=Xdata-Xclick;
Ydiff=0;%Ydata-Yclick;
 
distnce=sqrt(Xdiff.^2+Ydiff.^2);
 
index=distnce==min(distnce);
 
index=index(:); %make sure it's a column.
 
if sum(index)>1
    thispoint=find(distnce==min(distnce),1);
    index=false(size(distnce));
    index(thispoint)=true;
end
end