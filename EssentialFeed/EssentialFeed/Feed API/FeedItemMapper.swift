//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 09/04/23.
//

import Foundation

internal final class FeedItemsMapper {
	private struct Root: Decodable {
		let items: [Item]
		
		var feed: [FeedItem] {
			items.map { $0.item }
		}
	}
	
	private struct Item: Decodable {
		public let id: UUID
		public let description: String?
		public let location: String?
		public let image: URL
		
		var item: FeedItem {
			FeedItem(
				id: id,
				description: description,
				location: location,
				imageURL: image
			)
		}
	}
	
	private static var OK_200: Int { return 200 }
	
	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == OK_200,
				let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(.invalidData)
		}
		
		return .success(root.feed)
	}
}
