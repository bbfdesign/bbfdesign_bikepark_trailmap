<link rel="stylesheet" href="{$adminUrl}css/dataTables.dataTables.css">

<div class="row">
  <div class="col-md-12">
    <div class="card">

      <div class="card-header bbf-card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">{$langVars->getTranslation('routes', $adminLang)}</h5>

        <button type="button" class="btn btn-success" onclick="openCreateRouteModal()">
          <i class="fa fa-plus"></i>
          {$langVars->getTranslation('create_new_route', $adminLang)}
        </button>
      </div>

      <div class="card-body">

        <!-- FILTERS -->
        <div class="row mb-3">
          <div class="col-md-3">
            <label for="filterDifficulty">
              {$langVars->getTranslation('filter_difficulty', $adminLang)}
            </label>
            <select id="filterDifficulty" class="form-control">
              <option value="">
                {$langVars->getTranslation('all', $adminLang)}
              </option>
              {foreach $difficultyLevels as $key => $value}
                <option value="{$value}">{$value}</option>
              {/foreach}
            </select>
          </div>

          <div class="col-md-3">
            <label for="filterStatus">
              {$langVars->getTranslation('filter_status', $adminLang)}
            </label>
            <select id="filterStatus" class="form-control">
              <option value="">
                {$langVars->getTranslation('all', $adminLang)}
              </option>
              {foreach $statuses as $key => $value}
                <option value="{$value}">{$value}</option>
              {/foreach}
            </select>
          </div>
        </div>

        <!-- TABLE -->
        <div class="table-responsive">
          <table class="table table-hovered" id="routes-table">
            <thead class="thead-sticky">
              <tr>
                <th>ID</th>
                <th>{$langVars->getTranslation('name', $adminLang)}</th>
                <th>{$langVars->getTranslation('external_id', $adminLang)}</th>
                <th>{$langVars->getTranslation('status', $adminLang)}</th>
                <th>{$langVars->getTranslation('difficulty', $adminLang)}</th>
                <th>{$langVars->getTranslation('sort_order', $adminLang)}</th>
                <th>{$langVars->getTranslation('created_at', $adminLang)}</th>
                <th>{$langVars->getTranslation('action', $adminLang)}</th>
              </tr>
            </thead>

            <tbody>
              {foreach $routes as $route}
              <tr>
                <td>{$route.id}</td>
                <td>{$route.name}</td>
                <td>{$route.external_id}</td>
                <td>{$route.status}</td>
                <td>{$difficultyLevels[$route.difficulty]|default:$route.difficulty}</td>
                <td>{$route.sequence}</td>
                <td>{$route.created_at|date_format:"%d-%m-%Y %H:%M"}</td>

                <td>
                  <button class="btn btn-sm btn-primary" onclick="editRoute({$route.id})">
                    <i class="fa fa-pencil"></i>
                  </button>

                  <button class="btn btn-sm btn-danger" onclick="deleteRoute({$route.id})">
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
</div>

<!-- ADD ROUTE MODAL -->
<div class="modal fade" id="createRouteModal" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <form id="createRouteForm">

        <div class="modal-header">
          <h5 class="modal-title">
            {$langVars->getTranslation('create_new_route', $adminLang)}
          </h5>
        </div>

        <div class="modal-body">

          <input type="hidden" name="is_ajax" value="1">
          <input type="hidden" name="action" value="addRoute">
          {$jtl_token}

          <div class="row g-3">

            <div class="col-md-6">
              <label>{$langVars->getTranslation('name', $adminLang)}</label>
              <input type="text" name="name" class="form-control" required>
            </div>

            <div class="col-md-6">
              <label>{$langVars->getTranslation('external_id', $adminLang)}</label>
              <input type="text" name="external_id" class="form-control" required>
            </div>

            <div class="col-md-6">
              <label>{$langVars->getTranslation('difficulty', $adminLang)}</label>
              <select name="difficulty" class="form-control" required>
                {foreach $difficultyLevels as $key => $value}
                  <option value="{$key}">{$value}</option>
                {/foreach}
              </select>
            </div>

            <div class="col-md-6">
              <label>{$langVars->getTranslation('status', $adminLang)}</label>
              <select name="status" class="form-control" required>
                {foreach $statuses as $key => $value}
                  <option value="{$key}">{$value}</option>
                {/foreach}
              </select>
            </div>

            <div class="col-md-6">
              <label>{$langVars->getTranslation('sort_order', $adminLang)}</label>
              <input type="number" name="sequence" class="form-control" min="1">
            </div>

            <div class="col-md-12">
              <label>{$langVars->getTranslation('short_description', $adminLang)}</label>
              <textarea name="short_description" class="form-control tinymce"></textarea>
            </div>

            <div class="col-md-12">
              <label>{$langVars->getTranslation('description', $adminLang)}</label>
              <textarea name="description" class="form-control tinymce"></textarea>
            </div>

            <div class="col-md-12">
              <label>{$langVars->getTranslation('warnings', $adminLang)}</label>
              <textarea name="warning" class="form-control"></textarea>
            </div>

            <div class="col-md-12">
              <label>{$langVars->getTranslation('tags', $adminLang)}</label>
              <select name="tags[]" id="tagsSelect" class="form-control" multiple>
                {foreach $tags as $tag}
                  <option value="{$tag.id}">{$tag.name}</option>
                {/foreach}
              </select>

              <small class="text-muted">
                {$langVars->getTranslation('add_tag', $adminLang)}
              </small>
            </div>

          </div>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">
            {$langVars->getTranslation('close', $adminLang)}
          </button>
          <button type="button" class="btn btn-primary" onclick="saveCreateRouteForm()">
            {$langVars->getTranslation('save', $adminLang)}
          </button>
        </div>

      </form>
    </div>
  </div>
</div>

<!-- EDIT ROUTE MODAL -->
<div class="modal fade" id="editRouteModal" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <form id="editRouteForm">

        <div class="modal-header">
          <h5 class="modal-title">
            {$langVars->getTranslation('route', $adminLang)}
          </h5>
        </div>

        <div class="modal-body">

          <input type="hidden" name="is_ajax" value="1">
          <input type="hidden" name="action" value="updateRoute">
          <input type="hidden" name="route_id" id="edit_route_id">
          {$jtl_token}

          <div class="row g-3">

            <div class="col-md-6">
              <label>{$langVars->getTranslation('name', $adminLang)}</label>
              <input type="text" name="name" id="edit_name" class="form-control" required>
            </div>

            <div class="col-md-6">
              <label>{$langVars->getTranslation('external_id', $adminLang)}</label>
              <input type="text" name="external_id" id="edit_external_id" class="form-control" required>
            </div>

            <div class="col-md-6">
              <label>{$langVars->getTranslation('difficulty', $adminLang)}</label>
              <select name="difficulty" id="edit_difficulty" class="form-control" required>
                {foreach $difficultyLevels as $key => $value}
                  <option value="{$key}">{$value}</option>
                {/foreach}
              </select>
            </div>

            <div class="col-md-6">
              <label>{$langVars->getTranslation('status', $adminLang)}</label>
              <select name="status" id="edit_status" class="form-control" required>
                {foreach $statuses as $key => $value}
                  <option value="{$key}">{$value}</option>
                {/foreach}
              </select>
            </div>

            <div class="col-md-6">
              <label>{$langVars->getTranslation('sort_order', $adminLang)}</label>
              <input type="number" name="sequence" id="edit_sequence" class="form-control" min="1">
            </div>

            <div class="col-md-12">
              <label>{$langVars->getTranslation('short_description', $adminLang)}</label>
              <textarea name="short_description" id="edit_short_description" class="form-control tinymce"></textarea>
            </div>

            <div class="col-md-12">
              <label>{$langVars->getTranslation('description', $adminLang)}</label>
              <textarea name="description" id="edit_description" class="form-control tinymce"></textarea>
            </div>

            <div class="col-md-12">
              <label>{$langVars->getTranslation('warnings', $adminLang)}</label>
              <textarea name="warning" id="edit_warning" class="form-control"></textarea>
            </div>

            <div class="col-md-12">
              <label>{$langVars->getTranslation('tags', $adminLang)}</label>
              <select name="tags[]" id="editTagsSelect" class="form-control" multiple>
                {foreach $tags as $tag}
                  <option value="{$tag.id}">{$tag.name}</option>
                {/foreach}
              </select>
              <small class="text-muted">
                {$langVars->getTranslation('add_tag', $adminLang)}
              </small>
            </div>

          </div>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">
            {$langVars->getTranslation('close', $adminLang)}
          </button>
          <button type="button" class="btn btn-primary" onclick="saveEditRouteForm()">
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
    var table = $('#routes-table').DataTable({
      "language": datatableLangVariables,
      "order": [[0, "desc"]]
    });

    // Filter by Difficulty dropdown
    $('#filterDifficulty').on('change', function () {
      var selected = $.fn.dataTable.util.escapeRegex($(this).val());
      if (selected) {
        table.column(4).search('^' + selected + '$', true, false).draw();
      } else {
        table.column(4).search('').draw();
      }
    });

    // Filter by Status dropdown
    $('#filterStatus').on('change', function () {
      var selected = $.fn.dataTable.util.escapeRegex($(this).val());
      if (selected) {
        table.column(3).search('^' + selected + '$', true, false).draw();
      } else {
        table.column(3).search('').draw();
      }
    });

    $('#tagsSelect').select2({
      tags: true,
      tokenSeparators: [','],
      placeholder: "{$langVars->getTranslation('select_or_create_tags', $adminLang)}",
      width: '100%',
      dropdownParent: $('#createRouteModal')
    });

    $('#editTagsSelect').select2({
      tags: true,
      tokenSeparators: [','],
      placeholder: "{$langVars->getTranslation('select_or_create_tags', $adminLang)}",
      width: '100%',
      dropdownParent: $('#editRouteModal')
    });
  });

  function openCreateRouteModal() {
    setTimeout(() => {
      initTinyMCE();
    }, 500);
    $('#createRouteModal').modal('show');
  }

  function saveCreateRouteForm() {
    tinymce.triggerSave();
    $.ajax({
      url: postURL,
      type: 'POST',
      data: $('#createRouteForm').serialize(),
      success: function (response) {
        if (response.flag) {
          bbdNotify("Success", response.message, "success", "fa fa-check-circle");
          $('#createRouteModal').modal('hide');
          setTimeout(() => getPage('routes'), 1000);
        } else {
          (response.errors || []).forEach(error =>
            bbdNotify("Error", error, "danger", "fa fa-exclamation-triangle")
          );
        }
      },
      error: function () {
        bbdNotify("Error", "An error occurred while saving.", "danger", "fa fa-exclamation-triangle");
      }
    });
  }

  function editRoute(routeId) {
    $.ajax({
      url: postURL,
      method: "POST",
      data: {
        action: 'getRoute',
        route_id: routeId,
        is_ajax: 1,
        jtl_token: $('[name="jtl_token"]').val()
      },
      success: function (response) {
        if (response.flag && response.route) {
          const r = response.route;
          $('#edit_route_id').val(r.id);
          $('#edit_name').val(r.name);
          $('#edit_external_id').val(r.external_id);
          $('#edit_difficulty').val(r.difficulty);
          $('#edit_status').val(r.status);
          $('#edit_sequence').val(r.sequence);
          $('#edit_warning').val(r.warning);
          $('#edit_short_description').val(r.short_description);
          $('#edit_description').val(r.description);
          if (r.tags && Array.isArray(r.tags)) {
            const tagValues = r.tags.map(tag => tag.id.toString());
            $("#editTagsSelect option").prop("selected", false);
            tagValues.forEach(value => {
              $(`#editTagsSelect option[value="`+value+`"]`).prop("selected", true);
            });
            $("#editTagsSelect").trigger("change");
          } else {
            $("#editTagsSelect").val(null).trigger("change");
          }
          $('#editRouteModal').modal('show');
          setTimeout(() => {
            initTinyMCE();
          }, 500);

        } else {
          bbdNotify("Error", "Route not found.", "danger", "fa fa-exclamation-triangle");
        }
      }
    });
  }

  function saveEditRouteForm() {
    tinymce.triggerSave();
    
    $.ajax({
      url: postURL,
      type: 'POST',
      data: $('#editRouteForm').serialize(),
      success: function (response) {
        if (response.flag) {
          bbdNotify("Success", response.message, "success", "fa fa-check-circle");
          $('#editRouteModal').modal('hide');
          setTimeout(() => getPage('routes'), 1000);
        } else {
          (response.errors || []).forEach(error =>
            bbdNotify("Error", error, "danger", "fa fa-exclamation-triangle")
          );
        }
      },
      error: function () {
        bbdNotify("Error", "An error occurred while saving.", "danger", "fa fa-exclamation-triangle");
      }
    });
  }

  function deleteRoute(routeId) {
   if (!confirm("{$langVars->getTranslation('delete_route_confirm', $adminLang)}")) {
      $.ajax({
        url: postURL,
        type: 'POST',
        data: {
          jtl_token: $('[name="jtl_token"]').val(),
          is_ajax: 1,
          route_id: routeId,
          action: 'deleteRoute'
        },
        success: function (response) {
          if (response.flag) {
            bbdNotify("Success", response.message, "success", "fa fa-check-circle");
            setTimeout(() => getPage('routes'), 1000);
          } else {
            (response.errors || []).forEach(error =>
              bbdNotify("Error", error, "danger", "fa fa-exclamation-triangle")
            );
          }
        },
        error: function () {
          bbdNotify("Error", "An error occurred while deleting.", "danger", "fa fa-exclamation-triangle");
        }
      });
    }
  }
</script>
