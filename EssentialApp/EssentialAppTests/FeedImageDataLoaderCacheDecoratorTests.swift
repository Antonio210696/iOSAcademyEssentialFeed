//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialAppTests
//
//  Created by Antonio Epifani on 24/05/23.
//

import XCTest
import EssentialFeed

protocol FeedImageDataCache {
	typealias Result = Swift.Result<Void, Swift.Error>
	
	func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
	private let decoratee: FeedImageDataLoader
	private let cache: FeedImageDataCache
	
	private final class Task: FeedImageDataLoaderTask {
		var wrapped: FeedImageDataLoaderTask?
		
		func cancel() {
			wrapped?.cancel()
		}
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		let task = Task()
		task.wrapped = decoratee.loadImageData(from: url) { [weak self] result in
			if let data = try? result.get() {
				self?.cache.save(data, for: url) { _ in }
			}
			completion(result)
		}
		
		return task
	}
	
	init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
		self.decoratee = decoratee
		self.cache = cache
	}
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {
	func test_init_doesSendAnyMessage() {
		let cacheSpy = ImageCacheSpy()
		let (_, loaderSpy) = makeSUT(cache: cacheSpy)
		
		XCTAssertTrue(cacheSpy.messages.isEmpty)
		XCTAssertTrue(loaderSpy.completions.isEmpty)
	}
	
	func test_loadImageData_loadsFromDecoratee() {
		let (sut, loaderSpy) = makeSUT()
		let url = anyURL()
		
		_ = sut.loadImageData(from: url) { _ in }
		
		XCTAssertEqual(loaderSpy.loadedURLs, [url])
	}
	
	func test_loadImageData_deliversImageOnSuccessfulLoad() {
		let (sut, loaderSpy) = makeSUT()
		let feedImage = Data("Expected image".utf8)
		let url = anyURL()

		expect(sut, for: url, toCompleteWith: .success(feedImage), when: {
			loaderSpy.completeSuccessfully(with: feedImage)
		})
	}
	
	func test_loadImageData_cachesImageOnSuccessfulLoad() {
		let cacheSpy = ImageCacheSpy()
		let (sut, loaderSpy) = makeSUT(cache: cacheSpy)
		let feedImage = Data("Expected image".utf8)
		let url = anyURL()
		
		_ = sut.loadImageData(from: url) { _ in }
		loaderSpy.completeSuccessfully(with: feedImage)
		
		XCTAssertEqual(cacheSpy.messages, [.save(image: feedImage, url: url)])
	}
	
	func test_loadImageData_cancelsTaskOnDecoratee() {
		let (sut, loaderSpy) = makeSUT()
		let url = anyURL()
		
		let task = sut.loadImageData(from: url) { _ in }
		task.cancel()
		
		XCTAssertEqual(loaderSpy.cancelledURLs, [url])
	}
	
	func test_loadImageData_deliversErrorOnLoadFailure() {
		let (sut, loaderSpy) = makeSUT()
		let url = anyURL()
		let expectedError = anyNSError()
		
		expect(sut, for: url, toCompleteWith: .failure(expectedError), when: {
			loaderSpy.complete(with: expectedError)
		})
	}
	
	// MARK: - Helpers
	
	private func makeSUT(cache: FeedImageDataCache = ImageCacheSpy.init(), file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderCacheDecorator, loaderSpy: FeedImageDataLoaderSpy) {
		let loaderSpy = FeedImageDataLoaderSpy()
		let sut = FeedImageDataLoaderCacheDecorator(decoratee: loaderSpy, cache: cache)
		trackForMemoryLeaks(loaderSpy)
		trackForMemoryLeaks(sut)
		
		return (sut, loaderSpy)
	}
	
	private func expect(_ sut: FeedImageDataLoader, for url: URL, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = 0) {
		let exp = expectation(description: "Wait for load to complete")
		_ = sut.loadImageData(from: url) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedImage), .success(expectedImage)):
				XCTAssertEqual(receivedImage, expectedImage, "Expected to receive \(expectedImage), got \(receivedImage) instead", file: file, line: line)
				
			case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
				XCTAssertEqual(receivedError, expectedError, "Expected to receive error \(expectedError), got \(receivedError) instead", file: file, line: line)
				
			default:
				XCTFail("Expected result \(expectedResult), got \(receivedResult), instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		action()
		wait(for: [exp], timeout: 1.0)
	}
	
	private class ImageCacheSpy: FeedImageDataCache {
		var messages: [Message] = []
		
		enum Message: Equatable {
			case save(image: Data, url: URL)
		}
		
		func save(_ data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
			messages.append(.save(image: data, url: url))
		}
	}
}
