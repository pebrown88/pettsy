%This file is a copy of that used to create the model at 26-Apr-2009 14:58:17
%If you wish to re-make the model you must edit the file in /Users/West/Documents/MATLAB/Copy of TheoryGUIs5/models/definitions/
%Editing this one will have no effect

function dydt = f(t, y, p)


% declare all variables parameters and variables below to be symbolic variables 
eval(p); 

dydt=[...
kd1a*y(3) - ka1a*y(1)*y(2) - ki1*y(1) + c5a*y(3) + ke1*y(4) + kt2a*y(14); %Free Cytoplasmic NFkB
kd1a*y(3) - ka1a*y(1)*y(2) - ki3a*y(2) + ke3a*y(5) - c4a*y(2) + c2a*y(7) - kc1a*y(9)*y(2); %Free Cytoplasmic IkBa
ka1a*y(1)*y(2) - kd1a*y(3) + ke2a*y(6) - c5a*y(3) - kc2a*y(9)*y(3); %Cytoplasmic NFkB-IkBa
kd1a*y(6) - ka1a*y(4)*y(5) + kv*ki1*y(1) - kv*ke1*y(4); %Free nuclear NFkB
kd1a*y(6) - ka1a*y(4)*y(5) + kv*ki3a*y(2) - kv*ke3a*y(5) - c4a*y(5); %Free nuclear IkBa
ka1a*y(4)*y(5) - kd1a*y(6) - kv*ke2a*y(6); %Nuclear NFkB-IkBa
c1a*(y(4)^h/(y(4)^h + k^h)) - c3a*y(7); %IkBa transcription
kp*y(10)*(kbA20/(kbA20 + y(12)*force)) - force*ka*y(8); %IKKn
force*ka*y(8) - ki*y(9); %Ikka
ki*y(9) - kp*y(10)*(kbA20/(kbA20 + y(12)*force)); %IKKi
c1*(y(4)^h/(y(4)^h + k^h)) - c3*y(11); %A20 transcription
c2*y(11) - c4*y(12); %A20
kc1a*y(9)*y(2) - kt1a*y(13); %Phosphorylated IkBa
kc2a*y(9)*y(3) - kt2a*y(14); %Phosphorylated NFkB-IkBa
(1 + y(15))*(ki1*y(1) - ke1*y(4) - ke2a*y(6))/(y(1) + y(3) + y(14))
];

% p = [kv,tv,kp,ka,ki,ka1a,kd1a,kc1a,kc2a,kt1a,kt2a,c4a,c5a,ki1,ke1,ke2a,ki3a,ke3a,h,k,c1a,c2a,c3a,c1,c2,c3,c4,kbA20];

% varnames=
% ['NFkB             ';
% 'IkBa              ';
% 'IkBa:NFkB         ';
% 'nNFkB             ';
% 'nIkBa             ';
% 'nNFkB:IkBa        ';
% 'tIkBa             ';
% 'IKKn              ';
% 'IKKa              ';
% 'IKKi              ';
% 'tA20              ';
% 'A20               ';
% 'pIkBa             ';
% 'pIkBa:NFkB        ';
% ttNFkB      ]        

% =======================================================================
% the information below is written into the file name.info and is used to
% communicate whether the system is an oscillator or a signalling system,
% which ode solver method to use, the end time is teh system is a signal,
% the force type used from the file /shared/theforce and wherther the
% solutions should be non-negative or not. The %%% before
% each line is needed. Using %%%info lines it can also be used to store away
% other information. In this case the title of the model and the initial
% condition that is used.
%%%info 2feedback NF-kB model
%%%tend 36000
%%%positivity non-negative
%%%method matlab_stiff
%%%orbit_type signal
%force_type 60
% =======================================================================

