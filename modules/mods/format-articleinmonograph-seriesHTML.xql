xquery version "3.0";
module namespace seriesHTML="http://www.stonesutras.org/publication/fo/modules/seriesHTML";

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



declare function seriesHTML:format-articleinmonograph-seriesHTML($entry as element(mods:mods)) {
    if ($config:DEBUG) then
        <fo:block color="blue">format-articleinmonograph-series (=monograph in series) </fo:block> (:format-articleinmonograph-series (=monograph in series):)
    else
        (),
            nameHTML:output-nameHTML($entry, "author"),
            nameHTML:output-nameHTML($entry, "commentator"),
            nameHTML:output-nameHTML($entry, "editor"),
            nameHTML:output-nameHTML($entry, "translator"),
            titleHTML:format-titleHTML($entry),
            if (exists($entry/mods:extension)) then  <span font-family="{$config:BiblioFont}">{$settings:SPACE}{tei2fo:process-biblioHTML($entry/mods:extension[1])}{if (fn:ends-with($entry/mods:extension[1]/text(), ".")) then () else "."}</span>
            else
                (),
                 if ($entry/mods:physicalDescription/mods:extent/mods:detail/@type ="volume") then <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:physicalDescription/mods:extent/mods:detail//text()}{$settings:SPACE}vols.</span> else (),
            if (exists($entry/mods:originInfo/mods:dateOther)) then  <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:originInfo/mods:dateOther/text()}.</span>
            else
                (),
            $settings:SPACE,
            if (exists ($entry/mods:relatedItem[@type="series"]/mods:titleInfo/@transliteration)) then
                    (
                <span font-family="{$config:BiblioFont}">({tei2fo:process-biblioHTML($entry/mods:relatedItem[@type="series"]/mods:titleInfo[(@transliteration)]/mods:title)}{$settings:SPACE}</span>,
                <span font-family="{$config:ChineseFont}">{tei2fo:process-biblioHTML($entry/mods:relatedItem[@type="series"]/mods:titleInfo[@lang = ("zh", "ja", "ko")]/mods:title)}<span font-family="{$config:BiblioFont}">{if (exists($entry/mods:relatedItem/mods:part/mods:detail/mods:number)) then <span> {$entry/mods:relatedItem/mods:part/mods:detail/mods:number/text()}</span> else ()}{if (exists($entry/mods:relatedItem/mods:titleInfo/@displayLabel)) then <span>{$settings:SPACE}[{$entry/mods:relatedItem/mods:titleInfo[@type="translated"]/mods:title/text()}]</span> else ()}).</span></span>
                    )
                
            else
                    (  
                <span font-family="{$config:BiblioFont}">({tei2fo:process-biblioHTML($entry/mods:relatedItem[@type="series"]/mods:titleInfo[@lang = ("de", "en", "fr")]/mods:title)}{if ($entry/mods:relatedItem[@type="series"]//mods:number/text())then <span>{$settings:SPACE}{$entry/mods:relatedItem[@type="series"]//mods:number/text()}</span> else () }).</span>
                     ),
                publisherHTML:output-publisherHTML($entry),
                dateHTML:output-dateHTML($entry),
                ".",
                if ($entry/mods:note/@type="reprint")then
            <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:note[@type="reprint"]/text()}.</span>
            else
                (),
                
                
                if (exists($entry/mods:location/mods:url/text())) then
                (
                <span  font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:location/mods:url/text()}{$settings:SPACE}</span>,
                <span font-family="{$config:BiblioFont}">(accessed{$settings:SPACE}
               {
                   for $date in ($entry//mods:originInfo/mods:dateCaptured)
                   let $corrected :=
                            if (matches($date, "\d+-\d+-\d+")) then
                                format-date(xs:date($date), "[MNn] [D1o], [Y0001]")
                            else if (matches($date, "\d+-\d+")) then
                                format-date(xs:date($date || "-01"), "[MNn], [Y0001]")
                            else
                                $date
                        return
                            $corrected
               }).</span>
               )
               else
                   ()
                   

};

declare function seriesHTML:reprint-format-articleinmonograph-seriesHTML($entry as element(mods:mods)) {
    if ($config:DEBUG) then
        <span color="blue">format-articleinmonograph-series REPRINT</span> (:!REPRINT:!:)
    else
        (),
    
            nameHTML:output-nameHTML($entry, "editor"),
            titleHTML:format-titleHTML($entry),
            $settings:SPACE,
            if (exists ($entry/mods:relatedItem[@type="series"]/mods:titleInfo/@transliteration)) then
                    (
                <span font-family="{$config:BiblioFont}">{tei2fo:process-biblioHTML($entry/mods:relatedItem[@type="series"]/mods:titleInfo[(@transliteration)]/mods:title)}{$settings:SPACE}</span>,
                <span font-family="{$config:ChineseFont}">{tei2fo:process-biblioHTML($entry/mods:relatedItem[@type="series"]/mods:titleInfo[@lang = ("zh", "ja", "ko")]/mods:title)}.</span>
                    )
                
            else
                    (  
                <span font-family="{$config:BiblioFont}">({tei2fo:process-biblioHTML($entry/mods:relatedItem[@type="series"]/mods:titleInfo[@lang = ("de", "en", "fr")]/mods:title)}{if ($entry/mods:relatedItem[@type="series"]//mods:number/text())then <span>{$entry/mods:relatedItem[@type="series"]//mods:number/text()}{$settings:SPACE}</span> else () }).</span>
                     ),
                publisherHTML:output-publisherHTML($entry),
                dateHTML:output-dateHTML($entry),
                "."
                   

};