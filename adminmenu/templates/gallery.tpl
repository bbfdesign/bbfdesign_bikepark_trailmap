<div class="card">
  <div class="card-header d-flex justify-content-between">
    <h5>Route Gallery</h5>
    <button class="btn btn-success" onclick="openCreateGalleryModal()">
      <i class="fa fa-plus"></i> Add Image
    </button>
  </div>
  
  <div class="card-body">
    <table class="table table-hover">
      <thead>
        <tr>
          <th>ID</th>
          <th>Route</th>
          <th>Image</th>
          <th>Alt</th>
          <th>Sort Order</th>
          <th>Action</th>
        </tr>
      </thead>
      
      <tbody>
        {foreach $galleries as $gallery}
        <tr>
          <td>{$gallery.id}</td>
          <td>{$gallery.name}</td>
          <td><img src="{$gallery.image_url}" style="height:60px;"></td>
          <td>{$gallery.alt}</td>
          <td>{$gallery.sort_order}</td>
          <td>
            <button class="btn btn-sm btn-primary" onclick="editGallery({$gallery.id})">
              <i class="fa fa-pencil"></i>
            </button>
            <button class="btn btn-sm btn-danger" onclick="deleteGallery({$gallery.id})">
              <i class="fa fa-trash"></i>
            </button>
          </td>
        </tr>
        {/foreach}
      </tbody>
    </table>
  </div>
</div>
<!-- Create Modal -->
<div class="modal fade" id="createGalleryModal" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <form id="createGalleryForm" enctype="multipart/form-data">
        <div class="modal-header">
          <h5>Create Gallery Item</h5>
        </div>
        <div class="modal-body">
          <input type="hidden" name="is_ajax" value="1">
          <input type="hidden" name="action" value="addGallery">
          {$jtl_token}
          
          <div class="row">
            <div class="col-md-6 mb-3">
              <label for="create_route_id">Route</label>
              <select name="route_id" id="create_route_id" class="form-control">
                <option value="">Select Route</option>
                {foreach from=$routes item=route}
                <option value="{$route.id}">{$route.name} - {$route.external_id}</option>
                {/foreach}
              </select>
            </div>
            
            <div class="col-md-6 mb-3">
              <label for="create_img_type">Image Source</label>
              <select name="is_external" id="create_img_type" class="form-control" onchange="toggleImageInput('create')">
                <option value="0">Upload Image</option>
                <option value="1">External URL</option>
              </select>
            </div>
            
            <div class="col-md-6 mb-3" id="create_image_url_group" style="display:none;">
              <label for="create_image_url">Image URL</label>
              <input type="text" name="image_url" id="create_image_url" class="form-control">
            </div>
            
            <div class="col-md-6 mb-3" id="create_image_file_group">
              <label for="create_image_file">Upload Image</label>
              <input type="file" name="image_file" id="create_image_file" class="form-control">
            </div>
            
            <div class="col-md-6 mb-3">
              <label for="create_alt">Alt Text</label>
              <input type="text" name="alt" id="create_alt" class="form-control">
            </div>
            
            <div class="col-md-6 mb-3">
              <label for="create_sort_order">Sort Order</label>
              <input type="number" name="sort_order" id="create_sort_order" class="form-control">
            </div>
            <div class="col-md-6 mb-3">
              <label for="status">Status</label>
              <select name="status" id="status" class="form-control">
                <option value="1">Active</option>
                <option value="0">Inactive</option>
              </select>
            </div>
          </div>
        </div>
        
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary" onclick="saveCreateGallery()">Save</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Edit Modal -->
<div class="modal fade" id="editGalleryModal" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <form id="editGalleryForm" enctype="multipart/form-data">
        <div class="modal-header">
          <h5>Edit Gallery Item</h5>
        </div>
        <div class="modal-body">
          <input type="hidden" name="is_ajax" value="1">
          <input type="hidden" name="action" value="updateGallery">
          <input type="hidden" name="gallery_id" id="edit_gallery_id">
          {$jtl_token}
          
          <div class="row">
            <div class="col-md-6 mb-3">
              <label for="edit_route_id">Route</label>
              <select name="route_id" id="edit_route_id" class="form-control">
                <option value="">Select Route</option>
                {foreach from=$routes item=route}
                  <option value="{$route.id}">{$route.name} - {$route.external_id}</option>
                {/foreach}
              </select>
            </div>
            
            <div class="col-md-6 mb-3">
              <label for="edit_img_type">Image Source</label>
              <select name="is_external" id="edit_img_type" class="form-control" onchange="toggleImageInput('edit')">
                <option value="0">Upload Image</option>
                <option value="1">External URL</option>
              </select>
            </div>
            
            <div class="col-md-6 mb-3" id="edit_image_url_group" style="display:none;">
              <label for="edit_image_url">Image URL</label>
              <input type="text" name="image_url" id="edit_image_url" class="form-control">
            </div>
            
            <div class="col-md-6 mb-3" id="edit_image_file_group">
              <label for="edit_image_file">Upload Image</label>
              <input type="file" name="image_file" id="edit_image_file" class="form-control">
              <img src="" alt="" id="selected_image_file" style="height: 100px;">
            </div>
            
            <div class="col-md-6 mb-3">
              <label for="edit_alt">Alt Text</label>
              <input type="text" name="alt" id="edit_alt" class="form-control">
            </div>
            
            <div class="col-md-6 mb-3">
              <label for="edit_sort_order">Sort Order</label>
              <input type="number" name="sort_order" id="edit_sort_order" class="form-control">
            </div>
            <div class="col-md-6 mb-3">
              <label for="edit_status">Status</label>
              <select name="status" id="edit_status" class="form-control">
                <option value="1">Active</option>
                <option value="0">Inactive</option>
              </select>
            </div>
            
          </div>
        </div>
        
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary" onclick="saveEditGallery()">Save</button>
        </div>
      </form>
    </div>
  </div>
</div>




<script>
  function toggleImageInput(prefix) {
    const type = $(`#`+prefix+`_img_type`).val();
    const urlGroup = $(`#`+prefix+`_image_url_group`);
    const fileGroup = $(`#`+prefix+`_image_file_group`);
    
    if (type == '1') {
      urlGroup.show();
      fileGroup.hide();
    } else {
      urlGroup.hide();
      fileGroup.show();
    }
  }
  
  function openCreateGalleryModal() {
    $('#createGalleryModal').modal('show');
  }
  
  function saveCreateGallery() {
    const form = $('#createGalleryForm')[0];
    const formData = new FormData(form);
    
    $.ajax({
      url: postURL,
      type: 'POST',
      data: formData,
      processData: false,  // required for FormData
      contentType: false,  // required for FormData
      success: function(response) {
        if (response.flag) {
          bbdNotify("Success", response.message, "success", "fa fa-check-circle");
          $('#createGalleryModal').modal('hide');
          setTimeout(() => getPage('gallery'), 500);
        } else {
          (response.errors || []).forEach(err =>
          bbdNotify("Error", err, "danger", "fa fa-exclamation-triangle")
          );
        }
      }
    });
  }
  
  function editGallery(id) {
    $.post(postURL, {
      action: 'getGallery',
      gallery_id: id,
      is_ajax: 1,
      jtl_token: $('[name="jtl_token"]').val()
    }, function(response) {
      if (response.flag) {
        const g = response.gallery;
        $('#edit_gallery_id').val(g.id);
        $('#edit_route_id').val(g.route_id);
        $('#edit_image_url').val(g.image_url);
        $('#edit_alt').val(g.alt);
        $('#edit_sort_order').val(g.sort_order);
        $('#edit_status').val(g.status).trigger('change');
        
        // Set image type and show relevant fields
        setTimeout(function(){
          if (g.is_external == "1") {
            $('#edit_img_type').val(1).trigger('change');
          } else {
            $('#edit_img_type').val(0).trigger('change');
          }
          $('#selected_image_file').attr('src', g.image_url);
        }, 1000);
        
        $('#editGalleryModal').modal('show');
      }
    });
  }
  
  function saveEditGallery() {
    const form = $('#editGalleryForm')[0];
    const formData = new FormData(form);
    
    $.ajax({
      url: postURL,
      type: 'POST',
      data: formData,
      processData: false,
      contentType: false,
      success: function(response) {
        if (response.flag) {
          bbdNotify("Success", response.message, "success", "fa fa-check-circle");
          $('#editGalleryModal').modal('hide');
          setTimeout(() => getPage('gallery'), 500);
        } else {
          (response.errors || []).forEach(err =>
          bbdNotify("Error", err, "danger", "fa fa-exclamation-triangle")
          );
        }
      }
    });
  }
  
  function deleteGallery(id) {
    if (!confirm("Are you sure?")) return;
    
    $.post(postURL, {
      action: 'deleteGallery',
      gallery_id: id,
      is_ajax: 1,
      jtl_token: $('[name="jtl_token"]').val()
    }, function(response) {
      if (response.flag) {
        bbdNotify("Success", response.message, "success", "fa fa-check-circle");
        setTimeout(() => getPage('gallery'), 500);
      } else {
        (response.errors || []).forEach(err =>
        bbdNotify("Error", err, "danger", "fa fa-exclamation-triangle")
        );
      }
    });
  }
  
</script>
