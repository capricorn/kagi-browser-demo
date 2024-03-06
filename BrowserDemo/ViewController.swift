//
//  ViewController.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 2/26/24.
//

import UIKit
import WebKit
import Combine

class ViewController: UIViewController {
    private var label: UITextView!
    private var webView: UIView!
    private var toolbarView: UIView!
    private var toolbarDelegate: ToolbarDelegate!
    private var keyboardOpenSubscriber: AnyCancellable? = nil
    private var keyboardCloseSubscriber: AnyCancellable? = nil
    
    private var keyboardYOffset: CGFloat = 0
    private var toolbarBottomConstraint: NSLayoutConstraint!
    
    private class ToolbarDelegate: BrowserToolbarDelegate {
        let webViewController: WebViewController
        
        private var webView: WKWebView {
            webViewController.webView
        }
        
        init(webViewController: WebViewController) {
            self.webViewController = webViewController
        }
        
        func search(_ input: String?) {
            // TODO: Handle malformed urls -- prefix url with https:// if missing
            if let input, let url = URL(string: input) {
                if url.isFileURL {
                    //let htmlURL = url / "popup" / "panel.html"
                    //let htmlStr = String(data: try! Data(contentsOf: htmlURL), encoding: .ascii)!
                    
                    // TODO: Should only occur on initial installation (For this domain?)
                    
                    //webView.configuration.userContentController.addUserScript(WKUserScript(source: topSitesAPIScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
                    // TODO: Test by evaluating javascript within scope?
                    //let htmlStr2 = "<html><body><h1>hello world</h1></body></html>"
                    // Test to see if topsites API is available via user script
                    //let htmlStr2 = "<html>  <body>  </body><script>browser.topSites.get().then(f => {    let e = document.createElement('h1');    e.textContent = f[0].title;    document.body.appendChild(e);});</script></html>"
                    //let htmlStr2 = "<html>  <body>  </body><script>browser.topSites.get().then(results => {        for (const entry of results) {      let e = document.createElement('h1');      e.textContent = entry.title;      document.body.appendChild(e);    }});</script></html>"
                    // TODO: Figure out how to load content.. presumably the popup js is the issue..?
                    // TODO: Better way to test..?
                    // TODO: Write this to disk and load as url request / file url?
                    let imgLoadHTML = "<html><body><img width=\"200\" height=\"200\" src=\"/icons/24-flame.png\"></img></body></html>"
                    //webView.loadHTMLString(htmlStr, baseURL: url)
                    //webView.load(URLRequest(url: htmlURL))
                    
                    var bundleHTMLURL = Bundle.main.url(forResource: "panel", withExtension: "html", subdirectory: "top_sites_button-1.5/popup")!
                    //var bundleHTMLURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "top_sites_button-1.5")!
                    //bundleHTMLURL = URL(fileURLWithPath: "file://" + bundleHTMLURL.path)
                    let htmlStr = String(data: try! Data(contentsOf: bundleHTMLURL), encoding: .utf8)!
                    
                    //webView.loadHTMLString(imgLoadHTML, baseURL: url)
                    //webView.loadHTMLString(, baseURL: nil)
                    //webView.loadFileURL(bundleHTMLURL, allowingReadAccessTo: bundleHTMLURL.deletingLastPathComponent())
                    //webView.loadHTMLString(htmlStr, baseURL: bundleHTMLURL.deletingLastPathComponent())
                    var baseURLStr = bundleHTMLURL.deletingLastPathComponent().deletingLastPathComponent().absoluteString
                    //baseURLStr.removeLast()
                    
                    let baseURL = URL(string: baseURLStr)!
                    //baseURL = URL(string URL(fileURLWithPath: baseURL.path)
                    /*
                     let baseURLStr = baseURL.absoluteString
                     let slice = String(baseURLStr[baseURLStr.index(baseURLStr.startIndex, offsetBy: "file://".count)...])
                     baseURL = URL(string: slice)!
                     */
                    
                    
                    //webView.loadHTMLString(htmlStr, baseURL: baseURL)
                    
                    // All requests will be relative to this
                    let extensionSchemeURL = URL(string: "extension://" + bundleHTMLURL.path)!
                    var req = URLRequest(url: extensionSchemeURL)
                    //req.allHTTPHeaderFields?["extension_base_url"] = baseURLStr
                    // NB base url is _not_ guaranteed (could set somethign else like a cookie..)
                    req.setValue(baseURLStr, forHTTPHeaderField: "extension_base_url")
                    webView.load(req)
                    //webView.loadFileURL(bundleHTMLURL, allowingReadAccessTo: baseURL)
                    //webView.loadHTMLString(htmlStr2, baseURL: URL(string: url.absoluteString + "/")!)
                    /*
                } else if url.isExtensionURL {
                    // Resolution of _exactly_ a web extension
                    let extensionRoot = url.relativePath(from: FileManager.default.orionExtensionInstallDir)!
                    let req = URLRequest(url: url)
                    let data = try! Data(contentsOf: url.fileScheme)
                    webView.load(
                        data,
                        mimeType: "text/html",
                        characterEncodingName: "utf8",
                        baseURL: (FileManager.default.orionExtensionInstallDir / extensionRoot.pathComponents.first!).extensionScheme)
                     */
                } else {
                    var req = URLRequest(url: url)
                    webView.load(req)
                }
            }
        }
        
        func back() {
            if webView.canGoBack {
                webView.goBack()
            }
        }
    }
    
    func setupConstraints() {
        let safeArea = view.layoutMarginsGuide
        
        toolbarBottomConstraint = toolbarView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -self.keyboardYOffset)
        toolbarBottomConstraint.isActive = true
        toolbarView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        toolbarView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        toolbarView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        webView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor).isActive = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.keyboardOpenSubscriber = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification).sink { [weak self] notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            
            self?.keyboardYOffset = keyboardFrame.height
            UIView.animate(withDuration: 1/4, animations: { [weak self] in
                self?.toolbarBottomConstraint.constant = -(self?.keyboardYOffset ?? 0)
                self?.view.layoutIfNeeded()
            })
        }
        
        self.keyboardCloseSubscriber = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification).sink { [weak self] _ in
            UIView.animate(withDuration: 1/4, animations: { [weak self] in
                self?.toolbarBottomConstraint.constant = 0
                self?.view.layoutIfNeeded()
            })
        }

        let webViewController = WebViewController()
        webView = webViewController.view!
        
        toolbarDelegate = ToolbarDelegate(webViewController: webViewController)
        
        let toolbar = BrowserToolbarViewController(delegate: toolbarDelegate)
        toolbarView = toolbar.view!
        self.addChild(toolbar)
        self.view.addSubview(toolbar.view)
        
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(webViewController)
        self.view.addSubview(webView)
        
        setupConstraints()
    }
}
