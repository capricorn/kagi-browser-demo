class TopSites {
    get() {
        return new Promise((resolve, reject) => {
            window.addEventListener('topSites', (e) => {
                let result = JSON.parse(e.topSites);
                resolve(result.topSites);
            }, { once: true})
            window.webkit.messageHandlers.topSites.postMessage({});
        });
    }
}

let browser = window.webkit;
browser.topSites = new TopSites();

// Forward console messages to the app for display
console.log = (input) => {
    window.webkit.messageHandlers.console.postMessage(input);
}
