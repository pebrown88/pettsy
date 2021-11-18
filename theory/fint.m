function [dydt, varargout] = fint(t, y, userdata)


%forward integration from ti-1 to ti, with dydt = A(t)Y(t)

dim = userdata{1};
A = userdata{2};
At = userdata{3};
sol = userdata{4};
par = userdata{5};
force = userdata{6};
cp = userdata{7};

% memory allocation for speeding up 
dydt = zeros(length(y), 1);

%find value of A at time t
if isa(A, 'function_handle')
    % Atmp = feval(A, t);
    Atmp = feval(A, t, interpsol(sol,t), par, force, cp);
else
    Atmp = interp1(At, A, t, 'pchip');
end

Atmp = squeeze(Atmp);
% linearised system integration 
v = zeros(dim);
v(:) = y;  % v is now a matrix
v = Atmp * v;

dydt = v(:);

if nargout > 1 %for CVode
	varargout{1} = 0; %indicate success
	varargout{2} = []; %userdata not modified
end

