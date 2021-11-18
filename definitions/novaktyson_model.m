function dydt = f(t, y, p)
   
% Novak-Tyson model
% Novak-Tyson cell cycle model, described in J. theor. Biol. (1998) 195,
% 69-85

% State names and ordering:
% 
% statevector(1): Cyclin
% statevector(2): YT
% statevector(3): PYT
% statevector(4): PYTP
% statevector(5): MPF
% statevector(6): Cdc25P
% statevector(7): Wee1P
% statevector(8): IEP
% statevector(9): APCstar
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cyclin = statevector(1);
% YT = statevector(2);
% PYT = statevector(3);
% PYTP = statevector(4);
% MPF = statevector(5);
% Cdc25P = statevector(6);
% Wee1P = statevector(7);
% IEP = statevector(8);
% APCstar = statevector(9);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ka = 0.1;
% Kb = 1;
% Kc = 0.01;
% Kd = 1;
% Ke = 0.1;
% Kf = 1;
% Kg = 0.01;
% Kh = 0.01;
% k1 = 0.01;
% k3 = 0.5;
% V2p = 0.005;
% V2pp = 0.25;
% V25p = 0.017;
% V25pp = 0.17;
% Vweep = 0.01;
% Vweepp = 1;
% kcak = 0.64;
% kpp = 0.004;
% kas = 2;
% kbs = 0.1;
% kcs = 0.13;
% kds = 0.13;
% kes = 2;
% kfs = 0.1;
% kgs = 2;
% khs = 0.15;

% original ic plus time 0.017200 0.011600 0.000900 0.019800 0.073000 0.949900 0.949900 0.242000 0.313200 0

eval(p);    
   
dydt = [ 
                                                                                k1-(V2p+y(9)*(V2pp-V2p))*y(1)-k3*y(1);
 kpp*y(5)-(Vweepp+y(7)*(Vweep-Vweepp))*y(2)-kcak*y(2)-(V2p+y(9)*(V2pp-V2p))*y(2)+(V25p+y(6)*(V25pp-V25p))*y(3)+k3*y(1);
         (Vweepp+y(7)*(Vweep-Vweepp))*y(2)-(V25p+y(6)*(V25pp-V25p))*y(3)-kcak*y(3)-(V2p+y(9)*(V2pp-V2p))*y(3)+kpp*y(4);
         (Vweepp+y(7)*(Vweep-Vweepp))*y(5)-kpp*y(4)-(V25p+y(6)*(V25pp-V25p))*y(4)-(V2p+y(9)*(V2pp-V2p))*y(4)+kcak*y(3);
         kcak*y(2)-kpp*y(5)-(Vweepp+y(7)*(Vweep-Vweepp))*y(5)-(V2p+y(9)*(V2pp-V2p))*y(5)+(V25p+y(6)*(V25pp-V25p))*y(4);
                                                                      kas*y(5)*(1-y(6))/(1+Ka-y(6))-kbs*y(6)/(Kb+y(6));
                                                                      kes*y(5)*(1-y(7))/(1+Ke-y(7))-kfs*y(7)/(Kf+y(7));
                                                                      kgs*y(5)*(1-y(8))/(1+Kg-y(8))-khs*y(8)/(Kh+y(8));
                                                                      kcs*y(8)*(1-y(9))/(1+Kc-y(9))-kds*y(9)/(Kd+y(9));
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
% =======================================================================