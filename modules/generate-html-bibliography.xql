xquery version "3.1";

declare namespace c = "http://exist-db.org/ns/catalog";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "text";
declare option output:media-type "text/csv";
declare option output:encoding "UTF-8";
declare option output:method "html5";

(: Get the precomputed bibliography data :)
let $precomputed-references :=
    try {
        doc('xmldb:exist:///db/apps/stonesutras7/modules/mods/bibliography-table.xml')/*:bibliographies/*:reference
    } catch * {
        (: Handle the case where the file is not found :)
        <p>Error: The precomputed bibliography file does not exist.</p>
    }

return
    <html>
        <head>
            <meta charset="UTF-8"></meta>
            <title>Complete Bibliography</title>
        </head>
        <body>
            <h1>Complete Bibliography</h1>
            {
                if (exists($precomputed-references)) then
                    for $ref in $precomputed-references
                    let $biblioID := fn:string($ref/@id)
                    let $ref_title := fn:string($ref/title)
                    let $full_reference := fn:string($ref/full_reference)
                    let $copy := fn:string($ref/copy)
                    return
                        <div class="reference-entry" id="{$biblioID}">
                            <h3>{$ref_title}</h3>
                            <p>{$full_reference}</p>
                        </div>
                else
                    (: If the file was not found, this will be the output inside the body :)
                    <p>No bibliography data to display.</p>
            }
        </body>
    </html>
