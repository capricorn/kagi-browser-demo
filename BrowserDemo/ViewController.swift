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
            if let input, let url = URL(string: input) {
                webView.load(URLRequest(url: url))
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
