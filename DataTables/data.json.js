$(function () {

    DataTablesA = $('#DataTablesA');

    datatable = DataTablesA.DataTable({
        "ajax": {
            "data": function (parameters) { },
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

    $('.checkAll', DataTablesA).click(function () {
        $('input:checkbox', DataTablesA).not(this).prop('checked', this.checked);
    });

});