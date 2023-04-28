//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 06/04/23.
//

import Foundation


public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
	func load(completion: @escaping(LoadFeedResult) -> Void)
}

