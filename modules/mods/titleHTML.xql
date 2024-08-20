xquery version "3.0";

module namespace titleHTML="http://www.stonesutras.org/publication/fo/modules/titleHTML";

import module namespace settings="http://www.stonesutras.org/publication/fo/modules/settings" at "settings.xql";
import module namespace config="http://www.stonesutras.org/publication/config" at "fo-config.xql";
import module namespace tei2fo="http://www.stonesutras.org/publication/tei2fo" at "tei2fo.xql";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mads="http://www.loc.gov/mads/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace tei="http://www.tei-c.org/ns/1.0";



declare function titleHTML:format-titleHTML($settings as element(mods:mods)) {
    let $transliteration := $settings/mods:titleInfo[@transliteration]
    let $title := $settings/mods:titleInfo[not(@transliteration)][not(@type)]
    let $TitleTranslation := $settings/mods:titleInfo[@type="translated"][@lang="en"]
    let $displayTitle := ($title[@lang != ("en", "de", "fr")], $title[@lang = ("en", "de", "fr")], $title[not(@lang)])[1]
    return (
        if (exists($transliteration)) then (
            <i>{tei2fo:process-biblioHTML($transliteration/mods:title)}{$settings:SPACE}</i>,<span font-family="{settings:get-font($title)}">{tei2fo:process-biblioHTML($displayTitle/mods:title)}</span> 
        ) else
            (<i>{tei2fo:process-biblioHTML($displayTitle/mods:title)}</i> ),
         if(exists($TitleTranslation)) then (
            <span lang="en">{$settings:SPACE}[{tei2fo:process-biblioHTML($TitleTranslation/mods:title)}]</span>    
             )    
           else
            (),
            if (ends-with($title, "?")) then ()
            else
            "."
    )
    
};   


declare function titleHTML:format-titlenotitalicHTML($settings as element(mods:mods)) {
    let $transliteration := $settings/mods:titleInfo[@transliteration]
    let $title := $settings/mods:titleInfo[not(@transliteration)][not(@type)]
    let $TitleTranslation := $settings/mods:titleInfo[@type="translated"][@lang="en"]
    let $displayTitle := ($title[@lang != ("en", "de", "fr")], $title[@lang = ("en", "de", "fr")], $title[not(@lang)])[1]
    return (
        if (exists($transliteration)) then (
            <span  lang="en">{tei2fo:process-biblioHTML($transliteration/mods:title)}{$settings:SPACE}</span>
        ) else
            (),
        <span font-family="{settings:get-font($title)}">{tei2fo:process-biblioHTML($displayTitle/mods:title)}</span> ,
         if(exists($TitleTranslation)) then (
            <span lang="en">{$settings:SPACE}[{tei2fo:process-biblioHTML($TitleTranslation/mods:title)}]</span>    
             )    
           else
            (),
            if (ends-with($title, "?")) then ()
            else
            "."
    )
    
};   

declare function titleHTML:articleinmonograph-seriesHTML($settings as element(mods:mods)) {
    let $transliteration := $settings/mods:titleInfo[@transliteration]
    let $title := $settings/mods:titleInfo[not(@transliteration)][not(@type)]
    let $TitleTranslation := $settings/mods:titleInfo[@type="translated"][@lang="en"]
    let $displayTitle := ($title[@lang != ("en", "de", "fr")], $title[@lang = ("en", "de", "fr")], $title[not(@lang)])[1]
    return (
        if (exists($transliteration)) then (
            <i>{tei2fo:process-biblioHTML($transliteration/mods:title)}{$settings:SPACE}</i>
        ) else
            (),
        <i>{tei2fo:process-biblioHTML($displayTitle/mods:title)}</i> ,
         if(exists($TitleTranslation)) then (
            <span lang="en">{$settings:SPACE}[{tei2fo:process-biblioHTML($TitleTranslation/mods:title)}]</span>    
             )    
           else
            (),
            ","
    )
    
};  

declare function titleHTML:extensionHTML($settings as element(mods:mods)) {
    let $extension := $settings/mods:extension/text()

    return 
    
        if (exists($extension)) then 
            
        (
            <span lang="en">{$settings:SPACE}{$extension}{$settings:SPACE}</span>
        )    
        else
            ()
    
    
};  


