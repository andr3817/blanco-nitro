let nitroPercentage = 0;
let isUIVisible = false;

// Update nitro percentage
window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (data.type === 'updateNitro') {
        nitroPercentage = data.percentage;
        updateNitroUI();
    } else if (data.type === 'showUI') {
        isUIVisible = data.show;
        const container = document.querySelector('.nitro-container');
        if (container) {
            container.style.display = isUIVisible ? 'block' : 'none';
        }
    }
});

// Initialize UI visibility
const container = document.querySelector('.nitro-container');
if (container) {
    container.style.display = 'none';
}

function updateNitroUI() {
    const nitroBar = document.querySelector('.nitro-bar');
    const nitroPercentageText = document.querySelector('.nitro-percentage');
    
    nitroBar.style.width = `${nitroPercentage}%`;
    nitroPercentageText.textContent = `${nitroPercentage}%`;
}
