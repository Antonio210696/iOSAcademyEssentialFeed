//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Antonio Epifani on 04/05/23.
//

import Foundation
import EssentialFeed

final class MainQueueDispatchDecorator<T> {
	private let decoratee: T
	
	init(decoratee: T) {
		self.decoratee = decoratee
	}
	
	func dispatch(completion: @escaping () -> Void) {
		guard Thread.isMainThread else {
			return DispatchQueue.main.async { completion() }
		}
		
		completion()
	}
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
	func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
		decoratee.load { [weak self] result in
			self?.dispatch { completion(result) }
		}
	}
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		return decoratee.loadImageData(from: url) { [weak self] result in
			self?.dispatch { completion(result) }
		}
	}
}
