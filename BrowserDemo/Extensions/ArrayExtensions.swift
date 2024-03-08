//
//  ArrayExtensions.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 3/7/24.
//

import Foundation

extension Array {
    func unique<Value>(_ transform: (Element) -> Value) -> [Element] where Value: Comparable & Hashable {
        var seen = Set<Value>()
        var uniq: [Element] = []
        
        for item in self {
            let val = transform(item)
            if seen.contains(val) {
                continue
            } else {
                seen.insert(val)
                uniq.append(item)
            }
        }
        
        return uniq       
    }
}
