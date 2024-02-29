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
