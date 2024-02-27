//
//  BrowserDemoTests.swift
//  BrowserDemoTests
//
//  Created by Collin Palmer on 2/26/24.
//

import XCTest
@testable import BrowserDemo

final class BrowserDemoTests: XCTestCase {
    var testBundle: Bundle!
    var extensionData: Data!

    override func setUpWithError() throws {
        self.testBundle = Bundle(for: type(of: self))
        self.extensionData = try Data(contentsOf: testBundle.url(forResource: "top_sites_button-1.5", withExtension: "xpi")!)
    }

    override func tearDownWithError() throws {}

    func testExtensionManifestExtraction() throws {
        let ext = try BrowserExtension.extract(extensionData)
        XCTAssert(ext.manifest.icon_paths.contains("icons/16-flame.png"), "\(ext.manifest.icon_paths)")
    }
    
    func testExtensionIconExtraction() throws {
        let ext = try BrowserExtension.extract(extensionData)
        XCTAssert(ext.icons.count == 4)
    }
}
