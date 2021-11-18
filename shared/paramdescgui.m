function r = paramdescgui(model)

persistent newFig

%draw figure
newFig=figure('resize', 'off', 'menubar', 'none' ,'Name', [model.name ' Model Parameters'] ,'NumberTitle','off');
set(0,'Units','centimeters')
screen_size = get(0,'ScreenSize');

figwidth = 10;
figheight = 12;
figleft = (screen_size(3) - figwidth)/2;
figbottom = (screen_size(4) - figheight)/2;

pos = [figleft figbottom figwidth figheight];
set(newFig, 'Units', 'centimeters', 'Position', pos);

maincol = get(newFig, 'Color');
frmPos=[0.1 0.9 figwidth-0.2 figheight-1];

panel = uipanel('BorderType', 'etchedin', ...
    'BackgroundColor', maincol, ...
    'Units','centimeters', ...
    'Position',frmPos, ...
    'HandleVisibility', 'on', ...
    'visible', 'on', ...
    'Parent', newFig);

pheight = frmPos(4);
pwidth = frmPos(3);

tbl = uitable('units', 'centimeters', 'position', [0.5 0.5 pwidth-1 pheight-1], ...
    'fontunits', 'points', 'fontsize', 10, ...
    'columnname', {'Parameter', 'Description'}, ...
    'parent', panel);

set(tbl, 'units', 'pixels');
tblwidth = get(tbl, 'position');
tblwidth = tblwidth(3);
if length(model.parn) >= 18
    tblwidth = tblwidth*0.95;
end

set(tbl, 'data', [model.parn model.parnames], 'columnwidth', {tblwidth*0.265 tblwidth*0.6});


%OK and Cancel buttons

OKHndl = uicontrol(...
    'Style','pushbutton', ...
    'Units','centimeters', ...
    'Position',[figwidth-2.1 0.1 2 0.7], ...
    'Parent',newFig, ...
    'string', 'OK', ...
    'FontUnits', 'points', 'FontSize', 10, ...
    'Callback','delete(gcf)');

r = newFig;

    
