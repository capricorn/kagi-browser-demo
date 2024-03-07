//
//  BrowserExtension.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 2/27/24.
//

import Foundation
import ZIPFoundation
import UIKit

extension NSNotification.Name {
    static let installedBrowserExtension = Notification.Name("installed-extension")
}

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
        
        // TODO: Set popup html url
        ext.manifest = manifest
        ext.icons = manifest.icon_paths
            .compactMap({ try? Data(contentsOf: extensionRoot.appendingPathComponent($0)) })
            .compactMap({ UIImage(data: $0) })
        ext.unpackedURL = extensionRoot
        
        return ext
    }
    
    static func extract(_ extensionData: Data) throws -> BrowserExtension {
        let fileManager = FileManager()
        let ext = BrowserExtension()
        let archive = try Archive(data: extensionData, accessMode: .read)
        
        guard let manifestEntry = archive["manifest.json"] else {
            throw ManifestMissingError()
        }
        
        _ = try archive.extract(manifestEntry) { data in
            ext.manifest = try JSONDecoder().decode(ExtensionManifest.self, from: data)
        }
        
        for iconPath in ext.manifest.icon_paths {
            guard let iconEntry = archive[iconPath] else {
                print("Failed to load icon at path \(iconPath)")
                continue
            }
            
            _ = try archive.extract(iconEntry) { data in
                if let icon = UIImage(data: data) {
                    ext.icons.append(icon)
                } else {
                    print("Failed to load icon as UIImage at path \(iconPath)")
                }
            }
        }
        
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
