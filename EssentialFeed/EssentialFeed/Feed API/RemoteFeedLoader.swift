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
	
	public init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	
	public func load() {
		client.get(from: url)
	}
}

public protocol HTTPClient {
	func get(from url: URL)
}
