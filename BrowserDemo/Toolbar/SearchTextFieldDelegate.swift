//
//  SearchTextFieldDelegate.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 3/7/24.
//

import UIKit
import Foundation

private extension NSRegularExpression {
    func matches(_ input: String) -> Bool {
        return self.matches(in: input, range: NSRange(location: 0, length: input.utf16.count)).isEmpty == false
    }
}

class SearchDelegate: NSObject, UITextFieldDelegate {
    var toolbarDelegate: BrowserToolbarDelegate?
    static let marginaliaQuery = "https://search.marginalia.nu/search?query="
    
    func urlQuery(_ query: String) -> Bool {
        // TODO: Support unicode tlds, etc
        let tldRegex = try! NSRegularExpression(pattern: "\\.[a-z]+$", options: .caseInsensitive)
        return (query.split(separator: " ").count == 1) && tldRegex.matches(query)
    }
    
    func adjustQuery(_ query: String) -> String {
        if urlQuery(query) {
            let prefixRegex = try! NSRegularExpression(pattern: "^https?://")
            if prefixRegex.matches(query) {
                return query
            } else {
                return "https://" + query
            }
        } else {
            let encodedQuery = query
                .split(separator: " ")
                .joined(separator: "+")
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            return SearchDelegate.marginaliaQuery + encodedQuery
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        switch reason {
        case .committed:
            if let query = textField.text {
                toolbarDelegate?.search(adjustQuery(query))
            }
        default:
            break
        }
    }
}
