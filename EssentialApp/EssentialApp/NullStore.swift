//
//  NullStore.swift
//  EssentialApp
//
//  Created by Antonio Epifani on 12/08/23.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		completion(.success(()))
	}
	
	func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		completion(.success(()))
	}
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.success(.none))
	}
	
	func retrieve(dataForURL url: URL) throws -> Data? { .none }
	
	func insert(_ data: Data, for url: URL) throws { }
}
