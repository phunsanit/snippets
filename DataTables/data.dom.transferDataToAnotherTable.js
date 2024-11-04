$(function () {

    DataTablesA = $('#DataTablesA');
    DataTablesFiltersA = $('#available table');

    filtersTable = DataTablesFiltersA
        .DataTablesA({
            "columns": [
                {
                    "title": "Intermediary Code"
                }, {
                    "title": "Type"
                }, {
                    "title": "Intermediary Name 1",
                }
            ],
            "processing": true,
            "serverSide": true,
            "stateSave": true,
        })
        .on('draw', function (event, settings, json, xhr) {
            /* add style to checkbox, radio */
            //iCheckInit($('input:checkbox, input:radio', settings.nTable));
        });

    iCheckBulk(DataTablesFiltersA, filtersTable);

    DataTablesA = DataTablesA
        .DataTablesA({
            "columns": [
                {
                    "title": "Intermediary Code"
                }, {
                    "title": "Type"
                }, {
                    "title": "Intermediary Name 1",
                }
            ],
        })
        .on('draw', function (event, settings, json, xhr) {
            /* add style to checkbox, radio */
            //iCheckInit($('input:checkbox, input:radio', settings.nTable));
        });

    iCheckBulk(DataTablesA, DataTablesA);

    iCheckChange(DataTablesFiltersA, filtersTable, DataTables);

    iCheckCopy(DataTables, filtersTable, 'DISTRICT_CODE');

});