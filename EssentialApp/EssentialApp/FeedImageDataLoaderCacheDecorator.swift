//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Antonio Epifani on 25/05/23.
//

import EssentialFeed

public final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
	private let decoratee: FeedImageDataLoader
	private let cache: FeedImageDataCache
	
	private final class Task: FeedImageDataLoaderTask {
		var wrapped: FeedImageDataLoaderTask?
		
		func cancel() {
			wrapped?.cancel()
		}
	}
	
	public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
		self.decoratee = decoratee
		self.cache = cache
	}
	
	public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		let task = Task()
		task.wrapped = decoratee.loadImageData(from: url) { [weak self] result in
			if let data = try? result.get() {
				self?.cache.save(data, for: url) { _ in }
			}
			completion(result)
		}
		
		return task
	}
}
