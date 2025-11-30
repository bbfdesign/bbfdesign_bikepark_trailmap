<link rel="stylesheet" href="{$adminUrl}css/dataTables.dataTables.css">

<div class="card">
  <div class="card-header d-flex justify-content-between">
    <h5>{$langVars->getTranslation('route_videos', $adminLang)}</h5>

    <button class="btn btn-success" onclick="openCreateVideoModal()">
      <i class="fa fa-plus"></i> {$langVars->getTranslation('add_video', $adminLang)}
    </button>
  </div>

  <div class="card-body">
    <table class="table table-hover" id="videos-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>{$langVars->getTranslation('route', $adminLang)}</th>
          <th>{$langVars->getTranslation('provider', $adminLang)}</th>
          <th>{$langVars->getTranslation('video', $adminLang)}</th>
          <th>{$langVars->getTranslation('status', $adminLang)}</th>
          <th>{$langVars->getTranslation('action', $adminLang)}</th>
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
              <a href="https://www.youtube.com/watch?v={$video.value}" target="_blank">YouTube</a>

            {elseif $video.provider == 'self_hosted'}
              <video src="{$video.value}" controls style="max-height:60px;" autoplay muted></video>

            {elseif $video.provider == 'embedded_code'}
              <a href="javascript:void(0);" class="embedded-video-link"
                 data-video="{$video.value|escape:'html'}">
                {$langVars->getTranslation('embedded_video', $adminLang)}
              </a>
            {else}
              {$video.value}
            {/if}
          </td>

          <td>
            {if $video.status == 1}
              <span class="badge badge-success">
                {$langVars->getTranslation('status_active', $adminLang)}
              </span>
            {else}
              <span class="badge badge-secondary">
                {$langVars->getTranslation('status_inactive', $adminLang)}
              </span>
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


<!-- EMBEDDED VIDEO VIEW MODAL -->
<div class="modal fade" id="embeddedVideoModal" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5>{$langVars->getTranslation('embedded_video', $adminLang)}</h5>
        <button type="button" class="btn-close" data-dismiss="modal"></button>
      </div>

      <div class="modal-body">
        <div id="embeddedVideoContainer"></div>
      </div>
    </div>
  </div>
</div>


<!-- CREATE VIDEO MODAL -->
<div class="modal fade" id="createVideoModal" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">

      <form id="createVideoForm" enctype="multipart/form-data">
        <div class="modal-header">
          <h5>{$langVars->getTranslation('add_new_video', $adminLang)}</h5>
        </div>

        <div class="modal-body">

          <input type="hidden" name="is_ajax" value="1">
          <input type="hidden" name="action" value="addVideo">
          {$jtl_token}

          <div class="row g-3">

            <div class="col-md-6">
              <label>{$langVars->getTranslation('select_route', $adminLang)}</label>
              <select name="route_id" id="create_route_id" class="form-control" required>
                <option value="">
                  {$langVars->getTranslation('select_route', $adminLang)}
                </option>
                {foreach $routes as $route}
                  <option value="{$route.id}">{$route.name} - {$route.external_id}</option>
                {/foreach}
              </select>
            </div>

            <div class="col-md-6">
              <label>{$langVars->getTranslation('provider', $adminLang)}</label>
              <select name="provider" id="create_provider" class="form-control" required>
                <option value="self_hosted">Self Hosted</option>
                <option value="youtube">YouTube</option>
                <option value="video">Video</option>
                <option value="embedded_code">Embedded Code</option>
              </select>
            </div>

            <div class="col-md-6" id="create_self_hosted_file_group" style="display:none;">
              <label>{$langVars->getTranslation('upload_video_file', $adminLang)}</label>
              <input type="file" name="video_file" id="create_video_file" class="form-control">
            </div>

            <div class="col-md-12 mt-3" id="create_video_value_group">
              <label>{$langVars->getTranslation('video_value', $adminLang)}</label>
              <textarea name="value" id="create_value" class="form-control" rows="4"></textarea>
            </div>

            <div class="col-md-6 mt-3">
              <label>{$langVars->getTranslation('status', $adminLang)}</label>
              <select name="status" id="create_status" class="form-control">
                <option value="1">
                  {$langVars->getTranslation('status_active', $adminLang)}
                </option>
                <option value="0">
                  {$langVars->getTranslation('status_inactive', $adminLang)}
                </option>
              </select>
            </div>

          </div>

        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">
            {$langVars->getTranslation('close', $adminLang)}
          </button>
          <button type="button" class="btn btn-primary" onclick="saveCreateVideo()">
            {$langVars->getTranslation('save', $adminLang)}
          </button>
        </div>
      </form>

    </div>
  </div>
</div>


<!-- EDIT VIDEO MODAL -->
<div class="modal fade" id="editVideoModal" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">

      <form id="editVideoForm" enctype="multipart/form-data">
        <div class="modal-header">
          <h5>{$langVars->getTranslation('edit_video', $adminLang)}</h5>
        </div>

        <div class="modal-body">

          <input type="hidden" name="is_ajax" value="1">
          <input type="hidden" name="action" value="updateVideo">
          <input type="hidden" name="video_id" id="edit_video_id">
          {$jtl_token}

          <div class="row g-3">

            <div class="col-md-6">
              <label>{$langVars->getTranslation('select_route', $adminLang)}</label>
              <select name="route_id" id="edit_route_id" class="form-control">
                <option value="">
                  {$langVars->getTranslation('select_route', $adminLang)}
                </option>
                {foreach $routes as $route}
                  <option value="{$route.id}">{$route.name} - {$route.external_id}</option>
                {/foreach}
              </select>
            </div>

            <div class="col-md-6">
              <label>{$langVars->getTranslation('provider', $adminLang)}</label>
              <select name="provider" id="edit_provider" class="form-control">
                <option value="self_hosted">Self Hosted</option>
                <option value="youtube">YouTube</option>
                <option value="vimeo">Vimeo</option>
                <option value="embedded_code">Embedded Code</option>
              </select>
            </div>

            <div class="col-md-6 mt-3" id="edit_self_hosted_file_group" style="display:none;">
              <label>{$langVars->getTranslation('upload_video_file', $adminLang)}</label>
              <input type="file" name="video_file" id="edit_video_file" class="form-control">
            </div>

            <div class="col-md-12 mt-3" id="edit_video_value_group">
              <label>{$langVars->getTranslation('video_value', $adminLang)}</label>
              <textarea name="value" id="edit_value" class="form-control" rows="4"></textarea>
            </div>

            <div class="col-md-6 mt-3">
              <label>{$langVars->getTranslation('status', $adminLang)}</label>
              <select name="status" id="edit_status" class="form-control">
                <option value="1">
                  {$langVars->getTranslation('status_active', $adminLang)}
                </option>
                <option value="0">
                  {$langVars->getTranslation('status_inactive', $adminLang)}
                </option>
              </select>
            </div>

          </div>

        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">
            {$langVars->getTranslation('close', $adminLang)}
          </button>
          <button class="btn btn-primary" type="button" onclick="saveEditVideo()">
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


  // Embedded Video Modal
  $(document).on('click', '.embedded-video-link', function () {
    var code = $(this).data('video');
    $('#embeddedVideoContainer').html(code);
    $('#embeddedVideoModal').modal('show');
  });

  $('#embeddedVideoModal').on('hidden.bs.modal', function () {
    $('#embeddedVideoContainer').html('');
  });


  // Provider field logic
  function toggleProviderFields(prefix = '') {
    const provider = $('#' + prefix + 'provider').val();

    if (provider === 'self_hosted') {
      $('#' + prefix + 'self_hosted_file_group').show();
      $('#' + prefix + 'video_value_group').hide();
      $('#' + prefix + 'value').prop('required', false);
      $('#' + prefix + 'video_file').prop('required', true);

    } else {
      $('#' + prefix + 'self_hosted_file_group').hide();
      $('#' + prefix + 'video_value_group').show();
      $('#' + prefix + 'value').prop('required', true);
      $('#' + prefix + 'video_file').prop('required', false);
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
  });


  // CREATE VIDEO
  function openCreateVideoModal() {
    $('#createVideoModal').modal('show');
  }

  function saveCreateVideo() {
    const formData = new FormData($('#createVideoForm')[0]);

    $.ajax({
      url: postURL,
      type: 'POST',
      data: formData,
      processData: false,
      contentType: false,
      success: function (res) {
        if (res.flag) {
          bbdNotify("Success", res.message, "success");
          $('#createVideoModal').modal('hide');
          setTimeout(() => getPage('videos'), 500);
        }
        else {
          (res.errors || []).forEach(err =>
            bbdNotify("Error", err, "danger")
          );
        }
      }
    });
  }


  // EDIT VIDEO
  function editVideo(id) {

    $.post(postURL, {
      action: 'getVideo',
      video_id: id,
      is_ajax: 1,
      jtl_token: $('[name="jtl_token"]').val()
    }, function (res) {

      if (res.flag) {
        const v = res.video;

        $('#edit_video_id').val(v.id);
        $('#edit_route_id').val(v.route_id);
        $('#edit_provider').val(v.provider);
        $('#edit_value').val(v.value);
        $('#edit_status').val(v.status);

        setTimeout(() => {
          toggleProviderFields('edit_');
        }, 200);

        $('#editVideoModal').modal('show');
      }

    });
  }


  // SAVE EDIT VIDEO
  function saveEditVideo() {
    const formData = new FormData($('#editVideoForm')[0]);

    $.ajax({
      url: postURL,
      type: 'POST',
      data: formData,
      processData: false,
      contentType: false,
      success: function (res) {
        if (res.flag) {
          bbdNotify("Success", res.message, "success");
          $('#editVideoModal').modal('hide');
          setTimeout(() => getPage('videos'), 500);
        }
        else {
          (res.errors || []).forEach(err =>
            bbdNotify("Error", err, "danger")
          );
        }
      }
    });
  }


  // DELETE VIDEO
  function deleteVideo(id) {
    if (!confirm("{$langVars->getTranslation('confirm_delete_video', $adminLang)}")) return;

    $.post(postURL, {
      action: 'deleteVideo',
      video_id: id,
      is_ajax: 1,
      jtl_token: $('[name="jtl_token"]').val()
    }, function (res) {

      if (res.flag) {
        bbdNotify("Success", res.message, "success");
        setTimeout(() => getPage('videos'), 500);
      }
      else {
        (res.errors || []).forEach(err =>
          bbdNotify("Error", err, "danger")
        );
      }

    });

  }

</script>
