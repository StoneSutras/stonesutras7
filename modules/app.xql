xquery version "3.1";

(: 
 : Module for app-specific template functions
 :
 : Add your own templating functions here, e.g. if you want to extend the template used for showing
 : the browsing view.
 :)
module namespace app="teipublisher.com/app";

declare namespace templates = "http://exist-db.org/xquery/html-templating";
declare namespace c = "http://exist-db.org/ns/catalog";
declare namespace xlink = "http://www.w3.org/1999/xlink";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function app:pb-document($node as node(), $model as map(*), $site as xs:string?) {
    let $catalog := collection($config:data-catalog)/id($site)
    let $path :=
        if ($catalog/c:fileDescription/c:link[@type="introduction"]) then
            let $id := $catalog/c:fileDescription/c:link[@type="introduction"]/@xlink:href
            let $doc := collection($config:data-root || "/Publication")/id($id)
            return
                substring-after(document-uri(root($doc)), $config:data-root || "/")
        else
            "Publication/Site_" || $site || ".xml"
    return
        <pb-document path="{$path}" root-path="{$config:data-root}">
        { $node/@* }
        </pb-document>
};

declare function app:pb-document-catalog($node as node(), $model as map(*), $site as xs:string?) {
    <pb-document path="catalog/{$site}_Site.xml" root-path="{$config:data-root}">
    { $node/@* }
    </pb-document>
};