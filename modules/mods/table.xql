xquery version "3.0";

module namespace table="http://www.stonesutras.org/publication/fo/modules/table";
import module namespace settings="http://www.stonesutras.org/publication/fo/modules/settings" at "settings.xql";
import module namespace foc="http://www.stonesutras.org/publication/config" at "fo-config.xql";
import module namespace counter="http://exist-db.org/xquery/counter" 
    at "java:org.exist.xquery.modules.counter.CounterModule";
import module namespace tei2fo="http://www.stonesutras.org/publication/tei2fo" at "tei2fo.xql";

declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace axf="http://www.antennahouse.com/names/XSL/Extensions";
declare namespace catalog="http://exist-db.org/ns/catalog";

declare function table:tableswitch($nodes as node()*){
    for $node in $nodes
    return
        switch ($node/@rend)
            case "cavelist" return table:cavelist($node)
            case "box" return table:box($node)
            case "boxproportional" return table:boxproportional($node)
            case "boxspanall" return table:boxspanall($node)
            case "innerbox" return table:innerbox($node)
            case "innerboxSecond" return table:innerboxSecond($node)
            case "innerboxSecondFixed" return table:innerboxSecondFixed($node)
            case "onecolumn" return table:contenttable-onecolumn($node)
            case "onecolumnfixed" return table:contenttable-onecolumnfixed($node)
            case "content" return table:contenttable($node)
            case "contenttablealignright" return table:contenttablealignright($node)
            case "textmarker" return table:textmarker($node)
            case "textmarker2" return table:textmarker2($node)
            
            default return
                table:box($node)
};



declare function table:box($nodes as node()*) {
let $table := $nodes/self::tei:table
return
    <fo:block space-before="16pt" space-after="16pt">
    
    <fo:table background-color="{$foc:ColorBoxes}" width="100%"
        font-size="10pt" font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}" keep-together.within-page="always" keep-together.within-column="{if ($table/@cols='allowbreak') then () else 'always'}"  xml:lang="{if ($table/ancestor::tei:div[@xml:lang='zh']) then 'zh' else 'en'}">
    <fo:table-body font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}"  xml:lang="{if ($table/ancestor::tei:div[@xml:lang='zh']) then 'zh' else 'en'}">
        
        {if (exists($table/tei:head/text())) then
            <fo:table-row>
            <fo:table-cell padding="5mm 5mm 0mm 5mm">
                { foc:attributes($foc:table-header-catalog) }
                <fo:block font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}">{tei2fo:process($table/tei:head)}</fo:block>
            </fo:table-cell>
            </fo:table-row>
            else ()
        }
        
        <fo:table-row>
            <fo:table-cell padding="5mm 5mm 5mm 5mm">
                <fo:table>
                    
                    <fo:table-body>
        {
            for $row  in $table/tei:row
            return
                <fo:table-row>
                    {
                        for $cell in $row/tei:cell
                        return

                            <fo:table-cell>
                           <fo:block>{if (exists($cell/tei:table)) then table:tableswitch($cell/tei:table) else <fo:inline>{ tei2fo:process($cell)}</fo:inline>  } </fo:block>
                            </fo:table-cell>
                            
                    }
                </fo:table-row>
                
        }
                    </fo:table-body>
                </fo:table>      
            </fo:table-cell>
        </fo:table-row>
    </fo:table-body>
    </fo:table>
    
    </fo:block>
      
};

declare function table:boxproportional($nodes as node()*) {
let $table := $nodes/self::tei:table
return
    <fo:block space-before="16pt" space-after="16pt">
    
    <fo:table background-color="{$foc:ColorBoxes}" width="100%"
        font-size="10pt" font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}" keep-together.within-page="always" keep-together.within-column="{if ($table/@cols='allowbreak') then () else 'always'}"  xml:lang="{if ($table/ancestor::tei:div[@xml:lang='zh']) then 'zh' else 'en'}">
    <fo:table-body font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}"  xml:lang="{if ($table/ancestor::tei:div[@xml:lang='zh']) then 'zh' else 'en'}">
        
        {if (exists($table/tei:head/text())) then
            <fo:table-row>
            <fo:table-cell padding="5mm 5mm 0mm 5mm">
                { foc:attributes($foc:table-header-catalog) }
                <fo:block font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}">{tei2fo:process($table/tei:head)}</fo:block>
            </fo:table-cell>
            </fo:table-row>
            else ()
        }
        
        <fo:table-row>
            <fo:table-cell padding="5mm 5mm 5mm 5mm">
                <fo:table>
                    <fo:table-column column-width="proportional-column-width(1)"/>
                    <fo:table-body>
        {
            for $row  in $table/tei:row
            return
                <fo:table-row>
                    {
                        for $cell in $row/tei:cell
                        return

                            <fo:table-cell>
                           <fo:block>{if (exists($cell/tei:table)) then table:tableswitch($cell/tei:table) else <fo:inline>{ tei2fo:process($cell)}</fo:inline>  } </fo:block>
                            </fo:table-cell>
                            
                    }
                </fo:table-row>
                
        }
                    </fo:table-body>
                </fo:table>      
            </fo:table-cell>
        </fo:table-row>
    </fo:table-body>
    </fo:table>
    
    </fo:block>
      
};

declare function table:boxspanall($nodes as node()*) {
let $table := $nodes/self::tei:table
return
    <fo:block span="all"  space-before="16pt" space-after="16pt" margin-top="16pt" margin-bottom="16pt">
    
    <fo:table background-color="{$foc:ColorBoxes}" width="100%"
        font-size="10pt" font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}" keep-together.within-column="always">
    <fo:table-body font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}"  xml:lang="{if ($table/ancestor::tei:div[@xml:lang='zh']) then 'zh' else 'en'}">
        
        {if (exists($table/tei:head//text())) then
            <fo:table-row>
            <fo:table-cell padding="5mm 5mm 0mm 5mm">
                { foc:attributes($foc:table-header-catalog) }
                <fo:block  font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}">{tei2fo:process($table/tei:head)}</fo:block>
            </fo:table-cell>
            </fo:table-row>
            else ()
        }
        
        <fo:table-row>
            <fo:table-cell padding="5mm 5mm 5mm 5mm">
                <fo:table>
                    
                    <fo:table-body>
        {
            for $row  in $table/tei:row
            return
                <fo:table-row>
                    {
                        for $cell in $row/tei:cell
                        return

                            <fo:table-cell padding="2.5mm 5mm 2.5mm 5mm">
                           <fo:block>{if (exists($cell/tei:table)) then table:tableswitch($cell/tei:table) else <fo:inline>{ tei2fo:process($cell)}</fo:inline>  } </fo:block>
                            </fo:table-cell>
                            
                    }
                </fo:table-row>
                
        }
                    </fo:table-body>
                </fo:table>      
            </fo:table-cell>
        </fo:table-row>
    </fo:table-body>
    </fo:table>
    
    </fo:block>
      
};

(: 
 declare function table:innerbox($nodes as node()*) {
let $table := $nodes
return

<fo:table keep-together.within-page="always">
    <fo:table-body>
        <fo:table-row>
            <fo:table-cell padding="2mm 0mm 2mm 2mm">
                
                <fo:block font-weight="bold" font-color="#FFA500">{$table/tei:head/text()}</fo:block>
            </fo:table-cell>
        </fo:table-row>
        <fo:table-row>
            <fo:table-cell>
                <fo:table>
                    
                    <fo:table-body>
        {
            for $row  in $table/tei:row
            return
                <fo:table-row>
                    {
                        for $cell in $row/tei:cell
                        return

                            <fo:table-cell padding="1mm 0mm 1mm 5mm">
                            <fo:block>{if (exists($cell/tei:table)) then table:tableswitch($cell/tei:table) else <fo:inline>{ tei2fo:process($cell)}</fo:inline>  } </fo:block>
                            </fo:table-cell>
                            
                    }
                </fo:table-row>
                
        }
                    </fo:table-body>
                </fo:table>      
            </fo:table-cell>
        </fo:table-row>
    </fo:table-body>
</fo:table>};
:) 


declare function table:innerbox($nodes as node()*) {
let $table := $nodes
return

<fo:table font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}">
    <fo:table-body>
        <fo:table-row>
            <fo:table-cell padding="2mm 0mm 2mm 2mm">
                
                <fo:block font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}" white-space-treatment="preserve" font-weight="bold">{tei2fo:process($table/tei:head/node())}</fo:block>
            </fo:table-cell>
        </fo:table-row>
        <fo:table-row>
            <fo:table-cell>
                <fo:table>
                    
                    <fo:table-body>
        {
            for $row at $pos in $table//tei:row
            return
                <fo:table-row >
                
                    {
                        for $cell in $row/tei:cell
                        return

                            <fo:table-cell padding="1mm 0mm 1mm 5mm">
                            <fo:block>{if (exists($cell/tei:table)) then table:tableswitch($cell/tei:table) else <fo:inline>{ tei2fo:process($cell)}</fo:inline>  } </fo:block>
                            </fo:table-cell>
                            
                    }
                </fo:table-row>
                
        }
                    </fo:table-body>
                </fo:table>      
            </fo:table-cell>
        </fo:table-row>
    </fo:table-body>
</fo:table>};


declare function table:innerboxSecond($nodes as node()*) {
let $table := $nodes
return

<fo:table font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}">
    <fo:table-body>
        {if (exists($table/tei:head/text())) then
        <fo:table-row >
            <fo:table-cell padding="2mm 0mm 2mm 2mm" >
            { foc:attributes($foc:table-header-catalog) }
                
                <fo:block font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}">{tei2fo:process($table/tei:head)}</fo:block>
            </fo:table-cell>
        </fo:table-row>
        else ()}
        <fo:table-row>
            <fo:table-cell>
                <fo:table>
                    
                    <fo:table-body>
        {
            for $row  in $table/tei:row
            return
                <fo:table-row keep-together.within-column="always">
                    
                     {
                        for $cell at $pos in $row/tei:cell
                        return

                           <fo:table-cell column-number="{$pos}"  width="{if ($pos=1) then "30mm" else () }"  padding="1mm 0mm 1mm 5mm">
                            <fo:block text-align="{if ($pos=1) then "left" else "justify" }">{tei2fo:process($cell)} </fo:block>
                            </fo:table-cell>
                            
                    }
                </fo:table-row>
                
        }
                    </fo:table-body>
                </fo:table>      
            </fo:table-cell>
        </fo:table-row>
    </fo:table-body>
</fo:table>};

declare function table:innerboxSecondFixed($nodes as node()*) {
let $table := $nodes
return

<fo:table >
    <fo:table-body font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}">
        {if (exists($table/tei:head/text())) then
        <fo:table-row >
            <fo:table-cell padding="2mm 0mm 2mm 2mm" >
            { foc:attributes($foc:table-header-catalog) }
                
                <fo:block font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}">{tei2fo:process($table/tei:head)}</fo:block>
            </fo:table-cell>
        </fo:table-row>
        else ()}
        <fo:table-row>
            <fo:table-cell>
                <fo:table>
                    
                    <fo:table-body>
        {
            for $row  in $table/tei:row
            return
                <fo:table-row>
                 
                     {
                        for $cell at $pos in $row/tei:cell
                        return
                       
                           <fo:table-cell column-number="{$pos}"  width="{if ($pos=1) then "20%" else "35%" }"  padding="1mm 0mm 1mm 5mm">
                            <fo:block text-align="{if ($pos=1) then "left" else "justify" }">{tei2fo:process($cell)} </fo:block>
                            </fo:table-cell>
                            
                    }
                </fo:table-row>
                
        }
                    </fo:table-body>
                </fo:table>      
            </fo:table-cell>
        </fo:table-row>
    </fo:table-body>
</fo:table>};

declare function table:contenttable($nodes as node()*) {
    let $table := $nodes
    return
    <fo:table keep-together.within-page="always">
        <fo:table-column column-width="auto"/>
        <fo:table-body font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}">
            {
                for $row  in $table/tei:row
                return
                    <fo:table-row>
                        {
                            for $cell in $row/tei:cell
                            return
                                <fo:table-cell padding="2mm 0mm 2mm 2mm" text-align="{if ($row/@role = 'label') then 'center' else 'left'}">
                                    <fo:block>
                                    {
                                       if (exists($cell/tei:table)) then table:tableswitch($cell/tei:table) else <fo:inline>{ tei2fo:process($cell)}</fo:inline>
                                    }
                                    </fo:block>
                                </fo:table-cell>
                                
                        }
                    </fo:table-row>
                    
            }
        </fo:table-body>
    </fo:table>
};

declare function table:contenttable-onecolumn($nodes as node()*) {
    let $table := $nodes
    return
    <fo:table span="all">
        <fo:table-column column-width="auto"/>
        <fo:table-body font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}">
            {
                for $row  in $table/tei:row
                return
                    <fo:table-row>
                        {
                            for $cell in $row/tei:cell
                            return
                                <fo:table-cell padding="2mm 0mm 2mm 2mm" text-align="{if ($row/@role = 'label') then 'center' else 'left'}">
                                    <fo:block>
                                    {
                                       if (exists($cell/tei:table)) then table:tableswitch($cell/tei:table) else <fo:inline>{ tei2fo:process($cell)}</fo:inline>
                                    }
                                    </fo:block>
                                </fo:table-cell>
                                
                        }
                    </fo:table-row>
                    
            }
        </fo:table-body>
    </fo:table>
};

declare function table:contenttable-onecolumnfixed($nodes as node()*) {
    let $table := $nodes
    return
    <fo:table span="all">
        <fo:table-column column-width="fixed"/>
        <fo:table-body font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}">
            {
                for $row  in $table/tei:row
                return
                    <fo:table-row>
                        {
                            for $cell in $row/tei:cell
                            return
                                <fo:table-cell padding="2mm 0mm 2mm 2mm" text-align="{if ($row/@role = 'label') then 'center' else 'left'}">
                                    <fo:block>
                                    {
                                       if (exists($cell/tei:table)) then table:tableswitch($cell/tei:table) else <fo:inline>{ tei2fo:process($cell)}</fo:inline>
                                    }
                                    </fo:block>
                                </fo:table-cell>
                                
                        }
                    </fo:table-row>
                    
            }
        </fo:table-body>
    </fo:table>
};

declare function table:contenttablealignright($nodes as node()*) {
let $table := $nodes
return
<fo:table keep-together.within-page="always">
    <fo:table-column column-width="auto"/>
    <fo:table-body font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}">
        {
            for $row  in $table/tei:row
            return
                <fo:table-row>
                    {
                        for $cell in $row/tei:cell
                        return
 
                            <fo:table-cell  padding="0mm 0mm 0mm 0mm">
                           <fo:block margin-top="0pt" text-align="right" padding="0mm 0mm 0mm 0mm" >{if (exists($cell/tei:table)) then table:tableswitch($cell/tei:table) else <fo:inline>{ tei2fo:process($cell)}</fo:inline>  }</fo:block>
                            </fo:table-cell>
                            
                    }
                </fo:table-row>
                
        }
    </fo:table-body>
</fo:table>};

(:  declare function table:cavelist($nodes as node()*) {

let $table := $nodes/self::tei:table
return 
    (
    
  
<fo:block space-before="12pt" space-after="20pt" />,


<fo:table  span="all" border-before-style="solid" border-before-width="3.5pt" 
            border-before-color="#FFFFFF" border-after-style="solid" border-after-width="12.5pt" border-after-color="#FFFFFF"  



padding-bottom="5mm"   background-color="{$foc:ColorBoxes}" width="100%"

        font-size="10pt" font-family="{$foc:DefaultFont}" keep-together.within-page="always">
    <fo:table-body>
        <fo:table-row>
            <fo:table-cell padding="5mm 5mm 0mm 5mm">
                { foc:attributes($foc:table-header-catalog) }
                <fo:block font-weight="bold">{$table/tei:head/text()}</fo:block>
            </fo:table-cell>
        </fo:table-row>
        <fo:table-row>
            <fo:table-cell padding="5mm 5mm 0mm 5mm">
                <fo:table>
                    
                    <fo:table-body>
        {
            for $row at $pos in $table//tei:row
            return
                <fo:table-row font-weight="{if ($pos=1) then "bold" else () }">
                    {
                        for $cell at $pos in $row/tei:cell
                        return
                            <fo:table-cell column-number="{$pos}" font-weight="{if ($pos=1) then "bold" else () }" padding="2mm 2mm 2mm 2mm">
                            <fo:block>{$cell/text()} </fo:block>
                            </fo:table-cell>
                    }
                </fo:table-row>
                
        }
                    </fo:table-body>
                </fo:table>      
            </fo:table-cell>
        </fo:table-row>
    </fo:table-body>
</fo:table>
,
 <fo:block />
 
    )

}; 

:)

declare function table:cavelist($nodes as node()*) {
    let $table := $nodes/self::tei:table
    return (
        <fo:block span="all" keep-with-previous.within-page="always"></fo:block>,
        <fo:block span="all" space-before="16pt" space-after="16pt" padding-top="8pt" padding-bottom="8pt" background-color="{$foc:ColorBoxes}"
            font-size="10pt" font-family="{$foc:DefaultFont}" keep-together.within-page="always">
            <fo:block start-indent="2mm" space-after="8pt">
            {
                foc:attributes($foc:table-header-catalog),
                tei2fo:process($table/tei:head)
            }</fo:block>
            <fo:table>
                <fo:table-body>
                {
                    for $row at $pos in $table//tei:row
                    return
                        <fo:table-row font-weight="{if ($pos=1) then "bold" else () }">
                        {
                            for $cell at $pos in $row/tei:cell
                            return
                                <fo:table-cell column-number="{$pos}" font-weight="{if ($pos=1) then "bold" else () }" padding="2mm 2mm 2mm 2mm">
                                    <fo:block>{$cell/text()} </fo:block>
                                </fo:table-cell>
                        }
                        </fo:table-row>
                        
                }
                </fo:table-body>
            </fo:table>
        </fo:block>,
        <fo:block span="all" keep-with-previous.within-page="always"></fo:block>
    )
};

declare function table:textmarker($nodes as node()*) {
let $table := $nodes/self::tei:table
return

<fo:block text-indent="0mm" provisional-distance-between-starts="6mm" space-before="16pt" space-after="16pt"
        line-height="16pt" font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}" 
        xml:lang="{if ($table/ancestor::tei:div[@xml:lang='zh']) then 'zh' else 'en'}"
        >
<fo:table background-color="{$foc:ColorWhite}" width="100%"
        font-size="10pt"  font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}" 
        >
    <fo:table-body>
        
        <fo:table-row>
            <fo:table-cell padding="0mm 0mm 0mm 0mm">
                <fo:table>
                    
                    <fo:table-body>
        {
            for $row  in $table/tei:row
            return
                <fo:table-row>
                    {
                        for $cell at $pos in $row/tei:cell
                        return

                           <fo:table-cell column-number="{$pos}"  width="{if ($pos=1) then "20mm" else () }"  font-weight="{if ($pos=1) then "bold" else () }" padding="2mm 2mm 2mm 2mm">
                            <fo:block text-align="{if ($pos=1) then "left" else "justify" }">{tei2fo:process($cell)} </fo:block>
                            </fo:table-cell>
                            
                    }
                </fo:table-row>
                
        }
                    </fo:table-body>
                </fo:table>      
            </fo:table-cell>
        </fo:table-row>
    </fo:table-body>
</fo:table>
</fo:block>

};

declare function table:textmarker2($nodes as node()*){
    let $table := $nodes/self::tei:table
    return
    <fo:block text-indent="0mm" provisional-distance-between-starts="6mm" space-before="16pt" space-after="16pt"
        font-family="{if ($table/ancestor::tei:div[@xml:lang='zh']) then $foc:ChineseFont else $foc:DefaultFont}"
        xml:lang="{if ($table/ancestor::tei:div[@xml:lang='zh']) then 'zh' else 'en'}"
        background-color="{$foc:ColorBoxes}" width="100%"
        padding-top="16pt" padding-bottom="16pt"
        font-size="10pt" line-height="16pt">
        <fo:table>
            
            <fo:table-body>
            {
                for $row at $pos in $table/tei:row
                return
                    <fo:table-row font-weight="{if ($pos=1) then "bold" else () }">
                    {
                        for $cell at $pos in $row/tei:cell
                        return
            
                            <fo:table-cell column-number="{$pos}"  width="{if ($pos=1) then "14mm" else () }"  font-weight="{if ($pos=1) then "bold" else () }" 
                                padding="0pt 8pt 0pt 8pt">
                                <fo:block text-align="{if ($pos=1) then "left" else "justify" }">{tei2fo:process($cell)} </fo:block>
                            </fo:table-cell>
                                
                    }
                    </fo:table-row>
                    
            }
            </fo:table-body>
        </fo:table>
    </fo:block>
};



