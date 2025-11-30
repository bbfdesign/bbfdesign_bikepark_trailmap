<link rel="stylesheet" href="{$adminUrl}css/dataTables.dataTables.css">

<div class="row">
  <div class="col-md-12">
    <div class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
          {$langVars->getTranslation('route_geo_locations', $adminLang)}
        </h5>

        <button type="button" class="btn btn-success" onclick="openAddGeoModal()">
          <i class="fa fa-plus"></i>
          {$langVars->getTranslation('add_geo_entry', $adminLang)}
        </button>
      </div>
      
      <div class="card-body">
        <table class="table table-hover" id="geo-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>{$langVars->getTranslation('route', $adminLang)}</th>
              <th>{$langVars->getTranslation('geo_type', $adminLang)}</th>
              <th>{$langVars->getTranslation('coordinates', $adminLang)}</th>
              <th>{$langVars->getTranslation('action', $adminLang)}</th>
            </tr>
          </thead>

          <tbody>
            {foreach $geos as $g}
            <tr>
              <td>{$g.id}</td>
              <td>{$g.name}</td>
              <td>{$g.geo_type}</td>

              <td>
                {if $g.geo_type == 'json'}
                  <a href="javascript:void(0);" 
                     class="view-json-link"
                     data-json="{$g.coordinates|escape:'html'}">
                     {$langVars->getTranslation('view_json', $adminLang)}
                  </a>
                {elseif $g.geo_type == 'gpx_file' && $g.file_url}
                  {assign var="filename" value=$g.file_url|basename}
                  <a href="{$g.file_url}" target="_blank">{$filename}</a>
                {else}
                  {$langVars->getTranslation('na', $adminLang)}
                {/if}
              </td>

              <td>
                <button class="btn btn-primary btn-sm" onclick="editGeo({$g.id})">
                  <i class="fa fa-pencil"></i>
                </button>
                <button class="btn btn-danger btn-sm" onclick="deleteGeo({$g.id})">
                  <i class="fa fa-trash"></i>
                </button>
              </td>
            </tr>
            {/foreach}
          </tbody>

        </table>
      </div>
    </div>
  </div>
</div>



<!-- JSON VIEW MODAL -->
<div class="modal fade" id="jsonViewModal" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title">
          {$langVars->getTranslation('geo_json_data', $adminLang)}
        </h5>

        <button type="button" class="btn-close" data-dismiss="modal"></button>
      </div>

      <div class="modal-body">
        <pre id="jsonContent" style="white-space: pre-wrap; word-wrap: break-word;"></pre>
      </div>

    </div>
  </div>
</div>



<!-- ADD -->
<div class="modal fade" id="addGeoModal">
  <div class="modal-dialog">
    <div class="modal-content">

      <form id="addGeoForm">
        <div class="modal-header">
          <h5>{$langVars->getTranslation('add_geo', $adminLang)}</h5>
        </div>

        <div class="modal-body">

          <input type="hidden" name="action" value="addGeo">
          <input type="hidden" name="is_ajax" value="1">
          {$jtl_token}
          
          <div class="row">

            <div class="col-md-6">
              <label>{$langVars->getTranslation('route', $adminLang)}</label>
              <select name="route_id" class="form-control">
                {foreach $routes as $route}
                  <option value="{$route.id}">{$route.name}</option>
                {/foreach}
              </select>
            </div>

            <div class="col-md-6">
              <label>{$langVars->getTranslation('geo_type', $adminLang)}</label>
              <select name="geo_type" id="geo_type" class="form-control" required>
                <option value="json">JSON</option>
                <option value="gpx_file">GPX</option>
              </select>
            </div>

            <div class="col-md-12 mt-3" id="coordinates_group">
              <label>{$langVars->getTranslation('coordinates_json', $adminLang)}</label>
              <textarea name="coordinates" id="coordinates_input" class="form-control" rows="4"></textarea>
            </div>

            <div class="col-md-12 mt-3" id="file_upload_group" style="display:none;">
              <label>{$langVars->getTranslation('upload_gpx_file', $adminLang)}</label>
              <input type="file" name="file_url" id="file_upload_input" class="form-control" accept=".gpx" />
            </div>

          </div>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">
            {$langVars->getTranslation('close', $adminLang)}
          </button>
          <button type="button" class="btn btn-primary" onclick="saveGeo()">
            {$langVars->getTranslation('save', $adminLang)}
          </button>
        </div>
      </form>

    </div>
  </div>
</div>





<!-- EDIT -->
<div class="modal fade" id="editGeoModal">
  <div class="modal-dialog">
    <div class="modal-content">

      <form id="editGeoForm">
        <div class="modal-header">
          <h5>{$langVars->getTranslation('edit_geo', $adminLang)}</h5>
        </div>

        <div class="modal-body">

          <input type="hidden" name="action" value="updateGeo">
          <input type="hidden" name="is_ajax" value="1">
          <input type="hidden" name="geo_id" id="edit_geo_id">
          {$jtl_token}

          <div class="row">

            <div class="col-md-6">
              <label>{$langVars->getTranslation('route', $adminLang)}</label>
              <select name="route_id" id="edit_route_id" class="form-control" required>
                {foreach $routes as $route}
                  <option value="{$route.id}">{$route.name}</option>
                {/foreach}
              </select>
            </div>

            <div class="col-md-6">
              <label>{$langVars->getTranslation('geo_type', $adminLang)}</label>
              <select name="geo_type" id="edit_geo_type" class="form-control" required>
                <option value="json">JSON</option>
                <option value="gpx_file">GPX</option>
              </select>
            </div>

          </div>

          <div class="mt-3" id="edit_coordinates_group">
            <label>{$langVars->getTranslation('coordinates_json', $adminLang)}</label>
            <textarea name="coordinates" id="edit_coordinates" class="form-control" rows="4"></textarea>
          </div>

          <div class="mt-3" id="edit_file_upload_group" style="display:none;">
            <label>{$langVars->getTranslation('upload_gpx_file', $adminLang)}</label>
            <input type="file" name="file_url" id="edit_file_input" class="form-control" accept=".gpx" />
            <div class="mt-2">
              <a href="" target="_blank" id="current_gpx_link">
                {$langVars->getTranslation('current_gpx_file', $adminLang)}
              </a>
            </div>
          </div>

        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">
            {$langVars->getTranslation('close', $adminLang)}
          </button>
          <button type="button" class="btn btn-primary" onclick="updateGeo()">
            {$langVars->getTranslation('save', $adminLang)}
          </button>
        </div>

      </form>

    </div>
  </div>
</div>




<script src="{$adminUrl}js/dataTables.js"></script>
<script>
  $(document).ready(function () {
    var table = $('#geo-table').DataTable({
      "language": datatableLangVariables,
      "order": [[0, "desc"]]
    });
  });

  $(document).on('click', '.view-json-link', function() {
    var jsonData = $(this).data('json');
    try {
      jsonData = JSON.stringify(JSON.parse(jsonData), null, 2);
    } catch(e) {}
    $('#jsonContent').text(jsonData);
    $('#jsonViewModal').modal('show');
  });


  function toggleGeoTypeFields(prefix = '') {
    const type = $('#' + prefix + 'geo_type').val();

    const fileGroup = $('#' + prefix + 'file_upload_group');
    const coordGroup = $('#' + prefix + 'coordinates_group');
    const fileInput = $('#' + prefix + 'file_upload_input');
    const coordInput = $('#' + prefix + 'coordinates_input');

    if (type === 'gpx_file') {
      fileGroup.show();
      coordGroup.hide();
      fileInput.prop('required', true);
      coordInput.prop('required', false);
    } else {
      fileGroup.hide();
      coordGroup.show();
      coordInput.prop('required', true);
      fileInput.prop('required', false);
    }
  }


  $(document).ready(function() {
    $('#geo_type').on('change', () => toggleGeoTypeFields());
    $('#edit_geo_type').on('change', () => toggleGeoTypeFields('edit_'));
  });


  function openAddGeoModal() {
    $('#addGeoModal').modal('show');
  }


  function saveGeo() {
    const formData = new FormData($('#addGeoForm')[0]);

    $.ajax({
      url: postURL,
      type: 'POST',
      data: formData,
      processData: false,
      contentType: false,
      success: function(res) {
        if (res.flag) {
          bbdNotify("Success", res.message, "success");
          $('#addGeoModal').modal('hide');
          setTimeout(() => getPage('geo'), 500);
        } else {
          (res.errors || []).forEach(err => 
            bbdNotify("Error", err, "danger")
          );
        }
      },
      error: function() {
        bbdNotify("Error", "{$langVars->getTranslation('error_upload', $adminLang)}", "danger");
      }
    });
  }


  function updateGeo() {
    const formData = new FormData($('#editGeoForm')[0]);

    $.ajax({
      url: postURL,
      type: 'POST',
      data: formData,
      processData: false,
      contentType: false,
      success: function(res) {
        if (res.flag) {
          bbdNotify("Success", res.message, "success");
          $('#editGeoModal').modal('hide');
          setTimeout(() => getPage('geo'), 500);
        } else {
          (res.errors || []).forEach(err => 
            bbdNotify("Error", err, "danger")
          );
        }
      },
      error: function() {
        bbdNotify("Error", "{$langVars->getTranslation('error_upload', $adminLang)}", "danger");
      }
    });
  }


  function editGeo(id) {
    $.post(postURL, {
      action: 'getGeo',
      is_ajax: 1,
      geo_id: id,
      jtl_token: $('[name=\"jtl_token\"]').val()
    }, function(res) {
      if (res.flag) {

        $('#edit_geo_id').val(res.geo.id);
        $('#edit_geo_type').val(res.geo.geo_type);
        $('#edit_coordinates').val(res.geo.coordinates);

        if (res.geo.geo_type === 'gpx_file') {
          $('#current_gpx_link').attr('href', res.geo.file_url);
        } else {
          $('#current_gpx_link').attr('href', '#');
        }

        $('#editGeoModal').modal('show');

        setTimeout(() => toggleGeoTypeFields('edit_'), 300);
      }
    });
  }


  function deleteGeo(id) {
    if (!confirm("{$langVars->getTranslation('delete_geo_confirm', $adminLang)}")) return;

    $.post(postURL, {
      action: 'deleteGeo',
      is_ajax: 1,
      geo_id: id,
      jtl_token: $('[name=\"jtl_token\"]').val()
    }, function(res) {
      if (res.flag) {
        bbdNotify("Success", res.message, "success");
        setTimeout(() => getPage('geo'), 500);
      }
    });
  }

</script>
