module namespace iiif="https://stonesutras.org/api/iiif";

import module namespace http="http://expath.org/ns/http-client" at "java:org.exist.xquery.modules.httpclient.HTTPClientModule";
import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";

declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace catalog="http://exist-db.org/ns/catalog";

declare variable $iiif:IMAGE_API_BASE := "https://sutras.adw.uni-heidelberg.de/iiif/3";

declare %private function iiif:image-info($path as xs:string) {
    let $request := <http:request method="GET" href="{$iiif:IMAGE_API_BASE}/{$path}/info.json"/>
    let $response := http:send-request($request)
    return
        if ($response[1]/@status = 200) then
            let $data := util:binary-to-string(xs:base64Binary($response[2]))
            return
                parse-json($data)
        else
            ()
};

declare %private function iiif:structures($catalog as element(), $canvases as map(*)*) {
    array {
        for $canvas at $p in $canvases
        return
            map {
                "@id": "https://stonesutras.org/iiif/presentation/" || $catalog/@xml:id || "/range/" || $p,
                "@type": "sc:Range",
                "canvases": [
                    $canvas("@id")
                ]
            }
    }
};

declare %private function iiif:canvases($catalog as element()) {
    for $link at $p in $catalog/catalog:fileDescription/catalog:link[@type=('rubbing', 'stone')]
    let $id := $link/@xlink:href
    let $info := iiif:image-info($id)
    where exists($info)
    return
        map {
            "@id": "https://www.stonesutras.org/canvas/image-" || $p || ".json",
            "@type": "sc:Canvas",
            "label": [
                map {
                    "@value": $link/catalog:caption[@*:lang="en"]/string(),
                    "@language": "en"
                },
                map {
                    "@value": $link/catalog:caption[@*:lang="zh"]/string(),
                    "@language": "zh"
                }
            ],
            "width": $info?width,
            "height": $info?height,
            "images": [
                map {
                    "@type": "oa:Annotation",
                    "motivation": "sc:painting",
                    "resource": map {
                        "@id": $iiif:IMAGE_API_BASE || "/" || $id || "/full/full/0/default.jpg",
                        "@type": "dctypes:Image",
                        "format": "image/jpeg",
                        "width": $info?width,
                        "height": $info?height,
                        "service": map {
                            "@context": "http://iiif.io/api/image/2/context.json",
                            "@id": $iiif:IMAGE_API_BASE || "/" || $id,
                            "profile": "http://iiif.io/api/image/2/level2.json"
                        }
                    },
                    "on": "https://www.stonesutras.org/canvas/image-" || $p || ".json"
                }
            ]
        }
};

declare function iiif:manifest($request as map(*)) {
    let $id := $request?parameters?id
    let $catalog := collection($config:data-catalog)/id($id)
    let $canvases := iiif:canvases($catalog)
    return
        map {
            "@context": "http://iiif.io/api/presentation/2/context.json",
            "@id": "https://www.stonesutras.org/manifest.json",
            "@type": "sc:Manifest",
            (: "label": $id, :)
            "label": [
                map {
                    "@value": $catalog/catalog:header/catalog:title[@*:lang="en"][@type="given"]/string(),
                    "@language": "en"
                },
                map {
                    "@value": $catalog/catalog:header/catalog:title[@*:lang="zh"][@type="given"]/string(),
                    "@language": "zh"
                }
            ],
            "sequences": [
                map {
                    "@type": "sc:Sequence",
                    "canvases": array { $canvases }
                }
            ]
            (: "structures": api:iiif-structures($catalog, $canvases) :)
        }
};