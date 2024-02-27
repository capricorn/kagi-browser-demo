//
//  ViewController.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 2/26/24.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    private var label: UITextView!
    private var toolbarDelegate: ToolbarDelegate!
    
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
                webView.load(URLRequest(url: url))
            }
        }
        
        func back() {
            print("Delegate back")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let safeArea = view.safeAreaLayoutGuide
        
        let webViewController = WebViewController()
        let webView = webViewController.view!
        
        toolbarDelegate = ToolbarDelegate(webViewController: webViewController)
        
        let toolbar = BrowserToolbarViewController(delegate: toolbarDelegate)
        self.addChild(toolbar)
        self.view.addSubview(toolbar.view)
        
        toolbar.view.translatesAutoresizingMaskIntoConstraints = false
        toolbar.view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        toolbar.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        toolbar.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        toolbar.view.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(webViewController)
        self.view.addSubview(webView)
        
        webView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: toolbar.view.topAnchor).isActive = true
    }
}
