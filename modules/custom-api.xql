xquery version "3.1";

(:~
 : This is the place to import your own XQuery modules for either:
 :
 : 1. custom API request handling functions
 : 2. custom templating functions to be called from one of the HTML templates
 :)
module namespace api="http://teipublisher.com/api/custom";

(: Add your own module imports here :)
import module namespace rutil="http://e-editiones.org/roaster/util";
import module namespace app="teipublisher.com/app" at "app.xql";
import module namespace tpu="http://www.tei-c.org/tei-publisher/util" at "lib/util.xql";
import module namespace pm-config="http://www.tei-c.org/tei-simple/pm-config" at "pm-config.xql";
import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";
import module namespace layout="https://stonesutras.org/api/layout" at "layout.xql";
import module namespace nav="http://www.tei-c.org/tei-simple/navigation/tei" at "navigation-tei.xql";

declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace catalog="http://exist-db.org/ns/catalog";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $api:SITES := (
     "HDS", "TC", "SY", "EG", "YC", "DZ", "Sili", "Yin", "PY", "HT", "JS", "Yang", "HSY", "CLS", "FHS", "SNS",
     "Ziyang", "TS", "LS", "Yi", "Tie", "Ge", "GS", "JCW_east",
     "WFY_1", "WFY_2", "WFY_29", "WFY_33", "WFY_46"
);

declare variable $api:PROVINCES := (
    map {
        "name": "Shandong",
        "name_zh": "山東",
        "coordinates": map {
            "latitude": 36.372645,
            "longitude": 118.059082
        }
    },
    map {
        "name": "Sichuan",
        "name_zh": "四川",
        "coordinates": map {
            "latitude": 30.694612,
            "longitude": 102.392578
        }
    },
    map {
        "name": "Shaanxi",
        "name_zh": "陝西",
        "coordinates": map {
            "latitude": 30.694612,
            "longitude": 102.392578
        }
    }
);

declare function api:sites($request as map(*)) {
    <div>
    {
        for $province in $api:PROVINCES
        return
            <pb-collapse class="province" opened="">
                <h4 slot="collapse-trigger">{$province?name_zh} {$province?name}</h4>
                <div slot="collapse-content">
                    <ul>
                    {
                        for $site in collection($config:data-catalog)/catalog:object[@type=("site", "cave")][catalog:header/catalog:province=$province?name][@xml:id = $api:SITES]
                        let $title := string-join(($site/catalog:header/catalog:title[@lang="zh"], $site/catalog:header/catalog:title[@lang="en"]), " - ")
                        let $coordinates := tokenize($site/*:location/*:coordinates[@srsName="EPSG:4326"], "\s*,\s*")
                        order by $site/catalog:header/catalog:title[@lang="en"], $site/@xml:id
                        return
                            <li>
                                <pb-geolocation id="{$site/@xml:id/string()}" longitude="{$coordinates[1]}" latitude="{$coordinates[2]}" label="{$title}" emit="map">{$title}</pb-geolocation>
                            </li>
                    }
                    </ul>
                </div>
            </pb-collapse>
    }
    </div>
};

declare function api:inscriptions($request as map(*)) {
    let $catalog := collection($config:data-catalog)/id($request?parameters?site)
    let $title := string-join(($catalog/catalog:header/catalog:title[@lang="zh"], $catalog/catalog:header/catalog:title[@lang="en"]), " - ")
    return
        <div>
            <h1>{$title}</h1>
            {
                for $link in $catalog/catalog:fileDescription/catalog:link/@xlink:href
                let $inscription := collection($config:data-catalog)/id($link)
                let $tei := collection($config:data-docs)/id($inscription/@xml:id)
                where $tei
                let $relPath := config:get-relpath($tei[1])
                return
                    <div class="inscription">
                    {
                        $pm-config:web-transform($inscription, map {
                            "mode": "title",
                            "doc": $relPath
                        }, "catalog.odd")
                    }
                    </div>
            }
        </div>
};

declare function api:taisho($id as xs:string) {
    let $taisho := doc("/db/apps/stonesutras7/data/T08n0235.xml")/tei:TEI
    let $start := $taisho//tei:lb[@n = substring-after($id, '_')]
    let $end := $start/following::tei:lb[1]
    return
        <li>
            <h3>{$id}</h3>
            <div>{$start/following::text()[. << $end]}</div>
        </li>
};

declare function api:stonesutras($id as xs:string) {
    for $lb in collection($config:data-root)//tei:lb[@n = $id][@ed = "T"]
    let $end := $lb/following::tei:lb[@ed = "T"][1]
    let $fragment := nav:milestone-chunk($lb, $end, ($lb/ancestor::* intersect $end/ancestor::*)[last()])
    let $html := $pm-config:web-transform($fragment, map { "mode": "synopsis" }, "stonesutras.odd")
    let $relpath := substring-after(document-uri(root($lb)), $config:data-root || "/")
    return
        <li>
            <h3>
                <pb-link path="{$relpath}" emit="transcription">{$lb/ancestor::tei:text/@xml:id/string()}</pb-link>
            </h3>
            <div>{$html}</div>
        </li>
};

declare function api:variants($request as map(*)) {
    let $id := $request?parameters?id
    return
        <ul lang="zh" class="variants">
            { api:taisho($id) }
            { api:stonesutras($id) }
        </ul>
};

(:~
 : Keep this. This function does the actual lookup in the imported modules.
 :)
declare function api:lookup($name as xs:string, $arity as xs:integer) {
    try {
        function-lookup(xs:QName($name), $arity)
    } catch * {
        ()
    }
};