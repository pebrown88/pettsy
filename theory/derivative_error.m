function derivative_error(dm, y, t, p, force, mtype, fp, dforce)

%analyses a derivataive matrix hat has Inf or NaN values. Finds which
%element and advises the user what the cause might have been

%dm - the matrix
%y - current model variables
%p - model paramters
%force - current force
%mtype - type of  matrix. 0 = model system, 1 = dydt/dy, 2 = dydt/dk
%fp -  equations info file
%dforce may contain the dawn and dusk derivatives, if mtype is 2


% jac(i, j) is (dyi/dt)/dyj
% dpar(i, j) is (dyj/dt)/dki


%check df_ddawn etc

%load info on equations needed to display hints to user

load(fp);
%eqn_info - array of structures, one for each ode, with fields
%   variables - index num of model variables appearing in this eqn
%   parameters - index num of model params appearing in this eqn
%   force -  - index num of forces appearing in this eqn

%model_odes - equation in symbolic form
%dydtdy, dydtdk - derivative matrices in symbolic form
%parn, varnames, forcenames, dforcesym - the symbolic names

nans = find(isnan(dm(:)));
infs = find(isinf(dm(:)));
comp = find(imag(dm(:)));
bad_result = [nans; infs; comp];
dim = length(y);
if nargin < 8
    dforce = [];
end

if mtype == 0
    %model ODE error
    msg = ['<html><h2>Error evaluating the model ODEs at t = ' num2str(t) '</h2>'];
    equations = model_odes;
elseif mtype == 1
    %dydt/dy
    msg = ['<html><h2>Error evaluating (&#8706y / &#8706t) / &#8706y at t = ' num2str(t) '</h2>'];
    equations = dydtdy;
elseif mtype == 2
    %dydt/dk
    msg = ['<html><h2>Error evaluating (&#8706y / &#8706t) / &#8706k at t = ' num2str(t) '</h2>'];
    equations = dydtdk;
end
msg = [msg '<p>These are the usual causes of this type of error</p>'];
msg = [msg '<br/><table><tr><th>Expression</th><th>Evaluates to</th></tr>'];
msg = [msg '<tr><td><i>x<sup> y</sup></i>, where <i>x</i> &lt; 0 and <i>y</i> is a non-integer value</td></td>NaN</td></tr>'];
msg = [msg '<tr><td><i>0 / 0</i></td><td>NaN</td></tr>'];
msg = [msg '<tr><td><i>0<sup> x</sup</i>, where <i>x</n> &lt; 0</td><td>Inf</td></tr>'];
msg = [msg '<tr><td><i>&#177; x / 0</i>, where <i>x</i> is non-zero</td><td>&#177;Inf</td></tr>'];
msg = [msg '<tr><td><i>log 0</i></td><td>-Inf</td></tr>'];
msg = [msg '<tr><td><i>log x</i>, where x &lt; 0</td><td>complex value</td></tr>'];
msg = [msg '</table>'];

msg = [msg '<p>The details are shown below</p>'];

for n=1:length(bad_result)
    
    if mtype == 0
        eqn = equations{bad_result(n)};
        msg = [msg '<h3>Equation ' num2str(bad_result(n)) ':</h3><p>' eqn ' = ' num2str(dm(bad_result(n))) '</p>'];
    else
        col = floor((bad_result(n)-1)/ size(equations, 1))+1;
        row = mod(bad_result(n)-1, size(equations, 1)) + 1;
        eqn = equations{row, col}; 
        if mtype == 1
            msg = [msg '<h3>&#8706f' num2str(row) '/&#8706y' num2str(col) ':</h3><p>' eqn ' = ' num2str(dm(bad_result(n))) '</p>'];
        else
            msg = [msg '<h3>&#8706f' num2str(row) '/&#8706k' num2str(col) ':</h3><p>' eqn ' = ' num2str(dm(bad_result(n))) '</p>'];
        end
    end
    msg = evaluate_eqn(eqn, msg, y, p, force, varnames, parn, forcenames, dforcesym, dforce);
    
end
  
msg  = [msg '</html>'];

ME = MException('ODEError:InvalidValue', msg);

%clear eqn_info variables parameters force
throw(ME);

return;

%==========================================================================

function msg = evaluate_eqn(eqn, msg, y, p, force, vnames, parn, forcenames, dforcesym, dforce)

%look for cause of NaN/Inf value by breaking eqn up into seperate expressions
%and evaluating each. Problems always caused by ^ or / operator. 
%NaN can be zero/zero, Inf/Inf, or x^-y, when x < 0 and y is not an integer. 
%Inf can be caused by 0^-n, x/0, where x is non-zero, or log(0)

%returns an error message and the parameter and state values that caused th
%error


msg = [msg '<ul>'];

%evalaute all '^' and '/' operators to find the problem
err_details = {};
op_idx = strfind(eqn, '^');
op_idx2 = strfind(eqn, '/');
op_idx = [op_idx op_idx2];

expression_idx = [];

for i = 1:length(op_idx)
    [left_sym, first_idx] = find_left_expr(eqn, op_idx(i));
    [right_sym, last_idx] = find_right_expr(eqn, op_idx(i));
    %first and last idx is the index position the whole expression around th e'^' or '/' operator occupies within
    %the equation
    %save this so later we can eliminate any long expressions that have
    %smaller one scontained within them
    %Example, (a + B - c/0)/(f + g) evaluates to Inf, but we really onlyt want the c/0 as this is the cause 
    
    %replace sym names with their values
    [left_val, components_left] = find_value_from_sym(left_sym, y, p, force, vnames, parn, forcenames, dforcesym, dforce);
    [right_val, components_right] = find_value_from_sym(right_sym, y, p, force, vnames, parn, forcenames, dforcesym, dforce);
    if eqn(op_idx(i)) == '^'
        result = left_val^right_val;
        tmp_msg = ['<li>' left_sym  '<sup>' right_sym '</sup> evaluates to '  num2str(left_val)  '<sup>' num2str(right_val) '</sup> = ' num2str(result)];
    else
        result = left_val/right_val;
        tmp_msg = ['<li>' left_sym  ' / ' right_sym  ' evaluates to '  num2str(left_val)  ' / ' num2str(right_val) ' = ' num2str(result)];
    end
    
    %construct warning message
    
    if isnan(result) || isinf(result) || ~isreal(result)
        %merge
        components = unique([components_left  components_right]);
        tmp_msg = [tmp_msg '<ul style="list-style-type:none">'];
        for c = 1:length(components)
            tmp_msg = [tmp_msg '<li><i>' components{c} '</i>'];
        end
        tmp_msg = [tmp_msg '</ul>'];
        err_details{end+1} = tmp_msg;
        expression_idx(end+1,:) = [first_idx last_idx];
    end
   
end


%find logs
log_idx = strfind(eqn, 'log(');
log_idx = log_idx+2;
for i = 1:length(log_idx)
    [log_sym, last_idx] = find_right_expr(eqn, log_idx(i));
    [log_val, components] = find_value_from_sym(log_sym, y, p, force, vnames, parn, forcenames, dforcesym, dforce);
    result = log(log_val);
    
   if isnan(result) || isinf(result) || ~isreal(result)
        tmp_msg = ['<li>log(' log_sym(2:end-1) ') evaluates to log(' num2str(log_val) ') = ' num2str(result)]; % note log term will be surrounded by unwanted (...)
        tmp_msg = [tmp_msg '<ul style="list-style-type:none">'];
        for c = 1:length(components)
            tmp_msg = [tmp_msg '<li><i>' components{c} '</i>'];
        end
        tmp_msg = [tmp_msg '</ul>'];
        err_details{end+1} = tmp_msg;
        expression_idx(end+1,:) = [log_idx(i)+1 last_idx];
    end
    
end

%now look for any expressions that have othe expressions within them
%so these larger expressions can be removed
%Example, (a + B - c/0)/(f + g) evaluates to Inf, but we really onlyt want the c/0 as this is the cause 
 
to_remove = [];
for i = 1:length(err_details)
    expr_range = expression_idx(i, :);
    if any(expression_idx([1:i-1 i+1:end],1) >= expr_range(1) & expression_idx([1:i-1 i+1:end],2) <= expr_range(2))
       to_remove = [to_remove i]; %remove expression i if there are others contained within it 
    end
    %Note that use of <=, >= allows things like (a/b)^2 to be caught as /
    %and ^ expression both start at '('. So we need to use [1:i-1 i+1:end]
    %for indexing to prevent entries being removed becasue they match
    %themselves
end
err_details(to_remove) = [];

%remove duplicates
[~, unique_idx] = unique(err_details); 
%THIS HAS BEEN SORTED!!!
unique_idx = sort(unique_idx);
err_details = err_details(unique_idx); %Original order restored


%create output
for i = 1:length(err_details)
    msg = [msg err_details{i}]; 
end
msg = [msg '</ul>'];


%==========================================================================

function [numeric_value, components] = find_value_from_sym(sym_expr, y, par, force, varnames, parn, forcenames, df_ddawn_names, df_ddawn_values)

%repalce symbolic variables with their numeric value

 %df_ddawn_names = vector [dawn1 dusk1 dawn2 dusk2]
 %df_ddawn_values = matrix [dawn1 dusk1; dawn2 dusk2]
 
numeric_expr = sym_expr;
 
%find var names
symnames = regexp(sym_expr, '(([a-zA-Z][a-zA-Z_0-9]*)+)', 'tokens');
components = {};
numeric_value = [];
val = [];
%for each one
for s = 1:length(symnames)
    name = char(symnames{s});
    v = find(strcmp(varnames, name));
    if ~isempty(v)
        % its a variable
        val = y(v);
    else
        p = find(strcmp(parn, name));
        if ~isempty(p)
            %its a parameter
            val = par(p);
        else
            f = find(strcmp(forcenames, name));
            if ~isempty(f)
                %its a force
                val = force(f);
            else
                if ~isempty(df_ddawn_values)
                    df = find(strcmp(df_ddawn_names, name));
                    if ~isempty(df)
                        val = df_ddawn_values(ceil(df/2), mod(df+1, 2)+1);
                    end
                end
            end
        end
    end
    if ~isempty(val)
        %replace name with value
        numeric_expr = regexprep(numeric_expr, ['(^|[^a-zA-Z0-9_])' name '([^a-zA-Z0-9_\(]|$)'], ['$1' num2str(val) '$2']);
        %note '\('  in $2. Without this then if user gave a parm or var
        %same name as a built in function such as log(), then any call to
        %that function in the same eqn would be replaced with the numeric
        %value, eg log +log(a), where log is a symbolic expression = 5,
        %would become 5 + 5(a)
        %Using a built in name might cause an error anyway
        components{end+1}= [name '=' num2str(val)];
        
    end
end

numeric_value = eval(numeric_expr);

%df_ddawn(1) will b df_ddawn1 in sym_expr. Need to retrieve its value

%==========================================================================

function [expr, last_idx] = find_right_expr(eqn, i)

i=i+1;
expr = eqn(i);

if expr == '('
    
    openb = 1;
    closeb = 0;
    while i <= length(eqn)
        i = i+1;
        expr = [expr eqn(i)];
        if expr(end) == '('
            openb = openb+1;
        elseif expr(end) == ')'
            closeb = closeb+1;
        end
        if openb == closeb
            last_idx = i;
            break;
        end
        
    end
    
elseif isstrprop(expr, 'digit')
    %no backets, simple literal value
    expr=regexp(eqn(i:end), '^([\d\.]+)', 'tokens');
    expr = char(expr{1});
    last_idx = i +length(expr)-1; 
elseif isstrprop(expr, 'alpha')
    %sym name
    expr=regexp(eqn(i:end), '^([a-zA-Z][a-zA-Z_\d]*)', 'tokens');
    expr = char(expr{1});
    last_idx = i +length(expr)-1;
end

%==========================================================================

function [expr, first_idx] = find_left_expr(eqn, i)

i=i-1;
expr = eqn(i);

if expr == ')'
    
    openb = 0;
    closeb = 1;
    while i > 1
        i = i-1;
        expr = [eqn(i) expr ];
        if expr(1) == '('
            openb = openb+1;
        elseif expr(1) == ')'
            closeb = closeb+1;
        end
        if openb == closeb
            first_idx = i;
            break;
        end
        
    end
    
elseif isstrprop(expr, 'digit')
    %no backets, 
    %test for variable whose name ends in a digit
    expr=regexp(eqn(1:i), '([a-zA-Z][a-zA-Z_\d]*[\d])$', 'tokens');
    if isempty(expr)
        %simple literal value
         expr=regexp(eqn(1:i), '([\d\.]+)$', 'tokens');
    end

    expr = char(expr{1});
    first_idx = i - length(expr) +1;
elseif isstrprop(expr, 'alpha')
    %sym name
    expr=regexp(eqn(1:i), '([a-zA-Z][a-zA-Z_\d]*)$', 'tokens');
    expr = char(expr{1});
    first_idx = i - length(expr) +1;
end
