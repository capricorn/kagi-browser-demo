//
//  BrowserExtension.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 2/27/24.
//

import Foundation
import ZIPFoundation
import UIKit

class BrowserExtension {
    struct ManifestMissingError: Error {}
    struct ManifestSerializationError: Error {}
    
    var js: String?
    var icons: [UIImage] = []
    var manifest: ExtensionManifest!
    var unpackedURL: URL?
    
    private init() {}
    
    static func load(_ extensionRoot: URL, fileManager: FileManager = .default) throws -> BrowserExtension {
        let files = fileManager
        let manifestURL = (extensionRoot / "manifest.json")
        let ext = BrowserExtension()
        
        guard let manifestData = try? Data(contentsOf: manifestURL) else {
            throw ManifestMissingError()
        }
        
        guard let manifest = try? JSONDecoder().decode(ExtensionManifest.self, from: manifestData) else {
            throw ManifestSerializationError()
        }
        
        ext.manifest = manifest
        ext.icons = manifest.icon_paths
            .compactMap({ try? Data(contentsOf: extensionRoot.appendingPathComponent($0)) })
            .compactMap({ UIImage(data: $0) })
        ext.unpackedURL = extensionRoot
        
        return ext
    }
    
    @discardableResult
    static func saveUnpacked(_ xpi: Data, filename: String, extensionInstallDir: URL=FileManager.default.orionExtensionInstallDir) throws -> URL {
        let xpiURL = FileManager.default.temporaryDirectory / filename
        try xpi.write(to: xpiURL)
        
        let extractionURL = extensionInstallDir / "\(filename)_extracted"
        
        if extractionURL.fileExists() {
            try FileManager.default.removeItem(at: extractionURL)
        }
        
        try FileManager.default.createDirectory(at: extractionURL, withIntermediateDirectories: true)
        try FileManager.default.unzipItem(at: xpiURL, to: extractionURL)
        
        return extractionURL
    }
}
