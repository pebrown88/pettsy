function dydt = integraprc(t, y, par, amp, pulseOn, pulseOff, j)

global system ModelForce CP 

st = pulseOn-4;
en = pulseOff+4;

%t1=mod(t,24); PEB removed this line so perturbation only applied once 
t1 = t;
%applies a pulse to ther selected parameter
if t > st && t < en   
    force = amp * (tanh((t1-pulseOn)*24) + 1) * (-tanh((t1-pulseOff)*24)+1)/4;
else
    force = 0;
end

pare = par;
pare(j) = pare(j) + force;

dydt = feval(system, t, y, {pare, ModelForce, CP});


