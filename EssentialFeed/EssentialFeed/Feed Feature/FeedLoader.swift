//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 06/04/23.
//

import Foundation

public protocol FeedLoader {
	typealias Result = Swift.Result<[FeedImage], Error>
	
	func load(completion: @escaping(FeedLoader.Result) -> Void)
}

