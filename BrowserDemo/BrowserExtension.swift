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
}
