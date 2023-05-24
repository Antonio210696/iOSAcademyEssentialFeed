//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialAppTests
//
//  Created by Antonio Epifani on 24/05/23.
//

import XCTest
import EssentialFeed

protocol FeedImageDataCache { }

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
	private let decoratee: FeedImageDataLoader
	private struct Task: FeedImageDataLoaderTask {
		func cancel() { }
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		return decoratee.loadImageData(from: url, completion: completion)
	}
	
	init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
		self.decoratee = decoratee
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
		
		private struct Task: FeedImageDataLoaderTask {
			func cancel() { }
		}
		
		func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
			completions.append(completion)
			return Task()
		}
		
		func completeSuccessfully(with image: Data, at index: Int = 0) {
			completions[index](.success(image))
		}
	}
	
	private class ImageCacheSpy: FeedImageDataCache {
		var messages: [Message] = []
		
		enum Message { }
	}
}
