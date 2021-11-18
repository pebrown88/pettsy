function [ircs, del_per_and_x0,del_x0, sdxdm, phaseIRCs, bs_out, phaseIRCs_t] = getfirst(lc, prod,prod_phi, getdxdm, getidxdm, getbdxdm) %MD extended input to prodi and extended output to ircsphi


% DAR time can be saved by not dong the integral as this can also be got
% from the calculation of int_0^t(X(s,t).dF/dk.b(s)

% calculates first derivatives
%
% name - model name
% lc - periodic solution
% prod - Y(p)Y(s)^-1 product
% prod_phi - for phase IRCs
% getdxdm - output ircs
% getidxdm - output del_per_and_x) (dperdpar)
% getbdxdm - output del_x0 (dy0dpar)
%
% del_per_and_x0 - first derivative int_0^p X(s,p).df/dk(s)ds in field aligned coordinate system
% ircs - X(s,p).df/dk(s) at s = t(i) in field aligned coordinate system
% del_x0 - del_x0(k,:) is dx_0/dk_k in standard coords
% del_per_and_x0 is the parameter by variable matrix int_0^p X(t,p)dt
% del_per_and_x0 gives the change in period and x_0
% sdxdm is the
% time-series int_0^t X(s,p)ds which is a time by parameter by variable
% matrix - DAR

%edited by PEB 11/12/2006.
%Unused parameters removed 16/03/2007

% edited by DAR November 07

% PEB Nov 2012 added extra input flags to indicate exactly which outputs
% required.



%% -----------------------------------
% preparations
% -----------------------------------
global ModelForce CP

name = lc.name;
t = lc.sol.x;
y = lc.sol.y;
t0 = t(1);
y0 = y(1,:);
dim = length(y0);
pnum = length(lc.par);
sysjac = str2func([lc.name,'_jac']);%%MD
syspar = str2func([name,'_dp']);
system = str2func(lc.name); %MD for doing phases (scaler)

%outputs empty by default
ircs = [];  %required for irc and dxdm
phaseIRCs = cell(0); %will have dimension var * peaknum
bs_out =  cell(0);
phaseIRCs_t = [];
del_x0 = []; %This is bdxdm, required for dy0dpar and dgs
del_per_and_x0 = []; %This is idxdm, required for dperdpar and dgs
sdxdm = [];

 % right side of the expression
dia = eye(dim);
if ~lc.forced
    dia(1,1) = 0;       % this is the diagonal matrix diag(0,1,1,...,1)
end

if ~isempty(prod)
    % required for absolutely everything except phase ircs
    % arrays preallocation for speeding up
    yp = prod{1}; % X(0,p)
    ircs = zeros(length(t),dim,pnum);
    del_x0 = zeros(pnum,dim);
    del_per_and_x0 = zeros(pnum,dim);
    
    %% -----------------------------------
    % making field aligned coordinate change
    % -----------------------------------
    
    % find new basis
    if ~lc.forced
        % field aligned basis
        bas = getbasis(name, t0, y0, lc.par, ModelForce, CP);  % this is an orthogonal basis with the first vector the vectorfield at the strat point
    else
        bas = eye(dim); % used for periodically forced systems
    end
    
   
    trans = inv(bas);
    right = trans * yp * bas - dia; % this is B^{-1}X(p)B - diag
    % Y(p)=B^{-1}X(p)B is X(0,p) in the new
    % coord system
    if strcmp(lc.orbit_type,'signal')   % DAR probably not necessary
        right = eye(dim);
        trans = eye(dim);
    end
    
    %% -----------------------------------
    % calculating IRCs and related things
    % -----------------------------------
    if getdxdm
        display_message('    Calculating dxdm...');
        for i = 1:length(t)
            
            % derivative of the vector field by all parameters (matrix)
            dfdki = feval(syspar,t(i),y(i,:),lc.par, ModelForce, CP);      % the matrix df/dk at the ith time point
            
            % left side of the expression for all parameters (matrix)
            % prod{i} is X(t(i),p) - DAR
            left = -trans * prod{i} * dfdki';   % X(s,p).df/dk(s) at s = t(i) in new coords - a dim x params matrix
            
            ircs(i,:,:) = left; % dimensions are time, variable, parameter
        end
        display_message('done');
    end
    
    if getidxdm
        display_message('    Integrating idxdm...');
        % integrals by simpson integration of the curves
        % del_per_and_x0 is the parameter by variable matrix int_0^p X(s,p).df/dk(s)ds
        % sdxdm is the time-series int_0^t X(s,p)ds (sic) which is a time by parameter by variable matrix - DAR
        [del_per_and_x0, sdxdm] = bsimpson(ircs, t);
        display_message('done');
        
    end
    % testthing = del_per_and_x0; %DAR
    
    %% -----------------------------------
    % convert from field aligned coordinate system to original coords
    % -----------------------------------
    if getdxdm
        for i = 1:length(t)                     % for each time point
            dtemp = squeeze(ircs(i,:,:));       % X(s,p).df/dk(s) at s = t(i)
          %  stemp = squeeze(sdxdm(i,:,:));
            if rcond(right) < eps
                ircs(i,:,:) = pinv(right) * dtemp;
           %     sdxdm(i,:,:) = (pinv(right) * stemp')';
            else
                ircs(i,:,:) = right \ dtemp;        % equivalent to  inv(right) * X(s,p).df/dk(s)[new coords]; gives IRC
            %    sdxdm(i,:,:) = (right \ stemp')';
            end
        end
    end
    
    if getidxdm
        if rcond(right) < eps
            del_per_and_x0 = (pinv(right) * del_per_and_x0')';
        else
            del_per_and_x0 = (right \ del_per_and_x0')';              % equivalent to  inv(right) * int_0^p X(s,p).df/dk(s)ds [new coords]; A\B=inv(A)*B
        end
    end
    % del_per_and_x0 gives the change in period and x_0
    
    if getbdxdm
        if ~lc.forced
            for k=1:pnum
                % first integral is not convertes (dp/dpar)
                % vector of others is ircs with the first component equal to 0
                vec = [0, del_per_and_x0(k,2:end)];
                
                % in the new cordinates
                del_x0(k,:) = (bas * vec')';   % del_x0(k,:) is dx_0/dk_k in standard coords
            end
        else
            del_x0 = del_per_and_x0;
        end
    end
    
    %max difference in sdxdm in neurospora model dd compared to old function is
    %8.5265e-014
    %max proportional difference (abs(old-new)/old = 2.1224e-011
    %new method slightly slower 0.08s versus 0.05s fo rneurospora dd
    
    
end

if ~isempty(prod_phi)
    tic
    display_message('    Calculating phase IRCs...');
    peaks=[];
    %MD  this indentifies all peaks. inde keeps track of which variable the peak
    % belongs to. indk keeps track of which peak it is (e.g.is it first, second or, third peak)
    inde=[];
    indk=[];
    for i = 1:dim%reocrd number of peaks for each var here. needed for bs_graph
        if ~isempty(lc.peaks{i})
            peaks = [peaks lc.peaks{i}];
            tin=[];
            tink=[];
            tin(1:length(lc.peaks{i}))=i;
            tink(1:length(lc.peaks{i}))=1:length(lc.peaks{i});
            inde=[inde tin];%var num
            indk=[indk tink];%peak num for this var
        end
        phaseIRCs{i} = cell(1,length(lc.peaks{i}));
        bs_out{i} = cell(1,length(lc.peaks{i}));
        
    end
    %accessed like this phaseIRCs{var}{peaknum}
    %content will be a time*param matrix
    
    pt=[peaks];
   
    %MD: phase IRCs on 9000+ points.
    t_ext=[(t(1):(t(end)-t(1))/9000:t(end)),  peaks];
    %removing repeats and correcting ordering
    t_ext=unique(t_ext,'first')';
    %MD but for plotting only plot tspan+peak times.
    t_extB=[t; peaks'];t_extB=sort(t_extB);
    
    phaseIRCs_t = t_extB; %output parameter
    
    for j=1:length(pt) %j is the index of phases (phi_j)
        
        display_message(['    ' num2str(j)]);
        %  dphi_j/dk_m = -(df/dk(phi_j)+ J_j(phi_j).dy/dk_m(phi_j))/dotdoty_j where
        %  J_j is j-th row of jacobian matrix J.
        % and dotdoty_j= dotdoty(phi_j)
        %pkindx a list of peak times, contcatenated for all variables
        
        %dotdoty_j = df/dt + df/dy.doty = df/dt + J(phi_j).y = J(phi_j).y
        %df/dt=0 in our cases
        index_phi= find(t_ext==pt(j));y_ext=interp1(t,y,t_ext);%MD 09.09---evaluate jac and dydt at peak time j
        jacym=feval(sysjac,pt(j),y_ext(index_phi,:),lc.par,ModelForce,CP);% MD 09/09 %this is J(phi_j).y
        dydt = feval(system, pt(j),y_ext(index_phi,:), {lc.par, ModelForce, CP}); % MD 09/09
        denom=jacym*dydt;
        
        % we  calculate the phase IRCs as a sum of two parts:
        % bs)=-df/dk(phi_j)/dotdoty_j and
        % ircphi(i,:,:)=-J_j(phi_j).dy/dk(tt)/ dotdoty_j.
        % dy/dk(phi_j)= (I-X(phi_j,phi_j+p))^(-1)* int_(phi_j)^(phi_j+p)X(s,phi_j+p) dfdk(s)ds and this is equal to:
        %  dy/dk(phi_j)= int_(phi_j)^(phi_j+p) [(I-X(phi_j,phi_j+p))^(-1)*  X(s,phi_j+p) dfdk(s)]ds
        % so J_j(phi_j).dy/dk(tt)= int_(phi_j)^(phi_j+p)[J_j(phi_j)*((I-X(phi_j,phi_j+p))^(-1)*  X(s,phi_j+p) dfdk(s)]/ dotdoty_s ds
        % in what follows, we calculate the terms inside the integral sign
        %ircphiA(i,:,:)=((I-X(phi_j,phi_j+p))^(-1)*  X(s,phi_j+p) dfdk(s)
        %ircphi(i,:,:)= J_j(phi_j)*ircphiA(i,:,:)/ dotdoty_s
        
        tmpIRCs = zeros(length(t_ext), pnum);
        varnum = inde(j);
        peaknum = indk(j);
        bs = [];
        
        for i = 1:length(t_ext)
            
            dfdki = feval(syspar,t_ext(i),y_ext(i,:),lc.par, ModelForce, CP); %MD 09.09
            %first calculate  -df/dk(phi_j)/dotdoty_j.
            if i== index_phi% MD 09/09
                %found a peak time
                %bs measures partial derivative  df_j/dk_i,
                % == (dy/dp) / ((dy/dy)* (dy/dt))
                %so if k_i  parameter doesn't occur in j-th ODE (f_j) then df_j/dk_i=0.
                
                %  if (pt(j)<=lc.par(end)) && (pt(j)>=lc.par(end-1))
                %peak falls between dawn and dusk
                bs.y=(dfdki(:,varnum))/denom(varnum,:); %bs=df/dk(phi_j)/ dotdoty_j
                % else
                %    bs.y=zeros(pnum, 1);
                %If phi_j outside the time interval where the force is 'on' then take bs=0.
                %end
                bs.t = pt(j); %record time of this peak
            end
            
            % calculate terms of J_j(phi_j).dy/dk_m(phi_j)/dotdoty_j ( we need to
            % integrate them later. see like 210).
            yp=prod_phi{index_phi,j};%MD 09/09 %X(phi_j,phi_j+p)
            right1=yp-dia; %X(phi_j,phi_j+p)-I
            
            ircsphiA=prod_phi{i,j}*dfdki'; %X(s,phi_j+p)*df/dk(phi_j) where s=t(i);
            ircsphiA =-right1\ircsphiA; % [(I-X(phi_j,phi_j+p))^(-1)* X(s,phi_j+p)*dfdk(s)]  where s=t(i)=t(i) (term under the integral sign, line 151.
            
            %This is a time*param matrix for the nth peak of the mth variable
            tmpIRCs(i,:) = -(jacym(varnum,:)*ircsphiA)/denom(varnum,:);
            
        end
        bs_out{varnum}{peaknum} = bs;
        if peaknum == 1
           display_message('',1); 
        end
        %done for this peak
        phaseIRCs{varnum}{peaknum} = interp1(t_ext,tmpIRCs, t_extB);
        
        %Need to integrate phase IRCs (tmpIRCs) from phi to phi+p. Let h be the distance between two consecutive points. tmpIRCs
        %written above are for time points p to (phi-h)+p  and then phi to p.
        %They are discontinuous at point phi.
        %Need to rewrite by putting phi to p time points first, then p+h to
        %(phi-h)+p. Also need to add on the point for phi+p.
        %need to generate phase IRC for point phi+p:
        dfdki = feval(syspar,t_ext(index_phi),y_ext(index_phi,:),lc.par, ModelForce, CP);
        % this is the phase IRCs for point for phi+p.
        tempIRCs_extra= -(jacym(inde(j),:)*(-right1\dfdki'))/denom(varnum,:);
        
        %put the time points in correct order: phi to p, p+h to p+(phi-h) and phi+p.
        %relabel this from 0 to p.
        t_shuffle=[t_ext(index_phi:end,:)-pt(j); t_ext(end)+t_ext(2:index_phi-1,:)-pt(j);t_ext(end)];
        % corresponding phase IRCs
        tmpIRCs_shuffle=[tmpIRCs(index_phi:end,:);tmpIRCs(2:index_phi-1,:); tempIRCs_extra];
        
        %find phase IRCs on an equal time space
        tmpIRCs_equal=interp1(t_shuffle, tmpIRCs_shuffle,t);
        %integrate phase IRCs
        %integral_PhaseIRCs{varnum}{peaknum}=bsimpson(tmpIRCs_equal,t);
        
    end
    tt=toc;
    display_message('    done');
    str = sprintf('    Phase IRCs have been calculated in %.*f seconds',2,tt);
    display_message(str);
    
end
