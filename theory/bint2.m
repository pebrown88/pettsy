function [dydt, varargout] = bint2(u, y, userdata)


% t is absolute time
% this is to solve dY/dt=A(t-u)*Y(u) (Y(u) will be X(t-u,t)*)
% backward integration with u = [0 ti-ti-1], dY/dt = Y(t)A(t-u) where Y =
% X(t-u,t)

dim = userdata{1};
A = userdata{2};
At = userdata{3};
tt = userdata{4};
sol = userdata{5};
par = userdata{6};
force = userdata{7};
cp = userdata{8};

% memory allocation for speeding up



dydt = zeros(length(y), 1);

%find value of A at time t-u
if isa(A, 'function_handle')
    Atmp = feval(A, tt-u, interpsol(sol,tt-u), par, force, cp);
else
    Atmp = interp1(At, A, t-u, 'pchip');
end

Atmp = squeeze(Atmp)';
% linearised system integration
v = zeros(dim);
v(:) = y;  % v is now a matrix
v = Atmp * v;

dydt = v(:);

if nargout > 1 %for CVode
	varargout{1} = 0; %indicate success
	varargout{2} = []; %userdata not modified
end