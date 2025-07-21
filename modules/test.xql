xquery version "3.1";
(:this file is only for test:)
import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";
import module namespace query="http://www.tei-c.org/tei-simple/query" at "query.xql";
import module namespace facets="http://teipublisher.com/facets" at "facets.xql";
import module namespace custom="http://teipublisher.com/api/custom" at "custom-api.xql";

declare namespace catalog="http://exist-db.org/ns/catalog";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace c = "http://exist-db.org/ns/catalog";

(:
declare function local:find-dynasties-with-multiple-ids-concise() {
  distinct-values(
    for $d in collection($config:data-biblio)/reign_mentions_summary/reign_entry/dynasty_info
    let $dynasty-name-key := if (normalize-space($d/dynasty_name_zh) != "") then normalize-space($d/dynasty_name_zh) else normalize-space($d/dynasty_name_en)
    group by $name := $dynasty-name-key
    where count(distinct-values($d/dynasty_id)) > 1
    return $name
  )
}; 
local:find-dynasties-with-multiple-ids-concise():)
let $request := map {
    "parameters": map {
        "Tnumber": "T_1360"
    }
}

return
    custom:text-details($request)
    (:collection($config:data-catalog)//catalog:ref[@type="taisho"][count(catalog:pages) > 1]:)
