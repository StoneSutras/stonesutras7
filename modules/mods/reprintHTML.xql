xquery version "3.0";

module namespace reprintHTML="http://www.stonesutras.org/publication/fo/modules/reprintHTML";

declare namespace mads="http://www.loc.gov/mads/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mods="http://www.loc.gov/mods/v3";


import module namespace norelatedItemHTML="http://www.stonesutras.org/publication/fo/modules/norelatedItemHTML" at "biblio-no-relatedItemHTML.xql";
import module namespace continuingHTML="http://www.stonesutras.org/publication/fo/modules/continuingHTML" at "format-articleinmonograph-host-continuingHTML.xql";
import module namespace defaulHTML="http://www.stonesutras.org/publication/fo/modules/defaulHTML" at "format-articleinmonograph-host-defaultHTML.xql";
import module namespace monographicHTML="http://www.stonesutras.org/publication/fo/modules/monographicHTML" at "format-articleinmonograph-host-monographicHTML.xql";
import module namespace seriesHTML="http://www.stonesutras.org/publication/fo/modules/seriesHTML" at "format-articleinmonograph-seriesHTML.xql";
import module namespace settings="http://www.stonesutras.org/publication/fo/modules/settings" at "settings.xql";
import module namespace webHTML="http://www.stonesutras.org/publication/fo/modules/webHTML" at "format-websitesHTML.xql";
import module namespace thesisHTML="http://www.stonesutras.org/publication/fo/modules/thesisHTML" at "format-thesisHTML.xql";
import module namespace foc="http://www.stonesutras.org/publication/config" at "fo-config.xql";




(: MODULFILTER FÜR ERSTEN TEIL DES BIBLIOGRAPHIEEINTRAGS. :)

declare function reprintHTML:biblio-with-relatedItemHTML($entry as element(mods:mods)) {
    
         if ($entry//mods:relatedItem/@type="series")
         
         then
             (
            seriesHTML:format-articleinmonograph-seriesHTML($entry),
            reprintHTML:reprint-biblio-with-relatedItemHTML($entry)
             )
        else
            reprintHTML:format-articleinmonograph-host-allHTML($entry)
};




declare function reprintHTML:format-articleinmonograph-host-allHTML($entry as element(mods:mods)) {
        if ($entry/mods:relatedItem[@type="host"][data(@xlink:href) != data($entry/mods:classification["reprint"]/@edition)]//mods:issuance = "monographic")
        
        then
            (
            monographicHTML:format-articleinmonograph-host-monographicHTML($entry), 
            reprintHTML:reprint-biblio-with-relatedItemHTML($entry)
                )
        
        
        else
             reprintHTML:format-articleinmonograph-host-restHTML($entry)
};


declare function reprintHTML:format-articleinmonograph-host-restHTML($entry as element(mods:mods)) {
    
        if ($entry/mods:relatedItem[@type="host"][data(@xlink:href) != data($entry/mods:classification["reprint"]/@edition)]//mods:issuance = "continuing")
        
        then
            (
            if (exists($entry//mods:location/mods:url))
                then 
                    (
                continuingHTML:format-articleinmonograph-host-continuing-webHTML($entry),
                reprintHTML:reprint-biblio-with-relatedItemHTML($entry)    
                    )
            else
                (
            continuingHTML:format-articleinmonograph-host-continuingHTML($entry),
            reprintHTML:reprint-biblio-with-relatedItemHTML($entry)
                )
            )
        else
            defaulHTML:format-articleinmonograph-host-defaultHTML($entry)
             
};

(: MODULFILTER FÜR REPRINT TEIL DES BIBLIOGRAPHIEEINTRAGS. :)
declare function reprintHTML:reprint-biblio-with-relatedItemHTML($entry as element(mods:mods)) {
    
         if ($entry//mods:relatedItem/@type="series")
         
         then
           seriesHTML:reprint-format-articleinmonograph-seriesHTML($entry)
        else
            reprintHTML:reprint-format-articleinmonograph-host-allHTML($entry)
};




declare function reprintHTML:reprint-format-articleinmonograph-host-allHTML($entry as element(mods:mods)) {
        if ($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]//mods:issuance = "monographic")
        
        then
            monographicHTML:reprint-format-articleinmonograph-host-monographicHTML($entry)
        else
             reprintHTML:reprint-format-articleinmonograph-host-restHTML($entry)
};


declare function reprintHTML:reprint-format-articleinmonograph-host-restHTML($entry as element(mods:mods)) {
    
        if ($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]//mods:issuance = "continuing")
        
        then
            (
            if (exists($entry//mods:location/mods:url))
                then 
                continuingHTML:reprint-format-articleinmonograph-host-continuing-webHTML($entry)    
            else
            continuingHTML:reprint-format-articleinmonograph-host-continuingHTML($entry)
            )
        else
            defaulHTML:format-articleinmonograph-host-defaultHTML($entry)
             
};


