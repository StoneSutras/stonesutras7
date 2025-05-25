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
        if ($mad/mads:variant[@transliteration or @lang]) then
            let $filteredVariants := 
                for $v in $mad/mads:variant[@transliteration or @lang]
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
        let $is_site := starts-with($tei_xml_id, 'Site_')
        
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

    declare function api:places($request as map(*)) {
        let $search := normalize-space($request?parameters?search)
        let $typeParam := $request?parameters?category
        let $places := api:places-name-to-display($search)
    
        let $sortedPlaces := 
            for $place in $places
            let $sortKey := lower-case(string($place?name_to_display))
            let $type := string($place?type)
            order by $sortKey
            return map {
                "sortKey": $sortKey,
                "name_to_display": $place?name_to_display,
                "id": $place?id,
                "type": $type
            }
    
        let $displayItems := 
            array {
                for $place in 
                    if ($typeParam = "All" or not($typeParam)) then 
                        $sortedPlaces
                    else 
                        filter($sortedPlaces, function($entry) {
                            $entry?type = $typeParam
                        })
                return 
                    <span>
                        <a href="place.html?id={$place?id}">{$place?name_to_display}</a>
                    </span>
            }
    
        let $categories := 
            let $types := distinct-values(for $p in $sortedPlaces return $p?type)
            return array {
                for $type in $types
                let $hits := count(filter($sortedPlaces, function($entry) { $entry?type = $type }))
                where $hits > 0
                order by $type
                return map {
                    "category": $type,
                    "count": $hits
                },
                map {
                    "category": "All",
                    "count": count($sortedPlaces)
                }
            }
    
        return map {
            "items": $displayItems,
            "categories": $categories
        }
    };
        
    declare function api:places-name-to-display($search as xs:string?) as map()* {
        let $query := normalize-space($search)
        let $places :=
            if ($query != "") then
                collection($config:data-biblio)//place[
                    contains(lower-case(name_zh), lower-case($query)) or
                    contains(lower-case(name_en), lower-case($query))
                ]
            else
                collection($config:data-biblio)//place
    
        for $place in $places
        let $id := string($place/@id)
        let $name_zh := string($place/name_zh)
        let $name_en := string($place/name_en)
        let $type := string($place/@type)
        let $final_name_with_dates := 
            if ($name_zh != "" and $name_en != "") then
                concat($name_en, " (", $name_zh, ")")
            else if ($name_zh != "") then
                $name_zh
            else
                $name_en
    
        return map {
            "id": $id,
            "name_to_display": $final_name_with_dates,
            "type": $type
        }
    };


declare function api:place-info($request as map(*)) {
    let $id := $request?parameters?id
    let $places := collection($config:data-biblio)/places
    let $place := $places/place[@id = $id] 
    let $name_zh := string($place/name_zh)
    let $name_en := string($place/name_en)
    let $type := string($place/@type)
    let $sources := $place/*[starts-with(name(), 'source')] ! string()
    
    let $name := 
        if ($name_zh != "" and $name_en != "") then
            concat($name_en, " (", $name_zh, ")")
        else if ($name_zh != "") then
            $name_zh
        else
            $name_en
    
    let $wiki-link := $place/Wikipedia_link/string()

    
    return 
        <div>
            <div class="person-head">
                <h1>{$name}</h1>
                <p>(Type: {$type})</p>
            </div>
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




