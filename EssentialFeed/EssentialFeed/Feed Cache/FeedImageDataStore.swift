//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 17/05/23.
//

import Foundation

public protocol FeedImageDataStore {
	func insert(_ data: Data, for url: URL) throws
	func retrieve(dataForURL url: URL) throws -> Data?
}
