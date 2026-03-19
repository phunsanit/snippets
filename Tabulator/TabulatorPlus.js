/**
 * TabulatorPlus.js
 * A wrapper class for Tabulator-tables to provide standardized configurations,
 * deep-merge capabilities, and utility methods across different frameworks.
 */
import { TabulatorFull as Tabulator } from 'tabulator-tables';

/**
 * Helper function to check if an item is a plain object.
 * @param {any} item - The item to check.
 * @returns {boolean}
 */
function isObject(item) {
	return (item && typeof item === 'object' && !Array.isArray(item));
}

/**
 * Deeply merges two objects to ensure nested properties (like 'persistence' or 'downloadConfig')
 * are not completely overwritten by user-provided configurations.
 * @param {Object} target - The default configuration object.
 * @param {Object} source - The user-provided configuration object.
 * @returns {Object} - The merged configuration.
 */
function deepMerge(target, source) {
	let output = Object.assign({}, target);
	if (isObject(target) && isObject(source)) {
		Object.keys(source).forEach(key => {
			if (isObject(source[key])) {
				if (!(key in target)) {
					Object.assign(output, { [key]: source[key] });
				} else {
					output[key] = deepMerge(target[key], source[key]);
				}
			} else {
				Object.assign(output, { [key]: source[key] });
			}
		});
	}
	return output;
}

export default class TabulatorPlus extends Tabulator {
	/**
	 * @param {HTMLElement|string} el - DOM element or selector to attach the table to.
	 * @param {Object} userConfig - Custom Tabulator options provided by the user.
	 * @param {string|null} storageKey - Unique ID for persistence (state saving).
	 */
	constructor(el, userConfig = {}, storageKey = null) {
		// 1. Define global organization-wide default settings
		const defaultConfig = {
			downloadConfig: {
				columnGroups: false,
				rowGroups: false,
				columnCalcs: true,
			},
			layout: "fitColumns",
			movableColumns: true,
			pagination: "local",
			paginationSize: 10,
			paginationSizeSelector: [10, 25, 50, 100],
			persistence: storageKey ? {
				filter: true,
				page: true,
				sort: true
			} : false,
			persistenceID: storageKey,
			placeholder: "No Data Available",
			resizableRows: true,
			responsiveLayout: "collapse"
		};

		// 2. Perform deep merge to protect nested default settings
		const finalConfig = deepMerge(defaultConfig, userConfig);

		// 3. Initialize the parent Tabulator class
		super(el, finalConfig);
	}

	/**
	 * Filters the table across multiple columns using OR logic.
	 * @param {string} searchTerm - String to search for.
	 * @param {Array} columnsToSearch - Optional fields to search in. Defaults to all columns with fields.
	 */
	globalSearch(searchTerm, columnsToSearch = []) {
		if (!searchTerm || searchTerm.trim() === "") {
			this.clearFilter();
			return;
		}

		const cols = columnsToSearch.length > 0
			? columnsToSearch
			: this.getColumnDefinitions()
				.filter(col => col.field)
				.map(col => col.field);

		const filterArray = cols.map(field => {
			return {
				field: field,
				type: "like",
				value: searchTerm
			};
		});

		// Apply filters with OR logic by wrapping the array
		this.setFilter([filterArray]);
	}

	/**
	 * Updates the table with a new dataset.
	 * Preferred over re-initializing the class for better performance.
	 * @param {Array} newData - Array of objects to load into the table.
	 * @returns {Promise}
	 */
	refreshData(newData) {
		if (newData && Array.isArray(newData)) {
			return this.setData(newData);
		}
		return Promise.reject("Invalid data format: Expected an Array.");
	}

	/**
	 * Downloads the current table data as an Excel file (.xlsx).
	 * Requires the 'xlsx' library to be present in the environment.
	 * @param {string} fileName - Name of the file (without extension).
	 */
	exportToExcel(fileName = "table-data") {
		if (typeof window.XLSX === "undefined" && !require?.resolve('xlsx')) {
			console.warn("Tabulator requires the 'xlsx' library to export Excel files. - TabulatorPlus.js:128");
		}

		this.download("xlsx", `${fileName}.xlsx`, { sheetName: "Data" });
	}

	/**
	 * Forces the table to recalculate dimensions and redraw.
	 * Use after container resizing or inside modal/tab transitions.
	 */
	forceRedraw() {
		this.redraw(true);
	}

	/**
	 * Clears all active filters and header filters.
	 */
	resetFilters() {
		this.clearFilter(true);
		this.clearHeaderFilter();
	}
}