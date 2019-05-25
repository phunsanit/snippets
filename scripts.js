/*
pitt phunsanit 
default fetch api options
version 1
*/
let fetchOptions = {
    "headers": {
        'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8'
    },
    "method": "post"
};

/*
pitt phunsanit 
custom user menu
version 1
*/
function anonymousUserBadge() {
    let badge = $('.user-link > a:first').closest('li');
    let emp_code = sessionStorage.getItem('emp_code');
    let emp_name = sessionStorage.getItem('emp_name');
    let navigation = $('#navigation');

    if (emp_name === null) {
        badge.replaceWith('<li class="user-link"><a href="/jw/web/login" class="btn waves-effect btn waves-button waves-float"><i class="fa fa-user white"></i> Login</a></li>');

        $('a[href$="/anonymousLogin"]', navigation).show();
        $('a[href$="_anonymous"]', navigation).hide();
    } else {

        $('a[href$="/anonymousLogin"]', navigation).closest('li').hide();

        $('a[href$="_anonymous"]', navigation).each(function (index, value) {
            let a = $(this);

            let href = a.attr('href');

            href += '?or_requester_id=' + emp_code + '&or_preparer_id=' + emp_code + '&pr_requester_id=' + emp_code + '&pr_preparer_id=' + emp_code;

            a.attr('href', href).show();
        });

        setTimeout(function () {
            badge.replaceWith('<li class="user-link dropdown"><a data-toggle="dropdown" class="btn dropdown-toggle waves-effect btn waves-button waves-float"><i class="fa fa-user-secret"></i> ' + emp_name + '<span class="caret"></span></a><ul class="dropdown-menu"><li><a id="logoutBtn"><i class="fa fa-power-off"></i> Logout</a></li></ul></li>');
        }, 1000);
    }
}

/*
pitt phunsanit 
custom display user name for anonymous
version 1
*/
function anonymousUser() {

    anonymousUserBadge();

    $(document).on('click', '#logoutBtn', function () {
        localStorage.removeItem('emp_code');
        localStorage.removeItem('emp_name');
        sessionStorage.removeItem('emp_code');
        sessionStorage.removeItem('emp_name');

        anonymousUserBadge('');

        window.location.href = '/jw/web/login';
    });
}

/*
pitt phunsanit 
editable input
version 1
*/
function beforeSubmit() {
    if ($("form.readonly").length == 0) {
        setTimeout(function () {
            $("#section-actions button, #section-actions input")
                .off("click")
                .on("click", function () {
                    $("#visibilityControl").val("all");
                    $(":disabled").prop("disabled", false);
                    $("[readonly]").prop("readonly", false);
                });
        }, 1000);
    }
}

/*
pitt phunsanit 
editable input
version 1
*/
function clickToEdit(inputs) {
    $.each(inputs, function (key, value) {
        let id = value + "EditFlag";
        let input = FormUtil.getField(value);

        input
            .attr("readonly", true)
            .closest(".form-cell")
            .append(
                '<label style="display: inline;"><input id="' +
                id +
                '" name="' +
                id +
                '" type="checkbox" value="Y"> Click to Edit</label>'
            );
        $("#" + id).on("change", function () {
            if ($(this).prop("checked") == true) {
                input.prop("readonly", false);
            } else {
                input.prop("readonly", true);
            }
        });
    });
}

/*
pitt phunsanit 
confirm submit form
version 1
*/
function confirmSubmit(
    confirmMessage = "Are you sure to submit ?",
    message = "Please wait...",
    delay = 1000
) {
    setTimeout(function () {
        $("#submit").on("click", function (event) {
            if (confirm(confirmMessage)) {
                $.blockUI({
                    css: {
                        "-moz-border-radius": "10px",
                        "-webkit-border-radius": "10px",
                        backgroundColor: "#000",
                        border: "none",
                        color: "#fff",
                        opacity: 0.3,
                        padding: "15px"
                    },
                    message: "<h1>" + message + "</h1>"
                });

                return true;
            }
        });
    }, delay);
}

/*
pitt phunsanit 
email attachment preview
version 1
*/
function emailAttachment(lists) {
    let accordionA = $("#accordionA");
    let expaned = "";

    $.each(lists, function (a, item) {
        let itemNo = a + 1;

        $("#mailAttachName" + itemNo).val(item.name);
        $("#mailAttachPath" + itemNo).val(item.url);

        let id = "attach" + itemNo;

        if (a == 0) {
            expaned = " in";
        } else {
            expaned = "";
        }

        let card =
            '<div class="accordion-group">' +
            '<div class="accordion-heading">' +
            '<input checked style="float: left; margin: 10px 10px 0 10px;" type="checkbox" value="' +
            itemNo +
            '">' +
            '<a class="accordion-toggle" data-parent="#accordionA" data-toggle="collapse"  href="#' +
            id +
            '" style="margin: 0px 10px; width: 90%;">' +
            item.name +
            '</a><a class="fa fa-download" href="' +
            item.url +
            '" style="float: right; font-size: 30px; margin: -32px 20px;" target="_blank"></a></div>' +
            '<div class="accordion-body collapse' +
            expaned +
            '" id="' +
            id +
            '"><div class="accordion-inner">' +
            '<iframe frameborder="0" height="842" id="attachIframe" src="' +
            item.url +
            '" width="100%"></iframe>' +
            "</div></div></div>" +
            "</div>";
        accordionA.append(card);
    });

    accordionA.on("change", 'input[type="checkbox"]', function () {
        let checkbox = $(this);

        let itemNo = checkbox.val();

        let mailAttachName = $("#mailAttachName" + itemNo);
        let mailAttachPath = $("#mailAttachPath" + itemNo);
        if (checkbox.is(":checked")) {
            mailAttachPath.prop("disabled", false);
            mailAttachName.prop("disabled", false);
        } else {
            mailAttachPath.prop("disabled", true);
            mailAttachName.prop("disabled", true);
        }
    });
}

/*
pitt phunsanit 
get file name from fetch api 
version 1
*/
function fetchGetFilename(response) {
    let filename = '';
    let disposition = response.headers.get('Content-Disposition');
    if (disposition && disposition.indexOf('attachment') !== -1) {
        let filenameRegex = /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/;
        let matches = filenameRegex.exec(disposition);
        if (matches != null && matches[1]) {
            filename = matches[1].replace(/['"]/g, '');
        }
    }
    return filename;
}

/*
pitt phunsanit 
get status from fetch api 
version 1
*/
function fetchStatus(Response) {
    if (Response.status >= 200 && Response.status < 300) {
        return Promise.resolve(Response);
    } else {
        return Promise.reject(new Error(Response.status + ' : ' + Response.statusText));
    }
}

/*
pitt phunsanit 
email attachment preview
version 1
*/
function flexfieldsInit(form, inputSelector, flexfieldsSelector) {
    let input = $(inputSelector, form);
    let parentSubFormId = $(flexfieldsSelector, form);

    flexfieldsLabels(form);
    flexfieldsSorts(inputSelector);

    let name = input.attr("name");
    input.on("change", function () {
        parentSubFormId.val(name + "=" + $(this).val()).trigger("change");
    });
}

/*
pitt phunsanit 
email attachment preview
version 1
*/
function flexfieldsLabels(form) {
    items = $('input[name$="labels"]').val();
    if (items == "") {
        return true;
    }
    try {
        let temp = JSON.parse(items);
        $.each(temp, function (index, value) {
            if (value.trim() == "") {
                $("#" + index)
                    .closest("div")
                    .hide();
            } else {
                let input = $("#" + index);

                input.siblings("label").text(value);
                input.closest("div").show();
            }
        });
    } catch (e) {
        console.log(e.message);
        html = "<h1>Error!!</h1>";
    }
}

/*
pitt phunsanit 
email attachment preview
version 1
*/
function flexfieldsSorts(inputSelector) {
    let items = $('input[name$="sorts"]').val();
    if (items == "") {
        return true;
    }
    try {
        let temp = JSON.parse(items);
        $.each(temp, function (index, value) {
            if (index == value) {
            } else if (value == 1) {
                $("#" + index)
                    .closest(":parent")
                    .insertAfter(inputSelector);
            } else {
                $("#" + index)
                    .closest(":parent")
                    .insertAfter("#attribute" + (value - 1) + ":parent");
            }
        });
    } catch (e) {
        console.log(e.message);
        html = "<h1>Error!!</h1>";
    }
}

/*
pitt phunsanit 
resize iframe
version 1
*/
function iframeHeight(obj) {
    the_height = obj.contentWindow.document.body.offsetHeight;
    obj.height = the_height + 10;
}

/*
pitt phunsanit 
show / hide section with joget Visibility
version 1
*/
function navSection() {
    let hash = window.location.hash.substr(1);
    let tabsA = $("#tabsA");
    let visibilityControl = $("#visibilityControl");

    if (hash != "" && hash != visibilityControl.val()) {
        $('a[href="#' + hash).click();
        visibilityControl.val(hash);
    }

    $("li > a", tabsA).on("click", function () {
        visibilityControl
            .val(
                $(this)
                    .attr("href")
                    .substr(1)
            )
            .trigger("change");
    });
}

/*
pitt phunsanit 
show / hide section with bootstrapt tabs
version 1
*/
function navSectionTabs() {
    let hash = window.location.hash.substr(1);
    let tabsA = $("#tabsA");
    let visibilityControl = $("#visibilityControl");

    $(".form-section:first").after('<div class="tab-content"></div>');
    $("a", tabsA).each(function () {
        $($(this).attr("href")).appendTo(".tab-content");
    });
    setTimeout(function () {
        $('a[href="#' + visibilityControl.val() + '"]').trigger("click");
    }, 300);

    $(".form-section").each(function () {
        $(this).addClass("fade tab-pane");
    });
    $("#" + visibilityControl.val()).addClass("fade tab-pane active show");

    if (hash != "" && hash != visibilityControl.val()) {
        $('a[href="#' + hash).click();
        visibilityControl.val(hash);
    }

    $("li > a", tabsA).on("click", function () {
        let target = $(this)
            .attr("href")
            .substr(1);
        visibilityControl.val(target).trigger("change");

        $(".form-section").each(function () {
            $(this)
                .addClass("fade in tab-pane")
                .removeClass("active show");
        });
        $("#" + target).addClass("fade tab-pane active show");
    });
}

/*
pitt phunsanit 
Please wait
version 1
*/
function preloader(message = 'Please wait...') {
    $.blockUI({
        css: {
            border: 'none',
            padding: '15px',
            backgroundColor: '#000',
            '-webkit-border-radius': '10px',
            '-moz-border-radius': '10px',
            opacity: .3,
            color: '#fff'
        },
        message: "<h1>" + message + "</h1>"
    });
}