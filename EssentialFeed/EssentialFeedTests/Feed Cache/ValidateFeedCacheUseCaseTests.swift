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
		
		sut.validateCache()
		store.completeRetrieval(with: anyNSError())
		
		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
	}
	
	func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
		let (sut, store) = makeSUT()
		
		sut.validateCache()
		store.completeRetrievalWithEmptyCache()
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_validateCache_doesNotDeleteCacheOnLessThanSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
		let (sut, store) = makeSUT { fixedCurrentDate }
		
		sut.validateCache()
		store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimeStamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		
		return (sut, store)
	}
	
	private func uniqueImage() -> FeedImage {
		return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
	}
	
	private func uniqueImageFeed() -> (model: [FeedImage], local: [LocalFeedImage]) {
		let models = [uniqueImage(), uniqueImage()]
		let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
		
		return (models, local)
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "Any error", code: 0)
	}
	
	private func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}
}

private extension Date {
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
	
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
}
