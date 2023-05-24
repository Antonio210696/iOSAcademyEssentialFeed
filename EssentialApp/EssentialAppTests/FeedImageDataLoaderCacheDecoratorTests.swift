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
		let cacheSpy = ImageCacheSpy()
		let loaderSpy = FeedImageDataLoaderSpy()
		_ = FeedImageDataLoaderCacheDecorator(decoratee: loaderSpy, cache: cacheSpy)
		
		XCTAssertTrue(cacheSpy.messages.isEmpty)
	}
	
	// MARK: - Helpers
	
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
