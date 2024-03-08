//
//  SearchDelegateTests.swift
//  BrowserDemoTests
//
//  Created by Collin Palmer on 3/7/24.
//

import XCTest
@testable import Orion

final class SearchDelegateTests: XCTestCase {
    private var delegate: SearchDelegate!

    override func setUpWithError() throws {
        delegate = SearchDelegate()
    }

    override func tearDownWithError() throws {}

    /// E.g. navigating to 'kagi.com' should resolve to 'https://kagi.com'.
    func testAutoPrefixDomainWithHTTPS() throws {
        let query = "kagi.com"
        XCTAssert(delegate.adjustQuery(query) == ("https://" + query))
    }
    
    /// E.g. `http://kagi.com` or `https://kagi.com` should remain unchanged.
    func testPreserveHTTPDomain() throws {
        let httpQuery = "http://kagi.com"
        let httpsQuery = "https://kagi.com"
        
        XCTAssert(delegate.adjustQuery(httpQuery) == httpQuery)
        XCTAssert(delegate.adjustQuery(httpsQuery) == httpsQuery)
    }
    
    /// Any search that is not a domain will instead resolve as a marginalia query.
    func testRewriteSearchAsMarginaliaQuery() throws {
        let marginalia = SearchDelegate.marginaliaQuery
        let query1 = "software correctness"
        let query2 = "swift"
        
        XCTAssert(delegate.adjustQuery(query1) == (marginalia + "software+correctness"))
        XCTAssert(delegate.adjustQuery(query2) == (marginalia + "swift"))
    }
}
