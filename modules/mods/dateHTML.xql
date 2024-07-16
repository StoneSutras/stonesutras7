xquery version "3.0";

module namespace dateHTML="http://www.stonesutras.org/publication/fo/modules/dateHTML";
import module namespace settings="http://www.stonesutras.org/publication/fo/modules/settings" at "settings.xql";
import module namespace config="http://www.stonesutras.org/publication/config" at "fo-config.xql";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mads="http://www.loc.gov/mads/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace tei="http://www.tei-c.org/ns/1.0";




declare function dateHTML:output-dateHTML($entry as element(mods:mods)){
    let  $date := $entry//mods:originInfo/mods:dateIssued
    return
        if ($date/@qualifier="others") then
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($date [@qualifier="others"]/text())}</span>
        else if ($date/@qualifier="forthcoming") then
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($date [@qualifier="forthcoming"]/text())}</span>
        else
            if ($date/@point="start") then
            <span font-family="{$config:BiblioFont}">{($settings:SPACE),fn:substring($date[@point="start"]/text(),1 ,4)}–{fn:substring($date[@point="end"]/text(),1 ,4)}</span> 
            else
            <span font-family="{$config:BiblioFont}">{($settings:SPACE),fn:substring($date[1]/text(),1 ,4)}</span>        
};

declare function dateHTML:output-journaldateHTML($entry as element(mods:mods)){
    let  $date := $entry/mods:relatedItem[1]/mods:part[1]/mods:date
    return
        if ($date/@qualifier="others") then
        <span font-family="{$config:BiblioFont}">{($date [not(@*)]/text())},{($settings:SPACE),($date [@qualifier="others"]/text())}</span>
        else
            if ($date/@point="start") then
            <span font-family="{$config:BiblioFont}">{fn:substring($date[@point="start"]/text(),1 ,4)}–{fn:substring($date[@point="end"]/text(),1 ,4)}</span> 
            else
            <span font-family="{$config:BiblioFont}">{fn:substring($date[1]/text(),1 ,4)}</span>        
};