xquery version "3.0";

module namespace rarebookHTML="http://www.stonesutras.org/publication/fo/modules/rarebookHTML";

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

declare function rarebookHTML:format-rarebookHTML($entry as element(mods:mods)) {
    
 
    if ($config:DEBUG) then
        <fo:block color="maroon">(format-rarebook) </fo:block>
        
        (:format-articleinmonograph-host-continuing :)
    else
        (),
    
    <span>{nameHTML:output-nameHTML($entry, "author")}</span>,
    <span>{nameHTML:output-nameHTML($entry, "editor")}</span>,
    <span>{nameHTML:output-nameHTML($entry, "translator")}</span>,
    <span>{titleHTML:format-titleHTML($entry)}</span>,
    <span font-family="{$config:BiblioFont}">{$settings:SPACE}</span>,
    if (exists($entry/mods:originInfo/mods:dateOther)) then  <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:originInfo/mods:dateOther/text()}.</span>
            else
                (),
    if (exists($entry/mods:extension)) then  <span font-family="{$config:BiblioFont}">{$settings:SPACE}{tei2fo:process-biblioHTML($entry/mods:extension[1])}{if (fn:ends-with($entry/mods:extension[1]/text(), ".")) then () else "."}</span>
            else
                (), 
    <span font-family="{$config:BiblioFont}">{tei2fo:process-biblioHTML($entry/mods:note[@type="rarebook"])}</span>,
    "."
};