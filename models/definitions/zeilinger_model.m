function dydt = f(t, y, p)

%zeilinger Arabidopsis

eval(p);

dydt = [

	%1 mRNA of LHY
	amp*force * q1 * y(13) + (n1 * y(9)^a) / (g1^a + y(9)^a) * (g7^h) / (g7^h + y(16)^h) * (g8^ii) / (g8^ii + y(19)^ii) - (m1 * y(1)) / (k1 + y(1));
    
    %2 Cytoplasm LHy
    p1 * y(1) - r1 * y(2) + r2 * y(3) - (m2 * y(2)) / (k2 + y(2));
    
    %3 Nucleus LHy
    r1 * y(2) - r2 * y(3) - (m3 * y(3)) / (k3 + y(3));
    
    %4 mRNA of TOC1
    (n2 * y(12)^b) / (g2^b + y(12)^b) * (g3^c) / (g3^c + y(3)^c) - (m4 * y(4)) / (k4 + y(4));
    
    %5 Cytoplasm TOC1
    p2 * y(4) - r3 * y(5) + r4 * y(6) - ((1 - amp*force) * m5 + m6) * (y(5)) / (k5 + y(5));

    %6 Nucleus TOC1
    r3 * y(5) - r4 * y(6) - ((1 - amp*force) * m7 + m8) * (y(6)) / (k6 + y(6));
   
    %7 mRNA of X
    (n3 * y(6)^d) / (g4^d + y(6)^d) - (m9 * y(7)) / (k7 + y(7));
    
    %8 Cytoplasm X
    p3 * y(7) - r5 * y(8) + r6 * y(9) - (m10 * y(8)) / (k8 + y(8));
    
    %9 Nucleus X
    r5 * y(8) - r6 * y(9) - (m11 * y(9)) / (k9 + y(9));
    
    %10 mRNA of Y
    (amp*force * n4 + n5) * g5^e / (g5^e + y(6)^e) * (g6^f) / (g6^f + y(3)^f) - (m12 * y(10)) / (k10 + y(10));
    
    %11 Cytoplasm y
    p4 * y(10) - r7 * y(11) + r8 * y(12) - (m13 * y(11)) / (k11 + y(11));
    
    %12 Nucleus y 
    r7 * y(11) - r8 * y(12) - (m14 * y(12)) / (k12 + y(12));
    
    %13 Nucleus P
    (1 - amp*force) * p5 - (m15 * y(13)) / (k13 + y(13)) - q3 * amp*force * y(13);
    
    %14 mRNA of PRR7
    (n6 * y(3)^jj) / (g9^jj + y(3)^jj) - (m16 * y(14)) / (k14 + y(14));
    
    %15 Cytoplasm PRR7
    p6 * y(14) - r9 * y(15) + r10 * y(16) - (m17 * y(15)) / (k15 + y(15));
    
    %16 Nucleus PRR7
    r9 * y(15) - r10 * y(16) - (m18 * y(16)) / (k16 + y(16));
   
    %17 mRNA of PRR9
    (amp*force * q4 * y(13) + amp*force * n7 + n8) * (y(3)^k) / (g10^k + y(3)^k) - (m19 * y(17)) / (k17 + y(17));
    
    %18 Cytoplams PRR9
    p7 * y(17) - r11 * y(18) + r12 * y(19) - (m20 * y(18)) / (k18 + y(18));
  
    %19 Nucleus PRR9
    r11 * y(18) - r12 * y(19) - (m21 * y(19)) / (k19 + y(19));
    
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
%%%info Zeilinger Arabidopsis model
%%%positivity non-negative
%%%method matlab_non-stiff
%%%orbit_type oscillator
% =======================================================================
