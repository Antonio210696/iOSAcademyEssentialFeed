//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 07/04/23.
//

import XCTest

class RemoteFeedLoader {
	let client: HTTPClient
	let url: URL
	
	init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	func load() {
		client.get(from: url)
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
		let url = URL(string: "https://a-given-url.com")!
		let client = HTTPClientSpy()
		_ = RemoteFeedLoader(url: url, client: client)
		
		// we want a collaborator to make the request
		XCTAssertNil(client.requestedURL)
	}
	
	func test_load_requestDataFromURL() {
		let url = URL(string: "https://a-given-url.com")!
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		
		sut.load()
		
		XCTAssertEqual(client.requestedURL, url)
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
// FeedLoader doesnt need to know the URL, it can be injected. It should not be injected in the load, as the client of the feed loader don t
// know the URL
