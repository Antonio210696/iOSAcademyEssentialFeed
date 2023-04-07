//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 07/04/23.
//

import XCTest

class RemoteFeedLoader {
	func load() {
		HTTPClient.shared.get(from: URL(string: "https://a-rul.com")!)
	}
}

class HTTPClient {
	static var shared = HTTPClient()
	
	func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
	override func get(from url: URL) {
		requestedURL = url
	}
	
	var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
	
	func test_init() {
		let client = HTTPClientSpy()
		HTTPClient.shared = client
		_ = RemoteFeedLoader()
		
		// we want a collaborator to make the request
		XCTAssertNil(client.requestedURL)
	}
	
	func test_load_requestDataFromURL() {
		let client = HTTPClientSpy()
		HTTPClient.shared = client
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
// if we make the shared a var, we open possibilities for subclassing and spying inside that class
