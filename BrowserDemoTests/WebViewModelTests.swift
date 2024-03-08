//
//  WebViewModelTests.swift
//  BrowserDemoTests
//
//  Created by Collin Palmer on 3/7/24.
//

import XCTest
@testable import BrowserDemo

final class WebViewModelTests: XCTestCase {
    var viewModel: WebViewModel!

    override func setUpWithError() throws {
        viewModel = WebViewModel()
    }

    override func tearDownWithError() throws {}

    func testTopSites() throws {
        viewModel.updateHistory(URL(string: "https://kagi.com")!)
        viewModel.updateHistory(URL(string: "https://kagi.com")!)
        viewModel.updateHistory(URL(string: "https://kagi.com")!)
        
        viewModel.updateHistory(URL(string: "https://marginalia.nu")!)
        
        viewModel.updateHistory(URL(string: "https://wikipedia.com")!)
        viewModel.updateHistory(URL(string: "https://wikipedia.com")!)
        
        viewModel.updateHistory(URL(string: "https://test4.com")!)
        viewModel.updateHistory(URL(string: "https://test5.com")!)
        viewModel.updateHistory(URL(string: "https://test6.com")!)
        viewModel.updateHistory(URL(string: "https://test7.com")!)
        viewModel.updateHistory(URL(string: "https://test8.com")!)
        viewModel.updateHistory(URL(string: "https://test9.com")!)
        viewModel.updateHistory(URL(string: "https://test10.com")!)
        viewModel.updateHistory(URL(string: "https://test11.com")!)
        
        let topSites = viewModel.topSites
        XCTAssert(topSites.first?.url == "https://kagi.com")
        XCTAssert(topSites.first?.visits == 3)
        XCTAssert(topSites.count >= 1 && topSites[1].url == "https://wikipedia.com")
        XCTAssert(topSites.count == 10)
        // Marginalia is the oldest of all visits with a visit count of 1 and hence is excluded.
        XCTAssertFalse(topSites.contains(where: { $0.url == "https://marginalia.nu" }), "\(topSites)")
        // '4' is therefore the oldest of the visit=1 history and therefore sorted last.
        XCTAssert(topSites.last?.url == "https://test4.com")
    }
}
