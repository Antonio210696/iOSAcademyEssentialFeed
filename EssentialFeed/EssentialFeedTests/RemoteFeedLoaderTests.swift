//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 07/04/23.
//

import XCTest

class RemoteFeedLoader {
	func load() {
		HTTPClient.shared.requestedURL = URL(string: "https://a-rul.com")
	}
}

class HTTPClient {
	static let shared = HTTPClient()
	
	private init() { }
	var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
	
	func test_init() {
		let client = HTTPClient.shared
		_ = RemoteFeedLoader()
		
		// we want a collaborator to make the request
		XCTAssertNil(client.requestedURL)
	}
	
	func test_load_requestDataFromURL() {
		let client = HTTPClient.shared
		let sut = RemoteFeedLoader()
		
		sut.load()
		
		XCTAssertNotNil(client.requestedURL)
	}
}

// Different ways to inject HTTPClient
// 1. through init
// 2. thorugh prop injection
//
// lets start with singleton, which is much more concrete. We are not required to have
// a single instance of HTTPClient, but lets stick with that in a first moment
