function [t,y] = getmaximum(name, tspan, y0, par, varnum, ops)

% function [t,y] = getminimum(system, tspan, y0, par, varnum)
%
% the function locates first following minimum in the given variable 
% with given precision
%
% name - function name
% tspan - time interval where it looks for minimum
% y0 - initial conditions
% par - model parameters
% varnum - number of variables where looking for minimum

%
% t,y - obtained solution with minimum at t(end-1),t(end-1,:)
global system varnum1 solver ModelForce CP;

% preset of variables used by function ifmin below in this file
varnum1 = varnum;
system = name;

% integrate until the first following minimum
% ifmin - event handler, Refine is set to 1
% tolerance can be reduced

options = ops;
options = odeset(options, 'Events', @ifmax);
system = str2func(name);

routine = str2func(solver);
[t, y] = feval(routine,system, tspan, y0, options,{par, ModelForce, CP});

%============================================


function [value, flag, direction] = ifmax(t,y,userdata)

global system varnum1  method
persistent lastdydt

dydt = feval(system,t,y,userdata);
dydt = dydt(varnum1);

if strcmp(method{1}, 'matlab')
    %Matlab
    flag = 1; %value of non-zero indicates stop when event fires
    direction = -1; 
    value = dydt;
else
    %CVode
    %can't handle direction so need to keep a record of last value
    
    if ~isempty(lastdydt) && dydt<=0 && (lastdydt>0)
        %not first timepoint
         value = 0; %found it
         lastdydt = [];
    else
         value = 1; 
         lastdydt = dydt;
    end
        
    flag = 0; %value of zero indicates no error
    direction = []; %just a placeholder. Must be set to empty
end

