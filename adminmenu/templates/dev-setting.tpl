<div class="row">
  <div class="col-md-12">
    <div class="card m-3-d">
      <div class="card-body">
        <div class="row">
          <div class="col-md-6">
            <div class="form-group">
              <button class="btn btn-primary" onclick="refreshLanguageVariables()"><i class="fa fa-refresh"></i> Sprachvariablen aktualisieren</button>
            </div>
          </div>

          <div class="col-md-6">
            <div class="form-group">
              <button class="btn btn-primary" onclick="syncMissingSettings()"><i class="fa fa-refresh"></i> Fehlende Einstellungen synchronisieren</button>
            </div>
          </div>

        </div>
      </div>
    </div>
  </div>
</div>
<script>

  
function refreshLanguageVariables() {
    var formdata = new FormData();
    formdata.append("is_ajax", 1);
    formdata.append("action", 'refreshLanguageVariables');
    formdata.append("jtl_token", $('[name="jtl_token"]').val());

    $.ajax({
      url: postURL,
      type: 'POST',
      data: formdata,
      processData: false,
      contentType: false,
      success: function (response) {
        if (response.flag) {
          if (typeof response.message !== "undefined" && response.message) {
            bbdNotify("Success", response.message, "success", "fa fa-check-circle");
          }
        } else {
          if (typeof response.errors !== "undefined" && response.errors.length) {
            response.errors.forEach((error) => {
              bbdNotify("Error", error, "danger", "fa fa-exclamation-triangle");
            });
          }
        }
      },
      error: function () {
        bbdNotify("An error occurred while saving.", error, "danger", "fa fa-exclamation-triangle");
      }
    });
  }

  function syncMissingSettings() {
    var formdata = new FormData();
    formdata.append("is_ajax", 1);
    formdata.append("action", 'syncMissingSettings');
    formdata.append("jtl_token", $('[name="jtl_token"]').val());

    $.ajax({
      url: postURL,
      type: 'POST',
      data: formdata,
      processData: false,
      contentType: false,
      success: function (response) {
        if (response.flag) {
          if (typeof response.message !== "undefined" && response.message) {
            bbdNotify("Success", response.message, "success", "fa fa-check-circle");
          }
        } else {
          if (typeof response.errors !== "undefined" && response.errors.length) {
            response.errors.forEach((error) => {
              bbdNotify("Error", error, "danger", "fa fa-exclamation-triangle");
            });
          }
        }
      },
      error: function () {
        bbdNotify("An error occurred while saving.", error, "danger", "fa fa-exclamation-triangle");
      }
    });
  }

</script>
