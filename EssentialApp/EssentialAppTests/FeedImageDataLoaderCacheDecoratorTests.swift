//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialAppTests
//
//  Created by Antonio Epifani on 24/05/23.
//

import XCTest
import EssentialApp
import EssentialFeed

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
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
	
	func test_loadImageData_cachesImageOnSuccessfulLoad() {
		let cacheSpy = ImageCacheSpy()
		let (sut, loaderSpy) = makeSUT(cache: cacheSpy)
		let feedImage = Data("Expected image".utf8)
		let url = anyURL()
		
		_ = sut.loadImageData(from: url) { _ in }
		loaderSpy.completeSuccessfully(with: feedImage)
		
		XCTAssertEqual(cacheSpy.messages, [.save(image: feedImage, url: url)])
	}
	
	func test_loadImageData_doesNotCacheImageOnLoaderFailure() {
		let cacheSpy = ImageCacheSpy()
		let (sut, loaderSpy) = makeSUT(cache: cacheSpy)
		let url = anyURL()
		
		_ = sut.loadImageData(from: url) { _ in }
		loaderSpy.complete(with: anyNSError())
		
		XCTAssertTrue(cacheSpy.messages.isEmpty)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(cache: FeedImageDataCache = ImageCacheSpy.init(), file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderCacheDecorator, loaderSpy: FeedImageDataLoaderSpy) {
		let loaderSpy = FeedImageDataLoaderSpy()
		let sut = FeedImageDataLoaderCacheDecorator(decoratee: loaderSpy, cache: cache)
		trackForMemoryLeaks(loaderSpy)
		trackForMemoryLeaks(sut)
		
		return (sut, loaderSpy)
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
