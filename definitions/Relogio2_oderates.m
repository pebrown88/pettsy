function R=f(t,y,p,force)

% keyboard
% assign the parameters
% Hello
a=p(1);% 12 "Per"
d=p(2);% 12 "Cry"
g=p(3);% 5 "Rev-Erb"
h=p(4);% 5 "Ror"
i11=p(5);% 12 "Bmal"
b=p(6);%  5 "Per-activation"
c=p(7); %  "Per-inhibition"
e=p(8);% 6 "Cry-activation rate"
f=p(9);% 4 "Cry-inhibition"
f1=p(10);% 1 "Cry-inhibition"
v=p(11);% 6  "Rev-Erb-activation"
w=p(12);% 2  "Rev-Erb-inhibition"
p1=p(13);% 6 "Ror-activation"
q=p(14);% 3 "Ror-inhibition"
n=p(15);% 2 "Bmal-activation"
m=p(16);% 5 "Bmal-inhibition"
y_10=p(17);% 0 "Per"
y_20=p(18);% 0 "Cry"
y_30=p(19);% 0 "Rev-Erb"
y_40=p(20);% 0 "Ror"
y_50=p(21);% 0 "Bmal"
d_z1=p(22);% 0.23 "CRYC"
d_z2=p(23);% 0.25 "PERC"
d_z3=p(24);% 0.6 "PERC*"
d_z4=p(25);% 0.2 "PERC*/CRYC"
d_z5=p(26); %0.2 "PERC/CRYC"
d_z6=p(27); %0.31 "REV-ERBC"
d_z7=p(28);% 0.3 "RORC"
d_z8=p(29);% 0.73 "BMALC"
d_y1=p(30);% 0.3 "Per"
d_y2=p(31);% 0.2 "Cry"
d_y3=p(32);% 2 "Rev-Erb"
d_y4=p(33); %0.2 "Ror"
d_y5=p(34); %1.6 "Bmal"
d_x1=p(35); %0.08 "CLOCK/BMALPD"
d_x2=p(36); % 0.06 "PER*N/CRYN **"
d_x3=p(37); % 0.09 "PERN/CRYN"
d_x5=p(38); % 0.17 "REV-ERBN"
d_x6=p(39); % 0.12 "RORN    ** -28 PD" 
d_x7=p(40); % 0.15 "BMALN"
kf_x1=p(41); % 2.3 "CLOCK/BMAL-complex formation [hour-1]"
kd_x1=p(42); % 0.01 "CLOCK/BMAL-complex dissociation [hour-1]"
kf_z4=p(43); % 1 "PERC*/CRYC-complex formation [(a.u.×hour)-1]"
kd_z4=p(44); % 1 "PERC*/CRYC-complex dissociation [hour-1]"
kf_z5=p(45); % 1 "PERC/CRYC-complex formation [(a.u.×hour)-1]"
kd_z5=p(46); % 1 "PERC/CRYC-complex dissociation [hour-1]"
ki_z4=p(47); % 0.2 "PERC*/CRYC"
ki_z5=p(48); % 0.1 "PERC/CRYC"
ki_z6=p(49); % 0.5 "REV-ERBC"
ki_z7=p(50); %  0.1 "RORC  ** 12.9 PD"
ki_z8=p(51); % 0.1 "BMALC ** 15.6 PD"
ke_x2=p(52); % 0.02 "PER*N/CRYN ** -21 PD"
ke_x3=p(53); % 0.02 "PERN/CRYN"
kph_z2=p(54); % 2 "PERC-phosphorylation rate"
kd_phz3=p(55); % 0.05 "PERC*-dephosphorylation rate"
k_p1=p(56); % 0.4 "PERC"
k_p2=p(57); % 0.26 "CRYC"
k_p3=p(58); % 0.37 "REV-ERBC"
k_p4=p(59); % 0.76 "RORC"
k_p5=p(60); %1.21 "BMALC"
k_t1=p(61); % 3 "Per-activation rate"
k_i1=p(62); % 0.9 "Per-inhibition rate"
k_t2=p(63); % 2.4 "Cry-activation rate"
k_i2=p(64); % 0.7 "Cry-inhibition rate"
k_i21=p(65); % 5.2 "Cry-inhibition rate"
k_t3=p(66); % 2.07 "Rev-Erb-activation rate"
k_i3=p(67); % 3.3 "Rev-Erb-inhibition rate"
k_t4=p(68); % 0.9 "Ror-activation rate"
k_i4=p(69);% 0.4 "Ror-inhibition rate PD"
k_t5=p(70);% 8.35 "Bmal-activation rate"
k_i5=p(71);% 1.94 "Bmal-inhibition rate"
V_1max=p(72);% 1 "Per"
V_2max=p(73);% 2.92 "Cry"
V_3max=p(74);% 1.9 "Rev-Erb"
V_4max=p(75);% 10.9 "Ror"
V_5max=p(76);% 1 "Bmal"
force(1)=force;
Omega=p(77);
% keyboard

% calcualte the rate vector
R=[...
kf_x1*y(4); %1
kd_x1*y(1);%2
d_x1*y(1);%3
ki_z4*y(15);%4
ke_x2*y(2);%5
d_x2*y(2);%6
ki_z5*y(16);%7
ke_x3*y(3);%8
d_x3*y(3);%9
ki_z8*y(19);%10
d_x7*y(4);%11
ki_z6*y(17);%12
d_x5*y(5);%13
ki_z7*y(18);%14
d_x6*y(6);%15
%V_1max*( (1+a*((y(1)/k_t1)^b))/( 1+(((y(2)+y(3))/k_i1)^c)*((y(1)/k_t1)^b)+((y(1)/k_t1)^b) ));%16
V_1max*( (1+a*((y(1)/k_t1)^b))/( 1+(((y(2)+y(3))/k_i1)^c)*((y(1)/k_t1)^b)+((y(1)/k_t1)^b) ));%16
d_y1*y(7);%17
%V_2max*( (1+d*((y(1)/k_t2)^e))/( 1+(((y(2)+y(3))/k_i2)^f)*((y(1)/k_t2)^e)+((y(1)/k_t2)^e) ))*(1/(1+((y(5)/k_i21)^f1)));%18
V_2max*( (1+d*((y(1)/k_t2)^e))/( 1+(((y(2)+y(3))/k_i2)^f)*((y(1)/k_t2)^e)+((y(1)/k_t2)^e) ))*(1/(1+((y(5)/k_i21)^f1)));%18
d_y2*y(8);%19
%V_3max*( (1+g*((y(1)/k_t3)^v))/( 1+(((y(2)+y(3))/k_i3)^w)*((y(1)/k_t3)^v)+((y(1)/k_t3)^v)));%20
V_3max*( (1+g*((y(1)/k_t3)^v))/( 1+(((y(2)+y(3))/k_i3)^w)*((y(1)/k_t3)^v)+((y(1)/k_t3)^v)));%20
d_y3*y(9);%21
%V_4max*( (1+h*((y(1)/k_t4)^p))/( 1+(((y(2)+y(3))/k_i4)^q)*((y(1)/k_t4)^p)+((y(1)/k_t4)^p) ));%22
V_4max*( (1+h*((y(1)/k_t4)^p1))/( 1+(((y(2)+y(3))/k_i4)^q)*((y(1)/k_t4)^p1)+((y(1)/k_t4)^p1) ));%22
d_y4*y(10);%23
%V_5max*( (1+i*((y(6)/k_t5)^n))/( 1+(((y(5)/k_i5)^m)+(y(6)/k_t5)^n)));%24
V_5max*( (1+i11*((y(6)/k_t5)^n))/( 1+(((y(5)/k_i5)^m)+(y(6)/k_t5)^n)));%24
d_y5*y(11);%25
k_p2*(y(8)+y_20);%26
kd_z4*y(15);%27
kd_z5*y(16);%28
%kf_z5*y(12)*y(13);%29
(kf_z5)*y(12)*y(13);%29
%kf_z4*y(12)*y(14);%30
(kf_z4)*y(12)*y(14);%30
d_z1*y(12);%31
k_p1*(y(7)+y_10);%32
kd_phz3*y(14)%33
kph_z2*y(13);%34
d_z2*y(13);%35
d_z3*y(14);%36
d_z4*y(15);%37
d_z5*y(16);%38
k_p3*(y(9) +y_30);%39
d_z6*y(17);%40
k_p4*(y(10)+y_40);%41
d_z7*y(18);%42
k_p5*(y(11)+y_50);%43
d_z8*y(19);%44
];