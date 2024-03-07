//
//  WebViewModel.swift
//  BrowserDemo
//
//  Created by Collin Palmer on 3/7/24.
//

import Foundation

class WebViewModel {
    var history: [String: BrowserHistory] = [:]
    
    var topSites: [BrowserHistory] {
        Array(history
            .map({$0.value})
            .sorted(by: { $0.visits > $1.visits })
            .prefix(10))
    }
    
    func updateHistory(_ url: URL?, siteTitle: String?=nil) {
        if let url = url?.absoluteString {
            if let prevVisit = history[url] {
                var copy = prevVisit
                copy.visits += 1
                history[url] = copy
            } else {
                var title = siteTitle ?? "Untitled"
                if let siteTitle, siteTitle.isEmpty {
                    title = "Untitled"
                }
                
                history[url] = BrowserHistory(title: title, url: url, visits: 1)
            }
        }
    }
    
    func handleExtensionRequest(_ request: URLRequest) throws -> (Data, URLResponse) {
        let baseExtensionURL = FileManager.default.orionExtensionInstallDir
        var fileURL = request.url!.fileScheme
        
        // This is an absolute extension request
        if fileURL.sameBasePath(as: baseExtensionURL) == false {
            let extensionName = request.mainDocumentURL!.relativePath(from: baseExtensionURL)!.pathComponents[0]
            fileURL = baseExtensionURL.appendingPathComponent(extensionName).appendingPathComponent(request.url!.path)
        }
        
        let extensionData = try! Data(contentsOf: fileURL)
        let mimeType = fileURL.mimeType ?? "text/plain"
        let urlResponse = HTTPURLResponse(
            url: request.url!,
            mimeType: mimeType,
            expectedContentLength: extensionData.count,
            textEncodingName: "utf8")
        
        return (extensionData, urlResponse)
    }
}
