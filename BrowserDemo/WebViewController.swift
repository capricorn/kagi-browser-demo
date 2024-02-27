//
//  WebViewController.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 2/26/24.
//

import UIKit
import WebKit

private enum ScriptMessageType: String {
    case installExtension
}

private extension WKUserContentController {
    func add(
        _ scriptMessageHandler: WKScriptMessageHandler,
        name: ScriptMessageType
    ) {
        self.add(scriptMessageHandler, name: name.rawValue)
    }
}

class WebViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler {
    var webView: WKWebView!
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch ScriptMessageType(rawValue: message.name) {
        case .installExtension:
            let extensionURL = message.body as! String
            print("Extension url: \(extensionURL)")
        default:
            break
        }
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        let browserNameUserScript = """
        if (document.domain == 'addons.mozilla.org') { \
            window.webkit.messageHandlers.installExtension.postMessage();
            setInterval(() => { \
                let button = document.querySelector('a.AMInstallButton-button'); \
                button.textContent = 'Add to Orion'; \
                button.onclick = (e) => { window.webkit.messageHandlers.installExtension.postMessage(button.href) };
            }, 100); \
        }
        """
        contentController.add(self, name: .installExtension)
        contentController.addUserScript(WKUserScript(source: browserNameUserScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
        webConfiguration.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:70.0) Gecko/20100101 Firefox/70.0"
        
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string:"https://addons.mozilla.org/en-US/firefox/addon/top-sites-button/")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}
