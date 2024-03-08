//
//  BrowserExtensionTests.swift
//  BrowserDemoTests
//
//  Created by Collin Palmer on 3/7/24.
//

import XCTest
@testable import Orion

final class BrowserExtensionTests: XCTestCase {
    var testBundle: Bundle!
    var extensionData: Data!
    var unpackedExtensionRoot: URL!

    override func setUpWithError() throws {
        self.testBundle = Bundle(for: type(of: self))
        self.extensionData = try Data(contentsOf: testBundle.url(forResource: "top_sites_button-1.5", withExtension: "xpi")!)
        self.unpackedExtensionRoot = testBundle.url(forResource: "top_sites_button-1.5", withExtension: "")
    }

    override func tearDownWithError() throws {}

    func testSaveUnpacked() throws {
        let tmpExtensionsDir = FileManager.default.temporaryDirectory / self.name
        try FileManager.default.createDirectory(at: tmpExtensionsDir, withIntermediateDirectories: true)
        
        let extractDirName = UUID().uuidString
        let resultURL = try BrowserExtension.saveUnpacked(self.extensionData, filename: extractDirName, extensionInstallDir: tmpExtensionsDir)
        
        XCTAssert(resultURL.lastPathComponent == "\(extractDirName)_extracted")
        XCTAssert(resultURL.fileExists())
        XCTAssert((resultURL / "manifest.json").fileExists())
    }
    
    func testExtensionLoad() throws {
        let ext = try BrowserExtension.load(self.unpackedExtensionRoot)
        XCTAssert(ext.icons.count == 4)
        XCTAssert(ext.manifest.popupHTMLPath == "popup/panel.html")
    }
}
