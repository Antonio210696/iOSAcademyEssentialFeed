//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 07/04/23.
//

import XCTest

class RemoteFeedLoader {
	
}

class HTTPClient {
	var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
	
	func test_init() {
		let client = HTTPClient()
		_ = RemoteFeedLoader()
		
		// we want a collaborator to make the request
		XCTAssertNil(client.requestedURL)
	}
}
