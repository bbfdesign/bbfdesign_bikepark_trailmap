var routes = window.BIKEPARK_ROUTES || [];
var difficultyLabels = window.DIFFICULTY_LABELS || {};
var availabilityLabels = window.AVAILABILITY_LABELS || {};
var difficultyColors = {
  very_easy: "#34d399",
  easy: "#22c55e",
  medium: "#eab308",
  difficult: "#ef4444",
  pro: "#6366f1",
};
var visibleDiff = {};
var visibleStatus = {};

/* INIT MAP */
var map = L.map("map").setView([51.183691, 8.509673], 16);

L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
  maxZoom: 19,
}).addTo(map);

var routeLayers = {};

$(function () {
  /* BUILD LEGEND */
  function buildLegend() {
    var html = "<strong>Legend & Filter</strong>";

    html +=
      '<div class="legend-item" style="margin-top:4px"><em style="font-size:12px;color:#555">difficulty</em></div>';

    $.each(difficultyLabels, function (key, label) {
      html += `<div class="legend-item">
                    <span class="swatch" style="background:${
                      difficultyColors[key] || "#666"
                    }"></span>
                    ${label}
                    <input type="checkbox" class="df" data-diff="${key}" checked style="margin-left:auto">
                </div>`;
    });

    html +=
      '<div class="legend-item" style="margin-top:10px"><em style="font-size:12px;color:#555">status</em></div>';

    $.each(availabilityLabels, function (key, label) {
      html += `<div class="legend-item">
                    ${label}
                    <input type="checkbox" class="sf" data-status="${key}" checked style="margin-left:auto">
                </div>`;
    });

    $(".legend").html(html);
  }

  buildLegend();

  routes.forEach(function (r) {
    var geo = r.geo;

    /* GPX FILE */
    if (geo.geo_type === "gpx_file") {
      var gpxLayer = new L.GPX(geo.file_url, {
        async: true,
        marker_options: { startIconUrl: null, endIconUrl: null },
        polyline_options: {
          color: difficultyColors[r.difficulty] || "#888",
          weight: 4,
          opacity: 0.95,
        },
      })
        .on("loaded", function (e) {
          map.fitBounds(e.target.getBounds());
        })
        .addTo(map);

      routeLayers[r.id] = { layer: gpxLayer, meta: r };
    } else if (geo.geo_type === "json") {
      /* JSON POLYLINE */
      try {
        var latlngs = JSON.parse(geo.geo_value);

        var poly = L.polyline(
          latlngs.map((c) => [c.lat, c.lng]),
          {
            color: difficultyColors[r.difficulty] || "#888",
            weight: 4,
            opacity: 0.95,
          }
        );
        poly.addTo(map);

        routeLayers[r.id] = { layer: poly, meta: r };
      } catch (e) {}
    }
  });

  /* FILTERS + SEARCH */
  function renderRouteDetails(filter) {
    $(".df:checked").each(function () {
      visibleDiff[$(this).data("diff")] = true;
    });
    $(".sf:checked").each(function () {
      visibleStatus[$(this).data("status")] = true;
    });

    var needle = (filter || "").toLowerCase();

    var list = $("#routeDetailsList").empty();

    routes.forEach(function (r) {
      if (!visibleDiff[r.difficulty] || !visibleStatus[r.status]) return;

      var match =
        !needle ||
        r.name.toLowerCase().includes(needle) ||
        (difficultyLabels[r.difficulty] || "").toLowerCase().includes(needle) ||
        (availabilityLabels[r.status] || "").toLowerCase().includes(needle);

      if (!match) return;

      var card = `
        <div class="route-detail-card route-open" data-id="${r.id}">
            <div class="route-detail-title">${r.name}</div>

            <div class="route-detail-meta">
                <span class="route-detail-badge" style="background:${
                  difficultyColors[r.difficulty] || "#333"
                }">
                    ${difficultyLabels[r.difficulty] || r.difficulty}
                </span>
                <span class="route-detail-status">
                    ${availabilityLabels[r.status] || r.status}
                </span>
            </div>
        </div>
    `;

      list.append(card);
    });
  }

  renderRouteDetails();

  $(document).on("change", ".df,.sf", function () {
    renderRouteDetails($("#q").val());
    updateMapVisibility();
  });

  $("#q").on("input", function () {
    renderRouteDetails($(this).val());
  });

  /* SHOW/HIDE ALL BUTTONS */
  $("#showAll").click(function () {
    $(".df,.sf").prop("checked", true);
    renderRouteDetails($("#q").val());
  });

  $("#hideAll").click(function () {
    $(".df,.sf").prop("checked", false);
    renderRouteDetails($("#q").val());
  });

  /* FIT BUTTON */
  $("#fitBtn").click(function () {
    var visibleLayers = [];

    $(".df:checked").each(function () {
      visibleDiff[$(this).data("diff")] = true;
    });

    $(".sf:checked").each(function () {
      visibleStatus[$(this).data("status")] = true;
    });

    routes.forEach(function (r) {
      if (
        routeLayers[r.id] &&
        visibleDiff[r.difficulty] &&
        visibleStatus[r.status]
      ) {
        visibleLayers.push(routeLayers[r.id].layer);
      }
    });

    if (visibleLayers.length) {
      var group = L.featureGroup(visibleLayers);
      map.fitBounds(group.getBounds().pad(0.1));
    }
  });
});

$(document).on("click", ".route-open", function () {
  var id = $(this).data("id");
  var r = routes.find((x) => x.id == id);

  if (!r) return;

  $("#mTitle").text(r.name);
  $("#mDiff").text(difficultyLabels[r.difficulty] || r.difficulty);
  $("#mDiff").css("background", difficultyColors[r.difficulty] || "#333");

  $("#mStatus").text(availabilityLabels[r.status] || r.status);

  $("#mMeta").html(`
        <div>Start: ${r.start_lat ?? "-"}, ${r.start_lng ?? "-"}</div>
        ${r.short_description ? `<div>${r.short_description}</div>` : ""}
        ${r.description ? `<div>${r.description}</div>` : ""}
        ${r.warning ? `<div style="color:#f87171">⚠ ${r.warning}</div>` : ""}
    `);

  $("#mZoom")
    .off()
    .on("click", function () {
      if (routeLayers[id]) {
        map.fitBounds(routeLayers[id].layer.getBounds());
      }
      document.getElementById("trackModal").close();
    });

  document.getElementById("trackModal").showModal();
});

$("#mClose, #mClose2").on("click", function () {
  document.getElementById("trackModal").close();
});

function updateMapVisibility() {
  var visibleDiff = {};
  var visibleStatus = {};

  $(".df:checked").each(function () {
    visibleDiff[$(this).data("diff")] = true;
  });
  $(".sf:checked").each(function () {
    visibleStatus[$(this).data("status")] = true;
  });

  routes.forEach(function (r) {
    var entry = routeLayers[r.id];
    if (!entry) return;

    var layer = entry.layer;

    var shouldShow = visibleDiff[r.difficulty] && visibleStatus[r.status];

    if (shouldShow) {
      if (!map.hasLayer(layer)) map.addLayer(layer);
    } else {
      if (map.hasLayer(layer)) map.removeLayer(layer);
    }
  });
}
