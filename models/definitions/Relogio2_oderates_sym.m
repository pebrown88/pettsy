function R=f(t,y,p, force)


eval(p);

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
(kf_z5)*y(12)*y(13);%29
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
