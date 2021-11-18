function [dydt, varargout] = integrate_d_traj_dk_par(t, y, userdata)

%parallel version, integrates one parameter at a time, pnum

% function dydt = integrate_d_traj_dk(t, y, par, sol)
%
% integrates all solution derivatives wrt parameters
%
% t - time
% y - the matrix d_xi/dk expresses as a vector
% par - model parameters
% dydt = equations right hand side

par = userdata{1};
which_pars = userdata{2};
odesol = userdata{3};
dim= userdata{4};
sysjac = userdata{5};
syspar = userdata{6};
ModelForce = userdata{7};
CP = userdata{8};

yr = interpsol(odesol, t); % gets the values of the base solution

jac = feval(sysjac, t, yr, par, ModelForce, CP);    % evaluates jacobian dF/dx
bs = feval(syspar,t,yr,par, ModelForce, CP);        % evaluates dF/dk
bs = bs(which_pars,:);               %new

% memory allocation for speeding up 
dydt = zeros(dim,1);

dydt = jac * y + bs'; 

if nargout > 1 %for CVode
	varargout{1} = 0; %indicate success
	varargout{2} = []; %userdata not modified
end

return

