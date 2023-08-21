//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 17/05/23.
//

import Foundation

public protocol FeedImageDataStore {
	typealias RetrievalResult = Swift.Result<Data?, Error>
	typealias InsertionResult = Swift.Result<Void, Error>
	
	func insert(_ data: Data, for url: URL) throws
	func retrieve(dataForURL url: URL) throws -> Data?
	
	@available(*, deprecated)
	func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
	
	@available(*, deprecated)
	func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}

public extension FeedImageDataStore {
	
	func insert(_ data: Data, for url: URL) throws {
		let group = DispatchGroup()
		group.enter()
		
		var result: InsertionResult!
		insert(data, for: url, completion: {
			result = $0
			group.leave()
		})
		
		group.wait()
		return try result.get()
		
	}
	
	func retrieve(dataForURL url: URL) throws -> Data? {
		let group = DispatchGroup()
		group.enter()
		
		var result: RetrievalResult!
		retrieve(dataForURL: url, completion: {
			result = $0
			group.leave()
		})
		
		group.wait()
		return try result.get()
	}
	
	
	func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) { }
	 
	func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) { }
}
