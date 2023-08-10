//
//  CombineHelpers.swift
//  EssentialApp
//
//  Created by Antonio Epifani on 07/06/23.
//

import Combine
import EssentialFeed

public extension HTTPClient {
	typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>
	
	func getPublisher(url: URL) -> Publisher {
		var task : HTTPClientTask?
		
		return Deferred {
			Future { completion in
				task = self.get(from: url, completion: completion)
			}
		}
		.handleEvents(receiveCancel: { task?.cancel() })
		.eraseToAnyPublisher()
	}
}

extension LocalFeedLoader {
	public typealias Publisher = AnyPublisher<[FeedImage], Error>
	
	public func loadPublisher() -> Publisher {
		return Deferred {
			Future(self.load)
		}
		.eraseToAnyPublisher()
	}
}

extension Publisher  {
	func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> where Output == Paginated<FeedImage> {
		handleEvents(receiveOutput: cache.saveIgnoringResult)
			.eraseToAnyPublisher()
	}
	
	func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> where Output == [FeedImage]  {
		handleEvents(receiveOutput: cache.saveIgnoringResult)
			.eraseToAnyPublisher()
	}
}

public extension FeedImageDataLoader {
	typealias Publisher = AnyPublisher<Data, Error>
	
	func loadImageDataPublisher(from url: URL) -> Publisher {
		var task: FeedImageDataLoaderTask?
		
		return Deferred {
			Future { completion in
				task = self.loadImageData(from: url, completion: completion)
			}
		}
		.handleEvents(receiveCancel: { task?.cancel() })
		.eraseToAnyPublisher()
	}
}

public extension Paginated {
	init(items: [Item], loadMorePublisher: (() -> AnyPublisher<Self, Error>)?) {
		self.init(items: items, loadMore: loadMorePublisher.map { publisher in
			return { completion in
				publisher().subscribe(Subscribers.Sink(receiveCompletion: { result in
					if case let .failure(error) = result {
						completion(.failure(error))
					}
				}, receiveValue: { result in
					completion(.success(result))
				}))
				
			}
		})
	}
	
	var loadMorePublisher: (() -> AnyPublisher<Self, Error>)? {
		guard let loadMore = loadMore else { return nil }
		
		return {
			Deferred {
				Future(loadMore)
			}.eraseToAnyPublisher()
		}
	}
}
extension Publisher where Output == Data {
	func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
		handleEvents(receiveOutput: { data in
			cache.saveIgnoringResult(data, for: url)
		}).eraseToAnyPublisher()
	}
}

private extension FeedCache {
	func saveIgnoringResult(_ feed: [FeedImage]) {
		save(feed) { _ in }
	}
	
	func saveIgnoringResult(_ page: Paginated<FeedImage>) {
		save(page.items) { _ in }
	}
}

private extension FeedImageDataCache {
	func saveIgnoringResult(_ data: Data, for url: URL) {
		save(data, for: url) { _ in }
	}
}

extension Publisher {
	func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
		self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
	}
}
