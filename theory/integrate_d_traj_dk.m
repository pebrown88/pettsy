function [dydt, varargout] = integrate_d_traj_dk(t, y, userdata)

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

global sysjac syspar ModelForce CP

% y is a vector representing the matrix Y(:)=y
% ith row of Y is del_xi_i/del_k which is k dimensional
wpnum=length(which_pars);
Y = zeros(dim,wpnum); % was pnum
Y(:) = y;  %turns y into a matrix - reshape

yr = interpsol(odesol, t); % gets the values of the base solution

jac = feval(sysjac, t, yr, par, ModelForce, CP);    % evaluates jacobian dF/dx
bs = feval(syspar,t,yr,par, ModelForce, CP);        % evaluates dF/dk
bs = bs(which_pars,:);               %new


% memory allocation for speeding up 
%dydt = zeros(dim + dim2 + dim*pnum, 1);
dydt = zeros(wpnum*dim,1);

dydt(:) = jac * Y + bs'; %this should convert the rhs matrix into a vector


if nargout > 1 %for CVode
	varargout{1} = 0; %indicate success
	varargout{2} = []; %userdata not modified
end

return

