//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Antonio Epifani on 21/05/23.
//

import XCTest
import EssentialApp
import EssentialFeed

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase, FeedImageDataLoaderTestCase {
	
	func test_init_doesNotLoadImageData() {
		let (_, primaryLoader, fallbackLoader) = makeSUT()
		
		XCTAssertTrue(primaryLoader.loadedURLs.isEmpty)
		XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty)
	}
	
	func test_loadImageData_deliversPrimaryImageDataOnPrimaryLoaderSuccess() {
		let primaryData = Data("primary".utf8)
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()
		
		expect(sut, for: url, toCompleteWith: .success(primaryData), when: {
			primaryLoader.completeSuccessfully(with: primaryData)
		})
		XCTAssertEqual(primaryLoader.loadedURLs, [url])
		XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty)
	}
	
	func test_loadImageData_deliversFallbackImageDataOnPrimaryLoaderFailure() {
		let fallbackData = Data("fallback".utf8)
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()
		
		expect(sut, for: url, toCompleteWith: .success(fallbackData), when: {
			primaryLoader.complete(with: anyNSError())
			fallbackLoader.completeSuccessfully(with: fallbackData)
		})
		XCTAssertEqual(primaryLoader.loadedURLs, [url])
		XCTAssertEqual(fallbackLoader.loadedURLs, [url])
	}
	
	func test_loadImageData_deliversErrorIfOnBothLoadersFailure() {
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()
		
		expect(sut, for: url, toCompleteWith: .failure(anyNSError()), when: {
			primaryLoader.complete(with: anyNSError())
			fallbackLoader.complete(with: anyNSError())
		})
		XCTAssertEqual(primaryLoader.loadedURLs, [url])
		XCTAssertEqual(fallbackLoader.loadedURLs, [url])
	}
	
	func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()
		
		let task = sut.loadImageData(from: url) { _ in }
		task.cancel()
		
		XCTAssertEqual(primaryLoader.cancelledURLs, [url])
		XCTAssertTrue(fallbackLoader.cancelledURLs.isEmpty)
	}
	
	func test_cancelLoadImageData_cancelsFallbackLoaderTaskOnPrimaryLoaderFailure() {
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()
		
		let task = sut.loadImageData(from: url) { _ in }
		primaryLoader.complete(with: anyNSError())
		task.cancel()
		
		XCTAssertTrue(primaryLoader.cancelledURLs.isEmpty)
		XCTAssertEqual(fallbackLoader.cancelledURLs, [url])
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> (sut: FeedImageDataLoader, primaryLoader: FeedImageDataLoaderSpy, fallbackLoader: FeedImageDataLoaderSpy) {
		let primary = FeedImageDataLoaderSpy()
		let fallback = FeedImageDataLoaderSpy()
		let sut = FeedImageDataLoaderWithFallbackComposite(primary: primary, fallback: fallback)
		trackForMemoryLeaks(primary)
		trackForMemoryLeaks(fallback)
		trackForMemoryLeaks(sut)
		return (sut, primary, fallback)
	}
}
