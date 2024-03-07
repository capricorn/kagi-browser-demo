//
//  NSRegularExpressionExtensions.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 3/7/24.
//

import Foundation

extension NSRegularExpression {
    func matches(_ input: String) -> Bool {
        return self.matches(in: input, range: NSRange(location: 0, length: input.utf16.count)).isEmpty == false
    }
}
