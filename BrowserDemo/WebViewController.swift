//
//  WebViewController.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 2/26/24.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate {
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        let browserNameUserScript = "if (document.domain == 'addons.mozilla.org') { setInterval(() => { document.querySelector('a.AMInstallButton-button').textContent = 'Add to Orion'}, 100) }"
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
