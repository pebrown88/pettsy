function Species = AnalyseSpeciesforSASSy(SBMLModel)

%This function is taken from the SBML Toolbox. Modified by Paul Brown,
%University  of Warwick. 
%Lots of code removed that is not relevantg to SASSy
%eg dealing with assignment and algebraic rules

%Here is the original instructions and copright notice

% [analysis] = AnalyseSpecies(SBMLModel)
%
% Takes
%
% 1. SBMLModel, an SBML Model structure
%
% Returns
%
% 1. a structure detailing the species and how they are manipulated
%               within the model
%
%
% *EXAMPLE:*
%
%          Using the model from toolbox/Test/test-data/algebraicRules.xml
%
%             analysis = AnalyseSpecies(m)
%
%             analysis =
%
%             1x5 struct array with fields:
%                 Name
%                 constant
%                 boundaryCondition
%                 initialValue
%                 hasAmountOnly
%                 isConcentration
%                 compartment
%                 ChangedByReaction
%                 KineticLaw
%                 ChangedByRateRule
%                 RateRule
%                 ChangedByAssignmentRule
%                 AssignmentRule
%                 InAlgebraicRule
%                 AlgebraicRule
%                 ConvertedToAssignRule
%                 ConvertedRule
%
%             analysis(1) =
%
%
%                                    Name: {'S1'}
%                                constant: 0
%                       boundaryCondition: 0
%                            initialValue: 0.0300
%                         hasAmountOnly: 0
%                         isConcentration: 0
%                             compartment: 'compartment'
%                       ChangedByReaction: 1
%                              KineticLaw: {' - (k*S1)'}
%                       ChangedByRateRule: 0
%                                RateRule: ''
%                 ChangedByAssignmentRule: 0
%                          AssignmentRule: ''
%                         InAlgebraicRule: 1
%                           AlgebraicRule: {{1x1 cell}}
%                   ConvertedToAssignRule: 0
%                           ConvertedRule: ''
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


[name, Values, KineticLaw, RateRule] = GetRateLawsForSASSy(SBMLModel);
% create the output structure

for i = 1:length(SBMLModel.species)
    
    Species(i).Name = name(i);
    if isnan(Values(i))
         Species(i).initialValue = 0;
    else
        Species(i).initialValue = Values(i);
       
    end
     Species(i).compartment = SBMLModel.species(i).compartment;
    
    if (strcmp(KineticLaw(i), '0'))
        Species(i).ChangedByReaction = 0;
        Species(i).KineticLaw = '';
    else
        Species(i).ChangedByReaction = 1;
        Species(i).KineticLaw = KineticLaw(i);
    end;
    
    if (strcmp(RateRule(i), '0'))
        Species(i).ChangedByRateRule = 0;
        Species(i).RateRule = '';
    else
        Species(i).ChangedByRateRule = 1;
        Species(i).RateRule = RateRule(i);
    end;
    
end;




