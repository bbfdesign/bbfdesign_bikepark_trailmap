<div class="app">
    <div class="sidebar">
        <div class="top-buttons">
            <button id="showAll">All at</button>
            <button id="hideAll">All from</button>
            <button id="fitBtn">Zoom in on routes</button>
        </div>

        <input type="text" id="q" class="search" placeholder="Search route (name/difficulty/status)…">

        <div class="legend">
        </div>

        <h3 class="section-title">Stretch</h3>

        <div id="routeDetailsList" class="route-details-list">
        </div>
    </div>

    <!-- MAP -->
    <div id="bikepark-trackmap-map"></div>
</div>

<dialog id="trackModal" style="border:none;border-radius:16px;padding:0;max-width:520px;width:clamp(320px,92vw,520px);">
  <div style="background:#0f172a;color:#e5e7eb;border-radius:16px;overflow:hidden">
    <div style="display:flex;align-items:center;justify-content:space-between;padding:14px 16px;border-bottom:1px solid rgba(255,255,255,.08)">
      <strong id="mTitle" style="font-size:16px;color:#fff">Strecke</strong>
      <button id="mClose" class="btn" style="margin-left:12px">Schließen</button>
    </div>
    <div style="padding:16px;display:grid;gap:10px">
      <div><span class="badge" id="mDiff">–</span></div>
      <div style="font-size:14px;color:#cbd5e1">Status: <span id="mStatus">–</span></div>
      <div id="mMeta" style="font-size:14px;color:#cbd5e1"></div>
    </div>
    <div style="display:flex;gap:8px;justify-content:flex-end;padding:12px 16px;border-top:1px solid rgba(255,255,255,.08);background:rgba(255,255,255,.03)">
      <button id="mZoom" class="btn">Zur Strecke zoomen</button>
      <button id="mClose2" class="btn">OK</button>
    </div>
  </div>
</dialog>


<script>
window.BIKEPARK_ROUTES = {$routes|json_encode};
window.DIFFICULTY_LABELS = {$difficultyLabels|json_encode};
window.AVAILABILITY_LABELS = {$availabilityLabels|json_encode};
</script>
