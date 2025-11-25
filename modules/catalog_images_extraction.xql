xquery version "3.1";

declare namespace c = "http://exist-db.org/ns/catalog";
declare namespace catalog = "http://exist-db.org/ns/catalog";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "text";
declare option output:media-type "text/csv";
declare option output:encoding "UTF-8";

let $collection-path := "/db/apps/stonesutras-data/data/catalog" 
(: 假设这是包含 catalog:object/catalog:link 的集合路径。您可能需要根据实际情况调整。 :)
let $options := <query:options xmlns:query="http://exist-db.org/query:options"><ft:stop-words/></query:options>
(: 确保 $options 正确声明，以便 ft:query 能运行 :)

(: 定义排除规则的开头字符串列表 :)
let $excluded-prefixes := ('DF', 'CS', 'Yi', 'JKB', 'JY', 'LJ', 'MD', 'XL', 'GM', 'SF', 'JCh', 'CW', 'LGj', 'GQ', 'BSS', 'QH', 'QL', 'DAI', 'TP', 'YYS', 'FM', 'HR', 'TM', 'NY', 'XH', 'BSY', 'WLS', 'BL', 'JX', 'WS', 'SG', 'Beilin-Diamond')

(: 1. 构建 CSV 头部 :)
let $csv-header := "object_id,xlink_href,link_type,caption_en,caption_zh,published?"

(: 2. 获取所有 catalog:link 元素 :)
let $all-links := collection($collection-path)//catalog:link[ancestor::catalog:object]

(: 3. 遍历所有链接并处理 :)
let $csv-rows :=
    for $link in $all-links
    let $xml-id := $link/ancestor::catalog:object/@xml:id/string()
    let $original-href := normalize-space($link/@xlink:href)
    let $link-type := data($link/@type)

    (: 清理 CSV 特殊字符：用空格替换逗号、引号、回车和换行，并确保引号包裹，防止内容中的逗号干扰 :)
    let $caption-zh := replace(string-join($link/catalog:caption[@xml:lang = 'zh']/string(), ' '), '[,"]', ' ', 'i')
    let $caption-en := replace(string-join($link/catalog:caption[@xml:lang = 'en']/string(), ' '), '[,"]', ' ', 'i')

    (: --- 检查 Published 条件 (与您提供的源代码中的 NOT 逻辑相反) --- :)
    let $is-published :=
        (
            (: 1. 类型检查 :)
            ($link-type = "rubbing" or $link-type = "stone") and
            (: 2. 全文搜索检查 (保留此项，但 ft:query(., "type:*", $options) 在一些环境中可能需要调整) :)
            (try { ft:query($link, "type:*", $options) } catch * { true() }) and
            (: 3. 排除 .swf 和 .svg :)
            not(ends-with(lower-case($original-href), '.swf')) and
            not(ends-with(lower-case($original-href), '.svg')) and
            (: 4. 链接非空 :)
            $original-href != "" and
            (: 5. 标题非空 :)
            (
                normalize-space($caption-en) ne '' or
                normalize-space($caption-zh) ne ''
            ) and
            (: 6. 排除旧的/未发布的 ID (这是源代码中的 NOT 块) :)
            not(
                some $prefix in $excluded-prefixes satisfies starts-with($xml-id, $prefix) or
                ends-with(lower-case($xml-id), '-old') or
                ends-with(lower-case($xml-id), 'old') (: 考虑到 ends-with(lower-case(ancestor::catalog:object/@xml:id/string()), 'old') 的精确匹配 :)
            )
        )

    (: 4. 决定 published 状态 :)
    let $published-status := if ($is-published) then 'published' else 'unpublished/unfound'

    (: 5. 构造 CSV 行 (用逗号分隔，并用双引号包裹所有字段以处理空格和逗号) :)
    let $csv-row :=
        string-join((
            '"' || $xml-id || '"',
            '"' || $original-href || '"',
            '"' || $link-type || '"',
            '"' || $caption-en || '"',
            '"' || $caption-zh || '"',
            '"' || $published-status || '"'
        ), ",")

    return $csv-row
    
(: 6. 将头部和所有行连接起来，以换行符分隔 :)
let $csv-content := string-join(($csv-header, string-join($csv-rows, "&#xA;")), "&#xA;")

return $csv-content