window.addEventListener('DOMContentLoaded', () => {
    pbEvents.subscribe('pb-end-update', 'sites', () => {
        const sites = document.getElementById('sites');
        const documents = document.getElementById('documents');
        pbEvents.emit('pb-update', 'map', {
            root: sites
        });
        sites.querySelectorAll('pb-geolocation').forEach((geo) => {
            geo.addEventListener('click', (ev) => {
                ev.preventDefault();
                documents.load({
                    site: geo.id
                });
            });
        });
    });

    const panel = document.querySelector('pb-panel');
    let svgPath;
    pbEvents.subscribe('pb-update', 'catalog', (ev) => {
        const svgImg = ev.detail.root.querySelector('.layout');
        svgPath = svgImg.getAttribute('src');
        const svg = panel.querySelector('pb-svg');
        if (svg) {
            svg.setAttribute('url', svgPath);
        }
    });
    pbEvents.subscribe('pb-panel', 'panels', () => {
        const svg = panel.querySelector('pb-svg');
        if (svg) {
            svg.setAttribute('url', svgPath);
        }
    });
});