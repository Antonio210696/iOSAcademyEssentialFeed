//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 07/04/23.
//

import Foundation

public final class RemoteFeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public typealias Result = LoadFeedResult<Error>
	
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
				completion(FeedItemsMapper.map(data, from: response))
			case .failure:
				completion(.failure(.connectivity))
			}
		}
	}
}
