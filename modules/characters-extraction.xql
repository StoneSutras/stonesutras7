xquery version "3.1";

declare namespace c = "http://exist-db.org/ns/catalog";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "text";
declare option output:media-type "text/csv";
declare option output:encoding "UTF-8";

let $collection-path := "/db/apps/stonesutras-data/data/catalog"

let $documents := collection($collection-path)

let $csv-header := "Variant_filename_with_extension,char,Source,date_range_lower,date_range_upper,date_point,title_zh,title_en,URL,column,row,height(cm),width(cm),engraving_width(cm),engraving_depth(cm),condition(scale),condition,"

let $csv-rows := for $doc in $documents
    let $filename := fn:tokenize(base-uri($doc), '/')[last()]
    let $id := data($doc//@xml:id[1]) 
    let $link := if ($id) then concat("https://www.stonesutras.org/inscriptions/", $id) else ""
    let $title-zh := normalize-space(string-join($doc//c:title[@lang="zh"]//text(), ""))
    let $title-en := normalize-space(string-join($doc//c:title[@lang="en"]//text(), ""))
    let $title-zh := fn:replace($title-zh, "[\r\n]+", " ")
    let $title-en := fn:replace($title-en, "[\r\n]+", " ")
    let $characters := $doc//c:character
    let $date-gregorian := $doc//c:date/c:gregorian
    let $date_range_lower := ($date-gregorian/c:range/@lower)[1]
    let $date_range_upper := ($date-gregorian/c:range/@upper)[1]
    let $date_point := ($date-gregorian/c:point)[1]
    for $char in $characters
    where $char/@char != ""
    let $engraving := $char/c:engraving
    let $engraving_width_point := ($engraving/c:width/c:point)[1]
    let $engraving_depth_point := ($engraving/c:depth/c:point)[1]
    let $condition := $char/c:condition
    let $condition_type := data($condition/@grade)[1]
    let $condition_text := normalize-space(string-join($condition//text(), " "))
    return string-join((
        '"' || $filename || '"',
        '"' || data($char/@char) || '"',
        '"' || $id || '"',
        '"' || data($date_range_lower) || '"',
        '"' || data($date_range_upper) || '"',
        '"' || data($date_point) || '"',
        '"' || $title-zh || '"',
        '"' || $title-en || '"',
        '"' || $link || '"',
        '"' || data($char/@column) || '"',
        '"' || data($char/@row) || '"',
        '"' || data($char/@height) || '"',
        '"' || data($char/@width) || '"',
        '"' || data($engraving_width_point) || '"',
        '"' || data($engraving_depth_point) || '"',
        '"' || $condition_type || '"',
        '"' || $condition_text || '"'
    ), ",")

let $csv-content := string-join(($csv-header, string-join($csv-rows, "&#xA;")), "&#xA;")

return $csv-content
