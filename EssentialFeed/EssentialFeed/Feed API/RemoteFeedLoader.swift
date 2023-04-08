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
	}
	
	public init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	
	public func load(completion: @escaping (Error) -> Void = { _ in } ) {
		// rfl is mapping an http error to a domain error
		client.get(from: url) { error in
			completion(.connectivity)
		}
	}
}

public protocol HTTPClient {
	func get(from url: URL, completion: @escaping (Error) -> Void)
	// we don t want the same error that we have in the RemoteFeedLoader
}
