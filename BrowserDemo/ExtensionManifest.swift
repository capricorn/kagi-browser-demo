//
//  ExtensionManifest.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 2/27/24.
//

import Foundation

struct ExtensionManifest: Decodable {
    var icon_paths: [String]
    
    enum CodingKeys: String, CodingKey {
        case icon_paths = "icons"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let icons = try container.decode([String: String].self, forKey: .icon_paths)
        self.icon_paths = Array(icons.values)
    }
}
