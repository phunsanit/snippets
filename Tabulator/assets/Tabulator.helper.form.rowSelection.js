// function to cache form data to localStorage
function TabulatorCacheDataToLocalStorage(form, table, tableRowSelectName) {
    const currentLocalStorage = JSON.parse(localStorage.getItem('forms') || '{}');
    const formData = new FormData(form);
    const collectedData = formDataCollected(form);
    const dynamicKeys = [];

    // Get the definitive list of selected items from Tabulator
    const selectedTabulatorItems = table.getSelectedData().map(row => row.code);

    // Set the Tabulator items directly. Do not merge.
    collectedData[tableRowSelectName] = selectedTabulatorItems;
    if (!dynamicKeys.includes(tableRowSelectName)) {
        dynamicKeys.push(tableRowSelectName);
    }

    // Update the dynamic key list
    collectedData['_inputDynamic'] = dynamicKeys;

    // Merge the collected data into localStorage
    for (const [key, value] of Object.entries(collectedData)) {
        // For dynamic arrays, check if the key is 'items'.
        if (Array.isArray(value) && key === tableRowSelectName) {
            currentLocalStorage[key] = value; // Replace the old array with the new one
        } else if (Array.isArray(value)) {
            // Merge other dynamic arrays
            currentLocalStorage[key] = mergeArraysUnique(currentLocalStorage[key], value);
        } else {
            currentLocalStorage[key] = value;
        }
    }

    // Clean up dynamic arrays that are no longer in the form
    const previouslyDynamicKeys = currentLocalStorage['_inputDynamic'] || [];
    for (const key of previouslyDynamicKeys) {
        if (!collectedData[key] || (Array.isArray(collectedData[key]) && collectedData[key].length === 0)) {
            delete currentLocalStorage[key];
        }
    }
    currentLocalStorage['_inputDynamic'] = dynamicKeys;

    localStorage.setItem('forms', JSON.stringify(currentLocalStorage));
    console.log('Form data cached:', currentLocalStorage);
}

// ฟังก์ชันแสดงจำนวนข้อมูลใน Tabulator
function TabulatorPaginationRecords(table) {
    const totalCount = table.getDataCount();            // all rows in dataset
    const filteredCount = table.getDataCount("active"); // filtered rows (ignores pagination)

    document.getElementById('total-count').textContent = totalCount;
    document.getElementById('filtered-count').textContent = filteredCount;
}