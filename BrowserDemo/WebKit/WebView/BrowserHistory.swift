//
//  BrowserHistory.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 3/7/24.
//

import Foundation

struct BrowserHistory: Codable {
    let title: String
    let url: String
    var lastVisitTimestamp: Double
    var visits: Int
    
    static func visitSorter(_ left: BrowserHistory, _ right: BrowserHistory) -> Bool {
        if left.visits == right.visits {
            return left.lastVisitTimestamp > right.lastVisitTimestamp
        } else {
            return left.visits > right.visits
        }
    }
}