function [dxdm, dphidm, idxdm, bdxdm, dphi, dxdks, bs_graph] = parscale(dxdm,dphidm,idxdm, bdxdm, dphi, dxdks, bs_graph, par, len)


% scaling by parameters, turn derivative with respect to k into derivative
% with respect to log_k
% parameter scaling matrix

% len - num time points in limit cycle
% len2 num time points in phase IRCs

% -ve params ignored  for dxdm (IRCs), dphidm (phase IRC), bs_graph
% not for idxdm (dperdpar), bdxdm (dy0dpar), dphi, dxdks in older versions
% of this function

pnum = length(par);

sc = eye(pnum);
for k=1:pnum
    if par(k) > 0
        %-ve params ignored
        sc(k,k) = par(k);
    end
end

% integrals
if ~isempty(idxdm)
    for i=1:length(par)
        if par(i) > 0   
            idxdm(i,:)=idxdm(i,:)*par(i);   %idxdm(:,1) = dTau/dpar
        end
    end
end

if ~isempty(bdxdm)
    for i=1:length(par)
        if par(i) > 0 
            bdxdm(i,:)=bdxdm(i,:)*par(i);     %dY0/dpar
        end
    end 
end

% and scaling of the curves
if ~isempty(dxdm)
    for i=1:len
        %dxdm(:,1,:) = IRCs
        dxdm(i,:,:) = squeeze(dxdm(i,:,:)) * sc;
    end
end

if ~isempty(dphidm)
    for var = 1:length(dphidm)
        for peak = 1:length(dphidm{var})
            %phase IRCs
            %for i=1:len2
            %   dphidm{var}{peak}(i, :) =  dphidm{var}{peak}(i,:) * sc;
            %end
            %probably can do
             dphidm{var}{peak} =  dphidm{var}{peak} * sc;
            %Integral of phase IRC
            %integral_PhaseIRCs{var}{peak} =  integral_PhaseIRCs{var}{peak}*sc;
           
           % for i=1:length(par)
           %     if par(i)
           %         bs_graph{var}{peak}.y(i) =  bs_graph{var}{peak}.y(i) * par(i);
           %     end
           % end
           bs_graph{var}{peak}.y = sc* bs_graph{var}{peak}.y;
        end
    end
end

%phase derivatives
if ~isempty(dphi)
    for varnum=1:length(dphi.peaks)
        if ~isempty(dphi.peaks{varnum})
            for i=1:length(par)
                if par(i) > 0
                    dphi.peaks{varnum}(i, :) = dphi.peaks{varnum}(i, :) * par(i);
                end
            end
        end
    end 
    for varnum=1:length(dphi.troughs)
        if ~isempty(dphi.troughs{varnum})
            for i=1:length(par)
                if par(i) > 0
                    dphi.troughs{varnum}(i, :) = dphi.troughs{varnum}(i, :) * par(i);
                end
            end
        end
    end
end

if ~isempty(dxdks)
    for varnum=1:length(dxdks.peaks)
        if ~isempty(dxdks.peaks{varnum})
            for i=1:length(par)
                if par(i) > 0
                    dxdks.peaks{varnum}(i, :) = dxdks.peaks{varnum}(i, :) * par(i);
                end
            end
        end
        
        if ~isempty(dxdks.troughs{varnum})
            for i=1:length(par)
                if par(i) > 0
                    dxdks.troughs{varnum}(i, :) = dxdks.troughs{varnum}(i, :) * par(i);
                end
            end
        end
    end
end
