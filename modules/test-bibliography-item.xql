xquery version "3.1";
(:this file is for testing the single Bibliography Item:)
import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";
import module namespace query="http://www.tei-c.org/tei-simple/query" at "query.xql";
import module namespace facets="http://teipublisher.com/facets" at "facets.xql";
import module namespace custom="http://teipublisher.com/api/custom" at "custom-api.xql";

declare namespace catalog="http://exist-db.org/ns/catalog";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace c = "http://exist-db.org/ns/catalog";

let $request := map {
    "parameters": map {
        "id": "Hay2019"
        (:replace the id:)
    }
}
return
    custom:biblio-test($request)
