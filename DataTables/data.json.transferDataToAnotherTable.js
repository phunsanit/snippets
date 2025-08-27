$(function () {

	DataTablesA = $('#DataTablesA');
	DataTablesFiltersA = $('#DataTablesFiltersA');

	TableFilters = DataTablesFiltersA
		.DataTable({
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
					if (row.enable == '1') {
						var checked = ' checked';
					} else {
						var checked = '';
					}

					return '<input' + checked + ' name="enables[]" type="checkbox" value="' + row.DISTRICT_CODE + '">';
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
			"processing": true,
			"serverSide": true,
			"stateSave": true
		})
		.on('draw', function (event, settings, json, xhr) {
			/* add style to checkbox, radio */
			iCheckInit($('input:checkbox, input:radio', settings.nTable));
		});

	iCheckBulk(DataTablesFiltersA, TableFilters);

	dataTables = DataTablesA
		.DataTable({
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
					if (row.enable == 1) {
						var checked = ' checked';
					} else {
						var checked = '';
					}

					return '<input' + checked + ' name="enables[]" type="checkbox" value="' + row.DISTRICT_CODE + '">';
				},
				"title": '<input class="checkAll" type="checkbox">',
				"width": "10px",
			},
			{
				"orderable": false,
				"render": function (data, type, row, meta) {
					if (row.enable) {
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
			]
		})
		.on('draw', function (event, settings, json, xhr) {
			/* add style to checkbox, radio */
			iCheckInit($('input:checkbox, input:radio', settings.nTable));
		});

	iCheckBulk(DataTablesA, dataTable);

	iCheckChange(DataTablesFiltersA, TableFilters, dataTables);

	iCheckCopy(dataTables, TableFilters, 'DISTRICT_CODE');

});