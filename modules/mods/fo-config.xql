xquery version "3.0";

module namespace config="http://www.stonesutras.org/publication/config";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace fo="http://www.w3.org/1999/XSL/Format";

declare variable $config:app-root :=
    let $rawPath := system:get-module-load-path()
    let $modulePath :=
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    return
        substring-before($modulePath, "/modules")
;

declare variable $config:DEBUG := false();
(:declare variable $config:DEBUG := true(); :)


declare variable $config:Images-Drive :=
    let $param := request:get-parameter("img-dir", ())
    return
        ($param, "file:///D:/Akademie/stonesutras1")[1];
(:    "file://129.206.36.40/stonesutras1";
 :    "file:///D:/Akademie/stonesutras1")[1]
 : 
 : :)

declare variable $config:volume :=
    let $volume := request:get-parameter("volume", "volume1")
    return
        $volume;

declare variable $config:Images-Path :=
    switch(request:get-parameter("volume", "volume1"))
        case "Shaanxi1" return
            $config:Images-Drive || "/Images/Shaanxi_Band_1"
        case "Shaanxi2" return
            $config:Images-Drive || "/Images/Shaanxi_Band_2"
        case "Shaanxi3" return
            $config:Images-Drive || "/Images/Shaanxi_Band_3"
        case "volume2" return
            $config:Images-Drive || "/Images/Shandong_Band_2"
        case "volume3" return
            $config:Images-Drive || "/Images/Shandong_Band_3"
        case "volume4" return
            $config:Images-Drive || "/Images/Shandong_Band_4"
        case "volume5" return
            $config:Images-Drive || "/Images/Shandong_Band_5"
        case "sichuan_volume1" return
            $config:Images-Drive || "/Images/Sichuan_Band_1"
        case "sichuan_volume2" return
            $config:Images-Drive || "/Images/Sichuan_Band_2"
        case "sichuan_volume3" return
            $config:Images-Drive || "/Images/Sichuan_Band_3"
        case "sichuan_volume4" return
            $config:Images-Drive || "/Images/Sichuan_Band_4"
        case "sichuan_volume5" return
            $config:Images-Drive || "/Images/Sichuan_Band_5"
        case "sichuan_volume6" return
            $config:Images-Drive || "/Images/Sichuan_Band_6"
        case "sichuan_volume7" return
            $config:Images-Drive || "/Images/Sichuan_Band_7"
        case "sichuan_volume8" return
            $config:Images-Drive || "/Images/Sichuan_Band_8"
        
        case "Evaluierung2018" return
            $config:Images-Drive || "/Images/Evaluierung2018"
            case "Geburtstagsalbum_LL_2022" return
            $config:Images-Drive || "/Images/Geburtstagsalbum_LL_2022"
        default return
            $config:Images-Drive || "/Images/Shandong_Band_1";

declare variable $config:Catalog-Images-Path := $config:Images-Path;

declare variable $config:Variant-Images-Path := $config:Images-Path || "/character variants";

declare variable $config:Seitenhoehe := "375mm";
declare variable $config:Seitenbreite := "285mm";
declare variable $config:Rand-Inhalt-rechts := "28mm 45mm 45mm 38mm";
declare variable $config:Satzspiegel-Inhalt-rechts := "28mm 0mm 40mm 0mm";
declare variable $config:Rand-Inhalt-links := "28mm 38mm 45mm 45mm";
declare variable $config:Satzspiegel-Inhalt-links := "28mm 0mm 40mm 0mm";

declare variable $config:Bildbreite-max := "202mm";
declare variable $config:Bildhoehe-max := "282mm";

declare variable $config:ChineseFont := "SimSun,SimSun-ExtB,Gandhari Unicode";
(:declare variable $config:ChineseFont := "SimSun,HanaMinA,HanaMinB";:)
declare variable $config:ChineseFontQuotes := "KaiTi,SimSun,SimSun-ExtB";

declare variable $config:EnglishFont := "Gandhari Unicode";
declare variable $config:SanskritFont := "Helvetica_TCC";
(:declare variable $config:SanskritFont := "Calibri";:)
(:declare variable $config:SanskritFont := "Gentium Plus";:)
(:declare variable $config:SanskritFontHead := "URW Palladio SKT";:)
declare variable $config:SanskritFontHead := "Gandhari Unicode";
(:declare variable $config:SanskritFontHead := "Gentium Plus";:)
declare variable $config:JapaneseFont := "Arial Unicode MS";
declare variable $config:BiblioFont := "Arial Unicode MS";
declare variable $config:KoreanFont := "Arial Unicode MS";
(:declare variable $config:SanskritFont := "Arial Unicode";:)
(:declare variable $config:SanskritFont := "DejaVu Sans";:)
(:declare variable $config:DefaultFont := "DejaVu Sans";:)
(:declare variable $config:DefaultFont := "Calibri,SimSun";:)
declare variable $config:DefaultFont := "Helvetica,SimSun,SimSun-ExtB";
(: declare variable $config:DefaultFont := "Gentium Plus";:)
declare variable $config:SpecialFont := "MingLiU-ExtB";

declare variable $config:FontSizeDefault := ("12pt", "16pt");
(:declare variable $config:FontSizeDefault := ("13pt", "16pt");:)
declare variable $config:FontSizeReference := ("10pt", "14pt");
declare variable $config:HalfLineHeight := "8pt";

declare variable $config:ColorBlack := "rgb-icc(#CMYK,0%,0%,0%,100%)";

declare variable $config:ColorWhite := "rgb-icc(#CMYK,0%,0%,0%,0%)";

declare variable $config:TableBackground := "rgb-icc(#CMYK,0%,0%,0%,6%)";

declare variable $config:ColorBoxes := "rgb-icc(#CMYK,0%,0%,0%,12%)";

(: Gold :)
(:declare variable $config:ColorBlue := "rgb-icc(#CMYK,35%,40%,80%,0%)";:)
(: Gold dunkler :)
declare variable $config:ColorBlue := "rgb-icc(#CMYK,35%,40%,80%,0%)";

declare variable $config:ColorCaptions := "rgb-icc(#CMYK,55%,60%,100%,0%)";

(: Dunkelblau :)
(:declare variable $config:ColorTranscriptTitle := "rgb-icc(#CMYK,80%,50%,55%,0%)";:)
(:declare variable $config:ColorTranscriptTitle := "rgb-icc(#CMYK,80%,45%,40%,0%)";:)
(:declare variable $config:ColorTranscriptTitle := "rgb-icc(#CMYK,80%,40%,30%,0%)";:)
(:declare variable $config:ColorTranscriptTitle := "rgb-icc(#CMYK,70%,30%,10%,0%)";:)
declare variable $config:ColorTranscriptTitle := "rgb-icc(#CMYK,90%,0%,30%,0%)";

(:declare variable $config:ColorTranscriptScroll := "rgb-icc(#CMYK,65%,45%,100%,0%)";:)

declare variable $config:ColorTranscriptScroll := "rgb-icc(#CMYK,65%,25%,100%,0%)";

(: Dunkelrot :)
declare variable $config:ColorOrange := "rgb-icc(#CMYK,50%,90%,65%,10%)";

declare variable $config:ColorOrangeDark := $config:ColorOrange;
(:declare variable $config:ColorG := "rgb(161,0,235)";:)
declare variable $config:ColorG := $config:ColorOrange;

declare variable $config:ColorSupplied := "rgb-icc(#CMYK,0%,0%,0%,40%)";

declare variable $config:ColorUnfinished := "rgb-icc(#CMYK,0%,0%,0%,10%)";

declare variable $config:HyphenationMin := 3;

declare variable $config:Kopf := map {
    "font-family" : $config:EnglishFont,
    "font-size" : "14pt",
    "line-height" : "17pt"
};

declare variable $config:grafik := map {
    "span" : "all"
};

declare variable $config:Ueberschrift-Separator := map {
    "color" : $config:ColorBlue,
    "font-size" : "40pt",
    "line-height" : "46pt",
    "text-align" : "left",
    "space-before" : "36pt",
    "space-after" : "100pt",
    "keep-with-next.within-page" : "always",
    "hyphenate" : "false",
    "span" : "all"
};

declare variable $config:Ueberschrift-Separator-Small := map {
    "color" : $config:ColorBlue,
    "font-size" : "30pt",
    "line-height" : "36pt",
    "text-align" :"left",
    "margin-top" : "36pt",
    "space-after" : "100pt",
    "keep-with-next.within-page" : "always",
    "hyphenate" : "false",
    "span" : "all"
};



declare variable $config:Ueberschrift-Transcriptions := map {
    "color" : $config:ColorBlue,
    "font-size" : "20pt",
    "font-weight" : "",
    "text-align" : "left",
    "space-after" : "16pt",
    "keep-with-next.within-page" : "always",
    "hyphenate" : "false",
    "span" : "all"
};

declare variable $config:Ueberschrift-Titel1 := map {
    "color" : $config:ColorBlue,
    "font-size" : "30pt",
    "line-height" : "36pt",
    "text-align" : "left",
    "space-before" : "36pt",
    "space-after" : "100pt",
    "keep-with-next.within-page" : "always",
    "hyphenate" : "false",
    "span" : "all"
};

declare variable $config:Ueberschrift-Titel1-SD5Discussion := map {
    "color" : $config:ColorBlue,
    "font-size" : "30pt",
    "line-height" : "36pt",
    "text-align" : "left",
    "space-before" : "36pt",
    "space-after" : "16pt",
    "keep-with-next.within-page" : "always",
    "hyphenate" : "false",
    "span" : "all"
};

declare variable $config:Ueberschrift-Titel-sidebyside := map {
    "color" : $config:ColorBlue,
    "font-size" : "30pt",
    "line-height" : "36pt",
    "text-align" : "left",
    "space-before" : "36pt",
    "space-after" : "100pt",
    "keep-with-next.within-page" : "always",
    "hyphenate" : "false",
    "span" : "all"
};

declare variable $config:Ueberschrift-Titel-CaveNumber := map {
    "color" : $config:ColorBlue,
    "font-size" : "30pt",
    "font-weight" : "bold",
    "line-height" : "36pt",
    "text-align" : "left",
    "space-before" : "36pt",
    "space-after" : "100pt",
    "keep-with-next.within-page" : "always",
    "hyphenate" : "false",
    "span" : "all"
};



declare variable $config:Ueberschrift-Titel2 := map {
    "color" : $config:ColorBlue,
    "font-size" : "20pt",
    "line-height" : "26pt",
    "font-weight" : "",
    "text-align" : "left",
    "space-after" : "16pt",
    "keep-with-next.within-page" : "always",
    "hyphenate" : "false",
    "span" : "all"
};

declare variable $config:Ueberschrift-Titel2SD4Sources := map {
    "color" : $config:ColorBlue,
    "font-size" : "20pt",
    "line-height" : "26pt",
    "font-weight" : "",
    "text-align" : "left",
    "space-after" : "16pt",
    "space-before" : "36pt",
    "keep-with-next.within-page" : "always",
    "hyphenate" : "false"
};

(: new form for the titel with Author :)

declare variable $config:Ueberschrift-Titel-Author1:= map {
    "color" : $config:ColorBlue,
    "font-size" : "30pt",
    "font-weight" : "",
    "letter-spacing" : "0.45pt",
    "text-align" : "left",
    "space-before" : "36pt",
    "space-after" : "06pt",
    "keep-with-next.within-page" : "always",
    "keep-with-next.within-column" : "always",
    "hyphenate" : "false",
    "span" : "all"
};


declare variable $config:Ueberschrift-Titel-Author12 := map {
    "color" : $config:ColorBlue,
    "font-size" : "24pt",
    "font-weight" : "",
    "text-align" : "left",
    "space-before" : "0pt",
    "space-after" : "12pt",
    "keep-with-next.within-page" : "always",
    "hyphenate" : "false",
    "span" : "all"
};


declare variable $config:Ueberschrift-Titel-Author2 := map {
    "color" : $config:ColorBlue,
    "font-size" : "20pt",
    "font-weight" : "",
    "text-align" : "left",
    "space-before" : "0pt",
    "space-after" : "0pt",
    "keep-with-next.within-page" : "always",
    "hyphenate" : "false",
    "span" : "all"
};

declare variable $config:Ueberschrift-Titel-Author-Name := map {
    "color" : $config:ColorBlue,
    "font-size" : "20pt",
    "font-weight" : "",
    "text-align" : "left",
    "space-before" : "0pt",
    "space-after" : "100pt",
    "keep-with-next.within-page" : "always",
    "hyphenate" : "false",
    "span" : "all"
};





declare variable $config:Ueberschrift-Titel2-Catalog :=
    map:merge(($config:Ueberschrift-Titel2, map:entry("space-after", "48pt")))
;


declare variable $config:Ueberschrift-Titel3 := map {
    "color" : $config:ColorBlue,
    "font-size" : "14pt",
    "font-weight" : "",
    "text-align" : "left",
    "line-height" : "16pt",
    "space-before" : "16pt",
    "space-after" : "16pt",
    "keep-with-next.within-page" : "always",
    "keep-with-next.within-column" : "always",
    "hyphenate" : "false"
};

declare variable $config:Ueberschrift-Titel4 := map {
    "color" : $config:ColorBlue,
    "font-size" : $config:FontSizeDefault[1],
    "text-align" : "left",
    "line-height" : $config:FontSizeDefault[2],
    "space-before" : $config:FontSizeDefault[2],
    "space-after" : $config:FontSizeDefault[2],
    "keep-with-next.within-page" : "always",
    "keep-with-next.within-column" : "always",
    "hyphenate" : "false"
};

declare variable $config:para := map {
    "font-family" : $config:DefaultFont,
    "font-size" : "12pt",
    "line-height" : "16pt",
    "xml:lang" : "en",
    "hyphenate" : "true",
    "hyphenation-keep" : "column",
    "hyphenation-ladder-count" : $config:HyphenationMin,
    "hyphenation-remain-character-count" : $config:HyphenationMin,
    "text-align" : "justify"
};

(: new for the authors name in head :)
declare variable $config:paraAuthor := map {


   "color" : $config:ColorBlue,
    "font-size" : "20pt",
    "font-weight" : "",
    "text-align" : "left",
    "space-before" : "18pt",
    "space-after" : "16pt",
    "keep-with-next.within-page" : "always",
    "hyphenate" : "false",
    "span" : "all"



};

declare variable $config:quote := map {
    "hyphenate" : "true",
    "hyphenation-keep" : "column",
    "hyphenation-ladder-count" : $config:HyphenationMin,
    "hyphenation-remain-character-count" : $config:HyphenationMin,
    "text-align" : "justify",
    "space-before" : "16pt",
    "space-after" : "16pt",
    "margin-left" : "2em"
};

declare variable $config:quotecontinued := map {
    "hyphenate" : "true",
    "hyphenation-keep" : "column",
    "hyphenation-ladder-count" : $config:HyphenationMin,
    "hyphenation-remain-character-count" : $config:HyphenationMin,
    "text-align" : "justify",
    "space-before" : "",
    "space-after" : "16pt",
    "margin-left" : "2em"
};

declare variable $config:lg := map {
    "hyphenate" : "true",
    "hyphenation-keep" : "column",
    "hyphenation-ladder-count" : $config:HyphenationMin,
    "hyphenation-remain-character-count" : $config:HyphenationMin,
    "text-align" : "left",
    "space-before" : "16pt",
    "space-after" : "16pt",
    "margin-left" : "2em"
};

declare variable $config:lgcontinued := map {
    "hyphenate" : "true",
    "hyphenation-keep" : "column",
    "hyphenation-ladder-count" : $config:HyphenationMin,
    "hyphenation-remain-character-count" : $config:HyphenationMin,
    "text-align" : "left",
    "space-before" : "16pt",
    "space-after" : "16pt",
    "margin-left" : "2em"
};

declare variable $config:byline := map {
    "font-size" : "12pt",
    "line-height" : "16pt",
    "xml:lang" : "en",
    "hyphenate" : "true",
    "hyphenation-keep" : "column",
    "hyphenation-ladder-count" : $config:HyphenationMin,
    "hyphenation-remain-character-count" : $config:HyphenationMin,
    "text-align" : "justify",
    "space-before" : "16pt",
    "space-after" : "16pt"
};

declare variable $config:footnote-text := map {
    "font-size" : "10pt",
    "line-height" : "12pt",
    "hyphenate" : "true",
    "hyphenation-keep" : "column",
    "hyphenation-ladder-count" : $config:HyphenationMin,
    "hyphenation-remain-character-count" : $config:HyphenationMin,
    "text-align" : "justify"
};

declare variable $config:footnote-number := map {
    "font-family" : $config:DefaultFont,
    "font-size" : "6pt",
    "line-height" : "12pt",
    "xml:lang" : "en",
    "hyphenate" : "false",
    "white-space-treatment" : "preserve",
    "keep-with-previous.within-line" : "always",
    "baseline-shift" : "super"
};

declare variable $config:table-header-catalog := map {
    "color" : $config:ColorOrange,
    "font-family" : $config:DefaultFont,
    "font-size" : "12pt",
    "font-weight" : "bold",
    "text-align" : "left",
    "hyphenate" : "false"
};

declare variable $config:table-catalog := map {
    "padding" : "1pt 2pt 2pt 2pt",
    "space-after" : "14pt",
    "space-before" : "14pt",
    "line-height" : "16pt"
};

declare variable $config:Ueberschrift-Katalog := map {
    "color" : $config:ColorOrange,
    "font-family" : $config:DefaultFont,
    "font-size" : "20pt",
    "font-weight" : "bold",
    "text-align" : "left",
    "space-after" : "12pt",
    "keep-with-next.within-page" : "always",
    "hyphenate" : "false",
    "span" : "all"
};

declare variable $config:referenz := map {
    "font-size" : "10pt",
    "line-height" : "14pt",
    "space-after" : "2pt",
    "xml:lang" : "en",
    "hyphenate" : "true",
    "text-align" : "justify"
};

declare variable $config:referenzZH := map {
    "font-size" : "10pt",
    "line-height" : "14pt",
    "space-after" : "2pt",
    "xml:lang" : "zh",
    "hyphenate" : "true",
    "text-align" : "justify"
};

declare variable $config:Ueberschrift-IHV := map {
    "color" : $config:ColorBlue,
    "font-family" : $config:EnglishFont,
    "font-size" : "30pt",
    "text-align" : "left",
    "margin-top" : "50pt",
    "space-after" : "100pt",
    "hyphenate" : "false",
    "span" : "all"
};

declare variable $config:Ueberschrift-IHV1 := map {
    "color" : $config:ColorBlue,
    "font-size" : "30pt",
    "text-align" : "left",
    "space-before" : "38pt",
    "space-after" : "9pt",
    "hyphenate" : "false",
    "span" : "all"
};

declare variable $config:Ueberschrift-IHV2 := map {
    "color" : $config:ColorBlue,
    "font-size" : "20pt",
    "font-weight" : "bold",
    "text-align" : "left",
    "space-before" : "24pt",
    "space-after" : "18pt",
    "hyphenate" : "false",
    "span" : "all"
};

declare variable $config:Ueberschrift-IHV3 := map {
    "color" : $config:ColorBlue,
    "font-size" : "12pt",
    "font-weight" : "bold",
    "text-align" : "left",
    "space-before" : "18pt",
    "space-after" : "9pt",
    "hyphenate" : "false"
};

declare variable $config:Ueberschrift-Biblio := map {
    "color" : $config:ColorBlue,
    "font-size" : "30pt",
    "text-align" : "left",
    "space-before" : "36pt",
    "space-after" : "100pt",
    "keep-with-next.within-page" : "always",
    "hyphenate" : "false"
};

declare function config:dash($node as node()*) {
    if ($node/ancestor::*/@xml:lang[1] = "zh") then
        <fo:inline keep-together.within-line="always" font-family="'PERPETUA TITLING MT'" font-size="75%" white-space-treatment="preserve" hyphenate="false">——</fo:inline>
    else
        <fo:inline keep-together.within-line="always" font-family="'Times New Roman'" font-size="85%" white-space-treatment="preserve" hyphenate="false">——</fo:inline>
};

declare function config:get-font($chinese as xs:boolean) {
    attribute font-family {
        if ($chinese) then
            $config:ChineseFont
        else
            $config:DefaultFont
    }
};

declare function config:font($node as element()) {
    if ($node/ancestor::tei:div[@xml:lang='zh']) then $config:ChineseFont else $config:DefaultFont
};

declare function config:attributes($map as map(*)) {
    for $key in map:keys($map)
    return
        attribute { $key }{ $map($key) }
};

declare function config:attributes($map as map(*), $options as element()) {
    let $overwrite := map:merge(for $attr in $options/@* return map:entry(local-name($attr), $attr))
    let $tmpMap := for-each(map:keys($map), function($key) {
            if ($overwrite($key)) then
                ()
            else
                map:entry($key, $map($key))
        })
    let $merged := map:merge(($tmpMap, $overwrite))
    return
        config:attributes($merged)
};
