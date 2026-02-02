import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap-icons/font/bootstrap-icons.css';
import 'datatables.net-dt/css/dataTables.dataTables.css';

import $ from 'jquery';
import DataTable from 'datatables.net-dt';

// --- Remove or Comment out this line ---
// DataTable(window, $);

interface LocationData {
    POST_CODE: string;
    SUB_DISTRICT_NAME: string;
    DISTRICT_NAME: string;
    PROVINCE_NAME: string;
    enable: string;
}

// In new DataTables versions used with Vite/ESM
// We usually call via DataTable.DataTable or call directly if already bound
let dataTableInstance: any;

$(() => {
    // Use this command instead of calling directly via jQuery Prototype for safety
    dataTableInstance = new DataTable('#DataTablesA', {
		ajax: {
        	type: "GET",
        	url: "data.json",
    	},
        columns: [
            {
                orderable: true,
                render: (_data: any, _type: any, _row: any, meta: any) => meta.row + 1,
                title: 'No.',
                width: "40px",
            },
            {
                orderable: false,
                render: (_data: any, _type: any, row: LocationData) =>
                    `<input type="checkbox" value="${row.SUB_DISTRICT_NAME}">`,
                title: '<input class="checkAll" type="checkbox">',
                width: "30px",
            },
            {
                orderable: true,
                render: (_data: any, _type: any, row: LocationData) => {
                    const isEnabled = row.enable === '1';
                    return `<span class="bi bi-${isEnabled ? 'check-circle-fill text-success' : 'x-circle-fill text-danger'}"></span>`;
                },
                title: "Status",
                width: "60px",
            },
            { data: "POST_CODE", title: "Zip Code", width: "80px" },
            { data: "SUB_DISTRICT_NAME", title: "Sub District" },
            { data: "DISTRICT_NAME", title: "District" },
            { data: "PROVINCE_NAME", title: "Province" }
        ],
        data: [],
		processing: true,
		serverSide: false
    });

    // The Search and AJAX parts remain the same
    $('#searchBtn').on('click', () => {
        $.ajax({
            dataType: "json",
            method: "GET",
            success: (data: LocationData[]) => {
                dataTableInstance.clear().rows.add(data).draw();
            },
            url: "/data.json"
        });
    });
});
