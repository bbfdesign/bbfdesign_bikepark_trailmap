<div class="row">
  <div class="col-md-12">
    <div class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Route Geo Locations</h5>
        <button type="button" class="btn btn-success" onclick="openAddGeoModal()">
          <i class="fa fa-plus"></i> Add Geo Entry
        </button>
      </div>
      
      <div class="card-body">
        <table class="table table-hover">
          <thead>
            <tr>
              <th>ID</th>
              <th>Route</th>
              <th>Type</th>
              <th>Coordinates</th>
              <th>Action</th>
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
                <a href="javascript:void(0);" class="view-json-link" data-json="{$g.coordinates|escape:'html'}">View JSON</a>
                {elseif $g.geo_type == 'gpx_file' && $g.file_url}
                {assign var="filename" value=$g.file_url|basename}
                <a href="{$g.file_url}" target="_blank">{$filename}</a>
                {else}
                N/A
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
<div class="modal fade" id="jsonViewModal" tabindex="-1" aria-labelledby="jsonViewModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="jsonViewModalLabel">Geo JSON Data</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
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
        <div class="modal-header"><h5>Add Geo</h5></div>
        <div class="modal-body">
          <input type="hidden" name="action" value="addGeo">
          <input type="hidden" name="is_ajax" value="1">
          {$jtl_token}
          
          <div class="row">
            <div class="col-md-6">
              <label>Route</label>
              <select name="route_id" class="form-control">
                {foreach from=$routes item=route}
                <option value="{$route.id}">{$route.name}</option>
                {/foreach}
              </select>
            </div>
            
            <div class="col-md-6">
              <label>Geo Type</label>
              <select name="geo_type" id="geo_type" class="form-control" required>
                <option value="json">JSON</option>
                <option value="gpx_file">GPX File</option>
              </select>
            </div>
            
            <div class="col-md-12 mt-3" id="coordinates_group">
              <label>Coordinates (JSON)</label>
              <textarea name="coordinates" id="coordinates_input" class="form-control" rows="4"></textarea>
            </div>
            
            <div class="col-md-12 mt-3" id="file_upload_group" style="display:none;">
              <label>Upload GPX File</label>
              <input type="file" name="file_url" id="file_upload_input" class="form-control" accept=".gpx" />
            </div>
          </div>
        </div>
        
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary" onclick="saveGeo()">Save</button>
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
        <div class="modal-header"><h5>Edit Geo</h5></div>
        <div class="modal-body">
          <input type="hidden" name="action" value="updateGeo" />
          <input type="hidden" name="is_ajax" value="1" />
          <input type="hidden" name="geo_id" id="edit_geo_id" />
          {$jtl_token}
          
          <div class="row">
            <div class="col-md-6">
              <label>Route</label>
              <select name="route_id" id="edit_route_id" class="form-control" required>
                {foreach from=$routes item=route}
                <option value="{$route.id}">{$route.name}</option>
                {/foreach}
              </select>
            </div>
            <!-- Add geo_type select -->
            <div class="col-md-6">
              <label>Geo Type</label>
              <select name="geo_type" id="edit_geo_type" class="form-control" required>
                <option value="json">JSON</option>
                <option value="gpx_file">GPX File</option>
              </select>
            </div>
          </div>
          
          <!-- JSON Coordinates Input -->
          <div class="mt-3" id="edit_coordinates_group">
            <label>Coordinates (JSON)</label>
            <textarea name="coordinates" id="edit_coordinates" class="form-control" rows="4"></textarea>
          </div>
          
          <!-- GPX File Upload -->
          <div class="mt-3" id="edit_file_upload_group" style="display:none;">
            <label>Upload GPX File</label>
            <input type="file" name="file_url" id="edit_file_input" class="form-control" accept=".gpx" />
            <div class="mt-2">
              <a href="" target="_blank" id="current_gpx_link">Current GPX File</a>
            </div>
          </div>
        </div>
        
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary" onclick="updateGeo()">Save</button>
        </div>
      </form>
    </div>
  </div>
</div>


<script>
  $(document).on('click', '.view-json-link', function() {
    var jsonData = $(this).data('json');
    try {
      var obj = JSON.parse(jsonData);
      jsonData = JSON.stringify(obj, null, 2);
    } catch(e) {
    }
    $('#jsonContent').text(jsonData);
    $('#jsonViewModal').modal('show');
  });
  
  function toggleGeoTypeFields(prefix = '') {
    const geoType = $(`#`+prefix+`geo_type`).val();
    
    if (geoType === 'gpx_file') {
      $(`#`+prefix+`file_upload_group`).show();
      $(`#`+prefix+`coordinates_group`).hide();
      // Adjust required flags
      $(`#`+prefix+`file_upload_input`).prop('required', true);
      $(`#`+prefix+`coordinates_input`).prop('required', false);
    } else if (geoType === 'json') {
      $(`#`+prefix+`file_upload_group`).hide();
      $(`#`+prefix+`coordinates_group`).show();
      $(`#`+prefix+`coordinates_input`).prop('required', true);
      $(`#`+prefix+`file_upload_input`).prop('required', false);
    } else {
      $(`#`+prefix+`file_upload_group`).hide();
      $(`#`+prefix+`coordinates_group`).hide();
      $(`#`+prefix+`coordinates_input`).prop('required', false);
      $(`#`+prefix+`file_upload_input`).prop('required', false);
    }
  }
  
  $(document).ready(function() {
    $('#geo_type').on('change', function() {
      toggleGeoTypeFields();
    });
    
    $('#edit_geo_type').on('change', function() {
      toggleGeoTypeFields('edit_');
    });
  });
  
  function openAddGeoModal() {
    $('#addGeoModal').modal('show');
  }
  
  function saveGeo() {
    const form = $('#addGeoForm')[0];
    const formData = new FormData(form);
    
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
          (res.errors || []).forEach(error => {
            bbdNotify("Error", error, "danger", "fa fa-exclamation-triangle");
          });
        }
      },
      error: function() {
        bbdNotify("Error", "An error occurred during upload.", "danger", "fa fa-exclamation-triangle");
      }
    });
  }
  
  function updateGeo() {
    const form = $('#editGeoForm')[0];
    const formData = new FormData(form);
    
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
          (res.errors || []).forEach(error => {
            bbdNotify("Error", error, "danger", "fa fa-exclamation-triangle");
          });
        }
      },
      error: function() {
        bbdNotify("Error", "An error occurred during upload.", "danger", "fa fa-exclamation-triangle");
      }
    });
  }
  
  
  function editGeo(id) {
    $.post(postURL, {
      action: 'getGeo',
      is_ajax: 1,
      geo_id: id,
      jtl_token: $('[name="jtl_token"]').val()
    }, function(res) {
      if (res.flag) {
        $('#edit_geo_id').val(res.geo.id);
        $('#edit_geo_type').val(res.geo.geo_type);
        $('#edit_coordinates').val(res.geo.coordinates || '');
        if (res.geo.geo_type === 'gpx_file') {
          $('#current_gpx_link').attr('href', res.geo.file_url).text('Download GPX File');
        } else {
          $('#current_gpx_link').attr('href', '#').text('');
        }
        $('#editGeoModal').modal('show');
        
        setTimeout(function() {
          toggleGeoTypeFields('edit_');
        }, 300);
      }
    });
  }
  
  
  
  function deleteGeo(id) {
    if (!confirm("Delete Geo entry?")) return;
    
    $.post(postURL, {
      action: 'deleteGeo',
      is_ajax: 1,
      geo_id: id,
      jtl_token: $('[name="jtl_token"]').val()
    }, function(res) {
      if (res.flag) {
        bbdNotify("Success", res.message, "success");
        setTimeout(() => getPage('geo'), 500);
      } else {
        (response.errors || []).forEach(error => {
          bbdNotify("Error", error, "danger", "fa fa-exclamation-triangle");
        });
      }
    });
  }
  
</script>
