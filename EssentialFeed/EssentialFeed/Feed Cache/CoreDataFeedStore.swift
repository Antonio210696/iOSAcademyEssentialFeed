//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 24/04/23.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
	
	public init() { }
}
