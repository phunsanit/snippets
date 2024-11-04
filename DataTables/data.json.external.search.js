$(function () {

    formA = $('#formA');
    tableA = $('#tableA');

    datatable = tableA.DataTable({
        "ajax": {
            "beforeSend": function (jqXHR, settings) {
                /* add value form from to DataTable params */
                settings.data = formA.serialize() + '&' + settings.data;

                /* validation */
                var params = new URLSearchParams(settings.data);

                /* user must selected region if enable advance search */
                if (params.get('advanceSearch') == 'on' && params.get('geo_id') == '') {
                    jqXHR.abort();
                    alert('กรุณาเลือกภูมิภาค');
                    return false;
                }

                return true;
            },
            "dataSrc": function (json) {
                alert('data back ' + json.data.length + ' items');

                return json.data;
            },
            "method": "POST",
            "url": "data.json.php",
        },
        "columns": [{
            "orderable": false,
            "render": function (data, type, row, meta) {
                return parseInt(meta.row) + parseInt(meta.settings._iDisplayStart) + 1;
            },
            "title": 'No.',
            "width": "10px",
        },
        {
            "orderable": false,
            "render": function (data, type, row, meta) {
                return '<input type="checkbox" value="' + row.DISTRICT_CODE + '">';
            },
            "title": '<input class="checkAll" type="checkbox">',
            "width": "10px",
        },
        {
            "orderable": false,
            "render": function (data, type, row, meta) {
                if (row.enable == '1') {
                    return '<span class="glyphicon glyphicon-ok"></span>';
                } else {
                    return '<span class="glyphicon glyphicon-remove"></span>';
                }
            },
            "title": "Enable",
            "width": "10px",
        }, {
            "data": "DISTRICT_CODE",
            "title": "District Code",
            "width": "90px",
        }, {
            "data": "DISTRICT_NAME",
            "title": "District Name",
        }, {
            "data": "PROVINCE_NAME",
            "title": "Province Name",
        }
        ],
        /* default sort */
        "order": [
            [3, "asc"],
            [4, "asc"],
        ],
        "processing": true,
        "serverSide": true,
        "stateSave": true,
    });

    $('.checkAll', tableA).click(function () {
        $('input:checkbox', tableA).not(this).prop('checked', this.checked);
    });

    formA.submit(function (event) {
        event.preventDefault();

        datatable.ajax.reload();
    });

});