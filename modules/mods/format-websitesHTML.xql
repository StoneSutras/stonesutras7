xquery version "3.0";
module namespace webHTML="http://www.stonesutras.org/publication/fo/modules/webHTML";

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

declare function webHTML:format-websiteHTML($entry as element(mods:mods)){
    
    if ($config:DEBUG) then
        <fo:block color="maroon">format-website</fo:block> (:format-website:)
    else
        (),
    
    <span>{nameHTML:output-nameHTML($entry, "author")}</span>,
    <span>{nameHTML:output-nameHTML($entry, "editor")}</span>,
    if ($entry//mods:titleInfo/@rend = "italic") then 
    (<span>{titleHTML:format-titleHTML($entry)}</span>)
        else
            (
    <span><span font-family="{$config:BiblioFont}">“</span>
    <span>{titleHTML:format-titlenotitalicHTML($entry)}</span>
    <span font-family="{$config:BiblioFont}">”</span></span>),
    
    <span font-family="{$config:BiblioFont}">{$settings:SPACE}</span>,
    if (not($entry/mods:relatedItem)) then () else
        <span> In {$settings:SPACE}</span>,
    <span font-variant="small-caps" font-family="{$config:BiblioFont}">{settings:getreftitle($entry)}</span>,
        (:if (exists ($entry/mods:relatedItem/mods:titleInfo/@transliteration)) then
        (
        <span font-style="italic" font-family="{$config:BiblioFont}">{$entry/mods:relatedItem/mods:titleInfo[(@transliteration)]/mods:title/text()}{$settings:SPACE}</span>,
        <span font-family="{$config:ChineseFont}">{$entry/mods:relatedItem/mods:titleInfo[@lang = ("zh", "ja", "ko")]/mods:title/text()}.{$settings:SPACE}</span>
        )

        else
        (  
        <span font-style="italic" font-family="{$config:BiblioFont}">{$entry/mods:relatedItem/mods:titleInfo/mods:title/text()}.{$settings:SPACE}</span>
        ),:)
    if (not($entry//mods:dateOther)) then () 
        else <span  font-family="{$config:BiblioFont}">{tei2fo:process-biblio($entry//mods:dateOther)}.{$settings:SPACE}</span>,
    <span  font-family="{$config:BiblioFont}">{if ($entry/mods:relatedItem) then () else $entry/mods:location/mods:url/text()}</span>,
    <span  font-family="{$config:BiblioFont}">{if ($entry/mods:location/mods:url/@rend = "yes") then <span  font-family="{$config:BiblioFont}">.{$settings:SPACE}{$entry/mods:location/mods:url/text()}</span>  else ()}</span>,
    if (not($entry//mods:dateCaptured)) then ()
        else 
    <span font-family="{$config:BiblioFont}">{$settings:SPACE}(accessed{$settings:SPACE}
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
               })</span>,
    "."
};