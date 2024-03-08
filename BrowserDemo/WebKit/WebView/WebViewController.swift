//
//  WebViewController.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 2/26/24.
//

import UIKit
import WebKit
import ZIPFoundation

private enum ScriptMessageType: String {
    case installExtension
    case console
    case topSites
}

private extension WKUserContentController {
    func add(
        _ scriptMessageHandler: WKScriptMessageHandler,
        name: ScriptMessageType
    ) {
        self.add(scriptMessageHandler, name: name.rawValue)
    }
}

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, WKURLSchemeHandler {
    var webView: WKWebView!
    let viewModel = WebViewModel()
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewModel.updateHistory(webView.url, siteTitle: webView.title)
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        do {
            let (file, urlResponse) = try viewModel.handleExtensionRequest(urlSchemeTask.request)
            urlSchemeTask.didReceive(urlResponse)
            urlSchemeTask.didReceive(file)
            urlSchemeTask.didFinish()
        } catch {
            print("Failed to handle url scheme task: \(error)")
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        print("Stopping request: \(urlSchemeTask.request.url)")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Navigation failed: \(error)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Navigation failed: \(error)")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, viewModel.xpiAddonURL(url) {
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch ScriptMessageType(rawValue: message.name) {
        case .installExtension:
            let xpiURL = URL(string: message.body as! String)!
            viewModel.installExtensionTask(xpiURL)
        case .console:
            print("Console: \(message.body as? String)")
        case .topSites:
            // TODO: Custom serialization for array type?
            var topSitesJSON = String(data: try! JSONEncoder().encode(viewModel.topSites), encoding: .utf8)!
            topSitesJSON = "{ \"topSites\": \(topSitesJSON) }"
            // Evaluate javascript to post the message
            let js = """
            let event = new Event('topSites');
            event.topSites = '\(topSitesJSON)';
            window.dispatchEvent(event);
            """
            webView.evaluateJavaScript(js)
        default:
            print("Received message: \(message.name)")
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        let browserNameUserScript = String(data: try! Data(contentsOf: Bundle.main.url(forResource: "AddToOrion", withExtension: "js")!), encoding: .utf8)!
        let topSitesAPIScript = String(data: try! Data(contentsOf: Bundle.main.url(forResource: "TopSitesAPI", withExtension: "js")!), encoding: .utf8)!
        
        contentController.add(self, name: .installExtension)
        contentController.add(self, name: .console)
        contentController.add(self, name: .topSites)
        
        contentController.addUserScript(WKUserScript(source: browserNameUserScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
        contentController.addUserScript(WKUserScript(source: topSitesAPIScript, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        
        webConfiguration.userContentController = contentController
        webConfiguration.setURLSchemeHandler(self, forURLScheme: "extension")
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:70.0) Gecko/20100101 Firefox/70.0"
        
        view = webView
        
        let myURL = URL(string:"https://addons.mozilla.org/en-US/firefox/addon/top-sites-button/")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}
