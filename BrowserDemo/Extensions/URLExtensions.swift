//
//  URLExtensions.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 2/29/24.
//

import Foundation

func / (_ url: URL, _ path: String) -> URL {
    url.appendingPathComponent(path)
}

extension URL {
    func fileExists(_ manager: FileManager=FileManager.default) -> Bool {
        manager.fileExists(atPath: self.path)
    }
    
    func printFileTree(_ manager: FileManager=FileManager.default) {
        if let enumerator = FileManager.default.enumerator(at: self, includingPropertiesForKeys: nil) {
            for filename in enumerator {
                print("\((filename as? NSURL)?.relativeString)")
            }
        }
    }
    
    func relativePath(from base: URL) -> URL? {
        let components = self.pathComponents
        let baseComponents = base.pathComponents
        
        var i = 0
        while i < components.count {
            if baseComponents.count-1 >= i, components[i] == baseComponents[i] {
                i += 1
                continue
            }
            break
        }
        
        if i < components.count {
            let relativeComponents = components[components.index(components.startIndex, offsetBy: i)...]
            return URL(string: relativeComponents.joined(separator: "/"))
        }
        
        return nil
    }
    
    func sameBasePath(as otherURL: URL) -> Bool {
        for (c1, c2) in zip(self.pathComponents, otherURL.pathComponents) {
            if c1 != c2 {
                return false
            }
        }
        
        return true
    }
    
    var extensionScheme: URL {
        URL(string: "extension://" + self.path)!
    }
    
    var fileScheme: URL {
        URL(string: "file://" + self.path)!
    }
    
    var isExtensionURL: Bool {
        return self.scheme == "extension"
    }
    
    var mimeType: String? {
        let file = self.lastPathComponent
        let mimeMap = [
            "css": "text/css",
            "js": "text/javascript",
            "png": "image/png",
            "html": "text/html" ]
        
        return mimeMap.first(where: { key, _ in file.hasSuffix(key) })?.value
    }
}
