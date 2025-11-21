<link rel="stylesheet" href="{$frontUrl}/css/lightbox.min.css">

<div class="modal-dialog modal-lg modal-dialog-centered" >
    <div class="modal-content">
        <input type="hidden" id="geo_type" value="{$route.geo.geo_type}">
        {if $route.geo.geo_type == 'coordinates'}
            <input type="hidden" id="geo_value" value="{$route.geo.coordinates|@json_encode|default:'null'}">
        {else}
            <input type="hidden" id="geo_value" value="{$route.geo.file_url}">
        {/if}
       
        <div class="modal-header">
            <h5 class="modal-title fw-bold" id="routeDetailsModalLabel">
                <i class="fa fa-route me-2 text-primary"></i>{$route.name}
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>

        <div class="modal-body">

            <!-- Tabs -->
            <nav class="tab-navigation">
                <ul class="nav nav-tabs mb-3" role="tablist" id="route-tabs">

                    <li class="nav-item" role="presentation">
                        <a class="nav-link active"
                           href="#tab-details"
                           id="tab-link-details"
                           aria-selected="true"
                           role="tab"
                           aria-controls="tab-details"
                           data-toggle="tab">
                            <i class="fa fa-info-circle me-1"></i> Details
                        </a>
                    </li>

                    <li class="nav-item" role="presentation">
                        <a class="nav-link"
                           href="#tab-gallery"
                           id="tab-link-gallery"
                           aria-selected="false"
                           role="tab"
                           aria-controls="tab-gallery"
                           data-toggle="tab">
                            <i class="fa fa-images me-1"></i> Galerie
                        </a>
                    </li>

                    <li class="nav-item" role="presentation">
                        <a class="nav-link"
                           href="#tab-videos"
                           id="tab-link-videos"
                           aria-selected="false"
                           role="tab"
                           aria-controls="tab-videos"
                           data-toggle="tab">
                            <i class="fa fa-video me-1"></i> Videos
                        </a>
                    </li>

                    <li class="nav-item" role="presentation">
                        <a class="nav-link"
                           href="#tab-map"
                           id="tab-link-map"
                           aria-selected="false"
                           role="tab"
                           aria-controls="tab-map"
                           data-toggle="tab">
                            <i class="fa fa-map-marked-alt me-1"></i> Karte
                        </a>
                    </li>
                </ul>
            </nav>

            <!-- Tab Content -->
            <div class="tab-content">

                <!-- Details -->
                <div class="tab-pane fade show active"
                     id="tab-details"
                     role="tabpanel"
                     aria-labelledby="tab-link-details">

                    {if $route.short_description}
                    <div class="mb-2">
                        <i class="fa fa-file-alt me-1 text-muted"></i>
                        <strong>Kurzbeschreibung :</strong>
                        <br/>{$route.short_description}
                    </div>
                    {/if}

                    {if $route.description}
                    <div class="mb-2">
                        <i class="fa fa-align-left me-1 text-muted"></i>
                        <strong>Beschreibung :</strong>:
                        <br/>{$route.description}
                    </div>
                    {/if}

                    {if $route.warning}
                    <div class="alert alert-warning py-1">
                        <i class="fa fa-exclamation-triangle me-1"></i>
                        <br/>{$route.warning}
                    </div>
                    {/if}

                    {if $route.tags|@count}
                    <div class="mt-3">
                        <strong>
                            <i class="fa fa-tags me-1 text-muted"></i>Stichworte :
                        </strong>
                        {foreach $route.tags as $tag}
                        <span class="badge badge-secondary me-1 mb-1">{$tag.name}</span>
                        {/foreach}
                    </div>
                    {/if}
                </div>

                <!-- Galerie -->
                <div class="tab-pane fade"
                     id="tab-gallery"
                     role="tabpanel"
                     aria-labelledby="tab-link-gallery">

                    {if $route.gallery|@count}
                        <div id="gallery-carousel-{$route.id}" class="row" data-bs-ride="false">
                            {foreach $route.gallery as $img key=k}
                            <div class="col-md-3 mb-2">
                                <a href="{$img.image_url}" data-lightbox="gallery-{$route.id}" data-title="{$img.alt|default:''}">
                                    <img src="{$img.image_url}" class="d-block w-100 rounded" alt="{$img.alt|default:''}">
                                </a>
                            </div>

                            {/foreach}
                        </div>
                    {else}
                        <em><i class="fa fa-image me-1"></i>Keine Bilder vorhanden.</em>
                    {/if}
                </div>

                <!-- Videos -->
                <div class="tab-pane fade"
                     id="tab-videos"
                     role="tabpanel"
                     aria-labelledby="tab-link-videos">

                    {if $route.videos|@count}
                    {foreach $route.videos as $video}
                        {if $video.provider == 'youtube'}
                        <div class="mb-2">
                            <iframe width="100%" height="315"
                                    src="https://www.youtube.com/embed/{$video.value}"
                                    frameborder="0" allowfullscreen>
                            </iframe>
                        </div>
                        {elseif $video.provider == 'self_hosted'}
                        <video controls style="max-width: 100%" class="mb-2">
                            <source src="{$video.value}">
                        </video>
                        {elseif $video.provider == 'embedded_code'}
                        <div>{$video.value}</div>
                        {/if}
                    {/foreach}
                    {else}
                    <em><i class="fa fa-video me-1"></i>Keine Videos vorhanden.</em>
                    {/if}
                </div>

                <!-- Map -->
                <div class="tab-pane fade"
                     id="tab-map"
                     role="tabpanel"
                     aria-labelledby="tab-link-map">
                    <div id="routeMap" style="height: 350px;"></div>
                    
                </div>

            </div>
        </div>

    </div>
</div>
<script src="{$frontUrl}/js/lightbox-plus-jquery.min.js"></script>
{literal}
<script>
$(document).ready(function () {

    let mapInstance = null;
    let mapLoaded = false;

    const geoType = $('#geo_type').val();
    let geoValue = $('#geo_value').val();

    // Parse JSON coordinates
    try {
        if (geoType === 'json') {
            geoValue = JSON.parse(geoValue);
        }
    } catch (e) { console.error('JSON parse failed', e); }

    // Load map ONLY when the map tab is opened
    $(document).on('shown.bs.tab', 'a[href="#tab-map"]', function () {
        if (!mapLoaded) {
            mapLoaded = true;
            initRouteMap();

            // FIX: force Leaflet to recalc size
            setTimeout(() => {
                mapInstance.invalidateSize();
            }, 200);
        }
    });

    // Also fix when modal opens
    $('#routeDetailsModal').on('shown.bs.modal', function () {
        if (mapInstance) {
            setTimeout(() => {
                mapInstance.invalidateSize();
            }, 200);
        }
    });

    function initRouteMap() {

        // Fix Leaflet duplicate map initialization
        const container = L.DomUtil.get('routeMap');
        if (container) container._leaflet_id = null;

        mapInstance = L.map('routeMap');

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 18
        }).addTo(mapInstance);

        // GPX FILE
        if (geoType === "gpx_file") {

            new L.GPX(geoValue, {
                async: true,
                marker_options: {
                    startIconUrl: null,
                    endIconUrl: null
                }
            }).on('loaded', function (e) {
                mapInstance.fitBounds(e.target.getBounds());
            }).addTo(mapInstance);

            return;
        }

        // JSON COORDINATES
        if (geoType === "json") {
            try {
                const latlngs = geoValue.map(c => [c.lat, c.lng]);

                const poly = L.polyline(latlngs).addTo(mapInstance);

                L.marker(latlngs[0]).addTo(mapInstance).bindPopup("Start");
                L.marker(latlngs[latlngs.length - 1]).addTo(mapInstance).bindPopup("End");

                mapInstance.fitBounds(poly.getBounds());

            } catch (e) {
                console.error("Invalid JSON route", e);
            }
        }
    }

});
</script>
{/literal}

