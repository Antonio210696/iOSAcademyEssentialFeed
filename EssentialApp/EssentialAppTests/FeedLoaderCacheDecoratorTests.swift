//
//  FeedLoaderCacheDecorator.swift
//  EssentialAppTests
//
//  Created by Antonio Epifani on 22/05/23.
//

import EssentialFeed
import XCTest

final class FeedLoaderCacheDecorator: FeedLoader {
	private let decoratee: FeedLoader
	init(decoratee: FeedLoader) {
		self.decoratee = decoratee
	}
	
	func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
		decoratee.load(completion: completion)
	}
}

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
	func test_load_deliversFeedOnLoaderSuccess() {
		let feed = uniqueFeed()
		let loader = FeedLoaderStub(result: .success(feed))
		let sut = FeedLoaderCacheDecorator(decoratee: loader)
		
		expect(sut, toCompleteWith: .success(feed))
	}

	func test_load_deliversErrorOnLoadedFailure() {
		let loader = FeedLoaderStub(result: .failure(anyNSError()))
		let sut = FeedLoaderCacheDecorator(decoratee: loader)
		
		expect(sut, toCompleteWith: .failure(anyNSError()))
	}
}
