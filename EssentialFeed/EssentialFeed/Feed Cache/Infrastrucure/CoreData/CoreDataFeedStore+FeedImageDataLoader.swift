//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 20/05/23.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
	public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
		perform { context in
			completion(Result {
				return try ManagedFeedImage.first(with: url, in: context)?.data
			})
		}
	}
	
	public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
		perform { context in
			guard let image = try? ManagedFeedImage.first(with: url, in: context) else { return }
			
			image.data = data
			try? context.save()
		}
	}
}
