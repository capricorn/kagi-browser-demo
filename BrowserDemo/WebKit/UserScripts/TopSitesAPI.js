class TopSites {
    get() {
        return new Promise((resolve, reject) => {
            window.addEventListener('topSites', (e) => {
                console.log('got top sites message: ' + e.type);
                console.log('output: ' + e.topSites);
                let result = JSON.parse(e.topSites);
                console.log('parse result: ' + JSON.stringify(result.topSites));
                console.log('parse result: ' + result.topSites[0].url);
                resolve(result.topSites);
            }, { once: true})
            window.webkit.messageHandlers.topSites.postMessage({});
        });
    }
}

// TODO: Does browser even need defined?
//class Browser {}

// Confirmed to exist
let browser = window.webkit;
//let browser = new Browser();
browser.topSites = new TopSites();
/*
let e = document.createElement('h1');
e.textContent = "Test";
document.body.appendChild(e);
 */
/*
browser.topSites.get().then(f => {
    let e = document.createElement('h1');
    e.textContent = f[0].title;

    document.body.appendChild(e);
});
*/


function handleImgError() {
    // TODO -- post message
    window.webkit.messageHandlers.imageError.postMessage("Failed to load image");
}

console.log = (input) => {
    window.webkit.messageHandlers.console.postMessage(input);
}

console.log('test');
