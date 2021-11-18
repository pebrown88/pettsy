<html><body style="font-family:'sans serif';padding-left:5px;padding-right:5px">
<p><u>Importing Models from SBML</u></p>
<p>PeTTSy uses the <a href="http://sbml.org/Software/SBMLToolbox" target="_blank">SBML toolbox</a> to import SBML models. This toolbox imposes a number of restrictions on the format of the model. In addition, PeTTSy imposes further restrictions, which are listed below.</p>
<p><u>Model Format</u></p>
<p>The model should be encoded in SBML Level 2 or later. It will be interpreted as follows:</p>
<ul>
<li>Parameters defined in the <code>listOfParameters</code> block will appear in the model .par file. They will be named according to their SBML <code>id</code> attribute. The <code>name</code> attribute, if present, will be used as a parameter description. 
<li>Species defined in the <code>listOfSpecies</code> block will become PeTTSy variables. Again they will be named according to their SBML <code>id</code> attribute. The <code>name</code> attribute, if present, will be used as a species description. 
<li>Models ODEs can be defined in one of two ways
<ul
<li>Each species can have a <code>rateRule</code> defined in the <code>listOfRules</code> block. This will be the ODE. 
<li>The model can consist of a series of <code>reaction</code> blocks within the <code>listOfReactions</code> block. The SBML toolbox will use these to construct a rate rule for each species. 
<li>The model can include functions. PeTTSy will replace a function call with the corresponding function body within the ODEs. An exception is when a function represents an external force. In this case it will be be replaced by a call to PeTTSy's force functions. Should the SBML model define a force function not included in PeTTSy, the user will need to add this to PeTTSy separately as a new force definition. Similarly, if one or more model parameters are external forces, the user will have the chance to specify this during the import process so that they are replaced by calls to PeTTSy's force functions. 
</ul>
</ul>
<p><u>Restrictions</u></p>
<p>In addition to conforming to the above format, PeTTSy and/or the SBML toolbox impose the following restrictions on the SBML that can be imported.</p>
<ul>
<li>All parameters must be constant, that is they cannot have their <code>constant</code> attribute set to <code>false</code>. 
<li>SBML requires that the model defines at least one compartment. The SBML toolbox requires there to be only one, and that it be constant in size, i.e. its <code>constant</code> attribute is not set to <code>false</code>. PeTTSy will ignore the model compartment and it will not appear in the model ODEs. 
<li>Model Events are not supported. 
<li>Model constraints are not supported. 
<li>Assignment and algebraic rules are not supported.
<li>Initial Assignments are not supported. 
<li>The reaction <code>fast</code> attribute is not supported, i.e. cannot be set to <code>true</code>. 
<li>The SBML Level 3 <code>conversionFactor</code> attribute is not supported. 
<li>The MathML <code>piecewise</code> element is not supported in the SBML model equations. 
</body></html> 
