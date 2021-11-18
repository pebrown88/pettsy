function display_message(msg, varargin)

%print message, and also write it to gui if one of defined

global gui

disp(msg);

if ~isempty(gui)
    if nargin == 1
        feval(gui,'write', msg);
    elseif varargin{1}
        feval(gui,'progress', msg, varargin{1});
    end
end