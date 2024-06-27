xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "text";
declare option output:media-type "text/csv";
declare option output:encoding "UTF-8";

let $unicode-path := "/db/apps/stonesutras-data/data/unicode"
let $unicode-documents := collection($unicode-path)

let $csv-header := string-join((
    "appearance:cert",
    "appearance:character",
    "appearance:id",
    "appearance:nr",
    "appearance:original",
    "appearance:preferred_reading",
    "appearance:variant",
    "source",
    "rubbing",
    "graphic",
    "coordinates:height",
    "coordinates:width",
    "coordinates:x",
    "coordinates:y",
    "coordinates:angle"
), ",")

let $csv-rows := for $doc in $unicode-documents
    for $appearance in $doc//appearance
    let $cert := data($appearance/@cert)
    let $character := data($appearance/@character)
    let $id := data($appearance/@id)
    let $nr := data($appearance/@nr)
    let $original := data($appearance/@original)
    let $preferred_reading := data($appearance/@preferred_reading)
    let $variant := data($appearance/@variant)
    let $source := data($appearance/source)
    let $rubbing := data($appearance/rubbing)
    let $graphic := data($appearance/graphic)
    let $base := $appearance/coordinates/base
    let $height := data($base/@height)
    let $width := data($base/@width)
    let $x := data($base/@x)
    let $y := data($base/@y)
    let $angle := data($appearance/coordinates/angle/@phi)

    return string-join((
        '"' || $cert || '"',
        '"' || $character || '"',
        '"' || $id || '"',
        '"' || $nr || '"',
        '"' || $original || '"',
        '"' || $preferred_reading || '"',
        '"' || $variant || '"',
        '"' || $source || '"',
        '"' || $rubbing || '"',
        '"' || $graphic || '"',
        '"' || $height || '"',
        '"' || $width || '"',
        '"' || $x || '"',
        '"' || $y || '"',
        '"' || $angle || '"'
    ), ",")

let $csv-content := string-join(($csv-header, string-join($csv-rows, "&#xA;")), "&#xA;")

return $csv-content
