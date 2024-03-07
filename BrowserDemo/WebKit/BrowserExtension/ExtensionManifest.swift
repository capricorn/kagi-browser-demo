//
//  ExtensionManifest.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 2/27/24.
//

import Foundation

struct ExtensionManifest: Decodable {
    var icon_paths: [String]
    var name: String
    var popupHTMLPath: String?
    
    private struct BrowserAction: Decodable {
        var popupPath: String
        
        enum CodingKeys: String, CodingKey {
            case popupPath = "default_popup"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case iconPaths = "icons"
        case name
        case browserAction = "browser_action"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let icons = try container.decode([String: String].self, forKey: .iconPaths)
        self.icon_paths = Array(icons.values)
        self.name = try container.decode(String.self, forKey: .name)
        
        if let browserAction = try container.decodeIfPresent(BrowserAction.self, forKey: .browserAction) {
            self.popupHTMLPath = browserAction.popupPath
        }
    }
}
