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
		let (_, cacheSpy, loaderSpy) = makeSUT()
		
		XCTAssertTrue(cacheSpy.messages.isEmpty)
		XCTAssertTrue(loaderSpy.completions.isEmpty)
	}
	
	func test_loadImageData_deliversImageOnSuccessfulLoad() {
		let (sut, _, loaderSpy) = makeSUT()
		let feedImage = Data("Expected image".utf8)
		let url = anyURL()
		
		var receivedImage: Data?
		_ = sut.loadImageData(from: url) { receivedImage = try? $0.get() }
		loaderSpy.completeSuccessfully(with: feedImage)
		
		XCTAssertEqual(receivedImage, feedImage)
	}
	
	func test_loadImageData_cachesImageOnSuccessfulLoad() {
		let (sut, cacheSpy, loaderSpy) = makeSUT()
		let feedImage = Data("Expected image".utf8)
		let url = anyURL()
		
		_ = sut.loadImageData(from: url) { _ in }
		loaderSpy.completeSuccessfully(with: feedImage)
		
		XCTAssertEqual(cacheSpy.messages, [.save(image: feedImage, url: url)])
	}
	
	func test_loadImageData_cancelsTaskOnDecoratee() {
		let (sut, _, loaderSpy) = makeSUT()
		let feedImage = Data("Expected image".utf8)
		let url = anyURL()
		
		let task = sut.loadImageData(from: url) { _ in }
		task.cancel()
		loaderSpy.completeSuccessfully(with: feedImage)
		
		XCTAssertEqual(loaderSpy.cancelledURLs, [url])
	}
	
	func test_loadImageData_deliversErrorOnLoadFailure() {
		let (sut, _, loaderSpy) = makeSUT()
		let url = anyURL()
		let expectedError = anyNSError()
		
		var receivedError: NSError?
		_ = sut.loadImageData(from: url) { _ = $0.mapError {
			receivedError = $0 as NSError
			return $0
		}}
		
		loaderSpy.complete(with: expectedError)
		XCTAssertEqual(receivedError, expectedError)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderCacheDecorator, cacheSpy: ImageCacheSpy, loaderSpy: FeedImageDataLoaderSpy) {
		let cacheSpy = ImageCacheSpy()
		let loaderSpy = FeedImageDataLoaderSpy()
		let sut = FeedImageDataLoaderCacheDecorator(decoratee: loaderSpy, cache: cacheSpy)
		trackForMemoryLeaks(cacheSpy)
		trackForMemoryLeaks(loaderSpy)
		trackForMemoryLeaks(sut)
		
		return (sut, cacheSpy, loaderSpy)
	}
	
	private class FeedImageDataLoaderSpy: FeedImageDataLoader {
		typealias Completion = (FeedImageDataLoader.Result) -> Void
		var completions: [Completion] = []
		var cancelledURLs = [URL]()
		
		private struct Task: FeedImageDataLoaderTask {
			let callback: () -> Void
			func cancel() { callback() }
		}
		
		func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
			completions.append(completion)
			return Task() { self.cancelledURLs.append(url) }
		}
		
		func completeSuccessfully(with image: Data, at index: Int = 0) {
			completions[index](.success(image))
		}
		
		func complete(with error: NSError, at index: Int = 0) {
			completions[index](.failure(error))
		}
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