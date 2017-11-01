$(function() {
 
    dataTableA = $('#dataTableA');
    filtersTableA = $('#available table');
    tableA = $('#tableA');
 
    filtersTable = filtersTableA
        .DataTable({
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
        .on('draw', function(event, settings, json, xhr) {
            /* add style to checkbox, radio */
            //iCheckInit($('input:checkbox, input:radio', settings.nTable));
        });
 
    iCheckBulk(filtersTableA, filtersTable);
 
    dataTable = tableA
        .DataTable({
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
        .on('draw', function(event, settings, json, xhr) {
            /* add style to checkbox, radio */
            //iCheckInit($('input:checkbox, input:radio', settings.nTable));
        });
 
    iCheckBulk(tableA, dataTable);
 
    iCheckChange(filtersTableA, filtersTable, dataTable);
 
    iCheckCopy(dataTable, filtersTable, 'DISTRICT_CODE');
 
});