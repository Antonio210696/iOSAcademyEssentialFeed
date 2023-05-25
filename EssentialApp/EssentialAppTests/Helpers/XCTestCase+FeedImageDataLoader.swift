//
//  XCTestCase+FeedImageDataLoader.swift
//  EssentialAppTests
//
//  Created by Antonio Epifani on 25/05/23.
//

import EssentialFeed
import XCTest

protocol FeedImageDataLoaderTestCase: XCTestCase { }

extension FeedImageDataLoaderTestCase {
	func expect(_ sut: FeedImageDataLoader, for url: URL, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = 0) {
		let exp = expectation(description: "Wait for load to complete")
		_ = sut.loadImageData(from: url) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedImage), .success(expectedImage)):
				XCTAssertEqual(receivedImage, expectedImage, "Expected to receive \(expectedImage), got \(receivedImage) instead", file: file, line: line)
				
			case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
				XCTAssertEqual(receivedError, expectedError, "Expected to receive error \(expectedError), got \(receivedError) instead", file: file, line: line)
				
			default:
				XCTFail("Expected result \(expectedResult), got \(receivedResult), instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		action()
		wait(for: [exp], timeout: 1.0)
	}
}
