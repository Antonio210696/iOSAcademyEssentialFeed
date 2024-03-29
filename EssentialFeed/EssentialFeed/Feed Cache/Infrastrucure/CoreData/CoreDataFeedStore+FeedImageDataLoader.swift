//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 20/05/23.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
	public func retrieve(dataForURL url: URL) throws -> Data? {
		try performSync { context in
			Result {
				try ManagedFeedImage.data(with: url, in: context)
			}
		}
	}
	
	public func insert(_ data: Data, for url: URL) throws {
		try performSync { context in
			 Result {
				try ManagedFeedImage.first(with: url, in: context)
					.map { $0.data = data }
					.map (context.save)
			 }
		}
	}
}
