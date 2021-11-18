function sds = master_svd6(scaling, all_dgs)

% this function takes in the output of the function get_solutions and
% does a SVD of the d_xi/dk. It then projects this onto the normal and then
% does a SVD of that. Options are noscale_z and noscale_params - default is
% to do scaling

% in the latest version the unscaled, parameters-only scaled and z and
% parameters scaled cases are all worked out

% note that z is a d*num_param x tspan_length matrix where each row is
% of the form dx_i/dk_j(t_m) for a fixed m. As you go down the columns
% i changes faster than jmain

% this is converted into sds.main_deriv where each row j is of the form
% dx_1/dk_j followed by dx_2/dk_j followed by dx_3/dk_j followed by ...

% need to check the unobserved stuff - not finished

% initial version subtracted out the meaan vectors. Decided that this is
% not a good idea as any general deviation/bias is something that should be
% included

%results should be param by dim*timepoint

%dgs from theory - timepoint by variable by parameter 


%exclude one column at a time from each dgs matix
%gemean diff from all vars, and plot var num against this diff to tell 
%us mos timportant var

% Pre-allocate storeage for the svd output, one set for each dgs

sds.U_all = cell(length(all_dgs), 1);          % U matrix for all, (dim*numt) by (dim*numt)
sds.V_all = cell(length(all_dgs), 1);          % V matrix for all, nump by nump
sds.spec_all = cell(length(all_dgs), 1);       % singular spectrun for all, length nump
sds.strengths = cell(length(all_dgs), 1);      % sing spec for all, nump by nump
sds.slope_spec_all = cell(length(all_dgs), 1);
sds.main_deriv = cell(length(all_dgs), 1);
sds.sigma_missing_var = cell(length(all_dgs), 1);
sds.dim = zeros(length(all_dgs),1);
sds.bigU = [];
sds.bigV = [];
sds.bigspec = [];
sds.bigstrengths = [];
sds.bigslope_spec = [];
sds.bigsigma_missing_var = [];

big_dgs = [];
do_big_dgs = (length(all_dgs) > 1);
total_time_length = 0; % added by DAR 22.4.11
dgs_time_length = zeros(length(all_dgs), 1);


for e = 1:length(all_dgs)   %each iteration of this loop represents one time series
    
    tmp_dgs = all_dgs{e};%this is t*v*p
    len_t=size(tmp_dgs,1);
    d = size(tmp_dgs,2); 
    w_pnum=size(tmp_dgs, 3);
    if do_big_dgs
        dgs_time_length(e) = len_t;
        total_time_length = total_time_length + len_t;
    end
    sds.dim(e) = d;

    % =================================================================
    % reshape the derivative solution so that d/dk_j is all on one row
    % =================================================================

    B=zeros(w_pnum,len_t*d); % column length is pn, row length is l*d
    for pp=1:w_pnum%B is param by d*t
        a = squeeze(tmp_dgs(:,:,pp));
        B(pp,:)=a(:)';
    end
    
    if do_big_dgs
        big_dgs = [big_dgs B]; % modified by DAR 22.4.11
    end

    % =================================================================
    % scale B to remove the dependence on the time-series length
    % =================================================================
    sds.main_deriv{e} = B';
    if ~strcmp(scaling, '-')
        sds.main_deriv{e} = sds.main_deriv{e} / sqrt(len_t);
    end
    
    B = B/sqrt(len_t); % modified by DAR 22.4.11
    
    % =================================================================
    % Do the SVD on this time series
    % =================================================================
    
    [sig_vals, U, V, se, slope] = getSVD(B);
    sds.U_all{e} = U;          % U matrix for all, (dim*numt) by (dim*numt)
    sds.V_all{e} = V;          % V matrix for all, nump by nump
    sds.spec_all{e} = sig_vals;  % singular spectrun for all, length nump
    sds.strengths{e} = se;     % sing spec for all, nump by nump
    sds.slope_spec_all{e}= slope;
    
    % =================================================================
    % now repeat SVD for this time series, removing one variable at a time
    % =================================================================
    
    cols_to_remove = [1:len_t]; %this is variable number one
    sigma_missing_var = cell(1,d);
    for v = 1:d
        tmpB = B;
        tmpB(:, cols_to_remove ) = [];
        %just get singular vals this time
        s = getSVD(tmpB);
        %comapre to singular vals for all variables
        sigma_missing_var{v} = s;
        cols_to_remove =  cols_to_remove + len_t; %move on to next variable
    end
    sds.sigma_missing_var{e} = sigma_missing_var; 
    
end

if do_big_dgs
    %now combined dgs
    big_dgs = big_dgs/sqrt(total_time_length); % added by DAR 22.4.11
    
    [s, U, V, se, slope] = getSVD(big_dgs);
    sds.bigU = U;          % U matrix for all, (dim*numt) by (dim*numt)
    sds.bigV = V;          % V matrix for all, nump by nump
    sds.bigspec = s;       % singular spectrun for all, length nump
    sds.bigstrengths = se;     % sing spec for all, nump by nump
    sds.bigslope_spec = slope;
    
     % =================================================================
    % now repeat SVD for this time series, removing one variable at a time
    % =================================================================
    
    %need to remove the variable from all the original time series
    
    %Is this meaningful, as variables won't neccessarily correspond between
    %different dgs
    %remove each var in turn, or remove all var1s, then all var2s etc?
    
    sigma_missing_var = cell(0);
    start_t = 1;
    
    for e = 1:length(all_dgs)
        len_t = dgs_time_length(e);
        for v = 1:sds.dim(e)
            cols_to_remove = [start_t:start_t+len_t-1]; %for this variable/dgs combination
            tmp_dgs = big_dgs; 
            tmp_dgs(:, cols_to_remove) = [];
            s = getSVD(tmp_dgs);
            %comapre to singular vals for all variables
            sigma_missing_var{end+1} = s;
            start_t = start_t + len_t;
        end
        
    end
    sds.bigsigma_missing_var = sigma_missing_var;
end



%=====================================================================
function [s, U, V, se, slope] = getSVD(B)

[U,S,V] = svd(B',0); % columns of U contain the principal components
s=diag(S); %length is nump (or dim * numt if smaller, will crash)

if nargout > 1
    W=inv(V);   %size is nump by nump
    se = zeros(size(W));
    w_pnum = size(B, 1);
    for j=1:w_pnum
        se(j,:)=s(j)*W(j,:); % this gives the strengths
    end
    
    % ================= get log slopes for specs ===================
    warning off MATLAB:log:logOfZero;
    nn=min(10,w_pnum);
    x=log10(s(1:nn));
    y1=detrend(x);
    dif=x-y1;
    slope=(dif(end)-dif(1))/(length(dif)-1);
    warning on MATLAB:log:logOfZero;
end








