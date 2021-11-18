function [results] = theory_signal(lc, args)

% outputs are 
% results.gs, dx_i/dk_j (t)
% results.ts times 
% results.sds the SVD structure 


%% ---------------------------------------------------------------------
% dealing with varargin
% ---------------------------------------------------------------------

% For signal model

% 'getdgsoutput'   nonper_dgs
% 'getdphasedpar'  dtrdpar, dpkdpar (require dgs)
% 'getdypkdpar'    dytr, dypk (require dgs)
global odetol gui

gui = [];
getdgsoutput = 0;
getdphasedpar = 0;
getdypkdpar = 0;

for i=1:length(args)
    if isa(args{i},'function_handle')
        gui = args{i};
    else
        %set names paramerers to non-zero
        eval([args{i} '=1;']);
    end
end

%initialise results structure - repeats what is in new_theory
results.date = date;
if getdgsoutput
    results.t = lc.sol.x;
end
start_t = clock;
str = sprintf('\nRunning using solver %s\n',lc.solver{1});
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
% % % solX = calc_Xt(lc,[lc.odesol.x(1) lc.odesol.x(end)],lc.par)
% % % tt = toc
% % % str = sprintf('X(t), 0< t <%.*f has been calculated in %.*f seconds',2,per,2,tt);
% % % disp(str);
% % % if ~isempty(gui)
% % %     feval(gui,'prog', str, 1/6);
% % % end

%% ---------------------------------------------------------------------
% calculating int_0^t X(s,t)b(s)ds
% ---------------------------------------------------------------------
if getdgsoutput || getdphasedpar || getdypkdpar
    display_message('',1);
    if getdgsoutput
        str = ('Calculating derivatives...');
        display_message(str);
        tmp_t = clock;
    end
    ts = t;
    solint2t = calc_int2t(lc,[lc.odesol.x(1) lc.odesol.x(end)], dim, ts);
    display_message('',1);
    gs=zeros(length(ts),dim,length(lc.par));
    for i=1:dim
        for j=1:length(lc.par)
            gs(:,i,j)=solint2t((j-1)*dim+i,:);
        end
    end
    if getdgsoutput
        display_message('done');
        tt = etime(clock, tmp_t);
        str = sprintf('calculation of del_y(t) = dx/dk(t) was completed in %.*f seconds',2,tt);
        display_message(str);
    end
    
    % ---------------------------------------------------------------------
    % calculate the phase derivatives
    % ---------------------------------------------------------------------
    
    if getdphasedpar || getdypkdpar
        display_message('Performing phase derivative analysis...');
        tmp_t = clock;
        [dphi, dxdks] = getphases(lc, gs, getdphasedpar, getdypkdpar, 0);
        
        %scale as for oscillator so that derivatives are respect to log_k
        for varnum=1:dim
            for i=1:length(lc.par)
                if lc.par(i) > 0
                    if ~isempty(dphi.peaks{varnum})
                        dphi.peaks{varnum}(i, :) = dphi.peaks{varnum}(i, :) * lc.par(i);
                    end
                    if ~isempty(dphi.troughs{varnum})
                        dphi.troughs{varnum}(i, :) = dphi.troughs{varnum}(i, :) * lc.par(i);
                    end
                    if ~isempty(dxdks.peaks{varnum})
                        dxdks.peaks{varnum}(i, :) = dxdks.peaks{varnum}(i, :) * lc.par(i);
                    end
                    if ~isempty(dxdks.troughs{varnum})
                        dxdks.troughs{varnum}(i, :) = dxdks.troughs{varnum}(i, :) * lc.par(i);
                    end
                end
            end
        end

        tt = etime(clock, tmp_t);
        display_message('done');
        str = sprintf('Phase derivatives have been calculated in %.*f seconds',2,tt);
        display_message(str);
        display_message('Note this analysis is only valid if the force is flat at the phase in question');
    end
    
end
% ---------------------------------------------------------------------
% adjusting for scaled parameters
% ---------------------------------------------------------------------

% sc = eye(length(lc.par));
% for k=1:length(lc.par)        % deliberately not diag(lc.par) to deal with zero parameters
%     if lc.par(k) > 0
%         sc(k,k) = lc.par(k);
%     end
% end
% % for i=1:length(gs(:,1,1))
% %     pscaled_gs(i,:,:) = squeeze(gs(i,:,:)) * sc;
% % end
% tt = toc;
% % str = sprintf('dxi/dparams has been calculated in %.*f seconds',2,tt);
% % display_message(str);
% str = sprintf('scaling was completed in %.*f seconds',2,tt);
% display_message(str);



%% ---------------------------------------------------------------------
% allocate the results structure according to the flags set
% ---------------------------------------------------------------------

if getdgsoutput
    results.nonper_dgs = gs;
end

%phase outputs should be scaled by parameter as in oscillator. This makes
%then derivative with respect to log_k
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


% tt = toc;
% str = sprintf('function signal_oscilator was completed in %.*f seconds',2,tt);
% disp(str);
% if ~isempty(gui)
%     feval(gui,'prog', str, 1/6);
% end
tt = etime(clock, start_t);
str = sprintf('function theory_signal was completed in %.*f seconds',2,tt);
display_message(str);
display_message('Completed successfully');
return;