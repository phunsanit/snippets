/**
 * Create a Tabulator table with common configuration
 * @param {string} selector - DOM selector for the table container
 * @param {Object} options - Tabulator options (columns, data, etc.)
 * @returns {Tabulator} - Tabulator instance
 */
function TabulatorCreate(selector, options = {}) {
    const defaultConfig = {
        layout: "fitColumns",
        movableColumns: true,
        pagination: true,
        paginationSize: 10,
        responsiveLayout: true,
        // Add more default options as needed
    };
    return new Tabulator(selector, Object.assign({}, defaultConfig, options));
}

// Expose to global scope for inline HTML usage
window.TabulatorCreate = TabulatorCreate;

//https://tabulator.info/docs/6.3/filter

//Define variables for input elements
var fieldEl = document.getElementById("filter-field");
var typeEl = document.getElementById("filter-type");
var valueEl = document.getElementById("filter-value");

//Custom filter example
function customFilter(data) {
    return data.car && data.rating < 3;
}

//Trigger setFilter function with correct parameters
function updateFilter() {
    var filterVal = fieldEl.options[fieldEl.selectedIndex].value;
    var typeVal = typeEl.options[typeEl.selectedIndex].value;

    // Decode the filter value
    filterVal = decodeURIComponent(filterVal);

    var filter = filterVal == "function" ? customFilter : filterVal;

    if (filterVal == "function") {
        typeEl.disabled = true;
        valueEl.disabled = true;
    } else {
        typeEl.disabled = false;
        valueEl.disabled = false;
    }

    if (filterVal) {
        table.setFilter(filter, typeVal, valueEl.value);
    }
}

//Update filters on value change
document.getElementById("filter-field").addEventListener("change", updateFilter);
document.getElementById("filter-type").addEventListener("change", updateFilter);
document.getElementById("filter-value").addEventListener("keyup", updateFilter);

//Clear filters on "Clear Filters" button click
document.getElementById("filter-clear").addEventListener("click", function () {
    fieldEl.value = "";
    typeEl.value = "=";
    valueEl.value = "";

    table.clearFilter();
});