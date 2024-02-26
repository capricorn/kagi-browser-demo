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
        
        // TODO: Programmatically add view controller..?
        let toolbar = BrowserToolbarViewController()
        self.addChild(toolbar)
        self.view.addSubview(toolbar.view)
        
        let safeArea = view.safeAreaLayoutGuide
        toolbar.view.translatesAutoresizingMaskIntoConstraints = false
        toolbar.view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        toolbar.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        toolbar.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        toolbar.view.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        label = UITextView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "testing label"
        label.font = .systemFont(ofSize: 16)
        
        self.view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        // TODO: Dynamic sizing according to text requirements..?
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 32).isActive = true
    }
}
