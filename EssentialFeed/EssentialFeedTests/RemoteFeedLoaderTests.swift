//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 07/04/23.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
	
	func test_init() {
		let (_, client) = makeSUT()
		
		// we want a collaborator to make the request
		XCTAssert(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load()
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load()
		sut.load()
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		client.error = NSError(domain: "Test", code: 0)
		
		var capturedError: RemoteFeedLoader.Error?
		sut.load { error in capturedError = error}
		
		XCTAssertEqual(capturedError, .connectivity)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		return (sut, client)
	}
	
	private class HTTPClientSpy: HTTPClient {
		var requestedURLs = [URL]()
		var error: Error?
		
		func get(from url: URL, completion: @escaping (Error) -> Void) {
			if let error = error {
				completion(error)
			}
			requestedURLs.append(url)
		}
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
// HTTPClient can be injected and it can be a protocol, so that the feed loader doesn t need to know the concrete type of HTTPClient (tight coupling)
// by conforming to protocol, we could even avoid creating a type, just extend an existing type to conform to that.

// FeedLoader doesnt need to know the URL, it can be injected. It should not be injected in the load, as the client of the feed loader don t
// know the URL

// refactoring with tests backing up allows to refactor with confidence.

// just asserting a value is not enough, what if that method is called multiple times?
// we could have a counter to update whenever the spied function is called
// but better, we could have an array that stores values produced by that method, so that we can test
// quality, order and quantity.
