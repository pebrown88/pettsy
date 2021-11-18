function [results] = theory_oscillator(lc, args)

% outputs are 
% results.gs, dx_i/dk_j (t)
% results.ts times 
% results.dxdm, the IRCs 
% results.sds the SVD structure 

%called by gettheory.m

global odetol gui solver stiff_problem;

%gui needs to be global. It is set here and called in 'display_message'

%% ---------------------------------------------------------------------
% dealing with options
% ---------------------------------------------------------------------

% For oscillators

% 'yp'          yp matrix
% 'dy0dpar'     dy0dpar
% 'dxdm'        dxdm
% 'irc'         ircs for unforced (requires dxdm), phase ircs for forced

% for unforced oscillators

% 'dperdpar'    dperdpar, (requires irc)

% For all models

% 'dgs'         periodic_dgs nonper_dgs
% 'dphasedpar'  dtrdpar, dpkdpar (require dgs)
% 'dypkdpar'    dytr, dypk (require dgs)

solver = lc.solver{1};
stiff_problem = lc.solver{2}; %used by runCVode

gui = [];
allow_reject_Xst = 0;
getyp = 0;
getdy0dpar = 0;
getdxdm = 0;
getirc = 0;
getdperdpar = 0;
getdgsoutput = 0;
getdphasedpar = 0;
getdypkdpar = 0;

for i=1:length(args)
    if isa(args{i},'function_handle')
        gui = args{i};
    else
        eval([args{i} '=1;']);
    end
end

%initialise results structure 

results.date = date;
if getirc || getdxdm || getdgsoutput
    results.t = lc.sol.x;
end
 
str = sprintf('Running using solver %s',lc.solver{1});
display_message(str);

%% ---------------------------------------------------------------------
% calculation of the derivatives of the solutions
% ---------------------------------------------------------------------
t = lc.sol.x;
y = lc.sol.y;

tol.int = odetol;

y0 = y(1,:);
dim = length(y0);
% adjoint function calculation


%% ---------------------------------------------------------------------
% calculating X(t)
% ---------------------------------------------------------------------
% % % tic
% % % solX = calc_Xt(lc,[lc.odesol.x(1) lc.odesol.x(end)],par)
% % % tt = toc
% % % str = sprintf('X(t), 0< t <%.*f has been calculated in %.*f seconds',2,per,2,tt);
% % % disp(str);
% % % if ~isempty(gui)
% % %     feval(gui,'prog', str, 1/7);
% % % end

%% ---------------------------------------------------------------------
% calculating int_0^t X(s,t)b(s)ds
% ---------------------------------------------------------------------
% % % tic
% % % solint2t = calc_int2t(lc.name,[lc.odesol.x(1) lc.odesol.x(end)],par);
% % % tt = toc
% % % z_solint2t=zeros(length(solint2t.x),dim,length(par));
% % % for i=1:dim
% % %     for j=1:length(par)
% % %         z_solint2t(:,i,j)=solint2t.y((j-1)*dim+i,:);
% % %     end
% % % end
% % % time_solint2t=solint2t.x;
% % % 
% % % str = sprintf('dxi/dparams has been calculated in %.*f seconds',2,tt);
% % % disp(str);
% % % if ~isempty(gui)
% % %     feval(gui,'prog', str, 1/7);
% % % end

%% ---------------------------------------------------------------------
% calculating stuff for IRCs
% ---------------------------------------------------------------------
start_t = clock;
display_message('Calculating X(s,t)s...');
getProd = any([getyp getdy0dpar getdxdm getdgsoutput getdphasedpar getdypkdpar (~lc.forced && getirc) (~lc.forced && getdperdpar)]);
getProdphi = (lc.forced && getirc);
[prod,prod_phi, fsols,tb] = product_bw(lc, allow_reject_Xst, getProd, getProdphi); %lc must be sol structure with evenly space t
% calculates z = Y(p)Y(s)^-1; prod is value of z for s=t(i)

%MD new_product_bw_mod calculates prodi{i}= X(s,phi_i+tau) where s runs from phi_i to phi_i+tau. Here i is the
%i-th variable, phi_i is the phase of the i-th variable. These matrices are needed to calculate the phase IRCs.
display_message('done');
tt = etime(clock, start_t);
str = sprintf('X(s,t)s have been calculated in %.*f seconds',2,tt);
display_message(str);
if getyp
    yp = prod{1};
end

% calculation of the stuff for IRCs and for the dx_0/dk_j

%if prod is empty, dxdm, idxdm, bdxdm and sdxdm will all be empty
%if prod_phi is empty, dphidm, bs_graph, and phaseIRCs_t
%will all be empty

%dxdm needed for ircs, idxdm, dperdpar, dgs, dphasedpar, dypkdpar
%idxdm needed for bdxdm  dy0dpar dperdpar, dgs, dphasedpar, dypkdpar
%bdxdm needed for dy0dpar and dgs, dphasedpar, dypkdpar
%sdxdm needed for dgs (removed)

getbdxdm = any([getdy0dpar getdgsoutput getdphasedpar getdypkdpar]);
getidxdm = getbdxdm || (~lc.forced && getdperdpar);
getdxdm_tmp = getidxdm || (~lc.forced && getirc) || getdxdm;
%use tmp variable as user might not have request this, but needed anyway if
%irc,dgs,phases or dy0dpar requested

if (getbdxdm || getidxdm || getdxdm_tmp || getProdphi)
    display_message('Calculating derivatives...',1);
    tmp_t = clock;
    [dxdm, idxdm, bdxdm, sdxdm, dphidm, bs_graph, phaseIRCs_t] = getfirst(lc, prod, prod_phi, getdxdm_tmp, getidxdm, getbdxdm);
    tt = etime(clock, tmp_t);
    % dxdm is X(t(i),p) in adjusted coordinates - DAR
    % idxdm is the parameter by variable matrix int_0^p X(t,p)b(t)dt in adjusted field-aligned coordinates
    % sdxdm is the time-series int_0^t X(s,p)ds which is a time by parameter by variable in adjusted field-aligned coordinates
    % bdxdm is idxdm in original coordinates

    %For unforced oscillators, idxdm gives dperdpar
    %for forced oscillators, bdxdm is the same as idxdm
    display_message('done');
    str = '';
    if getdxdm
        str = 'dxdm ';
    end
    if getirc
        str = [str 'ircs '];
    end
    if getdperdpar
        str = [str 'dper/dpar '];
    end
    if getdy0dpar
        str = [str 'dy_0/dpar ']; 
    end
    if ~strcmp(str, '')
        str = sprintf('%s calculated in %.*f seconds',str,2,tt);
        display_message(str);
    end
else
    dxdm =[]; idxdm=[]; bdxdm=[]; sdxdm=[]; dphidm=[]; bs_graph=[];  phaseIRCs_t=[];
end

% derivatives of the limit cycle
dphi =[]; dxdks = [];
if getdgsoutput || getdphasedpar || getdypkdpar || getProdphi 
    %this last term indicates phase ircs required. This requires getdgs and get phases to
    %calculate the integrals
    if getdgsoutput
        display_message('Calculating limit cycle derivatives...');
         tmp_t = clock;
    end
    %periodic_gs is identical to gs for forced models
    display_message('',1);
    [periodic_gs, gs, ts] = getdgs(lc, idxdm, bdxdm, sdxdm, tol.int, fsols,tb);  %scaled means scaled by parameter
    if getdgsoutput
        display_message('done');
        tt = etime(clock, tmp_t);
        str = sprintf('Limit cycle derivatives have been calculated in %.*f seconds',2,tt);
        display_message(str);
    end

    % ---------------------------------------------------------------------
    % calculate the phase derivatives
    % ---------------------------------------------------------------------
    
    if getdphasedpar || getdypkdpar || getProdphi
        if getdphasedpar || getdypkdpar
            display_message('Performing phase derivative analysis...');
            tmp_t = clock;
        end
        %getProdPhi indicates dphi.peaks needed for phase ircs, even if
        %troughs not needed when getdphasedpar = 0
        [dphi, dxdks] = getphases(lc, gs, getdphasedpar , getdypkdpar, getProdphi);
        if getdphasedpar || getdypkdpar
            tt = etime(clock, tmp_t);
            display_message('done');
            str = sprintf('Phase derivatives have been calculated in %.*f seconds',2,tt);
            display_message(str);
            display_message('Note this analysis is only valid if the force is flat at the phase in question');
        end
    end
end


%% ---------------------------------------------------------------------
% see old version of new_theory for what was below DAR
% calcsecond has been removed and the prc stuff DAR
% ---------------------------------------------------------------------


%% ---------------------------------------------------------------------
% adjust dxdm, idxdm, bdxdm, dphi, dxdks so that they are for the scaled
% parameters log k_j DAR
% ---------------------------------------------------------------------

display_message('Processing outputs...', 1);
%change derivative with respect to k to derivaive with respect to log_k
[dxdm, dphidm, idxdm, bdxdm, dphi, dxdks, bs_graph ] = parscale(dxdm, dphidm, idxdm, bdxdm, dphi, dxdks, bs_graph, lc.par, length(t));


%% ---------------------------------------------------------------------
% allocate the results structure according to the flags set
% ---------------------------------------------------------------------

if getyp
    results.yp = yp;
end
if getdxdm
    results.dxdm = dxdm;
end
if getdperdpar
    results.dperdpar = idxdm(:,1); %first derivatives in field aligned coordinate system
    %originally dTau/dpar, but parscale makes it dTau/dlog(par)
end
if getdy0dpar
    results.dy0dpar = bdxdm;            %first derivatives in standard coordinate system
end
% these above are for log k_j

if getirc
    if lc.forced
        %phase ircs for forced oscillator
        ircphi = cell(size(dphidm));
        for var =1:length(dphidm)
            vardata = cell(1, length(dphidm{var}));
            maxAdvances_all = [];
            maxDelays_all = [];
            integrals_all = [];
            for peak = 1:length(dphidm{var})
                % t*param
                one_irc.data = dphidm{var}{peak};
                one_irc.bs = bs_graph{var}{peak};
                peaks = zeros(1, size(one_irc.data,2));
                troughs = zeros(1, size(one_irc.data,2));
                for k=1:size(one_irc.data,2)
                    %for each parameter
                    peaks(k) = max(one_irc.data(:,k));
                    troughs(k) = min(one_irc.data(:,k));
                end
                one_irc.integrals = dphi.peaks{var}(:, peak)';%row vector,one element for each par
                %We  use peaks as phase irc refers to phase change of peak so
                %we need to add affect of a perturbation at the time of the
                %peak (bs point) to area under curve to get phase change
                %caused by a permamant parameter perturbation. dphi.peaks
                %is the sum of the area and bs point
                    
                one_irc.maxAdvances = peaks;
                one_irc.maxDelays = troughs;
                vardata{peak} = one_irc;
                if length(dphidm{var}) > 1
                    %one row for each peak
                    maxAdvances_all = [maxAdvances_all; peaks];
                    maxDelays_all = [maxDelays_all; troughs];
                    integrals_all = [integrals_all; one_irc.integrals];
                end
            end
            if length(dphidm{var}) > 1
                %find largest advance/delay across all peaks
                maxAdvances_all = max(maxAdvances_all);
                maxDelays_all = min(maxDelays_all);
                %sum inegrals
                integrals_all = max(abs(integrals_all));
                all_peaks_irc.integrals = integrals_all;
                all_peaks_irc.maxAdvances = maxAdvances_all;
                all_peaks_irc.maxDelays = maxDelays_all;
                vardata{end+1} = all_peaks_irc;
            end
            ircphi{var} = vardata;
        end
        results.ircphi = ircphi;
        results.ircphi_t = phaseIRCs_t;
    else
        %For an unforced oscillator, area under the curve of the irc is the
        %phase change. But we are considering a perturbation whose length
        %approaches zero, so vlaue of irc curve at that time point
        %approximates to the area under the curve for the period of the
        %perturbation
        
        % these below are for log k_j
        irc.data = squeeze(dxdm(:,1,:));
        %this queezes irc results for just the period 'variable'. Don't want to
        %do the same to dphidm
        timesteps = zeros(1, length(results.t)-1);
        Integrals = zeros(1, size(irc.data,2));
        for i = 1:length(results.t)-1
            timesteps(i) = results.t(i+1)-results.t(i);
        end
        for i = 1:size(irc.data,2)
            Integrals(i) = sum(timesteps' .* irc.data(1:end-1,i));
        end
        irc.integrals = Integrals;
        peaks = zeros(size(irc.data,2),1);
        troughs = zeros(size(irc.data,2),1);
        for i = 1:size(irc.data,2)
            peaks(i) = max(irc.data(:,i));
            troughs(i) = min(irc.data(:,i));
        end
        
        irc.maxAdvances = peaks;
        irc.maxDelays = troughs;
        results.irc = irc;
    end
end

if getdgsoutput
    results.periodic_dgs = periodic_gs;
    if ~lc.forced
        results.nonper_dgs = gs;
    end
end

if getdphasedpar 
    % derivative of ith peak/trough of jth variable with respect to kth parameter
    % cell arrays, one element for each var. Each element is a par by peak/trough num matrix
    % peak/trough num are peaks/troughs in chronological order for that
    % variable
    results.dtrdpar = dphi.troughs; 
    results.dpkdpar = dphi.peaks;    
end
if getdypkdpar
     %at the ith peak/trough of the jth variable, the derivative of that
    %variable with respect to kth parameter 
    % cell arrays, one element for each var. Each element is a par by peak/trough num matrix
    % peak/trough num are peaks/troughs in chronological order for that
    % variable
    results.dytr = dxdks.troughs;  
    results.dypk = dxdks.peaks;
end

%new output, model jac evaluated at all timepoints
global CP ModelForce
sysjac = str2func([lc.name,'_jac']);
results.model_jac = cell(1,length(lc.sol.x));

for t=1:length(lc.sol.x)
    results.model_jac{t} = feval(sysjac, lc.sol.x(t), lc.sol.y(t,:), lc.par, ModelForce, CP);
end

display_message('done');
tt = etime(clock, start_t);
str = sprintf('function theory_oscillator was completed in %.*f seconds',2,tt);
display_message(str);
display_message('Completed successfully');
return;

%perform check
% if dgs && svdf
%         % 1st pc in sds should be the same as periodic_dgs
%         % sds.U_all; %this is timepoint * variables by parameter matrix
%         % results.periodic_dgs;    %timepoint by varaible by parameter matrix
%     numTimepoints = length(results.t);
%     ss = 0;
%     for var = 1:dim
%         u = results.periodic_sds.U_all(numTimepoints * (var-1) + 1: numTimepoints * var, 1);
%         lc = results.periodic_dgs(:,var,1); Parameter 1 is an arbitrary
%         one???
%         u = u/max(abs(u));         % normalise
%         if max(abs(lc))
%             lc = lc/max(abs(lc));      % normalise
%         end
%         ss = ss + sum((u - lc).^2) / (numTimepoints*dim);
%     end
%     str = 'Comparing first principle component with limit cycle derivative.';
%     disp(str);
%     if ~isempty(gui)
%         feval(gui,'prog', str, 6/7);
%     end
%     str = sprintf('Normalised sum of squares error = %f', ss);
%     disp(str);
%     if ~isempty(gui)
%         feval(gui,'prog', str, 6/7);
%     end
% end