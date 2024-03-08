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
            .sorted(by: BrowserHistory.visitSorter)
            .unique({ URL(string: $0.url)!.host! }) // Default top sites behavior is to include each domain at most once.
            .prefix(10))
    }
    
    func updateHistory(_ url: URL?, siteTitle: String?=nil, lastVisit: Double=Date().timeIntervalSince1970) {
        if url?.host != nil, let url = url?.absoluteString {
            if let prevVisit = history[url] {
                var copy = prevVisit
                copy.visits += 1
                copy.lastVisitTimestamp = lastVisit
                history[url] = copy
            } else {
                var title = siteTitle ?? "Untitled"
                if let siteTitle, siteTitle.isEmpty {
                    title = "Untitled"
                }
                
                history[url] = BrowserHistory(title: title, url: url, lastVisitTimestamp: lastVisit, visits: 1)
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
    
    @discardableResult
    func installExtensionTask(_ xpiDownloadURL: URL) -> Task<Void, Never> {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: xpiDownloadURL)
                
                let extensionURL = try BrowserExtension.saveUnpacked(data, filename: xpiDownloadURL.lastPathComponent)
                
                DispatchQueue.main.async {
                    // TODO: Send unzip file url in this message
                    NotificationCenter.default.post(name: .orionInstalledBrowserExtension, object: extensionURL)
                }
            } catch {
                print("Extension install failed: \(error)")
            }
        }
    }
    
    func xpiAddonURL(_ url: URL) -> Bool {
        return url.host == "addons.mozilla.org" && url.absoluteString.hasSuffix(".xpi")
    }
}
