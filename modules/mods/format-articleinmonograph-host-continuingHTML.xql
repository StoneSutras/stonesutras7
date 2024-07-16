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
                <span font-style="italic" font-family="{$config:BiblioFont}">{tei2fo:process-biblio($entry/mods:relatedItem[1]/mods:titleInfo[(@transliteration)]/mods:title)}{$settings:SPACE}</span>,
                
                
                <span font-family="{$config:ChineseFont}">{tei2fo:process-biblio($entry/mods:relatedItem[1]/mods:titleInfo[@lang = ("zh", "ja", "ko")]/mods:title)}<span font-family="{$config:BiblioFont}"></span></span>,
                    (:for translated title:) 
                if ($entry/mods:relatedItem[1]/mods:titleInfo[@type = "translated"]/@displayLabel/string() = "yes")  then <span font-family="{$config:BiblioFont}"> ({tei2fo:process-biblio($entry/mods:relatedItem[1]/mods:titleInfo[@type = "translated"]/mods:title)})</span>  else ()
                    )
                
            else
                    (  
                <span font-style="italic" font-family="{$config:BiblioFont}">{tei2fo:process-biblio($entry/mods:relatedItem[1]/mods:titleInfo/mods:title)}</span>
                     ),
                     
            (:for newspapers:)         
            if ($entry//mods:frequency = "daily") then
                  <span font-family="{$config:BiblioFont}">,{$settings:SPACE}
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
                    <span font-family="{$config:BiblioFont}">:{$settings:SPACE}
                        {if (exists($entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text())) then
                        <span font-family="{$config:BiblioFont}">{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}–{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text()}</span>
                        else
                        <span font-family="{$config:BiblioFont}">{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}</span>
                        }
                    </span>
               </span>
            (:for articles in journals:)
                else 
                    
                
                        (:volume and number:)
                        (
                        if (($entry/mods:relatedItem[1]/mods:part[1]/mods:detail/@type="volume") and ($entry/mods:relatedItem[1]/mods:part[1]/mods:detail/@type="no")) then 
                                (
                                <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:detail[@type="volume"]//text()}, no. {$entry/mods:relatedItem[1]/mods:part[1]/mods:detail[@type="no"]//text()}</span>,
                                <span font-family="{$config:BiblioFont}">{$settings:SPACE}({dateHTML:output-journaldateHTML($entry)})</span>,
                                if (not($entry/mods:relatedItem[1]/mods:part[1]/mods:extent)) then () else
                                    <span>:</span>,
                                    if (exists($entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text())) then
                                    <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}–{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text()}</span>
                                 else
                                    <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}</span>
                                
                                
                                )
                        (:volume:)
                        else
                            if (($entry/mods:relatedItem[1]/mods:part[1]/mods:detail/@type="volume")) then 
                                (
                                <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:detail[@type="volume"]//text()}</span>,
                                <span font-family="{$config:BiblioFont}">{$settings:SPACE}({dateHTML:output-journaldateHTML($entry)})</span>,
                                if (not($entry/mods:relatedItem[1]/mods:part[1]/mods:extent)) then () else
                                    <span>:
                                    {if (exists($entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text())) then
                                    <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}–{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text()}</span>
                                 else
                                    <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}</span>}
                                </span>
                                
                                )
                        (:number:)
                        else
                             if (($entry/mods:relatedItem[1]/mods:part[1]/mods:detail/@type="no")) then 
                                (
                                <span font-family="{$config:BiblioFont}">{$settings:SPACE}{dateHTML:output-journaldateHTML($entry)}, no. {$entry/mods:relatedItem[1]/mods:part[1]/mods:detail[@type="no"]//text()}</span>,
                                if (not($entry/mods:relatedItem[1]/mods:part[1]/mods:extent)) then () else
                                    <span>:
                                <span font-family="{$config:BiblioFont}">
                                    {if (exists($entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text())) then
                                <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}–{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text()}</span>
                                 else
                                    <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}</span>  
                                }</span>
                                </span>  
                                )
                        (:neither number nor volume:)
                        else
                            (
                            <span font-family="{$config:BiblioFont}">{dateHTML:output-journaldateHTML($entry)}</span>,
                            if (not($entry/mods:relatedItem[1]/mods:part[1]/mods:extent)) then () else
                                    <span>:
                                <span font-family="{$config:BiblioFont}">
                                    {if (exists($entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text())) then
                                <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}–{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:end/text()}</span>
                                 else
                                    <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[1]/mods:extent/mods:start/text()}</span>  
                                }</span> 
                                </span>      
                            )
                                
                        
                        
                           
                        ,
                        (:if published over two issues output the second issue:)
                        if(exists ($entry/mods:relatedItem[1]/mods:part[2]/mods:extent/mods:start/text())) then
                                
                                    (
                                    <fo-inline font-family="{$config:BiblioFont}">{$settings:SPACE}and{$settings:SPACE}</fo-inline>,
                                    
                                        if (($entry/mods:relatedItem[1]/mods:part[2]/mods:detail/@type="volume") and ($entry/mods:relatedItem[1]/mods:part[2]/mods:detail/@type="no")) then 
                                            (
                                            <span font-family="{$config:BiblioFont}">{$settings:SPACE}
                                                {$entry/mods:relatedItem[1]/mods:part[2]/mods:detail[@type="volume"]/text()}, no.{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[2]/mods:detail[@type="no"]/text()}{$settings:SPACE}({fn:substring(($entry/mods:relatedItem[1]/mods:part[2]/mods:date)[1],1,4)}):
                                            </span>
                                            )
                                        else
                                            if ($entry/mods:relatedItem[1]/mods:part[2]/mods:detail/@type="volume") then
                                            (
                                            <span font-family="{$config:BiblioFont}">
                                            {$settings:SPACE}and{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[2]/mods:detail[@type="volume"]/text()}
                                            {$settings:SPACE}({fn:substring(($entry/mods:relatedItem[1]/mods:part[2]/mods:date)[1],1,4)})
                                            </span>   
                                            )
                                            else     
                                            (
                                            <span font-family="{$config:BiblioFont}">
                                            {$settings:SPACE}and{$settings:SPACE}
                                            {fn:substring(($entry/mods:relatedItem[1]/mods:part[2]/mods:date)[1],1,4)}, no.{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[2]/mods:detail[@type="no"]/text()}
                                            </span>   
                                            )
                                    ,<span font-family="{$config:BiblioFont}">{$settings:SPACE} 
                                    {if (exists($entry/mods:relatedItem[1]/mods:part[2]/mods:extent/mods:end/text())) then
                                    <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[2]/mods:extent/mods:start/text()}–{$entry/mods:relatedItem[1]/mods:part[2]/mods:extent/mods:end/text()}</span>
                                     else
                                    <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem[1]/mods:part[2]/mods:extent/mods:start/text()}</span>
                                    }   
                                    </span>
                                    )
                        else
                          ()
                        ),
    ".",
    if ($entry/mods:note/@type="forthcoming") then <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:note[@type="forthcoming"]/text()}.</span> else ()
    
};

declare function continuingHTML:reprint-format-articleinmonograph-host-continuingHTML($entry as element(mods:mods)) {
    

        <span font-family="{$config:BiblioFont}">{$settings:SPACE}Reprinted in{$settings:SPACE}</span>,
    
            if (exists ($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:titleInfo/@transliteration)) then
                    (
                <span font-style="italic" font-family="{$config:BiblioFont}">{$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:titleInfo[(@transliteration)]/mods:title/text()}{$settings:SPACE}</span>,
                <span font-family="{$config:ChineseFont}">{$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:titleInfo[@lang = ("zh", "ja", "ko")]/mods:title/text()}</span>
                    )
                
            else
                    (  
                <span font-style="italic" font-family="{$config:BiblioFont}">{$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:titleInfo/mods:title/text()}</span>
                     ),
            if (exists ($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:extent/mods:start/text())) then
                        (
                            (:volume and number:)
                            if (($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:detail/@type="volume") and ($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:detail/@type="no")) then 
                                (
                                <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:detail[@type="volume"]/text()}, no. {$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:detail[@type="no"]/text()} ({fn:substring(($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:date)[1],1,4)}): </span>
                                )
                            else
                                
                                if ($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:detail/@type="volume")
                            then
                                (
                                <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:detail[@type="volume"]/text()} ({fn:substring(($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:date)[1],1,4)}): </span> 
                                )
                              else 
                                (
                                <span font-family="{$config:BiblioFont}">{$settings:SPACE}{fn:substring(($entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:date)[1],1,4)}, no. {$entry/mods:relatedItem[2]/mods:part/mods:detail[@type="no"]/text()}</span>
                                )
                        ,<span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:extent/mods:start/text()}–{$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:extent/mods:end/text()}</span>
                        )
            else
               <span font-family="{$config:BiblioFont}">{$entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:detail/mods:number/text(), $entry/mods:relatedItem[@type="host"][data(@xlink:href) = data($entry/mods:classification["reprint"]/@edition)]/mods:part/mods:detail/text()}
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
    <span font-family="{$config:BiblioFont}">"</span>,
    <span>{titleHTML:format-titlenotitalicHTML($entry)}</span>,
    <span font-family="{$config:BiblioFont}">"</span>,
    <span font-family="{$config:BiblioFont}">{$settings:SPACE}</span>,
            if (exists ($entry/mods:relatedItem/mods:titleInfo/@transliteration)) then
                    (
                <span font-style="italic" font-family="{$config:BiblioFont}">{$entry/mods:relatedItem/mods:titleInfo[(@transliteration)]/mods:title/text()}{$settings:SPACE}</span>,
                <span font-family="{$config:ChineseFont}">{$entry/mods:relatedItem/mods:titleInfo[@lang = ("zh", "ja", "ko")]/mods:title/text()},</span>
                    )
                
            else
                    (  
                <span font-style="italic" font-family="{$config:BiblioFont}">{$entry/mods:relatedItem/mods:titleInfo/mods:title/text()},</span>
                     ),
            if (exists ($entry/mods:relatedItem/mods:part/mods:extent/mods:start/text())) then
                        (
                            if (($entry/mods:relatedItem/mods:part/mods:detail/@type="volume") and ($entry/mods:relatedItem/mods:part/mods:detail/@type="no")) then 
                                (
                                <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem/mods:part/mods:detail[@type="volume"]/text()}.{$entry/mods:relatedItem/mods:part/mods:detail[@type="no"]/text()}</span>
                                )
                            else
                                (
                                <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem/mods:part/mods:detail[@type="volume"]/text(),$entry/mods:relatedItem/mods:part/mods:detail[@type="no"]/text()}</span>   
                                )
                        ,<span font-family="{$config:BiblioFont}">{$settings:SPACE}({fn:substring($entry/mods:relatedItem/mods:part/mods:date/text(),1,4)}): {$entry/mods:relatedItem/mods:part/mods:extent/mods:start/text()}–{$entry/mods:relatedItem/mods:part/mods:extent/mods:end/text()}</span>
                        )
            else
               <span font-family="{$config:BiblioFont}">{$entry/mods:relatedItem/mods:part/mods:detail/mods:number/text(), $entry/mods:relatedItem/mods:part/mods:detail/text()}
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
               <span  font-family="{$config:BiblioFont}">. {$settings:SPACE}{$entry/mods:location/mods:url/text()}{$settings:SPACE}</span>,
                <span font-family="{$config:BiblioFont}">(accessed{$settings:SPACE}
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
    <span font-family="{$config:BiblioFont}">"</span>,
    <span>{titleHTML:format-titlenotitalicHTML($entry)}</span>,
    <span font-family="{$config:BiblioFont}">"</span>,
    <span font-family="{$config:BiblioFont}">{$settings:SPACE}</span>,
            if (exists ($entry/mods:relatedItem/mods:titleInfo/@transliteration)) then
                    (
                <span font-style="italic" font-family="{$config:BiblioFont}">{$entry/mods:relatedItem/mods:titleInfo[(@transliteration)]/mods:title/text()}{$settings:SPACE}</span>,
                <span font-family="{$config:ChineseFont}">{$entry/mods:relatedItem/mods:titleInfo[@lang = ("zh", "ja", "ko")]/mods:title/text()},</span>
                    )
                
            else
                    (  
                <span font-style="italic" font-family="{$config:BiblioFont}">{$entry/mods:relatedItem/mods:titleInfo/mods:title/text()},</span>
                     ),
            if (exists ($entry/mods:relatedItem/mods:part/mods:extent/mods:start/text())) then
                        (
                            if (($entry/mods:relatedItem/mods:part/mods:detail/@type="volume") and ($entry/mods:relatedItem/mods:part/mods:detail/@type="no")) then 
                                (
                                <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem/mods:part/mods:detail[@type="volume"]/text()}.{$entry/mods:relatedItem/mods:part/mods:detail[@type="no"]/text()}</span>
                                )
                            else
                                (
                                <span font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:relatedItem/mods:part/mods:detail[@type="volume"]/text(),$entry/mods:relatedItem/mods:part/mods:detail[@type="no"]/text()}</span>   
                                )
                        ,<span font-family="{$config:BiblioFont}">{$settings:SPACE}({fn:substring($entry/mods:relatedItem/mods:part/mods:date/text(),1,4)}): {$entry/mods:relatedItem/mods:part/mods:extent/mods:start/text()}–{$entry/mods:relatedItem/mods:part/mods:extent/mods:end/text()}</span>
                        )
            else
               <span font-family="{$config:BiblioFont}">{$entry/mods:relatedItem/mods:part/mods:detail/mods:number/text(), $entry/mods:relatedItem/mods:part/mods:detail/text()}
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
               <span  font-family="{$config:BiblioFont}">. {$settings:SPACE}{$entry/mods:location/mods:url/text()}{$settings:SPACE}</span>,
                <span font-family="{$config:BiblioFont}">(accessed{$settings:SPACE}
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