%This file is a copy of that used to create the model at 15-Oct-2013 15:41:51
%If you wish to re-make the model you must edit the file in /Users/mdomijan/Desktop/SASSY_Oct/models/definitions
%Editing this one will have no effect

%This file is a copy of that used to create the model at 29-Aug-2012 18:49:42
%If you wish to re-make the model you must edit the file in /Users/mdomijan/Downloads/TheoryGUIs5_distrib/TheoryGUIs5_distrib/models/definitions/
%Editing this one will have no effect

%This file is a copy of that used to create the model at 31-Jan-2012 16:57:45
%If you wish to re-make the model you must edit the file in /Users/mdomijan/Downloads/TheoryGUIs5_distrib/TheoryGUIs5_distrib/models/definitions/
%Editing this one will have no effect

function dydt = f(t,y,p)

eval(p);

dydt=[
%1 LHY mRNA
(q1*force*y(4)+n1*g1^2/(g1^2+(y(6)+y(8)+y(10)+y(12))^2))-y(1)*(m1*force+m2*(1-force));

%2 LHY protein 
(p2*(1-force)+p1*force)*y(1)-m3*y(2)-p3*y(2)^2/(y(2)^2+g3^2);

%3 LHY protein modified
p3*y(2)^2/(y(2)^2+g3^2)-m4*y(3);
 

%4 protein P
 p7*(1-force)*(1-y(4))-m11*y(4)*force;
 
 %5 PRR9 mRNA 
 (q3*force*y(4)+g8/(g8+y(24))*(n4+n7*y(2)^2/(y(2)^2+g9^2)))-m12*y(5);
 
%6 PRR9
 p8*y(5)-(m13*force+m22*(1-force))*y(6);
 
%7 PRR7 mRNA
(n8*(y(2)+y(3))^2/(g10^2+(y(2)+y(3))^2)+n9*y(6)^2/(g11^2+y(6)^2))-m14*y(7);

%8 PRR7 
 p9*y(7)-y(8)*(m15*force+m23*(1-force));
 
%9 NI mRNA
(n10*y(3)^2/(g12^2+y(3)^2)+n11*y(8)^2/(g13^2+y(8)^2))-m16*y(9);

%10 NI
 p10*y(9)-(m17*force+m24*(1-force))*y(10);
 
 %11 TOC1 mRNA
 n2*g4/(g4+y(24))*(g5^2/(g5^2+y(2)^2))-y(11)*m5;
 
 %12 TOC1 
 p4*y(11)-m8*y(12)-(m6*force+m7*(1-force))*y(12)*(p5*y(25)+y(26));
 
 %13 E4 mRNA
n13*(g6^2/(g6^2+y(2)^2))*g2/(g2+y(24))-y(13)*m34;

%14 E4 
p23*y(13)-m35*y(14)-p25*y(17)*y(14)+p21*(p25*y(14)*y(17)/(p26*y(19)+p21+m36*y(21)+m37*y(22)));

%15 E3 mRNA

 n3*g16^2/(g16^2+y(2)^2)-m26*y(15);
%16 E3 cytoplasmic protein
   p16*y(15)-m9*y(16)*y(20)-p17*y(16)*y(28)-p19*y(16)+p20*y(17);
 
%17 E3 nuclear protein
 p19*y(16)-p20*y(17)-m29*y(17)*y(21)-m30*y(17)*y(22)-p25*y(17)*y(14)+p21*(p25*y(14)*y(17)/(p26*y(19)+p21+m36*y(21)+m37*y(22)))-p17*y(17)*(p28*y(28)/(p29+m19+p17*y(17)));


%18 LUX mRNA
n13*(g6^2/(g6^2+y(2)^2))*g2/(g2+y(24))-y(18)*m34;
    
%19 LUX
 p27*y(18)-m39*y(19)-p26*y(19)*(p25*y(14)*y(17)/(p26*y(19)+p21+m36*y(21)+m37*y(22)));

%20 COP1 cytoplasmic
n5-p6*y(20)-y(20)*m27*(1+p15*force);
   
%21 COP1 night
p6*y(20)-n6*force*y(4)*y(21)-n14*y(21)-y(21)*m27*(1+p15*force);

%22 COP1 day
(n14*y(21)+n6*force*y(4)*y(21))-m31*(1+m33*(1-force))*y(22);

 %23 EGc
p17*y(16)*y(28)-m9*y(23)*y(20)-p18*y(23)+p31*((p18*y(23)+p17*y(17)*(p28*y(28)/(p29+m19+p17*y(17))))/(m9*y(21)+m10*y(22)+p31));
   
%24 ELF4-ELF3-LUX
p26*y(19)*(p25*y(14)*y(17)/(p26*y(19)+p21+m36*y(21)+m37*y(22)))-m36*y(24)*y(21)-m37*y(24)*y(22)-y(24)*m32*(1+p24*force*(((p18*y(23)+p17*y(17)*(p28*y(28)/(p29+m19+p17*y(17))))/(m9*y(21)+m10*y(22)+p31))+(p28*y(28)/(p29+m19+p17*y(17))))^2/(g7^2+(((p18*y(23)+p17*y(17)*(p28*y(28)/(p29+m19+p17*y(17))))/(m9*y(21)+m10*y(22)+p31))+(p28*y(28)/(p29+m19+p17*y(17))))^2));

%25 ZTL 
p14-m20*y(25)-p12*force*y(25)*y(28)+p13*y(26)*(1-force);

%26 ZG 
p12*force*y(25)*y(28)-p13*y(26)*(1-force)-m21*y(26);

%27 GI mRNA
(q2*force*y(4)+g15^2/(g15^2+y(2)^2)*g14/(g14+y(24))*n12)-y(27)*m18;

%28 GI cytoplasmic
 p11*y(27)-m19*y(28)-p12*force*y(25)*y(28)+p13*y(26)*(1-force)-p17*y(16)*y(28)-p28*y(28)+p29*(p28*y(28)/(p29+m19+p17*y(17)))
 

% p22-m38*y(21)*y(22)-m25*y(21)*y(21);
% 
% p30-m28*y(22)*y(21);


];
