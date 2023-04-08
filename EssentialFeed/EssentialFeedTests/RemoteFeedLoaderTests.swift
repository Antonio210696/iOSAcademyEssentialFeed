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
		
		expect(sut, toCompleteWith: .failure(.connectivity), when: {
			let clientError = NSError(domain: "Test", code: 0)
			client.complete(with: clientError)
		})
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		
		let samples = [199, 201, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .failure(.invalidData), when: {
				client.complete(withStatusCode: code, at: index)
			})
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJson()  {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .failure(.invalidData), when: {
			let invalidJson = Data("invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJson)
		})
	}
	
	func test_load_deliverNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()

		
		expect(sut, toCompleteWith: .success([])) {
			let emptyListJSON = Data("{\"items\": []}".utf8)
			client.complete(withStatusCode: 200, data: emptyListJSON)
		}
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		return (sut, client)
	}
	
	private func expect(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		var capturedResults = [RemoteFeedLoader.Result]()
		sut.load { capturedResults.append($0) }
		
		action()
		
		XCTAssertEqual(capturedResults, [result], file: file, line: line)
	}
	
	private class HTTPClientSpy: HTTPClient {
		var error: Error?
		var completions = [(Error) -> Void]()
		
		private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
		
		var requestedURLs: [URL] {
			return messages.map { $0.url }
		}
		
		func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
			messages.append((url, completion))
		}
		
		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(.failure(error))
		}
		
		func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
			let response = HTTPURLResponse(
				url: requestedURLs[index],
				statusCode: code,
				httpVersion: nil,
				headerFields: nil
			)
			
			messages[index].completion(.success(data, response!))
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

// we stubbed the client, but it is a spy. Spies are test helpers that capture received messages
// before making it a spy, the client had to set the error in the "arrange"
// part of the test, but an error is more of an "act" phase event
// so we want to capture the urls and completions passed to the client

// spies have to capture messages that pass through them, in this case invocations to the get method of the client
// in this case, we can combine values passed to the get method in a  "message" tuple

// we handle the case of invalid data, we can do it with HTTPURLResponse
// at first we give completions two possible optionals.
// we want to make invalid paths unrepresentable, so we use enum instead of double optionals
// what if other cases appear, enums is easier to modify

// map the reponse of the client in feedItem
