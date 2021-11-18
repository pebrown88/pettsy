function [Species, Values, RateLawsReact, RateLawsRules] = GetRateLawsForSASSy(SBMLModel)

%This function is taken from the SBML Toolbox. Based on
%GetRateLawsFromReactions, GetRateLawsFromRules, GetSpecies
%modified by Paul Brown, University  of Warwick.
%progress bar added and lots of code removed that is not relevant to SASSY
%eg dealing with assignment and algebraic rules

%Here is the original instructions and copright notice

% [species, rateLaws] = GetRateLawsFromReactions(SBMLModel)
%
% Takes
%
% 1. SBMLModel; an SBML Model structure
%
% Returns
%
% 1. an array of strings representing the identifiers of all species
% 2. an array of
%
%  - the character representation of the rate law established from any reactions
%    that determines the particular species
%  - '0' if the particular species is not a reactant/product in any reaction
%
% *EXAMPLE:*
%
%      model has 4 species (s1, s2, s3, s4)
%            and 2 reactions; s1 -> s2 with kineticLaw 'k1*s1'
%                             s2 -> s3 with kineticLaw 'k2*s2'
%
%           [species, rateLaws] = GetRateLawsFromReactions(model)
%
%                    species     = ['s1', 's2', 's3', 's4']
%                    rateLaws = {'-k1*s1', 'k1*s1-k2*s2', 'k2*s2', '0'}
%

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


wbHndl = waitbar(0.0,'Analysing model species and constructing ODEs...', 'Name', 'PeTTSy', 'pointer', 'watch', 'resize', 'off');
set(wbHndl, 'userdata', 0);

NumberSpecies = length(SBMLModel.species);
num_increments = NumberSpecies*2 + 1;
inc = 1/num_increments;
updatebar(wbHndl, inc);

NumReactions = length(SBMLModel.reaction);
RateRules = Model_getListOfRateRules(SBMLModel);
NumRateRules = Model_getNumRateRules(SBMLModel);

% for each species loop through each reaction and determine whether the species
% takes part and in what capacity

RateLawsRules = cell(1, NumberSpecies);
RateLawsReact = cell(1, NumberSpecies);
Species = cell(1, NumberSpecies);
Values = zeros(1, NumberSpecies);

for i = 1:NumberSpecies
    
     %Paul Brown added these lines========
    str = ['Analysing species ' num2str(i) ' of ' num2str(NumberSpecies) '...'];
    updatebar(wbHndl, 0, str);
    %====================================
    

    %determine the name or id of the species
    if (SBMLModel.SBML_level == 1)
        Species{i} = SBMLModel.species(i).name;
    else
        if (isempty(SBMLModel.species(i).id))
            Species{i} = SBMLModel.species(i).name;
        else
            Species{i} = SBMLModel.species(i).id;
        end;
    end;
    % get the initial concentration values
    % add to an array

    Values(i) = SBMLModel.species(i).initialAmount;

    if (SBMLModel.SBML_level > 1)
        if (SBMLModel.species(i).isSetInitialConcentration)
            Values(i) = SBMLModel.species(i).initialConcentration;
        end;
    end;
    
    
    % if species is a boundary condition (or constant in level 2
    % no rate law is required
    
    rule_output = '0';
    react_output = '0';
    
    if (SBMLModel.species(i).constant == 0)
        
        %look for a rate rule for th species
        %determine which rules it occurs within
        if NumRateRules > 0
            j = 0;
            while (j <NumRateRules)
                
                if ((strcmp(Species(i), RateRules(j+1).variable)) || (strcmp(Species(i), RateRules(j+1).species)))
                    rule_output = RateRules(j+1).formula;
                    break;
                else
                    j = j + 1;
                end;
                
                %Paul Brown added these lines========
                updatebar(wbHndl, inc/NumRateRules);
                %====================================
                
            end; % while NumRateRules
        else
            updatebar(wbHndl, inc);
        end
        
       
        
        if (SBMLModel.species(i).boundaryCondition == 0) && strcmp(rule_output, '0')
            % can be changed by the a reaction if no rate rule
            
            %determine which reactions it occurs within
            for j = 1:NumReactions
                
                SpeciesRole = DetermineSpeciesRoleInReaction(SBMLModel.species(i), SBMLModel.reaction(j));
                
                %--------------------------------------------------------------
                % check that reaction has a kinetic law
                if (isempty(SBMLModel.reaction(j).kineticLaw))
                    ShowError(['Reaction ' SBMLModel.reaction(j).id ' has no kinetic law defined.']);
                    delete(wbHndl);return;
                end;
                %--------------------------------------------------------------
                if (SBMLModel.SBML_level < 3)
                    kineticLawMath = SBMLModel.reaction(j).kineticLaw.formula;
                else
                    kineticLawMath = SBMLModel.reaction(j).kineticLaw.math;
                end;
                
                
                TotalOccurences = 0;
                % record numbers of occurences of species as reactant/product
                % and check that we can deal with reaction
                if (sum(SpeciesRole)>0)
                    
                    NoReactants = SpeciesRole(2);
                    NoProducts =  SpeciesRole(1);
                    TotalOccurences = NoReactants + NoProducts;
                    
                    %--------------------------------------------------------------
                    % check that a species does not occur twice on one side of the
                    % reaction
                    if (NoReactants > 1 || NoProducts > 1)
                        ShowError(['Error analysing reaction ' SBMLModel.reaction(j).id '. Species occurrs more than once on one side of the reaction.']);
                        delete(wbHndl);return;
                    end;
                    
                end;
                
                % species has been found in this reaction
                while (TotalOccurences > 0) %
                    
                    % add the kinetic law to the output for this species
                    
                    if(NoProducts > 0)
                        
                        % Deal with case where parameter is defined within the reaction
                        % and thus the reaction name has been appended to the parameter
                        % name in the list in case of repeated use of same name
                        Param_Name = GetParameterFromReaction(SBMLModel.reaction(j));
                        
                        
                        if (~isempty(Param_Name))
                            ReviseParam_Name = GetParameterFromReactionUnique(SBMLModel.reaction(j));
                            formula = Substitute(Param_Name, ReviseParam_Name, kineticLawMath);
                        else
                            formula = kineticLawMath;
                            
                        end;
                        
                        
                        % put in stoichiometry
                        
                        if ((SBMLModel.SBML_level == 2 && SBMLModel.SBML_version > 1) ...
                                || SBMLModel.SBML_level == 3)
                            stoichiometry = SBMLModel.reaction(j).product(SpeciesRole(4)).stoichiometry;
                        else
                            stoichiometry = SBMLModel.reaction(j).product(SpeciesRole(4)).stoichiometry/double(SBMLModel.reaction(j).product(SpeciesRole(4)).denominator);
                        end;
                        
                        if ((SBMLModel.SBML_level == 2) && (~isempty(SBMLModel.reaction(j).product(SpeciesRole(4)).stoichiometryMath)))
                            if (SBMLModel.SBML_version < 3)
                                react_output = sprintf('%s + (%s) * (%s)', react_output, SBMLModel.reaction(j).product(SpeciesRole(4)).stoichiometryMath, formula);
                            else
                                react_output = sprintf('%s + (%s) * (%s)', react_output, SBMLModel.reaction(j).product(SpeciesRole(4)).stoichiometryMath.math, formula);
                            end;
                        elseif (SBMLModel.SBML_level == 3)
                            % level 3 stoichiometry may be assigned by
                            % rule/initialAssignment which will override any
                            % stoichiometry value
                            if (~isempty(SBMLModel.reaction(j).product(SpeciesRole(4)).id))
                                rule = Model_getAssignmentRuleByVariable(SBMLModel, SBMLModel.reaction(j).product(SpeciesRole(4)).id);
                                rrule = Model_getRateRuleByVariable(SBMLModel, SBMLModel.reaction(j).product(SpeciesRole(4)).id);
                                ia = Model_getInitialAssignmentBySymbol(SBMLModel, SBMLModel.reaction(j).product(SpeciesRole(4)).id);
                                if ~isempty(rule)
                                    react_output = sprintf('%s + (%s) * (%s)', react_output, rule.formula, formula);
                                elseif ~isempty(ia)
                                    react_output = sprintf('%s + (%s) * (%s)', react_output, ia.math, formula);
                                elseif ~isempty(rrule)
                                    error('Cannot deal with stoichiometry in a rate rule');
                                elseif ~isnan(stoichiometry)
                                    if (stoichiometry == 1)
                                        react_output = sprintf('%s + (%s)', react_output, formula);
                                    else
                                        react_output = sprintf('%s + %g * (%s)', react_output, stoichiometry, formula);
                                    end;
                                else
                                    error('Cannot determine stoichiometry');
                                end;
                            elseif isnan(stoichiometry)
                                error ('Cannot determine stoichiometry');
                            else
                                if (stoichiometry == 1)
                                    react_output = sprintf('%s + (%s)', react_output, formula);
                                else
                                    react_output = sprintf('%s + %g * (%s)', react_output, stoichiometry, formula);
                                end;
                            end;
                        else
                            % if stoichiometry = 1 no need to include it in formula
                            if (stoichiometry == 1)
                                react_output = sprintf('%s + (%s)', react_output, formula);
                            else
                                react_output = sprintf('%s + %g * (%s)', react_output, stoichiometry, formula);
                            end;
                            
                        end;
                        NoProducts = NoProducts - 1;
                        
                    elseif (NoReactants > 0)
                        
                        % Deal with case where parameter is defined within the reaction
                        % and thus the reaction name has been appended to the parameter
                        % name in the list in case of repeated use of same name
                        Param_Name = GetParameterFromReaction(SBMLModel.reaction(j));
                        
                        if (~isempty(Param_Name))
                            ReviseParam_Name = GetParameterFromReactionUnique(SBMLModel.reaction(j));
                            formula = Substitute(Param_Name, ReviseParam_Name, kineticLawMath);
                        else
                            formula = kineticLawMath;
                            
                        end;
                        
                        
                        % put in stoichiometry
                        if ((SBMLModel.SBML_level == 2 && SBMLModel.SBML_version > 1) ...
                                || SBMLModel.SBML_level == 3)
                            stoichiometry = SBMLModel.reaction(j).reactant(SpeciesRole(5)).stoichiometry;
                        else
                            stoichiometry = SBMLModel.reaction(j).reactant(SpeciesRole(5)).stoichiometry/double(SBMLModel.reaction(j).reactant(SpeciesRole(5)).denominator);
                        end;
                        if ((SBMLModel.SBML_level == 2) && (~isempty(SBMLModel.reaction(j).reactant(SpeciesRole(5)).stoichiometryMath)))
                            if (SBMLModel.SBML_version < 3)
                                react_output = sprintf('%s - (%s) * (%s)', react_output, SBMLModel.reaction(j).reactant(SpeciesRole(5)).stoichiometryMath, formula);
                            else
                                react_output = sprintf('%s - (%s) * (%s)', react_output, SBMLModel.reaction(j).reactant(SpeciesRole(5)).stoichiometryMath.math, formula);
                            end;
                        elseif (SBMLModel.SBML_level == 3)
                            % level 3 stoichiometry may be assigned by
                            % rule/initialAssignment which will override any
                            % stoichiometry value
                            if (~isempty(SBMLModel.reaction(j).reactant(SpeciesRole(5)).id))
                                rule = Model_getAssignmentRuleByVariable(SBMLModel, SBMLModel.reaction(j).reactant(SpeciesRole(5)).id);
                                rrule = Model_getRateRuleByVariable(SBMLModel, SBMLModel.reaction(j).reactant(SpeciesRole(5)).id);
                                ia = Model_getInitialAssignmentBySymbol(SBMLModel, SBMLModel.reaction(j).reactant(SpeciesRole(5)).id);
                                if ~isempty(rule)
                                    react_output = sprintf('%s - (%s) * (%s)', react_output, rule.formula, formula);
                                elseif ~isempty(ia)
                                    react_output = sprintf('%s - (%s) * (%s)', react_output, ia.math, formula);
                                elseif ~isempty(rrule)
                                    error('Cannot deal with stoichiometry in a rate rule');
                                elseif ~isnan(stoichiometry)
                                    if (stoichiometry == 1)
                                        react_output = sprintf('%s - (%s)', react_output, formula);
                                    else
                                        react_output = sprintf('%s - %g * (%s)', react_output, stoichiometry, formula);
                                    end;
                                else
                                    error('Cannot determine stoichiometry');
                                end;
                            elseif isnan(stoichiometry)
                                error ('Cannot determine stoichiometry');
                            else
                                if (stoichiometry == 1)
                                    react_output = sprintf('%s - (%s)', react_output, formula);
                                else
                                    react_output = sprintf('%s - %g * (%s)', react_output, stoichiometry, formula);
                                end;
                            end;
                        else
                            % if stoichiometry = 1 no need to include it in formula
                            if (stoichiometry == 1)
                                react_output = sprintf('%s - (%s)', react_output, formula);
                            else
                                react_output = sprintf('%s - %g * (%s)', react_output, stoichiometry, formula);
                            end;
                            
                            
                        end;
                        
                        NoReactants = NoReactants - 1;
                    end;
                    
                    
                    
                    TotalOccurences = TotalOccurences - 1;
                    
                end; % while found > 0
                
                updatebar(wbHndl, inc/NumReactions)
            end; % for NumReactions
            
        else
            
             updatebar(wbHndl, inc);
            
        end % if (boundary == 0) && strcmp(rule_output, '0')
        

        
    else
        
         updatebar(wbHndl, 2*inc);
        
    end % if (constant == 0)
    
    RateLawsRules{i} = rule_output;
    RateLawsReact{i} = react_output;
   
    
end; % for NumberSpecies

delete(wbHndl);


function y = Substitute(InitialCharArray, ReplacementParams, Formula)
% Allowed = {'(',')','*','/','+','-','^', ' ', ','};
if exist('OCTAVE_VERSION')
    [g,b,c,e] = regexp(Formula, '[,+/*\^()-]');
    len = length(Formula);
    a{1} = Formula(1:b(1)-1);
    for i=2:length(b)
        a{i} = Formula(b(i-1)+1:b(i)-1);
    end;
    i = length(b)+1;
    a{i} = Formula(b(i-1)+1:len);
else
    [a,b,c,d,e] = regexp(Formula, '[,+*/()-]', 'split');
end;

num = length(a);
for i=1:length(InitialCharArray)
    for j=1:num
        if strcmp(a(j), InitialCharArray{i})
            a(j) = regexprep(a(j), a(j), ReplacementParams{i});
        end;
    end;
end;

Formula = '';
for i=1:num-1
    Formula = strcat(Formula, char(a(i)), char(e(i)));
end;
Formula = strcat(Formula, char(a(num)));

y = Formula;







