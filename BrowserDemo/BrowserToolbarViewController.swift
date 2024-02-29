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

class BrowserToolbarViewController: UIViewController {
    private var backButton: UIButton!
    private var searchTextField: UITextField!
    private let searchDelegate = SearchDelegate()
    private var extensionInstallSubscriber: AnyCancellable? = nil
    
    private var extensionIcons: [UIImage] = []
    var delegate: BrowserToolbarDelegate?
    
    class SearchDelegate: NSObject, UITextFieldDelegate {
        var toolbarDelegate: BrowserToolbarDelegate?
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return true
        }
        
        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            switch reason {
            case .committed:
                toolbarDelegate?.search(textField.text)
            default:
                break
            }
        }
    }
    
    @objc
    private func handleBackButton() {
        delegate?.back()
    }
    
    init(delegate: BrowserToolbarDelegate?=nil) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        
        self.extensionInstallSubscriber = NotificationCenter.default.publisher(for: .installedBrowserExtension).sink { [weak self] message in
            print("Received installation update: \((message.object as? URL)?.path)")
            let extensionURL = URL(string: "file://" + (message.object as! URL).path)!
            self?.delegate?.search(extensionURL.absoluteString)
            self?.extensionIcons.append(UIImage(systemName: "puzzlepiece.extension")!)
            self?.viewDidLoad()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var extensionButtons: [UIButton] {
        self.extensionIcons.map {
            let button = UIButton()
            button.setImage($0, for: .normal)
            // TODO: Set callback
            return button
        }
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
        
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(backButton)
        self.view.addSubview(searchTextField)
        
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backButton.trailingAnchor.constraint(equalTo: searchTextField.leadingAnchor).isActive = true
        backButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        // TODO: Build UIButton
        let extensionStack = UIStackView(arrangedSubviews: self.extensionButtons)
        if self.extensionIcons.count > 0 {
            self.view.addSubview(extensionStack)
            extensionStack.translatesAutoresizingMaskIntoConstraints = false
            extensionStack.axis = .horizontal
            //extensionStack.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor).isActive = true
            extensionStack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            extensionStack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            extensionStack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            // TODO: Scrollview?
            extensionStack.widthAnchor.constraint(greaterThanOrEqualToConstant: 32).isActive = true
            extensionStack.clipsToBounds = true
            extensionStack.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        }
        
        let searchTrailingAnchor = (self.extensionIcons.count > 0) ? extensionStack.leadingAnchor : view.trailingAnchor
        
        searchTextField.leadingAnchor.constraint(equalTo: backButton.trailingAnchor).isActive = true
        searchTextField.trailingAnchor.constraint(equalTo: searchTrailingAnchor).isActive = true
        searchTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        searchTextField.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        self.view.clipsToBounds = true
    }
}

