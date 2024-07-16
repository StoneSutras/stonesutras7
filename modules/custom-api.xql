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
import module namespace iiif="https://stonesutras.org/api/iiif" at "iiif.xql";
import module namespace nav="http://www.tei-c.org/tei-simple/navigation/tei" at "navigation-tei.xql";
import module namespace vapi="http://teipublisher.com/api/view" at "lib/api/view.xql";
import module namespace errors = "http://e-editiones.org/roaster/errors";
import module namespace query="http://www.tei-c.org/tei-simple/query" at "query.xql";
import module namespace facets="http://teipublisher.com/facets" at "facets.xql";
import module namespace template="http://exist-db.org/xquery/html-templating";
import module namespace modsHTML="http://www.loc.gov/mods/v3" at "mods/bibliooutputHTML.xql"; 

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace catalog="http://exist-db.org/ns/catalog";
declare namespace tei="http://www.tei-c.org/ns/1.0";


declare variable $api:SITES := (
     "HDS", "TC", "SY", "EG", "YC", "DZ", "Sili", "Yin", "PY", "HT", "JS", "Yang", "HSY", "CLS", "FHS", "SNS",
     "Ziyang", "TS", "LS", "Yi", "Tie", "Ge", "GS", "JCW_east", "JCW_west", "YS", "Ziyang_site", "JSY",
     "WFY_1", "WFY_2", "WFY_29", "WFY_33", "WFY_46", "WFY_51", "WFY_59", "WFY_66", "WFY_71", "WFY_73", 
     "WFY_76", "WFY_85", "WFY_109", "WFY_110"
);

declare variable $api:PROVINCES := (
    map {
        "name": "Shandong Province",
        "name_zh": "山東省",
        "coordinates": map {
            "latitude": 36.372645,
            "longitude": 118.059082
        }
    },
    map {
        "name": "Sichuan Province",
        "name_zh": "四川省",
        "coordinates": map {
            "latitude": 30.694612,
            "longitude": 102.392578
        }
    },
    map {
        "name": "Shaanxi Province",
        "name_zh": "陝西省",
        "coordinates": map {
            "latitude": 30.694612,
            "longitude": 102.392578
        }
    }
);

declare function api:resolve($request as map(*)) {
    let $byId := 
        collection($config:data-docs)/id($request?parameters?id) |
        collection($config:data-publication)/id($request?parameters?id)
    let $root :=
        if ($byId) then
            $byId
        else
            doc($config:data-root || "/" || $request?parameters?collection || "/" || $request?parameters?idOrDoc)
    return
        if ($root) then
            vapi:view(
                map:merge((
                    $request, 
                    map { 
                        "parameters": map:merge((
                            $request?parameters,
                            map {
                                "docid": substring-after(document-uri(root($root)), $config:data-root || '/'),
                                "id": if ($byId) then $request?parameters?id else (),
                                "data-root": $config:data-root
                            }
                        ))
                    }
                ))
            )
        else
            error($errors:NOT_FOUND, "Document " || $request?parameters?id || " not found")
};

declare function api:inscription-table($request as map(*)) {
    let $lang := replace($request?parameters?language, "^([^_-]+)[_-].*$", "$1")
    let $query := $request?parameters?search
    let $inscriptions :=
        let $catalogs := 
            if ($query and $query != "") then
                collection($config:data-catalog)/catalog:object[ft:query(., "site:* AND type:inscription AND title:(" || $query || ")", query:options(()))]
            else
                collection($config:data-catalog)/catalog:object[ft:query(., "site:* AND type:inscription", query:options(()))]
        let $nil := session:set-attribute($config:session-prefix || ".inscriptions", $catalogs)
        for $catalog in $catalogs
        order by $catalog/@xml:id
        let $siteId := ft:field($catalog, "site")
        let $site := collection($config:data-catalog)/id($siteId)[@type=("site", "cave")]
        let $title := (
            $catalog/catalog:header/catalog:title[@*:lang="zh"]/string(),
            <br/>,
            $catalog/catalog:header/catalog:title[@*:lang="en"]/string()
        )
        let $taisho := $catalog/catalog:references/catalog:ref[@type="taisho"]
        (: 
        <c:date>
            <c:gregorian type="case-date-point">
                <c:range lower="" upper=""/>
                <c:point>570</c:point>
            </c:gregorian>
            <c:original>武平元年</c:original>
            <c:given/>
        </c:date>
        :)
        let $datePoint := $catalog//catalog:date/catalog:gregorian/catalog:point
        let $date :=
            if ($datePoint/text()) then
                "(" || $catalog//catalog:date/catalog:gregorian/catalog:point || ")"
            else
                ()
        return
            map {
                "id": translate($catalog/@xml:id, '_', ' '),
                "site": <a href="sites/{$siteId}">{$site/catalog:header/catalog:title[@*:lang=$lang]/string()}</a>,
                "title": <a href="inscriptions/{$catalog/@xml:id}">{$title}</a>,
                "taisho": api:taisho-refs($taisho),
                "date": <span>{$catalog//catalog:date/catalog:original} {$date}</span>
            }
    return
        map {
            "count": count($inscriptions),
            "results": array { subsequence($inscriptions, $request?parameters?start, $request?parameters?limit) }
        }
};

declare function api:taisho-refs($refs as element(catalog:ref)*) {
    <ul class="taisho">
    {
    for $ref in $refs
    return
        <li>{$ref/@xlink:href/string(), " ", $ref/catalog:pages/text()}</li>
    }
    </ul>
};

declare function api:sites($request as map(*)) {
    <div>
    {
        for $province in $api:PROVINCES
        return
            <pb-collapse class="province">
                <h4 slot="collapse-trigger">{$province?name_zh} {$province?name}</h4>
                <div slot="collapse-content">
                    <ul>
                    {
                        for $site in collection($config:data-catalog)/catalog:object[@type=("site", "cave")][catalog:header/catalog:province=$province?name][@xml:id = $api:SITES]
                        let $title := string-join(($site/catalog:header/catalog:title[@*:lang="zh"], $site/catalog:header/catalog:title[@*:lang="en"]), " - ")
                        let $coordinates := tokenize($site/*:location/*:coordinates[@srsName="EPSG:4326"], "\s*,\s*")
                        order by $site/catalog:header/catalog:title[@*:lang="en"], $site/@xml:id
                        return
                            <li>
                                { 
                if (exists($coordinates)) then
                                        <pb-geolocation id="{$site/@xml:id/string()}" longitude="{$coordinates[1]}" latitude="{$coordinates[2]}" label="{$title}" emit="map">
                                            <a href="sites/{$site/@xml:id}">{$title}</a>
                                        </pb-geolocation>
                                    else
                                        <a href="sites/{$site/@xml:id}">{$title}</a>
                                }
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
    return
        <div>
        {
            for $link in $catalog/catalog:fileDescription/catalog:link[@type="inscription"]/@xlink:href
            let $inscription := collection($config:data-catalog)/id($link)
            let $tei := collection($config:data-docs)/id($inscription/@xml:id)
            where $tei
            let $relPath := $inscription/@xml:id
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
    let $taisho := doc($config:data-root || "/T08n0235.xml")/tei:TEI
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

declare function api:characters($request as map(*)) {
    let $query := $request?parameters?query
    let $matches :=
        if ($query) then
            collection($config:data-root || "/unicode")//char[appearance/@character = $query]
        else
            collection($config:data-root || "/unicode")//char[appearance]
    let $log := util:log('INFO', 'Searching ' || count($matches))
    return
        <div class="characters">
        {
            for $char in $matches
            return
                <a href="{substring($char/@xmlid, 3)}">
                    <div class="character">
                        <div class="count">{count($char/appearance)}</div>
                        <h1>{$char/appearance[1]/@character/string()}</h1>
                        <h2>{$char/@xmlid/string()}</h2>
                    </div>
                </a>
        }
        </div>
};

declare function api:research-articles($request as map(*)) {
    let $lang := replace($request?parameters?language, "^([^_-]+)[_-].*$", "$1")
    let $options := query:options(())
    let $volumes := 
        collection($config:data-publication)//tei:body[ft:query(., "volume:*", $options)][ancestor::tei:TEI//tei:seriesStmt]
    let $nil := session:set-attribute($config:session-prefix || ".articles", $volumes)
    for $volume in $volumes
    group by $id := $volume/ancestor::tei:TEI//tei:seriesStmt/tei:title[1]/@n
    order by $id
    let $seriesStmt := head($volume/ancestor::tei:TEI)/tei:teiHeader//tei:seriesStmt
    return
        <div class="volume">
            <h2>{$seriesStmt/tei:title[@xml:lang=$lang]/string()}</h2>
            {
                for $article in $volume
                let $div := ($article/tei:div[@xml:lang=$lang], $article/tei:div)[1]
                let $id := $article/parent::tei:text/@xml:id
                let $head := $pm-config:web-transform($div/tei:head[1], map { "mode": "articles" }, "stonesutras.odd")
                order by number(root($article)//tei:seriesStmt//tei:biblScope/@n)
                return
                    <div class="article">
                        <a href="articles/{$id}">{$head}</a>
                        <p>{$div/tei:head[@type="author"]/string()}</p>
                    </div>
            }
        </div>
};

declare function api:article-facets($request as map(*)) {
    
    let $hits := session:get-attribute($config:session-prefix || ".articles")
    where count($hits) > 0
    return
        <div>
        {
            for $config in $config:article-facets?*
            return
                facets:display($config, $hits)
        }
        </div>
};

declare function api:catalog-facets($request as map(*)) {
    
    let $hits := session:get-attribute($config:session-prefix || ".inscriptions")
    where count($hits) > 0
    return
        <div>
        {
            for $config in $config:catalog-facets?*
            return
                facets:display($config, $hits)
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

(:
declare function api:sites-new($request as map(*)) {
    <div>
    {
        let $lang := replace($request?parameters?language, "^([^_]+)_.*$", "$1")
        let $all := collection($config:data-catalog)/catalog:object[ft:query(., "type:inscription", query:options(()))]
        let $nil := session:set-attribute($config:session-prefix || ".inscriptions", $all)
        for $catalog in $all
        let $title := $catalog/catalog:header/catalog:title[@*:lang=$lang]
        let $coordinates := tokenize($catalog/catalog:location/catalog:coordinates[@srsName="EPSG:4326"], "\s*,\s*")
        where count($coordinates) = 2
        return
            <pb-geolocation id="{$catalog/@xml:id}" longitude="{$coordinates[1]}" latitude="{$coordinates[2]}" 
                label="{$title} – {$catalog/@xml:id}" emit="map">
            { 
                if (ft:field($catalog, "type") = "site") then
                    attribute icon { "site" }
                else
                    ()
            }
            </pb-geolocation>
    }
    </div>
};
:)

declare function api:bibliography($request as map(*)) {
    let $lang := replace($request?parameters?language, "^([^_-]+)[_-].*$", "$1")
    let $query := $request?parameters?search
    let $start := if (exists($request?parameters?start)) then xs:double($request?parameters?start) else 1
    let $limit := if (exists($request?parameters?limit)) then xs:double($request?parameters?limit) else 50
    
    let $precomputed-references :=
        try {
            doc($config:app-root || '/modules/mods/bibliography-table.xml')/*:bibliographies/*:reference
        } catch * {
            error(xs:QName("file-not-found"), "The precomputed bibliography file does not exist.")
        }
    
    let $filtered-references :=
        if ($query) then
            for $ref in $precomputed-references
            let $biblioID := fn:string($ref/@id)
            let $ref_title := fn:string($ref/@title)
            where contains(lower-case($ref), lower-case($query))
            order by $biblioID
            return map {
                "biblioID": $biblioID,
                "title": <a href="bibliography-details.html?id={$biblioID}" target="_blank">{$ref_title}</a>,
                "full_reference": fn:string($ref)
            }
        else
            for $ref in $precomputed-references
            let $biblioID := fn:string($ref/@id)
            let $ref_title := fn:string($ref/@title)
            order by $biblioID
            return map {
                "biblioID": $biblioID,
                "title": <a href="bibliography-details.html?id={$biblioID}" target="_blank">{$ref_title}</a>,
                "full_reference": fn:string($ref)
            }
    
    let $sorted-references := subsequence($filtered-references, $start, $limit)
    
    return map {
        "count": count($filtered-references),
        "results": array { $sorted-references }
    }
};


declare function api:bibliography-details($request as map(*)) {
    let $biblioID := $request?parameters?id

    let $mods :=
        collection($config:data-biblio)/*:mods[@ID = $biblioID]

    return if (exists($mods)) then
        element result {
            $mods
        }
    else
        error(xs:QName("not-found"), concat("The bibliography entry with ID '", $biblioID, "' does not exist."))
};

(:used for generating the precached xml or static html:)
declare function api:bibliography-table($request as map(*)) {
    let $start := if (exists($request?parameters?start)) then xs:double($request?parameters?start) else 1
    let $limit := if (exists($request?parameters?limit)) then xs:double($request?parameters?limit) else 5003
    let $bibliographies :=
        let $files :=
                collection($config:data-biblio)/*:mods[*:titleInfo[@type = "reference"]]
        for $biblio in $files
        order by $biblio/@ID
        let $title := $biblio/*:titleInfo[@type = "reference"]/*:title/string()
        
        let $foentry :=
            try {
                modsHTML:format-biblioHTML($biblio)
            } catch * {
                $title
            }
        let $output := element p { $foentry }
                
      
        return
            map {
                "biblioID": string($biblio/@ID),
                "title":$title,
                "full_reference": fn:string($output)
            }
    return
        map {
            "count": count($bibliographies),
            "results": array { subsequence($bibliographies, $start, $limit) }
        }
};
