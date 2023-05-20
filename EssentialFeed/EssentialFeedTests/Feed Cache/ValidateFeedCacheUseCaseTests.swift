//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 20/04/23.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
	
    func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.receivedMessages, [])
    }
	
	func test_validateCache_deletesCacheOnRetrievalError() {
		let (sut, store) = makeSUT()
		
		sut.validateCache() { _ in }
		store.completeRetrieval(with: anyNSError())
		
		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
	}
	
	func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
		let (sut, store) = makeSUT()
		
		sut.validateCache() { _ in }
		store.completeRetrievalWithEmptyCache()
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_validateCache_doesNotDeleteCacheOnNonExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let nonExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
		let (sut, store) = makeSUT { fixedCurrentDate }
		
		sut.validateCache() { _ in }
		store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimeStamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_validateCache_deletesCacheOnExpirationCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
		let (sut, store) = makeSUT { fixedCurrentDate }
		
		sut.validateCache() { _ in }
		store.completeRetrieval(with: feed.local, timestamp: expirationTimeStamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
	}
	
	func test_validateCache_deletesCacheOnExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let expiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
		let (sut, store) = makeSUT { fixedCurrentDate }
		
		sut.validateCache() { _ in }
		store.completeRetrieval(with: feed.local, timestamp: expiredTimeStamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
	}
	
	func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		sut?.validateCache() { _ in }

		sut = nil
		
		store.completeRetrieval(with: anyNSError())
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()
		
		expect(sut, toCompleteWith: .failure(deletionError), when: {
			store.completeRetrieval(with: anyNSError())
			store.completeDeletion(with: deletionError)
		})
	}
	
	func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
		let (sut, store) = makeSUT()
		
		expect(sut, toCompleteWith: .success(()), when: {
			store.completeRetrieval(with: anyNSError())
			store.completeDeletionSuccessfully()
		})
	}
	
	// MARK: - Helpers
	
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		
		return (sut, store)
	}
	
	private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.ValidationResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		sut.validateCache { receivedResult in
			switch (receivedResult, expectedResult) {
			case (.success, .success):
				break
				
			case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
				
			default:
				XCTFail("Expected result \(expectedResult), got \(receivedResult)", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		action()
		wait(for: [exp], timeout: 1.0)
	}
}


