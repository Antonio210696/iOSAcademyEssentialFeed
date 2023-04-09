//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 06/04/23.
//

import Foundation

public enum LoadFeedResult {
	case success([FeedItem])
	case failure(Error)
}

protocol FeedLoader {
	func load(completion: @escaping(LoadFeedResult) -> Void)
}

