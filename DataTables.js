function iCheckBulk(dataTableArea, dataTableObject) {
    dataTableArea.on('ifChanged', '.checkAll', function(event) {

        var datas = dataTableObject.data();
        var inputs = $('input:checkbox, input:radio', dataTableArea);

        if (event.target.checked) {
            var enable = '1';
            var state = 'check';
        } else {
            var enable = '0';
            var state = 'uncheck';
        }

        $.each(datas, function(index, value) {
            value.enable = enable;

            dataTableObject.row(index).data(value);
        });

        iCheckInit($('input:checkbox, input:radio', dataTableArea));
    });

}

/* change filtersTable data value on input name enables is change */
function iCheckChange(filtersTableArea, filtersTableObject, dataTableObject) {
    $('tbody', filtersTableArea).on('ifChanged', 'input[name="enables[]"]', function(event) {

        event.stopPropagation();

        var row = $(this).closest('tr');

        var data = dataTableObject.row(row).data();

        if ($(this).is(':checked')) {
            $(this).attr('checked', 1);
            data.enable = true;
        } else {
            $(this).attr('checked', 0);
            data.enable = false;
        }
        dataTableObject.row(row).data(data);

        iCheckInit(row);
    });
}


function iCheckCopy(dataTableObject, filtersTableObject, pkField) {
    $('#copyBtn').click(function() {

        /* loop current data (pkField) in current dataTableObject */
        var datas = dataTableObject.data();
        var hasKeys = new Array();
        $.each(datas, function(index, value) {
            hasKeys.push(value[pkField]);
        });

        var datasChoose = filtersTableObject.data();

        $.each(datasChoose, function(index, value) {
            /* add row to filtersTableObject if input name enables[] is checked */
            if (value.enable == true && hasKeys.indexOf(value[pkField]) == -1) {
                dataTableObject
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