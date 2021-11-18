% Adapting Giorgos' approach to create the Relogio clock model from Denise's thesis
%, Maria Veretennikova, Nov. 2020
function dydt = f(t, y, p)
 
eval(p); 

dydt = [ 
kf_x1*y(4)- kd_x1*y(1)-d_x1*y(1)+0*force;  %Clock/Bmal1 complexes
ki_z4*y(15)- ke_x2*y(2)-d_x2*y(2); %PER*N/CRYN    
ki_z5*y(16)-ke_x3*y(3)-d_x3*y(3); %PERN/CRYN
ki_z8*y(19)+kd_x1*y(1)-kf_x1*y(4)-d_x7*y(4); %BMAL_N
ki_z6*y(17)-d_x5*y(5); %Rev-erb (Nuclear)
ki_z7*y(18)- d_x6*y(6); %Ror (nuclear)
V_1max*( (1+a*((y(1)/k_t1)^b))/( 1+(((y(2)+y(3))/k_i1)^c)*((y(1)/k_t1)^b)+((y(1)/k_t1)^b) ))-d_y1*y(7); %Per
V_2max*( (1+d*((y(1)/k_t2)^e))/( 1+(((y(2)+y(3))/k_i2)^f)*((y(1)/k_t2)^e)+((y(1)/k_t2)^e) ))*(1/(1+((y(5)/k_i21)^f1)))-d_y2*y(8); %Cry
V_3max*( (1+g*((y(1)/k_t3)^v))/( 1+(((y(2)+y(3))/k_i3)^w)*((y(1)/k_t3)^v)+((y(1)/k_t3)^v)))-d_y3*y(9);% Rev-erb
V_4max*( (1+h*((y(1)/k_t4)^p1))/( 1+(((y(2)+y(3))/k_i4)^q)*((y(1)/k_t4)^p1)+((y(1)/k_t4)^p1) ))-d_y4*y(10); %Ror
V_5max*( (1+i11*((y(6)/k_t5)^n))/( 1+(((y(5)/k_i5)^m)+(y(6)/k_t5)^n)))-d_y5*y(11); %Bmal
k_p2*(y(8)+y_20)+kd_z4*y(15)+kd_z5*y(16)-kf_z5*y(12)*y(13)-kf_z4*y(12)*y(14)-d_z1*y(12); %Cry(Cytoplasm)
k_p1*(y(7)+y_10)+kd_z5*y(16)+kd_phz3*y(14)-kf_z5*y(13)*y(12)-kph_z2*y(13)-d_z2*y(13); %Per (Cytoplasm)
kph_z2*y(13)+kd_z4*y(15)-kd_phz3*y(14)-kf_z4*y(14)*y(12)-d_z3*y(14); %Per* (Cytoplasm)
kf_z4*y(12)*y(14)+ke_x2*y(2)-ki_z4*y(15)-kd_z4*y(15)-d_z4*y(15); %PERC*/CRYC 
kf_z5*y(12)*y(13)+ke_x3*y(3)-ki_z5*y(16)-kd_z5*y(16)-d_z5*y(16); % PERC/CRYC    
k_p3*(y(9) +y_30)-ki_z6*y(17)-d_z6*y(17); %Rev-erb (cytoplasmic)
k_p4*(y(10)+y_40)-ki_z7*y(18)-d_z7*y(18); %Ror (cytoplasmic)
k_p5*(y(11)+y_50)-ki_z8*y(19)-d_z8*y(19); %Bmal (cytoplasmic)
];

%dim

% =======================================================================
% the information below is written into the file name.info and is used to
% communicate whether the system is an oscillator or a signalling system,
% which ode solver method to use, the end time is teh system is a signal,
% the force type used from the file /shared/theforce and wherther the
% solutions should be non-negative or not. The %%% before
% each line is needed. Using %%%info lines it can also be used to store away
% other information. In this case the title of the model and the initial
% condition that is used.
%%%info Relogio clock model
%%%orbit_type oscillator
%%%tend 100
%%%positivity non-negative
%%%method ode15s
%%%force photo 6 18
% =======================================================================



