function th_plotircdata(src, evnt)

%displays data when user clicks on variable plot
%input param is the axis clicked on

%global phase_plot_styles;
global plot_font_size

%get underlying data
data = get(src, 'UserData');
parameter = data{1};
yData = data{2};
times = data{3};
bs=[];peaknum=[];
if length(data)>3
    bs = data{4};
    if length(data)>4
        peaknum = data{5};
    end
end

fig = figure( 'NumberTitle', 'off');%, 'WindowStyle', 'modal');

set(0,'Units','centimeters');
screen_size = get(0,'ScreenSize');

figwidth = 24;
figheight = 18;
figleft = (screen_size(3) - figwidth)/2;
figbottom = (screen_size(4) - figheight)/2;
pos = [figleft figbottom figwidth figheight];
set(fig, 'Units', 'centimeters', 'Position', pos);

 OKHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Position',[figwidth-2.25 0.25 2 0.7], ...
        'string', 'OK', ...
        'Parent',fig, ...
        'Callback','delete(gcf);');

colnames ={'Time'};
numpeaks = size(yData, 2);  %only > 1 when plotting each param on s seperate line plot and there are > 1 peaks
if numpeaks > 1
    for p = 1:numpeaks
        colnames{end+1} = ['Peak ' num2str(p)];
    end
else
    colnames{2} = 'IRC';
end
tbldata = cell(length(times),numpeaks+1);

for t = 1:length(times);
    tbldata{t, 1} = times(t);
    for p=1:numpeaks
        tbldata{t, p+1} = yData(t,p);
    end
end
tblWidth = (numpeaks+1)*2.5;
resHndl=uitable( ...
        'Units','centimeters', ...
        'position',[0.6 2 tblWidth figheight-2.5], ...
        'Parent',fig, ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'RowName', {}, ...
        'ColumnName', colnames, 'data', tbldata);
    
set(fig, 'name', ['IRC for ', parameter]); % MD changed from  last discussion wth PEB. 
ha = axes('units', 'centimeters', 'Position', [tblWidth+2.5 2 figwidth-tblWidth-4 figheight-2.5]);

for p=1:numpeaks
    if isempty(peaknum)
        ls = get_plot_style(p);
    else
        %when selecting one peak from more than one on original plot,
        %ensure it is plotted same colour as original
        ls = get_plot_style(peaknum);
    end
    if isempty(bs)
        %irc plot
        plot(ha, times,yData(:,p), ls, 'LineWidth', 2);
        xlim([times(1) times(end)]);
        ylabel('\Delta\phi', 'FontSize', plot_font_size);
    else
        %phase irc
         
        bs_idx = find(times == bs(p).t);
        %create plot with 2 y axes
        x1 = times(1:bs_idx-1); y1 = yData(1:bs_idx-1,p)'; %first part of irc,on primary y axis
        x2 = bs(p).t; y2 = bs(p).y; %bs point will go on secondary y axis
        [ax, series1, series2] = plotyy(x1, y1, x2, y2, 'plot');
        set(series1, 'Color', ls(1), 'Linestyle', ls(2:end), 'LineWidth', 2);
        %mark bs with a circle the same color as line
        set(series2, 'Marker', 'o', 'MarkerFaceColor', ls(1), 'MarkerEdgeColor', ls(1), 'LineStyle', 'none');
        %don't show in legend
        set(get(get(series2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        
        hold on;
        %add second part of irc, after time of bs point, excluding it
        %from legend
        series3 = plot(ax(1), times(bs_idx:end),yData(bs_idx:end,p)',ls, 'LineWidth', 2);
        set(get(get(series3,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        %join 2 parts of irc with dotted , interpolated to give 10 points
        join_t = [times(bs_idx-1) times(bs_idx)];
        join_t = [join_t(1):diff(join_t)/10:join_t(2)];
        join_y = interp1(times(bs_idx-1:bs_idx), yData(bs_idx-1:bs_idx,p), join_t);
        series4 = plot(ax(1), join_t,join_y,[ls(1) ':'], 'LineWidth', 1);
        set(get(get(series4,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        %ensure point is at correct time by matching x axes
        xlim(ax(1), [times(1) times(end)]);
        xlim(ax(2), [times(1) times(end)]);
        
        %y labels
        set(get(ax(1),'Ylabel'),'String','\Delta\phi', 'FontSize', plot_font_size)
        set(get(ax(2),'Ylabel'),'String','bs', 'FontSize', plot_font_size)
        set(ax, 'YTickMode', 'auto', 'YLimMode', 'auto');
        
    end
    hold on;
end
    
if numpeaks>1
    legend_str = colnames(2:end);
    legend(legend_str);
end

xlabel('Time of Perturbation', 'FontSize', plot_font_size);
grid(ha,'on');
line(xlim, [0 0], 'Color', 'r', 'LineStyle', '--');
