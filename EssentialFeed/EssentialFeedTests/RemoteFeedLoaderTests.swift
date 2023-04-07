//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 07/04/23.
//

import XCTest

class RemoteFeedLoader {
	let client: HTTPClient
	init(client: HTTPClient) {
		self.client = client
	}
	func load() {
		client.get(from: URL(string: "https://a-rul.com")!)
	}
}

protocol HTTPClient {
	func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
	func get(from url: URL) {
		requestedURL = url
	}
	
	var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
	
	func test_init() {
		let client = HTTPClientSpy()
		_ = RemoteFeedLoader(client: client)
		
		// we want a collaborator to make the request
		XCTAssertNil(client.requestedURL)
	}
	
	func test_load_requestDataFromURL() {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(client: client)
		
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
// HTTPClientSpy allows to move test logic to a separate class that can become the shared instance
// HTTPClient can be injected and it can be a protocol, so that the feed loader doesn t need to know the concrete type of HTTPClient
