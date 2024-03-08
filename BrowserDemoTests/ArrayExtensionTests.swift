//
//  ArrayExtensionTests.swift
//  BrowserDemoTests
//
//  Created by Collin Palmer on 3/7/24.
//

import XCTest
@testable import Orion

final class ArrayExtensionTests: XCTestCase {

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func testArrayUniq() throws {
        let history = [
            BrowserHistory(title: "Kagi", url: "https://kagi.com", lastVisitTimestamp: Date().timeIntervalSince1970, visits: 3),
            BrowserHistory(title: "Hacker News", url: "https://news.ycombinator.com", lastVisitTimestamp: Date().timeIntervalSince1970, visits: 1),
            BrowserHistory(title: "Hacker News", url: "https://news.ycombinator.com/ask", lastVisitTimestamp: Date().timeIntervalSince1970, visits: 2),
            BrowserHistory(title: "Wikipedia", url: "https://wikipedia.org", lastVisitTimestamp: Date().timeIntervalSince1970, visits: 5)
        ]
        
        let uniqHistory = history.unique({ URL(string: $0.url)!.host! })
        XCTAssert(uniqHistory.count == 3)
    }
}
