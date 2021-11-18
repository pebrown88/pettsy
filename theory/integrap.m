function dydt = integrap(t, y, par, system, sysjac, dim, ModelForce, CP)

%version of integra2 suitable for parfor loop,
%ie system has already beenintegrated over tau in advance

% function dydt = integra2(t, y, par)
%
% integrates model equations together with equations for variations
%
% t,y - model solution
% par - model parameters
% dydt = equations right hand side

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


