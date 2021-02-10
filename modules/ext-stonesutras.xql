xquery version "3.1";

module namespace es="http://stonesutras.org/ext-common";

declare function es:fix-punctuation($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch($node)
            case element() return
                element { node-name($node) } {
                    $node/@*,
                    es:fix-punctuation($node/node())
                }
            case text() return
                text{ translate($node/string(), "。！，、、？：“” ‘’", "") }
            default return
                $node
};

declare function es:wrap-text($config as map(*), $node as node(), $class as xs:string+, $content) {
    let $text := $content ! (
        typeswitch (.)
            case text() return
                .
            default return
                text { . }
    )
    return
        <span class="t">{$text}</span>
};