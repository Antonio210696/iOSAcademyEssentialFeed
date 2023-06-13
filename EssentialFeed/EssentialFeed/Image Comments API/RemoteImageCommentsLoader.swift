//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 09/06/23.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
	convenience init(url: URL, client: HTTPClient) {
		self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
	}
}
