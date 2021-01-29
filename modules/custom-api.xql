xquery version "3.1";

(:~
 : This is the place to import your own XQuery modules for either:
 :
 : 1. custom API request handling functions
 : 2. custom templating functions to be called from one of the HTML templates
 :)
module namespace api="http://teipublisher.com/api/custom";

(: Add your own module imports here :)
import module namespace rutil="http://exist-db.org/xquery/router/util";
import module namespace app="teipublisher.com/app" at "app.xql";
import module namespace tpu="http://www.tei-c.org/tei-publisher/util" at "lib/util.xql";
import module namespace pm-config="http://www.tei-c.org/tei-simple/pm-config" at "pm-config.xql";
import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";

declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace catalog="http://exist-db.org/ns/catalog";

declare variable $api:SITES := (
     "HDS", "TC", "SY", "EG", "YC", "DZ", "Sili", "Yin", "PY", "HT", "JS", "Yang", "HSY", "CLS", "FHS", "SNS",
     "Ziyang", "TS", "LS", "Yi", "Tie", "Ge",
     "WFY_1", "WFY_2", "WFY_29", "WFY_33"
);

declare variable $api:PROVINCES := (
    map {
        "name": "Shandong",
        "coordinates": map {
            "latitude": 36.372645,
            "longitude": 118.059082
        }
    },
    map {
        "name": "Sichuan",
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
                <h4 slot="collapse-trigger">{$province?name}</h4>
                <div slot="collapse-content">
                    <ul>
                    {
                        for $site in collection("/db/catalog")/catalog:object[@type=("site", "cave")][catalog:header/catalog:province=$province?name][@xml:id = $api:SITES]
                        let $title := string-join(($site/catalog:header/catalog:title[@lang="zh"], $site/catalog:header/catalog:title[@lang="en"]), " - ")
                        let $coordinates := tokenize($site/*:location/*:coordinates[@srsName="EPSG:4326"], "\s*,\s*")
                        order by $site/catalog:header/catalog:title[@lang="en"], $site/@xml:id
                        return
                            <li>
                                <pb-geolocation id="{$site/@xml:id/string()}" longitude="{$coordinates[1]}" latitude="{$coordinates[2]}" emit="map">{$title}</pb-geolocation>
                            </li>
                    }
                    </ul>
                </div>
            </pb-collapse>
    }
    </div>
};

declare function api:inscriptions($request as map(*)) {
    let $catalog := collection("/db/catalog")/id($request?parameters?site)
    let $title := string-join(($catalog/catalog:header/catalog:title[@lang="zh"], $catalog/catalog:header/catalog:title[@lang="en"]), " - ")
    return
        <div>
            <h1>{$title}</h1>
            {
                for $link in $catalog/catalog:fileDescription/catalog:link/@xlink:href
                let $inscription := collection("/db/catalog")/id($link)
                let $tei := collection("/db/docs")/id($inscription/@xml:id)
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