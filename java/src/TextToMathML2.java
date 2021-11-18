/*
The TextToMathML2 java class is based on SnuggleTeX, a free and open-source Java
library for converting fragments of LaTeX to XML
http://www2.ph.ed.ac.uk/snuggletex/documentation/overview-and-features.html


SnuggleTeX is issued under a liberal 3-clause BSD license.

 SnuggleTeX Software License (BSD License)
=========================================

Copyright (c) 2010, The University of Edinburgh.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this
  list of conditions and the following disclaimer in the documentation and/or
  other materials provided with the distribution.

* Neither the name of the University of Edinburgh nor the names of its
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

SnuggleTex makes use of the Saxon XSLT processor, http://saxon.sourceforge.net/
This is released under the Mozilla public license
See https://www.mozilla.org/en-US/MPL/

 */

import uk.ac.ed.ph.snuggletex.SnuggleEngine;
import uk.ac.ed.ph.snuggletex.SnuggleInput;
import uk.ac.ed.ph.snuggletex.SnuggleSession;
import uk.ac.ed.ph.snuggletex.XMLStringOutputOptions;
import uk.ac.ed.ph.snuggletex.upconversion.UpConvertingPostProcessor;
import uk.ac.ed.ph.snuggletex.upconversion.internal.UpConversionPackageDefinitions;

import java.io.IOException;

public class TextToMathML2 { 
 
    public TextToMathML2() {
       
    }
    
    public String convert(String input) throws IOException {      
        
        input = "$$ "+input+" $$";
       
        SnuggleEngine engine = new SnuggleEngine();
        engine.addPackage(UpConversionPackageDefinitions.getPackage());
       
        SnuggleSession session = engine.createSession();
        session.parseInput(new SnuggleInput(input));
 
        UpConvertingPostProcessor upConverter = new UpConvertingPostProcessor();

        XMLStringOutputOptions xmlStringOutputOptions = new XMLStringOutputOptions(); 
        xmlStringOutputOptions.addDOMPostProcessors(upConverter);
        xmlStringOutputOptions.setIndenting(true);
        xmlStringOutputOptions.setUsingNamedEntities(true);
  
        String result = session.buildXMLString(xmlStringOutputOptions);
         
        return result;
        
    }
    
}
