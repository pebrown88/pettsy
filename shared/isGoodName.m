function [ok, errmsg] =isGoodName(name)

%test if name can be used as a model variable or parameter name

if iskeyword(name)
    errmsg = [name ' is a MATLAB keyword'];
    ok = false;
elseif exist(name, 'builtin')
    errmsg = [name ' is a built-in MATLAB function'];
    ok = false;
elseif exist(name, 'file') == 3 || exist(name, 'file') == 2
    errmsg = [name ' is a file on the MATLAB search path'];
    ok = false;
elseif ~isvarname(name)
    errmsg = [name ' is not a valid MATLAB variable name'];
    ok = false;
else
    errmsg = '';
    ok = true;
end
    
    
   