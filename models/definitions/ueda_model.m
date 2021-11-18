function dydt = f(t, y, p)

% 

eval(p);

%syms  coupling1 coupling2 coupling3;

coupling1 = (y(10)/a1)^a + b1;
coupling2 = (y(10)/a2)^a + b2;
coupling3 = (y(6)/a3)^a + b3;


dydt = [
    %PERm 1
   c1 + (s1 + amp * force) * (coupling1/ (1 + (y(6)/r1)^r + coupling1)) - ...
   d1 * y(1) / (l1 + y(1)) - d0 * y(1);
   
   %PERc 2
   s2*y(1) - v1 * y(2) * y(4) + v2*y(5) - d2*dbt*y(2)/(l2 +y(2))-d0*y(2);
   
   %TIMm 3
   c2 + s3*(coupling2 / (1 + (y(6)/r2)^r + coupling2)) - ...
   d3 * y(3) / (l3 + y(3)) - d0 * y(3);
   
   %TIMc 4
    s4*y(3) - v1 * y(2) * y(4) + v2*y(5) - (d4+0)*y(4)/(l4 +y(4))-d0*y(4);
    
    %PTc 5
    v1 * y(2) * y(4) - v2*y(5) - t11 * y(5)/(k1 + y(5)) + t2 * y(6) / (k2 +y(6))-(d5+0)*y(5)/(l5 + y(5)) - d0 * y(5);
    
    %PTn 6
    t11 * y(5)/(k1 + y(5)) - t2 * y(6)/(k2 + y(6)) - d6 * y(6)/(l6 + y(6)) - d0 * y(6);
    
    %CLKm 7
    c3 + (s5 + amp * 0) * (coupling3/(1+(y(10)/r3)^r+coupling3))-d7*y(7)/(l7 + y(7))-d0 * y(7);
    
    %CLKc 8
    s6*y(7) - v3v * y(8) * cyc + v4*y(9) - (d8+0)*y(8)/(l8 +y(8))-d0*y(8);
    
    %CCc 9
    v3v * y(8)*cyc - v4*y(9) - t3 * y(9)/(k3 + y(9)) + t4 * y(10)/(y(10)+k4) - ...
    (d9+0)*y(9)/(l9+y(9))-d0 * y(9);
    
    %CCn 10
    t3 * y(9)/(k3 + y(9)) - t4 * y(10)/(y(10)+k4) - d10*y(10)/(l10+y(10))-d0*y(10);
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
%%%info Ueda drosophila

% =======================================================================



