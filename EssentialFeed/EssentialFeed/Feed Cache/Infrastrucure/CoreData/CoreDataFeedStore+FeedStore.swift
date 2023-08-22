//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 20/05/23.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		
		performAsync { context in
			completion(Result{
				try ManagedCache.find(in: context).map(context.delete).map(context.save)
			})
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		performAsync { context in
			completion(Result{
				let managedCache = try ManagedCache.newUniqueInstance(in: context)
				managedCache.timestamp = timestamp
				managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
				try context.save()
			})
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		performAsync { context in
			completion(Result {
				try ManagedCache.find(in: context).map {
					CachedFeed(
						feed: $0.localFeed,
						timestamp: $0.timestamp)
				}
			})
		}
	}
}
