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

declare function es:finish($config as map(*), $input as node()*) {
    es:clear-whitespace($input, ())
};

declare function es:clear-whitespace($nodes as node()*, $lang as xs:string?) {
    for $node in $nodes
    return
        typeswitch($node)
            case document-node() return
                document {
                    es:clear-whitespace($node/node(), $lang)
                }
            case element() return
                if ($node/@lang = 'zh') then
                    element {node-name($node) } {
                        $node/@*,
                        es:clear-whitespace($node/node(), 'zh')
                    }
                else
                    element { node-name($node) } {
                        $node/@*,
                        es:clear-whitespace($node/node(), $lang)
                    }
            case text() return
                if ($lang = 'zh') then
                    replace($node, "\s+", "")
                else
                    $node
            default return
                $node
};