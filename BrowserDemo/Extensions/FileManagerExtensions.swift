//
//  FileManagerExtensions.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 3/7/24.
//

import Foundation

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
