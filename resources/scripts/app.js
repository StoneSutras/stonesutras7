window.addEventListener('DOMContentLoaded', () => {
    const sites = document.getElementById('sites');
    const documents = document.getElementById('documents');
    pbEvents.subscribe('pb-end-update', 'sites', () => {
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
});