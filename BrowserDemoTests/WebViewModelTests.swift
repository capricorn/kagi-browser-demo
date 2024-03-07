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
        viewModel.updateHistory(URL(string: "4")!)
        viewModel.updateHistory(URL(string: "5")!)
        viewModel.updateHistory(URL(string: "6")!)
        viewModel.updateHistory(URL(string: "7")!)
        viewModel.updateHistory(URL(string: "8")!)
        viewModel.updateHistory(URL(string: "9")!)
        viewModel.updateHistory(URL(string: "10")!)
        viewModel.updateHistory(URL(string: "11")!) // Excluded
        
        let topSites = viewModel.topSites
        XCTAssert(topSites.first?.url == "https://kagi.com")
        XCTAssert(topSites.first?.visits == 3)
        XCTAssert(topSites.count >= 1 && topSites[1].url == "https://wikipedia.com")
        // Top sites truncate to the top 10 most visited.
        XCTAssert(topSites.last?.url == "10")
    }
}
