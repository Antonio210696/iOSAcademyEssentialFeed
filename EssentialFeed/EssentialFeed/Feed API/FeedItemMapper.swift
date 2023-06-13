//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 09/04/23.
//

import Foundation

public final class FeedItemsMapper {
	private struct Root: Decodable {
		private let items: [RemoteFeedItem]
		
		private struct RemoteFeedItem: Decodable {
			public let id: UUID
			public let description: String?
			public let location: String?
			public let image: URL
		}
		
		var images: [FeedImage] {
			items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
		}
	}
	
	private static var OK_200: Int { return 200 }
	
	public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.isOK,
				let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteFeedLoader.Error.invalidData
		}
		
		return root.images
	}
}
