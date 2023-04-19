//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 07/04/23.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public typealias Result = LoadFeedResult
	
	public init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	
	public func load(completion: @escaping (Result) -> Void) {
		// rfl is mapping an http error to a domain error
		client.get(from: url) { [weak self] result in
			guard  self != nil else { return }
			
			switch result {
			case let .success(data, response):
				completion(RemoteFeedLoader.map(data, from: response))
			case .failure:
				completion(.failure(RemoteFeedLoader.Error.connectivity))
			}
		}
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let items = try FeedItemsMapper.map(data, from: response)
			return .success(items.toModels())
		} catch {
			return .failure(error)
		}
	}
}

private extension Array where Element == RemoteFeedItem {
	func toModels() -> [FeedItem] {
		return map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image)}
	}
}
