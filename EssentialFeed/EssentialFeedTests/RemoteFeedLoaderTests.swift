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
		
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load() { _ in }
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		var capturedError = [RemoteFeedLoader.Error]()
		sut.load { capturedError.append($0) }
		
		let clientError = NSError(domain: "Test", code: 0)
		client.complete(with: clientError)
		
		XCTAssertEqual(capturedError, [.connectivity])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		return (sut, client)
	}
	
	private class HTTPClientSpy: HTTPClient {
		var error: Error?
		var completions = [(Error) -> Void]()
		
		private var messages = [(url: URL, completion: (Error) -> Void)]()
		
		var requestedURLs: [URL] {
			return messages.map { $0.url }
		}
		
		func get(from url: URL, completion: @escaping (Error) -> Void) {
			messages.append((url, completion))
		}
		
		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(error)
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

// ========
// we have to think about client response. when client fails, we want to send an error
// when the client fails, it is a connectivity issue
// having defined the error that the feedloader can return, we have to stub the error in the client
// we send the error from the client to the remote feedloader with a completion inside the client
// the error in the client is different than the one in the feedloader

// when testing, we can store capturedErrors as we did for the produced values in arrays

// we stubbed the client, but it is a spy.
// before making it a spy, the client had to set the error in the "arrange"
// part of the test, but an error is more of an "act" phase event
