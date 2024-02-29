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

extension FileManager {
    var orionExtensionInstallDir: URL {
        let appSupportURL = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let appDirName = "\(Bundle.main.bundleIdentifier!).Orion"
        let extensionURL = appSupportURL.appendingPathComponent(appDirName).appendingPathComponent("Extensions")
        
        if FileManager.default.fileExists(atPath: extensionURL.absoluteString) == false {
            try! FileManager.default.createDirectory(at: extensionURL, withIntermediateDirectories: true)
        }
        
        return extensionURL
    }
}

class BrowserExtension {
    struct MissingManifestError: Error {}
    
    var js: String?
    var icons: [UIImage] = []
    var manifest: ExtensionManifest!
    
    private init() {}
    
    static func extract(_ extensionData: Data) throws -> BrowserExtension {
        let fileManager = FileManager()
        let ext = BrowserExtension()
        let archive = try Archive(data: extensionData, accessMode: .read)
        
        guard let manifestEntry = archive["manifest.json"] else {
            throw MissingManifestError()
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
        
        if FileManager.default.fileExists(atPath: extractionURL.path) {
            try FileManager.default.removeItem(at: extractionURL)
        }
        try FileManager.default.createDirectory(at: extractionURL, withIntermediateDirectories: true)
        
        // TODO: Is this blocking?
        try FileManager.default.unzipItem(at: xpiURL, to: extractionURL)
        return extractionURL
    }
}
