function  y_t  = interpsol( sol, t )

%interpolate solution to required timepoint(s)

if ~isfield(sol, 'solver') || strcmp(sol.solver, 'cvode')
   
    %sol produced by cvode. No helper interpoaltion function to use
    %happens with signal model. Only happens with oscillator when bvs fails
    
    x = sol.x(:);
    y = sol.y;
    %time series must be in cols
    i = find(size(y)==length(x));
    if i == 2
        y=y';
    end
    y_t = interp1(x, y, t, 'pchip');
    y_t = y_t';  
  
else  
    %matlab solver used
   y_t = deval(sol, t);
end

