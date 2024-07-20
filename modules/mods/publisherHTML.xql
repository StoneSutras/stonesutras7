xquery version "3.0";

module namespace publisherHTML="http://www.stonesutras.org/publication/fo/modules/publisherHTML";

import module namespace settings="http://www.stonesutras.org/publication/fo/modules/settings" at "settings.xql";
import module namespace config="http://www.stonesutras.org/publication/config" at "fo-config.xql";
import module namespace tei2fo="http://www.stonesutras.org/publication/tei2fo" at "tei2fo.xql";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mads="http://www.loc.gov/mads/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function publisherHTML:output-publisherHTML($entry as element(mods:mods)){
    
    let $publisherTrans :=$entry//mods:originInfo[1]//mods:publisher[1]//mods:namePart[@transliteration]
    let $publisherLangEn := $entry//mods:originInfo[1]//mods:publisher[1]//mods:namePart[@lang = ("en", "de", "fr")]
    let $publisherLangZh := $entry//mods:originInfo[1]//mods:publisher[1]//mods:namePart[@lang = ("ja", "zh", "ko")]
    let $publisher2Trans :=$entry//mods:originInfo[1]/mods:publisher[2]//mods:namePart[@transliteration]
    let $publisher2LangEn := $entry//mods:originInfo[1]/mods:publisher[2]//mods:namePart[@lang = ("en", "de", "fr")]
    let $publisher2LangZh := $entry//mods:originInfo[1]/mods:publisher[2]//mods:namePart[@lang = ("ja", "zh", "ko")]
    let $placeLangEn:= $entry//mods:originInfo[1]//mods:placeTerm[@lang = ("de", "en", "fr")]
    let $placeLangZh:= $entry//mods:originInfo[1]//mods:placeTerm[@lang = ("ja", "zh", "ko")]
    let $place:= $entry//mods:originInfo[1]//mods:placeTerm[not(@lang)]
    let $placeTrans := $entry//mods:originInfo[1]//mods:placeTerm[@transliteration = ("pinyin", "romaji", "others")]
    return 
    
    if ((exists($publisherTrans)) or (exists($publisherLangEn))) then
        (
        if ((not($publisher2Trans)) and (not($publisher2LangEn))) then
        (
        if (exists($placeLangZh)) then 
            (
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($placeTrans/text())," ",($placeLangZh/text())}</span>,<span font-family="{$config:BiblioFont}">:{($settings:SPACE),($publisherTrans/text())}</span>,
        if (exists($publisherLangZh/text())) then <span font-family="{$config:ChineseFont}">{($settings:SPACE),($publisherLangZh/text())}</span> else (),
        <span font-family="{$config:BiblioFont}">,</span>
            )
        else 
            (
            if (exists($placeLangEn)) then
                (
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($placeLangEn/text())}</span>,
        <span font-family="{$config:BiblioFont}">:{($settings:SPACE),(tei2fo:process-biblioHTML($publisherLangEn))},</span>
                )
            else
                (
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($place/text())}</span>,
        <span font-family="{$config:BiblioFont}">:{($settings:SPACE),(tei2fo:process-biblioHTML($publisherLangEn))},</span>
                )
            )
        )
        else
          (:two publishers:)  
        (
        if (exists($placeLangZh)) then 
            (
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($placeTrans/text())}</span>,<span font-family="{$config:BiblioFont}">:{($settings:SPACE)}</span>,
        if (exists($publisherLangZh/text())) then <span><span font-family="{$config:BiblioFont}">{($publisherTrans/text()),($settings:SPACE)}</span><span font-family="{$config:ChineseFont}">{($settings:SPACE),($publisherLangZh/text()),($settings:SPACE)}</span>and<span font-family="{$config:BiblioFont}">{($settings:SPACE),($publisher2Trans/text()),($settings:SPACE)}</span><span font-family="{$config:ChineseFont}">{($settings:SPACE),($publisher2LangZh/text())}</span></span> else (),
        <span font-family="{$config:BiblioFont}">,</span>
            )
        else 
            (
            if (exists($placeLangEn)) then
                (
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($placeLangEn/text())}</span>,
        <span font-family="{$config:BiblioFont}">:{($settings:SPACE),($publisherLangEn/text())},</span>
                )
            else
                (
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($place/text())}</span>,
        <span font-family="{$config:BiblioFont}">:{($settings:SPACE),($publisherLangEn/text())},</span>
                )
            )
        )  
        
        
        )
        
        
       
    else (:only place. publisher unknown:)
         
        (
        if (not(exists($placeLangZh)) or not(exists($placeLangEn))) then () else
        if (exists($placeLangZh)) then 
            (
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($placeTrans/text())}</span>
                    )
        else 
            (
            if (exists($placeLangEn)) then
                (
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($placeLangEn/text())},</span>
                )
            else
                (
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($place/text())},</span>
                )
            )
        )
    
};


declare function publisherHTML:output-publisher-reprintHTML($entry as element(mods:mods)){
    
   
    let $reprintdate := data($entry/mods:classification["reprint"]/@edition)
    let $publisherTransReprint :=$entry//mods:originInfo[mods:dateIssued = $reprintdate]/mods:publisher/mods:name/mods:namePart[./@transliteration = ("pinyin", "romaji")]
    let $publisherLangEnReprint := $entry//mods:originInfo[mods:dateIssued = $reprintdate]/mods:publisher/mods:name/mods:namePart[./@lang = ("en", "de", "fr")]
    let $publisherLangZhReprint := $entry//mods:originInfo[mods:dateIssued = $reprintdate]/mods:publisher/mods:name/mods:namePart[./@lang = ("ja", "zh", "ko")]
    let $placeLangEnReprint:= $entry//mods:originInfo[mods:dateIssued = $reprintdate]/mods:place/mods:placeTerm[@lang = ("de", "en", "fr")]
    let $placeLangZhReprint:= $entry//mods:originInfo[mods:dateIssued = $reprintdate]/mods:place/mods:placeTerm[@lang = ("ja", "zh", "ko")]
    let $placeReprint:= $entry//mods:originInfo[mods:dateIssued = $reprintdate]/mods:place/mods:placeTerm[not(@lang)]
    let $placeTransReprint := $entry//mods:originInfo[mods:dateIssued = $reprintdate]/mods:place/mods:placeTerm[@transliteration = ("pinyin", "romaji")]
    return 
    
 

    if ((exists($publisherTransReprint)) or (exists($publisherLangEnReprint))) then
        (
    
        if (exists($placeLangZhReprint)) then 
            (
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($placeTransReprint/text())}</span>,
        <span font-family="{$config:BiblioFont}">:{($settings:SPACE),($publisherTransReprint/text())}</span>,
        <span font-family="{$config:ChineseFont}">{($settings:SPACE),($publisherLangZhReprint/text())},</span>
            )
        else 
            (
            if (exists($placeLangEnReprint)) then
                (
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($placeLangEnReprint/text())}</span>,
        <span font-family="{$config:BiblioFont}">:{($settings:SPACE),($publisherLangEnReprint/text())},</span>
                )
            else
                (
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($placeReprint/text())}</span>,
        <span font-family="{$config:BiblioFont}">:{($settings:SPACE),($publisherLangEnReprint/text())},</span>
                )
            )
        )
    else
        (
    
        if (exists($placeLangZhReprint)) then 
            (
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($placeTransReprint/text())}</span>
                    )
        else 
            (
            if (exists($placeLangEnReprint)) then
                (
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($placeLangEnReprint/text())},</span>
                )
            else
                (
        <span font-family="{$config:BiblioFont}">{($settings:SPACE),($placeReprint/text())},</span>
                )
            )
        )

};
