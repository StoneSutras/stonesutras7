module namespace layout="https://stonesutras.org/api/layout";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace svg="http://www.w3.org/2000/svg";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";

declare variable $layout:font-size := 24;

declare variable $layout:interpunktion := '』『」「。，、： ；？！.,:;?!&#10;&#13;“”‘’（）·«»⌉⌈/[]［］…';

declare variable $layout:spaces := "                                     ";

declare function layout:svg($request as map(*)) {
    let $id := $request?parameters?id
    let $xml := collection($config:data-docs)/id($id)/tei:body/tei:div[@xml:lang='zh']
    return
        layout:generate($id, $xml)
};

declare function layout:extract-text($node as node()) {
    typeswitch ($node)
        case element(tei:supplied) return
            let $sup :=  <sup>{ for $child in $node/node() return layout:extract-text($child) }</sup>
            return
                if ($sup//lb) then (
                    for $lb in $sup//lb
                    let $before := $lb/preceding-sibling::lb
                    for $node in $lb/preceding-sibling::node()
                    where empty($before) or $node >> $before
                    return (
                        <sup>{$node}</sup>, <lb/>
                    ),
                    <sup>{$sup//lb[last()]/following-sibling::node()}</sup>
                ) else
                    $sup
        case element(tei:lb) return
            <lb/>
        case element(tei:space) return
            for $i in 1 to $node/@extent
            return
                <space/>
        case element(tei:choice) return
            if ($node/tei:unclear/@cert) then
                let $max := max($node/tei:unclear/@cert)
                return
                    layout:extract-text($node/tei:unclear[@cert = $max])
            else
                layout:extract-text($node/tei:unclear[1])
        case element(tei:app) return
            layout:extract-text($node/tei:lem)
        case element(tei:hi) return
            if ($node/@rend = "smaller") then
                <smaller>{for $child in $node/node() return layout:extract-text($child)}</smaller>
            else
                for $child in $node/node() return layout:extract-text($child)
        case element(tei:note) return ()
        case element() return
            for $child in $node/node() return layout:extract-text($child)
        case comment() return
            ()
        default return translate($node, $layout:interpunktion, "")
};

declare function layout:draw-node($node as node(), $remaining as node()*, $pos as xs:int, $xoffset as xs:int) {
    let $points := if ($node instance of element(space)) then 20 else string-to-codepoints(translate($node, " ", ""))
    return (
        for $code at $p in $points
        let $output :=
            typeswitch ($node)
                case element(space) return
                    let $n := if ($node/@n != '') then xs:int($node/@n) else 1
                    return
                        substring($layout:spaces, 1, $n)
                case element(smaller) return
                    <tspan xmlns="http://www.w3.org/2000/svg" class="smaller" x="{$layout:font-size idiv 4}px">{codepoints-to-string($code)}</tspan>
                default return
                    codepoints-to-string($code)
        return
            <text xmlns="http://www.w3.org/2000/svg" x="{$xoffset}" y="{($pos + $p) * ($layout:font-size * 1.5)}">
            {
                if ($node instance of element(sup)) then
                    attribute fill { "#909090" }
                else
                    ()
            }
            {
                $output
            }
            </text>,
        if (empty($remaining)) then
            ()
        else
            layout:draw-node($remaining[1], subsequence($remaining, 2), $pos + count($points), $xoffset)
    )
};

declare function layout:draw-column($column as element(c), $xoffset as xs:int) {
    let $nodes := $column/node()
    return
        if (empty($nodes)) then
            ()
        else
            layout:draw-node($nodes[1], subsequence($nodes, 2), 0, $xoffset)
};

declare function layout:scale($size, $max) {
    if ($size gt $max) then
		$max div $size
	else
		()
};

declare function layout:draw($columns as element(c)*, $direction as xs:string?) {
    let $maxCol := max(for $c in $columns return string-length(translate($c, " ", "")) + count($c/space))
    let $xspace := $layout:font-size * 2
    let $height := $maxCol * ($layout:font-size * 1.5)
    let $width := count($columns) * $xspace
	let $scale :=
		if ($height gt $width) then
			layout:scale($height, 960)
		else
			layout:scale($width, 770)
    return
        <svg xmlns="http://www.w3.org/2000/svg">
            <defs>
                <style type="text/css">
                    text {{
                        font-family: SimSun;
                        font-size: {$layout:font-size}px;
                    }}
                    .smaller {{
                        font-size: {$layout:font-size idiv 2}px;
                    }}
                </style>
            </defs>
            <g id="text">
			{
				if ($scale) then
					attribute transform { concat("scale(", $scale, ")") }
				else
					()
			}
            {
                let $cols := if ($direction = 'lr') then $columns else reverse($columns)
                for $column at $p in $cols
                return
                    layout:draw-column($column, ($p - 1) * $xspace)
            }
            </g>
        </svg>
};

declare function layout:generate($id as xs:string, $div as element()) {
    let $layout := doc(concat($config:data-layouts, "/", $id, ".svg"))/svg:svg
    return
        if ($layout) then
            element { node-name($layout) } {
                $layout/@* except ($layout/@width, $layout/@height),
                $layout/node()
            }
        else
            let $direction := $div/@rend
            let $text := <r>{layout:extract-text($div)}</r>
            let $columns :=
                if ($text/lb) then
                    for $lb in $text/lb
                    return
                        <c>
                        {
                            let $next := $lb/following-sibling::lb
                            for $node in $lb/following-sibling::node()
                            where empty($next) or $node << $next
                            return
                                $node
                        }
                        </c>
                else
                    <c>{$text}</c>
            return
                layout:draw($columns, $direction)
};