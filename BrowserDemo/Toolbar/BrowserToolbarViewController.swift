//
//  BrowserToolbar.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 2/26/24.
//

import UIKit
import Combine

protocol BrowserToolbarDelegate {
    func search(_ input: String?)
    func back()
}

extension BrowserToolbarDelegate {
    func search(_ input: String?) {}
    func back() {}
}

class ExtensionButton: UIButton {
    var ext: BrowserExtension?
}

class BrowserToolbarViewController: UIViewController {
    private var backButton: UIButton!
    private var searchTextField: UITextField!
    private var extensionStack: UIStackView!
    private var extensionStackWidthConstraint: NSLayoutConstraint!
    
    private let viewModel = BrowserToolbarViewModel()
    
    private let searchDelegate = SearchDelegate()
    var delegate: BrowserToolbarDelegate?
    
    @objc
    private func handleBackButton() {
        delegate?.back()
    }
    
    @objc
    private func handleExtensionButton(sender: UIButton) {
        let extButton = sender as! ExtensionButton
        let ext = extButton.ext!
        print("Tapped button: \(extButton.ext!.manifest.name) @ \(extButton.ext!.unpackedURL)")
        let popupURL = (ext.unpackedURL! / ext.manifest.popupHTMLPath!).extensionScheme
        // TODO: Special callback for loading extension
        delegate?.search(popupURL.absoluteString)
    }
    
    init(delegate: BrowserToolbarDelegate?=nil) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.extensionInstallSubscriber = NotificationCenter.default.publisher(for: .installedBrowserExtension).sink { [weak self] message in
            guard let self else {
                return
            }
            
            guard let extensionURL = message.object as? URL else {
                print("Could not install extension: 'url' message obj missing.")
                return
            }
            
            do {
                let ext = try viewModel.installExtension(extensionURL)
                self.addExtensionToToolbar(ext)
            } catch {
                print("Failed to add extension \(extensionURL) (\(error))")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.extensionInstallSubscriber = nil
    }
    
    private func addExtensionToToolbar(_ ext: BrowserExtension) {
        UIView.animate(withDuration: 1/4) {
            if self.viewModel.extensions.count == 1 {
                self.displayExtensionStack()
            }
            
            self.extensionStack.addArrangedSubview(self.buildExtensionButton(ext))
            self.view.layoutIfNeeded()
        }
    }
    
    private func displayExtensionStack() {
        extensionStack.removeConstraint(extensionStackWidthConstraint)
        extensionStackWidthConstraint = extensionStack.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
        extensionStackWidthConstraint.isActive = true
    }
    
    private func buildExtensionButton(_ ext: BrowserExtension) -> UIButton {
        let button = ExtensionButton()
        let icon32 = ext.icons.first(where: { img in img.size == CGSize(width: 32, height: 32) })
        let buttonImage = icon32 ?? UIImage(systemName: "puzzlepiece.extension")!
        
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(handleExtensionButton(sender:)), for: .touchDown)
        button.ext = ext
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return button
    }
    
    private func setupExtensionStack() {
        extensionStack = UIStackView()
        self.view.addSubview(extensionStack)
        extensionStack.translatesAutoresizingMaskIntoConstraints = false
        extensionStack.axis = .horizontal
        extensionStack.clipsToBounds = true
        extensionStack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        extensionStack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        extensionStack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        extensionStack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        extensionStackWidthConstraint = extensionStack.widthAnchor.constraint(equalToConstant: 0)
        extensionStackWidthConstraint.isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchDelegate.toolbarDelegate = self.delegate
        
        backButton = UIButton()
        // TODO: Respect aspect ratio (wrt height)
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchDown)
        
        searchTextField = UITextField()
        searchTextField.borderStyle = .line
        searchTextField.placeholder = "Search"
        searchTextField.delegate = self.searchDelegate
        searchTextField.autocapitalizationType = .none
        searchTextField.autocorrectionType = .no
        searchTextField.keyboardType = .webSearch
        searchTextField.returnKeyType = .search
        
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(backButton)
        self.view.addSubview(searchTextField)
        
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backButton.trailingAnchor.constraint(equalTo: searchTextField.leadingAnchor).isActive = true
        backButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        setupExtensionStack()
        
        let searchTrailingAnchor = extensionStack.leadingAnchor
        
        searchTextField.leadingAnchor.constraint(equalTo: backButton.trailingAnchor).isActive = true
        searchTextField.trailingAnchor.constraint(equalTo: searchTrailingAnchor).isActive = true
        searchTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        searchTextField.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        self.view.clipsToBounds = true
    }
}

