//
//  BrowserToolbarViewModel.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 3/7/24.
//

import Foundation
import Combine

class BrowserToolbarViewModel {
    var extensions: [BrowserExtension] = []
    var extensionInstallSubscriber: AnyCancellable? = nil
    
    init() {}
    
    func installExtension(_ extensionURL: URL) throws -> BrowserExtension {
        let extensionRootURL = extensionURL.fileScheme
        let ext = try BrowserExtension.load(extensionRootURL)
        
        self.extensions.append(ext)
        return ext
    }
}
