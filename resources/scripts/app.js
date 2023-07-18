window.addEventListener('DOMContentLoaded', () => {

    const sites = document.getElementById('sites');

    pbEvents.subscribe('pb-end-update', 'sites', () => {
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

    let svgPath;
    let loadSvg = false;
    pbEvents.subscribe('pb-update', 'catalog', (ev) => {
        if (ev.detail.root.querySelector('pb-geolocation')) {
            document.querySelector('pb-leaflet-map').style.display = 'block';
        } else {
            document.querySelector('pb-leaflet-map').style.display = 'none';
        }
        const svgImg = ev.detail.root.querySelector('.layout');
        svgPath = svgImg.getAttribute('src');
        if (loadSvg) {
            pbEvents.emit('pb-show-annotation', 'layout', {file: svgPath});
            loadSvg = false;
        }
    });

    let tify;
    pbEvents.subscribe('pb-tab', 'tabs', (ev) => {
        switch (ev.detail.selected) {
            case 0:
                const map = document.querySelector('pb-leaflet-map');
                setTimeout(() => {
                    map.map.invalidateSize(true)
                });
                break;
            case 2:
                if (svgPath) {
                    pbEvents.emit('pb-show-annotation', 'layout', {file: svgPath});
                } else {
                    loadSvg = true;
                }
                break;
            case 4:
    		const config = JSON.parse(document.getElementById('appConfig').textContent);
                if (!tify) {
                    tify = new Tify({
                        container: '#tify',
                        manifestUrl: `${config.app}/api/iiif/${config.inscription}.manifest`,
                        view: 'thumbnails',
                        pageLabelFormat: 'L',
                    });
                }
                break;
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
