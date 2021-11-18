function updatebar(wbHndl, inc, str)

if ~isempty(wbHndl)
    current_pos = get(wbHndl, 'userdata');
    new_pos = current_pos+inc;
    
    if nargin > 2
        waitbar(new_pos, wbHndl, str);
    else
        waitbar(new_pos, wbHndl);
    end
    set(wbHndl, 'userdata', new_pos);
    drawnow;
end

