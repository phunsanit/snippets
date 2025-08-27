// Helper function to merge two arrays uniquely
function mergeArraysUnique(arr1, arr2) {
    return Array.from(new Set([...(arr1 || []), ...(arr2 || [])]));
}

// Helper function to collect form data
function formDataCollected(form) {
    const currentLocalStorage = JSON.parse(localStorage.getItem('forms') || '{}');
    const dynamicKeys = [];
    const formData = new FormData(form);
    const formDataCollected = {};

    // Collect static and other dynamic form data
    for (const [name, value] of formData.entries()) {
        const isArrayInput = name.endsWith('[]');
        const key = isArrayInput ? name.slice(0, -2) : name;
        if (isArrayInput) {
            if (!formDataCollected[key]) {
                formDataCollected[key] = [];
            }
            formDataCollected[key].push(value);
            if (!dynamicKeys.includes(key)) {
                dynamicKeys.push(key);
            }
        } else {
            formDataCollected[key] = value;
        }
    }

    return formDataCollected;
}