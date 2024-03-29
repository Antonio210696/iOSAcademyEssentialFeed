//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 23/05/23.
//

import Foundation

public protocol FeedCache {
	typealias Result = Swift.Result<Void, Error>
	
	func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
