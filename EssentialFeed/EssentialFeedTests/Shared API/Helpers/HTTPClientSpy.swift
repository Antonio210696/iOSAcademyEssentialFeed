//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 16/05/23.
//

import Foundation
import EssentialFeed

final class HTTPClientSpy: HTTPClient {
	private struct Task: HTTPClientTask {
		let callback: () -> Void
		func cancel() { callback() }
	}
	
	var receivedResult: HTTPClient.Result?
	
	var requestedURLs: [URL] = []
	
	func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
		requestedURLs.append(url)
		completion(receivedResult ?? .failure(anyNSError()))
				   
		return Task { }
	}
	
	func complete(with error: Error, at index: Int = 0) {
		receivedResult = .failure(error)
	}
	
	func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
		let response = HTTPURLResponse(
			url: anyURL(),
			statusCode: code,
			httpVersion: nil,
			headerFields: nil
		)!
		
		receivedResult = .success((data, response))
	}
}
