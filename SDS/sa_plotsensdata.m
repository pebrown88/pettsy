function sa_plotsensdata(i, j, vn, tl, col)

%shows uninterpolated data. This may not match heat map data if using
%f(i,m) as absolute values taken here. For example 2, 2, -2, -2 might
%become 2, 2, 0, -2, -2 after interpolation, giving abs values 2,
%2,2,0,2,2 , rather than just all twos.

%displays data from pc_heatamp4 when use rclicks on variable name or colour
%bar

%i = which pc
%j = which var
%vn = var name
%tl = plot title
%col = position on figure of the heat map that was clicked on

global plot_font_size
fig = gcf;
img = gcbo;
axHndl = get(img, 'parent');

vals = get(fig, 'Userdata');
tVals = vals(:,1);

%jth variable of the ith pc
data = vals(:,col);

loc = get(axHndl,'CurrentPoint');
loc = loc(1,1); %position on x axis wher mouse was clicked
set(0,'Units','centimeters')
screen_size = get(0,'ScreenSize');
figwidth = 24;
figheight = 18;
figleft = (screen_size(3) - figwidth)/2;
figbottom = (screen_size(4) - figheight)/2;
pos = [figleft figbottom figwidth figheight];

fig = figure('Units', 'centimeters', 'Position', pos,'resize', 'off', 'NumberTitle', 'off', 'WindowStyle', 'modal');

OKHndl= uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'FontUnits', 'points', 'FontSize', 10, ...
        'Position',[figwidth-2.25 0.25 2 0.7], ...
        'string', 'Close', ...
        'Parent',fig, ...
        'Callback','delete(gcf);');
% plotHndl= uicontrol( ...
%         'Style','pushbutton', ...
%         'Units','centimeters', ...
%         'Position',[60/100 2.5/100 30/100 5/100], ...
%         'string', 'Composite Plot', ...
%         'FontUnits', 'FontSize', 10, ...
%         'Parent',fig, ...
%         'Callback',['delete(gcf);SensitivityAnalysisGui5(''auto'', ''comp'',' num2str(i) ',' num2str(j)  ')']);



 uicontrol('Style','frame', ...
        'Units','centimeters', ...
        'Position',[0.5 1 5 figheight-1.5], ...
        'BackgroundColor',[0.50 0.50 0.50]);
resHndl=uicontrol( ...
        'Style','listbox', ...
        'HorizontalAlignment', 'right', ...
        'FontName', 'FixedWidth', ...
        'Units','centimeters', ...
        'position',[0.6 1.1 4.8 figheight-2.2], ...
        'min', 1, 'max', 1, ...
        'Parent',fig, ...
        'FontUnits', 'points', 'FontSize', 10);

uicontrol('String', 'Time', 'FontName', 'FixedWidth','HorizontalAlignment', 'left', 'Parent', fig, 'FontUnits', 'points', 'FontSize', 10, 'visible', 'on', 'Style', 'text','Units','centimeters','position',[0.6 figheight-1.1 1.8 0.5], 'BackgroundColor', get(resHndl, 'BackgroundColor'));   
colTitleHndl=uicontrol('String', tl,'FontName', 'FixedWidth','HorizontalAlignment', 'left', 'Parent', fig, 'FontUnits', 'points', 'FontSize', 10, 'visible', 'on', 'Style', 'text','Units','centimeters','position',[2.4 figheight-1.1 3 0.5], 'BackgroundColor', get(resHndl, 'BackgroundColor'));   

if i == 1
    s = 'st';
elseif i == 2
    s = 'nd';
elseif i == 3
    s = 'rd';
else
    s = 'th';
end

set(fig, 'name', char(strcat({'Variable '}, vn, {' of the '}, num2str(i), s, {' principal component'})));

toselect = -1;
dl = cell(length(tVals),1);
for i = 1:length(dl);
    str = sprintf('%7.2f  %8.2f', tVals(i), data(i));
    dl(i) = {str};
    if toselect < 0 && tVals(i) >= loc
        toselect = i;
    end
end

set(resHndl, 'String', dl);

ha = axes('units', 'centimeters', 'Position', [7.5 2 figwidth-8 figheight-2.5]);
plot(tVals,data, 'b', 'LineWidth', 2);
hold on;
%ys = get(gca, 'ylim');
%plot(ha, [loc loc], ys, '-r');
plot(ha, loc, interp1(tVals, data, loc), 'ob', 'MarkerFaceColor', 'b');


xlabel('Time', 'FontSize', plot_font_size);

ylabel(tl, 'interpreter', 'none' ,'FontSize', plot_font_size);
grid(ha,'on');
hold off;
set(resHndl, 'Value', []);
set(resHndl, 'Value', toselect);





