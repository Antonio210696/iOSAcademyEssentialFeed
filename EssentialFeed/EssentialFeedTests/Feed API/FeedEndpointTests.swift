//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 10/08/23.
//

import XCTest
import EssentialFeed

class FeedEndpointTests: XCTestCase {
	func test_feed_endpointURL() {
		let baseURL = URL(string: "http://base-url.com")!
		
		let received = FeedEndpoint.get.url(baseURL: baseURL)
		let expected = URL(string: "http://base-url.com/v1/feed?limit=10")!
		
		XCTAssertEqual(received, expected)
		XCTAssertEqual(received.scheme, "http", "scheme")
		XCTAssertEqual(received.host, "base-url.com", "host")
		XCTAssertEqual(received.path, "/v1/feed", "path")
		XCTAssertEqual(received.query, "limit=10", "query")
	}
}
