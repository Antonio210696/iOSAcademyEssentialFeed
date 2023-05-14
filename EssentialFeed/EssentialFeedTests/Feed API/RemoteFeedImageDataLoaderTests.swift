//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 14/05/23.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
	init(client: Any) {
		
	}
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {
	func test_init_doesNotPerformAnyURLRequest() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedImageDataLoader(client: client)
		trackForMemoryLeaks(sut)
		trackForMemoryLeaks(client)
		return (sut, client)
	}
	
	private final class HTTPClientSpy {
		var requestedURLs: [URL] = []
	}
}
