function dydt = f(t, y, p)

% Goldbeter neurospora 

% declare all variables parameters and variables below to be symbolic variables 
eval(p); 
 
dydt = [  
   (vs + amp * force) * ki^n / (ki^n + y(3)^n) - vm * y(1) / (km + y(1));  
    (ks + 0) * y(1) - vd * y(2) / (kdn + y(2)) - k1n * y(2) + k2n * y(3);
    k1n * y(2) - k2n * y(3);
];

% force which is in modelname_f.m file   
%%%force_type cts 1 10
