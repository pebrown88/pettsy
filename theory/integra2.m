function [dydt, varargout] = integra2(t, y, userdata)

% function dydt = integra2(t, y, par)
%
% integrates model equations together with equations for variations
%
% t,y - model solution
% par - model parameters
% dydt = equations right hand side

par = userdata{1};
system = userdata{2};
sysjac = userdata{3};
dim = userdata{4};
ModelForce = userdata{5};
CP = userdata{6};


ncols = (length(y) - dim)/dim;
% memory allocation for speeding up 
dydt = zeros(length(y), 1);

% the system integration
dydt(1:dim) = feval(system, t, y(1:dim), {par, ModelForce, CP});

% system jacobian
jac = feval(sysjac, t, y(1:dim), par, ModelForce, CP);

% linearised system integration 
v = zeros(dim, ncols);
v(:) = y(dim+1:end)';
v(:) = jac * v;
dydt(dim+1:end) = v(:);

if nargout > 1 %for CVode
	varargout{1} = 0; %indicate success
	varargout{2} = []; %userdata not modified
end


