function  f = plusforce(mdl, t, ftype, cp) %DAR change

% calculates a potentially multi-dimensional force for every time point t(i) of
% the solution. Called at the end of limit cycle routines to produce the
% value of lc.force

%Edited by PEB 11/12/2006 and 5/2011



% functions are defined in the file 'name'_f.m produced by 'make'

% calculating the dimension of the force
% force = str2func([mdl.name,'_f']);
% f=feval(force, t(1), [], ftype, cp);
% dim2 = length(f);
% if dim2 > 0
%     f = zeros(length(t), dim2);
%     % calls force for everypoint of the solution
%     for i=1:length(t)
%         f(i, :) = feval(force, t(i), [], ftype, cp);
%     end
% end
% 


%re-written Dec 2012

%mdl    The model structure
%t      vector of time points
%ftype  the force structure with fields name,  dawn, dusk
%cp     cycle period

%returns force time series

f = [];
if mdl.numforce > 0
    f = zeros(length(t), mdl.numforce);
     % calls force for everypoint of the solution
    for i=1:length(t)
        f(i, :) = get_force(t(i), ftype, cp, mdl.orbit_type)';
    end
end

