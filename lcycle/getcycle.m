function [t, y, per, eps] = getcycle(name, tspan, y0, par, varnum, odeopts, mtype, shift)

% function [t,y,per,eps] = getcycle(system, tspan, y0, par, varnum)
%
% this function returns solution of the system from one minumum till the next 
% minimum in the given variable(varnum)
%
% name - model name
% tspan - time interval where it looks for minimum
% y0 - initial conditions
% par - vector of parameters
% varnum - number of the variable where it looks for minimum
%
% t,y - obtained solution
% per - system period
% eps - difference between start point and end point of the solution

global solver ModelForce CP

if strcmp(mtype,'min')
    f1 = str2func('getminimum');
    f2 = str2func('getmaximum');
else
    f1 = str2func('getmaximum');
    f2 = str2func('getminimum');
end

% gets first minimum
[tp,yp] = feval(f1,name, tspan, y0, par, varnum, odeopts);

tc = tp(end);   %conditions at first minimum
yc = yp(end,:);

t0 = tc;
y0 = yc;

% starting againg from discovered minimum
tspan = [t0, t0 + tspan(2) - tspan(1)];  

% gets next minimum
%gets max first
[t1, y1] = feval(f2,name, tspan, y0, par, varnum, odeopts);

t02 = t1(end);
y02 = y1(end,:);
tspan = [t02, t02 + tspan(2) - tspan(1)];  

%t02-tp(1)

[t, y] = feval(f1,name, tspan, y02, par, varnum, odeopts);
t = [t1; t];
y = [y1; y];

tc = t(end);
yc = y(end,:);

% period
per = tc - t0;

% calculates periodic solution shifted from minimum by 
% given time shift
%------------------------------------------------------
if shift < 0
    shift = shift + per;
end
if shift > 0
    % set end point as new initial conditions and integrate the system
    % for additional time shiftp
    [t2,y2] = feval(str2func(solver), str2func(name),[tc, (tc+shift)],yc,odeopts,{par, ModelForce, CP});
    % now intgeration for one period starting from t=tmin+shiftp 
    [t, y] = feval(str2func(solver),str2func(name),[t2(end), (t2(end)+per)],y2(end,:),odeopts,{par, ModelForce, CP});
end

% difference between to minima 
eps = norm(y(end,:) - y(1,:));  %square root of sum of squares
