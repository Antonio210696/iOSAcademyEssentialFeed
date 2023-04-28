//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 19/04/23.
//

import Foundation

struct RemoteFeedItem: Decodable {
	public let id: UUID
	public let description: String?
	public let location: String?
	public let image: URL
}
