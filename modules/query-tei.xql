(:
 :
 :  Copyright (C) 2017 Wolfgang Meier
 :
 :  This program is free software: you can redistribute it and/or modify
 :  it under the terms of the GNU General Public License as published by
 :  the Free Software Foundation, either version 3 of the License, or
 :  (at your option) any later version.
 :
 :  This program is distributed in the hope that it will be useful,
 :  but WITHOUT ANY WARRANTY; without even the implied warranty of
 :  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 :  GNU General Public License for more details.
 :
 :  You should have received a copy of the GNU General Public License
 :  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 :)
xquery version "3.1";

module namespace teis="http://www.tei-c.org/tei-simple/query/tei";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace c = "http://exist-db.org/ns/catalog";
declare namespace xlink = "http://www.w3.org/1999/xlink";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";
import module namespace nav="http://www.tei-c.org/tei-simple/navigation/tei" at "navigation-tei.xql";
import module namespace query="http://www.tei-c.org/tei-simple/query" at "query.xql";

declare function teis:query-default($fields as xs:string+, $query as xs:string, $target-texts as xs:string*,
    $sortBy as xs:string*) {
    if(string($query)) then
        for $field in $fields
        return
            switch ($field)
                case "head" return
                    if ($target-texts) then
                        for $text in $target-texts
                        return
                            $config:data-root ! doc(. || "/" || $text)//tei:head[ft:query(., $query, query:options($sortBy))]
                    else
                        collection($config:data-root)//tei:head[ft:query(., $query, query:options($sortBy))]
                default return
                    if ($target-texts) then
                        for $text in $target-texts
                        return
                            $config:data-root ! doc(. || "/" || $text)//tei:div[ft:query(., $query, query:options($sortBy))] |
                            $config:data-root ! doc(. || "/" || $text)//tei:text[ft:query(., $query, query:options($sortBy))]
                    else (
                        (: util:log('INFO', 'Querying NGRAM'), :)
                        (: collection($config:data-root)//tei:body[ngram:contains(., $query)] :)
                        for $hit in collection($config:data-root)//tei:body[ft:query(., $query, query:options($sortBy))]
                        where ft:field($hit, "type") = ("site", "cave", "inscription")
                        return
                            $hit
                    )
    else ()
};

declare function teis:query-metadata($path as xs:string?, $field as xs:string?, $query as xs:string?, $sort as xs:string) {
    let $queryExpr := 
        if ($field = "file" or empty($query) or $query = '') then 
            "file:*" 
        else
            ($field, "text")[1] || ":" || $query
    let $options := query:options($sort, ($field, "text")[1])
    let $result :=
        $config:data-default ! (
            collection(. || "/" || $path)//tei:text[ft:query(., $queryExpr, $options)]
        )
    return
        query:sort($result, $sort)
};

declare function teis:autocomplete($doc as xs:string?, $fields as xs:string+, $q as xs:string) {
    for $field in $fields
    return
        switch ($field)
            case "author" return
                collection($config:data-root)/ft:index-keys-for-field("author", $q,
                    function($key, $count) {
                        $key
                    }, 30)
            case "file" return
                collection($config:data-root)/ft:index-keys-for-field("file", $q,
                    function($key, $count) {
                        $key
                    }, 30)
            case "text" return
                if ($doc) then (
                    doc($config:data-root || "/" || $doc)/util:index-keys-by-qname(xs:QName("tei:div"), $q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index"),
                    doc($config:data-root || "/" || $doc)/util:index-keys-by-qname(xs:QName("tei:text"), $q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
                ) else (
                    collection($config:data-root)/util:index-keys-by-qname(xs:QName("tei:div"), $q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index"),
                    collection($config:data-root)/util:index-keys-by-qname(xs:QName("tei:text"), $q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
                )
            case "head" return
                if ($doc) then
                    doc($config:data-root || "/" || $doc)/util:index-keys-by-qname(xs:QName("tei:head"), $q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
                else
                    collection($config:data-root)/util:index-keys-by-qname(xs:QName("tei:head"), $q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
            default return
                collection($config:data-root)/ft:index-keys-for-field("title", $q,
                    function($key, $count) {
                        $key
                    }, 30)
};

declare function teis:get-parent-section($node as node()) {
    ($node/self::tei:text, $node/ancestor-or-self::tei:div[1], $node)[1]
};

declare function teis:get-breadcrumbs($config as map(*), $hit as node(), $parent-id as xs:string) {
    let $id := root($hit)//tei:text/@xml:id
    let $inscriptionCatalog := collection($config:data-catalog)/id($id)
    let $catalog :=
        if ($inscriptionCatalog) then
            $inscriptionCatalog
        else
            let $siteCatalog := collection($config:data-catalog)/id(substring-after($id, 'Site_'))
            return
                if ($siteCatalog) then
                    $siteCatalog
                else
                    collection($config:data-catalog)/c:object[.//c:link[@type='introduction']/@xlink:href = $id]
    let $site :=
        if ($catalog/@type=('site','cave')) then
            $catalog
        else
            collection($config:data-catalog)/c:object[@type=('site', 'cave')][c:fileDescription/c:link[@type='inscription'][@xlink:href=$catalog/@xml:id]]
    return
        <div class="breadcrumbs">
            <a class="breadcrumb" href="#">
                <span lang="zh">{$site/c:header/c:province[@*:lang="zh"]}</span>
                <span>{$site/c:header/c:province[@*:lang="en"]}</span>
            </a>
            <a class="breadcrumb" href="sites/{$site/@xml:id}">
                <span lang="zh">{$site/c:header/c:title[@*:lang="zh"][@type="given"]/string()}</span>
                <span>{$site/c:header/c:title[@*:lang="en"][@type="given"]/string()}</span>
            </a>
            {
                if ($catalog/@type='inscription') then
                    <a class="breadcrumb" href="inscriptions/{$catalog/@xml:id}">
                        <span lang="zh">{$catalog/c:header/c:title[@*:lang="zh"][@type="given"]/string()}</span>
                        <span>{$catalog/c:header/c:title[@*:lang="en"][@type="given"]/string()}</span>
                    </a>
                else
                    ()
            }
        </div>
};

(:~
 : Expand the given element and highlight query matches by re-running the query
 : on it.
 :)
declare function teis:expand($data as node()) {
    let $query := session:get-attribute($config:session-prefix || ".query")
    let $field := session:get-attribute($config:session-prefix || ".field")
    let $div :=
        if ($data instance of element(tei:pb)) then
            let $nextPage := $data/following::tei:pb[1]
            return
                if ($nextPage) then
                    if ($field = "text") then
                        (
                            ($data/ancestor::tei:div intersect $nextPage/ancestor::tei:div)[last()],
                            $data/ancestor::tei:text
                        )[1]
                    else
                        $data/ancestor::tei:text
                else
                    (: if there's only one pb in the document, it's whole
                      text part should be returned :)
                    if (count($data/ancestor::tei:text//tei:pb) = 1) then
                        ($data/ancestor::tei:text)
                    else
                      ($data/ancestor::tei:div, $data/ancestor::tei:text)[1]
        else
            $data
    let $result := teis:query-default-view($div, $query, $field)
    let $expanded :=
        if (exists($result)) then
            util:expand($result, "add-exist-id=all")
        else
            $div
    return
        if ($data instance of element(tei:pb)) then
            $expanded//tei:pb[@exist:id = util:node-id($data)]
        else
            $expanded
};


declare %private function teis:query-default-view($context as element()*, $query as xs:string, $fields as xs:string+) {
    for $field in $fields
    return
        switch ($field)
            case "head" return
                $context[./descendant-or-self::tei:head[ft:query(., $query, $query:QUERY_OPTIONS)]]
            default return
                $context[./descendant-or-self::tei:div[ft:query(., $query, $query:QUERY_OPTIONS)]] |
                $context[./descendant-or-self::tei:text[ft:query(., $query, $query:QUERY_OPTIONS)]]
};

declare function teis:get-current($config as map(*), $div as node()?) {
    if (empty($div)) then
        ()
    else
        if ($div instance of element(tei:teiHeader)) then
            $div
        else
            (nav:filler($config, $div), $div)[1]
};
