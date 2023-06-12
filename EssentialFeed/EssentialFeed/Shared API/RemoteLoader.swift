//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 12/06/23.
//

import Foundation

public final class RemoteLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public typealias Result = FeedLoader.Result
	
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
				completion(RemoteLoader.map(data, from: response))
			case .failure:
				completion(.failure(RemoteLoader.Error.connectivity))
			}
		}
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let items = try FeedItemsMapper.map(data, from: response)
			return .success(items)
		} catch {
			return .failure(Error.invalidData)
		}
	}
}
