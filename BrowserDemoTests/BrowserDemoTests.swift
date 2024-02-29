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
    
    func testSaveUnpacked() throws {
        let tmpExtensionsDir = FileManager.default.temporaryDirectory / self.name
        try FileManager.default.createDirectory(at: tmpExtensionsDir, withIntermediateDirectories: true)
        
        let extractDirName = UUID().uuidString
        let resultURL = try BrowserExtension.saveUnpacked(self.extensionData, filename: extractDirName, extensionInstallDir: tmpExtensionsDir)
        
        XCTAssert(resultURL.lastPathComponent == "\(extractDirName)_extracted")
        XCTAssert(FileManager.default.fileExists(atPath: resultURL.path))
        XCTAssert(FileManager.default.fileExists(atPath: (resultURL / "manifest.json").path))
    }
}
