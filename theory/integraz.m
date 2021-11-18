function dydt = integraz(t, y, par, odesol, sysjac, ftype, cp)

jac = feval(sysjac, t, interpsol(odesol,t), par, ftype, cp);

z = y;

ll = -jac'*z;

dydt = ll;

