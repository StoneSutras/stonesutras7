xquery version "3.0";

module namespace continuingHTML="http://www.stonesutras.org/publication/fo/modules/continuingHTML";

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

declare function continuingHTML:format-articleinmonograph-host-continuingHTML($entry as element(mods:mods)) {
    
 
    if ($config:DEBUG) then
        <fo:block color="maroon">(format-articleinmonograph-host-continuing) </fo:block>
        
        (:format-articleinmonograph-host-continuing :)
    else
        (),
    
    <span>{nameHTML:output-nameHTML($entry, "author")}</span>,
    <span>{nameHTML:output-nameHTML($entry, "commentator")}</span>,
    <span>{nameHTML:output-nameHTML($entry, "editor")}</span>,
    <span>{nameHTML:output-nameHTML($entry, "translator")}</span>,
    <span>“{titleHTML:format-titlenotitalicHTML($entry)}” </span>,
            if (exists ($entry/mods:relatedItem[1]/mods:titleInfo/@transliteration)) then
                    (
                <i>{tei2fo:process-biblioHTML($entry/mods:relatedItem[1]/mods:titleInfo[(@transliteration)]/mods:title)}{$settings:SPACE}</i>,
                
                
                <span lang="zh">{tei2fo:process-biblioHTML($entry/mods:relatedItem[1]/mods:titleInfo[@lang = ("zh", "ja", "ko")]/mods:title)}<span lang="en"></span></span>,
                    (:for translated title:) 
                if ($entry/mods:relatedItem[1]/mods:titleInfo[@type = "translated"]/@displayLabel/string() = "yes")  then <span lang="en"> ({tei2fo:process-biblioHTML($entry/mods:relatedItem[1]/mods:titleInfo[@type = "translated"]/mods:title)})</span>  else ()
                    )
                
            else
                    (  
                <i>{tei2fo:process-biblioHTML($entry/mods:relatedItem[1]/mods:titleInfo/mods:title)}</i>
                     ),
                     
            (:for newspapers:)         
            if ($entry//mods:frequency = "daily") then
                  <span lang="en">,{$settings:SPACE}
                    {$entry/mods:relatedItem[1]/mods:part[1]/mods:detail/mods:number/text(), $entry/mods:relatedItem[1]/mods:part[1]/mods:detail/text()}
                    {
                       for $date in ($entry/mods:relatedItem[1]/mods:part[1]/mods:date)
                       let $corrected :=
                                if (matches($date, "\d+-\d+-\d+")) then
                                    format-date(xs:date($date), "[MNn] [D], [Y0001]")
                                else if (matches($date, "\d+-\d+")) then
                                    format-date(xs:date($date || "-01"), "[MNn], [Y0001]")
                                else
                                    $date
                            return
                                $corrected
                    }
                    <span lang="en">:{$settings:SPACE}
                        {if (exists($entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text())) then
                        <span lang="en">{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}–{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text()}</span>
                        else
                        <span lang="en">{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}</span>
                        }
                    </span>
               </span>
            (:for articles in journals:)
                else 
                    
                
                        (:volume and number:)
                        (
                        if (($entry/mods:relatedItem[1]/mods:part[1]/mods:detail/@type="volume") and ($entry/mods:relatedItem[1]/mods:part[1]/mods:detail/@type="no")) then 
                                (
                                <span lang="en">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:detail[@type="volume"]//text()}, no. {$entry/mods:relatedItem[1]/mods:part[1]/mods:detail[@type="no"]//text()}</span>,
                                <span lang="en">{$settings:SPACE}({dateHTML:output-journaldateHTML($entry)})</span>,
                                if (not($entry/mods:relatedItem[1]/mods:part[1]/mods:extent)) then () else
                                    <span>:</span>,
                                    if (exists($entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text())) then
                                    <span lang="en">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}–{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text()}</span>
                                 else
                                    <span lang="en">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}</span>
                                
                                
                                )
                        (:volume:)
                        else
                            if (($entry/mods:relatedItem[1]/mods:part[1]/mods:detail/@type="volume")) then 
                                (
                                <span lang="en">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:detail[@type="volume"]//text()}</span>,
                                <span lang="en">{$settings:SPACE}({dateHTML:output-journaldateHTML($entry)})</span>,
                                if (not($entry/mods:relatedItem[1]/mods:part[1]/mods:extent)) then () else
                                    <span>:
                                    {if (exists($entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text())) then
                                    <span lang="en">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}–{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text()}</span>
                                 else
                                    <span lang="en">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}</span>}
                                </span>
                                
                                )
                        (:number:)
                        else
                             if (($entry/mods:relatedItem[1]/mods:part[1]/mods:detail/@type="no")) then 
                                (
                                <span lang="en">{$settings:SPACE}{dateHTML:output-journaldateHTML($entry)}, no. {$entry/mods:relatedItem[1]/mods:part[1]/mods:detail[@type="no"]//text()}</span>,
                                if (not($entry/mods:relatedItem[1]/mods:part[1]/mods:extent)) then () else
                                    <span>:
                                <span lang="en">
                                    {if (exists($entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text())) then
                                <span lang="en">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}–{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text()}</span>
                                 else
                                    <span lang="en">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}</span>  
                                }</span>
                                </span>  
                                )
                        (:neither number nor volume:)
                        else
                            (
                            <span lang="en">{dateHTML:output-journaldateHTML($entry)}</span>,
                            if (not($entry/mods:relatedItem[1]/mods:part[1]/mods:extent)) then () else
                                    <span>:
                                <span lang="en">
                                    {if (exists($entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text())) then
                                <span lang="en">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}–{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text()}</span>
                                 else
                                    <span lang="en">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}</span>  
                                }</span> 
                                </span>      
                            )
                                
                        
                        
                           
                        ,
                        (:if published over two issues output the second issue:)
                        let $parts := $entry/mods:relatedItem[1]/mods:part
                        let $count := count($parts)

                        for $part at $pos in $parts
                        return
                            if ($count >= 2 and $pos >= 2) then
                                (
                                    if ($count = $pos) then
                                        <fo:inline font-family="{$config:BiblioFont}">{$settings:SPACE}and{$settings:SPACE}</fo:inline>
                                    else
                                        <fo:inline font-family="{$config:BiblioFont}">;{$settings:SPACE}</fo:inline>,

                                    (: vol. and no. :)
                                    if (($part/mods:detail[@type = "volume"] and $part/mods:detail[@type = "no"])) then
                                        <fo:inline font-family="{$config:BiblioFont}">
                                            {$part/mods:detail[@type = "volume"]//text()}, no.{$settings:SPACE}{$part/mods:detail[@type = "no"]//text()}{$settings:SPACE}({fn:substring($part/mods:date, 1, 4)}):
                                        </fo:inline>
                                    else
                                        (: other case :)
                                        <fo:inline font-family="{$config:BiblioFont}">
                                            {fn:substring($part/mods:date, 1, 4)}, no.{$settings:SPACE}{$part/mods:detail[@type = "no"]//text()}:
                                        </fo:inline>,

                                    (: page number :)
                                    <fo:inline font-family="{$config:BiblioFont}">
                                        {if (exists($part/mods:extent/mods:end)) then
                                            $part/mods:extent/mods:start || '–' || $part/mods:extent/mods:end
                                        else
                                            $part/mods:extent/mods:start}
                                    </fo:inline>
                                )
                            else ()
                        ),
    ".",
    if ($entry/mods:note/@type="forthcoming") then <span lang="en">{$settings:SPACE}{$entry/mods:note[@type="forthcoming"]/text()}.</span> else ()
    
};

declare function continuingHTML:reprint-format-articleinmonograph-host-continuingHTML($entry as element(mods:mods)) {
    

        <span lang="en">{$settings:SPACE}Reprinted in{$settings:SPACE}</span>,
    
            if (exists ($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:titleInfo/@transliteration)) then
                    (
                <i>{$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:titleInfo[(@transliteration)]/mods:title/text()}{$settings:SPACE}</i>,
                <span lang="zh">{$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:titleInfo[@lang = ("zh", "ja", "ko")]/mods:title/text()}</span>
                    )
                
            else
                    (  
                <i>{$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:titleInfo/mods:title/text()}</i>
                     ),
            if (exists ($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:extent/mods:start/text())) then
                        (
                            (:volume and number:)
                            if (($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:detail/@type="volume") and ($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:detail/@type="no")) then 
                                (
                                <span lang="en">{$settings:SPACE}{$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:detail[@type="volume"]/text()}, no. {$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:detail[@type="no"]/text()} ({fn:substring(($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:date)[1],1,4)}): </span>
                                )
                            else
                                
                                if ($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:detail/@type="volume")
                            then
                                (
                                <span lang="en">{$settings:SPACE}{$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:detail[@type="volume"]/text()} ({fn:substring(($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:date)[1],1,4)}): </span> 
                                )
                              else 
                                (
                                <span lang="en">{$settings:SPACE}{fn:substring(($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:date)[1],1,4)}, no. {$entry/mods:relatedItem[2]/mods:part/mods:detail[@type="no"]/text()}</span>
                                )
                        ,<span lang="en">{$settings:SPACE}{$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:extent/mods:start/text()}–{$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:extent/mods:end/text()}</span>
                        )
            else
               <span lang="en">{$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:detail/mods:number/text(), $entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:detail/text()}
               {
                   for $date in ($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:date)
                   let $corrected :=
                            if (matches($date, "\d+-\d+-\d+")) then
                                format-date(xs:date($date), "[MNn] [D], [Y0001]")
                            else if (matches($date, "\d+-\d+")) then
                                format-date(xs:date($date || "-01"), "[MNn], [Y0001]")
                            else
                                $date
                        return
                            $corrected
               }
               </span>,
    "."
};

declare function continuingHTML:format-articleinmonograph-host-continuing-webHTML($entry as element(mods:mods)) {
    
 
    if ($config:DEBUG) then
        <fo:block color="maroon">format-articleinmonograph-host-continuing-WEB</fo:block>
    else
        (),
    
    <span>{nameHTML:output-nameHTML($entry, "author")}</span>,
    <span>{nameHTML:output-nameHTML($entry, "editor")}</span>, 
    <span lang="en">"</span>,
    <span>{titleHTML:format-titlenotitalicHTML($entry)}</span>,
    <span lang="en">"</span>,
    <span lang="en">{$settings:SPACE}</span>,
            if (exists ($entry/mods:relatedItem/mods:titleInfo/@transliteration)) then
                    (
                <i>{$entry/mods:relatedItem/mods:titleInfo[(@transliteration)]/mods:title/text()}{$settings:SPACE}</i>,
                <span lang="zh">{$entry/mods:relatedItem/mods:titleInfo[@lang = ("zh", "ja", "ko")]/mods:title/text()},</span>
                    )
                
            else
                    (  
                <i>{$entry/mods:relatedItem/mods:titleInfo/mods:title/text()},</i>
                     ),
            if (exists ($entry/mods:relatedItem/mods:part/mods:extent/mods:start/text())) then
                        (
                            if (($entry/mods:relatedItem/mods:part/mods:detail/@type="volume") and ($entry/mods:relatedItem/mods:part/mods:detail/@type="no")) then 
                                (
                                <span lang="en">{$settings:SPACE}{$entry/mods:relatedItem/mods:part/mods:detail[@type="volume"]/text()}.{$entry/mods:relatedItem/mods:part/mods:detail[@type="no"]/text()}</span>
                                )
                            else
                                (
                                <span lang="en">{$settings:SPACE}{$entry/mods:relatedItem/mods:part/mods:detail[@type="volume"]/text(),$entry/mods:relatedItem/mods:part/mods:detail[@type="no"]/text()}</span>   
                                )
                        ,<span lang="en">{$settings:SPACE}({fn:substring($entry/mods:relatedItem/mods:part/mods:date/text(),1,4)}): {$entry/mods:relatedItem/mods:part/mods:extent/mods:start/text()}–{$entry/mods:relatedItem/mods:part/mods:extent/mods:end/text()}</span>
                        )
            else
               <span lang="en">{$entry/mods:relatedItem/mods:part/mods:detail/mods:number/text(), $entry/mods:relatedItem/mods:part/mods:detail/text()}
               {
                   for $date in ($entry/mods:relatedItem/mods:part/mods:date)
                   let $corrected :=
                            if (matches($date, "\d+-\d+-\d+")) then
                                format-date(xs:date($date), "[MNn] [D], [Y0001]")
                            else if (matches($date, "\d+-\d+")) then
                                format-date(xs:date($date || "-01"), "[MNn], [Y0001]")
                            else
                                $date
                        return
                            $corrected
               }
               </span>,
               <span  lang="en">. {$settings:SPACE}{$entry/mods:location/mods:url/text()}{$settings:SPACE}</span>,
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
               })</span>,
    "."
};
declare function continuingHTML:reprint-format-articleinmonograph-host-continuing-webHTML($entry as element(mods:mods)) {
    
 
    if ($config:DEBUG) then
        <fo:block color="maroon">REPRINT (FO unfinished!) format-articleinmonograph-host-continuing-WEB </fo:block>
    else
        (),
    
    <span>{nameHTML:output-nameHTML($entry, "author")}</span>,
    <span>{nameHTML:output-nameHTML($entry, "editor")}</span>, 
    <span lang="en">"</span>,
    <span>{titleHTML:format-titlenotitalicHTML($entry)}</span>,
    <span lang="en">"</span>,
    <span lang="en">{$settings:SPACE}</span>,
            if (exists ($entry/mods:relatedItem/mods:titleInfo/@transliteration)) then
                    (
                <i>{$entry/mods:relatedItem/mods:titleInfo[(@transliteration)]/mods:title/text()}{$settings:SPACE}</i>,
                <span lang="zh">{$entry/mods:relatedItem/mods:titleInfo[@lang = ("zh", "ja", "ko")]/mods:title/text()},</span>
                    )
                
            else
                    (  
                <i>{$entry/mods:relatedItem/mods:titleInfo/mods:title/text()},</i>
                     ),
            if (exists ($entry/mods:relatedItem/mods:part/mods:extent/mods:start/text())) then
                        (
                            if (($entry/mods:relatedItem/mods:part/mods:detail/@type="volume") and ($entry/mods:relatedItem/mods:part/mods:detail/@type="no")) then 
                                (
                                <span lang="en">{$settings:SPACE}{$entry/mods:relatedItem/mods:part/mods:detail[@type="volume"]/text()}.{$entry/mods:relatedItem/mods:part/mods:detail[@type="no"]/text()}</span>
                                )
                            else
                                (
                                <span lang="en">{$settings:SPACE}{$entry/mods:relatedItem/mods:part/mods:detail[@type="volume"]/text(),$entry/mods:relatedItem/mods:part/mods:detail[@type="no"]/text()}</span>   
                                )
                        ,<span lang="en">{$settings:SPACE}({fn:substring($entry/mods:relatedItem/mods:part/mods:date/text(),1,4)}): {$entry/mods:relatedItem/mods:part/mods:extent/mods:start/text()}–{$entry/mods:relatedItem/mods:part/mods:extent/mods:end/text()}</span>
                        )
            else
               <span lang="en">{$entry/mods:relatedItem/mods:part/mods:detail/mods:number/text(), $entry/mods:relatedItem/mods:part/mods:detail/text()}
               {
                   for $date in ($entry/mods:relatedItem/mods:part/mods:date)
                   let $corrected :=
                            if (matches($date, "\d+-\d+-\d+")) then
                                format-date(xs:date($date), "[MNn] [D], [Y0001]")
                            else if (matches($date, "\d+-\d+")) then
                                format-date(xs:date($date || "-01"), "[MNn], [Y0001]")
                            else
                                $date
                        return
                            $corrected
               }
               </span>,
               <span  lang="en">. {$settings:SPACE}{$entry/mods:location/mods:url/text()}{$settings:SPACE}</span>,
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
               })</span>,
    "."
};