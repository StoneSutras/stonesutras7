xquery version "3.0";

module namespace tei2fo="http://www.stonesutras.org/publication/tei2fo";

import module namespace foc="http://www.stonesutras.org/publication/config" at "fo-config.xql";
import module namespace table="http://www.stonesutras.org/publication/fo/modules/table" at "table.xql";
import module namespace settings="http://www.stonesutras.org/publication/fo/modules/settings" at "settings.xql";
import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";


import module namespace counter="http://exist-db.org/xquery/counter"
    at "java:org.exist.xquery.modules.counter.CounterModule";

declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mads="http://www.loc.gov/mads/";
declare namespace axf="http://www.antennahouse.com/names/XSL/Extensions";
declare namespace catalog="http://exist-db.org/ns/catalog";
declare namespace sx="http://stonesutras.org/elements";

declare function tei2fo:process($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch ($node)
            case processing-instruction() return
                tei2fo:pi($node)
            case text() return
                if (fn:contains($node, "“") and exists($node/ancestor::tei:note)) then
                    if (tei2fo:get-lang($node/..) = "zh") then
                        <fo:inline font-family="SimSun">{tei2fo:characters($node)}</fo:inline>
                    else
                        tei2fo:characters($node)
                else
                    tei2fo:characters($node)
            case element(sx:pb) return
                <fo:block page-break-after="always"><!-- pb pi --></fo:block>
            case element(tei:body) return
                <fo:block>
                { tei2fo:process($node/*) }
                </fo:block>
            case element(tei:div) return
                tei2fo:div($node, tei2fo:process#1)
            case element(tei:seg) return
                tei2fo:process($node/node())
            case element(tei:p) return
                tei2fo:p($node)
            case element(tei:lb) return
                <fo:block/>
            case element(tei:ab) return
                <fo:block font-family="{if ($node/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}"
                    xml:lang="{if ($node/ancestor::tei:div[@xml:lang='zh']) then 'zh' else 'en'}" space-after="{if ($node/tei:abbr) then '16pt' else '0pt'}">
                    { tei2fo:process($node/node()) }
                </fo:block>

                (:case element(tei:ab)
                return


                ab:abswich ($node):)
            case element(tei:quote) return
                let $cn := exists($node/ancestor::tei:div[@xml:lang = "zh"])
                return
                    (: entfernt: text-indent="{if ($cn) then '2em' else ()}" :)
                    <fo:block text-indent="0" font-family="{if ($cn) then $foc:ChineseFontQuotes else $foc:DefaultFont}"
                        xml:lang="{if ($cn) then 'zh' else 'en'}">
                    { if ($node/@rend="continued") then foc:attributes($foc:quotecontinued) else foc:attributes($foc:quote) }
                    {
                        if (not($node/ancestor::tei:note)) then (
                            attribute font-size { "12pt" },
                            attribute line-height { "16pt" }
                        ) else
                            ()
                    }
                    {
                        tei2fo:process($node/node())
                    }
                    </fo:block>
            case element(tei:byline) return
                let $cn := exists($node/ancestor::tei:div[@xml:lang = "zh"]) or exists($node/ancestor::tei:foreign[@xml:lang = "zh"])
                return
                    <fo:inline font-family="{if ($cn) then $foc:ChineseFontQuotes else $foc:DefaultFont}" xml:lang="{if ($cn) then 'zh' else 'en'}">
                    {
                        tei2fo:process($node/node())
                    }
                    </fo:inline>
            case element(tei:anchor) return
                <fo:inline id="{$node/@xml:id}">{$node/node()}</fo:inline>
            case element(tei:abbr) return
                if ($node/ancestor::tei:div/@xml:lang="zh") then
                    <fo:block keep-with-previous.within-column="always" text-align="right"
                    font-size="{$foc:FontSizeDefault[1]}" line-height="{$foc:FontSizeDefault[2]}">（{tei2fo:process($node/node())}）</fo:block>
                else
                    <fo:block keep-with-previous.within-column="always" text-align="right"
                    font-size="{$foc:FontSizeDefault[1]}" line-height="{$foc:FontSizeDefault[2]}">({tei2fo:process($node/node())})</fo:block>
            case element(tei:foreign) return
                switch ($node/@xml:lang)
                    case "zh" return
                        <fo:inline font-family="{$foc:ChineseFont}">
                        { tei2fo:process($node/node()) }
                        </fo:inline>
                    case "en" return
                        if ($node/ancestor::tei:head) then
                            <fo:inline white-space-treatment="preserve" font-family="{if ($node/ancestor::tei:div[@xml:lang='zh']) then $foc:SanskritFontHead else $foc:EnglishFont}">{tei2fo:process($node/node())}</fo:inline>
                        else if ($node/ancestor::tei:div/@xml:lang = "zh") then
(:                        else if ($node/ancestor::tei:div/@xml:lang = "zh" and not($node/ancestor::tei:note)) then:)
                            <fo:inline white-space-treatment="preserve">{tei2fo:process($node/node())}</fo:inline>
                        else
                            <fo:inline white-space-treatment="preserve">{tei2fo:process($node/node())}</fo:inline>
                    case "sa" return
                        if (exists($node/ancestor::catalog:title) or exists($node/ancestor::tei:head)) then
                            <fo:inline white-space-treatment="ignore-if-surrounding-linefeed" font-family="{$foc:SanskritFontHead}" xml:lang="sa" hyphenate="true">{ tei2fo:process($node/node()) }</fo:inline>
                        else
                            <fo:inline 
                                white-space-treatment="ignore-if-surrounding-linefeed"  font-family="{if ($node/ancestor::tei:div[@xml:lang='zh']) then $foc:SanskritFontHead else $foc:SanskritFont}" xml:lang="sa" font-size="100%" hyphenate="true">{ tei2fo:process($node/node()) }</fo:inline>
                            (:~ <fo:inline white-space-treatment="preserve"
                                font-family="{$foc:SanskritFont}" xml:lang="sa" font-size="100%" hyphenate="true">{ tei2fo:process($node/node()) }</fo:inline> ~:)
                    case "ja" return
                        <fo:inline font-family="{$foc:JapaneseFont}" hyphenate="false">{ tei2fo:process($node/node()) }</fo:inline>
                    case "ko" return
                        <fo:inline font-family="{$foc:KoreanFont}" hyphenate="false">{ tei2fo:process($node/node()) }</fo:inline>
                    default return
                        tei2fo:process($node/node())
            case element(tei:hi) return
                switch($node/@rend)
                    case "underline" return
                        <fo:inline text-decoration="underline">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "dottedunderline" return
                        <fo:inline text-decoration="underline" axf:text-line-width="thin" axf:text-line-style="dotted">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "italic" return
                        <i>{tei2fo:process(tei2fo:normalize-ws($node/node()))}</i>
                    case "normal" return
                        <fo:inline style="font-style: normal">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "bold" return
                        <fo:inline font-weight="bold">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "smaller" return
                        <fo:inline font-size="85%">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "larger" return
                        <fo:inline font-size="125%">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "color-headings" return
                        <fo:inline color="{$foc:ColorBlue}">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "color-chapters" return
                        <fo:inline color="{$foc:ColorTranscriptTitle}">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "color-scrolls" return
                        <fo:inline color="{$foc:ColorTranscriptScroll}">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "color-g" return
                        <fo:inline color="{$foc:ColorG}">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "color-supplied" return
                        <fo:inline color="{$foc:ColorSupplied}">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "nh" return
                        <fo:inline hyphenate="false">{ tei2fo:process(tei2fo:normalize-ws($node/node())) }</fo:inline>
                     case "nb" return
                        <fo:inline hyphenate="false"  keep-together.within-line="always">{ tei2fo:process(tei2fo:normalize-ws($node/node())) }</fo:inline>
                    case "no-wrap" return
                        <fo:inline hyphenate="false" white-space="nowrap">{ tei2fo:process(tei2fo:normalize-ws($node/node())) }</fo:inline>
                    case "dash" return
                        if ($node/ancestor::*/@xml:lang[1] = "zh") then
                            <fo:inline keep-together.within-line="always" font-family="'PERPETUA TITLING MT'" font-size="75%" white-space-treatment="preserve" hyphenate="false">——</fo:inline>
                        else
                            <fo:inline keep-together.within-line="always" font-family="'Times New Roman'" font-size="85%" white-space-treatment="preserve" hyphenate="false">——</fo:inline>
                    case "standard" return
                        tei2fo:process(tei2fo:normalize-ws($node/node()))
                    case "sup" return 
                        <fo:inline baseline-shift="super" font-size="60%">{ tei2fo:process(tei2fo:normalize-ws($node/node())) }</fo:inline>
                    case "superscript" return 
                        <fo:inline position="relative" left="-1mm" keep-with-previous.within-line="always" font-family="{$foc:DefaultFont}" xml:lang="en" baseline-shift="super" font-size="60%">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "unfinished" return
                        <fo:inline background-color="{$foc:ColorUnfinished}">{ tei2fo:process(tei2fo:normalize-ws($node/node())) }</fo:inline>
                    default return
                        <fo:inline font-family="{$node/@rend}">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
            case element(tei:title) return
                tei2fo:process($node/node())
            case element(tei:ref) return
                tei2fo:ref($node)
            case element(tei:ptr) return
                tei2fo:ptr((), $node)
            case element (tei:lg) return
                let $cn := exists($node/ancestor::tei:div[@xml:lang = "zh"])
                return
                <fo:block
                    font-family="{if ($cn) then $foc:ChineseFontQuotes else $foc:DefaultFont}" font-size="{$foc:FontSizeDefault[1]}" 
                    line-height="{$foc:FontSizeDefault[2]}">
                    { foc:attributes($foc:lg) }
                {
                    for $line in $node/tei:l
                    let $indent := $line/@rend = 'indent'
                    return
                        (:text-indent="{if ($indent) then '2em' else '0'}":)
                            <fo:block  start-indent="3em"  text-indent="-1em">
                            { tei2fo:process-transcript($line) }
                            </fo:block>
                        
                }
                </fo:block>
                 
            case element(tei:note) return
                tei2fo:note($node)
            case element(tei:figure) return
                tei2fo:figure($node)
            case element(tei:graphic) return
                <fo:external-graphic src="{$foc:Images-Path}/{$node/@url}"
                    scaling="uniform" max-height="100%" content-width="scale-to-fit" width="{$foc:Bildbreite-max}"/>
            case element(tei:choice) return
                tei2fo:choice($node, ())
            case element(tei:list) return
                tei2fo:list($node, tei2fo:process#1)
            case element(tei:table) return
                table:tableswitch($node)


            (:case element(tei:person) return

                person:person($node):)




            case element(tei:bibl) return
                tei2fo:discussion($node)
            case element(tei:g) return
(:                if ($node/(ancestor::tei:title|$node/ancestor::tei:head)) then:)
                if ($node/ancestor::tei:head) then
                    $node/text()
                else if ($node/@rend = 'specialfont') then
                    <fo:inline font-family="{$foc:SpecialFont}">{$node/text()}</fo:inline>
                else if ($node/@rend[not(. = ("variant", "standard"))]) then
                    <fo:inline color="{$foc:ColorG}" font-family="{$node/@rend}">{$node/text()}</fo:inline>
                else
                    <fo:inline color="{$foc:ColorG}">{$node/text()}</fo:inline>
            case element(tei:space) return
                let $lang := tei2fo:get-lang($node)
                return
                    <fo:inline font-family="{if ($lang='zh') then 'SimSun' else $foc:DefaultFont}"
                        white-space-collapse="false" white-space-treatment="preserve">
                    {
                        let $count :=
                            if ($node/@n) then
                                $node/@n
                            else if ($node/@extent) then
                                0
                            else 1
                        for $i in 1 to $count return " "
                    }<!-- space--></fo:inline>
            case element(tei:postscript) return
                let $lang := tei2fo:get-lang($node)
                return
                    <fo:block font-size="10pt" line-height="{$foc:FontSizeDefault[2]}" space-before="{$foc:FontSizeDefault[2]}"
                        font-family="{if ($lang='zh') then 'SimSun' else $foc:DefaultFont}">
                        {
                            if ($node/ancestor::tei:div[@xml:lang="zh"]) then (
                                attribute white-space-treatment { "ignore" },
                                attribute linefeed-treatment { "ignore" }
                            ) else
                                ()
                        }
                        {tei2fo:process($node/*/node())}
                    </fo:block>
            case element() return
                tei2fo:process($node/node())
            default return
                $node
};

declare function tei2fo:pi($node) {
    switch (local-name($node))
        case "pb" return
            <fo:block page-break-after="always"><!-- pb pi --></fo:block>
        case "cb" return
            <fo:block break-after="column" text-align="justify"/>
        case "cbraw" return
            <fo:block break-after="column" text-align="justify"/>
        case "column-break" return
            attribute break-after { "column" }
        case "column-break-before" return
            attribute break-before { "column" }
        case "lb" return
            <fo:block/>
        case "half-space" return
            <fo:block-container height="{$foc:HalfLineHeight}">
                <fo:block>
                    <xsl:text>&#160;</xsl:text>
                </fo:block>
            </fo:block-container>
        case "keep-with-next" return
            attribute keep-with-next.within-page {
                let $content := $node/string()
                return
                    if ($content and $content != "") then
                        $content
                    else
                        "always"
            }
        case "keep-with-previous" return
            attribute keep-with-previous.within-page {
                $node/string()
            }
        default return
            ()
};

declare function tei2fo:column-break($pi as processing-instruction()) {
    let $before := $pi/preceding-sibling::node()
    let $after := $pi/following-sibling::node()
    return (
        <fo:block text-align-last="justify" break-after="column">{tei2fo:process($before)}</fo:block>,
        <fo:block text-indent="0pt">{tei2fo:process($after)}</fo:block>
    )
};

declare function tei2fo:process-transcript($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch ($node)
            case processing-instruction() return
                tei2fo:pi($node)
            case element(tei:body) return
                <fo:block>
                { tei2fo:process-transcript($node/*) }
                </fo:block>
            case element(tei:div) return
                tei2fo:div($node, tei2fo:process-transcript#1)
            case element(tei:seg) return
                tei2fo:process-transcript($node/node())
            case element(tei:head) return
                <fo:block space-after="1em">{tei2fo:process-transcript($node/node())}</fo:block>
            case element(tei:p) return
                if ($node/ancestor::tei:div[@xml:lang='en']) then
                    tei2fo:p($node)
                else
                    <fo:block text-indent="12pt" text-align="{if ($node/@rend = 'left') then 'left' else 'justify'}"
                        axf:punctuation-trim="start end adjacent">
                    {
                        if ($node/ancestor::tei:div[@xml:lang="zh"]) then (
                            attribute white-space-treatment { "ignore" },
                            attribute linefeed-treatment { "ignore" }
                        ) else
                            ()
                    }
                    {tei2fo:process-transcript($node/node())}
                    </fo:block>
            case element(tei:ab) return
                <fo:block>
                    { foc:attributes($foc:para) }
                    { tei2fo:process($node/node()) }
                </fo:block>
            case element(tei:byline) return
                let $cn := (exists($node/ancestor::tei:div[@xml:lang = "zh"]) or exists($node[@xml:lang = "zh"]))
                return
                    <fo:inline font-family="{if ($cn) then $foc:ChineseFontQuotes else $foc:DefaultFont}" xml:lang="{if ($cn) then 'zh' else 'en'}">
                    {
                        tei2fo:process($node/node())
                    }
                    </fo:inline>
            case element(tei:abbr) return
                <fo:block keep-with-previous.within-column="always" text-align="right">（{tei2fo:process($node/node())}）</fo:block>
            case element(tei:foreign) return
                switch ($node/@xml:lang)
                    case "zh" return
                        <fo:inline>{ foc:get-font(true()), tei2fo:process-transcript($node/node()) }</fo:inline>
                    case "sa" return
                        <fo:inline font-family="{if ($node/ancestor::tei:div[@xml:lang='zh']) then $foc:SanskritFontHead else $foc:SanskritFont}" hyphenate="false">{ tei2fo:process-transcript($node/node()) }</fo:inline>
                        (:~ <fo:inline font-family="{$foc:SanskritFont}" hyphenate="false">{ tei2fo:process-transcript($node/node()) }</fo:inline> ~:)
                    case "ja" return
                        <fo:inline font-family="{$foc:JapaneseFont}" hyphenate="false">{ tei2fo:process($node/node()) }</fo:inline>
                    case "ko" return
                        <fo:inline font-family="{$foc:KoreanFont}" hyphenate="false">{ tei2fo:process-biblio($node/node()) }</fo:inline>
                    default return
                        <fo:inline white-space-treatment="preserve">{tei2fo:process-transcript($node/node())}</fo:inline>
            case element(tei:g) return
                if ($node/(ancestor::tei:title|$node/ancestor::tei:head)) then
                    $node/text()
                else if ($node/@rend = 'specialfont') then
                    <fo:inline font-family="{$foc:SpecialFont}">{$node/text()}</fo:inline>
                else
                    if ($node/@rend[not(. = ("variant", "standard"))]) then
                        <fo:inline color="{$foc:ColorG}" font-family="{$node/@rend}">{$node/text()}</fo:inline>
                    else
                        <fo:inline color="{$foc:ColorG}">{$node/text()}</fo:inline>
            case element(tei:hi) return
                switch($node/@rend)
                    case "italic" return
                        <i>{tei2fo:process-transcript(tei2fo:normalize-ws($node/node()))}</i>
                    case "bold" return
                        <fo:inline font-weight="bold">{tei2fo:process-transcript(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "smaller" return
                        <fo:inline font-size="85%">{tei2fo:process-transcript(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "color-chapters" return
                        <fo:inline color="{$foc:ColorTranscriptTitle}">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "color-headings" return
                        <fo:inline color="{$foc:ColorBlue}">{tei2fo:process-transcript(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "color-titles" return
                        <fo:inline color="{$foc:ColorTranscriptTitle}">{tei2fo:process-transcript(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "color-g" return
                        <fo:inline color="{$foc:ColorG}">{tei2fo:process-transcript(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "color-supplied" return
                        <fo:inline color="{$foc:ColorSupplied}">{tei2fo:process-transcript(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "nh" return
                        <fo:inline hyphenate="false">{ tei2fo:process-transcript(tei2fo:normalize-ws($node/node())) }</fo:inline>
                    case "dash" return
                        if ($node/ancestor::*/@xml:lang[1] = "zh") then
                            <fo:inline keep-together.within-line="always" font-family="'PERPETUA TITLING MT'" font-size="75%" white-space-treatment="preserve" hyphenate="false">——</fo:inline>
                        else
                            <fo:inline keep-together.within-line="always" font-family="'Times New Roman'" font-size="85%" white-space-treatment="preserve" hyphenate="false">——</fo:inline>
                    case "standard" return
                        tei2fo:process-transcript(tei2fo:normalize-ws($node/node()))
                    default return
                        <fo:inline font-family="{$node/@rend}">{tei2fo:process-transcript(tei2fo:normalize-ws($node/node()))}</fo:inline>
            case element(tei:title) return
                switch($node/@type)
                    case "chapter" return
                        <fo:inline color="{$foc:ColorTranscriptTitle}">
                        {tei2fo:process-transcript($node/node())}
                        </fo:inline>
                    case "scroll" return
                        <fo:inline color="{$foc:ColorTranscriptScroll}">
                        {tei2fo:process-transcript($node/node())}
                        </fo:inline>
                    default return
                        <fo:inline color="{$foc:ColorTranscriptTitle}">
                        {tei2fo:process-transcript($node/node())}
                        </fo:inline>
            case element (tei:lg) return
                 <fo:block margin-left="10mm" space-before="2mm" space-after="2mm">
                    {
                        for $line in $node/tei:l
                        let $indent := $line/@rend = 'indent$$$'
                        return
                        (:text-indent="{if ($indent) then '2em' else '0'}":)
                            <fo:block  start-indent="3em"  text-indent="-1em">
                            { tei2fo:process-transcript($line) }
                            </fo:block>
                    }
                </fo:block>
            case element(tei:lb) return
                if ($node/@ed/string() = "T") then ()else
                <fo:inline keep-together.within-line="always" font-family="{$foc:DefaultFont}" space-start=".5em" space-end=".5em"
                    color="{$foc:ColorBlue}">/{$node/@n/string()}/</fo:inline>
            case element(tei:supplied) return
                if ($node/ancestor::tei:title) then
                    tei2fo:process-transcript($node/node())
                else if ($node/@reason = "unfinished") then
                    <fo:inline background-color="{$foc:ColorUnfinished}">{tei2fo:process-transcript($node/node())}</fo:inline>
                else
                    <fo:inline color="{$foc:ColorSupplied}">{tei2fo:process-transcript($node/node())}</fo:inline>
            case element(tei:ref) return
                tei2fo:ref($node)
            case element(tei:ptr) return
                tei2fo:ptr((), $node)
            case element(tei:anchor) return
                <fo:inline id="{$node/@xml:id}">{$node/node()}</fo:inline>
            case element(tei:note) return
                tei2fo:note($node)
            case element(tei:figure) return
                tei2fo:figure($node)
            case element(tei:choice) return
                tei2fo:choice($node, ())
            case element(tei:app) return
                tei2fo:app($node, true(), ())
            case element(tei:space) return
                let $lang := tei2fo:get-lang($node)
                return
                    <fo:inline font-family="{if ($lang='zh') then 'SimSun' else $foc:DefaultFont}"
                        white-space-collapse="false" white-space-treatment="preserve">
                    {
                        let $count :=
                            if ($node/@n) then
                                $node/@n
                            else if ($node/@extent) then
                                0
                            else 1
                        for $i in 1 to $count return " "
                    }
                    <!-- space--></fo:inline>
            case element() return
                tei2fo:process-transcript($node/node())
            case text() return
                if ($node = "“" and exists($node/ancestor::tei:note)) then
                    if (exists($node/ancestor::tei:div[@xml:lang = "zh"])) then
                        <fo:inline font-family="SimSun">{$node}</fo:inline>
                    else
                        tei2fo:characters($node)
                else
                    tei2fo:characters($node)
            default return
                $node
};

declare function tei2fo:characters($text as text()) {
    let $ana := analyze-string($text, "([&#x25a1;]+)|([·－–]|……)")
    for $group in $ana/*
    return
        typeswitch($group)
            case element(fn:match) return 
                if ($group/fn:group/@nr = "2") then
                    <fo:inline>&#x2060;{$group/string()}</fo:inline>
                else
                    <fo:inline font-family="SimSun">{ $group/string() }</fo:inline>
            default return
                text { $group/string() }
};

declare function tei2fo:discussion($bibl as element(tei:bibl)) {
    let $ref := $bibl/tei:ref
    return
        <fo:block space-after="6pt" font-family="{if ($ref/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}">
            <fo:block keep-with-next.within-page="always" line-height="{$foc:FontSizeDefault[2]}">
                {
                    $ref/preceding-sibling::text(), <fo:inline >{tei2fo:ref($ref)}</fo:inline>
                }
            </fo:block>
            <fo:block>
                {
                    for $note in $bibl/tei:note
                    return
                        tei2fo:process($note/node())
                }
            </fo:block>
        </fo:block>
};

declare function tei2fo:process-biblio($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch ($node)
            case element(mads:foreign) return
                switch ($node/@lang)
                    case "zh" return
                        <fo:inline xml:lang="zh" style="font-style: normal" font-family="{$foc:ChineseFont}">{ tei2fo:process-biblio($node/node()) }</fo:inline>
                    case "en" return
                        <fo:inline white-space-treatment="preserve" font-family="{$foc:DefaultFont}">{tei2fo:process-biblio($node/node())}</fo:inline>
                    (: case "sa" return
                        <fo:inline font-family="{$foc:SanskritFont}" hyphenate="true">{ tei2fo:process-biblio($node/node()) }</fo:inline> :)
                    case "ja" return
                        <fo:inline font-family="{$foc:JapaneseFont}" hyphenate="false">{ tei2fo:process-biblio($node/node()) }</fo:inline>
                    case "ko" return
                        <fo:inline font-family="{$foc:KoreanFont}" hyphenate="false">{ tei2fo:process-biblio($node/node()) }</fo:inline>
                    default return
                        tei2fo:process-biblio($node/node())
            case element(mods:foreign) return
                switch ($node/@lang)
                    case "zh" return
                        <fo:inline xml:lang="zh" style="font-style: normal" font-family="{$foc:ChineseFont}">{ tei2fo:process-biblio($node/node()) }</fo:inline>
                    case "en" return
                        <fo:inline white-space-treatment="preserve" font-family="{$foc:DefaultFont}">{tei2fo:process-biblio($node/node())}</fo:inline>
                    (: case "sa" return
                        <fo:inline font-family="{$foc:SanskritFont}" hyphenate="true">{ tei2fo:process-biblio($node/node()) }</fo:inline> :)
                    case "ja" return
                        <fo:inline font-family="{$foc:JapaneseFont}" hyphenate="false">{ tei2fo:process-biblio($node/node()) }</fo:inline>
                    case "ko" return
                        <fo:inline font-family="{$foc:KoreanFont}" hyphenate="false">{ tei2fo:process-biblio($node/node()) }</fo:inline>
                    default return
                        tei2fo:process-biblio($node/node())
            case element(mods:hi) return
                switch($node/@rend)
                   
                    case "bold" return
                        <fo:inline font-weight="bold">{tei2fo:process-biblio($node/node())}</fo:inline>
                    case "smaller" return
                        <fo:inline font-size="85%">{tei2fo:process-biblio($node/node())}</fo:inline>
                    case "sup" return 
                        <fo:inline baseline-shift="super" font-size="60%">{ tei2fo:process(tei2fo:normalize-ws($node/node())) }</fo:inline>
                    case "italic" return
                        <fo:inline font-style="italic">{tei2fo:process-biblio($node/node())}</fo:inline>
                    case "normal" return
                        <fo:inline style="font-style: normal">{tei2fo:process($node/node())}</fo:inline>
                    case "dash" return
                        <fo:inline keep-together.within-line="always" font-family="'PERPETUA TITLING MT'" font-size="75%" white-space-treatment="preserve" hyphenate="false">——</fo:inline>
                    case "small-caps" return
                        <fo:inline font-family="{$foc:BiblioFont}" font-style="small-caps">{tei2fo:process($node/node())}</fo:inline>
                    default return
                        <fo:inline>{tei2fo:process-biblio($node/node())}</fo:inline>
            case element(mads:hi) return
                switch($node/@rend)
                    case "italic" return
                        <fo:inline font-style="italic">{tei2fo:process-biblio($node/node())}</fo:inline>
                    case "dash" return
                        <fo:inline keep-together.within-line="always" font-family="'Times New Roman'" font-size="75%" white-space-treatment="preserve" hyphenate="false">——</fo:inline>
                    default return
                        <fo:inline>{tei2fo:process-biblio($node/node())}</fo:inline>
            case element(mods:space) return
                let $lang := tei2fo:get-lang($node)
                return
                    <fo:inline font-family="{if ($lang='zh') then 'SimSun' else $foc:DefaultFont}"
                        white-space-collapse="false" white-space-treatment="preserve">
                    {
                        let $count := if ($node/@n) then $node/@n else 1
                        for $i in 1 to $count return " "
                    }
                    <!-- space--></fo:inline>
            case element(mods:ref) return
                switch($node/@type)
                    case "biblio" return
                        let $ref := $node
                        let $mods := collection("//db/apps/stonesutras-data/data/biblio")/mods:mods[@ID = $ref/@target]

                        return
                             if (exists($mods)) then
                             <fo:inline hyphenate="false" font-family="{if ($ref/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}" white-space-treatment="ignore-if-surrounding-linefeed"><fo:inline font-variant="small-caps">{$mods/mods:titleInfo[@type = "reference"]/mods:title/text()}</fo:inline>{ if ($ref/node()) then <fo:inline>, {tei2fo:process-biblio($ref/node()) }</fo:inline> else ()}</fo:inline>
                              else
                             <fo:inline color="red">REF: {$ref/@target/string()}</fo:inline>
                    default return
                        ()
            case element() return
                for $child in $node/node()
                return
                    tei2fo:process-biblio($child)
            default return
                $node
};


declare function tei2fo:process-biblioHTML($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch ($node)
            case element(mads:foreign) return
                switch ($node/@lang)
                    case "zh" return
                        <span xml:lang="zh" style="font-style: normal" font-family="{$foc:ChineseFont}">{ tei2fo:process-biblioHTML($node/node()) }</span>
                    case "en" return
                        <fo:inline white-space-treatment="preserve" font-family="{$foc:DefaultFont}">{tei2fo:process-biblioHTML($node/node())}</fo:inline>
                    (: case "sa" return
                        <fo:inline font-family="{$foc:SanskritFont}" hyphenate="true">{ tei2fo:process-biblioHTML($node/node()) }</fo:inline> :)
                    case "ja" return
                        <fo:inline font-family="{$foc:JapaneseFont}" hyphenate="false">{ tei2fo:process-biblioHTML($node/node()) }</fo:inline>
                    case "ko" return
                        <fo:inline font-family="{$foc:KoreanFont}" hyphenate="false">{ tei2fo:process-biblioHTML($node/node()) }</fo:inline>
                    default return
                        tei2fo:process-biblioHTML($node/node())
            case element(mods:foreign) return
                switch ($node/@lang)
                    case "zh" return
                        <span xml:lang="zh" style="font-style: normal" font-family="{$foc:ChineseFont}">{ tei2fo:process-biblioHTML($node/node()) }</span>
                    case "en" return
                        <fo:inline white-space-treatment="preserve" font-family="{$foc:DefaultFont}">{tei2fo:process-biblioHTML($node/node())}</fo:inline>
                    (: case "sa" return
                        <fo:inline font-family="{$foc:SanskritFont}" hyphenate="true">{ tei2fo:process-biblioHTML($node/node()) }</fo:inline> :)
                    case "ja" return
                        <fo:inline font-family="{$foc:JapaneseFont}" hyphenate="false">{ tei2fo:process-biblioHTML($node/node()) }</fo:inline>
                    case "ko" return
                        <fo:inline font-family="{$foc:KoreanFont}" hyphenate="false">{ tei2fo:process-biblioHTML($node/node()) }</fo:inline>
                    default return
                        tei2fo:process-biblioHTML($node/node())
            case element(mods:hi) return
                switch($node/@rend)
                    case "bold" return
                        <fo:inline font-weight="bold">{tei2fo:process-biblioHTML($node/node())}</fo:inline>
                    case "smaller" return
                        <fo:inline font-size="85%">{tei2fo:process-biblioHTML($node/node())}</fo:inline>
                    case "sup" return 
                        <fo:inline baseline-shift="super" font-size="60%">{ tei2fo:process(tei2fo:normalize-ws($node/node())) }</fo:inline>
                    case "italic" return
                        <i>{tei2fo:process-biblioHTML($node/node())}</i>
                    case "normal" return
                        <fo:inline style="font-style: normal">{tei2fo:process($node/node())}</fo:inline>
                    case "dash" return
                        <fo:inline keep-together.within-line="always" font-family="'PERPETUA TITLING MT'" font-size="75%" white-space-treatment="preserve" hyphenate="false">——</fo:inline>
                    case "small-caps" return
                        <fo:inline font-family="{$foc:BiblioFont}" font-style="small-caps">{tei2fo:process($node/node())}</fo:inline>
                    default return
                        <fo:inline>{tei2fo:process-biblioHTML($node/node())}</fo:inline>
            case element(mads:hi) return
                switch($node/@rend)
                    case "italic" return
                        <i>{tei2fo:process-biblioHTML($node/node())}</i>
                    case "dash" return
                        <fo:inline keep-together.within-line="always" font-family="'Times New Roman'" font-size="75%" white-space-treatment="preserve" hyphenate="false">——</fo:inline>
                    default return
                        <fo:inline>{tei2fo:process-biblioHTML($node/node())}</fo:inline>
            case element(mods:space) return
                let $lang := tei2fo:get-lang($node)
                return
                    <fo:inline font-family="{if ($lang='zh') then 'SimSun' else $foc:DefaultFont}"
                        white-space-collapse="false" white-space-treatment="preserve">
                    {
                        let $count := if ($node/@n) then $node/@n else 1
                        for $i in 1 to $count return " "
                    }
                    <!-- space--></fo:inline>
            case element(mods:ref) return
                switch($node/@type)
                    case "biblio" return
                        let $ref := $node
                        let $mods := collection("//db/apps/stonesutras-data/data/biblio")/mods:mods[@ID = $ref/@target]

                        return
                             if (exists($mods)) then
                             <fo:inline hyphenate="false" font-family="{if ($ref/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}" white-space-treatment="ignore-if-surrounding-linefeed"><fo:inline font-variant="small-caps">{$mods/mods:titleInfo[@type = "reference"]/mods:title/text()}</fo:inline>{ if ($ref/node()) then <fo:inline>, {tei2fo:process-biblioHTML($ref/node()) }</fo:inline> else ()}</fo:inline>
                              else
                             <fo:inline color="red">REF: {$ref/@target/string()}</fo:inline>
                    default return
                        ()
            case element() return
                for $child in $node/node()
                return
                    tei2fo:process-biblioHTML($child)
            default return
                $node
};

declare function tei2fo:process-translation($config as map(*)?, $nodes as node()*) {
    typeswitch ($nodes[1])
        case element(tei:seg) return
            (: Segments: in Gangshan, only print the segments which are part of the current inscription :)
            let $first := $nodes[1]
            let $last := $nodes[2]
            return (
                    tei2fo:process-catalog($config, $first),
                    <fo:inline color="{$foc:ColorSupplied}">
                    {
                        tei2fo:process-catalog($config, $first/following-sibling::tei:* intersect $last/preceding-sibling::tei:*)
                    }
                    </fo:inline>,
                    tei2fo:process-catalog($config, $last)
                )
        default return
            tei2fo:process-catalog($config, $nodes)
};

declare function tei2fo:process-catalog($nodes as node()*) {
    tei2fo:process-catalog((), $nodes)
};

declare function tei2fo:process-catalog($config as map(*)?, $nodes as node()*) {
    for $node in $nodes
    return
        typeswitch ($node)
            case processing-instruction() return
                tei2fo:pi($node)
            case text() return
                if ($node = "“" and exists($node/ancestor::tei:note)) then
                    if (tei2fo:get-lang($node/..) = "zh") then
                        <fo:inline font-family="SimSun">{$node}</fo:inline>
                    else
                        tei2fo:characters($node)
                else
                    tei2fo:characters($node)
            case element(tei:lb) return
                if ($node/@ed/string() = "T") then ()else
                <fo:inline font-family="{$foc:DefaultFont}" space-start=".5em" space-end=".5em"
                    color="{$foc:ColorBlue}">/{$node/@n/string()}/</fo:inline>
            case element(tei:body) return
                <fo:block>
                { tei2fo:process-catalog($config, $node/*) }
                </fo:block>
            case element(tei:head) return
                <fo:block space-before="1em" space-after="1em">{tei2fo:process-catalog($config, $node/node())}</fo:block>
            case element(tei:seg) return (
                <fo:inline font-family="{$foc:DefaultFont}" space-start=".5em" space-end=".5em" white-space-treatment="preserve"
                    color="{$foc:ColorBlue}">/{$node/@n/replace(., "_", " ")}/</fo:inline>,
                tei2fo:process-catalog($config, $node/node())
            )
            case element(sx:pb) return
                <fo:block page-break-after="always"><!-- pb pi --></fo:block>
            case element(tei:p) return
                if ($node/ancestor::tei:div[@xml:lang='en']) then
                    tei2fo:p($node)
                else
                    <fo:block>
                    {
                        if ($node/ancestor::tei:div[@xml:lang="zh"]) then (
                            attribute white-space-treatment { "ignore" },
                            attribute linefeed-treatment { "ignore" },
                            attribute text-indent { if ($node/@rend = ('left','noindent')) then "0" else "12pt" }
                        ) else
                            ()
                    }
                    {tei2fo:process-catalog($config, $node/node())}
                    </fo:block>
            case element(tei:byline) return
                let $cn := exists($node/ancestor::tei:div[@xml:lang = "zh"])
                return
                    <fo:inline font-family="{if ($cn) then $foc:ChineseFontQuotes else $foc:DefaultFont}" xml:lang="{if ($cn) then 'zh' else 'en'}">
                    {
                        tei2fo:process($node/node())
                    }
                    </fo:inline>
            case element(tei:list) return
                tei2fo:list($node, tei2fo:process-catalog($config, ?))
            case element(tei:abbr) return
                <fo:inline>({tei2fo:process-catalog($config, $node/node())})</fo:inline>
            case element(tei:ab) return
                <fo:block>
                    { foc:attributes($foc:para) }
                    { tei2fo:process($node/node()) }
                </fo:block>
            case element(tei:foreign) return
                switch ($node/@xml:lang)
                    case "zh" return
                        <fo:inline>{ foc:get-font(true()), tei2fo:process-catalog($config, $node/node()) }</fo:inline>
                    case "sa" return
                        <fo:inline font-family="{if ($node/ancestor::tei:div[@xml:lang='zh']) then $foc:SanskritFontHead else $foc:SanskritFont}" hyphenate="false">{ tei2fo:process-catalog($config, $node/node()) }</fo:inline>
                        (:~ <fo:inline font-family="{$foc:SanskritFont}" hyphenate="false">{ tei2fo:process-catalog($config, $node/node()) }</fo:inline> ~:)
                    case "ja" return
                        <fo:inline font-family="{$foc:JapaneseFont}" hyphenate="false">{ tei2fo:process($node/node()) }</fo:inline>
                    case "ko" return
                        <fo:inline font-family="{$foc:KoreanFont}" hyphenate="false">{ tei2fo:process($node/node()) }</fo:inline>
                    default return
                        <fo:inline white-space-treatment="preserve">{tei2fo:process-catalog($config, $node/node())}</fo:inline>
            case element(tei:hi) return
                switch($node/@rend)
                    case "bold" return
                        <fo:inline font-weight="bold">{tei2fo:process-biblio($node/node())}</fo:inline>
                 
                    case "italic" return
                        <i>{tei2fo:process-catalog($config, tei2fo:normalize-ws($node/node()))}</i>
                    case "color-headings" return
                        <fo:inline color="{$foc:ColorBlue}">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "color-chapters" return
                        <fo:inline color="{$foc:ColorTranscriptTitle}">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "color-scrolls" return
                        <fo:inline color="{$foc:ColorTranscriptScroll}">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "color-g" return
                        <fo:inline color="{$foc:ColorG}">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "color-supplied" return
                        <fo:inline color="{$foc:ColorSupplied}">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "smaller" return
                        <fo:inline font-size="85%">{tei2fo:process(tei2fo:normalize-ws($node/node()))}</fo:inline>
                    case "standard" return
                        tei2fo:process-catalog(tei2fo:normalize-ws($node/node()))
                    default return
                        <fo:inline font-family="{$node/@rend}">{tei2fo:process-catalog($config, tei2fo:normalize-ws($node/node()))}</fo:inline>
            case element(tei:title) return
                switch($node/@type)
                    case "chapter" return
                        <fo:inline color="{$foc:ColorTranscriptTitle}">
                        {tei2fo:process-catalog($config, $node/node())}
                        </fo:inline>
                    case "scroll" return
                        <fo:inline color="{$foc:ColorTranscriptScroll}">
                        {tei2fo:process-catalog($config, $node/node())}
                        </fo:inline>
                    default return
                        <fo:inline color="{$foc:ColorTranscriptTitle}">
                        {tei2fo:process-catalog($config, $node/node())}
                        </fo:inline>
                
            case element(tei:ref) return
                tei2fo:ref($node)
            case element(tei:ptr) return
                tei2fo:ptr($config, $node)
            case element(tei:anchor) return
                <fo:inline id="{$node/@xml:id}">{$node/node()}</fo:inline>
            case element(tei:note) return
                tei2fo:note($node)
            case element(tei:figure) return
                tei2fo:figure($node)
            case element(tei:choice) return
                tei2fo:choice($node, $config)
            case element(tei:app) return
                tei2fo:app($node, false(), $config)
            case element (tei:lg) return
                <fo:block margin-left="10mm" space-before="2mm" space-after="2mm">
                    {
                        for $line in $node/tei:l
                        let $indent := $line/@rend = 'indent$$$'
                        return
                        (:text-indent="{if ($indent) then '2em' else '0'}":)
                            <fo:block  start-indent="{if ($indent) then '5em' else '3em'}"  text-indent="-1em">
                            { tei2fo:process-transcript($line) }
                            </fo:block>
                    }
                </fo:block>
            case element(tei:supplied) return
(:                if ($node/ancestor::tei:title) then:)
(:                    tei2fo:process-transcript($node/node()):)
(:                else:)
                if ($node/@reason = "unfinished") then
                    <fo:inline background-color="{$foc:ColorUnfinished}">{tei2fo:process-transcript($node/node())}</fo:inline>
                else
                    <fo:inline color="{$foc:ColorSupplied}">{tei2fo:process-transcript($node/node())}</fo:inline>
            case element(tei:g) return
                if ($node/(ancestor::tei:title|$node/ancestor::tei:head)) then
                    $node/text()
                else if ($node/@rend = 'specialfont') then
                    <fo:inline font-family="{$foc:SpecialFont}">{$node/text()}</fo:inline>
                else if ($node/@rend[. != "variant"]) then
                    <fo:inline color="{$foc:ColorG}" font-family="{$node/@rend}">{$node/text()}</fo:inline>
                else
                    <fo:inline color="{$foc:ColorG}">{$node/text()}</fo:inline>
            case element(tei:space) return
                let $lang := tei2fo:get-lang($node)
                return
                    <fo:inline font-family="{if ($lang='zh') then 'SimSun' else $foc:DefaultFont}"
                        white-space-collapse="false" white-space-treatment="preserve">
                    {
                        let $count :=
                            if ($node/@n) then
                                $node/@n
                            else if ($node/@extent) then
                                0
                            else 1
                        for $i in 1 to $count return " "
                    }
                    <!-- space--></fo:inline>
            case element(tei:postscript) return
                <fo:block font-size="10pt" line-height="{$foc:FontSizeDefault[2]}" space-before="{$foc:FontSizeDefault[2]}">
                    {
                        if ($node/ancestor::tei:div[@xml:lang="zh"]) then (
                            attribute white-space-treatment { "ignore" },
                            attribute linefeed-treatment { "ignore" }
                        ) else
                            ()
                    }
                    {tei2fo:process-catalog($config, $node/*/node())}
                </fo:block>
            case element() return
                for $child in $node/node()
                return
                    tei2fo:process-catalog($config, $child)
            default return
                $node
};

declare %private function tei2fo:p($para as element()) {
    let $isChinese := exists($para/ancestor::tei:div[@xml:lang='zh'] | $para/ancestor::catalog:note[@lang="zh"])
    return
    <fo:block
        text-align="{if ($para/@rend = 'left') then 'left' else 'justify'}" xml:lang="{if ($para/ancestor::tei:div[@xml:lang='zh']) then 'zh' else 'en'}" hyphenate="true"
        hyphenation-keep="page" hyphenation-push-character-count="2"
        hyphenation-remain-character-count="{$foc:HyphenationMin}"
        axf:punctuation-trim="start end adjacent">
        
        {
            if ($para/ancestor::tei:quote) then
                ()
            else
                attribute font-family { if ($isChinese) then $foc:ChineseFont else $foc:DefaultFont },
            if ($para/ancestor::catalog:note) then (
                attribute font-size { $foc:FontSizeReference[1] },
                attribute line-height { $foc:FontSizeReference[2] }
            ) else if (not($para/ancestor::tei:note)) then (
                attribute font-size { $foc:FontSizeDefault[1] },
                attribute line-height { $foc:FontSizeDefault[2] }
            ) else
                ()
        }
       {
            if ($para/ancestor::tei:div[@xml:lang="zh"]) then (
                attribute white-space-treatment { "ignore" },
                attribute linefeed-treatment { "ignore" }
                
            ) else
                ()
        }
        {
            if ($para/ancestor::tei:div[@xml:lang="zh"] or ($para/ancestor::catalog:note[@lang="zh"] and exists($para/preceding-sibling::*))) then
                attribute text-indent { if ($para/@rend = 'left') then "0" else "2em" }
(:            else if (not($para/preceding-sibling::*[1][self::tei:head]) and not(starts-with(util:collection-name($para), "/db/docs"))) then:)
            else if (exists($para/preceding-sibling::*) and not($para/preceding-sibling::*[1][self::tei:head])) then
                attribute text-indent { if ($para/@rend = ('left','noindent')) then "0" else "12pt" }
            else
                attribute text-indent { if ($para/@rend = ('indent')) then "12pt" else "0"  }
        }
        {
            if ($para/processing-instruction(cb)) then
                tei2fo:column-break($para/processing-instruction(cb))
            else
                
                tei2fo:process($para/node())
        }
    </fo:block>
};

declare %private function tei2fo:div($div as element(tei:div), $processFunc as function(*)) {
    let $level := count($div/ancestor-or-self::tei:div)
    (: let $titleFigure := $div/tei:figure[not(preceding-sibling::tei:p|preceding-sibling::tei:list)][1] :)
    let $titleFigure := $div/tei:figure intersect $div/*[1]
    return
        tei2fo:render-div($div, $titleFigure, $level, $processFunc)
};

declare function tei2fo:render-div($div, $titleFigure, $level, $processFunc) {
(:	if ($div/tei:bibl or $div/@rend="onecolumn") then:)
(:        <fo:block span="all" keep-with-next.within-page="always" space-before="16pt"/>:)
(:    else:)
(:        (),:)
    <fo:block id="{if ($div/@xml:id) then $div/@xml:id else $div/ancestor::tei:text/@xml:id || "_" || generate-id($div)}">
        {
            if ($div/@rend = "space-above") then
                attribute space-before { "320pt" }
            else
                ()
        }
        
        {
            if ($div/tei:bibl or $div/@rend="onecolumn") then
                attribute span { "all" }
            else
                ()
        }
        {
            if ($div/@rend="twocolumn") then
                attribute span { "none" }
            else
                ()
        }
        {
            if ($titleFigure) then
                tei2fo:process($titleFigure)
            else
                ()
        }
        {
            comment { "div level " || $level },
            let $level := if ($div/ancestor::catalog:description) then $level + 2 else $level
            let $func := function-lookup(xs:QName("tei2fo:heading" || $level), 1)
            return
                if ($div/tei:head) then
                    if (exists($func)) then
                        $func($div/tei:head)
                    else
                        <fo:block>Bad heading on level {$level}. Please move up!</fo:block>
                else
                    ()
        }
        {
            for $child in $div/node() except $div/tei:head except $titleFigure
            return
                $processFunc($child)

        }
    </fo:block>,
    if (empty(($div//*)[last()]/ancestor::tei:figure) and ($level < 3 or $div/tei:bibl or $div/@rend="onecolumn")) then
        <fo:block span="all" keep-with-previous.within-page="always"><!-- End div --></fo:block>
    else
        ()
};

declare %private function tei2fo:heading0($head as element(tei:head)) {
    ()
};

declare function tei2fo:heading1($head as element(tei:head)*) {
     if ($head[@type = "author"] or $head[@type = "subtitle"] ) then (
            <fo:block-container keep-with-next.within-page="always" page-break-before="always" absolute-position="absolute">
                <fo:block>
                    <fo:marker marker-class-name="ebene1">
                        <fo:inline font-family="{if ($head/ancestor-or-self::*[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
                            {
                                if ($head[@rend="rh"]) then
                                    tei2fo:process-no-pi($head[@rend="rh"])
                                else
                                    tei2fo:process-no-pi(
                                        $head[not(@type=("author", "nonrepeat"))]/node()
                                    )
                            }
                        </fo:inline>
                    </fo:marker>
                    <!-- heading1-marker-level-2 -->
                    <fo:marker marker-class-name="ebene2">
                    {
                        if ($head/../tei:div) then
                            <fo:inline font-family="{if ($head/ancestor-or-self::*[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
                                { foc:dash($head), $head[@type = "author"]/string() }
                            </fo:inline>
                        else
                            ()
                    }
                    </fo:marker>
                </fo:block>
            </fo:block-container>,
        <fo:block span="all" keep-with-next.within-page="always"/>,
        <fo:block font-family="{if ($head/ancestor::tei:div[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
            { foc:attributes($foc:Ueberschrift-Titel-Author1) }
            { tei2fo:process($head[@type = "subtitle"][not(@rend = "rh")]/node()) }
            <!--fo:inline>##DEBUG Heading1-subtitle </fo:inline-->
        </fo:block>,
        if ($head[@type = "nonrepeat"]) then
            <fo:block font-family="{if ($head/ancestor::tei:div[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
                { foc:attributes($foc:Ueberschrift-Titel-Author12) }
                { tei2fo:process($head[@type = "nonrepeat"]/node()) }
                 <!--fo:inline>##DEBUG Heading1-nonrepeat </fo:inline-->
            </fo:block>
        else
            (),
        <fo:block font-family="{if ($head/ancestor::tei:div[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
            { foc:attributes($foc:Ueberschrift-Titel-Author-Name) }
            { tei2fo:process($head[@type = "author"]/node()) }
             <!--fo:inline>##DEBUG Heading1-author </fo:inline-->
        </fo:block>,
        <fo:block span="all" keep-with-next.within-page="always"><!-- end heading 1 --></fo:block>
     )
     
     
    else if ($head/@rend = "ignore" or $head/@type = "nonrepeat") then
        <fo:block-container keep-with-next.within-page="always" page-break-before="always" absolute-position="absolute">
                <fo:block>
                    <fo:marker marker-class-name="ebene1">
                        <fo:inline font-family="{if ($head/ancestor-or-self::*[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
                            {
                                if ($head[@rend="rh"]) then
                                    tei2fo:process-no-pi($head[@rend="rh"])
                                else
                                    tei2fo:process-no-pi($head[not(@type=("author", "nonrepeat"))]/node())
                            }
                        </fo:inline>
                    </fo:marker>
                    <fo:marker marker-class-name="ebene2">
                    {
                        if ($head/../tei:div) then
                            <fo:inline font-family="{if ($head/ancestor-or-self::*[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
                                { foc:dash($head), $head[@type = "author"]/string() }
                            </fo:inline>
                        else
                            ()
                    }
                    </fo:marker>
                </fo:block>
            </fo:block-container>
    else if ($head[@type = "sectionhead"]) then (
        <fo:block-container keep-with-next.within-page="always" page-break-before="always" absolute-position="absolute">
            <fo:block>
                <!-- sectionhead -->
                <fo:marker marker-class-name="ebene1">
                {
                    if ($head[@rend="rh"]) then
                        tei2fo:process-no-pi($head[@rend="rh"])
                    else if ($head[not(@type=("author", "nonrepeat"))]//@exclude="fromheader") then
                        for $h in $head[not(@type=("author", "nonrepeat", "sectionhead"))][not(@exclude="fromheader")]
                        return
                            <fo:inline font-family="{if (($h/ancestor-or-self::*/@xml:lang)[last()] = 'zh') then $foc:ChineseFont else $foc:EnglishFont}">
                            {
                                tei2fo:process($h[@type="abbreviated"]/node())
                            }
                            </fo:inline>
                    else
                        for $h in $head[not(@type)]
                        return
                            <fo:inline font-family="{if (($h/ancestor-or-self::*/@xml:lang)[last()] = 'zh') then $foc:ChineseFont else $foc:EnglishFont}">
                            { tei2fo:process-no-pi($h/node()) }
                            </fo:inline>
                }
                </fo:marker>
            </fo:block>
        </fo:block-container>,
        <fo:block span="all" keep-with-next.within-page="always"/>,
        <fo:block font-family="{if ($head/ancestor::tei:div[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
            { foc:attributes($foc:Ueberschrift-Transcriptions) }
            { 
                for $sh in $head[@type = "sectionhead"]
                return
                    <fo:inline>
                    {
                        if ($sh/@xml:lang = 'en') then attribute font-family { $foc:EnglishFont } else (),
                        tei2fo:process($sh/node()) 
                    }
                    </fo:inline>
            }
             <!--fo:inline>##DEBUG Heading1-sectionhead </fo:inline-->
        </fo:block>,
        <fo:block font-family="{if ($head/ancestor::tei:div[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
        { foc:attributes($foc:Ueberschrift-Titel1) }
        {
            for $h in $head[not(@type)]
            return
                <fo:inline>
                {
                    if ($h/@xml:lang = 'en') then attribute font-family { $foc:EnglishFont } else (),
                    tei2fo:process($h/node())
                }
                </fo:inline>
        }</fo:block>
        
    ) 
    
    else if ($head[@type="cave"]) then
        (
             <fo:block-container keep-with-next.within-page="always" page-break-before="always" absolute-position="absolute">
            <fo:block>
                <fo:marker marker-class-name="ebene1">
                    <fo:inline font-family="{if ($head/ancestor::tei:div[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
                    {
                        if ($head[@rend="rh"]) then
                            tei2fo:process-no-pi($head[@rend="rh"])
                        else
                            tei2fo:process($head/node())
                    }
                    </fo:inline>
                </fo:marker>
            </fo:block>
        </fo:block-container>,
    <fo:block span="all" keep-with-next.within-page="always"/>,
    <fo:block font-family="{if ($head/ancestor::tei:div[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
        { foc:attributes($foc:Ueberschrift-Titel-CaveNumber) }
        { tei2fo:process($head[@type = "cave" ]/node()) }
         <!--fo:inline>##DEBUG Heading1-cave </fo:inline-->
    </fo:block>,
    <fo:block span="all" keep-with-next.within-page="always"><!-- end heading 1 --></fo:block>
            )
    
    else  
        (
            if ($head[not(@type = ("author","subtitle","nonrepeat", "sectionhead", "cave"))]) then
           (
        <fo:block-container keep-with-next.within-page="always" page-break-before="always" absolute-position="absolute">
            <fo:block>
                <fo:marker marker-class-name="ebene1">
                    <fo:inline font-family="{if ($head/ancestor::tei:div[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
                        {
                            if ($head[@rend="rh"]) then
                                tei2fo:process-no-pi($head[@rend="rh"])
                            else
                            if ($head[not(@type=("author", "nonrepeat"))]//@exclude="fromheader") then
                                tei2fo:process($head[@type=abbreviated][not(@exclude="fromheader")][not(@type=("author", "nonrepeat"))]/node())
                            else 
                                tei2fo:process-no-pi($head/node())
                        }
                    </fo:inline>
                </fo:marker>
            </fo:block>
        </fo:block-container>,
    <fo:block span="all" keep-with-next.within-page="always"/>,
    <fo:block font-family="{if ($head/ancestor::tei:div[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
        { foc:attributes($foc:Ueberschrift-Titel1) }
<!--   { tei2fo:process($head[not(@type = ("author","subtitle","nonrepeat", "sectionhead", "cave") )]/node())} -->
         {
            for $h in $head[not(@type = ("author","subtitle","nonrepeat", "sectionhead", "cave"))]
            return
                <fo:inline>
                {
                    if ($h/@xml:lang = 'en') then attribute font-family { $foc:EnglishFont } else (),
                    tei2fo:process($h/node())
                }
                </fo:inline>
        }
         <!--fo:inline>##DEBUG Heading1-else </fo:inline-->
    </fo:block>,
        <fo:block span="all" keep-with-next.within-page="always"><!-- end heading 1 --></fo:block>
       ) else 
           ()
        )
};

declare function tei2fo:process-no-pi($nodes) {
    for $node in $nodes
    return
        typeswitch($node)
            case processing-instruction() return ()
            default return tei2fo:process($node)
};

declare function tei2fo:heading2($head as element(tei:head)*) {
    let $preceding := $head/parent::tei:div/preceding-sibling::*[1]
    return
        if ($preceding and not(local-name($preceding) = "div")) then
            <fo:block span="all" keep-with-next.within-page="always"><!-- heading 2 start --></fo:block>
        else
            (),
    <!-- heading 2 -->,
    <fo:block font-family="{if ($head/ancestor::tei:div[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
        {
            let $space := 27 + (if ($head/@rend = "addspace") then 16 else 0)
            return
                attribute space-before { $space || "pt" }
        }
        { foc:attributes($foc:Ueberschrift-Titel2) }
        { tei2fo:process($head/node()) }
    </fo:block>,
(:    for $heading3 in $head/../tei:div[1]/tei:head:)
(:    return:)
(:        <fo:block margin-bottom="16pt" margin-top="4pt">:)
(:        { tei2fo:print-heading3($heading3) }:)
(:        </fo:block>,:)
    <fo:block span="all" keep-with-next.within-page="always"><!-- end heading 2 --></fo:block>,
    if ($head/@rend = "ignore") then
        ()
    else
        <fo:block-container absolute-position="absolute">
            <fo:block>
                <fo:marker marker-class-name="ebene2">
                    <fo:inline font-family="{if ($head/ancestor::tei:div[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
                    {
                        if ($head[@rend="rh"]) then
                            tei2fo:process-no-pi($head[@rend="rh"])
                        else (
                            if ($head/@rend='nosep') then () else foc:dash($head), 
                            if ($head//@exclude='fromheader') then
                                tei2fo:process-no-pi($head/node()[1]) else tei2fo:process-no-pi($head/node())
                        )
                    }
                    </fo:inline>
                </fo:marker>
            </fo:block>
        </fo:block-container>
};

declare %private function tei2fo:heading3($head as element(tei:head)*) {
(:    if (exists($head/../preceding-sibling::tei:div)) then :)
(:        tei2fo:print-heading3($head):)
(:    else:)
    tei2fo:print-heading3($head)
};

declare %private function tei2fo:print-heading3($head as element(tei:head)*) {
    <fo:block font-family="{if ($head/ancestor::tei:div[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
        { if ($head/@rend="no-space-above") then foc:attributes($foc:Ueberschrift-Titel3, <m
            space-before="0pt"/>) else foc:attributes($foc:Ueberschrift-Titel3)
            }
        <!-- heading 3 -->
        { tei2fo:process($head/node()) }
    </fo:block>,
    <fo:block-container keep-with-next.within-page="always" absolute-position="absolute">
        <fo:block font-family="{if ($head/ancestor::tei:div[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
            <fo:marker marker-class-name="ebene3">
                {tei2fo:process($head/node())}
            </fo:marker>
        </fo:block>
    </fo:block-container>
};

declare function tei2fo:heading4($head as element(tei:head)*) {
    <fo:block font-family="{if ($head/ancestor::tei:div[@xml:lang = 'zh']) then $foc:ChineseFont else $foc:EnglishFont}">
        { foc:attributes($foc:Ueberschrift-Titel4) }
        { tei2fo:process($head/node()) }
    </fo:block>
};

declare %private function tei2fo:enumerate($count as xs:int, $isChinese as item()*) {
    if (exists($isChinese)) then
        let $enum := collection($foc:app-root)/enumeration[@lang = "zh"]
        return
            $enum/num[@n=$count]/text() || $enum/@sep
    else
        $count || "."
};

declare %private function tei2fo:list($list as element(tei:list), $process as function(*)) {
    let $offset := if ($list/@n) then number($list/@n) - 1 else 0
    let $isChinese := $list/ancestor::tei:div[@xml:lang='zh']
    return
        if  ($list/@type = "blank") then
            (: Inline list without comma at the end:)
            for $item at $num in $list/tei:item
            let $num := $offset + $num
            return
                <fo:inline>
                    { if ($num > 1) then <fo:inline>{$settings:SPACE}</fo:inline> else () }
                    <fo:inline keep-with-next.within-line="always">{tei2fo:enumerate($num, $isChinese)} </fo:inline>
                    {$process($item/node())}
                </fo:inline>
        else if ($list/@type = "bullet") then
        <fo:list-block text-indent="0mm" space-before="{if ($list/@rend = 'multi-column') then $foc:FontSizeDefault[2] else $foc:HalfLineHeight}"
                space-after="{if ($list/@rend = 'multi-column') then $foc:FontSizeDefault[2] else $foc:HalfLineHeight}"
                line-height="16pt" font-family="{if ($isChinese) then $foc:ChineseFont else $foc:DefaultFont}" xml:lang="{if ($isChinese) then 'zh' else 'en'}"
                text-align="justify" font-size="12pt">
                    {
                for $item in $list/tei:item
                return
                        <fo:list-item>
                            <fo:list-item-label start-indent="1em" end-indent="label-end()">
                                
                                    <fo:block font-family="Arial Unicode MS" font-size="16pt">•</fo:block>
                                
                            </fo:list-item-label>
                            <fo:list-item-body start-indent="body-start()">
                                <fo:block font-family="{if ($isChinese) then $foc:ChineseFont else $foc:DefaultFont}"
                                    white-space-treatment="{if ($isChinese) then 'ignore' else 'ignore-if-surrounding-linefeed'}"
                                   xml:lang="{if ($isChinese) then 'zh' else 'en'}"
                                >
                                {
                                    if ($item/ancestor::catalog:note) then (
                                        attribute font-size { $foc:FontSizeReference[1] },
                                        attribute line-height { $foc:FontSizeReference[2] }
                                    ) else (
                                        attribute font-size { $foc:FontSizeDefault[1] },
                                        attribute line-height { $foc:FontSizeDefault[2] }
                                    )
                                }
                                { $process($item/node())}
                                </fo:block>
                            </fo:list-item-body>
                        </fo:list-item>
                    }
            </fo:list-block>
        else if ($list/(ancestor::tei:p|ancestor::tei:note) and not($list/ancestor::tei:bibl)) then
            (: Inline list :)
            for $item at $num in $list/tei:item
            let $num := $offset + $num
            return
                <fo:inline>
                    <!--{ if ($num > 1) then <fo:inline>{if ($list/@rend = "simple" and $isChinese) then "、" else "; "}</fo:inline> else () }-->
                    {
                        if ($list/@rend = "simple") then
                            ()
                        else
                            <fo:inline keep-with-next.within-line="always">{tei2fo:enumerate($num, $isChinese)} </fo:inline>
                    }
                    {$process($item/node())}
                </fo:inline>
        else
            <fo:list-block space-before="{if ($list/@rend = 'multi-column') then $foc:FontSizeDefault[2] else $foc:HalfLineHeight}"
                space-after="{if ($list/@rend = 'multi-column') then $foc:FontSizeDefault[2] else $foc:HalfLineHeight}"
                line-height="16pt" font-family="{if ($isChinese) then $foc:ChineseFont else $foc:DefaultFont}"
                text-align="justify" font-size="12pt">
            {
                for $item at $num in $list/tei:item
                return
                    if ($list/@type = "ordered") then
                        <fo:list-item>
                            <fo:list-item-label start-indent="{if ($isChinese) then "0em" else "1em"}" end-indent="label-end()">
                                <fo:block font-family="{$foc:DefaultFont}">
                                    {tei2fo:enumerate($offset + $num, if ($list/@style="arabic")then () else $isChinese)} </fo:block>
                            </fo:list-item-label>
                            <fo:list-item-body start-indent="body-start()">
                                <fo:block font-family="{if ($isChinese) then $foc:ChineseFont else $foc:DefaultFont}"
(:                                    xml:lang="{if ($isChinese) then 'zh' else 'en'}":)
                                    white-space-treatment="{if ($isChinese) then 'ignore' else 'ignore-if-surrounding-linefeed'}">
                                {
                                    if ($item/ancestor::catalog:note) then (
                                        attribute font-size { $foc:FontSizeReference[1] },
                                        attribute line-height { $foc:FontSizeReference[2] }
                                    ) else (
                                        attribute font-size { $foc:FontSizeDefault[1] },
                                        attribute line-height { $foc:FontSizeDefault[2] }
                                    )
                                }
                                { $process($item/node())}
                                </fo:block>
                            </fo:list-item-body>
                        </fo:list-item>
                    else
                        <fo:list-item>
                            <fo:list-item-label start-indent="1em" end-indent="label-end()">
                                <fo:block>
                                    <fo:block font-family="Arial Unicode MS" font-size="16pt">•</fo:block>
                                </fo:block>
                            </fo:list-item-label>
                            <fo:list-item-body start-indent="body-start()">
                                <fo:block font-family="{if ($isChinese) then $foc:ChineseFont else $foc:DefaultFont}"
                                    white-space-treatment="{if ($isChinese) then 'ignore' else 'ignore-if-surrounding-linefeed'}"
(:                                    xml:lang="{if ($isChinese) then 'zh' else 'en'}":)
                                >
                                {
                                    if ($item/ancestor::catalog:note) then (
                                        attribute font-size { $foc:FontSizeReference[1] },
                                        attribute line-height { $foc:FontSizeReference[2] }
                                    ) else (
                                        attribute font-size { $foc:FontSizeDefault[1] },
                                        attribute line-height { $foc:FontSizeDefault[2] }
                                    )
                                }
                                { tei2fo:process($item/node())}
                                </fo:block>
                            </fo:list-item-body>
                        </fo:list-item>
            }
            </fo:list-block>
};

declare %private function tei2fo:ptr($config as map(*)?, $ptr as element(tei:ptr)) {
    let $target := $ptr/@target/string()
    let $isChinese := tei2fo:get-lang($ptr) = "zh" or fn:contains($target,"_zh")
    let $beforePage := if ($isChinese) then "第" else ()
    let $afterPage := if ($isChinese) then "頁" else ()
    return
        if (exists($config) and $config("skip-footnotes")) then
            ()
        else if ($ptr/@type = "infra") then
            let $targets := tokenize($target, "\s+")
            let $ws := if ($isChinese) then (:"&#160;":) <!--ZH--> else ()
            return
                if (count($targets) = 1) then
                    <fo:inline white-space-treatment="preserve">{$ws}{$beforePage}<fo:page-number-citation ref-id="{$target}"/>{$afterPage}</fo:inline>
                else (
                    <fo:inline white-space-treatment="preserve">{$ws}{$beforePage}</fo:inline>,
                    for $target at $pos in $targets
                    return (
                        if ($pos > 1) then
                            if (tei2fo:get-lang($ptr) = "zh") then
                                <fo:inline font-family="{$foc:ChineseFont}">－</fo:inline>
                            else
                                <fo:inline>–</fo:inline>
                        else
                            (),
                        <fo:inline><fo:page-number-citation ref-id="{$target}"/></fo:inline>
                    ),
                    <fo:inline>{$afterPage}</fo:inline>
                )
        else if ($ptr/@type = "footnote") then
            <notePtr target="{$target}"/>
        else if ($ptr/@type = "infrafootnote") then
            <fo:inline>p. <fo:page-number-citation ref-id="{$target}"/>, note <notePtr target="{$target}"/></fo:inline>
        else if ($ptr/@type = "infrafootnote_zh") then
            <fo:inline font-family="{$foc:ChineseFont}">本卷{$beforePage}<fo:page-number-citation ref-id="{$target}"/>{$afterPage}，注<notePtr target="{$target}"/></fo:inline>
        else if (starts-with($target, "note")) then
            for $note in $ptr/ancestor::tei:text/tei:back//tei:note[@xml:id = $target][@type = "display"]
            let $number := counter:next-value("footnotes-site")
            return
                <fo:footnote id="{$note/@xml:id}"><fo:inline baseline-shift="super" font-size="60%">{ $number }</fo:inline>
                    <fo:footnote-body start-indent="0mm" end-indent="0mm" text-indent="0mm">
                        <fo:list-block
                            provisional-label-separation="2mm">
                            <fo:list-item>
                                <fo:list-item-label end-indent="label-end()">
                                    { foc:attributes($foc:footnote-number) }
                                    <fo:block>
                                    { $number }
                                    </fo:block>
                                </fo:list-item-label>
                                <fo:list-item-body start-indent="body-start()">
                                    <!--fo:block font-family="{if (tei2fo:get-lang($ptr) = 'zh') then $foc:ChineseFont else $foc:DefaultFont}"
                                        xml:lang="{if (tei2fo:get-lang($ptr) = 'zh') then 'zh' else 'en'}"-->
                                    <fo:block font-family="{if ($isChinese) then $foc:ChineseFont else $foc:DefaultFont}">
                                    { foc:attributes($foc:footnote-text) }
                                    { tei2fo:process($note/node()) }
                                    </fo:block>
                                </fo:list-item-body>
                            </fo:list-item>
                        </fo:list-block>
                    </fo:footnote-body>
                </fo:footnote>
        else if ($ptr/@type = "plate") then
                (
            let $lang := tei2fo:get-lang($ptr)
            return

                if ($lang = "zh") then
                    <fo:inline>本卷{$beforePage}<fo:page-number-citation ref-id='{$target}'/>{$afterPage}，圖版<figure ref-id="{$target}"/></fo:inline>
                else
                    <fo:inline white-space-treatment="preserve"><figure ref-id="{$target}"/>, p. <fo:page-number-citation ref-id='{$target}'/></fo:inline>

                )
        else
            let $lang := tei2fo:get-lang($ptr)
            return
                if ($lang = "zh") then
                    <fo:inline>本卷{$beforePage}<fo:page-number-citation ref-id='{$target}'/>{$afterPage}，圖<figure ref-id="{$target}"/></fo:inline>
                else
                    <fo:inline white-space-treatment="preserve"><figure ref-id="{$target}"/>, p. <fo:page-number-citation ref-id='{$target}'/></fo:inline>
};

declare %private function tei2fo:note($note as element(tei:note)) {
    if ($note/@type = ("todo", "ref", "layout")) then
        ()
    else
        let $number := counter:next-value("footnotes-site")
        let $addSpace := $note/following::*[1][self::tei:choice or self::tei:app]
        return
            <fo:footnote axf:footnote-max-height="20%" >
                {
                    if ($note/@xml:id) then
                        attribute id { $note/@xml:id }
                    else
                        ()
                }
                <fo:inline keep-with-previous.within-line="always" baseline-shift="super" font-size="60%" white-space-treatment="preserve">{ $number, if ($addSpace) then " " else () }</fo:inline>
                <!--fo:footnote-body start-indent="0mm" end-indent="0mm" text-indent="0mm" white-space-treatment="{if ($note/ancestor-or-self::*[@xml:lang='zh']) then 'ignore' else 'ignore-if-surrounding-linefeed'}"
                    color="{$foc:ColorBlack}" font-family="{if ($note/ancestor-or-self::*[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}"-->
                <fo:footnote-body start-indent="0mm" end-indent="0mm" text-indent="0mm" white-space-treatment="ignore-if-surrounding-linefeed" color="{$foc:ColorBlack}" axf:footnote-max-height="20%">
                    <fo:list-block>
                        <fo:list-item>
                            <fo:list-item-label end-indent="label-end()" >
                                { foc:attributes($foc:footnote-number) }
                                <fo:block >
                                { $number }
                                </fo:block>
                            </fo:list-item-label>
                            <fo:list-item-body start-indent="body-start()">
                                <!--fo:block font-family="{if ($note/ancestor-or-self::*[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}" white-space-collapse="true"
                                    xml:lang="{if ($note/ancestor-or-self::*[@xml:lang='zh']) then 'zh' else 'en'}"-->
                                <fo:block font-family="{if ($note/ancestor-or-self::*[@xml:lang='zh'] or $note/ancestor::catalog:note[@lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}" xml:lang="en" axf:footnote-max-height="auto">
                                { foc:attributes($foc:footnote-text) }
                                { tei2fo:process($note/node()) }
                                </fo:block>
                            </fo:list-item-body>
                        </fo:list-item>
                    </fo:list-block>
                </fo:footnote-body>
            </fo:footnote>
};

declare
        %private function tei2fo:ref($ref as element(tei:ref)) {
    switch ($ref/@type)
        case "biblio" return
            let $mods := collection("//db/apps/stonesutras-data/data/biblio")/mods:mods[@ID = $ref/@target]
            let $bibliolist := doc($foc:app-root || "/" || $foc:volume || ".xml")//(bibliography|biblio)/@href/string()
            let $entryinlist := doc($bibliolist)//tei:ptr[@target=$ref/@target]/@target/string()
            let $referencetitle := ($mods/mods:titleInfo[@type = "reference"]/mods:title)[1]/string()
            (:This was intended to control that the numbers in sigle and refnode are in the same font, but when using this, the italics are not formatted since hi elements are dissolved tei2foprocess does not work anymore:)
            let $refnode := for $chars in analyze-string($ref, "\d+|[a-z]+|[A-Z]+|\.|\s")/*
                            return
                               if (tei2fo:get-lang($ref) = "zh")
                                then 

                                    typeswitch($chars)
                                        case element(fn:match)return
                                            <fo:inline font-family="{$foc:DefaultFont}">{$chars/node()}</fo:inline>
                                        default return
                                            <fo:inline font-family="{$foc:ChineseFont}">{$chars/node()}</fo:inline>
                                else
                                    <fo:inline font-family="{$foc:DefaultFont}">{$chars/node()}</fo:inline>
                            
            let $pp :=
                if ($ref/node() and tei2fo:get-lang($ref) != "zh") then
                    if (contains($ref, "–")) then
                        "pp. "
                    else
                        "p. "
                else
                    ()
            return
                if ($entryinlist = $ref/@target) then
                    
                    
                    <fo:inline font-family="{$foc:BiblioFont}" hyphenate="false" white-space-treatment="preserve">
                        <fo:inline hyphenate="false" font-variant="small-caps">{$referencetitle}</fo:inline>{if ($ref/node()) then
                                if (tei2fo:get-lang($ref) = 'zh')
                                    then 
                                    <fo:inline font-family="{$foc:ChineseFont}">，{tei2fo:process($ref/node())}</fo:inline>
                                    else
                                        <fo:inline font-family="{if ($ref/ancestor::tei:figure) then $foc:EnglishFont else $foc:DefaultFont}">, {tei2fo:process($ref/node())}</fo:inline>
                                    
                                 
                                else ()}</fo:inline>
                    
                    
                        
                else
                    <fo:inline color="red">!NOT_IN_BIB!:{$ref/@target/string()}</fo:inline>
        default return
            ()
};

declare %private function tei2fo:app($app as element(tei:app), $skipReading as xs:boolean, $config as map(*)?) {
    <fo:inline>
    {
        tei2fo:process-transcript($app/tei:lem)
    }
    {
        if (exists($config) and $config("skip-footnotes")) then
            ()
        else
            tei2fo:app-fn($app, $skipReading)
    }
    </fo:inline>
};

declare %private function tei2fo:app-fn($app as element(tei:app), $skipWitnesses as xs:boolean) {
    let $number := counter:next-value("footnotes-site")
    let $addSpace := $app/following::*[1][self::tei:ptr or self::tei:choice]
    let $smCharNote :=
        if ($app/tei:lem//tei:hi[@rend="smaller"] and count($app/tei:lem/*) = 1) then
            "小字"
        else
            ()
    return
        <fo:footnote>
        {
                    if ($app/@id) then
                        attribute id { $app/@id }
                    else
                        ()
                }
            <fo:inline keep-with-previous.within-line="always" baseline-shift="super" font-size="60%" white-space-treatment="preserve" >{ $number, if ($addSpace) then " " else () }</fo:inline>
            <fo:footnote-body start-indent="0mm" end-indent="0mm" text-indent="0mm" white-space-treatment="preserve" color="{$foc:ColorBlack}">
                <fo:list-block provisional-label-separation="2mm">
                    <fo:list-item>
                        <fo:list-item-label end-indent="label-end()">
                            { foc:attributes($foc:footnote-number) }
                            <fo:block>{ $number }</fo:block>
                        </fo:list-item-label>
                        <fo:list-item-body start-indent="body-start()">
                            <!--fo:block font-family="{if (tei2fo:get-lang($app) = 'zh') then $foc:ChineseFont else $foc:DefaultFont}"
                                xml:lang="{if (tei2fo:get-lang($app) = 'zh') then 'zh' else 'en'}"-->
                            <fo:block font-family="{$foc:ChineseFont}" xml:lang="zh">
                                { foc:attributes($foc:footnote-text) }
                                {
                                    if (exists($app/tei:rdg[@type = 'manuscript'])) then
                                        tei2fo:rdg-manuscript($app, $app/tei:rdg)
                                    else if (exists($app/tei:lem//text()) and exists($app/tei:rdg[@type = ('textcritical')]//text()) and empty($app/tei:rdg[@type = 'interpretative'])) then
                                        (: Case 1.1, Lemma contains text, reading is type= textcritical and contains text :)
                                        (
                                            <fo:inline white-space-treatment="ignore" linefeed-treatment="ignore">{$smCharNote}“{tei2fo:lem($app, $app/tei:lem, true()), ""}”，</fo:inline>,
                                            <fo:inline white-space-treatment="ignore">《大正藏》本作{tei2fo:rdg($app, $app/tei:rdg, $skipWitnesses, true(), "字")}。</fo:inline>
                                        )
                                    else if (exists($app/tei:lem//text()) and empty($app/tei:rdg[@type = 'textcritical']//text()) and empty($app/tei:rdg[@type = 'interpretative'])) then
                                        (: Case 1.2, Lemma contains text, textcritical reading does not contain text :)
                                        (
                                            <fo:inline white-space-treatment="ignore" linefeed-treatment="ignore">石刻本作{$smCharNote}“{tei2fo:lem($app, $app/tei:lem, true())}”字</fo:inline>,
(:                                            if ($skipWitnesses) then:)
(:                                                <fo:inline>。</fo:inline>:)
(:                                            else:)
                                                <fo:inline white-space-treatment="ignore">，《大正藏》本闕此字{tei2fo:rdg($app, $app/tei:rdg, $skipWitnesses, false(), ())}。</fo:inline>
                                        )
                                    else if (empty($app/tei:lem//text()) and exists($app/tei:rdg[@type = 'textcritical']//text()) and empty($app/tei:rdg[@type = 'interpretative'])) then
                                        (: Case 1.3, Lemma contains no text, textcritical reading does :)
                                        <fo:inline white-space-treatment="ignore" linefeed-treatment="ignore">《大正藏》本此處有{tei2fo:rdg($app, $app/tei:rdg, $skipWitnesses, true(), "字")}。</fo:inline>
                                    else if (exists($app/tei:lem//text()) and exists($app/tei:rdg[@type = 'interpretative']//text())) then
                                        (: Case 2.1, Lemma contains text, interpretative reading as well :)
                                        <fo:inline white-space-treatment="ignore">他本作{tei2fo:rdg($app, $app/tei:rdg, $skipWitnesses, true(), "字")}。</fo:inline>
                                    else if (exists($app/tei:lem//text()) and empty($app/tei:rdg[@type = 'interpretative']//text()) and empty($app/tei:rdg[@type = 'textcritical'])) then (
                                        (: Case 2.2 Lemma contains text, interpretative reading does not contain text:)
                                        <fo:inline white-space-treatment="ignore">他本無“{tei2fo:lem($app, $app/tei:lem, false())}”字</fo:inline>,
                                        <fo:inline white-space-treatment="ignore">{tei2fo:rdg($app, $app/tei:rdg, false(), false(), ())}</fo:inline>,
                                        "。"
                                    ) else if (empty($app/tei:lem//text()) and exists($app/tei:rdg[@type = 'interpretative']//text()) and empty($app/tei:rdg[@type = 'textcritical'])) then
                                        (: Case 2.3, Lemma contains no text, textcritical reading does contain text :)
                                        <fo:inline white-space-treatment="ignore">他本多{tei2fo:rdg($app, $app/tei:rdg, false(), true(), "字")}。</fo:inline>
                                    else if (exists($app/tei:lem//text()) and exists($app/tei:rdg[@type = 'textcritical']//text()) and exists($app/tei:rdg[@type = 'interpretative']//text())) then
                                        (: Case 3.2 :)
                                        (
                                            <fo:inline white-space-treatment="ignore" linefeed-treatment="ignore">《大正藏》本作：{tei2fo:rdg($app, $app/tei:rdg[@type='textcritical'], $skipWitnesses, false(), "字"), ""}。</fo:inline>,
                                            <fo:inline white-space-treatment="ignore">他本作{tei2fo:rdg($app, $app/tei:rdg[@type='interpretative'], $skipWitnesses, true(), "字")}。</fo:inline>
                                        )
                                    else
                                        ()
                                }
                            </fo:block>
                        </fo:list-item-body>
                    </fo:list-item>
                </fo:list-block>
            </fo:footnote-body>
        </fo:footnote>
};

declare %private function tei2fo:lem($app as element(tei:app), $lem as element(tei:lem), $skipWitnesses as xs:boolean) {
    <fo:inline>{tei2fo:normalize-lem($lem)}</fo:inline>,
    if ($lem/@wit and not($skipWitnesses)) then (
        <fo:inline white-space-treatment="preserve"> (</fo:inline>,
        tei2fo:get-witnesses($app, $lem/ancestor::tei:TEI, $lem/@wit),
        <fo:inline white-space-treatment="preserve">) </fo:inline>
    ) else
        ()
};

declare %private function tei2fo:normalize-lem($lem) {
    if ($lem/*) then
        let $fixed := tei2fo:fix-punctuation(util:expand($lem))
        return
            tei2fo:process-catalog($fixed/node())
(:	    let $nodes := $lem/node():)
(:	    let $last := $nodes[last()]:)
(:        for $node in $nodes:)
(:        return:)
(:            if ($node is $last and $node instance of text()) then:)
(:                replace($node/string(), "[。、，]\s*$", ""):)
(:            else:)
(:	            tei2fo:process($node):)
    else
        normalize-space(translate($lem/string(), "。！，、、？：“” ‘’", ""))
};

declare %private function tei2fo:fix-punctuation($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch($node)
            case element(tei:lb) return
                ()
            case element() return
                element { node-name($node) } {
                    $node/@*,
                    tei2fo:fix-punctuation($node/node())
                }
            case text() return
                translate($node/string(), "。！，、、？：“” ‘’", "")
            default return
                $node
};

declare function tei2fo:rdg-manuscript($app as element(tei:app), $rdgs as element(tei:rdg)*) {
    for $rdg at $pos in $rdgs
    return (
        (: if ($pos gt 1) then
            <fo:inline white-space-treatment="preserve">; </fo:inline>
        else
            (), :)
        switch($rdg/@type)
            case "manuscript" return
                if ($app/tei:lem//text() and $rdg//text()) then
                    (: Case 1.1, Lemma contains text :)
<fo:inline>寫本作{tei2fo:rdg($app, $rdg, false(), true(), "字")}。</fo:inline>
                else if (empty($rdg//text())) then
<fo:inline>寫本無“{tei2fo:normalize-lem($app/tei:lem)}”字。</fo:inline>
                else
<fo:inline> 寫本多此{tei2fo:rdg($app, $rdg, false(), true(), "字")}。</fo:inline>
            default return
                (: Case 1.1, Lemma contains text :)
<fo:inline>《大正藏》本作{tei2fo:rdg($app, $rdg, false(), true(), "字")}，</fo:inline>
        )
};


declare %private function tei2fo:rdg($app as element(tei:app), $rdgs as element(tei:rdg)*, $skipWitnesses as xs:boolean,
    $quote as xs:boolean, $char as xs:string?) {
    for $rdg at $pos in $rdgs
    return (
        if ($pos gt 1) then
<fo:inline white-space-treatment="preserve">， </fo:inline>
        else
            (),
        <fo:inline>{if ($quote) then '“' else ()}{tei2fo:process($rdg/node())}{if ($quote and $skipWitnesses) then '”' || $char else ()}</fo:inline>,
        if (not($skipWitnesses)) then (
            <fo:inline white-space-treatment="preserve">{if ($quote) then '”' || $char else $char} (</fo:inline>,
            tei2fo:get-witnesses($app, $rdg/ancestor::tei:TEI, $rdg/@wit),
            <fo:inline>)</fo:inline>
        ) else
            ()
    )
};

declare %private function tei2fo:choice($choice as element(tei:choice), $config as map(*)?) {
    <fo:inline>
    {
        let $max := max($choice/tei:unclear/@cert)
        return
            if ($choice/tei:unclear/@cert) then
                tei2fo:process($choice/tei:unclear[@cert = $max])
            else
                tei2fo:process($choice/tei:unclear[1])
    }
    {
        if (exists($config) and $config("skip-footnotes")) then
            ()
        else
            tei2fo:choice-fn($choice)
    }
    </fo:inline>
};

declare %private function tei2fo:choice-fn($choice as element(tei:choice)) {
    let $number := counter:next-value("footnotes-site")
    let $addSpace := $choice/following::*[1][self::tei:ptr or self::tei:app]
    return
        <fo:footnote>
            <fo:inline keep-with-previous.within-line="always" baseline-shift="super" font-size="60%" white-space-treatment="preserve">{ $number, if ($addSpace) then " " else () }</fo:inline>
            <fo:footnote-body start-indent="0mm" end-indent="0mm" text-indent="0mm" white-space-treatment="preserve" color="{$foc:ColorBlack}">
                <fo:list-block
                    provisional-label-separation="2mm">
                    <fo:list-item>
                        <fo:list-item-label end-indent="label-end()">
                            { foc:attributes($foc:footnote-number) }
                            <fo:block>
                            { $number }
                            </fo:block>
                        </fo:list-item-label>
                        <fo:list-item-body start-indent="body-start()">
                            <!--fo:block font-family="{if (tei2fo:get-lang($choice) = 'zh') then $foc:ChineseFont else $foc:DefaultFont}"
                                xml:lang="{if (tei2fo:get-lang($choice) = 'zh') then 'zh' else 'en'}"-->
                            <fo:block font-family="{$foc:DefaultFont}" xml:lang="en">
                                {foc:attributes($foc:footnote-text)}此字漫漶，他本作{
                                    for $unclear at $pos in $choice/tei:unclear[@resp and @cert < 0.5]
                                    return (
                                        if ($pos > 1) then
                                            <fo:inline>; </fo:inline>
                                        else
                                            (),
                                        <fo:inline>“{tei2fo:process($unclear/node())}”字</fo:inline>,
                                        <fo:inline> (</fo:inline>,
                                        tei2fo:get-witnesses($choice, $choice/ancestor::tei:TEI, $unclear/@resp),
                                        <fo:inline>)</fo:inline>
                                    )
                                }。
                            </fo:block>
                        </fo:list-item-body>
                    </fo:list-item>
                </fo:list-block>
            </fo:footnote-body>
        </fo:footnote>
};

declare function tei2fo:get-witnesses($context as element(), $tei as element(tei:TEI), $witstr as xs:string?) {
    for $sigil at $pos in tokenize($witstr, "[,\s]+")
    return
        if (matches($sigil, "^[rR].*")) then
            tei2fo:get-witnesses-figure($context, $tei, $sigil, $pos)
        else
            tei2fo:get-witnesses-biblio($tei, $sigil, $pos)
};

declare %private function tei2fo:get-witnesses-biblio($tei as element(tei:TEI), $sigil as xs:string, $pos as xs:integer) {
    let $witness := $tei//tei:witList/tei:witness[@sigil = $sigil]
    let $target := $witness/tei:witDetail/@target
    let $mods := collection("//db/apps/stonesutras-data/data/biblio")/mods:mods[@ID = $target]
    let $reftitle := collection("//db/apps/stonesutras-data/data/biblio")/mods:mods[@ID = $target]/mods:titleInfo[@type="reference"]/mods:title/text()
    return
        if (fn:contains($reftitle, "T#")) then  
        (:Taisho T#... reference:)
        <fo:inline white-space-treatment="ignore-if-surrounding-linefeed">
            {
                if ($pos > 1) then
                    <fo:inline white-space-treatment="preserve">; </fo:inline>
                else
                    ()
            }
            {
                if (empty($mods)) then
                    <fo:inline white-space-treatment="preserve">{$witness/tei:witDetail/text()}</fo:inline>
                else (
                    <fo:inline hyphenate="false" font-variant="small-caps">{$mods/mods:titleInfo[@type = "reference"]/mods:title/text()}</fo:inline>, if (exists($witness/tei:witDetail/text())) then
<fo:inline white-space-treatment="preserve">: {$witness/tei:witDetail/text()}</fo:inline>else ()
                )
            }
        </fo:inline>
        else 
        (: all other references:)
        <fo:inline white-space-treatment="ignore-if-surrounding-linefeed">
            {
                if ($pos > 1) then
                    <fo:inline white-space-treatment="preserve">; </fo:inline>
                else
                    ()
            }
            {
                if (empty($mods)) then
                    <fo:inline white-space-treatment="preserve">{$witness/tei:witDetail/text()}</fo:inline>
                else (
                    <fo:inline hyphenate="false" font-family="{$foc:DefaultFont}" font-variant="small-caps">{$mods/mods:titleInfo[@type = "reference"]/mods:title/text()}</fo:inline>, if (exists($witness/tei:witDetail/text())) then
<fo:inline white-space-treatment="preserve">, {$witness/tei:witDetail/text()}</fo:inline>else ()
                )
            }
        </fo:inline>
};

declare %private function tei2fo:get-witnesses-figure($context as element(), $tei as element(tei:TEI), $sigil as xs:string, $pos as xs:integer) {
    let $witness := $tei//tei:witList/tei:witness[@sigil = $sigil]
    let $target := $witness/tei:witDetail/@target
    let $lang := tei2fo:get-lang($context)
    return
        <fo:inline>
            {
                if ($pos > 1) then
                    <fo:inline white-space-treatment="preserve">; </fo:inline>
                else
                    ()
            }
            {
                if ($lang = "zh") then
                    <fo:inline>本卷第<fo:page-number-citation ref-id='{$target}'/>頁，圖<figure ref-id="{$target}"/></fo:inline>
                else
                    <fo:inline white-space-treatment="preserve">see p. <fo:page-number-citation ref-id='{$target}'/>, figure <figure ref-id="{$target}"/></fo:inline>
            }
        </fo:inline>
};

declare function tei2fo:get-sigle($targets as xs:string*) {
    for $target in $targets
    let $mods := collection("//db/apps/stonesutras-data/data/biblio")/mods:mods[@ID = $target]
    return
        $mods/mods:titleInfo[@type = "reference"]/mods:title/text()
};
(: for ZH ref in "epigraphic" Sources SD 4 :)


declare function tei2fo:get-reftitleZH($targets as xs:string*) {
    for $target in $targets
    let $mods := collection("//db/apps/stonesutras-data/data/biblio")/mods:mods[@ID = $target]
    return
       tei2fo:process($mods/mods:titleInfo[@lang = ("zh", "ja", "ko")]/mods:title/node())
};



declare function tei2fo:get-lang($node as element()) {
    let $lang := ($node/ancestor-or-self::*/@xml:lang[1], $node/ancestor-or-self::*/@lang[1])[1]
    return
        if ($lang) then
            $lang/string()
        else
            let $note := $node/ancestor::tei:note
            return
                if ($note) then
                    let $origin := root($node)//tei:ptr[@target = $note/@xml:id]
                    return
                        ($origin/ancestor-or-self::*/@xml:lang)[1]
                else
                    ()
};

declare function tei2fo:get-fontfamily($node as element()) {
    let $lang := tei2fo:get-lang($node)
    return
        if ($lang = ("en", "de", "fr")) then
            $foc:DefaultFont
        else
            $foc:ChineseFont
};

(:  declare %private function tei2fo:figure($figure as element(tei:figure)) {
    let $url := $figure/tei:graphic/@url
    where not(ends-with($url, ".swf"))
    return (
        <fo:block span="all" keep-with-next.within-page="always" font-family="Minion Pro"/>,
        <fo:table space-before="12pt" space-after="24pt" keep-together.within-page="always" border-before-style="solid" border-before-width="1.5pt"
            border-before-color="grey" border-after-style="solid" border-after-width="1.5pt" border-after-color="grey" span="all" width="100%">
            <fo:table-body>
                <fo:table-row>
                    <fo:table-cell>
                    {
                        let $figNo := counter:next-value("figures")
                        return
                            <fo:block margin-bottom="12pt" font-family="{$foc:EnglishFont}" id="{$figure/@xml:id}">
                                { foc:attributes($foc:grafik) }
                                <figNo id="{$figure/@xml:id}">{$figNo}</figNo>
                                <fo:block-container>
                                    <fo:block color="grey"><fo:inline font-family="{$foc:ChineseFont}">圖</fo:inline> Figure {$figNo}</fo:block>
                                </fo:block-container>
                            </fo:block>
                    }
                    </fo:table-cell>
                </fo:table-row>
                <fo:table-row>
                    <fo:table-cell>
                        <fo:block space-after="6pt" text-align="center">
                        {
                            if ($figure/@rend = "page") then
                                <fo:external-graphic src="{$foc:Images-Path}/{$url}"
                                    scaling="uniform" max-height="100%" content-width="scale-to-fit" width="{$foc:Bildbreite-max}"/>
                            else
                                <fo:external-graphic src="{$foc:Images-Path}/{$url}" scaling="uniform"
                                    content-height="scale-to-fit" max-height="180mm"
                                    content-width="scale-to-fit" width="100%"/>
                        }
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
                <fo:table-row>
                    <fo:table-cell>
                        <fo:block margin-top="12pt" text-align="right">
                            <fo:block color="{$foc:ColorBlue}" font-family="{$foc:ChineseFont}">
                            { tei2fo:process($figure/tei:head[@xml:lang="zh"]) }
                            </fo:block>
                            <fo:block color="{$foc:ColorBlue}" font-family="{$foc:EnglishFont}">
                            { tei2fo:process(($figure/tei:head[@xml:lang="en"] | $figure/tei:head[not(@xml:lang)])[1]) }
                            </fo:block>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
        </fo:table>,
        <fo:block span="all"/>
    )
};:)


declare %private function tei2fo:figure($figure as element(tei:figure)) {
    let $url := $figure/tei:graphic/@url
    let $figuresposition:= $figure/@rend
    where not(ends-with($url, ".swf"))
    return
        if ($figuresposition="float") then
            <fo:float float="before" span="all">
            {tei2fo:figure-block("center", $figure, $url)}
            </fo:float>
        (: if ($figure/@rend = "top") then
            <fo:block-container position="absolute" top="0" left="0" height="33%" width="100%" overflow="none">
            { tei2fo:figure-block($figuresposition, $figure, $url) }
            </fo:block-container>
        else :)
        (:if ($float) then 
        
        (\:(
         <fo:float float="b">{tei2fo:figure-block($figuresposition, $figure, $url)}</fo:float>
        ):\)
        (
         <fo:float axf:float-x="alternate"
          axf:float-y="auto"
          axf:float-move="auto-next"
          axf:float-wrap="wrap"
          axf:float-reference="page"
          axf:float-margin-y="6pt">{tei2fo:figure-block($figuresposition, $figure, $url)}</fo:float>
        )
        
        else:)
        else (
            <!-- figure start -->,
            tei2fo:figure-block($figuresposition, $figure, $url),
            <!-- figure end -->
        )
};

declare function tei2fo:figure-block($figuresposition, $figure, $url) {
(:    if ($figuresposition = ("center", "page", "full")) then:)
(:	    <fo:block span="all" axf:suppress-if-first-on-page="true"></fo:block>:)
(:	else:)
(:	    (),:)
	let $line-height := if ($figuresposition = ("center", "page", "full")) then 12 else 16
	return
	
    <fo:table space-before="{if ($figure/parent::tei:ab) then 0 else $line-height}pt" space-after="{($line-height * 2)}pt" keep-together.within-page="always" keep-together.within-column="always" border-before-style="solid" border-before-width="1.5pt"
        border-before-color="grey" border-after-style="solid" border-after-width="1.5pt" border-after-color="grey" span="{if ($figuresposition = ('center', 'page', 'full', 'top')) then 'all' else () }" width="100%"
        >
        {
            if ($figuresposition = "page") then
                attribute page-break-before { "always" }
            else
                ()
        }
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell>
                {
                    let $figNo := counter:next-value("figures")
                    return
                        <fo:block margin-bottom="{$line-height}pt" font-family="{$foc:EnglishFont}" id="{$figure/@xml:id}">
                            { foc:attributes($foc:grafik) }
                            <figNo id="{$figure/@xml:id}">{$figNo}</figNo>
                            <fo:block-container>
                                <fo:block color="grey"><fo:inline font-family="{$foc:ChineseFont}">圖</fo:inline> Figure {$figNo}</fo:block>
                            </fo:block-container>
                        </fo:block>
                }
                </fo:table-cell>
            </fo:table-row>
            <fo:table-row>
                <fo:table-cell>
                    <fo:block space-after="{$line-height}pt" text-align="center">
                    {
                        if ($figure/tei:graphic/@rend = "embed") then
                            <fo:instream-foreign-object space-before="{$line-height}pt" space-after="{$line-height}pt">
                            { doc($url)/* }
                            </fo:instream-foreign-object>
                        else if ($figure/@rend = ("page", "full")) then
                            <fo:external-graphic src="{$foc:Images-Path}/{$url}"
                                scaling="uniform" max-height="100%" content-width="scale-to-fit" width="{$foc:Bildbreite-max}"/>
                        else
                            let $width := ($figure/tei:graphic/@width, "100%")[1]
                            let $height := $figure/tei:graphic/@height
                            return
                            <fo:external-graphic src="{$foc:Images-Path}/{$url}" scaling="uniform"
                                content-height="scale-to-fit"
                                content-width="scale-to-fit"
                                max-height="100%">
                            {
                                if ($height or $width) then
                                    (
                                     attribute height { $height },
                                     attribute width { $width }   
                                      )
                                else
                                    (
                                    attribute max-height { "180mm" },
                                    attribute width { "100%" }
                                )
                            }
                            </fo:external-graphic>
                    }
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>

            <fo:table-row>
                <fo:table-cell>
                    <fo:block margin-top="{$line-height}pt" text-align="right">
                        <fo:block color="{$foc:ColorCaptions}" font-family="{$foc:ChineseFont}">
                        { tei2fo:process($figure/tei:head[@xml:lang="zh"]) }
                        </fo:block>
                        <fo:block color="{$foc:ColorCaptions}" font-family="{$foc:EnglishFont}">
                        { tei2fo:process(($figure/tei:head[@xml:lang="en"] | $figure/tei:head[not(@xml:lang)])[1]) }
                        </fo:block>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
{if ($figure/tei:label) then 
<fo:table-row>
                <fo:table-cell>
<fo:block margin-top="{$line-height}pt" text-align="justify">
                        <fo:block  font-family="{$foc:ChineseFont}">
                        { tei2fo:process($figure/tei:label[@xml:lang="zh"]) }
                        </fo:block>
                    </fo:block>
<fo:block margin-top="{$line-height}pt" text-align="justify">
                        <fo:block  font-family="{$foc:DefaultFont}">
                        { tei2fo:process($figure/tei:label[@xml:lang="en"]) }
                        </fo:block>
                    </fo:block>
                    </fo:table-cell>
                    </fo:table-row>
else
()

}
        </fo:table-body>
    </fo:table>
    ,
    if ($figuresposition != "page" and ($figure/following-sibling::* or empty(($figure/following::tei:div)[1]/@xml:lang))) then
        <fo:block span="{if ($figuresposition = ("center", "page", "full")) then "all" else () }" axf:suppress-if-first-on-page="true">
        {
            comment { $figuresposition }
        }
        </fo:block>
    else
        ()
};

declare function tei2fo:normalize-ws($nodes) {
    for $node in $nodes
    return
        typeswitch($node)
            case element() return
                element { node-name($node) } {
                    $node/@*,
                    tei2fo:normalize-ws($node/node())
                }
            case text() return
                if (matches($node, '^\s+$')) then
                    ()
                else
                    $node
            default return
                $node
};