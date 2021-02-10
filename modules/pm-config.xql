
xquery version "3.1";

module namespace pm-config="http://www.tei-c.org/tei-simple/pm-config";

import module namespace pm-stonesutras-web="http://www.tei-c.org/pm/models/stonesutras/web/module" at "../transform/stonesutras-web-module.xql";
import module namespace pm-stonesutras-print="http://www.tei-c.org/pm/models/stonesutras/fo/module" at "../transform/stonesutras-print-module.xql";
import module namespace pm-stonesutras-latex="http://www.tei-c.org/pm/models/stonesutras/latex/module" at "../transform/stonesutras-latex-module.xql";
import module namespace pm-stonesutras-epub="http://www.tei-c.org/pm/models/stonesutras/epub/module" at "../transform/stonesutras-epub-module.xql";
import module namespace pm-catalog-web="http://www.tei-c.org/pm/models/catalog/web/module" at "../transform/catalog-web-module.xql";
import module namespace pm-catalog-print="http://www.tei-c.org/pm/models/catalog/fo/module" at "../transform/catalog-print-module.xql";
import module namespace pm-catalog-latex="http://www.tei-c.org/pm/models/catalog/latex/module" at "../transform/catalog-latex-module.xql";
import module namespace pm-catalog-epub="http://www.tei-c.org/pm/models/catalog/epub/module" at "../transform/catalog-epub-module.xql";
import module namespace pm-docx-tei="http://www.tei-c.org/pm/models/docx/tei/module" at "../transform/docx-tei-module.xql";
import module namespace pm-cbeta-web="http://www.tei-c.org/pm/models/cbeta/web/module" at "../transform/cbeta-web-module.xql";
import module namespace pm-cbeta-print="http://www.tei-c.org/pm/models/cbeta/fo/module" at "../transform/cbeta-print-module.xql";
import module namespace pm-cbeta-latex="http://www.tei-c.org/pm/models/cbeta/latex/module" at "../transform/cbeta-latex-module.xql";
import module namespace pm-cbeta-epub="http://www.tei-c.org/pm/models/cbeta/epub/module" at "../transform/cbeta-epub-module.xql";

declare variable $pm-config:web-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "stonesutras.odd" return pm-stonesutras-web:transform($xml, $parameters)
case "catalog.odd" return pm-catalog-web:transform($xml, $parameters)
case "cbeta.odd" return pm-cbeta-web:transform($xml, $parameters)
    default return pm-stonesutras-web:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:print-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "stonesutras.odd" return pm-stonesutras-print:transform($xml, $parameters)
case "catalog.odd" return pm-catalog-print:transform($xml, $parameters)
case "cbeta.odd" return pm-cbeta-print:transform($xml, $parameters)
    default return pm-stonesutras-print:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:latex-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "stonesutras.odd" return pm-stonesutras-latex:transform($xml, $parameters)
case "catalog.odd" return pm-catalog-latex:transform($xml, $parameters)
case "cbeta.odd" return pm-cbeta-latex:transform($xml, $parameters)
    default return pm-stonesutras-latex:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:epub-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "stonesutras.odd" return pm-stonesutras-epub:transform($xml, $parameters)
case "catalog.odd" return pm-catalog-epub:transform($xml, $parameters)
case "cbeta.odd" return pm-cbeta-epub:transform($xml, $parameters)
    default return pm-stonesutras-epub:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:tei-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "docx.odd" return pm-docx-tei:transform($xml, $parameters)
    default return error(QName("http://www.tei-c.org/tei-simple/pm-config", "error"), "No default ODD found for output mode tei")
            
    
};
            
    