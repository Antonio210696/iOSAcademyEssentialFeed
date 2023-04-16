//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 16/04/23.
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {
	
    func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.receivedMessages, [])
    }
	
	func test_save_requestsCacheDeletion() {
		let (sut, store) = makeSUT()
		
		let items = [uniqueItem(), uniqueItem() ]
		sut.save(items) { _ in }
		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
	}
	
	func test_save_doesNotRequestCacheInsertionOnDeletionError() {
		let (sut, store) = makeSUT()
		let items = [uniqueItem(), uniqueItem() ]
		let deletionError = anyNSError()
		
		sut.save(items) { _ in }
		store.completeDeletion(with: deletionError)
		
		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
	}
	
	func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
		let timestamp = Date()
		let (sut, store) = makeSUT(currentDate: { timestamp })
		let items = [uniqueItem(), uniqueItem() ]
		
		sut.save(items) { _ in }
		store.completeDeletionSuccessfully()
		
		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
	}
	
	func test_save_failsOnDeletionError() {
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()
		
		expect(sut, toCompleteWithError: deletionError) {
			store.completeDeletion(with: deletionError)
		}
	}
	
	func test_save_failsOnInsertError() {
		let (sut, store) = makeSUT()
		let insertionError = anyNSError()
		
		expect(sut, toCompleteWithError: insertionError, when: {
			store.completeDeletionSuccessfully()
			store.completeInsertion(with: insertionError)
		})
		
	}
	
	func test_save_succeedsOnSuccessfulCacheInsertion() {
		let (sut, store) = makeSUT()
		
		expect(sut, toCompleteWithError: nil, when: {
			store.completeDeletionSuccessfully()
			store.completeInsertionSuccessfully()
		})
	}
	
	func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		var receivedResults = [Error?]()
		sut?.save([uniqueItem()]) { receivedResults.append($0) }
		
		sut = nil
		store.completeDeletion(with: anyNSError())
		XCTAssertTrue(receivedResults.isEmpty)
	}
	
	func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		var receivedResults = [Error?]()
		sut?.save([uniqueItem()]) { receivedResults.append($0) }
		
		store.completeDeletionSuccessfully()
		sut = nil
		store.completeInsertion(with: anyNSError())
		XCTAssertTrue(receivedResults.isEmpty)
	}
	
	// MARK: - Helpers
	
	class FeedStoreSpy: FeedStore {
		typealias DeletionCompletion = (Error?) -> Void
		typealias InsertionCompletion = (Error?) -> Void
		
		enum ReceivedMessage: Equatable {
			case deleteCachedFeed
			case insert([FeedItem], Date)
		}
		
		private(set) var receivedMessages = [ReceivedMessage]()
		
		private var deletionCompletions = [DeletionCompletion]()
		private var insertionCompletions = [InsertionCompletion]()
		
		func deleteCachedFeed(completion: @escaping DeletionCompletion) {
			deletionCompletions.append(completion)
			receivedMessages.append(.deleteCachedFeed)
		}
		
		func completeDeletion(with error: Error, at index: Int = 0) {
			deletionCompletions[index](error)
		}
		
		func completeDeletionSuccessfully(at index: Int = 0) {
			deletionCompletions[index](nil)
		}
		
		func completeInsertion(with error: Error, at index: Int = 0) {
			insertionCompletions[index](error)
		}
		
		func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
			insertionCompletions.append(completion)
			receivedMessages.append(.insert(items, timestamp))
		}
		
		func completeInsertionSuccessfully(at index: Int = 0) {
			insertionCompletions[index](nil)
		}
	}
	
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		
		return (sut, store)
		
	}
	
	private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		
		let expectation = XCTestExpectation(description: "Wait for save completion")
		var receivedError: Error?
		 
		sut.save([uniqueItem()]) { error in
			receivedError = error
			expectation.fulfill()
			
		}
		action()
		
		wait(for: [expectation], timeout: 1.0)
		XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
	}
	private func uniqueItem() -> FeedItem {
		return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
	}
	
	private func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "Any error", code: 0)
	}
}