//
//  ViewController.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 2/26/24.
//

import UIKit

class ViewController: UIViewController {
    private var label: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let safeArea = view.safeAreaLayoutGuide
        
        let toolbar = BrowserToolbarViewController()
        self.addChild(toolbar)
        self.view.addSubview(toolbar.view)
        
        toolbar.view.translatesAutoresizingMaskIntoConstraints = false
        toolbar.view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        toolbar.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        toolbar.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        toolbar.view.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        let webViewController = WebViewController()
        let webView = webViewController.view!
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(webViewController)
        self.view.addSubview(webView)
        
        webView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: toolbar.view.topAnchor).isActive = true
    }
}
