window.addEventListener('DOMContentLoaded', () => {
    const sites = document.getElementById('sites');

    pbEvents.subscribe('pb-end-update', 'sites', () => {
        const documents = document.getElementById('documents');
        const locations = sites.querySelectorAll('pb-geolocation');
        pbEvents.emit('pb-update-map', 'map', Array.from(locations));
        // locations.forEach((geo) => {
        //     geo.addEventListener('click', (ev) => {
        //         ev.preventDefault();
        //         const url = new URL(location.href);
        //         url.searchParams.set('site', geo.id);
        //         history.pushState(null, null, url.toString());
        //         documents.load({
        //             site: geo.id
        //         });
        //     });
        // });
    });

    pbEvents.subscribe('pb-leaflet-marker-click', null, (ev) => {
        console.log(ev.detail);
    });

    const panel = document.querySelector('pb-panel');
    let svgPath;
    pbEvents.subscribe('pb-update', 'catalog', (ev) => {
        const config = JSON.parse(document.getElementById('appConfig').textContent);
        if (ev.detail.root.querySelector('pb-geolocation')) {
            document.querySelector('pb-leaflet-map').style.display = 'block';
        } else {
            document.querySelector('pb-leaflet-map').style.display = 'none';
        }
        const svgImg = ev.detail.root.querySelector('.layout');
        svgPath = svgImg.getAttribute('src');
        const svg = panel.querySelector('pb-svg');
        if (svg) {
            svg.setAttribute('url', new URL(svgPath, new URL(`${config.app}/`, location.href)).toString());
        }
    });
    pbEvents.subscribe('pb-panel', 'panels', () => {
        const config = JSON.parse(document.getElementById('appConfig').textContent);
        const svg = panel.querySelector('pb-svg');
        console.log(svg);
        if (svg) {
            svg.setAttribute('url', new URL(svgPath, new URL(`${config.app}/`, location.href)).toString());
        }
    });

    let cbeta;
    pbEvents.subscribe('pb-update', 'cbeta', (ev) => {
        cbeta = ev.detail.root;
    });

    pbEvents.subscribe('pb-update', 'transcription', (ev) => {
        const spans = ev.detail.root.querySelectorAll('.t');
        spans.forEach((span) => {
            span.addEventListener('click', () => {
                ev.detail.root.querySelectorAll('.cbeta').forEach(lb => {
                    lb.innerHTML = '';
                });
                const walker = ev.detail.root.ownerDocument.createTreeWalker(
                    ev.detail.root,
                    NodeFilter.SHOW_ELEMENT
                );
                let found = false;
                let prevLb;
                let nextLb;
                while (walker.nextNode()) {
                    if (walker.currentNode === span) {
                        found = true;
                    }
                    if (walker.currentNode.classList.contains('cbeta')) {
                        if (found) {
                            nextLb = walker.currentNode;
                            break;
                        } else {
                            prevLb = walker.currentNode;
                        }
                    }
                }
                if (prevLb) {
                    prevLb.innerHTML = '[';
                }
                if (nextLb) {
                    nextLb.innerHTML = ']';
                }
                pbEvents.emit('pb-refresh', 'variants', {
                    params: {
                        id: prevLb.getAttribute('data-taisho')
                    }
                });

                if (cbeta) {
                    cbeta.querySelectorAll('.cbeta').forEach(lb => {
                        lb.classList.remove('highlight-start', 'highlight-end');
                    });
                    const startId = prevLb.getAttribute('data-taisho').replace(/^.*_(.*)$/, '$1');
                    const lb = cbeta.querySelector(`#lb-${startId}`);
                    lb.classList.add('highlight-start');
                    const walker = ev.detail.root.ownerDocument.createTreeWalker(
                        cbeta,
                        NodeFilter.SHOW_ELEMENT
                    );
                    let found = false;
                    let nextLb = null;
                    while (walker.nextNode()) {
                        if (walker.currentNode === lb) {
                            found = true;
                        } else if (walker.currentNode.classList.contains('cbeta') && found) {
                            nextLb = walker.currentNode;
                            break;
                        }
                    }
                    if (nextLb) {
                        nextLb.classList.add('highlight-end');
                    }
                    lb.scrollIntoView({block: "end", behavior: "smooth"});
                }
            });
        });
    });

    pbEvents.subscribe('pb-zoom', 'transcription', (ev) => {
        const direction = ev.detail.direction;
        const view = document.getElementById('variants');
        if (!view) {
            return;
        }
        const fontSize = window.getComputedStyle(view).getPropertyValue('font-size');
        const size = parseInt(fontSize.replace(/^(\d+)px/, "$1"));

        if (direction === 'in') {
            view.style.fontSize = (size + 1) + 'px';
        } else {
            view.style.fontSize = (size - 1) + 'px';
        }
    });

    pbEvents.subscribe('pb-page-ready', null, function() {
        const params = new URLSearchParams(window.location.search);
        if (params.has('site')) {
            documents.load({
                site: params.get('site')
            });
        }
    });
});