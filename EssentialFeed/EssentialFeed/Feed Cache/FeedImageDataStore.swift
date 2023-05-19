//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 17/05/23.
//

import Foundation

public protocol FeedImageDataStore {
	typealias Result = Swift.Result<Data?, Error>
	typealias InsertionResult = Swift.Result<Void, Error>
	
	func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
	func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}
