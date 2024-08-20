xquery version "3.0";
module namespace monographicHTML="http://www.stonesutras.org/publication/fo/modules/monographicHTML";

import module namespace settings="http://www.stonesutras.org/publication/fo/modules/settings" at "settings.xql";
import module namespace config="http://www.stonesutras.org/publication/config" at "fo-config.xql";
import module namespace nameHTML="http://www.stonesutras.org/publication/fo/modules/nameHTML" at "nameHTML.xql";
import module namespace titleHTML="http://www.stonesutras.org/publication/fo/modules/titleHTML" at "titleHTML.xql";
import module namespace publisherHTML="http://www.stonesutras.org/publication/fo/modules/publisherHTML" at "publisherHTML.xql";
import module namespace dateHTML="http://www.stonesutras.org/publication/fo/modules/dateHTML" at "dateHTML.xql";
import module namespace tei2fo="http://www.stonesutras.org/publication/tei2fo" at "tei2fo.xql";
import module namespace modsHTML="http://www.loc.gov/mods/v3" at "bibliooutputHTML.xql";
import module namespace norelatedItemHTML="http://www.stonesutras.org/publication/fo/modules/norelatedItemHTML" at "biblio-no-relatedItemHTML.xql";



declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mads="http://www.loc.gov/mads/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace tei="http://www.tei-c.org/ns/1.0";


 
declare option exist:serialize "indent=no";



declare function monographicHTML:format-articleinmonograph-host-monographicHTML($entry as element(mods:mods)) 
{
 
    if ($config:DEBUG) then
        <fo:block color="orange">(format-articleinmonograph-host-monographic) </fo:block> (:(format-articleinmonograph-host-monographic):)
    else
        (),
    
    <span>{nameHTML:output-nameHTML($entry, "author")}</span>,
    <span>{nameHTML:output-nameHTML($entry, "commentator")}</span>,
    <span>{nameHTML:output-nameHTML($entry, "editor")}</span>,
    <span>{nameHTML:output-nameHTML($entry, "translator")}</span>,
    <span lang="en">“</span>,
    <span>{titleHTML:format-titlenotitalicHTML($entry)}</span>,
    <span lang="en">”</span>,
    if (exists($entry/mods:originInfo/mods:dateOther)) then  <span lang="en">{$settings:SPACE}{$entry/mods:originInfo/mods:dateOther/text()}.</span>
            else
                (),
    if (exists($entry/mods:extension)) then  <span lang="en">{$settings:SPACE}{tei2fo:process-biblioHTML($entry/mods:extension[1])}{if (fn:ends-with($entry/mods:extension[1]/text(), ".")) then () else "."}</span>
            else
                (),            
    if ($entry//mods:note/@type = "aftertitle") then  <span lang="en">{$settings:SPACE}{tei2fo:process-biblioHTML($entry//mods:note[@type = "aftertitle"]/node())}</span>
            else
                (),
    <span> In {$settings:SPACE}</span>,
    <span lang="en">{let $relitem:= settings:getrelateditem($entry)
    let $relitemoutput:= norelatedItemHTML:biblio-no-relatedItemHTML-before-relatedItemHTML($relitem) return ($relitemoutput)}</span>,
    if (exists($entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "series"]/mods:title/text())) then 
                (
                    if (exists($entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "series"]/mods:title/@transliteration)) then
                        <span>
                    <span lang="en">, {$entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "series"]/mods:title[(@transliteration)]/text()}</span>
                    <span lang="zh">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "series"]/mods:title[@lang = ("zh", "ja", "ko")]/text()}</span>
                        </span>
                    else
                        <span lang="en">, {$entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "series"]/mods:title/text()}</span>
                )
        else
                (),
    if (exists($entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "series"]/mods:number/text())) then 
             <span lang="en">, ser. {$entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "series"]/mods:number/text()}</span>
        else
                (),
    if (exists($entry/mods:relatedItem[1]/mods:part/mods:detail[./@type= "volume"]/mods:number/text())) then 
             <span lang="en">, vol. {$entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "volume"]/mods:number/text()}</span>
        else
                (),
    if (exists($entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "juan"]/mods:number/text())) then 
             <span lang="en">, juan {$entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "juan"]/mods:number/text()}</span>
        else
                (),            
    if (exists($entry/mods:relatedItem[1]/mods:part/mods:extent/mods:end[1]/text())) then
    <span lang="en">:{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part/mods:extent/mods:start[1]/text()}–{$entry/mods:relatedItem[1]/mods:part/mods:extent/mods:end/text()}</span>
        else
             <span lang="en">:{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part/mods:extent/mods:start[1]/text()}</span>,
    ".",
                if ($entry/mods:note/@type="reprint")then
            <span lang="en">{$settings:SPACE}{$entry/mods:note[@type="reprint"]/text()}.</span>
            else
                ()
     
};


declare function monographicHTML:reprint-format-articleinmonograph-host-monographicHTML($entry as element(mods:mods)) 
{
 
    <span lang="en">{$settings:SPACE}Reprinted in{$settings:SPACE}</span>,
    <span font-variant="small-caps" lang="en">{settings:reprint-getreftitle($entry)}</span>,
    if (exists($entry/mods:relatedItem[2]/mods:part/mods:detail[@type= "series"]/mods:title/text())) then 
             <span lang="en">, {$entry/mods:relatedItem[2]/mods:part/mods:detail[@type= "series"]/mods:title/text()}</span>
        else
                (),
    if (exists($entry/mods:relatedItem[2]/mods:part/mods:detail[@type= "series"]/mods:number/text())) then 
             <span lang="en">, ser. {$entry/mods:relatedItem[2]/mods:part/mods:detail[@type= "series"]/mods:number/text()}</span>
        else
            (),
    if (exists($entry/mods:relatedItem[2]/mods:part/mods:detail[@type= "volume"]/mods:number/text())) then 
             <span lang="en">, vol. {$entry/mods:relatedItem[2]/mods:part/mods:detail[@type= "volume"]/mods:number/text()}</span>
        else
            (),
    if (exists($entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "juan"]/mods:number/text())) then 
             <span lang="en">, juan {$entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "juan"]/mods:number/text()}</span>
        else
                (), 
    <span lang="en">:{$settings:SPACE}{$entry/mods:relatedItem[2]/mods:part/mods:extent/mods:start[1]/text()}–{$entry/mods:relatedItem[2]/mods:part/mods:extent/mods:end/text()}</span>,
    "."
     
};

declare function monographicHTML:monograph-in-congshuHTML($entry as element(mods:mods))
{
 
    if ($config:DEBUG) then
        <fo:block color="orange">(format-monograph-in-congshu)</fo:block> (:(format-articleinmonograph-host-monographic):)
    else
        (),
    
    <span>{nameHTML:output-nameHTML($entry, "author")}</span>,
    <span>{nameHTML:output-nameHTML($entry, "editor")}</span>,
    <span>{nameHTML:output-nameHTML($entry, "translator")}</span>,
    <span>{titleHTML:format-titleHTML($entry)}</span>,
    if (exists($entry/mods:originInfo/mods:dateOther)) then  <span lang="en">{$settings:SPACE}{$entry/mods:originInfo/mods:dateOther/text()}.</span>
            else
                (),
    if ($entry//mods:note/@type = "aftertitle") then  <span lang="en">{$settings:SPACE}{tei2fo:process-biblioHTML($entry//mods:note[@type = "aftertitle"]/node())}</span>
            else
                (),
     if (exists($entry/mods:extension)) then  <span lang="en">{$settings:SPACE}{tei2fo:process-biblioHTML($entry/mods:extension[1])}{if (fn:ends-with($entry/mods:extension[1]/text(), ".")) then () else "."}</span>
            else
                (),  
    
    <span> In {$settings:SPACE}</span>,
    <span lang="en">{
        let $relitem:= settings:getrelateditem($entry) 
        let $relitemoutput := fn:string-join(norelatedItemHTML:biblio-no-relatedItemHTML($relitem)," ")        return
            fn:substring($relitemoutput,1, fn:string-length($relitemoutput)-1)}</span>,
    if (exists($entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "series"]/mods:title/text())) then 
                (
                    if (exists($entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "series"]/mods:title/@transliteration)) then
                        <span>
                    <span lang="en">, {$entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "series"]/mods:title[(@transliteration)]/text()}</span>
                    <span lang="zh">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "series"]/mods:title[@lang = ("zh", "ja", "ko")]/text()}</span>
                        </span>
                    else
                        <span lang="en">, {$entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "series"]/mods:title/text()}</span>
                )
        else
                (),
    if (exists($entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "series"]/mods:number/text())) then 
             <span lang="en">, ser. {$entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "series"]/mods:number/text()}</span>
        else
                (),
    if (exists($entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "volume"]/mods:number/text())) then 
            if (not($entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "volume"]/mods:number[@type="start"]/text())) then
             <span lang="en">, vol. {$entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "volume"]/mods:number/text()}</span>
             else
                  <span lang="en">, vols. {$entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "volume"]/mods:number[@type= "start"]/text()}–{$entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "volume"]/mods:number[@type= "end"]/text()}</span>
        else
                (),
    if (exists($entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "juan"]/mods:number/text())) then 
             <span lang="en">, juan {$entry/mods:relatedItem[1]/mods:part/mods:detail[@type= "juan"]/mods:number/text()}</span>
        else
                (), 
    if (not($entry/mods:relatedItem[1]/mods:part/mods:extent)) then () 
    else
    if (exists($entry/mods:relatedItem[1]/mods:part/mods:extent/mods:end[1]/text())) then
    <span lang="en">:{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part/mods:extent/mods:start[1]/text()}–{$entry/mods:relatedItem[1]/mods:part/mods:extent/mods:end/text()}</span>
        else
             <span lang="en">:{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part/mods:extent/mods:start[1]/text()}</span>,
    ".",
                if ($entry/mods:note/@type="reprint")then
            <span lang="en">{$settings:SPACE}{$entry/mods:note[@type="reprint"]/text()}.</span>
            else
                ()
     
};