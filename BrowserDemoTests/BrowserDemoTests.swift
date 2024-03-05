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
    var unpackedExtensionRoot: URL!

    override func setUpWithError() throws {
        self.testBundle = Bundle(for: type(of: self))
        self.extensionData = try Data(contentsOf: testBundle.url(forResource: "top_sites_button-1.5", withExtension: "xpi")!)
        self.unpackedExtensionRoot = testBundle.url(forResource: "top_sites_button-1.5", withExtension: "")
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
        XCTAssert(resultURL.fileExists())
        XCTAssert((resultURL / "manifest.json").fileExists())
    }
    
    func testTopSitesBundleAcces() throws {
        XCTAssert(testBundle.url(forResource: "TopSitesAPI", withExtension: "js") != nil)
    }
    
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
    
    func testExtensionLoad() throws {
        let ext = try BrowserExtension.load(self.unpackedExtensionRoot)
        XCTAssert(ext.icons.count == 4)
        XCTAssert(ext.manifest.popupHTMLPath == "popup/panel.html")
    }
}
