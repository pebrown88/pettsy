function makeallmodels(varargin)

%calls make(model_name) for all model definitions it finds

%makeallmodels will make all the models it finds in /models/definitions/,
%prompting the user to overwrite any that have already been created.

%makeallmodels('f') forces overwrite so doesn't require user intervention

mydir = fileparts(mfilename('fullpath'));

if nargin > 0 && strcmp(char(varargin{1}), 'f') 
    force_overwrite = 1;
else
    force_overwrite = 0;
end

DefsDir = [mydir '/definitions/'];
l = dir([DefsDir, '*_model.m']);
if ~isempty(l)
    for i = 1:size(l,1)
        idx = strfind(l(i).name, '_model.m');
        name = l(i).name;
        name = name(1:idx(end)-1);
        count = sprintf('(%d of %d)', i, size(l,1));
        disp(['Creating the model ', name, ' ', count]);
        if force_overwrite
            make(name, 'f');
        else
            make(name);
        end
    end 
else
    disp('No model definitions found');
end

            