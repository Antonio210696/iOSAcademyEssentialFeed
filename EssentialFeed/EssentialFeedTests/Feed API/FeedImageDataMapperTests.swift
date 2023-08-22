//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 14/05/23.
//

import XCTest
import EssentialFeed

final class FeedImageDataMapperTests: XCTestCase {
	func test_map_deliversInvalidDataErrorOnNon200Response() throws {
		let samples = [199, 201, 300, 400, 500]
		
		try samples.forEach { code in
			XCTAssertThrowsError(try FeedImageDataMapper.map(anyData(), response: HTTPURLResponse(statusCode: code)))
		}
	}
	
	func test_map_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() throws {
		let emptyData = Data()
		XCTAssertThrowsError(try FeedImageDataMapper.map(emptyData, response: HTTPURLResponse(statusCode: 200)))
	}
	
	func test_map_deliversReceivedNonEmptyDataOn200HTTPResponse() {
		let nonEmptyData = Data("non empty data".utf8)
		XCTAssertNoThrow(try FeedImageDataMapper.map(nonEmptyData, response: HTTPURLResponse(statusCode: 200)))
	}
}
