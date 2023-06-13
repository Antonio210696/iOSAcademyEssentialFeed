//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 07/04/23.
//

import XCTest
import EssentialFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		
		let samples = [199, 201, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				let json = makeItemJson([])
				client.complete(withStatusCode: code, data: json, at: index)
			})
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJson()  {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: failure(.invalidData), when: {
			let invalidJson = Data("invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJson)
		})
	}
	
	func test_load_deliverNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()

		
		expect(sut, toCompleteWith: .success([])) {
			let emptyListJSON = makeItemJson([])
			client.complete(withStatusCode: 200, data: emptyListJSON)
		}
	}
	
	func test_load_deliversFeedItemsOn200HTTPResponseWithJSONItems() {
		let (sut, client) = makeSUT()
		
		let item1 = makeItem(
			id: UUID(),
			description: nil,
			location: nil,
			imageURL: URL(string: "http://a-url.com")!
		)
		
		let item2 = makeItem(
			id: UUID(),
			description: "a description",
			location: "a location",
			imageURL: URL(string: "http://another-url.com")!
		)
		
		let items = [item1.model, item2.model]
		expect(sut, toCompleteWith: .success(items)) {
			let json = makeItemJson([item1.json, item2.json])
			client.complete(withStatusCode: 200, data: json)
		}
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		// assertions to check for memory leak
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func makeItemJson(_ items: [[String: Any]]) -> Data {
		let itemsJSON = ["items": items]
		return try! JSONSerialization.data(withJSONObject: itemsJSON)
	}
	
	private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
		return .failure(error)
	}
	
	private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
		let item = FeedImage(id: id, description: description, location: location, url: imageURL)
		let json = [
			"id": id.uuidString,
			"description": description,
			"location": location,
			"image": imageURL.absoluteString
		].compactMapValues { $0 }
		
		return (item, json)
	}
	private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		
		let exp = expectation(description: "Wait for load completion")
		
		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
			case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
				
			default:
				XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		action()
		
		wait(for: [exp], timeout: 1.0)
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
