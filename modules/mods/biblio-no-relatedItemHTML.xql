xquery version "3.0";

module namespace norelatedItemHTML="http://www.stonesutras.org/publication/fo/modules/norelatedItemHTML";

import module namespace settings="http://www.stonesutras.org/publication/fo/modules/settings" at "settings.xql";
import module namespace config="http://www.stonesutras.org/publication/config" at "fo-config.xql";
import module namespace nameHTML="http://www.stonesutras.org/publication/fo/modules/nameHTML" at "nameHTML.xql";
import module namespace titleHTML="http://www.stonesutras.org/publication/fo/modules/titleHTML" at "titleHTML.xql";
import module namespace publisherHTML="http://www.stonesutras.org/publication/fo/modules/publisherHTML" at "publisherHTML.xql";
import module namespace dateHTML="http://www.stonesutras.org/publication/fo/modules/dateHTML" at "dateHTML.xql";
import module namespace tei2fo="http://www.stonesutras.org/publication/tei2fo" at "tei2fo.xql";




declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mads="http://www.loc.gov/mads/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "indent=no";


declare function norelatedItemHTML:biblio-no-relatedItemHTML($entry as element(mods:mods)){
    
         
    if ($config:DEBUG) then
        <fo:block color="green">(norelatedItemHTML:biblio-no-relatedItemHTML)</fo:block> (:(norelatedItem:biblio-no-relatedItem):)
    else
        (),
         
         
    
            nameHTML:output-nameHTML($entry, "author"),
            nameHTML:output-nameHTML($entry, "commentator"),
            nameHTML:output-nameHTML($entry, "editor"), 
            nameHTML:output-nameHTML($entry, "translator"),
            titleHTML:format-titleHTML($entry), 
            if (exists($entry/mods:extension)) then  <span lang="en">{$settings:SPACE}{tei2fo:process-biblioHTML($entry/mods:extension[1])}{if (fn:ends-with($entry/mods:extension[1]/text(), ".")) then () else "."}</span>
            else
                (),
            if (exists($entry/mods:originInfo/mods:dateOther)) then  <span lang="en">{$settings:SPACE}{$entry/mods:originInfo/mods:dateOther/text()}.</span>
            else
                (),
            if ($entry/mods:physicalDescription/mods:extent/mods:detail/@type ="volume") then <span lang="en">{$settings:SPACE}{$entry/mods:physicalDescription/mods:extent/mods:detail//text()}{$settings:SPACE}vols.</span> else (),
            if ($entry/mods:note/@type="revised")then
            <span lang="en">{$settings:SPACE}{tei2fo:process-biblioHTML($entry/mods:note[@type="revised"])}.</span>
            else
                (),
            
            publisherHTML:output-publisherHTML($entry),
            dateHTML:output-dateHTML($entry),
            ".",
            if ($entry/mods:note/@type="reprint")then
            <span lang="en">{$settings:SPACE}{tei2fo:process-biblioHTML($entry/mods:note[@type="reprint"])}.</span>
            else
                (),
            if ($entry/mods:classification="reprint") then 
                <span lang="en">{$settings:SPACE}Reprint, {publisherHTML:output-publisher-reprintHTML($entry)}{$settings:SPACE}{data($entry/mods:classification["reprint"]/@edition)}.</span>
            else 
                (),
            if (exists($entry/mods:location/mods:url/text())) then
                (
                <span  lang="en">{$settings:SPACE}{$entry/mods:location/mods:url/text()}{$settings:SPACE}</span>,
                <span lang="en">(accessed{$settings:SPACE}
               {
                   for $date in ($entry//mods:originInfo/mods:dateCaptured)
                   let $corrected :=
                            if (matches($date, "\d+-\d+-\d+")) then
                                format-date(xs:date($date), "[MNn] [D], [Y0001]")
                            else if (matches($date, "\d+-\d+")) then
                                format-date(xs:date($date || "-01"), "[MNn], [Y0001]")
                            else
                                $date
                        return
                            $corrected
               }).</span>
               )
               else
                   (),
              if ($entry/mods:note/@type="forthcoming") then <span lang="en">{$settings:SPACE}{tei2fo:process-biblioHTML($entry/mods:note[@type="forthcoming"])}.</span> else ()
              
            
            
};



declare function norelatedItemHTML:biblio-no-relatedItemHTML-before-relatedItemHTML($entry as element(mods:mods)){ (:(no ending dot):)
    
         
    if ($config:DEBUG) then
        <fo:block color="green">(norelatedItemHTML:biblio-no-relatedItemHTML)</fo:block> 
    else
        (),
         
         
    
            nameHTML:output-nameHTML($entry, "author"),
            nameHTML:output-nameHTML($entry, "commentator"),
            nameHTML:output-nameHTML($entry, "editor"), 
            nameHTML:output-nameHTML($entry, "translator"),
            titleHTML:format-titleHTML($entry), 
            if (exists($entry/mods:extension)) then  <span lang="en">{$settings:SPACE}{tei2fo:process-biblioHTML($entry/mods:extension[1])}{if (fn:ends-with($entry/mods:extension[1]/text(), ".")) then () else "."}</span>
            else
                (),
            if (exists($entry/mods:originInfo/mods:dateOther)) then  <span lang="en">{$settings:SPACE}{$entry/mods:originInfo/mods:dateOther/text()}.</span>
            else
                (),
            if ($entry/mods:physicalDescription/mods:extent/mods:detail/@type ="volume") then <span lang="en">{$settings:SPACE}{$entry/mods:physicalDescription/mods:extent/mods:detail//text()}{$settings:SPACE}vols.</span> else (),
            if ($entry/mods:note/@type="revised")then
            <span lang="en">{$settings:SPACE}{tei2fo:process-biblioHTML($entry/mods:note[@type="revised"])}.</span>
            else
                (),
            
            publisherHTML:output-publisherHTML($entry),
            dateHTML:output-dateHTML($entry),
            "",(:(otherwisethere would be another dot):)
            if ($entry/mods:note/@type="reprint")then
            <span lang="en">{$settings:SPACE}{tei2fo:process-biblioHTML($entry/mods:note[@type="reprint"])}.</span>
            else
                (),
            if ($entry/mods:classification="reprint") then 
                <span lang="en">{$settings:SPACE}Reprint, {publisherHTML:output-publisher-reprintHTML($entry)}{$settings:SPACE}{data($entry/mods:classification["reprint"]/@edition)}.</span>
            else 
                (),
            if (exists($entry/mods:location/mods:url/text())) then
                (
                <span  lang="en">{$settings:SPACE}{$entry/mods:location/mods:url/text()}{$settings:SPACE}</span>,
                <span lang="en">(accessed{$settings:SPACE}
               {
                   for $date in ($entry//mods:originInfo/mods:dateCaptured)
                   let $corrected :=
                            if (matches($date, "\d+-\d+-\d+")) then
                                format-date(xs:date($date), "[MNn] [D], [Y0001]")
                            else if (matches($date, "\d+-\d+")) then
                                format-date(xs:date($date || "-01"), "[MNn], [Y0001]")
                            else
                                $date
                        return
                            $corrected
               })</span>(:deleted a dot here:)
               )
               else
                   (),
              if ($entry/mods:note/@type="forthcoming") then <span lang="en">{$settings:SPACE}{tei2fo:process-biblioHTML($entry/mods:note[@type="forthcoming"])}.</span> else ()
              
            
            
};









