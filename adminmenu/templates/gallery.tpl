<link rel="stylesheet" href="{$adminUrl}css/dataTables.dataTables.css">
<div class="card">
  <div class="card-header d-flex justify-content-between">
    <h5>{$langVars->getTranslation('route_gallery', $adminLang)}</h5>

    <button class="btn btn-success" onclick="openCreateGalleryModal()">
      <i class="fa fa-plus"></i>
      {$langVars->getTranslation('add_image', $adminLang)}
    </button>
  </div>
  
  <div class="card-body">
    <table class="table table-hover" id="gallery-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>{$langVars->getTranslation('route', $adminLang)}</th>
          <th>{$langVars->getTranslation('image', $adminLang)}</th>
          <th>{$langVars->getTranslation('alt_text', $adminLang)}</th>
          <th>{$langVars->getTranslation('sort_order', $adminLang)}</th>
          <th>{$langVars->getTranslation('action', $adminLang)}</th>
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
          <h5>{$langVars->getTranslation('create_gallery_item', $adminLang)}</h5>
        </div>

        <div class="modal-body">
          <input type="hidden" name="is_ajax" value="1">
          <input type="hidden" name="action" value="addGallery">
          {$jtl_token}
          
          <div class="row">

            <div class="col-md-6 mb-3">
              <label>{$langVars->getTranslation('route', $adminLang)}</label>
              <select name="route_id" id="create_route_id" class="form-control">
                <option value="">
                  {$langVars->getTranslation('select_route', $adminLang)}
                </option>
                {foreach $routes as $route}
                <option value="{$route.id}">{$route.name} - {$route.external_id}</option>
                {/foreach}
              </select>
            </div>
            
            <div class="col-md-6 mb-3">
              <label>{$langVars->getTranslation('image_source', $adminLang)}</label>
              <select name="is_external" id="create_img_type" class="form-control" onchange="toggleImageInput('create')">
                <option value="0">{$langVars->getTranslation('upload_image', $adminLang)}</option>
                <option value="1">{$langVars->getTranslation('external_url', $adminLang)}</option>
              </select>
            </div>
            
            <div class="col-md-6 mb-3" id="create_image_url_group" style="display:none;">
              <label>{$langVars->getTranslation('image_url', $adminLang)}</label>
              <input type="text" name="image_url" id="create_image_url" class="form-control">
            </div>
            
            <div class="col-md-6 mb-3" id="create_image_file_group">
              <label>{$langVars->getTranslation('upload_image', $adminLang)}</label>
              <input type="file" name="image_file" id="create_image_file" class="form-control">
            </div>
            
            <div class="col-md-6 mb-3">
              <label>{$langVars->getTranslation('alt_text', $adminLang)}</label>
              <input type="text" name="alt" id="create_alt" class="form-control">
            </div>
            
            <div class="col-md-6 mb-3">
              <label>{$langVars->getTranslation('sort_order', $adminLang)}</label>
              <input type="number" name="sort_order" id="create_sort_order" class="form-control">
            </div>

            <div class="col-md-6 mb-3">
              <label>{$langVars->getTranslation('status', $adminLang)}</label>
              <select name="status" id="status" class="form-control">
                <option value="1">{$langVars->getTranslation('active', $adminLang)}</option>
                <option value="0">{$langVars->getTranslation('inactive', $adminLang)}</option>
              </select>
            </div>

          </div>
        </div>
        
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">
            {$langVars->getTranslation('close', $adminLang)}
          </button>
          <button type="button" class="btn btn-primary" onclick="saveCreateGallery()">
            {$langVars->getTranslation('save', $adminLang)}
          </button>
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
          <h5>{$langVars->getTranslation('edit_gallery_item', $adminLang)}</h5>
        </div>

        <div class="modal-body">
          <input type="hidden" name="is_ajax" value="1">
          <input type="hidden" name="action" value="updateGallery">
          <input type="hidden" name="gallery_id" id="edit_gallery_id">
          {$jtl_token}
          
          <div class="row">

            <div class="col-md-6 mb-3">
              <label>{$langVars->getTranslation('route', $adminLang)}</label>
              <select name="route_id" id="edit_route_id" class="form-control">
                <option value="">
                  {$langVars->getTranslation('select_route', $adminLang)}
                </option>
                {foreach $routes as $route}
                <option value="{$route.id}">{$route.name} - {$route.external_id}</option>
                {/foreach}
              </select>
            </div>
            
            <div class="col-md-6 mb-3">
              <label>{$langVars->getTranslation('image_source', $adminLang)}</label>
              <select name="is_external" id="edit_img_type" class="form-control" onchange="toggleImageInput('edit')">
                <option value="0">{$langVars->getTranslation('upload_image', $adminLang)}</option>
                <option value="1">{$langVars->getTranslation('external_url', $adminLang)}</option>
              </select>
            </div>
            
            <div class="col-md-6 mb-3" id="edit_image_url_group" style="display:none;">
              <label>{$langVars->getTranslation('image_url', $adminLang)}</label>
              <input type="text" name="image_url" id="edit_image_url" class="form-control">
            </div>
            
            <div class="col-md-6 mb-3" id="edit_image_file_group">
              <label>{$langVars->getTranslation('upload_image', $adminLang)}</label>
              <input type="file" name="image_file" id="edit_image_file" class="form-control">
              <img src="" alt="" id="selected_image_file" style="height: 100px;">
            </div>
            
            <div class="col-md-6 mb-3">
              <label>{$langVars->getTranslation('alt_text', $adminLang)}</label>
              <input type="text" name="alt" id="edit_alt" class="form-control">
            </div>
            
            <div class="col-md-6 mb-3">
              <label>{$langVars->getTranslation('sort_order', $adminLang)}</label>
              <input type="number" name="sort_order" id="edit_sort_order" class="form-control">
            </div>

            <div class="col-md-6 mb-3">
              <label>{$langVars->getTranslation('status', $adminLang)}</label>
              <select name="status" id="edit_status" class="form-control">
                <option value="1">{$langVars->getTranslation('active', $adminLang)}</option>
                <option value="0">{$langVars->getTranslation('inactive', $adminLang)}</option>
              </select>
            </div>
            
          </div>
        </div>
        
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">
            {$langVars->getTranslation('close', $adminLang)}
          </button>
          <button type="button" class="btn btn-primary" onclick="saveEditGallery()">
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
    var table = $('#videos-table').DataTable({
      "language": datatableLangVariables,
      "order": [[0, "desc"]]
    });
  });

  function toggleImageInput(prefix) {
    const type = $('#' + prefix + '_img_type').val();
    const urlGroup = $('#' + prefix + '_image_url_group');
    const fileGroup = $('#' + prefix + '_image_file_group');
    
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
    const formData = new FormData($('#createGalleryForm')[0]);
    
    $.ajax({
      url: postURL,
      type: 'POST',
      data: formData,
      processData: false,
      contentType: false,
      success: function(res) {
        if (res.flag) {
          bbdNotify("Success", res.message, "success");
          $('#createGalleryModal').modal('hide');
          setTimeout(() => getPage('gallery'), 500);
        } else {
          (res.errors || []).forEach(err =>
            bbdNotify("Error", err, "danger")
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
    }, function(res) {
      if (res.flag) {

        const g = res.gallery;

        $('#edit_gallery_id').val(g.id);
        $('#edit_route_id').val(g.route_id);
        $('#edit_image_url').val(g.image_url);
        $('#edit_alt').val(g.alt);
        $('#edit_sort_order').val(g.sort_order);
        $('#edit_status').val(g.status);

        setTimeout(() => {
          $('#edit_img_type').val(g.is_external).trigger('change');
          $('#selected_image_file').attr('src', g.image_url);
        }, 300);

        $('#editGalleryModal').modal('show');
      }
    });
  }
  
  function saveEditGallery() {
    const formData = new FormData($('#editGalleryForm')[0]);
    
    $.ajax({
      url: postURL,
      type: 'POST',
      data: formData,
      processData: false,
      contentType: false,
      success: function(res) {
        if (res.flag) {
          bbdNotify("Success", res.message, "success");
          $('#editGalleryModal').modal('hide');
          setTimeout(() => getPage('gallery'), 500);
        } else {
          (res.errors || []).forEach(err =>
            bbdNotify("Error", err, "danger")
          );
        }
      }
    });
  }
  
  function deleteGallery(id) {
    if (!confirm("{$langVars->getTranslation('delete_gallery_confirm', $adminLang)}")) return;
    
    $.post(postURL, {
      action: 'deleteGallery',
      gallery_id: id,
      is_ajax: 1,
      jtl_token: $('[name="jtl_token"]').val()
    }, function(res) {
      if (res.flag) {
        bbdNotify("Success", res.message, "success");
        setTimeout(() => getPage('gallery'), 500);
      } else {
        (res.errors || []).forEach(err =>
          bbdNotify("Error", err, "danger")
        );
      }
    });
  }
</script>
