$(document).ready(function () {
  getPage("setting");
});

$(document).on("change", ".parent-setting", function () {
  $(this).closest("form").find(".save-btn").click();
});

$(document).on("click", "a.nav-link", function () {
  if (typeof bootstrap !== "undefined") {
    var tab = new bootstrap.Tab(this);
    tab.show();
  } else {
    $(this).tab("show");
  }
});

function getPage(page, type = "page") {
  var postsData = {
    action: "getPage",
    page: page,
    is_ajax: 1,
    jtl_token: document.querySelector('[name="jtl_token"]').value,
  };
  let response = ajaxPost(postsData);
  if (
    response &&
    typeof response.errors !== "undefined" &&
    response.errors.length
  ) {
    response.errors.forEach((error) => {
      bbdNotify("Error", error, "danger", "fa fa-exclamation-triangle");
    });
  } else {
    if (type === "page") {
      $("#bbfdesign-plugin-page").html(response.content);
      $(".select2").select2();

      $(".sidebar-content")
        .find(".bbf-active-tab")
        .removeClass("bbf-active-tab");

      $("." + page + "").addClass("bbf-active-tab");
    }
  }
}

function saveSetting(formId) {
  let form = $("#" + formId);

  // Initialize FormData to handle file inputs
  let postsData = new FormData();
  postsData.append("action", form.attr("action"));
  postsData.append("is_ajax", 1);
  postsData.append(
    "jtl_token",
    document.querySelector('[name="jtl_token"]').value
  );

  // Append other form fields to FormData
  form.serializeArray().forEach((field) => {
    postsData.append(field.name, field.value);
  });

  // Handle multi-select fields
  form.find("select[multiple]").each(function () {
    let selectedOptions = $(this).val();
    if (selectedOptions) {
      selectedOptions.forEach((option) =>
        postsData.append($(this).attr("name"), option)
      );
    }
  });

  // Handle checkbox fields
  form.find('input[type="checkbox"]').each(function () {
    let isChecked = this.checked ? 1 : 0;
    postsData.append(this.name, isChecked);
  });

  // Handle checkbox arrays (e.g., checkbox groups with "[]" in name)
  form.find('input[type="checkbox"]').each(function () {
    if (this.name.endsWith("[]") && this.checked) {
      postsData.append(this.name, $(this).val());
    }
  });

  // Handle file inputs
  form.find('input[type="file"]').each(function () {
    let fileInput = this;
    let files = fileInput.files;
    if (files.length > 0) {
      Array.from(files).forEach((file) =>
        postsData.append(fileInput.name, file)
      );
    }
  });

  // AJAX request to submit FormData
  $.ajax({
    url: postURL,
    method: "POST",
    data: postsData,
    async: false,
    contentType: false,
    processData: false,
    success(response) {
      if (response && response.flag) {
        if (response.message) {
          bbdNotify(
            "Success",
            response.message,
            "success",
            "fa fa-check-circle"
          );
        }
      } else {
        if (response.errors && response.errors.length) {
          response.errors.forEach((error) => {
            bbdNotify("Error", error, "danger", "fa fa-exclamation-triangle");
          });
          $("#" + form)
            .find(".parent-setting")
            .prop("checked", false);
        }
      }
    },
    error(jqXHR, textStatus, errorThrown) {
      bbdNotify(
        "Error",
        "Error in saving settings: " + textStatus + " - " + errorThrown,
        "danger",
        "fa fa-exclamation-triangle"
      );
    },
  });
}

function ajaxPost(postData) {
  let ajaxResponse;
  $.ajax({
    url: postURL,
    data: postData,
    method: "POST",
    async: false,
    success: function (response) {
      ajaxResponse = response;
    },
  });

  return ajaxResponse;
}

function bbdNotify(
  title,
  message,
  type = "primary",
  icon = "fa fa-bell",
  from = "top",
  align = "right"
) {
  $.notify(
    {
      icon: icon,
      title: title,
      message: message,
    },
    {
      type: type,
      placement: {
        from: from,
        align: align,
      },
      time: 1000,
      delay: 1000,
    }
  );
}
