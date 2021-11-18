function [Names, Values] = GetAllParametersForSASSy(SBMLModel)

%This function is based on the SBML toolbox functions
%GetAllParametersUnique and GetGlobalParameters.

%Here is the license for the SBML Toolbox


%<!---------------------------------------------------------------------------
% This file is part of SBMLToolbox.  Please visit http://sbml.org for more
% information about SBML, and the latest version of SBMLToolbox.
%
% Copyright (C) 2009-2012 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. EMBL European Bioinformatics Institute (EBML-EBI), Hinxton, UK
%
% Copyright (C) 2006-2008 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. University of Hertfordshire, Hatfield, UK
%
% Copyright (C) 2003-2005 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA 
%     2. Japan Science and Technology Agency, Japan
%     3. University of Hertfordshire, Hatfield, UK
%
% SBMLToolbox is free software; you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation.  A copy of the license agreement is provided
% in the file named "LICENSE.txt" included with this software distribution.
%----------------------------------------------------------------------- -->


wbHndl = waitbar(0.0,'Analysing global parameters...', 'Name', 'PeTTSy', 'pointer', 'watch', 'resize', 'off');
set(wbHndl, 'userdata', 0);

NumParams = length(SBMLModel.parameter);
NumReactions = length(SBMLModel.reaction);

num_increments = NumParams + NumReactions;
inc = 1/num_increments;


%------------------------------------------------------------
% get the global parameters


% loop through the list of parameters
for i = 1:NumParams
    
    %Paul Brown added these lines========
    str = ['Analysing model parameters... ' num2str(i)  ' of ' num2str(NumParams)];
    updatebar(wbHndl, inc, str);
    %====================================
    
    
    if (isempty(SBMLModel.parameter(i).id))
        name = SBMLModel.parameter(i).name;
    else
        name = SBMLModel.parameter(i).id;
    end;

    
    % save into an array of character names
    Names{i} = name;
    
    % put the value into the array
    Values(i) = SBMLModel.parameter(i).value;
    
    % might be an initial assignment in l2v2
    if ((SBMLModel.SBML_level == 2 && SBMLModel.SBML_version > 1) || SBMLModel.SBML_level == 3)
        IA = Model_getInitialAssignmentBySymbol(SBMLModel, name);
        if (~isempty(IA))
            % remove this from the substtution
            newSBMLModel = SBMLModel;
            newSBMLModel.parameter(i) = [];
            for fd = 1:Model_getNumFunctionDefinitions(SBMLModel)
                newFormula = SubstituteFunction(IA.math, Model_getFunctionDefinition(SBMLModel, fd));
                if (~isempty(newFormula))
                    IA.math = newFormula;
                end;
            end;
            Values(i) = Substitute(IA.math, newSBMLModel);
        end;
    end;
    % might be set by assignment rule
    AR = Model_getAssignmentRuleByVariable(SBMLModel, name);
    if (~isempty(AR))
        newSBMLModel = SBMLModel;
        newSBMLModel.parameter(i) = [];
        for fd = 1:Model_getNumFunctionDefinitions(SBMLModel)
            newFormula = SubstituteFunction(AR.formula, Model_getFunctionDefinition(SBMLModel, fd));
            if (~isempty(newFormula))
                AR.formula = newFormula;
            end;
        end;
        Values(i) = Substitute(AR.formula, newSBMLModel);
    end;
end;


%------------------------------------------------------------
% get local parameters

% loop through the list of reactions
for i = 1:NumReactions
    
     %Paul Brown added these lines========
    str = ['Analysing reactions... ' num2str(i)  ' of ' num2str(NumReactions)];
    updatebar(wbHndl, inc, str);
    %====================================
    
    % get parameters within each reaction
    [Char, Value] = GetParameterFromReactionUnique(SBMLModel.reaction(i));
    
    % add to existing arrays
    for j = 1:length(Char)
        Values(end+1) = Value(j);
        Names{end+1} = Char{j};
    end;
    
end;

delete(wbHndl);






