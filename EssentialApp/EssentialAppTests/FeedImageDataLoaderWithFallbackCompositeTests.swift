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
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
		return primary.loadImageData(from: url) { [weak self] result in
			switch result {
			case let .success(data):
				completion(.success(data))
				
			case .failure:
				_ = self?.fallback.loadImageData(from: url, completion: completion)
			}
		}
	}
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
	func test_loadImageData_deliversPrimaryImageDataOnPrimaryLoaderSuccess() {
		let primaryData = Data("primary".utf8)
		let fallbackData = Data("fallback".utf8)
		let sut = makeSUT(primaryResult: .success(primaryData), fallbackResult: .success(fallbackData))
		
		expect(sut, toCompleteWith: .success(primaryData))
	}
	
	func test_loadImageData_deliversFallbackImageDataOnPrimaryLoaderFailure() {
		let primaryError = anyNSError()
		let fallbackData = Data("fallback".utf8)
		let sut = makeSUT(primaryResult: .failure(primaryError), fallbackResult: .success(fallbackData))
		
		expect(sut, toCompleteWith: .success(fallbackData))
	}
	
	// MARK: - Helpers
	
	private func makeSUT(primaryResult: FeedImageDataLoader.Result, fallbackResult: FeedImageDataLoader.Result) -> FeedImageDataLoader {
		let primaryLoader = ImageLoaderStub(dataResult: primaryResult)
		let fallbackLoader = ImageLoaderStub(dataResult: fallbackResult)
		let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
		trackForMemoryLeaks(primaryLoader)
		trackForMemoryLeaks(fallbackLoader)
		trackForMemoryLeaks(sut)
		return sut
	}
	
	private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for image data to load")
		_ = sut.loadImageData(from: anyURL()) { receivedResult in
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
		wait(for: [exp], timeout: 1.0)
	}
	
	private class ImageLoaderStub: FeedImageDataLoader {
		let dataResult: FeedImageDataLoader.Result
		
		init(dataResult: FeedImageDataLoader.Result) {
			self.dataResult = dataResult
		}
		
		private struct TaskWrapper: FeedImageDataLoaderTask {
			var wrapped: Task<Void, Error>
			
			func cancel() {
				wrapped.cancel()
			}
		}
		
		func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
			return TaskWrapper(wrapped: Task {
				completion(dataResult)
			})
		}
	}
}
