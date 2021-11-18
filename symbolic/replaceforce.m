function m = replaceforce(dpar, numf)

%need to replace multiple forces
%called only from savedifpar and the second derivative files

syms dy_dforce dj_dforce

global dforcesym

if ~iscell(dpar)
     %dpar is a jacobian matrix where the last col is the derivative with
    %respect to force. This function removes this column and adds 2 new cols,
    %the derivatives with respect to dawn and dusk, using dy/ddawn = dy/dforce * dforce/ddawn
    if ndims(dpar) > 2
        ShowError('replaceforce: Too many dimensions');
    end
    
    dy_dforce = dpar(:,end-numf+1:end);
    dpar = dpar(:,1:end-numf);

    %for each force
    for f = 1:numf
        dawncol = []; duskcol = [];
        for i = 1:size(dy_dforce,1)
            dawncol = [dawncol; dy_dforce(i, f) * sym(dforcesym(f))];
            duskcol = [duskcol; dy_dforce(i, f) * sym(dforcesym(f+1))];
        end
        dpar = [dpar dawncol duskcol];
    end
    m = dpar;

else
    %dpar is a cell array of jacobian matrices. The last one is the
    %derivatives with respect to force. Replace this with 2 matrices, the
    %derivatives with respect to dawn and dusk, using dy/ddawn = dy/dforce
    %* dforce/ddawn
    
    dj_dforce = dpar(end-numf+1:end);
    dpar = dpar(1:end-numf);
    
    for f = 1:numf    
        eval(['dawnmx = dj_dforce{f} * df_ddawn(' num2str(f) ');']);
        eval(['duskmx = dj_dforce{f} * df_ddusk(' num2str(f) ');']);
        dpar{end+1} = dawnmx;
        dpar{end+1} = duskmx;
    end
    m = dpar;
    
end

