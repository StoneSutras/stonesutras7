(:~
 : Implements a mechanism to replace a fragment shown by `pb-view` with another, aligned fragment, e.g. the translation
 : corresponding to a page of the transcription. The local name of a function in this module can be passed to the
 : `map` property of the `pb-view`.
 :)
module namespace mapping="http://www.tei-c.org/tei-simple/components/map";

import module namespace nav="http://www.tei-c.org/tei-simple/navigation/tei" at "navigation-tei.xql";
import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace c = "http://exist-db.org/ns/catalog";

declare function mapping:translation($root as node(), $userParams as map(*)) {
    let $id := root($root)//tei:text/@xml:id
    let $catalog := collection($config:data-catalog)/id($id)
    return
        if ($catalog//c:link[@type='translation']) then
            collection($config:data-root)/id($catalog//c:link[@type='translation']/@xlink:href)
        else
            $root//tei:text/tei:body/tei:div[@xml:lang='en']
};

declare function mapping:catalog($root as node(), $userParams as map(*)) {
    let $id := root($root)//tei:text/@xml:id
    return
        collection($config:data-catalog)/id($id)
};

declare function mapping:description($root as node(), $userParams as map(*)) {
    let $id := root($root)//tei:text/@xml:id
    let $catalog := collection($config:data-catalog)/id($id)
    let $description := $catalog//c:description/@src
    return
        if ($description) then
            doc($config:data-catalog || "/" || $description)
        else
            ()
};

declare function mapping:site($root as node(), $userParams as map(*)) {
    let $id := root($root)//tei:text/@xml:id
    let $catalog := collection($config:data-catalog)/id(substring-after($id, 'Site_'))
    return
        if ($catalog) then
            $catalog
        else
            collection($config:data-catalog)/c:object[.//c:link[@type='introduction']/@xlink:href = $id]
};

declare function mapping:language($root as node(), $userParams as map(*)) {
    let $rootParam := request:get-parameter("root", ())
    return
        if (exists($rootParam)) then
            $root
        else
            let $lang := replace($userParams?language, "^([^_-]+)[_-].*$", "$1")
            return
            switch($lang)
                case "zh" return
                    root($root)//tei:body/tei:div[@xml:lang="zh"]
                default return
                    root($root)//tei:body/tei:div[@xml:lang="en"]
};

declare function mapping:cbeta($root as node(), $userParams as map(*)) {
    let $cbeta := doc($config:data-root || "/T08n0235.xml")//tei:body
    let $lines := $root//tei:lb[@ed='T']/@n
    let $startId := tokenize($lines[1], '_')[2]
    let $endId := tokenize($lines[last()], '_')[2]
    let $start := $cbeta//tei:lb[@n = $startId]
    let $end := $cbeta//tei:lb[@n = $endId]
    let $chunk := nav:milestone-chunk($start, $end, $cbeta)
    return
        $chunk
};

(:~
 : For the Van Gogh letters: find the page break in the translation corresponding
 : to the one shown in the transcription.
 :)
declare function mapping:vg-translation($root as element(), $userParams as map(*)) {
    let $id := ``[pb-trans-`{$root/@f}`-`{$root/@n}`]``
    let $node := root($root)/id($id)
    return
        $node
};

declare function mapping:cortez-translation($root as element(), $userParams as map(*)) {
    let $first := (($root/following-sibling::text()/ancestor::*[@xml:id])[last()], $root/following-sibling::*[@xml:id], ($root/ancestor::*[@xml:id])[last()])[1]
    let $last := $root/following::tei:pb[1]
    let $firstExcluded := ($last/following-sibling::*[@xml:id], $last/following::*[@xml:id])[1]

    let $mappedStart := root($root)/id(translate($first/@xml:id, "s", "t"))
    let $mappedEnd := root($root)/id(translate($firstExcluded/@xml:id, "s", "t"))
    let $context := root($root)//tei:text[@type='translation']

    return
        nav:milestone-chunk($mappedStart, $mappedEnd, $context)
};

(:~  mapping by retrieving same book number in the translation; assumes div view  ~:)
declare function mapping:barum-book($root as element(), $userParams as map(*)) {
        let $bookNumber := $root/@n
        let $node := root($root)//tei:text[@type='translation']//tei:div[@type="book"][@n=$bookNumber]

    return
        $node
};

(:~  mapping by translating id prefix, by default from prefix s to t1  ~:)
declare function mapping:prefix-translation($root as element(), $userParams as map(*)) {
    let $sourcePrefix := ($userParams?sourcePrefix, 's')[1]
    let $targetPrefix := ($userParams?targetPrefix, 't1')[1]
   
    let $id := $root/@xml:id
    
    let $node := root($root)/id(translate($id, $sourcePrefix, $targetPrefix))

    return
        $node
};

(:~  mapping trying to find a node in the same relation to the base of translation as current node to the base of transcription  ~:)
declare function mapping:offset-translation($root as element(), $userParams as map(*)) {
    
let $language := ($userParams?language, 'en')[1]

let $node-id := util:node-id($root)

let $source-root := util:node-id(root($root)//tei:text[@type='source']/tei:body)
let $translation-root := util:node-id(root($root)//tei:text[@type='translation'][@xml:lang=$language]/tei:body)

let $offset := substring-after($node-id, $source-root)

let $node := util:node-by-id(root($root), $translation-root || $offset) 

return 
    $node

};

