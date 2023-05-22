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
		let sut = makeSUT(loaderResult: .success(feed))
		
		expect(sut, toCompleteWith: .success(feed))
	}

	func test_load_deliversErrorOnLoadedFailure() {
		let sut = makeSUT(loaderResult: .failure(anyNSError()))
		
		expect(sut, toCompleteWith: .failure(anyNSError()))
	}
	
	private func makeSUT(loaderResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoader {
		let loader = FeedLoaderStub(result: loaderResult)
		let sut = FeedLoaderCacheDecorator(decoratee: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
}
