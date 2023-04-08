//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 07/04/23.
//

import Foundation

public enum HTTPClientResult {
	case success(HTTPURLResponse)
	case failure(Error)
}

public protocol HTTPClient {
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	
	public func load(completion: @escaping (Error) -> Void) {
		// rfl is mapping an http error to a domain error
		client.get(from: url) { result in
			switch result {
			case .success:
				completion(.invalidData)
			case .failure:
				completion(.connectivity)
			}
		}
	}
}
