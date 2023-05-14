xquery version "3.1";

(: 
 : Module for app-specific template functions
 :
 : Add your own templating functions here, e.g. if you want to extend the template used for showing
 : the browsing view.
 :)
module namespace app="teipublisher.com/app";

declare namespace templates = "http://exist-db.org/xquery/html-templating";
import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function app:pb-document($node as node(), $model as map(*), $site as xs:string?) {
    <pb-document path="Publication/Site_{$site}.xml" root-path="{$config:data-root}">
    { $node/@* }
    </pb-document>
};

declare function app:pb-document-catalog($node as node(), $model as map(*), $site as xs:string?) {
    <pb-document path="catalog/{$site}_Site.xml" root-path="{$config:data-root}">
    { $node/@* }
    </pb-document>
};