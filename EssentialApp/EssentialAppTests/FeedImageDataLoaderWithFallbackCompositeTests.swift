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
		return primary.loadImageData(from: url, completion: completion)
	}
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
	func test_loadImageData_deliversPrimaryImageDataOnPrimaryLoaderSuccess() {
		let primaryData = Data("primary".utf8)
		let fallbackData = Data("fallback".utf8)
		let sut = makeSUT(primaryResult: .success(primaryData), fallbackResult: .success(fallbackData))
		
		let exp = expectation(description: "Wait for image data load")
		_ = sut.loadImageData(from: anyURL()) { result in
			switch result {
			case let .success(data):
				XCTAssertEqual(data, primaryData)
				
			case .failure:
				XCTFail("Expected success result with primary data")
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
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
	
	private func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}
	
	private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
		}
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
