function dydt = f(t, y, p)

% 

eval(p);
force = 2/(1+sqrt(1+8*keq*y(2)));
dydt = [ 
    vm/(1+(y(2)*(1-force)/(2*pc))^2)-km*y(1);
    vp*y(1)-(kp1*y(2)*force+kp2*y(2))/(jp+y(2))-kp3*y(2);
];

% =======================================================================
% the information below is written into the file name.info and is used to
% communicate whether the system is an oscillator or a signalling system,
% which ode solver method to use, the end time is teh system is a signal,
% the force type used from the file /shared/theforce and wherther the
% solutions should be non-negative or not. The %%% before
% each line is needed. Using %%%info lines it can also be used to store away
% other information. In this case the title of the model and the initial
% condition that is used.
%%%info Tyson 2-D drosophila
%%%force_type noforce

% =======================================================================
