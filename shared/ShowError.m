%=========================================================================


function  ShowError(msg, varargin)

se = '';
l = [];
if nargin > 1
       
        %show system error message
        l=varargin{1};
 else
     l = lasterror;
end
 
if (length(l.stack) > 0)
  se = {l.message , [l.stack(1).file ' line ' num2str(l.stack(1).line)]};
else
     se = {l.message };
end
  se = regexprep(se, '<[^>]+>', '');


if ~isempty(l)
    
    switch l.identifier
        
        case 'ODEError:InvalidValue'
            
            html_error('PeTTSy Error - Invalid ODE', l.message, [l.stack(1).file ' line ' num2str(l.stack(1).line)]);
            
        otherwise
            se = regexprep(se, '<[^>]+>', '');
            %remove html tags
          %  se=regexprep(se, '<[^>]+>([^<]*)</?[^>]+>', '$1');
            uiwait(errordlg([msg se],'An error has occurred','modal'));
            
    end
else
    msg = regexprep(msg, '<[^>]+>', '');
    uiwait(errordlg(msg,'An error has occurred','modal'));
end

%=========================================================================

function html_error(title_str, msg, loc)

%create from with java enabled text box that can interpret html

f=figure('menubar', 'none', 'Units', 'centimeters','Name', title_str ,'NumberTitle','off','Visible','on');

figsize = get(f, 'position');

txtHndl=uicontrol( ...
        'Style','edit', ...
        'Units','centimeters', ...
        'position',[0.25 1.25 figsize(3)-0.5 figsize(4)-1.5], ...
        'Parent',f, ...
        'BackgroundColor', 'w', ...
        'Max', 10, 'Min', 0, ...
        'horizontalalignment', 'left', ...
        'enable', 'inactive',...
        'string', '', ...
        'value', [], ...
        'FontUnits', 'points', 'FontSize', 9, 'FontName', 'SansSerif');
    
 closeHndl = uicontrol( ...
        'Style','pushbutton', ...
        'Units','centimeters', ...
        'Position',[figsize(3)-2 0.25 1.5 0.7], ...
        'string', 'OK', ...
        'Parent',f, ...
        'FontUnits', 'points', 'FontSize',10, ...
        'enable', 'on', ...
        'Callback','delete(gcf);'); 
    
set(f, 'resizefcn', {@resize_err_form, txtHndl, closeHndl});
    
import javax.swing.*
import java.awt.*
jscrollpane = findjobj(txtHndl);
jscrollpane.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_AS_NEEDED);
jscrollpane.setHorizontalScrollBarPolicy(ScrollPaneConstants.HORIZONTAL_SCROLLBAR_AS_NEEDED);
jeditbox = jscrollpane.getViewport.getView;
%make non-editable
jeditbox.setEditable(false);
%make lines wrap
jeditbox.setWrapping(true);
%set content type
jeditbox.setContentType('text/html');
set(txtHndl, 'string', msg);

%==========================================================================

function resize_err_form(src, ~, textbox, button)

%ensure text box fills form
figsize = get(src, 'position');
set(textbox, 'position', [0.25 1.25 figsize(3)-0.5 figsize(4)-1.5]);
set(button, 'position', [figsize(3)-2 0.25 1.5 0.7]);




           