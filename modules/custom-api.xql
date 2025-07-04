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
declare namespace mads="http://www.loc.gov/mads/";

declare variable $api:SITES := (
     "HDS", "TC", "SY", "EG", "YC", "DZ", "Sili", "Yin", "PY", "HT", "JS", "Yang", "HSY", "CLS", "FHS", "SNS",
     "Ziyang", "TS", "LS", "Yi", "Tie", "Ge", "GS", "JCW_east", "YS", "Ziyang_site", "JSY",
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
            doc($config:data-root || "/" || $request?parameters?id)
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
                                "id": if ($byId) then $request?parameters?id else $root//tei:text/@xml:id,
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
        let $catalogId := analyze-string($catalog/@xml:id, '^([^\d]+)(\d*)\.?(\d*)')
        order by 
            $catalogId//fn:group[@nr='1'],
            if ($catalogId//fn:group[@nr='2']/text()) then
                number($catalogId//fn:group[@nr='2'])
            else
                0,
            if ($catalogId//fn:group[@nr='3']/text()) then
                number($catalogId//fn:group[@nr='3'])
            else
                0
        let $siteId := ft:field($catalog, "site")
        let $site := collection($config:data-catalog)/id($siteId)[@type=("site", "cave")]
        let $title := (
            for $t in $catalog/catalog:header/catalog:title[@*:lang="zh"]/node()
            return $t,
            <br/>,
            let $en-title := $catalog/catalog:header/catalog:title[@*:lang="en" and @type="given"]
            return
                if (empty($en-title)) then
                    for $t in $catalog/catalog:header/catalog:title[@*:lang="en"]/node()
                    return 
                        if (name($t) = "hi" and $t/@rend = "italic") then 
                            element i { $t/node() }
                        else 
                            $t
                else
                    for $t in $en-title/node()
                    return 
                        if (name($t) = "hi" and $t/@rend = "italic") then 
                            element i { $t/node() }
                        else 
                            $t
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

(:
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
};:)

declare function api:characters_thumbnails($request as map(*)) {
    let $query := $request?parameters?query
    let $start := if (exists($request?parameters?start)) then xs:double($request?parameters?start) else 1
    let $per-page := if (exists($request?parameters?per-page)) then xs:double($request?parameters?per-page) else 55

    let $character-table :=
        try {
            doc($config:data-root || '/catalog/characters_table.xml')/character/char
        } catch * {
            error(xs:QName("file-not-found"), "The precomputed character file does not exist.")
        }

    let $filtered-characters :=
        for $char in $character-table
        let $character := fn:string($char/char)
        let $image := fn:string($char/image)
        let $source := fn:string($char/source)
        let $column := fn:string($char/column)
        let $row := fn:string($char/row)
        let $height := fn:string($char/height)
        let $width := fn:string($char/width)
        let $condition := fn:string($char/condition)
        let $date := 
            if ($char/date_point) then
                fn:string($char/date_point)
            else if ($char/date_range_lower or $char/date_range_upper) then
                fn:string($char/date_range_lower) || "–" || fn:string($char/date_range_upper)
            else
                ""
        where normalize-space($image) ne "" and (not($query) or 
              contains(lower-case($character), lower-case($query)))
        order by $char/Source_column_row
        return map {
            "character": $character,
            "imageUrl": "https://sutras.adw.uni-heidelberg.de/images/characters/" || $image,
            "altText": $character,
            "source": replace($source, '_', ' '),
            "column": $column,
            "row": $row,
            "height": $height,
            "width": $width,
            "condition": $condition,
            "date": $date
        }

    let $total-characters := count($filtered-characters)
    let $paginated-characters := subsequence($filtered-characters, $start, $per-page) 

    (: Set HTTP headers for pagination consistency with sapi:search :)
    let $set-headers := (
        response:set-header("pb-total", xs:string($total-characters)),
        response:set-header("pb-start", xs:string($start))
    )

    return
        <div id="thumbnails-container">
        {
            for $item at $p in $paginated-characters  
            return
                <paper-card class="character-card">
                    <div class="matches">
                        <div class="thumbnail-item">
                            <a href="{$item?imageUrl}" target="_blank">
                                <pb-popover theme="light">
                                    <img src="{$item?imageUrl}" alt="{$item?altText}" style="width: 100px; height: 100px;"/>
                                    <template slot="alternate">
                                        <div class="character-details">
                                            { 
                                                if (normalize-space($item?source) ne "") then
                                                    <p><strong>Source: </strong> <a href="https://stonesutras.org/inscriptions/{$item?source}" target="_blank">{$item?source}</a>
                                                    </p>
                                                else ()
                                            }
                                            {
                                                if (normalize-space($item?date) ne "") then
                                                    <p><strong>Date: </strong> {$item?date}</p>
                                                else ()
                                            }
                                            {
                                                if (normalize-space($item?column) ne "" and normalize-space($item?row) ne "") then
                                                    <p><strong>Column/Row: </strong> {$item?column}/{$item?row}</p>
                                                else ()
                                            }
                                            {
                                                if (normalize-space($item?height) ne "" and normalize-space($item?width) ne "") then
                                                    <p><strong>Height/Width: </strong> {$item?height}/{$item?width}</p>
                                                else ()
                                            }
                                            {
                                                if (normalize-space($item?condition) ne "") then
                                                    <p><strong>Condition: </strong> {$item?condition}</p>
                                                else ()
                                            }
                                        </div> 
                                    </template>
                                </pb-popover>
                            </a>
                            <p class="character-name">
                                {$item?character}
                                { 
                                    if (normalize-space($item?source) ne "") then
                                        " (" || $item?source || ")"
                                    else () 
                                }
                            </p>
                            
                        </div>
                    </div>
                </paper-card>
        }
        </div>
};

declare function api:characters_new($request as map(*)) {
    let $query := $request?parameters?search
    let $start := if (exists($request?parameters?start)) then xs:double($request?parameters?start) else 1
    let $limit := if (exists($request?parameters?limit)) then xs:double($request?parameters?limit) else 50
    
    let $character-table :=
        try {
            doc($config:data-root || '/catalog/characters_table.xml')/character/char
        } catch * {
            error(xs:QName("file-not-found"), "The precomputed character file does not exist.")
        }
    
    let $filtered-characters :=
        for $char in $character-table
        let $character := fn:string($char/char)
        let $inscription_title := fn:string($char/title_zh) || fn:string($char/title_en)
        let $image := fn:string($char/image)
        let $source := fn:string($char/source)
        let $columnrow := fn:string($char/column) || "/" || fn:string($char/row)
        let $heightwidth := fn:string($char/height) || "/" || fn:string($char/width)
        let $condition := fn:string($char/condition)
        let $date := 
            if ($char/date_point) then
                fn:string($char/date_point)
            else if ($char/date_range_lower or $char/date_range_upper) then
                fn:string($char/date_range_lower) || "–" || fn:string($char/date_range_upper)
            else
                ""
        where normalize-space($image) ne "" and (not($query) or 
              contains(lower-case($character), lower-case($query)))
        order by $char/Source_column_row
        return map {
            "character": $character,
            "image": <a href="https://sutras.adw.uni-heidelberg.de/images/characters/{$image}" target="_blank">
                        <img src="https://sutras.adw.uni-heidelberg.de/images/characters/{$image}" alt="{$character}" style="width: 100px; height: auto;"/>
                     </a>,
            "columnrow": $columnrow,
            "heightwidth": $heightwidth,
            "source": <a href="https://stonesutras.org/inscriptions/{$source}" target="_blank">{$source}</a>,
            "date": $date,
            "condition": $condition
        }
    
    let $sorted-characters := subsequence($filtered-characters, $start, $limit)
    
    return map {
        "count": count($filtered-characters),
        "results": array { $sorted-characters }
    }
};


declare function api:places($request as map(*)) {
  let $lang := replace($request?parameters?language, "^([^_-]+)[_-].*$", "$1")
  let $search := $request?parameters?search
  let $options := query:options(())

  let $query := if ($search and normalize-space($search) != "") 
                then $search 
                else "*:*"
  
  let $places := collection($config:data-biblio)/places/place[@type != ""][ft:query(., $query, $options)]

  let $nil := session:set-attribute($config:session-prefix || ".places", $places)

  let $grouped :=
    for $type in distinct-values($places/@type)
    order by $type
    return
      <div class="place-category">
        <h2>{$type}</h2>
        {
          for $place in $places[@type = $type]
            let $id := string($place/@id)
            let $name_zh := normalize-space($place/name_zh)
            let $name_en := normalize-space($place/name_en)
            let $final_name_with_dates := 
              if ($name_zh != "" and $name_en != "") then
                concat($name_en, "  ", $name_zh)
              else if ($name_zh != "") then
                $name_zh
              else
                $name_en
            order by lower-case($final_name_with_dates)
            let $href := concat("place.html?id=", $id)
            return <div class="place"><a>{$final_name_with_dates}</a></div>
        }
      </div>

  return <div class="all-places">{$grouped}</div>
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

declare function api:place-facets($request as map(*)) {
    
    let $hits := session:get-attribute($config:session-prefix || ".places")
    where count($hits) > 0
    return
        <div>
        {
            for $config in $config:place-facets?*
            return
                facets:display($config, $hits)
        }
        </div>
};

declare function api:image-facets($request as map(*)) {
    
    let $hits := session:get-attribute($config:session-prefix || ".images")
    where count($hits) > 0
    return
        <div>
        {
            for $config in $config:image-facets?*
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
            let $ref_title := fn:string($ref/title)
            let $full_reference := fn:string($ref/full_reference)
            let $copy := fn:string($ref/copy)
            where contains(lower-case($ref), lower-case($query)) 
               or contains(lower-case($biblioID), lower-case($query))
            order by $biblioID
            return map {
                "biblioID": $biblioID,
                "title": <a href="bibliography-details.html?id={$biblioID}" target="_blank">{$ref_title}</a>,
                "full_reference": $full_reference,
                "copy": $copy
            }
        else
            for $ref in $precomputed-references
            let $biblioID := fn:string($ref/@id)
            let $ref_title := fn:string($ref/title)
            let $full_reference := fn:string($ref/full_reference)
            let $copy := fn:string($ref/copy)
            order by $biblioID
            return map {
                "biblioID": $biblioID,
                "title": <a href="bibliography-details.html?id={$biblioID}" target="_blank">{$ref_title}</a>,
                "full_reference": $full_reference,
                "copy": $copy
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

(:used for testing a single bibliography entry:)
declare function api:biblio-test($request as map(*)) {
    let $biblioID := $request?parameters?id
    let $mods :=
        collection($config:data-biblio)/*:mods[@ID = $biblioID]
    
    return if (exists($mods)) then
        <div>
            <meta charset="utf-8"/>
            {modsHTML:format-biblioHTML($mods)}
        </div>
    else
        error(xs:QName("not-found"), concat("The bibliography entry with ID '", $biblioID, "' does not exist."))
};

(:used for generating the precached xml or static html:)
declare function api:bibliography-table($request as map(*)) as map(*)* {
    let $files := collection($config:data-biblio)/*:mods[*:titleInfo[@type = "reference"]]
    return
        for $biblio in $files
        let $biblioID := string($biblio/@ID)
        let $title := $biblio/*:titleInfo[@type = "reference"]/*:title/string()
        let $foentry := 
            try {
                modsHTML:format-biblioHTML($biblio)
            } catch * {
                $title
            }
        let $full_reference := fn:serialize($foentry)
        let $copy := 
            concat(
                '&lt;pb-clipboard label=&quot;&quot;&gt;',
                $full_reference,
                '&lt;/pb-clipboard&gt;'
            )
        return map {
            "biblioID": $biblioID,
            "title": $title,
            "full_reference": $full_reference,
            "copy": $copy
        }
};


declare function api:persons($request as map(*)) {
    let $search := normalize-space($request?parameters?search)
    let $letterParam := $request?parameters?category
    let $persons := api:persons-name-to-display($search)
    let $sortedPersons := 
        for $person in $persons
        let $sortKey := lower-case(string($person?name_to_display))
        order by $sortKey
        return map {
            "sortKey": $sortKey,
            "name_to_display": $person?name_to_display,
            "id": $person?id
        }
    let $displayItems := 
        array {
            for $person in 
                if ($letterParam = "All") then 
                    $sortedPersons 
                else 
                    filter($sortedPersons, function($entry) {
                        starts-with($entry?sortKey, lower-case($letterParam))
                    })
            return 
                <span>
                    <a href="person.html?id={$person?id}">{$person?name_to_display}</a>
                </span>
        }
    let $categories := 
        array {
            for $index in 1 to string-length('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
            let $alpha := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ', $index, 1)
            let $hits := count(filter($sortedPersons, function($entry) { starts-with($entry?sortKey, lower-case($alpha)) }))
            where $hits > 0
            return map {
                "category": $alpha,
                "count": $hits
            },
            map {
                "category": "All",
                "count": count($sortedPersons)
            }
        }
    return map {
        "items": $displayItems,
        "categories": $categories
    }
};

declare function api:persons-name-to-display($search) {
    let $query := string($search)
    let $mads := 
        if ($query and $query != "") then
            collection($config:data-authority)/mads:mads[
                mads:authority[mads:name[@type = "personal"]] and 
                (
                    matches(string(.), $query, "i") or
                    matches(
                        string-join(for $child in mads:authority//* return normalize-space(string($child)), " "), 
                        $query, "i"
                    ) or
                    matches(
                        string-join(for $child in mads:variant//* return normalize-space(string($child)), " "), 
                        $query, "i"
                    )
                )
            ]
        else 
            collection($config:data-authority)/mads:mads[
                mads:authority[mads:name[@type = "personal"]]
            ] 
    for $mad in $mads
    let $lang := string($mad/mads:authority/@lang)
    let $transliterationVariants := 
    (:if authority lang is CJK, usually it will have at least a trasliteration or a lang arribute, therefore we find the first valid variant to display:)
        if ($mad/mads:variant[(@transliteration or (@lang and not(@lang = 'zh')))]) then
            let $filteredVariants := 
                for $v in $mad/mads:variant[(@transliteration or (@lang and not(@lang = 'zh')))]
                let $variantNameParts := 
                    for $namePart in $v/mads:name/mads:namePart
                    where 
                        (not($namePart/@type) or $namePart/@type != "date") and
                        string-length(normalize-space(string($namePart))) > 0
                    return string($namePart)
                let $variantText := 
                    if (empty($variantNameParts)) then normalize-space(string($v/mads:name)) 
                    else string-join($variantNameParts, " ")
                (:in several cases, the text is not in <namePart> element but in <name> element...:)
                return 
                    if (empty($variantText) or normalize-space($variantText) = "") then () else $variantText
            return 
                if (empty($filteredVariants)) then () 
                else subsequence($filteredVariants, 1, 1)
        else
            for $namePart in $mad/mads:authority/mads:name/mads:namePart
            where 
                (not($namePart/@type) or $namePart/@type != "date") and
                string-length(normalize-space(string($namePart))) > 0
            return string($namePart)
    let $name_to_display := 
        if ($lang = "zh" or $lang = "ja" or $lang = "ko") then
            let $additionalNameParts := 
            (:if language is CJK, then the original name should be shown, which is ($additionalNameParts):)
                for $namePart in $mad/mads:authority/mads:name/mads:namePart
                where (not($namePart/@type) or $namePart/@type != "date")  and string-length(string($namePart)) > 0
                return string($namePart)
            return 
                if ((exists($transliterationVariants)) and $transliterationVariants !='') then
                    concat($transliterationVariants[1], " ", string-join($additionalNameParts, ""))
                else
                    concat($mad/authority/string(), " ", string-join($additionalNameParts, " "))
        else
            let $authorityNameParts := 
                for $namePart in $mad/mads:authority/mads:name/mads:namePart
                where $namePart/@type != "date" and string-length(string($namePart)) > 0
                return string($namePart)
            return string-join($authorityNameParts, ", ")      
    let $dateParts := 
    (:the date with parenthesis is the last part to add to the name to display:)
        for $namePart in $mad//mads:namePart
        where $namePart/@type = "date" and string-length(string($namePart)) > 0
        return concat("(", string($namePart), ")")
    let $final_name_with_dates := 
        if (exists($dateParts)) then
            concat($name_to_display, " ", string-join($dateParts, " "))
        else
            $name_to_display
    return 
        map {
            "id": string($mad/@ID),
            "name_to_display": string($final_name_with_dates)
        }
};

declare function api:person-info($request as map(*)) {
    let $id := $request?parameters?id
    let $mads := collection($config:data-authority)/mads:mads[@ID = $id]
    let $authority := $mads/mads:authority
    
    let $nameParts := 
        for $namePart in $authority/mads:name/mads:namePart
        where (not($namePart/@type) or $namePart/@type != "date")  and string-length(string($namePart)) > 0
        return normalize-space(string($namePart))
    
    let $name := 
        if (exists($nameParts)) then
            if (matches($nameParts[1], "^[a-zA-Z]")) then
            string-join($nameParts, ", ")
            else
            string-join($nameParts, "")
        else
            string-join($authority//mads:namePart[not(@type) or @type != 'date'], " ")
    
    let $lang := $authority/@lang
    let $name_lang := 
        if ($lang = "en") then "English"
        else if ($lang = "zh") then "Chinese"
        else if ($lang = "ja") then "Japanese"
        else if ($lang = "ko") then "Korean"
        else if ($lang = "de") then "German"
        else if ($lang = "ru") then "Russian"
        else if ($lang = "fr") then "French"
        else "Others"

    let $variants :=
        for $variant in collection($config:data-authority)/mads:mads[@ID = $id]/mads:variant
        let $variantNameParts := 
            for $namePart in $variant/mads:name/mads:namePart
            where (not($namePart/@type) or $namePart/@type != "date") and string-length(normalize-space(string($namePart))) > 0
            return normalize-space(string($namePart))
        let $variantText := 
            if (empty($variantNameParts)) then
                normalize-space(string($variant))
            else if (matches($variantNameParts[1], "^[a-zA-Z]")) then
                string-join($variantNameParts, ", ")
            else
                string-join($variantNameParts, "")
        where string-length($variantText) > 0
        return $variantText
    
    let $dates := 
        for $date in $mads//mads:namePart[@type = "date"]
        where string-length(normalize-space(string($date))) > 0
        return normalize-space(string($date))
    
    return 
        <div>
            <div class="person-head">
                <h1>{$name}</h1>
                <p>(Language: {$name_lang})</p>
            </div>
            <div class="person-details">
                <div class="person-variants">
                {
                    if (exists($variants)) then
                        <div>
                            <h2>Other Names:</h2>
                            <ul>
                                {for $v in $variants return <li>{$v}</li>}
                            </ul>
                        </div>
                    else ()
                }
                </div>
                <div class="person-date">
                {
                    if (exists($dates)) then
                            <div>
                                <h2>Date:</h2>
                                <p>{string-join($dates, ", ")}</p>
                            </div>
                    else ()
                }
                </div>
                { api:person-links($id) } 
                { api:get-mentioned-info($id) }
            </div>
        </div>
};

declare function api:person-links($id as xs:string) as element(div)? {
    let $record := doc($config:data-root || '/biblio/authorities.xml')/Records/Record[ID = $id]
    
    let $viaf_id := $record/VIAF_ID
    let $viaf_link := $record/VIAF_Link
    let $cbdb_id := $record/CBDB_ID
    let $cbdb_link := $record/CBDB_link
    let $ddbc_id := $record/DDBC_id
    let $ddbc_link := $record/DDBC_link
    let $wiki_links := 
        for $lang in ('en', 'zh', 'ja', 'fr', 'de', 'ko')
        let $link := $record/*[name() = concat('Wikipedia_Link_', $lang)]
        where string-length($link) > 0
        return <a href="{$link}" target="_blank">{$lang} 　</a>
    
    let $has_links := 
        string-length($viaf_id) > 0 or
        string-length($cbdb_id) > 0 or
        string-length($ddbc_id) > 0 or
        count($wiki_links) > 0
    
    return 
        if ($has_links) then
            <div>
            <h2>Links:</h2>
                <div class="person-links">
                    <div>
                    {
                        if (string-length($viaf_id) > 0) then
                            <p>VIAF: <a href="{$viaf_link}" target="_blank">{$viaf_id}</a></p>
                        else ()
                    }
                    </div>
                    <div>
                    {
                        if (string-length($cbdb_id) > 0) then
                            <p>CBDB: <a href="{$cbdb_link}" target="_blank">{$cbdb_id}</a></p>
                        else ()
                    }
                    </div>
                    <div>
                    {
                        if (string-length($ddbc_id) > 0) then
                            <p>DDBC: <a href="{$ddbc_link}" target="_blank">{$ddbc_id}</a></p>
                        else ()
                    }
                    </div>
                    <div>
                    {
                        if (count($wiki_links) > 0) then
                            <p>Wikipedia: { $wiki_links }</p>
                        else ()
                    }
                    </div>
                </div>
            </div>
        else ()
};

declare function api:get-mentioned-info($id as xs:string) as element(div) {
    let $record := doc($config:data-root || '/biblio/authorities.xml')/Records/Record[ID = $id]
    let $is_mentioned_in_biblio := $record/Mentioned/Is_Mentioned_in_Biblio
    let $is_mentioned_in_articles := $record/Mentioned/Is_Mentioned_in_Articles
    let $mods_ids := 
        for $mod_id in $record//*[starts-with(name(), 'MODS_ID')]
        let $mod := collection($config:data-biblio)/*:mods[@ID = $mod_id]
        return 
            <li>
                <a href="bibliography.html?search={string($mod_id)}" target="_blank">
                {
                    try {
                        modsHTML:format-biblioHTML($mod)
                    } catch * {
                        concat("Cannot display (mods id = ", string($mod_id), ")")
                    }
                }
                </a>
            </li>
    let $tei_xml_ids :=
        for $tei_xml_id in $record//*[starts-with(name(), 'TEI_XML_ID')]
        let $is_site := starts-with($tei_xml_id, 'Site_') or starts-with($tei_xml_id, 'Stele_')

        let $title_en := 
            try {
                if ($is_site) then
                    collection($config:data-publication)//tei:text[@xml:id = $tei_xml_id]/tei:body/tei:div[@xml:lang="en"]/tei:head[1]
                else
                    collection($config:data-publication)//tei:text[@xml:id = $tei_xml_id]/tei:body/tei:div[@xml:lang="en"]/tei:head[@type="subtitle"][1]
            } catch * {
                ()
            }
        
        let $title_zh := 
            try {
                if (not($is_site)) then
                    collection($config:data-publication)//tei:text[@xml:id = $tei_xml_id]/tei:body/tei:div[@xml:lang="zh"]/tei:head[@type="subtitle"][1]
                else
                    ()
            } catch * {
                ()
            }
        
        let $final_title :=
            if ($title_en) then $title_en
            else if ($title_zh) then $title_zh
            else "Title not available"
        
        let $url :=
            if ($is_site) then concat("articles/", string($tei_xml_id))     (:or link to sites/ID:)
            else concat("articles/", string($tei_xml_id))
        
        return 
            <li>
                <a href="{$url}" target="_blank">
                    {string($final_title)}
                </a>
            </li>
    return
        <div>
            {
                if ($is_mentioned_in_biblio = 'Y') then
                    <div>
                        <h2>Mentioned in Bibliography:</h2>
                        <ul>
                            { $mods_ids }
                        </ul>
                    </div>
                else 
                    ()
            }
            {
                if ($is_mentioned_in_articles = 'Y') then
                    <div>
                        <h2>Mentioned in Articles:</h2>
                        <ul>
                            { $tei_xml_ids }
                        </ul>
                    </div>
                else 
                    ()
            }
        </div>
    };


declare function api:place-name($request as map(*)) {
    let $id := $request?parameters?id
    let $places := collection($config:data-biblio)/places
    let $place := $places/place[@id = $id] 
    let $name_zh := string($place/name_zh)
    let $name_en := string($place/name_en)
    let $type := string($place/@type)

    let $name := 
        if ($name_zh != "" and $name_en != "") then
            concat($name_en, " (", $name_zh, ")")
        else if ($name_zh != "") then
            $name_zh
        else
            $name_en
    
    return 
        <div>
            <div class="person-head">
                <h1>{$name}</h1>
                <p>(Type: {$type})</p>
            </div>
        </div>
};

declare function api:place-info($request as map(*)) {
    let $id := $request?parameters?id
    let $places := collection($config:data-biblio)/places
    let $place := $places/place[@id = $id] 
    let $sources := $place/*[starts-with(name(), 'source')] ! string()
    let $wiki-link := $place/Wikipedia_link/string()
    
        return 
            <div class="person-details">
                <div class="person-date">                
                    <h2>Mentioned in:</h2>
                    <ul>
                    {
                        for $source in $sources
                        let $doc := doc(concat($config:data-publication, '/', $source))
                        let $title := ($doc//tei:title)[1]
                        let $label := if (exists($title)) then string($title) else "title unavailable"
                        return <li><a href="Publication/{$source}">{$label}</a></li>
                    }
                    </ul>                
                </div>
                
                {
                  if ($wiki-link) then
                    <div class="wiki-link">
                      <h2>Wikipedia:</h2>
                      <p><a href="{$wiki-link}" target="_blank">{$wiki-link}</a></p>
                    </div>
                  else ()
                }
            </div>
};


declare function api:place-coordinates($request as map(*)) {
  let $id := $request?parameters?id
  let $place := collection($config:data-root)//place[@id = $id]
  let $lat := string($place/coordinates/lat)
  let $lon := string($place/coordinates/lon)
  return map {
    "latitude": $lat,
    "longitude": $lon,
    "label": string($place/name_zh)
  }
};


declare function api:impressum($request as map(*)) {
  try {
    let $xml-id := $request?parameters?id
    return
      if (not($xml-id)) then
        <div class="error">Error: Missing parameter 'id'.</div>
      else
        let $doc := collection($config:data-root)//tei:TEI//tei:text[@xml:id = $xml-id]
        return
          if (empty($doc)) then
            <div class="error">Error: No TEI document found with id '{$xml-id}'.</div>
          else
            let $title := try {
                            normalize-space(string($doc/../tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title))
                          } catch * {
                            'Untitled'
                          },
                $body-divs := $doc/tei:body/tei:div
            return
              <div class="impressum" data-id="{$xml-id}">
                <h2>{$title}</h2>
                {
                  for $div in $body-divs
                  return
                    <div class="section">
                      {
                        let $head := try { normalize-space(($div/tei:head/text())[1]) } catch * { '' }
                        return if ($head) then <h3>{$head}</h3> else ()
                      }
                      <ul>
                        {
                          for $item in $div/tei:list/tei:item
                          return
                            try {
                              <li>{normalize-space(string($item))}</li>
                            } catch * {
                              <li class="error">[Error reading item]</li>
                            }
                        }
                      </ul>
                    </div>
                }
              </div>
  } catch * {
    <div class="error">Unexpected error: {
      if ($err:description) then $err:description else 'Unknown problem.'
    }</div>
  }
};


declare function api:tei-figures($request as map(*)) {
  let $image-base-url := "https://sutras.adw.uni-heidelberg.de/images/"
  let $lang := replace($request?parameters?language, "^([^_-]+)[_-].*$", "$1")
  let $options := query:options(())
  let $volumes := collection($config:data-publication)//tei:figure[ft:query(., "volume:*", $options)][ancestor::tei:TEI//tei:seriesStmt]
  let $nil := session:set-attribute($config:session-prefix || ".images", $volumes)
  
  return
        <div class="volume-group-for-grid"> 
            {
                for $volume in $volumes
                    group by $id := $volume/ancestor::tei:TEI//tei:seriesStmt/tei:title[1]/@n
                    order by $id
                    let $seriesStmt := head($volume/ancestor::tei:TEI)/tei:teiHeader//tei:seriesStmt
                        for $figures in $volume
                        return
                                for $figure in $figures
                                let $xml-id := $figure/@xml:id
                                let $url := $figure/tei:graphic/@url
                                where not(ends-with(lower-case(string($url)), '.swf')) and not(ends-with(lower-case(string($url)), '.svg'))
                                let $head_zh := $figure/tei:head[1]
                                let $head_en := $figure/tei:head[2]
                                let $image-filename-base := replace(string($url), "^(.*)\.[^\.]+$", "$1")
                                let $text-ancestor-id := $figure/ancestor::tei:text/@xml:id
                                let $xml-base-url := base-uri($figure)
                                let $xml-base-url-part := substring-after(string($xml-base-url), 'Publication/')

                                let $specific-xml-ids-to-be-JPG := ('W51_DSC7890.JPG', 'DSC_0070.JPG', 'DSC_2312.JPG', 'cave_40_DSC_0108.JPG', 'caves_42_41_40_DSC_0111.JPG', 'cave75_DSC_0015.JPG', 'cave75_DSC_1175.JPG', 'cave77_DSC_0018.JPG', 'WFY_8_89_90_DSC_0513.JPG', 'WFY_92_93_94_DSC_0450.JPG', 'WFY_cave82_DSC_0022.JPG', 'cave74_DSC_0166.JPG', 'WFY_73_IMGP6682.JPG')
                                let $new-specific-xml-ids-to-be-jpg := ('Section_a-b_DSC_0322.jpg', 'WFY_29-33_DSC0631.jpg', 'Wofoyuan_links_Höhlen_29-42.tif', 'pagoda_25b_DSC0492.jpg')
                                let $extension :=
                                if ($xml-id = $new-specific-xml-ids-to-be-jpg) then 'jpg' 
                                    else if ($xml-id = $specific-xml-ids-to-be-JPG) then 'JPG' 
                                    else if ($text-ancestor-id = 'Site_WFY_Section_AandB' or $text-ancestor-id = 'Site_WFY_Section_Bb_Cave39') then 'JPG'
                                    else if (ends-with($xml-id, 'tif')) then 'jpg'
                                    else if (ends-with($xml-id, 'TIF')) then 'jpg'
                                    else if (ends-with($xml-id, 'JPG')) then 'jpg'
                                    else if (ends-with($xml-id, 'jpg')) then 'jpg'
                                    else 'jpg'
                                let $image-url := concat($image-base-url, $image-filename-base, ".", $extension)
                                return
                                    <div class="image-container">
                                        <pb-popover theme="light">
                                            <img src="{$image-url}" alt="Figure {string($xml-id)}" loading="lazy"/>
                                            <template slot="alternate">
                                                <div class="character-details">
                                                    {<p>See: <a href="{concat('Publication/', $xml-base-url-part)}">{string($text-ancestor-id)}</a></p>}
                                                    { 
                                                         if (string($head_en) ne "") then
                                                            <p>{$head_en}</p>
                                                        else ()
                                                    }
                                                    {
                                                        if (string($head_zh) ne "") then
                                                            <p>{$head_zh}</p>
                                                        else ()
                                                    }
                                                </div> 
                                            </template>
                                        </pb-popover>
                                    </div>
            }
        </div>
} ;


declare function api:temples($request as map(*)) {
  let $search := $request?parameters?search
  let $temples := collection($config:data-biblio)/monastery

  for $temple in $temples
    let $id := string($temple/@xml:id)
    let $name_zh :=
        if ($temple/name[@xml:lang='zh']/placeName)
        then normalize-space( ($temple/name[@xml:lang='zh']/placeName)[1] )
        else ""
    let $name_pinyin :=
        if ($temple/name[@transliteration='pinyin'])
        then normalize-space(($temple/name[@transliteration='pinyin'])[1] )
        else ""

    let $final_name :=
        if (starts-with($id, 'unclear') ) then (: Check if it's 'unclear' followed by a number :)
            $id
        else if ($name_pinyin != "" and $name_zh != "") then
            concat($name_pinyin, " ", $name_zh)
        else if ($name_zh != "") then
            $name_zh
        else
            $name_pinyin

    (: the 'pinyin' one is the Template :)
    where $id != 'pinyin'

    order by lower-case($final_name)

    return <li>{$final_name} (xml:id is {$id})</li>
};

declare function api:sutras($request as map(*)) {
    let $search := $request?parameters?search
    let $sutras := collection($config:data-sutras)/mods:mods

    for $sutra in $sutras
        let $id := string($sutra/@ID)
        let $title_zh :=
            if ($sutra/mods:titleInfo[@lang='zh']/mods:title)
            then normalize-space( ($sutra/mods:titleInfo[@lang='zh']/mods:title)[1] )
            else ""
        let $title_pinyin :=
            if ($sutra/mods:titleInfo[@transliteration='pinyin']/mods:title)
            then normalize-space(($sutra/mods:titleInfo[@transliteration='pinyin']/mods:title)[1] )
            else ""
        let $title_en :=
            if ($sutra/mods:titleInfo[@lang='en' and @type='translated']/mods:title)
            then normalize-space(($sutra/mods:titleInfo[@lang='en' and @type='translated']/mods:title)[1] )
            else ""
        let $title_ja :=
            if ($sutra/mods:titleInfo[@lang='ja']/mods:title)
            then normalize-space( ($sutra/mods:titleInfo[@lang='ja']/mods:title)[1] )
            else ""
        let $title_romaji :=
            if ($sutra/mods:titleInfo[@transliteration='romaji']/mods:title)
            then normalize-space( ($sutra/mods:titleInfo[@transliteration='romaji']/mods:title)[1] )
            else ""
        let $final_title :=
            if ($title_ja != "" ) then
                concat($title_ja, " ",$title_romaji)
            else if ($title_pinyin != "" and $title_zh != "") then
                concat($title_pinyin, " ", $title_zh)
            else if ($title_zh != "") then
                $title_zh
            else if ($title_pinyin != "") then
                $title_pinyin
            else
                $title_en (: Fallback to English title if no Chinese or Pinyin found :)

        where $id != 'pinyin' (: Assuming 'pinyin' might be used as a template ID, similar to temples :)
              and ($search = '' or contains(lower-case($final_title), lower-case($search)))

        order by lower-case($final_title)

        return <li>{$final_title} (ID is {$id})</li>
};
(:  
declare function api:texts($request as map(*)) {
  let $docs := collection($config:data-docs)//tei:text
  for $doc in $docs
    let $text-id := string($doc/@xml:id)
    for $witness in $doc//tei:witness
      where $witness/@sigil[starts-with(., 'T_')]
      let $witDetail := $witness/tei:witDetail
      let $witness-content := normalize-space($witDetail/string())
      let $sigil := string($witness/@sigil)
      return
        <div>
          <rdg-wit-attribute>{$sigil}, </rdg-wit-attribute>
          <text-xml-id>{$text-id}, </text-xml-id>
          <related-witnesses>{$witDetail}</related-witnesses>
        </div>
};:)


declare function api:texts-table($request as map(*)) {
    let $lang := replace($request?parameters?language, "^([^_-]+)[_-].*$", "$1")
    let $query := $request?parameters?search
    let $start := if (exists($request?parameters?start)) then xs:integer($request?parameters?start) else 1
    let $limit := if (exists($request?parameters?limit)) then xs:integer($request?parameters?limit) else 100
    let $docs := collection($config:data-docs)//tei:text
    let $taisho-headings := collection($config:data-docs)//Taisho/heading

    let $filtered-references :=
            for $doc in $docs
                let $text-id := string($doc/@xml:id)
                order by $text-id
                    for $witness in $doc//tei:witness
                      where $witness/@sigil[starts-with(., 'T_')]
                      let $witDetail := $witness/tei:witDetail
                      let $Tnumber := string($witDetail/@target)
                      let $witness-content := normalize-space($witDetail/string())
                      let $sigil := string($witness/@sigil)
                      
                      let $cleaned-Tnumber := replace($Tnumber, "^T_", "")
                      let $formatted-Tnumber := if (string-length($cleaned-Tnumber) = 3) then concat("0", $cleaned-Tnumber) else $cleaned-Tnumber
                      
                      let $heading-text := ($taisho-headings[lower-case(@number) = lower-case($formatted-Tnumber)]/string())[1]

                where $witness-content != "" and $text-id != "" 
                
                return map {
                    "Tnumber": $Tnumber,
                    "Sigil": $sigil,
                    "Source": $text-id,
                    "witness-content": $witness-content,
                    "heading": $heading-text
                }
    
    let $sorted-references := subsequence($filtered-references, $start, $limit)
    
    return map {
        "count": count($filtered-references),
        "results": array { $sorted-references }
    }
};
