function dydt = f(t, y, p)

% forger model 

% this is the right part of the model
% it is used by make (program which performs symbolic calculations)

%  t - time on time step
%  y - system variables on time step
%  p - declaration string from make function

% declare all variables parameters and variables below to be symbolic variables 
eval(p);

% have changed ar to dar, ne to nex, and hot to hotp because of clash with
% built in functions

dydt=zeros(73,1);
dydt=[...
    bin*(y(71)+y(53)+y(57)+y(63)+y(67)+y(54)+y(58)+y(64)+y(68)+y(72)+y(55)+y(59)+y(65)+y(69)+y(56)+y(60)+y(66)+y(70))*(1-y(1))-unbin*y(1);
    binRv*y(16)*(1-y(2))-unbinRv*y(2);
    trRo*(1-y(1))*((1-y(2))^3)-tmc*y(3);
    tmc*y(3)-umR*y(4);
    trRt*(1-y(1))-tmc*y(5);
    tmc*y(5)-umR*y(6);
    trPo*((1-y(1))^5)+amp*force-tmc*y(7);
    tmc*y(7)-umPo*y(8);
    trPt*((1-y(1))^5)+amp*force-tmc*y(9);
    tmc*y(9)-umPt*y(10);
    trRv*((1-y(1))^3)-tmc*y(11);
    tmc*y(11)-umRv*y(12);
    tlrv*y(12)-arv*y(13)*y(13)+drv*y(15)-nl*y(13)+nex*y(14)-uRv*y(13);
    -Nf*arv*y(14)*y(14)+drv*y(16)+nl*y(13)-nex*y(14)-uRv*y(14);
    arv*y(13)*y(13)-drv*y(15)-nl*y(15)+nex*y(16)-2*uRv*y(15);
    Nf*arv*y(14)*y(14)-drv*y(16)+nl*y(15)-nex*y(16)-2*uRv*y(16);
    tlp*y(8)-ac*y(17)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))+dc*y(19)-upu*y(17);
    tlp*y(10)-ac*y(18)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))+dc*y(20)-upu*y(18);
    ac*y(17)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))-dc*y(19)-hoo*y(19)-upu*y(19);
    ac*y(18)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))-dc*y(20)-hotp*y(20)-upu*y(20);
    hoo*y(19)+ac*y(23)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))-dc*y(21)-up*y(21)-hto*y(21)-nl*y(21)+nex*y(47)-dar*y(21)*y(45)+dr*y(37)-dar*y(21)*y(46)+dr*y(39);
    hotp*y(20)+ac*y(24)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))-dc*y(22)-up*y(22)-ht*y(22)-nl*y(22)+nex*y(48)-dar*y(22)*y(45)+dr*y(38)-dar*y(22)*y(46)+dr*y(40);
    -ac*y(23)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))+dc*y(21)-up*y(23)-dar*y(23)*y(45)+dr*y(27)-dar*y(23)*y(46)+dr*y(29)-nl*y(23)+nex*y(49);
    -ac*y(24)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))+dc*y(22)-up*y(24)-dar*y(24)*y(45)+dr*y(28)-dar*y(24)*y(46)+dr*y(30)-nl*y(24)+nex*y(50);
    hto*y(21)-up*y(25)+ac*y(35)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))-dc*y(25)+nex*y(51)-dar*y(25)*y(45)+dr*y(41)-dar*y(25)*y(46)+dr*y(43);
    ht*y(22)-up*y(26)+ac*y(36)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))-dc*y(26)+nex*y(52)-dar*y(26)*y(45)+dr*y(42)-dar*y(26)*y(46)+dr*y(44);
    dar*y(23)*y(45)-dr*y(27)-ac*y(27)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))+dc*y(37)-nl*y(27)+nex*y(53);
    dar*y(24)*y(45)-dr*y(28)-ac*y(28)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))+dc*y(38)-nl*y(28)+nex*y(54);
    dar*y(23)*y(46)-dr*y(29)-ac*y(29)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))+dc*y(39)-nl*y(29)+nex*y(55);
    dar*y(24)*y(46)-dr*y(30)-ac*y(30)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))+dc*y(40)-nl*y(30)+nex*y(56);
    dar*y(35)*y(45)-dr*y(31)-ac*y(31)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))+dc*y(41)+nex*y(57);
    dar*y(35)*y(46)-dr*y(32)-ac*y(32)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))+dc*y(43)+nex*y(59);
    dar*y(36)*y(45)-dr*y(33)-ac*y(33)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))+dc*y(42)+nex*y(58);
    dar*y(36)*y(46)-dr*y(34)-ac*y(34)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))+dc*y(44)+nex*y(60);
    -ac*y(35)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))+dc*y(25)+nex*y(61)-dar*y(35)*y(45)+dr*y(31)-dar*y(35)*y(46)+dr*y(32)-up*y(35);
    -ac*y(36)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))+dc*y(26)+nex*y(62)-dar*y(36)*y(45)+dr*y(33)-dar*y(36)*y(46)+dr*y(34)-up*y(36);
    dar*y(21)*y(45)-dr*y(37)+ac*y(27)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))-dc*y(37)-nl*y(37)+nex*y(63)-hto*y(37);
    dar*y(22)*y(45)-dr*y(38)+ac*y(28)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))-dc*y(38)-nl*y(38)+nex*y(64)-ht*y(38);
    dar*y(21)*y(46)-dr*y(39)+ac*y(29)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))-dc*y(39)-nl*y(39)+nex*y(65)-hto*y(39);
    dar*y(22)*y(46)-dr*y(40)+ac*y(30)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))-dc*y(40)-nl*y(40)+nex*y(66)-ht*y(40);
    dar*y(25)*y(45)-dr*y(41)+ac*y(31)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))-dc*y(41)+nex*y(67)+hto*y(37);
    dar*y(26)*y(45)-dr*y(42)+ac*y(33)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))-dc*y(42)+nex*y(68)+ht*y(38);
    dar*y(25)*y(46)-dr*y(43)+ac*y(32)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))-dc*y(43)+nex*y(69)+hto*y(39);
    dar*y(26)*y(46)-dr*y(44)+ac*y(34)*(Ct-(y(19)+y(20)+y(21)+y(22)+y(25)+y(26)+y(37)+y(39)+y(38)+y(40)+y(41)+y(43)+y(42)+y(44)+y(47)+y(48)+y(51)+y(52)+y(63)+y(65)+y(64)+y(66)+y(67)+y(69)+y(68)+y(70)+y(73)))-dc*y(44)+nex*y(70)+ht*y(40);
    -dar*y(45)*y(23)-dar*y(45)*y(35)-dar*y(45)*y(21)-dar*y(45)*y(25)+dr*y(27)+dr*y(31)+dr*y(37)+dr*y(41)-dar*y(45)*y(24)-dar*y(45)*y(36)-dar*y(45)*y(22)-dar*y(45)*y(26)+dr*y(28)+dr*y(33)+dr*y(38)+dr*y(42)+tlr*y(4)-uro*y(45);
    -dar*y(46)*y(23)-dar*y(46)*y(35)-dar*y(46)*y(21)-dar*y(46)*y(25)+dr*y(29)+dr*y(32)+dr*y(39)+dr*y(43)-dar*y(46)*y(24)-dar*y(46)*y(36)-dar*y(46)*y(22)-dar*y(46)*y(26)+dr*y(30)+dr*y(34)+dr*y(40)+dr*y(44)+tlr*y(6)-urt*y(46);
    ac*Nf*y(49)*y(73)-dc*y(47)-hto*y(47)+nl*y(21)-nex*y(47)-dar*Nf*y(47)*y(71)+dr*y(63)-dar*Nf*y(47)*y(72)+dr*y(65)-up*y(47);
    ac*Nf*y(50)*y(73)-dc*y(48)-ht*y(48)+nl*y(22)-nex*y(48)-dar*Nf*y(48)*y(71)+dr*y(64)-dar*Nf*y(48)*y(72)+dr*y(66)-up*y(48);
    -ac*Nf*y(49)*y(73)+dc*y(47)-dar*Nf*y(49)*y(71)+dr*y(53)-dar*Nf*y(49)*y(72)+dr*y(55)+nl*y(23)-nex*y(49)-up*y(49);
    -ac*Nf*y(50)*y(73)+dc*y(48)-dar*Nf*y(50)*y(71)+dr*y(54)-dar*Nf*y(50)*y(72)+dr*y(56)+nl*y(24)-nex*y(50)-up*y(50);
    hto*y(47)+ac*Nf*y(61)*y(73)-dc*y(51)-nex*y(51)-dar*Nf*y(51)*y(71)+dr*y(67)-dar*Nf*y(51)*y(72)+dr*y(69)-up*y(51);
    ht*y(48)+ac*Nf*y(62)*y(73)-dc*y(52)-nex*y(52)-dar*Nf*y(52)*y(71)+dr*y(68)-dar*Nf*y(52)*y(72)+dr*y(70)-up*y(52);
    dar*Nf*y(49)*y(71)-dr*y(53)-ac*Nf*y(53)*y(73)+dc*y(63)+nl*y(27)-nex*y(53);
    dar*Nf*y(50)*y(71)-dr*y(54)-ac*Nf*y(54)*y(73)+dc*y(64)+nl*y(28)-nex*y(54);
    dar*Nf*y(49)*y(72)-dr*y(55)-ac*Nf*y(55)*y(73)+dc*y(65)+nl*y(29)-nex*y(55);
    dar*Nf*y(50)*y(72)-dr*y(56)-ac*Nf*y(56)*y(73)+dc*y(66)+nl*y(30)-nex*y(56);
    dar*Nf*y(61)*y(71)-dr*y(57)-ac*Nf*y(57)*y(73)+dc*y(67)-nex*y(57);
    dar*Nf*y(62)*y(71)-dr*y(58)-ac*Nf*y(58)*y(73)+dc*y(68)-nex*y(58);
    dar*Nf*y(61)*y(72)-dr*y(59)-ac*Nf*y(59)*y(73)+dc*y(69)-nex*y(59);
    dar*Nf*y(62)*y(72)-dr*y(60)-ac*Nf*y(60)*y(73)+dc*y(70)-nex*y(60);
    -ac*Nf*y(61)*y(73)+dc*y(51)-nex*y(61)-dar*Nf*y(61)*y(71)+dr*y(57)-dar*Nf*y(61)*y(72)+dr*y(59)-up*y(61);
    -ac*Nf*y(62)*y(73)+dc*y(52)-nex*y(62)-dar*Nf*y(62)*y(71)+dr*y(58)-dar*Nf*y(62)*y(72)+dr*y(60)-up*y(62);
    dar*Nf*y(47)*y(71)-dr*y(63)+ac*Nf*y(53)*y(73)-dc*y(63)+nl*y(37)-nex*y(63)-hto*y(63);
    dar*Nf*y(48)*y(71)-dr*y(64)+ac*Nf*y(54)*y(73)-dc*y(64)+nl*y(38)-nex*y(64)-ht*y(64);
    dar*Nf*y(47)*y(72)-dr*y(65)+ac*Nf*y(55)*y(73)-dc*y(65)+nl*y(39)-nex*y(65)-hto*y(65);
    dar*Nf*y(48)*y(72)-dr*y(66)+ac*Nf*y(56)*y(73)-dc*y(66)+nl*y(40)-nex*y(66)-ht*y(66);
    dar*Nf*y(51)*y(71)-dr*y(67)+ac*Nf*y(57)*y(73)-dc*y(67)-nex*y(67)+hto*y(63);
    dar*Nf*y(52)*y(71)-dr*y(68)+ac*Nf*y(58)*y(73)-dc*y(68)-nex*y(68)+ht*y(64);
    dar*Nf*y(51)*y(72)-dr*y(69)+ac*Nf*y(59)*y(73)-dc*y(69)-nex*y(69)+hto*y(65);
    dar*Nf*y(52)*y(72)-dr*y(70)+ac*Nf*y(60)*y(73)-dc*y(70)-nex*y(70)+ht*y(66);
    -dar*Nf*y(71)*y(49)-dar*Nf*y(71)*y(61)-dar*Nf*y(71)*y(47)-dar*Nf*y(71)*y(51)+dr*y(53)+dr*y(57)+dr*y(63)+dr*y(67)-dar*Nf*y(71)*y(50)-dar*Nf*y(71)*y(62)-dar*Nf*y(71)*y(48)-dar*Nf*y(71)*y(52)+dr*y(54)+dr*y(58)+dr*y(64)+dr*y(68)-uro*y(71);
    -dar*Nf*y(72)*y(49)-dar*Nf*y(72)*y(61)-dar*Nf*y(72)*y(47)-dar*Nf*y(72)*y(51)+dr*y(55)+dr*y(59)+dr*y(65)+dr*y(69)-dar*Nf*y(72)*y(50)-dar*Nf*y(72)*y(62)-dar*Nf*y(72)*y(48)-dar*Nf*y(72)*y(52)+dr*y(56)+dr*y(60)+dr*y(66)+dr*y(70)-urt*y(72);
    -ac*Nf*y(73)*y(49)-ac*Nf*y(73)*y(61)-ac*Nf*y(73)*y(53)-ac*Nf*y(73)*y(57)+dc*y(47)+dc*y(51)+dc*y(63)+dc*y(67)-ac*Nf*y(73)*y(50)-ac*Nf*y(73)*y(62)-ac*Nf*y(73)*y(54)-ac*Nf*y(73)*y(58)+dc*y(48)+dc*y(52)+dc*y(64)+dc*y(68)-ac*Nf*y(73)*y(55)-ac*Nf*y(73)*y(59)+dc*y(65)+dc*y(69)-ac*Nf*y(73)*y(56)-ac*Nf*y(73)*y(60)+dc*y(66)+dc*y(70)+up*y(47)+up*y(51)+up*y(48)+up*y(52);
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
%%%info 
%%%method matlab_stiff

% =======================================================================

