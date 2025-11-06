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
    let $options := query:options(())

let $chars :=
   try {
      collection($config:data-catalog)/character/char-entry[ft:query(., $query, $options)]
   } catch * {
      error(xs:QName("file-not-found"), "The precomputed character file does not exist.")
   }
let $nil := session:set-attribute($config:session-prefix || ".characters", $chars)

let $filtered-characters :=
   for $char in $chars
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
   let $image-path := if ($char/province = 'Shaanxi Province') then 'characters_shaanxi' 
               else if ($char/province = 'Sichuan Province') then 'characters_sichuan'
               else 'characters'
   where normalize-space($image) ne "" and (not($query) or
         contains(lower-case($character), lower-case($query)))
   order by $char/Source_column_row
   return map {
      "character": $character,
      "imageUrl": "https://sutras.adw.uni-heidelberg.de/images/" || $image-path || "/" || $image,
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
                                    <img src="{$item?imageUrl}" alt="{$item?altText}" style="width: 100px; height: 100px;" loading="lazy"/>
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
    let $options := query:options(())

    let $chars :=
        try {
            collection($config:data-catalog)/character/char-entry
        } catch * {
            error(xs:QName("file-not-found"), "The precomputed character file does not exist.")
        }

    let $filtered-characters :=
        for $char in $chars
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
        let $image-path := if ($char/province = 'Shandong Province') then 'characters'
                        else if ($char/province = 'Shaanxi Province') then 'characters_shaanxi' 
                        else 'characters_sichuan'
        where normalize-space($image) ne "" and (not($query) or
            contains(lower-case($character), lower-case($query)))
        order by $char/Source_column_row
        return map {
            "character": $character,
            "image": <a href="https://sutras.adw.uni-heidelberg.de/images/{$image-path}/{$image}" target="_blank">
                        <img src="https://sutras.adw.uni-heidelberg.de/images/{$image-path}/{$image}" alt="{$character}" style="width: 100px; height: auto;"/>
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
    let $type_en_label := api:translate-type(map { "type": $type, "lang": "en" })
    let $type_zh_label := api:translate-type(map { "type": $type, "lang": "zh" })
    order by $type
    return
      <div class="place-category">
        <h2>{concat($type_en_label, " ", $type_zh_label)}</h2>
        {
          for $place in $places[@type = $type]
            let $id := string($place/@id)
            let $name_zh := normalize-space($place/name_zh)
            let $name_en := normalize-space($place/name_en)
            let $final_name_with_dates :=
              if ($name_zh != "" and $name_en != "") then
                concat($name_en, " ", $name_zh)
              else if ($name_zh != "") then
                $name_zh
              else
                $name_en
            order by lower-case($final_name_with_dates)
            return
              <div class="place">
                <a data-place-id="{$id}" class="place-item-link">{$final_name_with_dates}</a>
              </div>
        }
      </div>

  return <div class="all-places">{$grouped}</div>
};

declare function api:translate-type($params as map(*)) as xs:string {
  let $type := $params?type
  let $lang := $params?lang
  return
    if ($lang = "zh") then
      switch ($type)
        case "Country" return "國家"
        case "Gate" return "門"
        case "Mountain" return "山"
        case "City" return "城市"
        case "River" return "河流"
        case "Monastery" return "寺院"
        case "District" return "區"
        case "Cloister" return "修道院"
        case "Town" return "鎮"
        case "Site" return "遺址"
        case "Cliff" return "懸崖"
        case "Village" return "村"
        case "Province" return "省"
        case "Institution" return "機構"
        case "Stupa" return "佛塔"
        case "Ridge" return "山脊"
        case "Valley" return "山谷"
        case "Peak" return "山峰"
        case "County" return "縣"
        case "Cave" return "洞穴"
        case "Lake" return "湖泊"
        case "Reservoir" return "水庫"
        case "Park" return "公園"
        case "Pool" return "水池"
        case "Canyon" return "峽谷"
        default return ""
    else
      $type
};

declare function api:research-articles($request as map(*)) {
  let $lang := replace($request?parameters?language, "^([^_-]+)[_-].*$", "$1")
  let $options := query:options(())
  let $query := "volume:*"
  let $volumes :=
    collection($config:data-publication)//tei:body[ancestor::tei:TEI//tei:seriesStmt/tei:title[1]/@n][ft:query(., $query, $options)]
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
            <a href="{
                                if (starts-with($id, 'Site_')) then
                                    concat('sites/', substring-after($id, 'Site_'))
                                else
                                    concat('articles/', $id)
                            }">{$head}</a>
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

declare function api:char-facets($request as map(*)) {
    
    let $hits := session:get-attribute($config:session-prefix || ".characters")
    where count($hits) > 0
    return
        <div>
        {
            for $config in $config:char-facets?*
            return
                facets:display($config, $hits)
        }
        </div>
};

declare function api:char-table-facets($request as map(*)) {
    
    let $hits := session:get-attribute($config:session-prefix || ".characters-table")
    where count($hits) > 0
    return
        <div>
        {
            for $config in $config:char-facets?*
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

declare function api:clinks-facets($request as map(*)) {
    
    let $hits := session:get-attribute($config:session-prefix || ".clinks")
    where count($hits) > 0
    return
        <div>
        {
            for $config in $config:clinks-facets?*
            return
                facets:display($config, $hits)
        }
        </div>
};

declare function api:reign-facets($request as map(*)) {
    
    let $hits := session:get-attribute($config:session-prefix || ".reigns")
    where count($hits) > 0
    return
        <div>
        {
            for $config in $config:reign-facets?*
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

declare function api:get-base-id($id as xs:string) as xs:string {
    replace($id, "_(enzh|en|zh|ja|enjp|j|2)$", "")
};

declare function api:get-display-name-from-mad($mad as element(mads:mads)) as xs:string {
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
                    concat($mad/mads:authority/string(), " ", string-join($additionalNameParts, " "))
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
    return string($final_name_with_dates)
};


declare function api:persons($request as map(*)) {
    let $search := normalize-space($request?parameters?search)
    let $letterParam := $request?parameters?category
    (: CHANGED: api:persons-name-to-display deduplicated :)
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
    
    for $madGroup in $mads
    let $baseId := api:get-base-id(string($madGroup/@ID))
    group by $baseId
    
    (: $madGroup 现在是一个序列，包含所有共享相同 $baseId 的 mads 记录 :)
    

    let $suffixRegex := "_(enzh|en|zh|ja|enjp|j|2)$"
    let $baseRecord := $madGroup[not(matches(string(@ID), $suffixRegex))][1]
    
    let $chosenMad := 
        if (exists($baseRecord)) then $baseRecord
        else $madGroup[1]
    
    let $name_to_display := api:get-display-name-from-mad($chosenMad)

    return 
        map {
            "id": $baseId,
            "name_to_display": $name_to_display
        }
};


declare function api:person-info($request as map(*)) {
    let $baseId := $request?parameters?id
    let $allMads := collection($config:data-authority)/mads:mads[
        api:get-base-id(string(@ID)) = $baseId
    ]
    
    return
    if (not(exists($allMads))) then 
            <div>Person not found (ID: {$baseId}).</div>
        else
            let $suffixRegex := "_(enzh|en|zh|ja|enjp|j|2)$"
            let $baseRecord := $allMads[not(matches(string(@ID), $suffixRegex))][1]
            let $chosenMad := 
                if (exists($baseRecord)) then $baseRecord
                else $allMads[1]
            
            let $authority := $chosenMad/mads:authority
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
                distinct-values(
                    for $variant in $allMads/mads:variant
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
                )
            
            let $dates := 
                distinct-values(
                    for $date in $allMads//mads:namePart[@type = "date"]
                    where string-length(normalize-space(string($date))) > 0
                    return normalize-space(string($date))
                )
            
            return 
                <div>
                    <div class="person-head">
                        <h1>{$name}</h1>
                        <p>(Language: {$name_lang})</p>
                    </div>
                    <div class="person-details">
                        
                        {
                            if (exists($variants)) then
                                <div class="person-variants">
                                    <h2>Other Names:</h2>
                                    <ul>
                                        {for $v in $variants return <li>{$v}</li>}
                                    </ul>
                                </div>
                            else ()
                        }
                        {
                            if (exists($dates)) then
                                    <div class="person-date">
                                        <h2>Date:</h2>
                                        <p>{string-join($dates, ", ")}</p>
                                    </div>
                            else ()
                        }
                        
                        { api:person-links($baseId) } 
                        { api:get-mentioned-info($baseId) }
                    </div>
                </div>
};

declare function api:person-links($id as xs:string) as element(div)? {
    let $baseId := $id
    
    let $records := doc($config:data-root || '/biblio/authorities.xml')/Records/Record[
        api:get-base-id(string(ID)) = $baseId
    ]
    
  
    let $viaf_links := 
        for $r in $records
        where string-length($r/VIAF_ID) > 0
        group by $vid := string($r/VIAF_ID)
        let $link := $r[1]/VIAF_Link 
        return <p>VIAF: <a href="{$link}" target="_blank">{$vid}</a></p>
    
    let $cbdb_links := 
        for $r in $records
        where string-length($r/CBDB_ID) > 0
        group by $cid := string($r/CBDB_ID)
        let $link := $r[1]/CBDB_link
        return <p>CBDB: <a href="{$link}" target="_blank">{$cid}</a></p>
     
    let $ddbc_links := 
        for $r in $records
        where string-length($r/DDBC_id) > 0
        group by $did := string($r/DDBC_id)
        let $link := $r[1]/DDBC_link
        return <p>DDBC: <a href="{$link}" target="_blank">{$did}</a></p>

let $wiki_links := 
    for $lang in ('en', 'zh', 'ja', 'fr', 'de', 'ko')
    
    let $link_element := $records/*[name() = concat('Wikipedia_Link_', $lang)][string-length(.) > 0][1]
    
    where exists($link_element)
    return <a href="{$link_element}" target="_blank">{$lang} 　</a>
    let $has_links := 
        count($viaf_links) > 0 or
        count($cbdb_links) > 0 or
        count($ddbc_links) > 0 or
        count($wiki_links) > 0
    
    return 
        if ($has_links) then
            <div class="person-links">
            <h2>Links:</h2>
                <div>
                    <div>{ $viaf_links }</div>
                    <div>{ $cbdb_links }</div>
                    <div>{ $ddbc_links }</div>
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


declare function api:get-mentioned-info($id as xs:string) as element(div)? {
    let $baseId := $id
        let $records := doc($config:data-root || '/biblio/authorities.xml')/Records/Record[
        api:get-base-id(string(ID)) = $baseId
    ]
    
    let $is_mentioned_in_biblio := if (exists($records/Mentioned/Is_Mentioned_in_Biblio[. = 'Y'])) then 'Y' else 'N'
    let $is_mentioned_in_articles := if (exists($records/Mentioned/Is_Mentioned_in_Articles[. = 'Y'])) then 'Y' else 'N'

    let $mods_ids := 
        for $mod_id in distinct-values($records//*[starts-with(name(), 'MODS_ID')])
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
        for $tei_xml_id in distinct-values($records//*[starts-with(name(), 'TEI_XML_ID')])
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
        if ($is_mentioned_in_biblio = 'Y' or $is_mentioned_in_articles = 'Y') then
            <div class="person-mentions">
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
        else
            <div></div>
    };

(:  
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
            <p>DEBUG: received id = {$id}</p>
            <div class="person-head">
                <h1>{$name}</h1>
                <p>(Type: {$type})</p>
            </div>
        </div>
};:)

declare function api:place-info($request as map(*)) {
    let $id := $request?parameters?id
    let $places := collection($config:data-biblio)/places
    let $place := $places/place[@id = $id] 
    let $sources := $place/*[starts-with(name(), 'source')] ! string()
    let $wiki-link := $place/Wikipedia_link/string()
    
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
            <div class="place-details">
                <div class="place-head">
                    <h1>{$name}</h1>
                    <p>(Type: {$type})</p>
                </div>

                <div class="place-data">                
                    <h2>Mentioned in:</h2>
                    <ul>
                    {
                        for $source in $sources
                        let $doc := doc(concat($config:data-publication, '/', $source))
                        let $title := ($doc//tei:title)[1]
                        let $label := if (exists($title)) then string($title) else "title unavailable"
                        return <li><a href="Publication/{$source}" target="_blank">{$label}</a></li>
                    }
                    </ul>                
                </div>
                
                {
                  if ($wiki-link) then
                    <div class="wiki-link">
                      <h2>Authority Links:</h2>
                      <p><a href="{$wiki-link}" target="_blank">Wikipedia</a></p>
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


declare function api:reign-info($request as map(*)) {
    let $id := $request?parameters?id
    let $reigns := collection($config:data-biblio)/reign_mentions_summary
    let $reign := $reigns/reign_entry[reign_id = $id]


    let $reign_name_zh := string($reign/reign_name_zh)
    let $reign_from_raw := string($reign/reign_from)
    let $reign_to_raw := string($reign/reign_to)
    let $reign_from := 
              if ($reign_from_raw castable as xs:integer) then string(xs:integer($reign_from_raw)) else ""
    let $reign_to := 
              if ($reign_to_raw castable as xs:integer) then string(xs:integer($reign_to_raw)) else ""
            
    let $reign_period :=
      if ($reign_from != "" and $reign_to != "") then
        concat(" (", $reign_from, "–", $reign_to, ")")
      else if ($reign_from != "") then
        concat(" (", $reign_from, "–?)")
      else
        ""

    let $dynasty_name_zh := string($reign/dynasty_info/dynasty_name_zh)
    let $dynasty_name_en := string($reign/dynasty_info/dynasty_name_en)
    let $dynasty_from_raw := string($reign/dynasty_info/dynasty_from)
    let $dynasty_to_raw := string($reign/dynasty_info/dynasty_to)
    let $dynasty_from := if ($dynasty_from_raw castable as xs:integer) then string(xs:integer($dynasty_from_raw)) else ""
    let $dynasty_to := if ($dynasty_to_raw castable as xs:integer) then string(xs:integer($dynasty_to_raw)) else ""

    let $dynasty_period := 
        if ($dynasty_from != '' and $dynasty_to != '') then
            concat('(', $dynasty_from, ' - ', $dynasty_to, ')')
        else if ($dynasty_from != '') then
            concat('(', $dynasty_from, ' - ?)')
        else if ($dynasty_to != '') then
            concat('(? - ', $dynasty_to, ')')
        else
            ''
let $mentioned_in_catalog_raw := string($reign/mentioned_in_catalog)
let $catalog_sources := tokenize($mentioned_in_catalog_raw, ',') ! normalize-space(.)

let $mentioned_in_TEI_raw := string($reign/mentioned_in_TEI)
let $tei_sources := tokenize($mentioned_in_TEI_raw, ',') ! normalize-space(.)

return
    <div class="reign-details">
        <div class="reign-head">
            <h1>
                {$reign_name_zh}
                {if ($reign_period != '') then <span class="reign-period">{$reign_period}</span> else ()}
            </h1>
            {if ($dynasty_name_zh != '' or $dynasty_name_en != '') then
                <p class="dynasty-info">
                    Dynasty:
                    {if ($dynasty_name_zh != '') then <span>{$dynasty_name_zh} </span> else ()}
                    {if ($dynasty_name_en != '') then <span class="dynasty-en">({$dynasty_name_en}) </span> else ()}
                    {if ($dynasty_period != '') then <span class="dynasty-period">{$dynasty_period}</span> else ()}
                </p>
            else ()}
        </div>

        <div class="reign-data">
            <h2>Mentioned in:</h2>

            <h3>Inscription catalogs:</h3>
            {
                if (exists($catalog_sources) and $catalog_sources[1] != '') then
                    <ul>
                    {
                        for $source in $catalog_sources
                        let $doc := collection($config:data-catalog)/catalog:object[@xml:id=string($source)]
                        let $title := $doc/catalog:header/catalog:title[1]
                        let $label := if (exists($title)) then string($title) else $source
                        return <li><a href="inscriptions/{$source}" target="_blank">{$label} ({$source})</a></li>
                    }
                    </ul>
                else
                    <ul>None</ul>
            }

            <h3>Research articles:</h3>
            {
                if (exists($tei_sources) and $tei_sources[1] != '') then
                    <ul>
                    {
                        for $source in $tei_sources
                        let $title_en := collection($config:data-publication)//tei:text[@xml:id = string($source)]/tei:body/tei:div[@xml:lang="en"]/tei:head[1]
                        let $title_zh := collection($config:data-publication)//tei:text[@xml:id = string($source)]/tei:body/tei:div[@xml:lang="zh"]/tei:head[1]
                        let $title :=
                        if (exists($title_en)) then
                            if (exists($title_zh)) then
                                string($title_en) || " " || string($title_zh)
                            else
                                string($title_en)
                        else if (exists($title_zh)) then
                            string($title_zh)
                        else
                            ()
                        let $label := if (exists($title)) then string($title) else $source
                        return <li><a href="articles/{$source}" target="_blank">{$label}</a></li>
                    }
                    </ul>
                else
                    <ul>None</ul>
            }
        </div>
    </div>
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

  let $figures := collection($config:data-publication)//tei:figure[
    ancestor::tei:TEI//tei:seriesStmt and
    ft:query(., "volume_figures:*", $options) and
    not(ends-with(lower-case(tei:graphic/@url), '.swf')) and
    not(ends-with(lower-case(tei:graphic/@url), '.svg'))
  ]

  let $nil := session:set-attribute($config:session-prefix || ".images", $figures)

  return
    <div class="volume-group-for-grid">
    {
      for $figure-group in $figures
      let $url := normalize-space(head($figure-group)/tei:graphic/@url)
      group by $url

      let $first-entry := head($figure-group)
      let $xml-id := $first-entry/@xml:id/string()
      let $text-ancestor-id := $first-entry/ancestor::tei:text/@xml:id/string()
      let $image-filename-base := replace($url, "^(.*)\.[^\.]+$", "$1")

      (: ================================================================ :)
      let $specific-xml-ids-to-be-JPG := ('W51_DSC7890.JPG', 'DSC_0070.JPG', 'DSC_2312.JPG', 'cave_40_DSC_0108.JPG', 'caves_42_41_40_DSC_0111.JPG', 'cave75_DSC_0015.JPG', 'cave75_DSC_1175.JPG', 'cave77_DSC_0018.JPG', 'WFY_8_89_90_DSC_0513.JPG', 'WFY_92_93_94_DSC_0450.JPG', 'WFY_cave82_DSC_0022.JPG', 'cave74_DSC_0166.JPG', 'WFY_73_IMGP6682.JPG')
      let $new-specific-xml-ids-to-be-jpg := ('Section_a-b_DSC_0322.jpg', 'WFY_29-33_DSC0631.jpg', 'Wofoyuan_links_Höhlen_29-42.tif', 'pagoda_25b_DSC0492.jpg')
      
      let $extension :=
        if ($xml-id = $new-specific-xml-ids-to-be-jpg) then 'jpg'
        else if ($xml-id = $specific-xml-ids-to-be-JPG) then 'JPG'
        else if ($text-ancestor-id = ('Site_WFY_Section_AandB', 'Site_WFY_Section_Bb_Cave39')) then 'JPG'
        else if (ends-with(lower-case($xml-id), ('.tif', '.jpg'))) then 'jpg'
        else 'jpg'

      let $image-url := concat($image-base-url, $image-filename-base, ".", $extension)
      (: ================================================================ :)
      
      let $links :=
        let $distinct-text-ids := distinct-values($figure-group/ancestor::tei:text/@xml:id/string())
        let $base-url-map := map:merge(
          for $f in $figure-group
          group by $tid := $f/ancestor::tei:text/@xml:id/string()
          return map:entry($tid, head($f) => base-uri())
        )
        for $text-id at $pos in $distinct-text-ids
        let $base := map:get($base-url-map, $text-id)
        let $path := substring-after(string($base), 'Publication/')
        let $anchor := <a href="{concat('Publication/', $path)}">{$text-id}</a>
        return if ($pos > 1) then (", ", $anchor) else $anchor

      return
        <div class="image-container">
          <pb-popover theme="light">
            <a href="{$image-url}" target="_blank"><img src="{$image-url}" alt="Figure" loading="lazy"/></a>
            <template slot="alternate">
              <div class="character-details">
                {
                  let $head_en := $first-entry/tei:head[2]
                  where string($head_en) ne ""
                  return <p>{$head_en}</p>
                }
                {
                  let $head_zh := $first-entry/tei:head[1]
                  where string($head_zh) ne ""
                  return <p>{$head_zh}</p>
                }
                <p>See: { $links }</p>

              </div>
            </template>
          </pb-popover>
        </div>
    }
    </div>
};

declare function api:catalog-links($request as map(*)) {
  let $image-base-url := "https://sutras.adw.uni-heidelberg.de/images/"
  let $lang := replace($request?parameters?language, "^([^_-]+)[_-].*$", "$1")
  let $options := query:options(())

  let $links := collection($config:data-catalog)//catalog:link[
    (@type = "rubbing" or @type = "stone") and
    ancestor::catalog:object and
    ft:query(., "type:*", $options) and
    not(ends-with(lower-case(@xlink:href), '.swf')) and
    not(ends-with(lower-case(@xlink:href), '.svg')) and
    string(@xlink:href) != "" and
    (
      normalize-space(self::catalog:link/catalog:caption[@xml:lang='en']) ne '' or
      normalize-space(self::catalog:link/catalog:caption[@xml:lang='zh']) ne ''
    ) and
    (: rule out those unpublished yet and old :)
    not(
      starts-with(ancestor::catalog:object/@xml:id/string(), 'DF') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'CS') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'Yi') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'JKB') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'JY') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'LJ') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'MD') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'XL') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'GM') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'SF') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'JCh') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'CW') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'LGj') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'GQ') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'BSS') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'QH') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'QL') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'DAI') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'TP') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'YYS') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'TP') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'FM') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'HR') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'TM') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'NY') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'XH') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'BSY') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'WLS') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'BL') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'JX') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'WS') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'SG') or
      starts-with(ancestor::catalog:object/@xml:id/string(), 'Beilin-Diamond') or

      ends-with(lower-case(ancestor::catalog:object/@xml:id/string()), 'old')
    )
  ]
  let $nil := session:set-attribute($config:session-prefix || ".clinks", $links)

  return
    <div class="image-grid">
    {
      for $link in $links
      let $original-href := normalize-space($link/@xlink:href)
      let $valid-image-extensions_regex := '\.(jpe?g|png|gif|tif?f)$'
      where $original-href ne '' and matches(lower-case($original-href), $valid-image-extensions_regex)

      let $base-filename := replace($original-href, '\.[^.]*$', '')

      let $extension :=
        if (ends-with(lower-case($original-href), '.tif')) then 'jpg'
        else if (ends-with(lower-case($original-href), '.tiff')) then 'jpg'
        else if (ends-with(lower-case($original-href), '.jpeg')) then 'jpg'
        else if (ends-with(lower-case($original-href), '.png')) then 'png'
        else if (ends-with(lower-case($original-href), '.gif')) then 'gif'
        else 'jpg'

      let $effective-href := concat($base-filename, '.', $extension)

      let $xlink := string($effective-href) (: DEBUG 用，显示有效 href :)
      let $xml-id := $link/ancestor::catalog:object/@xml:id/string()

      let $image-url := concat($image-base-url, $effective-href)

      let $caption-zh := $link/catalog:caption[@xml:lang = 'zh']/string()
      let $caption-en := $link/catalog:caption[@xml:lang = 'en']/string()

      let $anchor := <a href="{concat('inscriptions/', $xml-id)}">{$xml-id}</a>

      return
        <div class="image-container">
          <pb-popover theme="light">
            <a href="{$image-url}" target="_blank"><img src="{$image-url}" alt="Figure for {$xml-id}" loading="lazy"/></a>
            <template slot="alternate">
              <div class="image-details">
                {
                  if (string($caption-en) ne "") then <p>{$caption-en}</p> else ()
                }
                {
                  if (string($caption-zh) ne "") then <p>{$caption-zh}</p> else ()
                }
                <p>See: { $anchor }</p>
              </div>
            </template>
          </pb-popover>
        </div>
    }
    </div>
};

(:  
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
};:)

declare function api:texts-table($request as map(*)) {
    let $lang := replace($request?parameters?language, "^([^_-]+)[_-].*$", "$1")
    let $query := normalize-space(lower-case($request?parameters?search))
    let $start := if (exists($request?parameters?start)) then xs:integer($request?parameters?start) else 1
    let $limit := if (exists($request?parameters?limit)) then xs:integer($request?parameters?limit) else 100

    let $taisho-headings := collection($config:data-docs)/Taisho/heading
    let $heading-map := map:merge(
        for $h in $taisho-headings
        return map:entry(upper-case($h/@number), string($h))
    )

    let $refs :=
        for $object in collection($config:data-catalog)/catalog:object
        let $xml-id := string($object/@xml:id)
        for $ref in $object/catalog:references/catalog:ref[@type="taisho"]
        return map {
            "ref": $ref,
            "xml-id": $xml-id
        }

    let $processed-references :=
        for $entry in $refs
            let $ref := $entry?ref
            let $taisho-id := upper-case(string($ref/@xlink:href))
            let $num-part := replace($taisho-id, "^T_([^0-9]*)([0-9.]+).*", "$2")
            let $number-sort-key :=
                if (matches($num-part, "^[0-9.]+$")) then xs:double($num-part) else 9999999
            order by $number-sort-key
            where starts-with($taisho-id, 'T_')
            let $cleaned-Tnumber := replace($taisho-id, "^T_", "")
            (: 提取前面的整数部分，不包括小数点或字母 :)
            let $int-part := replace($cleaned-Tnumber, "^([0-9]+).*", "$1")
            (: 提取字母后缀（如有），忽略小数部分 :)
            let $suffix :=
                if (matches($cleaned-Tnumber, "^[0-9]+(?:\.[0-9]+)?([A-Z])$"))
                then replace($cleaned-Tnumber, "^[0-9]+(?:\.[0-9]+)?([A-Z])$", "$1")
                else ""

            let $padded-number :=
                if (string-length($int-part) = 4) then $int-part
                else if (string-length($int-part) = 3) then concat("0", $int-part)
                else if (string-length($int-part) = 2) then concat("00", $int-part)
                else if (string-length($int-part) = 1) then concat("000", $int-part)
                else $int-part

            let $formatted-Tnumber := upper-case(concat($padded-number, $suffix))
            let $Tnumber := "T_" || string($formatted-Tnumber)
            let $heading-text := $heading-map(upper-case($formatted-Tnumber))
            
            where starts-with($taisho-id, 'T_') and (
            empty($query) or
            contains(lower-case($Tnumber), $query) or
            contains(lower-case(string($heading-text)), $query)
        )
            return map {
                "Tnumber": $taisho-id,
                "inscription_item": concat('<a href="inscriptions/', $entry?xml-id, '" target="_blank" rel="noopener noreferrer">', $entry?xml-id, '</a>'),
                "sutras_title":
                    <pb-popover theme="light">
                        <span>
                            <a href="text.html?Tnumber={$Tnumber}" target="_blank">{$heading-text}</a> <svg xmlns="http://www.w3.org/2000/svg"
                                style="width: 14px; height: 14px; margin-left: 4px; vertical-align: middle;"
                                fill="currentColor" viewBox="0 0 16 16">
                                <path d="M6.354 5.5H4a2.5 2.5 0 0 0 0 5h2.354a.5.5 0 0 1 0 1H4a3.5 3.5 0 0 1 0-7h2.354a.5.5 0 0 1 0 1z"/>
                                <path d="M9.646 10.5H12a2.5 2.5 0 0 0 0-5H9.646a.5.5 0 0 1 0-1H12a3.5 3.5 0 0 1 0 7H9.646a.5.5 0 0 1 0-1z"/>
                                <path d="M4.879 8.5a.5.5 0 0 1 0-1h6.242a.5.5 0 0 1 0 1H4.879z"/>
                            </svg>
                        </span>
                        <template slot="alternate">
                            <div class="popover-links">
                                <p><a href="https://cbetaonline.dila.edu.tw/zh/T{$formatted-Tnumber}" target="_blank" rel="noopener noreferrer">Cbeta</a></p>
                                <p><a href="http://21dzk.l.u-tokyo.ac.jp/SAT/T{$formatted-Tnumber}.html" target="_blank" rel="noopener noreferrer">SAT</a></p>
                                <p><a href="https://dazangthings.nz/cbc/text/T{$formatted-Tnumber}" target="_blank" rel="noopener noreferrer">CBC@</a></p>
                                <p><a href="https://mbingenheimer.net/tools/bibls/transbibl.html#T{$formatted-Tnumber}" target="_blank" rel="noopener noreferrer">Western transl.</a></p>
                            </div>
                        </template>
                    </pb-popover>
            }

    let $grouped-references :=
        for $ref-map in $processed-references
        group by $t := $ref-map?Tnumber, $s := $ref-map?sutras_title
        order by
            let $extracted-num-str := replace($t, '^.*?([0-9.]+).*$', '$1')
            return
                if (matches($extracted-num-str, '^[0-9.]+$')) then
                    xs:decimal($extracted-num-str)
                else
                    0 
            return map {
            "Tnumber": $t,
            "sutras_title": $s,
            "inscription": string-join(distinct-values($ref-map?inscription_item), ", ")
        }

    let $sorted-and-paginated-results := subsequence($grouped-references, $start, $limit)

    return map {
        "count": count($grouped-references),
        "results": array { $sorted-and-paginated-results }
    }
};

declare function api:text-details($request as map(*)) {
    let $target-tnumber := upper-case($request?parameters?Tnumber)
    let $Tnumber-without-T_ := replace($target-tnumber, '^T_', '')

    let $heading := collection($config:data-docs)/Taisho/heading[@number=$Tnumber-without-T_]

    let $target-int-part := replace($Tnumber-without-T_, "^([0-9]+).*", "$1")
    let $target-suffix :=
        if (matches($Tnumber-without-T_, "^[0-9]+(?:\.[0-9]+)?([A-Z])$"))
        then replace($Tnumber-without-T_, "^[0-9]+(?:\.[0-9]+)?([A-Z])$", "$1")
        else ""
    let $target-padded-number :=
        if (string-length($target-int-part) = 4) then $target-int-part
        else if (string-length($target-int-part) = 3) then concat("0", $target-int-part)
        else if (string-length($target-int-part) = 2) then concat("00", $target-int-part)
        else if (string-length($target-int-part) = 1) then concat("000", $target-int-part)
        else $target-int-part
    let $formatted-target-tnumber := upper-case(concat($target-padded-number, $target-suffix))

    let $refs :=
        for $object in collection($config:data-catalog)/catalog:object
        let $xml-id := string($object/@xml:id)
        for $ref in $object/catalog:references/catalog:ref[@type="taisho"]

        let $current-ref-href := upper-case(string($ref/@xlink:href))
        let $cleaned-ref-href := replace($current-ref-href, "^T_", "")
        let $ref-int-part := replace($cleaned-ref-href, "^([0-9]+).*", "$1")
        let $ref-suffix :=
            if (matches($cleaned-ref-href, "^[0-9]+(?:\.[0-9]+)?([A-Z])$"))
            then replace($cleaned-ref-href, "^[0-9]+(?:\.[0-9]+)?([A-Z])$", "$1")
            else ""
        let $ref-padded-number :=
            if (string-length($ref-int-part) = 4) then $ref-int-part
            else if (string-length($ref-int-part) = 3) then concat("0", $ref-int-part)
            else if (string-length($ref-int-part) = 2) then concat("00", $ref-int-part)
            else if (string-length($ref-int-part) = 1) then concat("000", $ref-int-part)
            else $ref-int-part
        let $normalized-ref-tnumber := upper-case(concat("T_", $ref-padded-number, $ref-suffix))
        where $normalized-ref-tnumber = $target-tnumber

        return map {
            "ref": $ref,
            "xml-id": $xml-id
        }

    let $title-text := $heading

    return
        <div class="text-details-container">
            <header class="text-details-header">
                <h1 class="t-number-title">{$target-tnumber} - {$title-text}</h1>
            </header>

            <section class="external-links-section">
                <h2>External links</h2>
                <ul class="link-list">
                    <li><a href="{concat('https://cbetaonline.dila.edu.tw/zh/', $formatted-target-tnumber)}" target="_blank" rel="noopener noreferrer">Cbeta</a></li>
                    <li><a href="{concat('http://21dzk.l.u-tokyo.ac.jp/SAT/', $formatted-target-tnumber, '.html')}" target="_blank" rel="noopener noreferrer">SAT</a></li>
                    <li><a href="{concat('https://dazangthings.nz/cbc/text/', $formatted-target-tnumber)}" target="_blank" rel="noopener noreferrer">CBC@</a></li>
                    <li><a href="{concat('https://mbingenheimer.net/tools/bibls/transbibl.html#T', $formatted-target-tnumber)}" target="_blank" rel="noopener noreferrer">Western transl.</a></li>
                </ul>
            </section>

            <section class="details-section">
                <h2>Inscription</h2>
                <ul class="inscriptions-list">
                {
                    for $item in $refs 
                    let $inscription-xml-id := $item?xml-id 
                    let $ref-node := $item?ref 
                    let $page := string-join($ref-node/catalog:pages ! normalize-space(.), ", ") 
                    let $doc := collection($config:data-catalog)/catalog:object[@xml:id=string($inscription-xml-id)]
                    let $title := $doc/catalog:header/catalog:title[1]
                    return
                        <li>
                            <span class="inscription-item-label">Page: {$page}, </span>
                            <a href="{concat('inscriptions/', $inscription-xml-id)}" target="_blank" rel="noopener noreferrer">{$title} ({$inscription-xml-id})</a>
                        </li>
                }
                </ul>
            </section>
        </div>

};

declare function api:reigns($request as map(*)) {
  let $search := $request?parameters?search
  let $options := query:options(())

  let $query := if ($search and normalize-space($search) != "")
                then $search
                else "*:*"

  let $reigns-all := collection($config:data-biblio)/reign_mentions_summary/reign_entry[ft:query(., $query, $options)]
  let $reigns-filtered := $reigns-all

  let $nil := session:set-attribute($config:session-prefix || ".reigns", $reigns-filtered)

  let $grouped :=
    for $reign in $reigns-filtered 
    let $dynasty_name_zh := normalize-space($reign/dynasty_info/dynasty_name_zh)
    let $dynasty_name_en := normalize-space($reign/dynasty_info/dynasty_name_en)

    let $display_dynasty_name :=
      if ($dynasty_name_zh != "" and $dynasty_name_en != "") then
        concat($dynasty_name_zh, " (", $dynasty_name_en, ")")
      else if ($dynasty_name_zh != "") then
        $dynasty_name_zh
      else if ($dynasty_name_en != "") then
        $dynasty_name_en
      else
        "未知朝代"

    group by $dynasty_key := $display_dynasty_name
    let $sample := $reign[1]
    let $dynasty_from := number($sample/dynasty_info/dynasty_from)
    order by $dynasty_from
    return
      <div class="dynasty-category">
        <h2>{$dynasty_key}</h2>
        {
          for $current-reign in $reign 
          let $reign_id := string($current-reign/reign_id)
          let $reign_name_zh := normalize-space($current-reign/reign_name_zh)
          let $reign_name_en := normalize-space($current-reign/reign_name_en)

            let $reign_from_raw := $current-reign/reign_from
            let $reign_to_raw := $current-reign/reign_to
            
            let $reign_from := 
              if ($reign_from_raw castable as xs:integer) then string(xs:integer($reign_from_raw)) else ""
            
            let $reign_to := 
              if ($reign_to_raw castable as xs:integer) then string(xs:integer($reign_to_raw)) else ""
            
            let $reign_year_range :=
              if ($reign_from != "" and $reign_to != "") then
                concat(" (", $reign_from, "–", $reign_to, ")")
              else if ($reign_from != "") then
                concat(" (", $reign_from, "–?)")
              else
                ""

            
            let $final_reign_name :=
              if ($reign_name_zh != "" and $reign_name_en != "") then
                concat($reign_name_zh, " (", $reign_name_en, ")", $reign_year_range)
              else if ($reign_name_zh != "") then
                concat($reign_name_zh, $reign_year_range)
              else if ($reign_name_en != "") then
                concat($reign_name_en, $reign_year_range)
              else
                concat("未知年号", $reign_year_range)


          order by lower-case($reign_id) 
          return
            <div class="reign">
              <a data-reign-id="{$reign_id}" class="reign-item-link">{$final_reign_name}</a>
            </div>
        }
      </div>

  return
    <div class="all-reigns">
      {$grouped}
    </div>
};
