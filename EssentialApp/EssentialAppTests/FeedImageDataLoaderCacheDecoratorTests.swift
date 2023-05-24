//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialAppTests
//
//  Created by Antonio Epifani on 24/05/23.
//

import XCTest
import EssentialFeed

protocol FeedImageDataCache { }

final class FeedImageDataLoaderCacheDecorator {
	init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) { }
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {
	func test_init_doesSendAnyMessage() {
		let (_, cacheSpy, _) = makeSUT()
		
		XCTAssertTrue(cacheSpy.messages.isEmpty)
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
		var messages: [Message] = []
		
		enum Message { }
		
		private struct Task: FeedImageDataLoaderTask {
			func cancel() { }
		}
		
		func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
			return Task()
		}
	}
	
	private class ImageCacheSpy: FeedImageDataCache {
		var messages: [Message] = []
		
		enum Message { }
	}
}
