//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Antonio Epifani on 21/05/23.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
	let primary: FeedImageDataLoader
	let fallback: FeedImageDataLoader
	
	init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
		self.primary = primary
		self.fallback = fallback
	}
	
	private class TaskWrapper: FeedImageDataLoaderTask {
		var wrapped: FeedImageDataLoaderTask?
		
		func cancel() {
			wrapped?.cancel()
		}
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
		var task = TaskWrapper()
		task.wrapped = primary.loadImageData(from: url) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case let .success(data):
				completion(.success(data))
				
			case .failure:
				task.wrapped = self.fallback.loadImageData(from: url, completion: completion)
			}
		}
		
		return task
	}
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
	
	func test_init_doesNotLoadImageData() {
		let primaryLoader = ImageLoaderSpy()
		let fallbackLoader = ImageLoaderSpy()
		_ = makeSUT(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
		
		XCTAssertTrue(primaryLoader.messages.isEmpty)
		XCTAssertTrue(fallbackLoader.messages.isEmpty)
	}
	
	func test_loadImageData_deliversPrimaryImageDataOnPrimaryLoaderSuccess() {
		let primaryLoader = ImageLoaderSpy()
		let fallbackLoader = ImageLoaderSpy()
		let primaryData = Data("primary".utf8)
		let url = anyURL()
		
		let sut = makeSUT(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
		
		expect(sut, for: url, toCompleteWith: .success(primaryData), when: {
			primaryLoader.completeSuccessfully(with: primaryData)
		})
		XCTAssertEqual(primaryLoader.loadedURLs, [url])
		XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty)
	}
	
	func test_loadImageData_deliversFallbackImageDataOnPrimaryLoaderFailure() {
		let primaryLoader = ImageLoaderSpy()
		let fallbackLoader = ImageLoaderSpy()
		let fallbackData = Data("fallback".utf8)
		let url = anyURL()
		
		let sut = makeSUT(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
		
		expect(sut, for: url, toCompleteWith: .success(fallbackData), when: {
			primaryLoader.complete(with: anyNSError())
			fallbackLoader.completeSuccessfully(with: fallbackData)
		})
		XCTAssertEqual(primaryLoader.loadedURLs, [url])
		XCTAssertEqual(fallbackLoader.loadedURLs, [url])
	}
	
	func test_loadImageData_deliversErrorIfOnBothLoadersFailure() {
		let primaryLoader = ImageLoaderSpy()
		let fallbackLoader = ImageLoaderSpy()
		let url = anyURL()
		
		let sut = makeSUT(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
		
		expect(sut, for: url, toCompleteWith: .failure(anyNSError()), when: {
			primaryLoader.complete(with: anyNSError())
			fallbackLoader.complete(with: anyNSError())
		})
		XCTAssertEqual(primaryLoader.loadedURLs, [url])
		XCTAssertEqual(fallbackLoader.loadedURLs, [url])
	}
	
	func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
		let primaryLoader = ImageLoaderSpy()
		let fallbackLoader = ImageLoaderSpy()
		let url = anyURL()
		
		let sut = makeSUT(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
		
		let task = sut.loadImageData(from: url) { _ in }
		task.cancel()
		
		XCTAssertEqual(primaryLoader.cancelledURLs, [url])
		XCTAssertTrue(fallbackLoader.cancelledURLs.isEmpty)
	}
	
	func test_cancelLoadImageData_cancelsFallbackLoaderTaskOnPrimaryLoaderFailure() {
		let primaryLoader = ImageLoaderSpy()
		let fallbackLoader = ImageLoaderSpy()
		let url = anyURL()
		
		let sut = makeSUT(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
		
		let task = sut.loadImageData(from: url) { _ in }
		primaryLoader.complete(with: anyNSError())
		task.cancel()
		
		XCTAssertTrue(primaryLoader.cancelledURLs.isEmpty)
		XCTAssertEqual(fallbackLoader.cancelledURLs, [url])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(primaryLoader: ImageLoaderSpy, fallbackLoader: ImageLoaderSpy) -> FeedImageDataLoader {
		let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
		trackForMemoryLeaks(primaryLoader)
		trackForMemoryLeaks(fallbackLoader)
		trackForMemoryLeaks(sut)
		return sut
	}
	
	private func expect(_ sut: FeedImageDataLoader, for url: URL, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for image data to load")
		_ = sut.loadImageData(from: url) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedData), .success(expectedData)):
				XCTAssertEqual(receivedData, expectedData, file: file, line: line)
				
			case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
				
			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}
		
		action()
		wait(for: [exp], timeout: 1.0)
	}
	
	private class ImageLoaderSpy: FeedImageDataLoader {
		typealias LoadCompletions = (FeedImageDataLoader.Result) -> Void
		var messages = [(url: URL, completion: LoadCompletions)]()
		var cancelledURLs: [URL] = []
		
		var loadedURLs: [URL] {
			messages.map { $0.url }
		}
		
		private var completions: [LoadCompletions] {
			messages.map { $0.completion }
		}
		
		private struct TaskWrapper: FeedImageDataLoaderTask {
			var wrapped: Task<Void, Error>?
			let callback: () -> Void
			
			func cancel() { callback() }
		}
		
		func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
			messages.append((url: url, completion: completion))
			return TaskWrapper() { [weak self] in
				self?.cancelledURLs.append(url)
			}
		}
		
		func complete(with error: Error, at index: Int = 0) {
			completions[index](.failure(error))
		}
		
		func completeSuccessfully(with data: Data, at index: Int = 0) {
			completions[index](.success(data))
		}
	}
}
