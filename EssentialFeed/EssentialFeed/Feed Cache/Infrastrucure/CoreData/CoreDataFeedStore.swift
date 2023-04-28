//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 24/04/23.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext
	
	public init(storeURL: URL, bundle: Bundle = .main) throws {
		container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
		context = container.newBackgroundContext()
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		
		perform { context in
			completion(Result{
				try ManagedCache.find(in: context).map(context.delete).map(context.save)
			})
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform { context in
			completion(Result{
				let managedCache = try ManagedCache.newUniqueInstance(in: context)
				managedCache.timestamp = timestamp
				managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
				try context.save()
			})
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		perform { context in
			do {
				if let cache = try ManagedCache.find(in: context) {
					completion(.success(CachedFeed(
						feed: cache.localFeed,
						timestamp: cache.timestamp)))
				} else {
					completion(.success(.none))
				}
			} catch {
				completion(.failure(error))
			}
		}
	}
	
	private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
		let context = self.context
		context.perform {
			action(context)
		}
	}
}


