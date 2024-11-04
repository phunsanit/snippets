function iCheckBulk(DataTablesArea, dataTablesObject) {
	DataTablesArea.on('ifChanged', '.checkAll', function (event) {

		var datas = dataTablesObject.data();
		var inputs = $('input:checkbox, input:radio', DataTablesArea);

		if (event.target.checked) {
			var enable = '1';
			var state = 'check';
		} else {
			var enable = '0';
			var state = 'uncheck';
		}

		$.each(datas, function (index, value) {
			value.enable = enable;

			dataTablesObject.row(index).data(value);
		});

		iCheckInit($('input:checkbox, input:radio', DataTablesArea));
	});
}

/* change TableFilters data value on input name enables is change */
function iCheckChange(dataTablesFiltersA, TableFiltersObject, dataTablesObject) {
	$('tbody', DataTablesFiltersA).on('ifChanged', 'input[name="enables[]"]', function (event) {

		event.stopPropagation();

		var row = $(this).closest('tr');

		var data = TableFiltersObject.row(row).data();

		if ($(this).is(':checked')) {
			$(this).attr('checked', 1);
			data.enable = true;
		} else {
			$(this).attr('checked', 0);
			data.enable = false;
		}
		TableFiltersObject.row(row).data(data);

		iCheckInit(row);
	});
}

function iCheckCopy(dataTablesObject, TableFiltersObject, pkField) {
	$('#copyBtn').click(function () {

		/* loop current data (pkField) in current dataTablesObject */
		var datas = dataTablesObject.data();
		var hasKeys = new Array();
		$.each(datas, function (index, value) {
			hasKeys.push(value[pkField]);
		});

		var datasChoose = TableFiltersObject.data();

		$.each(datasChoose, function (index, value) {
			/* add row to TableFiltersObject if input name enables[] is checked */
			if (value.enable == true && hasKeys.indexOf(value[pkField]) == -1) {
				dataTablesObject
					.row.add(value)
					.draw()
					.node();
			}
		});

	});
}

function iCheckInit(selector) {
	selector.iCheck({
		checkboxClass: 'icheckbox_minimal-red',
		radioClass: 'iradio_minimal-red',
	});
}