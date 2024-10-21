window.addEventListener('DOMContentLoaded', () => {

    const sites = document.getElementById('sites');
    const appConfig = document.getElementById('appConfig');
    let config = {};
    if (appConfig) {
        config = JSON.parse(appConfig.textContent);
    }

    // registering facet checkbox events
    const facets = document.querySelector('.facets');
    if (facets) {
        facets.addEventListener('pb-custom-form-loaded', function(ev) {
            const elems = ev.detail.querySelectorAll('.facet');
            // add event listener to facet checkboxes
            elems.forEach(facet => {
                facet.addEventListener('change', () => {
                    if (!facet.checked) {
                        pbRegistry.state[facet.name] = null;
                    }
                    const table = facet.closest('table');
                    if (table) {
                        const nested = table.querySelectorAll('.nested .facet').forEach(nested => {
                            if (nested != facet) {
                                nested.checked = false;
                            }
                        });
                    }
                    facets.submit();
                });
            });
        });
    }

    // start page map
    pbEvents.subscribe('pb-end-update', 'sites', () => {
        const locations = sites.querySelectorAll('pb-geolocation');
        pbEvents.emit('pb-update-map', 'map', Array.from(locations));
    });

    // site description map
    pbEvents.subscribe('pb-end-update', 'documents', (ev) => {
        const locations = document.querySelectorAll('#documents pb-geolocation');
        pbEvents.emit('pb-update-map', 'catalog', Array.from(locations));
    });

    pbEvents.subscribe('pb-leaflet-marker-click', null, (ev) => {
        const label = ev.detail.element.getAttribute('label'); // get the label
        const formattedLabel = label.replace(/\s+/g, '_'); // replace " " with "_"
        let url;
    
        //determine whether we get a link of site or inscription (by detecting the "_")
        if (formattedLabel.includes('_')) {
            url = `${config.app}/inscriptions/${formattedLabel}`; // if there is "_", use the link of inscriptions
        } else {
            url = `${config.app}/sites/${formattedLabel}`; // if not, use sites
        }
    
        window.location = url; 
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
        const illustrations = ev.detail.root.querySelectorAll('.illustration .lightbox');
        const images = new Set();
        let lightbox;
        let elements = [];
        illustrations.forEach((img) => {
            const template = img.parentNode.querySelector('[slot=alternate]');
            images.add({
                href: img.href,
                title: Array.from(template.content.childNodes).map((node) => node.outerHTML).join('')
            });
            img.addEventListener('click', (ev) => {
                ev.preventDefault();
                ev.stopPropagation();
                const pos = elements.findIndex((elem) => elem.href === img.href);
                console.log('Opening image %d', pos);
                lightbox.openAt(pos);
            })
        });
        elements = Array.from(images);
        if (elements.length > 0) {
            lightbox = GLightbox({
                elements 
            });
        }
        
        // CBETA spans for side-by-side view
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
