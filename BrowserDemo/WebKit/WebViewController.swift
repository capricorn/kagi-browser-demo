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
    case imageError
    case console
    case topSites
}

struct BrowserHistory: Codable {
    let title: String
    let url: String
    var visits: Int
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
    var history: [String: BrowserHistory] = [:]
    
    var topSites: [BrowserHistory] {
        Array(history
            .map({$0.value})
            .sorted(by: { $0.visits > $1.visits })
            .prefix(10))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url?.absoluteString {
            if let prevVisit = history[url] {
                var copy = prevVisit
                copy.visits += 1
                history[url] = copy
            } else {
                let title = ((webView.title ?? "").isEmpty) ? "Untitled" : webView.title!
                history[url] = BrowserHistory(title: title, url: url, visits: 1)
            }
        }
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        print("Handling file:// task: \(urlSchemeTask.request)")
        //let baseExtensionURL = URL(string: urlSchemeTask.request.allHTTPHeaderFields!["extension_base_url"]!)!
        
        // Idea:
        // TODO: Reference this since it's the install directory
        //let baseExtensionURL = Bundle.main.url(forResource: "panel", withExtension: "html", subdirectory: "top_sites_button-1.5/popup")!.deletingLastPathComponent().deletingLastPathComponent()
        let baseExtensionURL = FileManager.default.orionExtensionInstallDir
        //let relativeFilePath = urlSchemeTask.request.url!.relativePath(from: baseExtensionURL)!
        
        
        //let fileURL = URL(string: "file://" + urlSchemeTask.request.url!.path)!
        //let fileURL = URL(string: "file://" + baseExtensionURL.appendingPathComponent(relativeFilePath.absoluteString).path)!
        var fileURL = urlSchemeTask.request.url!
        fileURL = URL(string: "file://" + fileURL.path)!
        // Resolve absolute paths in extensions
        // TODO: Check if url base is the extension
        //if fileURL.path.starts(with: "/") {
        // This is an absolute extension request
        if fileURL.sameBasePath(as: baseExtensionURL) == false {
            let extensionName = urlSchemeTask.request.mainDocumentURL!.relativePath(from: baseExtensionURL)!.pathComponents[0]
            fileURL = baseExtensionURL.appendingPathComponent(extensionName).appendingPathComponent(urlSchemeTask.request.url!.path)
        }
        
        let file = try! Data(contentsOf: fileURL)
        let mimeType = fileURL.mimeType ?? "text/plain"
        let urlResponse = HTTPURLResponse(url: urlSchemeTask.request.url!, mimeType: mimeType, expectedContentLength: file.count, textEncodingName: "utf8")
        // TODO: Is the url correct?
        urlSchemeTask.didReceive(urlResponse)
        urlSchemeTask.didReceive(file)
        urlSchemeTask.didFinish()
        // TODO
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        print("Stopping request: \(urlSchemeTask.request.url)")
    }
    
    private func installExtension(url: String) {
        Task {
            do {
                // TODO: Error handling
                let xpiDownloadURL = URL(string: url)!
                let (data, resp) = try await URLSession.shared.data(from: xpiDownloadURL)
                
                let extensionURL = try BrowserExtension.saveUnpacked(data, filename: xpiDownloadURL.lastPathComponent)
                
                DispatchQueue.main.async {
                    // TODO: Send unzip file url in this message
                    NotificationCenter.default.post(name: .installedBrowserExtension, object: extensionURL)
                }
            } catch {
                print("Extension install failed: \(error)")
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Navigation failed: \(error)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Navigation failed: \(error)")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("Nav action: \(navigationAction.request.url?.absoluteString)")
        decisionHandler(.allow)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch ScriptMessageType(rawValue: message.name) {
        case .installExtension:
            let extensionURL = message.body as! String
            print("Extension url: \(extensionURL)")
            self.installExtension(url: extensionURL)
        case .imageError:
            print("Image error: \(message.body)")
        case .console:
            print("Console: \(message.body as? String)")
        case .topSites:
            // TODO: Custom serialization for array type?
            var topSitesJSON = String(data: try! JSONEncoder().encode(self.topSites), encoding: .utf8)!
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
        // TODO: Dynamically register all?
        contentController.add(self, name: .installExtension)
        contentController.add(self, name: .imageError)
        contentController.add(self, name: .console)
        contentController.add(self, name: .topSites)
        contentController.addUserScript(WKUserScript(source: browserNameUserScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
        let topSitesAPIScript = String(data: try! Data(contentsOf: Bundle.main.url(forResource: "TopSitesAPI", withExtension: "js")!), encoding: .utf8)!
         // TODO: Is this _always_ injected?
         // TODO: Simple user script that just adds a title
        contentController.addUserScript(WKUserScript(source: topSitesAPIScript, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        //contentController.addUserScript(WKUserScript(source: topSitesAPIScript, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        webConfiguration.userContentController = contentController
        webConfiguration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        webConfiguration.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        webConfiguration.setValue(true, forKey: "_allowUniversalAccessFromFileURLs")
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
