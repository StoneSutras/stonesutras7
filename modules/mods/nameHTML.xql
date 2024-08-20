xquery version "3.0";

module namespace nameHTML="http://www.stonesutras.org/publication/fo/modules/nameHTML";

import module namespace settings="http://www.stonesutras.org/publication/fo/modules/settings" at "settings.xql";
import module namespace config="http://www.stonesutras.org/publication/config" at "fo-config.xql";
import module namespace tei2fo="http://www.stonesutras.org/publication/tei2fo" at "tei2fo.xql";


declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mads="http://www.loc.gov/mads/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace tei="http://www.tei-c.org/ns/1.0";


declare function nameHTML:output-nameHTML($entry as element(mods:mods), $type as xs:string) {
    let $names := $entry/mods:name[mods:role/mods:roleTerm = $type]
    let $outputname := (
        if(exists($names)) then (<span>
                                        {
                                            for $name at $pos in $names
                                            return
                                                (
                                                    (
                                                        (
                                                        if (count($names)=1) then nameHTML:nameHTML($name)
                                                        else
                                                            (
                                                            if ($pos=1)then nameHTML:nameHTML($name)
                                                            else
                                                                nameHTML:name-posgt1HTML($name)
                                                            )
                                                        )     
                                                        
                                                ),
                                                
                                                (
                                                if ($type="commentator") then
                                                (
                                                    if (count($names) = (2, 3)) then
                                                         (
                                                             if (count($names) = 2 and $pos = 1) then ", and "
                                                                    else
                                                                    (
                                                                        if (count($names) = 3 and $pos = (1, 2)) then
                                                                            (
                                                                                if ($pos = 1) then ", "
                                                                                else
                                                                                    (
                                                                                        if ($pos = 2) then
                                                                                        ", and "
                                                                                        else
                                                                                        ", comm. "
                                                                                    )
                                                                            )
                                                                        else
                                                                          ", comm. "  
                                                                    )
                                                         )
                                                    else            
                                                    ", comm. "
                                                        
                                                )
                                                else if ($type="editor") then
                                                (
                                                    if ((count($names) = (2, 3, 4)) and (not($entry/mods:name[1]/mods:role/mods:roleTerm/@type = "etal"))) then
                                                         (
                                                             if (count($names) = 2 and $pos = 1) then ", and "
                                                                    else
                                                                    (
                                                                        if (count($names) = 3 and $pos = (1, 2)) then
                                                                            (
                                                                                if ($pos = 1) then ", "
                                                                                else
                                                                                    (
                                                                                        if ($pos = 2) then
                                                                                        ", and "
                                                                                        else
                                                                                        ", eds. "
                                                                                    )
                                                                            )
                                                                        else
                                                                          (
                                                                        if (count($names) = 4 and $pos = (1, 2, 3)) then
                                                                            (
                                                                                if ($pos = (1, 2)) then ", "
                                                                                else
                                                                                    (
                                                                                        if ($pos = 3) then
                                                                                        ", and "
                                                                                        else
                                                                                        ", eds. "
                                                                                    )
                                                                            )
                                                                        else
                                                                          ", eds. "  
                                                                    )  
                                                                    )
                                                         )
                                                    else
                                                        
                                                     (
                                                    if ($entry/mods:name/mods:role/mods:roleTerm/@type = "etal") 
                                                        then " et al., eds. " 
                                                        else ", ed. "
                                                            )
                                                    
                                                    
                                                        
                                                )   
                                                  
                                                else
                                                (if ($type="translator") then
                                                (
                                                    if (count($names) = (2, 3)) then
                                                         (
                                                             if (count($names) = 2 and $pos = 1) then ", and "
                                                                    else
                                                                    (
                                                                        if (count($names) = 3 and $pos = (1, 2)) then
                                                                            (
                                                                                if ($pos = 1) then ", "
                                                                                else
                                                                                    (
                                                                                        if ($pos = 2) then
                                                                                        ", and "
                                                                                        else
                                                                                        ", trans. "
                                                                                    )
                                                                            )
                                                                        else
                                                                          ", trans. "  
                                                                    )
                                                         )
                                                    else            
                                                    ", trans. "
                                                        
                                                ) 
                                                    else
                                                    (if ($type="author") then
                                                        
                                                    (
                                                        if ((count($names) ge 2) or (not($entry/mods:name[1]/mods:role/mods:roleTerm/@type = "etal"))) then
                                                             (
                                                                if (count($names) = 2 and $pos = 1) then ", and "
                                                                        else
                                                                        (
                                                                            if (count($names) = 3 and $pos = (1, 2)) then
                                                                                (
                                                                                    if ($pos = 1) then ", "
                                                                                    else
                                                                                        (
                                                                                            if ($pos = 2) then
                                                                                            ", and "
                                                                                            else
                                                                                            ". "
                                                                                        )
                                                                                )
                                                                            else
                                                                                if (count($names) gt 3 and $pos != (count($names)))
                                                                                    then 
                                                                                     (if ($pos = (count($names)-1))
                                                                                        then
                                                                                            ", and "
                                                                                        else
                                                                                            ", "
                                                                                    
                                                                                        )
                                                                                    else
                                                                              ". " 
                                                                        )
                                                             )
                                                        else
                                                            (
                                                    if ($entry/mods:name/mods:role/mods:roleTerm/@type = "etal") 
                                                        then " et al. " 
                                                        else ". "
                                                            )
                                                        
                                                    )
                                                    else "DANGER")
                                                )
                                                )
                                                
                                            )
                                        
                                        }
                                    </span>)
            
            else
                ()
                        )
    
    
    return
        nameHTML:replace-dotsHTML($outputname)
};

declare function nameHTML:nameHTML($name as element(mods:name)) {
    (:    ns2:href="#baiqianshen":)
    let $name := util:expand($name)
    let $authRef := substring($name/@xlink:href, 2)
    let $mads := collection("//db/apps/stonesutras-data/data/biblio/authority")/mads:mads[@ID = $authRef][1]
    let $mads := if (exists($mads)) then util:expand($mads) else ()
    return
        if ($name//@type = "penname")
        then
            <span>{nameHTML:mods-pennameHTML($name)} ({nameHTML:mads-nameHTML($mads)})</span>
            else
                (
        if (exists($mads)) then
            nameHTML:mads-nameHTML($mads)
        else
            nameHTML:mods-nameHTML($name)
                )
};

declare function nameHTML:mods-pennameHTML($name as element(mods:name)){
    
   

    let $pennametransliteration := $name/mods:namePart[(@transliteration)][@type="penname"]
    let $penname := $name/mods:namePart[not(@transliteration)][@type="penname"]

    return
         if (exists($pennametransliteration)) then
                                (
                                <span lang="en">{($pennametransliteration/text()),($settings:SPACE)} <span lang="zh">{$penname/text()}</span></span>
                                )
                                else
                                    (
                                    <span lang="en">{$penname/text()}</span>
                                    )

};


declare function nameHTML:name-posgt1HTML($name as element(mods:name)) {
    (:    ns2:href="#baiqianshen":)
    let $name := util:expand($name)
    let $authRef := substring($name/@xlink:href, 2)
    let $mads := collection("//db/apps/stonesutras-data/data/biblio/authority")/mads:mads[@ID = $authRef][1]
    let $mads := if (exists($mads)) then util:expand($mads) else ()
    return
        if (exists($mads)) then
            nameHTML:mads-name-posgt1HTML($mads)
        else
            nameHTML:mods-name-posgt1HTML($name)
};




 declare function nameHTML:mads-nameHTML($mads as element(mads:mads)) {
    let $corporatename := $mads/mads:authority/mads:name[@type="corporate"]/mads:namePart
    let $corporatenametransliteration := $mads/mads:variant[@transliteration]/mads:name[@type="corporate"]/mads:namePart
    let $corporatenametranslation := $mads/mads:variant[@translated]/mads:name[@type="corporate"]/mads:namePart
    let $familyname  := $mads/mads:authority/mads:name/mads:namePart[@type="family"]
    let $givenname := $mads/mads:authority/mads:name/mads:namePart[@type="given"]
    let $familynamevariant  := $mads/mads:variant[not(@transliteration)]/mads:name/mads:namePart[@type="family"]
    let $givennamevariant := $mads/mads:variant[not(@transliteration)]/mads:name/mads:namePart[@type="given"]
    let $familynamevariantCJK  := $mads/mads:variant[@lang = ("zh", "ja", "ko")]/mads:name/mads:namePart[@type="family"]
    let $givennamevariantCJK := $mads/mads:variant[@lang = ("zh", "ja", "ko")]/mads:name/mads:namePart[@type="given"]
    let $familynametransliteration := $mads/mads:variant[@transliteration]/mads:name/mads:namePart[@type="family"]
    let $givennametramsliteration := $mads/mads:variant[@transliteration]/mads:name/mads:namePart[@type="given"]
    
  return
        if ($mads/mads:authority/mads:name/@type="corporate") then
                         
                            if  ($mads/mads:authority/@lang = ("zh", "ja", "ko")) then
                                     (
                                        (
                                        if ($mads/mads:authority/@lang = "zh") then
                                            <span>
                                                <span lang="en">{
                                                (tei2fo:process-biblioHTML($corporatenametransliteration/ancestor::mads:variant[@transliteration="pinyin"]/mads:name/mads:namePart)),
                                                ($settings:SPACE)
                                                }
                                                </span>
                                                <span lang="zh">{($corporatename/text())}</span>
                                                
                                            </span>
                                            
                                       else 
                                             if ($mads/mads:authority/@lang = "ja") then
                                            <span>
                                                <span lang="en">{
                                                (tei2fo:process-biblioHTML($corporatenametransliteration/ancestor::mads:variant[@transliteration="romaji"]/mads:name/mads:namePart)),
                                                ($settings:SPACE)
                                                }
                                                </span>
                                                <span lang="zh">{($corporatename/text())}</span>
                                            </span>
                                            else
                                                <span>
                                                <span lang="en">{
                                                (tei2fo:process-biblioHTML($corporatenametransliteration/ancestor::mads:variant[@transliteration="mccunereischauer"]/mads:name/mads:namePart)),
                                                ($settings:SPACE)
                                                }
                                                </span>
                                                <span lang="zh">{($corporatename/text())}</span>
                                            </span>
                                        ),
                                        if ($corporatenametranslation) then
                                                <span lang="en">{($settings:SPACE),(tei2fo:process-biblioHTML($corporatenametranslation))}
                                                </span>
                                                else
                                                    ()
                                     )
                            else
                                    (<span lang="en">{($corporatename/text())}</span>)
                            
                         
        else
    
                            (  
                                if ($mads/mads:authority/@lang = "sa") then
                                        (
                                     <span lang="en">{($mads/mads:authority[@lang = "sa"]//text()),($settings:SPACE),"(",($mads/mads:variant[@transliteration="pinyin"]/mads:name/mads:namePart/text()),($settings:SPACE)}</span>,
                                             <span lang="zh">{($mads/mads:variant[@lang = "zh"]/mads:name/mads:namePart/text())}</span>, <span lang="en">)</span>
                                        )
                                else
                                if  ($mads/mads:authority/@lang = ("zh", "ja", "ko")) then
                                    (
                                    if ($mads/mads:authority/@lang = "zh") then
                                         <span lang="en">{
                                            ($familynametransliteration/ancestor::mads:variant[@transliteration="pinyin"]/mads:name/mads:namePart[@type="family"]/text()),
                                            ($settings:SPACE),
                                            ($givennametramsliteration/ancestor::mads:variant[@transliteration="pinyin"]/mads:name/mads:namePart[@type="given"]/text()),
                                            ($settings:SPACE)}
                                        </span>
                                    else 
                                        if ($mads/mads:authority/@lang = "ja") then
                                        <span lang="en">{
                                            ($familynametransliteration/ancestor::mads:variant[@transliteration="romaji"]/mads:name/mads:namePart[@type="family"]/text()),
                                            ($settings:SPACE),
                                            ($givennametramsliteration/ancestor::mads:variant[@transliteration="romaji"]/mads:name/mads:namePart[@type="given"]/text()),
                                            ($settings:SPACE)}
                                        </span>
                                        else
                                            (<span lang="en">{
                                            ($familynametransliteration/ancestor::mads:variant[@transliteration="mccunereischauer"]/mads:name/mads:namePart[@type="family"]/text()),
                                            ($settings:SPACE),
                                            ($givennametramsliteration/ancestor::mads:variant[@transliteration="mccunereischauer"]/mads:name/mads:namePart[@type="given"]/text()),
                                            ($settings:SPACE)}
                                            </span>)
                                   ,
                                    <span lang="zh">{($familyname/text()),($givenname/text())}</span>
                                    ,
                                     
                                    if ($familynamevariant/text() and $mads/mads:variant[@lang != ("zh", "ja", "ko")]/@type="expansion") then <span lang="en">{($settings:SPACE),"[",($givennamevariant/text()),($settings:SPACE),($familynamevariant/text()), "]"}</span> else ()
                                    )
                                else
                                    (
                                    <span lang="en">{($familyname/text())},{($settings:SPACE),($givenname/text())}</span>,
                                if ($familynamevariantCJK/text() and $mads/mads:variant[@lang = ("zh", "ja", "ko")]/@type="expansion") then <span lang="zh">{($settings:SPACE),($familynamevariantCJK/text()),($givennamevariantCJK/text())}</span> else ()
                                    )
                            )
};

declare function nameHTML:mads-name-posgt1HTML($mads as element(mads:mads)) {
    let $corporatename := $mads/mads:authority/mads:name[@type="corporate"]/mads:namePart
    let $corporatenametransliteration := $mads/mads:variant[(@transliteration)]/mads:name[@type="corporate"]/mads:namePart
    let $corporatenametranslation := $mads/mads:variant[(@translated)]/mads:name[@type="corporate"]/mads:namePart
    let $familyname  := $mads/mads:authority/mads:name/mads:namePart[@type="family"]
    let $givenname := $mads/mads:authority/mads:name/mads:namePart[@type="given"]
    let $familynamevariant  := $mads/mads:variant/mads:name/mads:namePart[@type="family"]
    let $givennamevariant := $mads/mads:variant/mads:name/mads:namePart[@type="given"]
    let $familynamevariantCJK  := $mads/mads:variant[@lang = ("zh", "ja", "ko")]/mads:name/mads:namePart[@type="family"]
    let $givennamevariantCJK := $mads/mads:variant[@lang = ("zh", "ja", "ko")]/mads:name/mads:namePart[@type="given"]
    let $familynametransliteration := $mads/mads:variant[@transliteration]/mads:name/mads:namePart[@type="family"]
    let $givennametramsliteration := $mads/mads:variant[@transliteration]/mads:name/mads:namePart[@type="given"]
    
  return
        if ($mads/mads:authority/mads:name/@type="corporate") then
                         
                            if  ($mads/mads:authority/@lang = ("zh", "ja", "ko")) then
                                     (
                                        (
                                        if ($mads/mads:authority/@lang = "zh") then
                                            <span>
                                                <span lang="en">{
                                                (tei2fo:process-biblioHTML($corporatenametransliteration/ancestor::mads:variant[@transliteration="pinyin"]/mads:name/mads:namePart)),
                                                ($settings:SPACE)
                                                }
                                                </span>
                                                <span lang="zh">{($corporatename/text())}</span>
                                            </span>
                                            
                                        else 
                                             if ($mads/mads:authority/@lang = "ja") then
                                            <span>
                                                <span lang="en">{
                                                (tei2fo:process-biblioHTML($corporatenametransliteration/ancestor::mads:variant[@transliteration="romaji"]/mads:name/mads:namePart)),
                                                ($settings:SPACE)
                                                }
                                                </span>
                                                <span lang="zh">{($corporatename/text())}</span>
                                            </span>
                                            else
                                                <span>
                                                <span lang="en">{
                                                (tei2fo:process-biblioHTML($corporatenametransliteration/ancestor::mads:variant[@transliteration="mccunereischauer"]/mads:name/mads:namePart)),
                                                ($settings:SPACE)
                                                }
                                                </span>
                                                <span lang="zh">{($corporatename/text())}</span>
                                            </span>
                                        ),
                                        if ($corporatenametranslation) then
                                                <span lang="en">{($settings:SPACE),"(",(tei2fo:process-biblioHTML($corporatenametranslation)),")"}
                                                </span>
                                                else
                                                    ()
                                     )
                            else
                                    (<span lang="en">{($corporatename/text())}</span>)
                            
                         
        else
    
                            (  
                                
                                if  ($mads/mads:authority/@lang = ("zh", "ja", "ko")) then
                                   (
                                    if ($mads/mads:authority/@lang = "zh") then
                                         <span lang="en">{
                                            ($familynametransliteration/ancestor::mads:variant[@transliteration="pinyin"]/mads:name/mads:namePart[@type="family"]/text()),
                                            ($settings:SPACE),
                                            ($givennametramsliteration/ancestor::mads:variant[@transliteration="pinyin"]/mads:name/mads:namePart[@type="given"]/text()),
                                            ($settings:SPACE)}
                                        </span>
                                    else 
                                        if ($mads/mads:authority/@lang = "ja") then
                                        <span lang="en">{
                                            ($familynametransliteration/ancestor::mads:variant[@transliteration="romaji"]/mads:name/mads:namePart[@type="family"]/text()),
                                            ($settings:SPACE),
                                            ($givennametramsliteration/ancestor::mads:variant[@transliteration="romaji"]/mads:name/mads:namePart[@type="given"]/text()),
                                            ($settings:SPACE)}
                                        </span>
                                        else
                                            (<span lang="en">{
                                            ($familynametransliteration/ancestor::mads:variant[@transliteration="mccunereischauer"]/mads:name/mads:namePart[@type="family"]/text()),
                                            ($settings:SPACE),
                                            ($givennametramsliteration/ancestor::mads:variant[@transliteration="mccunereischauer"]/mads:name/mads:namePart[@type="given"]/text()),
                                            ($settings:SPACE)}
                                            </span>)
                                    ,
                                    <span lang="zh">{($familyname/text()),($givenname/text())}</span>
                                    )
                                else
                                    (
                                        
                                    <span lang="en">{($givenname/text()), ($settings:SPACE),($familyname/text())}</span>,
                                if ($familynamevariantCJK/text() and $mads/mads:variant[@lang = ("zh", "ja", "ko")]/@type="expansion") then <span lang="zh">{($settings:SPACE),($familynamevariantCJK/text()),($givennamevariantCJK/text())}</span> else ()
                                    )
                            )
};


declare function nameHTML:replace-dotsHTML($nodes as node()*) {
    for $node in $nodes
    return
    typeswitch($node)
        case text() return
            if (starts-with($node, ".") and ends-with($node/preceding::text()[1], ".")) then
                substring($node, 2)
            else
                $node
        case element() return
            element { node-name($node) } {
                $node/@*, for $child in $node/node() return nameHTML:replace-dotsHTML($child)
            }
        default return ()
};


(: MODS fallback :)

declare function nameHTML:mods-nameHTML($name as element(mods:name)){
    
    let $corporatename := $name[@type="corporate"]/mods:namePart[@lang != ("en", "de", "fr")]
    let $corporatenametransliteration := $name[@type="corporate"]/mods:namePart[(@transliteration)]
    let $corporatenametranslation := $name[@type="corporate"]/mods:namePart[@lang=("en", "de")]
    let $familyname  := $name/mods:namePart[(@lang)][@type="family"]
    let $givenname := $name/mods:namePart[(@lang)][@type="given"]
    let $familynametransliteration := $name/mods:namePart[(@transliteration)][@type="family"]
    let $givennametramsliteration := $name/mods:namePart[(@transliteration)][@type="given"]

    return
        if ($name/@type="corporate") then
                            ( 
                            if (exists($name/mods:namePart/@transliteration)) then
                            (<span lang="en">{($corporatenametransliteration/text())}</span>,
                            <span lang="zh">
                                        {($corporatename/text()), if ($name/mods:namePart/@lang="en") then (<span lang="en">{$settings:SPACE}[{$corporatenametranslation/text()}]</span>) else ()}
                            NO-MADS!</span>)
                            else
                            (<span lang="en">{($corporatename/text())}NO-MADS!</span>)
                            )
                            
        else
    
                            (   if (exists($name/mods:namePart/@transliteration)) then
                                (
                                <span lang="en">{($familynametransliteration/text()),($settings:SPACE),($givennametramsliteration/text())}NO-MADS!</span>,
                                <span lang="zh">{($familyname/text()),($givenname/text())}NO-MADS!</span>
                                )
                                else
                                    (
                                    <span lang="en">{($familyname/text()),($settings:SPACE),($givenname/text())}NO-MADS!</span>
                                    )
                            )

};

declare function nameHTML:mods-name-posgt1HTML($name as element(mods:name)){
    
    let $corporatename := $name[@type="corporate"]/mods:namePart[@lang != ("en", "de", "fr")]
    let $corporatenametransliteration := $name[@type="corporate"]/mods:namePart[(@transliteration)]
    let $corporatenametranslation := $name[@type="corporate"]/mods:namePart[@lang=("en", "de", "fr")]
    let $familyname  := $name/mods:namePart[(@lang)][@type="family"]
    let $givenname := $name/mods:namePart[(@lang)][@type="given"]
    let $familynametransliteration := $name/mods:namePart[(@transliteration)][@type="family"]
    let $givennametramsliteration := $name/mods:namePart[(@transliteration)][@type="given"]

    return
        if ($name/@type="corporate") then
                            ( 
                            if (exists($name/mods:namePart/@transliteration)) then
                            (<span lang="en">{($corporatenametransliteration/text())}</span>,
                            <span lang="zh">
                                        {($corporatename/text()), if ($name/mods:namePart/@lang="en") then (<span lang="en">{$settings:SPACE}[{$corporatenametranslation/text()}]</span>) else ()}
                            NO-MADS!</span>)
                            else
                            (<span lang="en">{($corporatename/text())}NO-MADS!</span>)
                            )
                            
        else
    
                            (   if (exists($name/mods:namePart/@transliteration)) then
                                (
                                <span lang="en">{($familynametransliteration/text()),($settings:SPACE),($givennametramsliteration/text())}NO-MADS!</span>,
                                <span lang="zh">{($familyname/text()),($settings:SPACE),($givenname/text())}NO-MADS!</span>
                                )
                                else
                                    (
                                    <span lang="en">{($givenname/text()),($settings:SPACE),($familyname/text())}NO-MADS!</span>
                                    )
                            )

};
        
