xquery version "3.0";

module namespace modsHTML="http://www.loc.gov/mods/v3";

declare namespace mads="http://www.loc.gov/mads/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace mods="http://www.loc.gov/mods/v3";

import module namespace norelatedItemHTML="http://www.stonesutras.org/publication/fo/modules/norelatedItemHTML" at "biblio-no-relatedItemHTML.xql";
import module namespace tei2fo="http://www.stonesutras.org/publication/tei2fo" at "tei2fo.xql";
import module namespace continuingHTML="http://www.stonesutras.org/publication/fo/modules/continuingHTML" at "format-articleinmonograph-host-continuingHTML.xql";
import module namespace defaulHTML="http://www.stonesutras.org/publication/fo/modules/defaulHTML" at "format-articleinmonograph-host-defaultHTML.xql";
import module namespace monographicHTML="http://www.stonesutras.org/publication/fo/modules/monographicHTML" at "format-articleinmonograph-host-monographicHTML.xql";
import module namespace seriesHTML="http://www.stonesutras.org/publication/fo/modules/seriesHTML" at "format-articleinmonograph-seriesHTML.xql";
import module namespace settings="http://www.stonesutras.org/publication/fo/modules/settings" at "settings.xql";
import module namespace webHTML="http://www.stonesutras.org/publication/fo/modules/webHTML" at "format-websitesHTML.xql";
import module namespace thesisHTML="http://www.stonesutras.org/publication/fo/modules/thesisHTML" at "format-thesisHTML.xql";
import module namespace lectureHTML="http://www.stonesutras.org/publication/fo/modules/lectureHTML" at "format-lectureHTML.xql";
import module namespace rarebookHTML="http://www.stonesutras.org/publication/fo/modules/rarebookHTML" at "format-rarebookHTML.xql";
import module namespace foc="http://www.stonesutras.org/publication/config" at "fo-config.xql";
import module namespace reprintHTML="http://www.stonesutras.org/publication/fo/modules/reprintHTML" at "reprintHTML.xql";
import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";

declare option exist:serialize "indent=no";

declare function modsHTML:format-allHTML($book as element(book)) {
    let $idList := doc($book/bibliography/@href|$book/biblio/@href)//tei:ptr/@target
    let $entries :=
        for $id in $idList
        return
            collection("//db/apps/stonesutras-data/data/biblio")/mods:mods[@ID = $id]
    return
        modsHTML:formatHTML($book, $entries)
};

declare function modsHTML:formatHTML($book as element(), $entries as element(mods:mods)*) {
         <fo:page-sequence master-reference="Bibliographie-Seiten">
            <fo:static-content flow-name="Inhalt-danach-rechts">
                <fo:block/>
            </fo:static-content>
            <fo:static-content flow-name="Inhalt-davor-rechts">
                <fo:block>
                    { foc:attributes($foc:Kopf) }
                    <fo:block color="{$foc:ColorBlue}" text-align-last="justify">
                        <fo:inline><fo:inline font-family="{$foc:ChineseFont}">參考文獻</fo:inline>Bibliography</fo:inline>
                        <fo:leader/>
                        <fo:inline color="{$foc:ColorBlack}">
                            <fo:page-number/>
                        </fo:inline>
                    </fo:block>
                </fo:block>
            </fo:static-content>
            <fo:static-content flow-name="Inhalt-danach-links">
                <fo:block text-align="outside">
                { foc:attributes($foc:Kopf) }
                </fo:block>
            </fo:static-content>
            <fo:static-content flow-name="Inhalt-davor-links">
                <fo:block>
                    { foc:attributes($foc:Kopf) }
                    <fo:block color="{$foc:ColorBlue}" text-align-last="justify">
                        <fo:inline color="{$foc:ColorBlack}">
                            <fo:page-number/>
                        </fo:inline>
                        <fo:leader/>
                        <fo:inline color="{$foc:ColorBlue}" font-family="{$foc:ChineseFont}">{tei2fo:process(root($book)//title[@lang="zh"]/node())}</fo:inline>
                        <fo:inline color="{$foc:ColorBlue}" font-family="{$foc:EnglishFont}">{tei2fo:process(root($book)//title[@lang="en"]/node())}</fo:inline>
                    </fo:block>
                </fo:block>
            </fo:static-content>
            <fo:flow flow-name="xsl-region-body" font-family="{$foc:BiblioFont}">
                <!--fo:block id="bibliography" page-break-before="always">
                    { foc:attributes($foc:Ueberschrift-Biblio) }
                    <fo:inline font-family="{$foc:ChineseFont}">參考文獻</fo:inline>
                    <fo:inline font-family="{$foc:EnglishFont}">Bibliography</fo:inline>
                </fo:block-->
                {
                    for $entry in $entries
                    order by replace(($entry/mods:titleInfo[@type="reference"]/mods:title)[1], " ", "_") collation "?lang=en_US&amp;strength=primary"
                    return
                          <fo:table table-layout="fixed" width="100%">
                          <fo:table-column column-width="30%"/>
                          <fo:table-column column-width="70%"/>
                          <fo:table-body>
                            <fo:table-row>
                              <fo:table-cell border-style="solid"
                                border-color="white" border-width="1pt"
                                padding-before="3pt" padding-after="2pt"
                                padding-start="3pt" padding-end="2pt">
                                <fo:block font-family="{$config:BiblioFont}" font-variant="small-caps" keep-together.within-page="always" space-before="2in" space-after="2in">
                                 {$entry/mods:titleInfo[@type="reference"]/mods:title/text()}
                                             {
                                                if ($foc:DEBUG) then
                                                     <fo:block font-size="4pt">(XMLID: {$entry/@ID/string()}, path: {fn:base-uri($entry)})</fo:block>
                                                else
                                                    ()
                                             }
                                </fo:block>

                              </fo:table-cell>
                              <fo:table-cell border-style="solid"
                                border-color="white" border-width="1pt"
                                padding-before="3pt" padding-after="2pt"
                                padding-start="3pt" padding-end="2pt">
                                <fo:block keep-together.within-page="always" space-before="2in" space-after="2in">
                                 {modsHTML:format-biblioHTML(util:expand($entry))}{if ($entry/mods:idno) then <fo:inline font-family="{$config:BiblioFont}">{$settings:SPACE}{$entry/mods:idno/text()}</fo:inline> else ()}
                                </fo:block>
                              </fo:table-cell>
                            </fo:table-row>

                          </fo:table-body>
                        </fo:table>
                }
            </fo:flow>
        </fo:page-sequence>
};

declare function modsHTML:format-biblioHTML($entry as element(mods:mods)) {

    let $relateI := $entry//mods:relatedItem

    return
        if ($entry/mods:classification = "lecture") then (lectureHTML:format-lectureHTML($entry))
        else if ($entry/mods:classification = "rarebook") then (rarebookHTML:format-rarebookHTML($entry))
        else if ($entry/mods:classification = "reprint")
        then
            (
            if (exists($relateI)) then
            reprintHTML:biblio-with-relatedItemHTML($entry)
            else
            if ($entry/mods:note/@type="thesis")
            then
            thesisHTML:format-thesisHTML($entry)
                else
                norelatedItemHTML:biblio-no-relatedItemHTML($entry)
            )

        else
        (
        if (exists($entry//mods:location/mods:url) and not($entry//mods:location/mods:url/@displayLabel/string()= ("no","additional"))) then
            webHTML:format-websiteHTML($entry)
        else
        if (exists($relateI)) then
            modsHTML:biblio-with-relatedItemHTML($entry)
            else
            (
            if ($entry/mods:note/@type="thesis")
            then
            thesisHTML:format-thesisHTML($entry)
                else
                norelatedItemHTML:biblio-no-relatedItemHTML($entry)
            )
        )
};



declare function modsHTML:biblio-with-relatedItemHTML($entry as element(mods:mods)) {

         if ($entry//mods:relatedItem/@type="series")

         then
            seriesHTML:format-articleinmonograph-seriesHTML($entry)
        else
            modsHTML:format-articleinmonograph-host-allHTML($entry)
};





declare function modsHTML:format-articleinmonograph-host-allHTML($entry as element(mods:mods)) {

        if ($entry/mods:relatedItem[@type="host"]//mods:typeOfResource/@collection = "yes")
        then
            monographicHTML:monograph-in-congshuHTML($entry)
        else if ($entry/mods:relatedItem[@type="host"]//mods:issuance = "monographic")

        then
            monographicHTML:format-articleinmonograph-host-monographicHTML($entry)
        else
             modsHTML:format-articleinmonograph-host-restHTML($entry)
};


declare function modsHTML:format-articleinmonograph-host-restHTML($entry as element(mods:mods)) {

        if ($entry/mods:relatedItem[@type="host"]//mods:issuance = "continuing")

        then
            (
            if (exists($entry//mods:location/mods:url))
                then
                continuingHTML:format-articleinmonograph-host-continuing-webHTML($entry)
            else
            continuingHTML:format-articleinmonograph-host-continuingHTML($entry)
            )
        else
            defaulHTML:format-articleinmonograph-host-defaultHTML($entry)

};
