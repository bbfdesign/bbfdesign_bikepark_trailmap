<link rel="stylesheet" href="{$adminUrl}css/dataTables.dataTables.css">

<div class="card">
  <div class="card-header d-flex justify-content-between">
    <h5>Route Videos</h5>
    <button class="btn btn-success" onclick="openCreateVideoModal()">
      <i class="fa fa-plus"></i> Add Video
    </button>
  </div>

  <div class="card-body">
    <table class="table table-hover" id="videos-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Route</th>
          <th>Provider</th>
          <th>Video</th>
          <th>Status</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody>
        {foreach $videos as $video}
        <tr>
          <td>{$video.id}</td>
          <td>{$video.name}</td>
          <td>{$video.provider|capitalize}</td>
          <td>
            {if $video.provider == 'youtube'}
            <a href="https://www.youtube.com/watch?v={$video.value}" target="_blank">YouTube Video</a>
            {elseif $video.provider == 'self_hosted'}
            <video src="{$video.value}" controls style="max-height:60px;" autoplay muted></video>
            {elseif $video.provider == 'embedded_code'}
            <a href="javascript:void(0);" class="embedded-video-link" data-video="{$video.value|escape:'html'}">View Embedded Video</a>
            {else}
            {$video.value}
            {/if}
          </td>
          <td>
            {if $video.status == 1}
            <span class="badge badge-success">Active</span>
            {else}
            <span class="badge badge-secondary">Inactive</span>
            {/if}
          </td>
          <td>
            <button class="btn btn-sm btn-primary" onclick="editVideo({$video.id})">
              <i class="fa fa-pencil"></i>
            </button>
            <button class="btn btn-sm btn-danger" onclick="deleteVideo({$video.id})">
              <i class="fa fa-trash"></i>
            </button>
          </td>
        </tr>
        {/foreach}
      </tbody>
    </table>
  </div>
</div>

<div class="modal fade" id="embeddedVideoModal" tabindex="-1" aria-labelledby="embeddedVideoModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="embeddedVideoModalLabel">Embedded Video</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <div id="embeddedVideoContainer"></div>
      </div>
    </div>
  </div>
</div>

<!-- Create Video Modal -->
<div class="modal fade" id="createVideoModal" tabindex="-1" aria-labelledby="createVideoModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <form id="createVideoForm" enctype="multipart/form-data">
        <div class="modal-header">
          <h5 class="modal-title" id="createVideoModalLabel">Add New Video</h5>
        </div>
        <div class="modal-body">
          <input type="hidden" name="is_ajax" value="1" />
          <input type="hidden" name="action" value="addVideo" />
          {$jtl_token}

          <div class="row g-3">
            <div class="col-md-6">
              <label for="create_route_id">Select Route</label>
              <select name="route_id" id="create_route_id" class="form-control" required>
                <option value="">Select Route</option>
                {foreach from=$routes item=route}
                <option value="{$route.id}">{$route.name} - {$route.external_id}</option>
                {/foreach}
              </select>
            </div>

            <div class="col-md-6">
              <label for="create_provider">Provider</label>
              <select name="provider" id="create_provider" class="form-control" required>
                <option value="self_hosted">Self Hosted</option>
                <option value="youtube">YouTube</option>
                <option value="video">Video</option>
                <option value="embedded_code">Embedded Code</option>
              </select>
            </div>

            <div class="col-md-6" id="create_self_hosted_file_group" style="display:none;">
              <label for="create_video_file">Upload Video File</label>
              <input type="file" name="video_file" id="create_video_file" class="form-control" accept="video/*" />
            </div>

            <div class="col-md-12 mt-3" id="create_video_value_group">
              <label for="create_value">Video URL / Embed Code / File Path</label>
              <textarea name="value" id="create_value" class="form-control" rows="4" placeholder="Paste link or embed code here"></textarea>
            </div>

            <div class="col-md-6 mt-3">
              <label for="create_status">Status</label>
              <select name="status" id="create_status" class="form-control" required>
                <option value="1">Active</option>
                <option value="0">Inactive</option>
              </select>
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary" onclick="saveCreateVideo()">Save</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Edit Video Modal -->
<div class="modal fade" id="editVideoModal" tabindex="-1" aria-labelledby="editVideoModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <form id="editVideoForm" enctype="multipart/form-data">
        <div class="modal-header">
          <h5 class="modal-title" id="editVideoModalLabel">Edit Video</h5>
        </div>
        <div class="modal-body">
          <input type="hidden" name="is_ajax" value="1" />
          <input type="hidden" name="action" value="updateVideo" />
          <input type="hidden" name="video_id" id="edit_video_id" />
          {$jtl_token}

          <div class="row g-3">
            <div class="col-md-6">
              <label for="edit_route_id">Select Route</label>
              <select name="route_id" id="edit_route_id" class="form-control" required>
                <option value="">Select Route</option>
                {foreach from=$routes item=route}
                <option value="{$route.id}">{$route.name} - {$route.external_id}</option>
                {/foreach}
              </select>
            </div>

            <div class="col-md-6">
              <label for="edit_provider">Provider</label>
              <select name="provider" id="edit_provider" class="form-control" required>
                <option value="self_hosted">Self Hosted</option>
                <option value="youtube">YouTube</option>
                <option value="vimeo">Vimeo</option>
                <option value="embedded_code">Embedded Code</option>
              </select>
            </div>

            <div class="col-md-6 mt-3" id="edit_self_hosted_file_group" style="display:none;">
              <label for="edit_video_file">Upload Video File</label>
              <input type="file" name="video_file" id="edit_video_file" class="form-control" accept="video/*" />
            </div>

            <div class="col-md-12 mt-3" id="edit_video_value_group">
              <label for="edit_value">Youtube ID / Vimeo ID / Embed Code</label>
              <textarea name="value" id="edit_value" class="form-control" rows="4" placeholder="Paste ID or embed code here"></textarea>
            </div>

            <div class="col-md-6 mt-3">
              <label for="edit_status">Status</label>
              <select name="status" id="edit_status" class="form-control" required>
                <option value="1">Active</option>
                <option value="0">Inactive</option>
              </select>
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary" onclick="saveEditVideo()">Save</button>
        </div>
      </form>
    </div>
  </div>
</div>

<script>
  $(document).on('click', '.embedded-video-link', function () {
    var videoEmbedCode = $(this).data('video');
    $('#embeddedVideoContainer').html(videoEmbedCode);
    $('#embeddedVideoModal').modal('show');
  });

  $('#embeddedVideoModal').on('hidden.bs.modal', function () {
    $('#embeddedVideoContainer').html('');
  });

  function toggleProviderFields(prefix = '') {
    const provider = $(`#`+prefix+`provider`).val();
    if (provider === 'self_hosted') {
      $(`#`+prefix+`self_hosted_file_group`).show();
      $(`#`+prefix+`video_value_group`).hide();
      $(`#`+prefix+`value`).prop('required', false);
      $(`#`+prefix+`video_file`).prop('required', true);
    } else {
      $(`#`+prefix+`self_hosted_file_group`).hide();
      $(`#`+prefix+`video_value_group`).show();
      $(`#`+prefix+`value`).prop('required', true);
      $(`#`+prefix+`video_file`).prop('required', false);
    }
  }

  $(document).ready(function () {
    toggleProviderFields('create_');
    $('#create_provider').on('change', function () {
      toggleProviderFields('create_');
    });

    $('#edit_provider').on('change', function () {
      toggleProviderFields('edit_');
    });

    // Open Create Modal
    window.openCreateVideoModal = function () {
      $('#createVideoModal').modal('show');
    };

    // Save Create Video
    window.saveCreateVideo = function () {
      const form = $('#createVideoForm')[0];
      const formData = new FormData(form);

      $.ajax({
        url: postURL,
        type: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        success: function (response) {
          if (response.flag) {
            bbdNotify("Success", response.message, "success", "fa fa-check-circle");
            $('#createVideoModal').modal('hide');
            setTimeout(() => getPage('videos'), 500);
          } else {
            (response.errors || []).forEach(error => {
              bbdNotify("Error", error, "danger", "fa fa-exclamation-triangle");
            });
          }
        }
      });
    };

    // Edit Video
    window.editVideo = function (id) {
      $.post(postURL, {
        action: 'getVideo',
        video_id: id,
        is_ajax: 1,
        jtl_token: $('[name="jtl_token"]').val()
      }, function (response) {
        if (response.flag && response.video) {
          const v = response.video;
          $('#edit_video_id').val(v.id);
          $('#edit_route_id').val(v.route_id);
          $('#edit_provider').val(v.provider);
          $('#edit_value').val(v.value);
          $('#edit_status').val(v.status).trigger('change');
          toggleProviderFields('edit_');
          $('#editVideoModal').modal('show');
        } else {
          bbdNotify("Error", "Video not found.", "danger", "fa fa-exclamation-triangle");
        }
      });
    };

    // Save Edit Video
    window.saveEditVideo = function () {
      const form = $('#editVideoForm')[0];
      const formData = new FormData(form);

      $.ajax({
        url: postURL,
        type: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        success: function (response) {
          if (response.flag) {
            bbdNotify("Success", response.message, "success", "fa fa-check-circle");
            $('#editVideoModal').modal('hide');
            setTimeout(() => getPage('videos'), 500);
          } else {
            (response.errors || []).forEach(error => {
              bbdNotify("Error", error, "danger", "fa fa-exclamation-triangle");
            });
          }
        }
      });
    };

    // Delete Video
    window.deleteVideo = function (id) {
      if (!confirm("Are you sure you want to delete this video?")) return;

      $.post(postURL, {
        action: 'deleteVideo',
        video_id: id,
        is_ajax: 1,
        jtl_token: $('[name="jtl_token"]').val()
      }, function (response) {
        if (response.flag) {
          bbdNotify("Success", response.message, "success", "fa fa-check-circle");
          setTimeout(() => getPage('videos'), 500);
        } else {
          (response.errors || []).forEach(error => {
            bbdNotify("Error", error, "danger", "fa fa-exclamation-triangle");
          });
        }
      });
    };
  });
</script>
