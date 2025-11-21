<div class="row">
  <div class="col-md-12">
    <div class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Route Tags</h5>
        <button type="button" class="btn btn-success" onclick="openAddTagModal()">
          <i class="fa fa-plus"></i> Add Tag
        </button>
      </div>
      
      <div class="card-body">
        <table class="table table-hover">
          <thead>
            <tr>
              <th>ID</th>
              <th>Tag</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {foreach $tags as $t}
            <tr>
              <td>{$t.id}</td>
              <td>{$t.name}</td>
              <td>
                <button class="btn btn-primary btn-sm" onclick="editTag({$t.id})">
                  <i class="fa fa-pencil"></i>
                </button>
                <button class="btn btn-danger btn-sm" onclick="deleteTag({$t.id})">
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

<!-- ADD -->
<div class="modal fade" id="addTagModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <form id="addTagForm">
        <div class="modal-header"><h5>Add Tag</h5></div>
        
        <div class="modal-body">
          <input type="hidden" name="action" value="addTag">
          <input type="hidden" name="is_ajax" value="1">
          {$jtl_token}
          
          <label class="mt-2">Name</label>
          <input type="text" name="name" class="form-control">
        </div>
        
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary" onclick="saveTag()">Save</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- EDIT -->
<div class="modal fade" id="editTagModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <form id="editTagForm">
        <div class="modal-header"><h5>Edit Tag</h5></div>
        
        <div class="modal-body">
          <input type="hidden" name="action" value="updateTag">
          <input type="hidden" name="is_ajax" value="1">
          <input type="hidden" name="tag_id" id="edit_tag_id">
          {$jtl_token}
          
          <label class="mt-2">Name</label>
          <input type="text" name="name" id="edit_name" class="form-control">
        </div>
        
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary" onclick="updateTag()">Save</button>
        </div>
      </form>
    </div>
  </div>
</div>

<script>
  function openAddTagModal() {
    $('#addTagModal').modal('show');
  }
  
  function saveTag() {
    $.post(postURL, $('#addTagForm').serialize(), function(res) {
      if (res.flag) {
        bbdNotify("Success", res.message, "success");
        $('#addTagModal').modal('hide');
        setTimeout(() => getPage('tags'), 300);
      }
    });
  }
  
  function editTag(id) {
    $.post(postURL, {
      action: 'getTag',
      tag_id: id,
      is_ajax: 1,
      jtl_token: $('[name="jtl_token"]').val()
    }, function(res) {
      if (res.flag) {
        $('#edit_tag_id').val(res.tag.id);
        $('#edit_name').val(res.tag.name);
        $('#editTagModal').modal('show');
      }
    });
  }
  
  function updateTag() {
    $.post(postURL, $('#editTagForm').serialize(), function(res) {
      if (res.flag) {
        bbdNotify("Success", res.message, "success");
        $('#editTagModal').modal('hide');
        setTimeout(() => getPage('tags'), 300);
      }
      if (
      typeof res.errors !== "undefined" &&
      res.errors.length
      ) {
        res.errors.forEach((error) => {
          bbdNotify("Error", error, "danger", "fa fa-exclamation-triangle");
        });
      }
    });
  }
  
  function deleteTag(id) {
    if (!confirm("Delete this tag?")) return;
    
    $.post(postURL, {
      action: 'deleteTag',
      tag_id: id,
      is_ajax: 1,
      jtl_token: $('[name="jtl_token"]').val()
    }, function(res) {
      if (res.flag) {
        bbdNotify("Success", res.message, "success");
        setTimeout(() => getPage('tags'), 300);
      }
    });
  }
</script>
