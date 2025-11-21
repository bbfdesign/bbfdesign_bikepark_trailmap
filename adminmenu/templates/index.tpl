<link rel="stylesheet" href="{$adminUrl}css/kaiadmin.css">
<link rel="stylesheet" href="{$adminUrl}css/admin.css">

<div class="wrapper">
  {$jtl_token}
    <!-- Sidebar -->
    <div id="bbfdesign-plugin-sidebar">
      {include './sidebar.tpl'}
    </div>
    <!-- End Sidebar -->

      <div class="main-panel">
    <div class="container">
      <div class="page-inner" >
        <div class="d-flex justify-content-between align-items-left align-items-md-center flex-column flex-md-row pt-2 pb-4">
          <div class="card page-title d-flex justify-content-between  flex-row align-items-center">
            <div class="">
              <h3 class="fw-bold mb-3">Bikepark Routen</h3>
              <h6 class=""></h6>
            </div>
            <div class="dashboard-icon">
              <img
              src="{$adminUrl}images/light-Cross-net-switch.svg"
              alt="navbar brand"
              class="navbar-brand"
              height="40"
              />
            </div>
          </div>
        </div>
        <div id="bbfdesign-plugin-page"></div>
      </div>
    </div>
  </div>

    </div>
    <input type="hidden" id="datatableLangVariables" value='{$datatableLangVariables}'>
<script>
    var ShopURL = "{$ShopURL}";
    var adminUrl = "{$adminUrl}";
    var postURL = "{$postURL}";
    var datatableLangVariables = JSON.parse($('#datatableLangVariables').val());
</script>
<script src="{$adminUrl}js/plugin/jquery-scrollbar/jquery.scrollbar.min.js"></script>
<script src="{$adminUrl}js/plugin/bootstrap-notify/bootstrap-notify.min.js"></script>
<script src="{$adminUrl}js/kaiadmin.js"></script>
<script src="{$adminUrl}js/admin.js"></script>
