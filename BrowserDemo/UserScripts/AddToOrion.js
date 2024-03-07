// Rewrites the button label 'Add to Firefox' to 'Add to Orion' on 'addons.mozilla.org'.
if (document.domain == 'addons.mozilla.org') {
    window.webkit.messageHandlers.installExtension.postMessage();
    setInterval(() => {
        let button = document.querySelector('a.AMInstallButton-button');
        button.textContent = 'Add to Orion';
        button.onclick = (e) => { window.webkit.messageHandlers.installExtension.postMessage(button.href) };
    }, 100);
}
