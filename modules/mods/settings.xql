xquery version "3.0";

module namespace settings="http://www.stonesutras.org/publication/fo/modules/settings";
import module namespace config="http://www.stonesutras.org/publication/config" at "fo-config.xql";



declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mads="http://www.loc.gov/mads/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $settings:CHINESE_FONT := $config:ChineseFont;
declare variable $settings:STANDARD_FONT := $config:BiblioFont;
declare variable $settings:SPACE := " ";


declare function settings:get-font($elem as element()*) {
    if ($elem/@lang = ("en", "de", "fr")) then
        $config:BiblioFont
    else
        $config:ChineseFont
    
};

declare function settings:getrelateditem($entry as element(mods:mods)) {
    let $authRef := ($entry//mods:relatedItem/@xlink:href)[1]/string()
   
    return
          if (fn:starts-with($authRef, "#")) then
        
        collection("/db/apps/stonesutras-data/data/biblio")//mods:mods[@ID = substring($authRef, 2)]
        
        else
        collection("/db/apps/stonesutras-data/data/biblio")//mods:mods[@ID=$authRef]};

    declare function settings:getreftitle($entry as element(mods:mods)) {
    let $authRef := ($entry//mods:relatedItem/@xlink:href)[1]/string()
   
    return
        if (fn:starts-with($authRef, "#")) then
        
        collection("/db/apps/stonesutras-data/data/biblio")//mods:mods[@ID = substring($authRef, 2)]/mods:titleInfo[@type="reference"]/mods:title/text()
        
        else
        collection("/db/apps/stonesutras-data/data/biblio")//mods:mods[@ID=$authRef]/mods:titleInfo[@type="reference"]/mods:title/text()
};

    declare function settings:reprint-getreftitle($entry as element(mods:mods)) {
    let $authRef := ($entry//mods:relatedItem[2]/@xlink:href [1])/string()
   
    return
        if (fn:starts-with($authRef, "#")) then
        
        collection("/db/apps/stonesutras-data/data/biblio")//mods:mods[@ID = substring($authRef, 2)]/mods:titleInfo[@type="reference"]/mods:title/text()
        
        else
        collection("/db/apps/stonesutras-data/data/biblio")//mods:mods[@ID=$authRef]/mods:titleInfo[@type="reference"]/mods:title/text()
};