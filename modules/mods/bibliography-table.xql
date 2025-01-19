xquery version "3.1";

import module namespace api="http://teipublisher.com/api/custom" at "../custom-api.xql";

(: using api:bibliography-table :)
let $bibliographies := api:bibliography-table(map {})

(: sorting by biblioID first letter :)
let $sorted-bibliographies := 
    for $biblio in $bibliographies
    let $first-letter := substring($biblio('biblioID'), 1, 1)
    order by $first-letter
    return $biblio

(: output xml :)
return
<bibliographies>
{
    for $biblio in $sorted-bibliographies
    return
        <reference id="{$biblio('biblioID')}">
            <title>{$biblio('title')}</title>
            <full_reference>{$biblio('full_reference')}</full_reference>
            <copy>{$biblio('copy')}</copy>
        </reference>
}
</bibliographies>
