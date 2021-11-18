function dydt = integrazt(t, y, par, sysjac, ftype, cp)

% This is for the equation dY/dy = -J(t)^t*Y which is the transpose of dZ/dt
% = -Z*J(t) which is the equation for integraz. The solution is Y =
% X(t,p)^t.

global dim  odesol

jac = feval(sysjac, t, interpsol(odesol,t), par, ftype, cp);

z = zeros(dim);
z(:) = y;

ll = -jac'*z;%was -z*jac

dydt = ll(:);


