//
//  Paginated.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 02/08/23.
//

import Foundation

public struct Paginated<Item> {
	public typealias LoadMoreCompletion = (Result<Self, Error>) -> Void
	
	public let items: [Item]
	public let loadMore: ((@escaping LoadMoreCompletion) -> Void)?
	
	public init(items: [Item], loadMore: ((LoadMoreCompletion) -> Void)? = nil) {
		self.items = items
		self.loadMore = loadMore
	}
}


