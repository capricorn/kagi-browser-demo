//
//  BrowserDemoTests.swift
//  BrowserDemoTests
//
//  Created by Collin Palmer on 2/26/24.
//

import XCTest
@testable import BrowserDemo

final class BrowserDemoTests: XCTestCase {
    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}
    
    func testURLRelativePath() throws {
        let url = URL(string: "extension:///Users/collin/Library/Developer/CoreSimulator/Devices/4C7E0ADB-5A09-43BA-9C30-EA41E4D26ADE/data/Containers/Bundle/Application/BED4C5FF-2B49-4385-B7F4-319492AC6EAC/BrowserDemo.app/top_sites_button-1.5/popup/panel.html")!
        let baseURL = URL(string: "extension:///Users/collin/Library/Developer/CoreSimulator/Devices/4C7E0ADB-5A09-43BA-9C30-EA41E4D26ADE/data/Containers/Bundle/Application/BED4C5FF-2B49-4385-B7F4-319492AC6EAC/BrowserDemo.app/top_sites_button-1.5/")!
        
        XCTAssert(url.relativePath(from: baseURL)?.absoluteString == "popup/panel.html")
    }
    
    func testSameBasePath() throws {
        let url = URL(string: "extension:///Users/collin/Library/Developer/CoreSimulator/Devices/4C7E0ADB-5A09-43BA-9C30-EA41E4D26ADE/data/Containers/Bundle/Application/BED4C5FF-2B49-4385-B7F4-319492AC6EAC/BrowserDemo.app/top_sites_button-1.5/popup/panel.html")!
        let baseURL = URL(string: "extension:///Users/collin/Library/Developer/CoreSimulator/Devices/4C7E0ADB-5A09-43BA-9C30-EA41E4D26ADE/data/Containers/Bundle/Application/BED4C5FF-2B49-4385-B7F4-319492AC6EAC/BrowserDemo.app/top_sites_button-1.5/")!
        
        let absoluteURL = URL(string: "extension:///popup/popup.html")!
        
        XCTAssert(url.sameBasePath(as: baseURL))
        XCTAssertFalse(url.sameBasePath(as: absoluteURL))
    }
}
